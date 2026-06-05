; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@res_c1.1F7A6571.0 = private constant [13 x i8] c"\0CUSER:BOOL:c1"
@res_c2.60825383.0 = private constant [13 x i8] c"\0CUSER:BOOL:c2"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_24_case_0.i, label %__hugr__.__tk2_sol_qalloc.20.exit

cond_24_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.20.exit:                ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %qalloc.i15 = tail call i64 @___qalloc()
  %not_max.not.not.i16 = icmp eq i64 %qalloc.i15, -1
  br i1 %not_max.not.not.i16, label %cond_38_case_0.i, label %__hugr__.__tk2_sol_qalloc.34.exit

cond_38_case_0.i:                                 ; preds = %__hugr__.__tk2_sol_qalloc.20.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.34.exit:                ; preds = %__hugr__.__tk2_sol_qalloc.20.exit
  tail call void @___reset(i64 %qalloc.i15)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  %read_bool = tail call i1 @___read_future_bool(i64 %lazy_measure)
  tail call void @___dec_future_refcount(i64 %lazy_measure)
  tail call void @print_bool(ptr nonnull @res_c1.1F7A6571.0, i64 12, i1 %read_bool)
  %lazy_measure6 = tail call i64 @___lazy_measure(i64 %qalloc.i15)
  tail call void @___qfree(i64 %qalloc.i15)
  %read_bool8 = tail call i1 @___read_future_bool(i64 %lazy_measure6)
  tail call void @___dec_future_refcount(i64 %lazy_measure6)
  tail call void @print_bool(ptr nonnull @res_c2.60825383.0, i64 12, i1 %read_bool8)
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

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call void @__hugr__.__main__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
