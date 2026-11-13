use std::fmt::{self, Write};

/// One source or object that refers to, or defines, a linker symbol.
#[derive(Clone, Debug)]
#[cfg_attr(
    feature = "python",
    pyo3::pyclass(frozen, get_all, skip_from_py_object, module = "selene_toolchain")
)]
pub struct LinkReference {
    pub relation: String,
    pub source: Option<String>,
    pub line: Option<u32>,
    pub column: Option<u32>,
    pub artifact: Option<String>,
    pub function: Option<String>,
    pub context: Option<String>,
}

/// A diagnostic parsed from LLD's text output. Unrecognised lines are kept in details.
#[derive(Clone, Debug)]
#[cfg_attr(
    feature = "python",
    pyo3::pyclass(frozen, get_all, skip_from_py_object, module = "selene_toolchain")
)]
pub struct LinkDiagnostic {
    pub severity: String,
    pub kind: String,
    pub message: String,
    pub symbol: Option<String>,
    pub references: Vec<LinkReference>,
    pub details: Vec<String>,
}

/// A linker failure with structured diagnostics and the original LLD output.
#[derive(Debug, thiserror::Error)]
#[error("link failed:\n{diagnostics}")]
pub struct LinkError {
    pub entries: Vec<LinkDiagnostic>,
    pub diagnostics: String,
    pub raw_diagnostics: String,
    pub inputs: Vec<String>,
}

impl LinkError {
    pub(crate) fn from_lld(raw_diagnostics: String, text: &str, inputs: Vec<String>) -> Self {
        let entries = parse(text, &inputs);
        let diagnostics = entries
            .iter()
            .map(ToString::to_string)
            .collect::<Vec<_>>()
            .join("\n\n");
        Self {
            entries,
            diagnostics,
            raw_diagnostics,
            inputs,
        }
    }
}

fn diagnostic(severity: &str, message: &str) -> LinkDiagnostic {
    let (kind, symbol) = if let Some(symbol) = message.strip_prefix("undefined symbol: ") {
        ("undefined_symbol", Some(symbol.to_owned()))
    } else if let Some(symbol) = message.strip_prefix("duplicate symbol: ") {
        ("duplicate_symbol", Some(symbol.to_owned()))
    } else {
        ("other", None)
    };
    LinkDiagnostic {
        severity: severity.into(),
        kind: kind.into(),
        message: message.into(),
        symbol,
        references: vec![],
        details: vec![],
    }
}

fn header(line: &str) -> Option<(&str, &str)> {
    let line = ["ld.lld: ", "ld64.lld: ", "lld-link: ", "lld: "]
        .iter()
        .find_map(|prefix| line.strip_prefix(prefix))
        .unwrap_or(line);
    for severity in ["error", "warning", "note"] {
        if let Some(message) = line
            .strip_prefix(severity)
            .and_then(|s| s.strip_prefix(": "))
        {
            return Some((severity, message));
        }
    }
    if line.starts_with("undefined symbol: ") || line.starts_with("duplicate symbol: ") {
        return Some(("error", line));
    }
    None
}

fn reference(relation: &str) -> LinkReference {
    LinkReference {
        relation: relation.into(),
        source: None,
        line: None,
        column: None,
        artifact: None,
        function: None,
        context: None,
    }
}

fn object_location(text: &str, inputs: &[String]) -> Option<(String, Option<String>)> {
    if let Some((artifact, context)) = text.rsplit_once(":(")
        && let Some(context) = context.strip_suffix(')')
    {
        return Some((artifact.into(), Some(context.into())));
    }
    if inputs.iter().any(|input| input == text)
        || [".o", ".obj", ".a", ".lib"]
            .iter()
            .any(|suffix| text.ends_with(suffix))
        || ((text.contains(".a(") || text.contains(".lib(")) && text.ends_with(')'))
    {
        return Some((text.into(), None));
    }
    None
}

