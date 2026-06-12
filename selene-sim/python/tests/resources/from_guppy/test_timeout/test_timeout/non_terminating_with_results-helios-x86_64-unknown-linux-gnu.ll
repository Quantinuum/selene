; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@res_r.F13F95F2.0 = private constant [12 x i8] c"\0BUSER:BOOL:r"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

; Function Attrs: noreturn
define void @__hugr__.__main__.main.1() local_unnamed_addr #0 {
alloca_block:
  %qalloc.i12 = tail call i64 @___qalloc()
  %not_max.not.not.i13 = icmp eq i64 %qalloc.i12, -1
  br i1 %not_max.not.not.i13, label %cond_30_case_0.i, label %__hugr__.__tk2_helios_qalloc.26.exit

cond_30_case_0.i:                                 ; preds = %__hugr__.__tk2_helios_qalloc.26.exit, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.26.exit:             ; preds = %alloca_block, %__hugr__.__tk2_helios_qalloc.26.exit
  %qalloc.i14 = phi i64 [ %qalloc.i, %__hugr__.__tk2_helios_qalloc.26.exit ], [ %qalloc.i12, %alloca_block ]
  tail call void @___reset(i64 %qalloc.i14)
  tail call void @___rxy(i64 %qalloc.i14, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i14, double 0x400921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i14)
  tail call void @___qfree(i64 %qalloc.i14)
  %read_bool = tail call i1 @___read_future_bool(i64 %lazy_measure)
  tail call void @___dec_future_refcount(i64 %lazy_measure)
  tail call void @print_bool(ptr nonnull @res_r.F13F95F2.0, i64 11, i1 %read_bool)
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_30_case_0.i, label %__hugr__.__tk2_helios_qalloc.26.exit
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

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

; Function Attrs: noreturn
define noundef i64 @qmain(i64 %0) local_unnamed_addr #0 {
entry:
  tail call void @setup(i64 %0)
  tail call void @__hugr__.__main__.main.1()
  unreachable
}

declare void @setup(i64) local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
