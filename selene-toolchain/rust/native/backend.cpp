#include "llvm/Config/llvm-config.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Object/ELFObjectFile.h"
#include "llvm/Object/ObjectFile.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/Error.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
#include "lld/Common/Driver.h"

#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <mutex>
#include <string>
#include <vector>

#ifdef _WIN32
#define ST_EXPORT __declspec(dllexport)
LLD_HAS_DRIVER(mingw)
LLD_HAS_DRIVER(coff)
#elif defined(__APPLE__)
#define ST_EXPORT __attribute__((visibility("default")))
LLD_HAS_DRIVER(macho)
#else
#define ST_EXPORT __attribute__((visibility("default")))
LLD_HAS_DRIVER(elf)
#endif

// Only this C interface crosses the Rust/C++ boundary. Memory is freed by the
// library that allocated it, including when the two sides use different CRTs.
extern "C" {
struct STBuffer { unsigned char *data; size_t length; int status; };
ST_EXPORT STBuffer st_call(const char *, const unsigned char *, size_t, const char *);
ST_EXPORT void st_free(STBuffer);
ST_EXPORT unsigned st_abi_version();
ST_EXPORT void st_shutdown();
}

static std::mutex backendMutex;
static bool usable = true;

static STBuffer buffer(llvm::StringRef text, int status = 0) {
    auto *data = static_cast<unsigned char *>(std::malloc(text.size() + 1));
    if (!data) return {nullptr, 0, 1};
    std::memcpy(data, text.data(), text.size());
    return {data, text.size(), status};
}

static STBuffer json(llvm::json::Value value) {
    std::string text;
    llvm::raw_string_ostream out(text);
    out << value;
    return buffer(text);
}

static STBuffer symbols(llvm::MemoryBufferRef input, bool moduleInput) {
    std::vector<std::string> defined, undefined;
    auto add = [&](llvm::StringRef name, bool declaration) {
        if (!llvm::json::isUTF8(name)) return false;
        if (!name.empty()) (declaration ? undefined : defined).push_back(name.str());
        return true;
    };
    llvm::json::Object result{{"schema_version", 1}};
    if (moduleInput) {
        llvm::LLVMContext context;
        llvm::SMDiagnostic diagnostic;
        auto module = llvm::parseIR(input, diagnostic, context);
        if (!module) {
            std::string error;
            llvm::raw_string_ostream out(error);
            diagnostic.print("LLVM module inspection failed", out);
            return buffer(error, 1);
        }
        result["target"] = module->getTargetTriple().str();
        for (const auto &function : *module) {
            if (!function.getName().starts_with("llvm.") &&
                !add(function.getName(), function.isDeclaration()))
                return buffer("LLVM function names must be valid UTF-8", 1);
        }
    } else {
        auto object = llvm::object::ObjectFile::createObjectFile(input);
        if (!object) return buffer("Cannot parse object file: " + llvm::toString(object.takeError()), 1);
        auto &file = **object;
        if (!file.isELF() && !file.isMachO() && !file.isCOFF())
            return buffer("Unsupported object format: expected ELF, Mach-O or PE/COFF", 1);
        result["target"] = file.makeTriple().str();
        result["format"] = file.isELF() ? "ELF" : file.isMachO() ? "MachO" : "COFF";
        auto visit = [&](const llvm::object::SymbolRef &symbol) {
            auto name = symbol.getName();
            if (!name) return llvm::toString(name.takeError());
            auto flags = symbol.getFlags();
            if (!flags) return llvm::toString(flags.takeError());
            auto normalised = *name;
            if (file.isMachO() && normalised.starts_with("_")) normalised = normalised.drop_front();
            bool declaration = (*flags & llvm::object::SymbolRef::SF_Undefined) &&
                               !(*flags & llvm::object::SymbolRef::SF_Common);
            if (!add(normalised, declaration)) return std::string("Object symbol names must be valid UTF-8");
            return std::string();
        };
        for (const auto &symbol : file.symbols()) {
            auto error = visit(symbol);
            if (!error.empty()) return buffer(error, 1);
        }
        if (auto *elf = llvm::dyn_cast<llvm::object::ELFObjectFileBase>(&file)) {
            for (const auto &symbol : elf->getDynamicSymbolIterators()) {
                auto error = visit(symbol);
                if (!error.empty()) return buffer(error, 1);
            }
        }
    }
    auto array = [](std::vector<std::string> &names) {
        std::sort(names.begin(), names.end());
        names.erase(std::unique(names.begin(), names.end()), names.end());
        llvm::json::Array items;
        for (auto &name : names) items.push_back(name);
        return items;
    };
    result[moduleInput ? "defined_functions" : "defined_symbols"] = array(defined);
    result[moduleInput ? "declared_functions" : "undefined_symbols"] = array(undefined);
    return json(std::move(result));
}

