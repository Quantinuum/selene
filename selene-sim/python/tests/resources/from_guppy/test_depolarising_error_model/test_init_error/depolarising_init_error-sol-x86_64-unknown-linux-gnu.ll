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
  br i1 %not_max.not.not.i, label %cond_16_case_0.i, label %__hugr__.__tk2_sol_qalloc.12.exit

cond_16_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.12.exit:                ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %qalloc.i13 = tail call i64 @___qalloc()
  %not_max.not.not.i14 = icmp eq i64 %qalloc.i13, -1
  br i1 %not_max.not.not.i14, label %cond_16_case_0.i15, label %__hugr__.__tk2_sol_qalloc.12.exit16

cond_16_case_0.i15:                               ; preds = %__hugr__.__tk2_sol_qalloc.12.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.12.exit16:              ; preds = %__hugr__.__tk2_sol_qalloc.12.exit
  tail call void @___reset(i64 %qalloc.i13)
  %___future_measure = tail call i64 @___future_measure(i64 %qalloc.i, i64 0)
  tail call void @___qfree(i64 %qalloc.i)
  %read_bool = tail call i1 @___read_future_bool(i64 %___future_measure)
  tail call void @___dec_future_refcount(i64 %___future_measure)
  tail call void @print_bool(ptr nonnull @res_c1.1F7A6571.0, i64 12, i1 %read_bool)
  %___future_measure6 = tail call i64 @___future_measure(i64 %qalloc.i13, i64 0)
  tail call void @___qfree(i64 %qalloc.i13)
  %read_bool8 = tail call i1 @___read_future_bool(i64 %___future_measure6)
  tail call void @___dec_future_refcount(i64 %___future_measure6)
  tail call void @print_bool(ptr nonnull @res_c2.60825383.0, i64 12, i1 %read_bool8)
  ret void
}

declare i64 @___future_measure(i64, i64) local_unnamed_addr

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