fn set_object(reference: &mut LinkReference, artifact: String, context: Option<String>) {
    reference.artifact = Some(artifact);
    reference.function = context.as_deref().and_then(|text| {
        let text = text.strip_prefix("symbol ").unwrap_or(text);
        let function = text.split_once("+0x").map_or(text, |(name, _)| name);
        if function.is_empty() || function.starts_with('.') {
            None
        } else {
            Some(function.into())
        }
    });
    reference.context = context;
}

fn source_location(text: &str) -> (String, Option<u32>, Option<u32>) {
    // ELF can print both a short and a full source location. Prefer the full
    // location when the parenthetical text ends in a numeric line number.
    let text = text
        .rsplit_once(" (")
        .and_then(|(_, full)| full.strip_suffix(')'))
        .filter(|full| {
            full.rsplit_once(':')
                .is_some_and(|(_, n)| n.parse::<u32>().is_ok())
        })
        .unwrap_or(text);
    if let Some((file, last)) = text.rsplit_once(':')
        && !file.is_empty()
        && let Ok(number) = last.parse::<u32>()
    {
        if let Some((file, line)) = file.rsplit_once(':')
            && !file.is_empty()
            && let Ok(line) = line.parse::<u32>()
        {
            return (file.into(), Some(line), Some(number));
        }
        return (file.into(), Some(number), None);
    }
    (text.into(), None, None)
}

fn function_location<'a>(text: &'a str, inputs: &[String]) -> Option<(&'a str, &'a str)> {
    if inputs.iter().any(|input| input == text) {
        return None;
    }
    // Input filenames can themselves contain " in ". Prefer the longest
    // known filename before considering a generic function/object pair.
    inputs
        .iter()
        .filter_map(|input| {
            text.strip_suffix(input).and_then(|prefix| {
                prefix
                    .strip_suffix(" in ")
                    .map(|function| (function, &text[text.len() - input.len()..]))
            })
        })
        .max_by_key(|(_, artifact)| artifact.len())
        .or_else(|| {
            text.rsplit_once(" in ")
                .filter(|(_, artifact)| object_location(artifact, inputs).is_some())
        })
}

fn parse(text: &str, inputs: &[String]) -> Vec<LinkDiagnostic> {
    let mut entries: Vec<LinkDiagnostic> = vec![];
    for line in text.lines() {
        if let Some((severity, message)) = header(line) {
            entries.push(diagnostic(severity, message));
            continue;
        }
        if line.trim().is_empty() {
            continue;
        }
        if entries.is_empty() {
            entries.push(diagnostic("error", line));
            continue;
        }
        let entry = entries.last_mut().unwrap();
        let continuation = line.trim_start().strip_prefix(">>>").map(str::trim);
        let body = continuation.unwrap_or(line.trim());
        if body.starts_with("did you mean:")
            || (body.starts_with("defined in ") && entry.kind != "duplicate_symbol")
        {
            entry.details.push(body.into());
            continue;
        }
        if let Some((relation, location)) = body
            .strip_prefix("referenced by ")
            .map(|s| ("referenced_by", s))
            .or_else(|| body.strip_prefix("defined at ").map(|s| ("defined_at", s)))
            .or_else(|| body.strip_prefix("defined in ").map(|s| ("defined_at", s)))
        {
            let mut item = reference(relation);
            if let Some((artifact, context)) = object_location(location, inputs) {
                set_object(&mut item, artifact, context);
            } else {
                let (file, line, column) = source_location(location);
                item.source = Some(file);
                item.line = line;
                item.column = column;
            }
            entry.references.push(item);
        } else if let Some((function, artifact)) = function_location(body, inputs) {
            let mut item = reference("referenced_by");
            set_object(&mut item, artifact.into(), Some(function.trim().into()));
            entry.references.push(item);
        } else if let Some((artifact, context)) = object_location(body, inputs) {
            if let Some(item) = entry.references.last_mut().filter(|r| r.artifact.is_none()) {
                set_object(item, artifact, context);
            } else {
                let mut item = reference("referenced_by");
                set_object(&mut item, artifact, context);
                entry.references.push(item);
            }
        } else {
            // Suggestions, truncation notices and future LLD formats still
            // belong in the displayed error, even when we can't classify them.
            entry.details.push(continuation.unwrap_or(line).to_owned());
        }
    }
    if entries.is_empty() {
        entries.push(diagnostic(
            "error",
            "The linker failed without a diagnostic",
        ));
    }
    entries
}

