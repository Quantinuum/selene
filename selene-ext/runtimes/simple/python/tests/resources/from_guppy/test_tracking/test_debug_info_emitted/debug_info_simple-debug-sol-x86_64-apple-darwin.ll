; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@res_c0.7C14CD6E.0 = private constant [13 x i8] c"\0CUSER:BOOL:c0"
@res_c1.1F7A6571.0 = private constant [13 x i8] c"\0CUSER:BOOL:c1"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr !dbg !4 {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc(), !dbg !8
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1, !dbg !8
  br i1 %not_max.not.not.i, label %cond_30_case_0.i, label %__hugr__.__tk2_sol_qalloc.26.exit, !dbg !8

cond_30_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0"), !dbg !8
  unreachable, !dbg !8

__hugr__.__tk2_sol_qalloc.26.exit:                ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i), !dbg !8
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18), !dbg !9
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18), !dbg !9
  %qalloc.i19 = tail call i64 @___qalloc(), !dbg !10
  %not_max.not.not.i20 = icmp eq i64 %qalloc.i19, -1, !dbg !10
  br i1 %not_max.not.not.i20, label %cond_44_case_0.i, label %__hugr__.__tk2_sol_qalloc.40.exit, !dbg !10

cond_44_case_0.i:                                 ; preds = %__hugr__.__tk2_sol_qalloc.26.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0"), !dbg !10
  unreachable, !dbg !10

__hugr__.__tk2_sol_qalloc.40.exit:                ; preds = %__hugr__.__tk2_sol_qalloc.26.exit
  tail call void @___reset(i64 %qalloc.i19), !dbg !10
  tail call void @___rp(i64 %qalloc.i19, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18), !dbg !11
  tail call void @___rpp(i64 %qalloc.i19, i64 %qalloc.i, double 0x3FF921FB54442D18, double 0.000000e+00), !dbg !11
  tail call void @___rp(i64 %qalloc.i, double 0xBFF921FB54442D18, double 0.000000e+00), !dbg !11
  tail call void @___rp(i64 %qalloc.i19, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18), !dbg !11
  tail call void @___rz(i64 %qalloc.i19, double 0xBFF921FB54442D18), !dbg !11
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i), !dbg !12
  tail call void @___qfree(i64 %qalloc.i), !dbg !12
  tail call void @___rp(i64 %qalloc.i19, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18), !dbg !13
  tail call void @___rz(i64 %qalloc.i19, double 0x400921FB54442D18), !dbg !13
  %read_bool = tail call i1 @___read_future_bool(i64 %lazy_measure), !dbg !12
  tail call void @___dec_future_refcount(i64 %lazy_measure), !dbg !12
  tail call void @print_bool(ptr nonnull @res_c0.7C14CD6E.0, i64 12, i1 %read_bool), !dbg !14
  %lazy_measure10 = tail call i64 @___lazy_measure(i64 %qalloc.i19), !dbg !15
  tail call void @___qfree(i64 %qalloc.i19), !dbg !15
  %read_bool12 = tail call i1 @___read_future_bool(i64 %lazy_measure10), !dbg !15
  tail call void @___dec_future_refcount(i64 %lazy_measure10), !dbg !15
  tail call void @print_bool(ptr nonnull @res_c1.1F7A6571.0, i64 12, i1 %read_bool12), !dbg !16
  ret void
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr !dbg !17 {
entry:
  tail call void @setup(i64 %0), !dbg !22
  tail call void @__hugr__.__main__.main.1(), !dbg !22
  %1 = tail call i64 @teardown(), !dbg !22
  ret i64 %1, !dbg !22
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!llvm.module.flags = !{!0}
!llvm.dbg.cu = !{!1}
!name = !{!3}

!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_Python, file: !2, producer: "guppylang (guppylang-internals-v0.33.0)-v0.21.12", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug)
!2 = !DIFile(filename: "/var/folders/82/vk9n_rxn0wd8h1hy261fn2480000gp/T/tmp5cu89wfl/temp_guppy_source.py", directory: "file:///Users/george.hodgkins/proj/selene")
!3 = !{!"mainlib"}
!4 = distinct !DISubprogram(name: "main", linkageName: "__hugr__.__main__.main.1", scope: null, file: !5, line: 9, type: !6, scopeLine: 10, spFlags: DISPFlagDefinition, unit: !1)
!5 = !DIFile(filename: "/var/folders/82/vk9n_rxn0wd8h1hy261fn2480000gp/T/tmp5cu89wfl/temp_guppy_source.py", directory: "")
!6 = !DISubroutineType(types: !7)
!7 = !{null}
!8 = !DILocation(line: 10, column: 9, scope: !4)
!9 = !DILocation(line: 12, column: 4, scope: !4)
!10 = !DILocation(line: 11, column: 9, scope: !4)
!11 = !DILocation(line: 13, column: 4, scope: !4)
!12 = !DILocation(line: 15, column: 17, scope: !4)
!13 = !DILocation(line: 14, column: 4, scope: !4)
!14 = !DILocation(line: 15, column: 4, scope: !4)
!15 = !DILocation(line: 16, column: 17, scope: !4)
!16 = !DILocation(line: 16, column: 4, scope: !4)
!17 = distinct !DISubprogram(name: "qmain", linkageName: "qmain", scope: null, file: !18, type: !19, spFlags: DISPFlagDefinition, unit: !1)
!18 = !DIFile(filename: "COMPILER_GENERATED_CODE", directory: "")
!19 = !DISubroutineType(types: !20)
!20 = !{!21, !21}
!21 = !DIBasicType(name: "i64", size: 64, encoding: DW_ATE_unsigned)
!22 = !DILocation(line: 0, scope: !17)
