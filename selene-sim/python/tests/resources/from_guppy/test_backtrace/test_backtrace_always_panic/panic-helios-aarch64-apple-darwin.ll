; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"s_This shoul.4464F519.0" = private constant [25 x i8] c"\18This should always panic"

; Function Attrs: noreturn
define void @__hugr__.__main__.main.1() local_unnamed_addr #0 !dbg !4 {
alloca_block:
  tail call void @panic(i32 1001, ptr nonnull @"s_This shoul.4464F519.0"), !dbg !8
  unreachable
}

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

; Function Attrs: noreturn
define noundef i64 @qmain(i64 %0) local_unnamed_addr #0 !dbg !9 {
entry:
  tail call void @setup(i64 %0), !dbg !14
  tail call void @panic(i32 1001, ptr nonnull @"s_This shoul.4464F519.0"), !dbg !15
  unreachable
}

declare void @setup(i64) local_unnamed_addr

attributes #0 = { noreturn }

!llvm.module.flags = !{!0}
!llvm.dbg.cu = !{!1}
!name = !{!3}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_Python, file: !2, producer: "guppylang (guppylang-internals-v1.0.2)-v1.0.2", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug)
!2 = !DIFile(filename: "/sanitized/path/program.py", directory: "/sanitized/path")
!3 = !{!"mainlib"}
!4 = distinct !DISubprogram(name: "main", linkageName: "__hugr__.__main__.main.1", scope: null, file: !5, line: 11, type: !6, scopeLine: 12, spFlags: DISPFlagDefinition, unit: !1)
!5 = !DIFile(filename: "/sanitized/path/program.py", directory: "")
!6 = !DISubroutineType(types: !7)
!7 = !{null}
!8 = !DILocation(line: 7, column: 4, scope: !4)
!9 = distinct !DISubprogram(name: "qmain", linkageName: "qmain", scope: null, file: !10, type: !11, spFlags: DISPFlagDefinition, unit: !1)
!10 = !DIFile(filename: "COMPILER_GENERATED_CODE", directory: "")
!11 = !DISubroutineType(types: !12)
!12 = !{!13, !13}
!13 = !DIBasicType(name: "i64", size: 64, encoding: DW_ATE_unsigned)
!14 = !DILocation(line: 0, scope: !9)
!15 = !DILocation(line: 7, column: 4, scope: !4, inlinedAt: !16)
!16 = distinct !DILocation(line: 0, scope: !9)