impl fmt::Display for LinkDiagnostic {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let prefix = match self.severity.as_str() {
            "warning" => "Warning: ",
            "note" => "Note: ",
            _ => "",
        };
        match (self.kind.as_str(), &self.symbol) {
            ("undefined_symbol", Some(symbol)) => write!(f, "{prefix}Undefined symbol `{symbol}`")?,
            ("duplicate_symbol", Some(symbol)) => write!(f, "{prefix}Duplicate symbol `{symbol}`")?,
            _ => write!(f, "{prefix}{}", self.message)?,
        }
        for reference in &self.references {
            let relation = if reference.relation == "defined_at" {
                "Defined"
            } else {
                "Referenced"
            };
            let mut location = String::new();
            if let Some(source) = &reference.source {
                location.push_str(source);
                if let Some(line) = reference.line {
                    write!(location, ":{line}")?;
                }
                if let Some(column) = reference.column {
                    write!(location, ":{column}")?;
                }
            }
            match (&reference.function, &reference.artifact) {
                (Some(function), Some(artifact)) => {
                    let position = reference.context.as_deref().unwrap_or(function);
                    let position = position.strip_prefix("symbol ").unwrap_or(position);
                    if reference.relation == "defined_at" {
                        write!(f, "\n  Defined in {artifact} ({position})")?;
                    } else {
                        write!(f, "\n  Referenced by {position} in {artifact}")?;
                    }
                }
                (_, Some(artifact)) => {
                    write!(f, "\n  {relation} in {artifact}")?;
                    if let Some(context) = &reference.context {
                        write!(f, " ({context})")?;
                    }
                }
                _ => {
                    write!(f, "\n  {relation} at {location}")?;
                    location.clear();
                }
            }
            if !location.is_empty() {
                write!(f, "\n    at {location}")?;
            }
        }
        for detail in &self.details {
            write!(f, "\n  {detail}")?;
        }
        Ok(())
    }
}

