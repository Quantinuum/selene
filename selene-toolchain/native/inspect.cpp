#include "llvm/Config/llvm-config.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Object/ELFObjectFile.h"
#include "llvm/Object/ObjectFile.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"

#include <algorithm>
#include <string>
#include <vector>

static int printSymbols(std::vector<std::string> definitions,
                        std::vector<std::string> declarations,
                        llvm::StringRef definedKey, llvm::StringRef undefinedKey) {
    std::sort(definitions.begin(), definitions.end());
    definitions.erase(std::unique(definitions.begin(), definitions.end()), definitions.end());
    std::sort(declarations.begin(), declarations.end());
    declarations.erase(std::unique(declarations.begin(), declarations.end()), declarations.end());
    llvm::json::Array definedSymbols;
    llvm::json::Array undefinedSymbols;
    for (const auto &name : definitions) {
        definedSymbols.push_back(name);
    }
    for (const auto &name : declarations) {
        undefinedSymbols.push_back(name);
    }
    llvm::json::Object result{
        {"schema_version", 1},
        {definedKey, std::move(definedSymbols)},
        {undefinedKey, std::move(undefinedSymbols)},
    };
    llvm::outs() << llvm::json::Value(std::move(result)) << "\n";
    return 0;
}

static int inspectModule(llvm::MemoryBufferRef input) {
    llvm::LLVMContext context;
    llvm::SMDiagnostic diagnostic;
    auto module = llvm::parseIR(input, diagnostic, context);
    if (!module) {
        diagnostic.print("selene-llvm", llvm::errs());
        return 1;
    }

    std::vector<std::string> definitions;
    std::vector<std::string> declarations;
    // We need the module's functions, rather than its linker symbol table.
    // This includes unused declarations and internal functions, but leaves
    // globals and aliases out of the results.
    for (const auto &function : *module) {
        auto name = function.getName();
        if (name.starts_with("llvm.")) {
            continue;
        }
        if (!llvm::json::isUTF8(name)) {
            llvm::errs() << "LLVM function names must be valid UTF-8\n";
            return 1;
        }
        auto &names = function.isDeclaration() ? declarations : definitions;
        names.push_back(name.str());
    }
    return printSymbols(std::move(definitions), std::move(declarations),
                        "defined_functions", "declared_functions");
}

static int inspectObject(llvm::MemoryBufferRef input) {
    auto object = llvm::object::ObjectFile::createObjectFile(input);
    if (!object) {
        llvm::errs() << "Cannot parse object file: " << llvm::toString(object.takeError()) << "\n";
        return 1;
    }
    auto &file = **object;
    if (!file.isELF() && !file.isMachO() && !file.isCOFF()) {
        llvm::errs() << "Unsupported object format: expected ELF, Mach-O or PE/COFF\n";
        return 1;
    }
    std::vector<std::string> definitions;
    std::vector<std::string> declarations;
    auto addSymbol = [&](const llvm::object::SymbolRef &symbol) {
        auto name = symbol.getName();
        if (!name) {
            llvm::errs() << "Cannot read object symbol: " << llvm::toString(name.takeError()) << "\n";
            return false;
        }
        auto flags = symbol.getFlags();
        if (!flags) {
            llvm::errs() << "Cannot read object symbol flags: "
                         << llvm::toString(flags.takeError()) << "\n";
            return false;
        }
        llvm::StringRef symbolName = *name;
        if (file.isMachO() && symbolName.starts_with("_")) {
            symbolName = symbolName.drop_front();
        }
        if (symbolName.empty()) {
            return true;
        }
        if (!llvm::json::isUTF8(symbolName)) {
            llvm::errs() << "Object symbol names must be valid UTF-8\n";
            return false;
        }
        // Common symbols provide storage even though some formats encode
        // them like undefined symbols. Weak definitions also remain defined.
        bool undefined = (*flags & llvm::object::SymbolRef::SF_Undefined) &&
                         !(*flags & llvm::object::SymbolRef::SF_Common);
        auto &names = undefined ? declarations : definitions;
        names.push_back(symbolName.str());
        return true;
    };
    // Object inspection includes data and aliases as well as functions.
    for (const auto &symbol : file.symbols()) {
        if (!addSymbol(symbol)) {
            return 1;
        }
    }
    if (const auto *elf = llvm::dyn_cast<llvm::object::ELFObjectFileBase>(&file)) {
        // A stripped shared library can have only a dynamic symbol table.
        // Include that table too; the JSON writer removes duplicate names.
        for (const auto &symbol : elf->getDynamicSymbolIterators()) {
            if (!addSymbol(symbol)) {
                return 1;
            }
        }
    }
    return printSymbols(std::move(definitions), std::move(declarations),
                        "defined_symbols", "undefined_symbols");
}

int main(int argc, char **argv) {
    llvm::InitLLVM initialise(argc, argv);
    llvm::StringRef command = argc > 1 ? argv[1] : "";
    if (argc == 2 && command == "--version") {
        llvm::outs() << "selene-llvm (LLVM " << LLVM_VERSION_STRING << ")\n";
        return 0;
    }
    if ((argc != 2 && argc != 3) || (command != "inspect" && command != "inspect-object")) {
        llvm::errs() << "Usage: selene-llvm inspect [FILE|-]\n"
                        "       selene-llvm inspect-object [FILE|-]\n";
        return 2;
    }
    // MemoryBuffer preserves binary stdin on Windows as well as Unix.
    auto input = llvm::MemoryBuffer::getFileOrSTDIN(argc == 3 ? argv[2] : "-");
    if (!input) {
        llvm::errs() << (command == "inspect" ? "Cannot read LLVM module: " : "Cannot read object file: ")
                     << input.getError().message() << "\n";
        return 1;
    }
    return command == "inspect" ? inspectModule((*input)->getMemBufferRef())
                                : inspectObject((*input)->getMemBufferRef());
}
