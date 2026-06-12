; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@res_c0.7C14CD6E.0 = private constant [13 x i8] c"\0CUSER:BOOL:c0"
@res_c1.1F7A6571.0 = private constant [13 x i8] c"\0CUSER:BOOL:c1"
@res_c2.60825383.0 = private constant [13 x i8] c"\0CUSER:BOOL:c2"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_72_case_0.i, label %__hugr__.__tk2_helios_qalloc.68.exit

cond_72_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.68.exit:             ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rxy(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  %read_bool = tail call i1 @___read_future_bool(i64 %lazy_measure)
  tail call void @___dec_future_refcount(i64 %lazy_measure)
  tail call void @print_bool(ptr nonnull @res_c0.7C14CD6E.0, i64 12, i1 %read_bool)
  br i1 %read_bool, label %0, label %2

0:                                                ; preds = %__hugr__.__tk2_helios_qalloc.68.exit
  %qalloc.i44 = tail call i64 @___qalloc()
  %not_max.not.not.i45 = icmp eq i64 %qalloc.i44, -1
  br i1 %not_max.not.not.i45, label %cond_97_case_0.i, label %__hugr__.__tk2_helios_qalloc.93.exit

cond_97_case_0.i:                                 ; preds = %0
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.93.exit:             ; preds = %0
  tail call void @___reset(i64 %qalloc.i44)
  tail call void @___rxy(i64 %qalloc.i44, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i44, double 0x400921FB54442D18)
  %lazy_measure10 = tail call i64 @___lazy_measure(i64 %qalloc.i44)
  tail call void @___qfree(i64 %qalloc.i44)
  tail call void @___inc_future_refcount(i64 %lazy_measure10)
  %read_bool16 = tail call i1 @___read_future_bool(i64 %lazy_measure10)
  tail call void @___dec_future_refcount(i64 %lazy_measure10)
  tail call void @print_bool(ptr nonnull @res_c1.1F7A6571.0, i64 12, i1 %read_bool16)
  %read_bool.i = tail call i1 @___read_future_bool(i64 %lazy_measure10)
  tail call void @___dec_future_refcount(i64 %lazy_measure10)
  br i1 %read_bool.i, label %1, label %2

1:                                                ; preds = %__hugr__.__tk2_helios_qalloc.93.exit
  %qalloc.i46 = tail call i64 @___qalloc()
  %not_max.not.not.i47 = icmp eq i64 %qalloc.i46, -1
  br i1 %not_max.not.not.i47, label %cond_125_case_0.i, label %__hugr__.__tk2_helios_qalloc.121.exit

cond_125_case_0.i:                                ; preds = %1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.121.exit:            ; preds = %1
  tail call void @___reset(i64 %qalloc.i46)
  tail call void @___rxy(i64 %qalloc.i46, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i46, double 0x400921FB54442D18)
  %lazy_measure28 = tail call i64 @___lazy_measure(i64 %qalloc.i46)
  tail call void @___qfree(i64 %qalloc.i46)
  %read_bool30 = tail call i1 @___read_future_bool(i64 %lazy_measure28)
  tail call void @___dec_future_refcount(i64 %lazy_measure28)
  tail call void @print_bool(ptr nonnull @res_c2.60825383.0, i64 12, i1 %read_bool30)
  br label %2

2:                                                ; preds = %__hugr__.__tk2_helios_qalloc.121.exit, %__hugr__.__tk2_helios_qalloc.93.exit, %__hugr__.__tk2_helios_qalloc.68.exit
  ret void
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

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
