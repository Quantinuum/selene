; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@res_c1.1F7A6571.0 = private constant [13 x i8] c"\0CUSER:BOOL:c1"
@res_c2.60825383.0 = private constant [13 x i8] c"\0CUSER:BOOL:c2"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

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
  %qalloc.i.i = tail call i64 @___qalloc()
  %not_max.not.not.i.i = icmp eq i64 %qalloc.i.i, -1
  br i1 %not_max.not.not.i.i, label %cond_24_case_0.i.i, label %__hugr__.__tk2_qalloc.20.exit.i

cond_24_case_0.i.i:                               ; preds = %entry
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.20.exit.i:                  ; preds = %entry
  tail call void @___reset(i64 %qalloc.i.i)
  %qalloc.i46.i = tail call i64 @___qalloc()
  %not_max.not.not.i47.i = icmp eq i64 %qalloc.i46.i, -1
  br i1 %not_max.not.not.i47.i, label %cond_38_case_0.i.i, label %__hugr__.__main__.main.1.exit

cond_38_case_0.i.i:                               ; preds = %__hugr__.__tk2_qalloc.20.exit.i
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__main__.main.1.exit:                    ; preds = %__hugr__.__tk2_qalloc.20.exit.i
  tail call void @___reset(i64 %qalloc.i46.i)
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %qalloc.i.i)
  tail call void @___qfree(i64 %qalloc.i.i)
  %read_bool.i = tail call i1 @___read_future_bool(i64 %lazy_measure.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure.i)
  tail call void @print_bool(ptr nonnull @res_c1.1F7A6571.0, i64 12, i1 %read_bool.i)
  %lazy_measure20.i = tail call i64 @___lazy_measure(i64 %qalloc.i46.i)
  tail call void @___qfree(i64 %qalloc.i46.i)
  %read_bool33.i = tail call i1 @___read_future_bool(i64 %lazy_measure20.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure20.i)
  tail call void @print_bool(ptr nonnull @res_c2.60825383.0, i64 12, i1 %read_bool33.i)
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