static STBuffer compile(llvm::MemoryBufferRef input, const llvm::json::Object &options) {
    llvm::LLVMContext context;
    llvm::SMDiagnostic diagnostic;
    auto module = llvm::parseIR(input, diagnostic, context);
    if (!module) {
        std::string error;
        llvm::raw_string_ostream out(error);
        diagnostic.print("Cannot compile LLVM module", out);
        return buffer(error, 1);
    }
    std::string error;
    llvm::raw_string_ostream errors(error);
    if (llvm::verifyModule(*module, &errors)) return buffer(error, 1);
    auto triple = options.getString("target");
    auto level = options.getInteger("optimisation");
    if (!triple || !level || *level < 0 || *level > 3) return buffer("Invalid compilation options", 1);
    llvm::Triple targetTriple(*triple);
    auto *target = llvm::TargetRegistry::lookupTarget(targetTriple.str(), error);
    if (!target) return buffer(error, 1);
    llvm::TargetOptions targetOptions;
    targetOptions.UseInitArray = true;
    auto machine = std::unique_ptr<llvm::TargetMachine>(target->createTargetMachine(
        targetTriple, "generic", "", targetOptions, llvm::Reloc::PIC_, std::nullopt,
        static_cast<llvm::CodeGenOptLevel>(*level)));
    if (!machine) return buffer("Cannot create target machine", 1);
    // Retargeting arbitrary IR is not safe. Permit absent target metadata and
    // compatible triples, but reject an incompatible architecture or OS.
    const auto &original = module->getTargetTriple();
    const bool retarget = options.getBoolean("retarget").value_or(false);
    if (!retarget && !original.str().empty() &&
        (original.getArch() != targetTriple.getArch() || original.getOS() != targetTriple.getOS() ||
         original.getEnvironment() != targetTriple.getEnvironment()))
        return buffer("LLVM module target is incompatible with the requested target", 1);
    auto layout = machine->createDataLayout();
    if (!retarget && !module->getDataLayoutStr().empty() && module->getDataLayout() != layout)
        return buffer("LLVM module data layout is incompatible with the requested target", 1);
    module->setTargetTriple(targetTriple);
    module->setDataLayout(layout);
    for (auto &function : *module) function.addFnAttr("frame-pointer", "all");
    if (*level) {
        llvm::LoopAnalysisManager loops;
        llvm::FunctionAnalysisManager functions;
        llvm::CGSCCAnalysisManager cgscc;
        llvm::ModuleAnalysisManager modules;
        llvm::PassBuilder passes(machine.get());
        passes.registerModuleAnalyses(modules);
        passes.registerCGSCCAnalyses(cgscc);
        passes.registerFunctionAnalyses(functions);
        passes.registerLoopAnalyses(loops);
        passes.crossRegisterProxies(loops, functions, cgscc, modules);
        auto optimisation = *level == 1 ? llvm::OptimizationLevel::O1 :
                            *level == 2 ? llvm::OptimizationLevel::O2 : llvm::OptimizationLevel::O3;
        auto pipeline = passes.buildPerModuleDefaultPipeline(optimisation);
        pipeline.run(*module, modules);
    }
    llvm::SmallVector<char, 0> bytes;
    llvm::raw_svector_ostream output(bytes);
    llvm::legacy::PassManager passes;
    if (machine->addPassesToEmitFile(passes, output, nullptr, llvm::CodeGenFileType::ObjectFile))
        return buffer("The target cannot emit object files", 1);
    passes.run(*module);
    return buffer(llvm::StringRef(bytes.data(), bytes.size()));
}