#[cfg(feature = "python")]
#[pyo3::pymethods]
impl LinkDiagnostic {
    fn __str__(&self) -> String {
        self.to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn error(text: &str) -> LinkError {
        LinkError::from_lld(
            text.into(),
            text,
            vec!["caller.o".into(), "library.a".into()],
        )
    }

    #[test]
    fn elf_references_have_source_locations_and_functions() {
        let error = error(
            "ld.lld: error: undefined symbol: missing\n>>> referenced by caller.c:12:3 (/src/caller.c:12:3)\n>>> caller.o:(main)\n>>> referenced 2 more times\n",
        );
        let entry = &error.entries[0];
        assert_eq!(entry.kind, "undefined_symbol");
        assert_eq!(entry.symbol.as_deref(), Some("missing"));
        let reference = &entry.references[0];
        assert_eq!(reference.source.as_deref(), Some("/src/caller.c"));
        assert_eq!(reference.line, Some(12));
        assert_eq!(reference.column, Some(3));
        assert_eq!(reference.function.as_deref(), Some("main"));
        assert_eq!(reference.artifact.as_deref(), Some("caller.o"));
        assert_eq!(entry.details, ["referenced 2 more times"]);
        assert_eq!(
            error.diagnostics,
            "Undefined symbol `missing`\n  Referenced by main in caller.o\n    at /src/caller.c:12:3\n  referenced 2 more times"
        );
    }

    #[test]
    fn coff_preserves_decorated_symbols_and_drive_letters() {
        let error = error(
            "lld-link: error: undefined symbol: __declspec(dllimport) missing\r\n>>> referenced by C:\\src\\caller.cpp:15\r\n>>> caller.o:(main)\r\n",
        );
        let entry = &error.entries[0];
        assert_eq!(
            entry.symbol.as_deref(),
            Some("__declspec(dllimport) missing")
        );
        assert_eq!(
            entry.references[0].source.as_deref(),
            Some(r"C:\src\caller.cpp")
        );
        assert_eq!(entry.references[0].line, Some(15));
        assert_eq!(entry.references[0].column, None);
    }

    #[test]
    fn macho_symbol_offsets_remain_visible() {
        let error = error(
            "ld64.lld: error: undefined symbol: _missing\n>>> referenced by caller.o:(symbol _main+0x5)\n",
        );
        let reference = &error.entries[0].references[0];
        assert_eq!(reference.function.as_deref(), Some("_main"));
        assert_eq!(reference.context.as_deref(), Some("symbol _main+0x5"));
        assert!(error.diagnostics.contains("_main+0x5 in caller.o"));
    }

    #[test]
    fn multiline_function_references_are_parsed() {
        let error = error("ld64.lld: error: undefined symbol: _missing\n    _main in caller.o\n");
        let reference = &error.entries[0].references[0];
        assert_eq!(reference.function.as_deref(), Some("_main"));
        assert_eq!(reference.artifact.as_deref(), Some("caller.o"));
    }

    #[test]
    fn duplicate_definitions_and_warnings_are_separate_entries() {
        let error = error(
            "ld.lld: warning: library has no symbols\nld.lld: error: duplicate symbol: answer\n>>> defined at first.c:4\n>>> caller.o:(answer)\n>>> defined at second.c:8\n>>> library.a(member.o):(.text+0x0)\nld.lld: error: too many errors emitted\n",
        );
        assert_eq!(error.entries.len(), 3);
        assert_eq!(error.entries[0].severity, "warning");
        let duplicate = &error.entries[1];
        assert_eq!(duplicate.kind, "duplicate_symbol");
        assert_eq!(duplicate.symbol.as_deref(), Some("answer"));
        assert_eq!(duplicate.references.len(), 2);
        assert!(
            duplicate
                .references
                .iter()
                .all(|r| r.relation == "defined_at")
        );
        assert_eq!(
            duplicate.references[1].artifact.as_deref(),
            Some("library.a(member.o)")
        );
        assert_eq!(duplicate.references[1].function, None);
        assert!(
            error
                .diagnostics
                .contains("Warning: library has no symbols")
        );
        assert!(error.diagnostics.contains("too many errors emitted"));
    }

    #[test]
    fn unfamiliar_text_is_kept_visible() {
        let raw = "future linker failure format\n  more information\n>>> unfamiliar detail\n";
        let error = error(raw);
        assert_eq!(error.raw_diagnostics, raw);
        assert_eq!(error.entries[0].kind, "other");
        for text in [
            "future linker failure format",
            "more information",
            "unfamiliar detail",
        ] {
            assert!(error.diagnostics.contains(text));
        }
    }

    #[test]
    fn filenames_containing_in_are_not_function_references() {
        let text =
            "ld.lld: error: undefined symbol: missing\n>>> referenced by code in project.o\n";
        let error = LinkError::from_lld(text.into(), text, vec!["code in project.o".into()]);
        let reference = &error.entries[0].references[0];
        assert_eq!(reference.artifact.as_deref(), Some("code in project.o"));
        assert_eq!(reference.function, None);
    }

    #[test]
    fn functions_in_filenames_with_spaces_keep_the_whole_filename() {
        let text = "ld64.lld: error: undefined symbol: _missing\n    _main in code in project.o\n";
        let error = LinkError::from_lld(text.into(), text, vec!["code in project.o".into()]);
        let reference = &error.entries[0].references[0];
        assert_eq!(reference.artifact.as_deref(), Some("code in project.o"));
        assert_eq!(reference.function.as_deref(), Some("_main"));
    }

    #[test]
    fn suggestions_are_not_mistaken_for_references() {
        let error = error(
            "ld.lld: error: undefined symbol: missing\n>>> did you mean: candidate\n>>> defined in caller.o\n",
        );
        assert!(error.entries[0].references.is_empty());
        assert_eq!(
            error.entries[0].details,
            ["did you mean: candidate", "defined in caller.o"]
        );
    }
}
