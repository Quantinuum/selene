#include "llvm/Config/llvm-config.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"

#include <algorithm>
#include <string>
#include <vector>

int main(int argc, char **argv) {
    llvm::InitLLVM initialise(argc, argv);
    if (argc == 2 && llvm::StringRef(argv[1]) == "--version") {
        llvm::outs() << "selene-llvm (LLVM " << LLVM_VERSION_STRING << ")\n";
        return 0;
    }
    if ((argc != 2 && argc != 3) || llvm::StringRef(argv[1]) != "inspect") {
        llvm::errs() << "Usage: selene-llvm inspect [FILE|-]\n";
        return 2;
    }

    // LLVM reads either textual IR or bitcode from the same buffer. Reading
    // stdin through MemoryBuffer also keeps bitcode intact on Windows, where
    // reading a binary stream in text mode would change its bytes.
    auto input = llvm::MemoryBuffer::getFileOrSTDIN(argc == 3 ? argv[2] : "-");
    if (!input) {
        llvm::errs() << "Cannot read LLVM module: " << input.getError().message() << "\n";
        return 1;
    }
    llvm::LLVMContext context;
    llvm::SMDiagnostic diagnostic;
    auto module = llvm::parseIR((*input)->getMemBufferRef(), diagnostic, context);
    if (!module) {
        diagnostic.print(argv[0], llvm::errs());
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
    std::sort(definitions.begin(), definitions.end());
    std::sort(declarations.begin(), declarations.end());
    llvm::json::Array definedFunctions;
    llvm::json::Array declaredFunctions;
    for (const auto &name : definitions) {
        definedFunctions.push_back(name);
    }
    for (const auto &name : declarations) {
        declaredFunctions.push_back(name);
    }
    llvm::json::Object result{
        {"schema_version", 1},
        {"defined_functions", std::move(definedFunctions)},
        {"declared_functions", std::move(declaredFunctions)},
    };
    llvm::outs() << llvm::json::Value(std::move(result)) << "\n";
    return 0;
}