extern "C" ST_EXPORT STBuffer st_call(const char *operation, const unsigned char *data,
                                       size_t length, const char *configuration) {
    // LLD and LLVM have process-wide state. Serialise entry across all Rust
    // toolchain instances, including callers that have released Python's GIL.
    std::lock_guard<std::mutex> guard(backendMutex);
    static bool initialised = false;
    if (!usable) return buffer("LLVM backend is unusable after a fatal linker failure", 1);
    if (!initialised) {
        llvm::InitializeAllTargetInfos();
        llvm::InitializeAllTargets();
        llvm::InitializeAllTargetMCs();
        llvm::InitializeAllAsmPrinters();
        llvm::InitializeAllAsmParsers();
        initialised = true;
    }
    llvm::StringRef op(operation);
    // LLVM's textual parser expects a trailing NUL, including for an empty
    // module. Rust slices don't promise one, so give LLVM an owned buffer.
    auto memory = llvm::MemoryBuffer::getMemBufferCopy(
        llvm::StringRef(reinterpret_cast<const char *>(data), length), "input");
    auto input = memory->getMemBufferRef();
    if (op == "version") return buffer(LLVM_VERSION_STRING);
    if (op == "inspect") return symbols(input, true);
    if (op == "inspect-object") return symbols(input, false);
    auto options = llvm::json::parse(configuration);
    if (!options) return buffer(llvm::toString(options.takeError()), 1);
    if (op == "compile" && options->getAsObject()) return compile(input, *options->getAsObject());
    if (op == "link" && options->getAsArray()) {
        std::vector<std::string> storage;
        for (const auto &arg : *options->getAsArray()) {
            if (!arg.getAsString()) return buffer("Link arguments must be strings", 1);
            storage.push_back(arg.getAsString()->str());
        }
        std::vector<const char *> args;
        for (const auto &arg : storage) args.push_back(arg.c_str());
        std::string diagnostics;
        llvm::raw_string_ostream output(diagnostics);
#ifdef _WIN32
        const lld::DriverDef drivers[] = {{lld::MinGW, &lld::mingw::link}, {lld::WinLink, &lld::coff::link}};
#elif defined(__APPLE__)
        const lld::DriverDef drivers[] = {{lld::Darwin, &lld::macho::link}};
#else
        const lld::DriverDef drivers[] = {{lld::Gnu, &lld::elf::link}};
#endif
        auto result = lld::lldMain(args, output, output, drivers);
        usable = result.canRunAgain;
        if (!usable) diagnostics += "\nLLVM backend disabled after a fatal linker failure";
        return buffer(diagnostics, result.retCode || !usable ? 1 : 0);
    }
    return buffer("Unsupported LLVM operation or invalid options", 1);
}

extern "C" ST_EXPORT void st_free(STBuffer value) { std::free(value.data); }

extern "C" ST_EXPORT unsigned st_abi_version() { return 1; }

extern "C" ST_EXPORT void st_shutdown() {
    std::lock_guard<std::mutex> guard(backendMutex);
    static bool stopped = false;
    if (stopped) return;
    stopped = true;
    usable = false;
    // Stop LLVM's workers before Windows starts unloading the DLL. Waiting
    // for them from a DLL destructor can deadlock under the loader lock.
    llvm::llvm_shutdown();
}
