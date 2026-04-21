; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@res_q2.2A5B30FD.0 = private constant [13 x i8] c"\0CUSER:BOOL:q2"
@res_q3.D71179D6.0 = private constant [12 x i8] c"\0BUSER:INT:q3"
@res_q2.798C5BAD.0 = private constant [12 x i8] c"\0BUSER:INT:q2"
@res_q3.C33BF3D1.0 = private constant [13 x i8] c"\0CUSER:BOOL:q3"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare i64 @___read_future_uint(i64) local_unnamed_addr

declare i64 @___lazy_measure_leaked(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  %qalloc.i.i = tail call i64 @___qalloc()
  %not_max.not.not.i.i = icmp eq i64 %qalloc.i.i, -1
  br i1 %not_max.not.not.i.i, label %cond_257_case_0.i.i, label %__hugr__.__tk2_qalloc.253.exit.i

cond_257_case_0.i.i:                              ; preds = %entry
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.253.exit.i:                 ; preds = %entry
  tail call void @___reset(i64 %qalloc.i.i)
  tail call void @___rp(i64 %qalloc.i.i, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i485.i = tail call i64 @___qalloc()
  %not_max.not.not.i486.i = icmp eq i64 %qalloc.i485.i, -1
  br i1 %not_max.not.not.i486.i, label %cond_271_case_0.i.i, label %__hugr__.__tk2_qalloc.267.exit.i

cond_271_case_0.i.i:                              ; preds = %__hugr__.__tk2_qalloc.253.exit.i
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.267.exit.i:                 ; preds = %__hugr__.__tk2_qalloc.253.exit.i
  tail call void @___reset(i64 %qalloc.i485.i)
  %qalloc.i487.i = tail call i64 @___qalloc()
  %not_max.not.not.i488.i = icmp eq i64 %qalloc.i487.i, -1
  br i1 %not_max.not.not.i488.i, label %cond_285_case_0.i.i, label %__hugr__.__tk2_qalloc.281.exit.i

cond_285_case_0.i.i:                              ; preds = %__hugr__.__tk2_qalloc.267.exit.i
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.281.exit.i:                 ; preds = %__hugr__.__tk2_qalloc.267.exit.i
  tail call void @___reset(i64 %qalloc.i487.i)
  %qalloc.i489.i = tail call i64 @___qalloc()
  %not_max.not.not.i490.i = icmp eq i64 %qalloc.i489.i, -1
  br i1 %not_max.not.not.i490.i, label %cond_299_case_0.i.i, label %__hugr__.__tk2_qalloc.295.exit.i

cond_299_case_0.i.i:                              ; preds = %__hugr__.__tk2_qalloc.281.exit.i
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.295.exit.i:                 ; preds = %__hugr__.__tk2_qalloc.281.exit.i
  tail call void @___reset(i64 %qalloc.i489.i)
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %qalloc.i.i)
  tail call void @___qfree(i64 %qalloc.i.i)
  %read_bool.i = tail call i1 @___read_future_bool(i64 %lazy_measure.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure.i)
  br i1 %read_bool.i, label %2, label %1

cond_403_case_1.i:                                ; preds = %2, %1
  %.sink.i = phi double [ 0x3FF921FB54442D18, %1 ], [ 0xBFF921FB54442D18, %2 ]
  tail call void @___rp(i64 %qalloc.i485.i, double %.sink.i, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i485.i, double 0xBFF921FB54442D18)
  %lazy_measure60.i = tail call i64 @___lazy_measure(i64 %qalloc.i485.i)
  tail call void @___qfree(i64 %qalloc.i485.i)
  %read_bool73.i = tail call i1 @___read_future_bool(i64 %lazy_measure60.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure60.i)
  br i1 %read_bool73.i, label %cond_417_case_1.i, label %cond_exit_79.i

1:                                                ; preds = %__hugr__.__tk2_qalloc.295.exit.i
  tail call void @___rp(i64 %qalloc.i489.i, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i485.i, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i487.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i485.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i485.i, i64 %qalloc.i487.i, double 0x3FF921FB54442D18, double 0xC00921FB54442D18)
  tail call void @___rp(i64 %qalloc.i487.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i487.i, double 0xBFF921FB54442D18)
  br label %cond_403_case_1.i

2:                                                ; preds = %__hugr__.__tk2_qalloc.295.exit.i
  tail call void @___rz(i64 %qalloc.i489.i, double 0x400921FB54442D18)
  tail call void @___rp(i64 %qalloc.i485.i, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i485.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i485.i, i64 %qalloc.i487.i, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i487.i, double 0xBFF921FB54442D18, double 0.000000e+00)
  br label %cond_403_case_1.i

cond_exit_79.i:                                   ; preds = %cond_403_case_1.i
  %lazy_measure_leaked.i.i = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i487.i)
  tail call void @___qfree(i64 %qalloc.i487.i)
  %read_uint.i.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i.i)
  %.not.i = icmp eq i64 %read_uint.i.i, 2
  %3 = icmp eq i64 %read_uint.i.i, 1
  %"177_0.0.i" = zext i1 %3 to i64
  %"181_0.0.i" = select i1 %.not.i, i64 2, i64 %"177_0.0.i"
  tail call void @print_int(ptr nonnull @res_q2.798C5BAD.0, i64 11, i64 %"181_0.0.i")
  %lazy_measure322.i = tail call i64 @___lazy_measure(i64 %qalloc.i489.i)
  tail call void @___qfree(i64 %qalloc.i489.i)
  %read_bool335.i = tail call i1 @___read_future_bool(i64 %lazy_measure322.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure322.i)
  tail call void @print_bool(ptr nonnull @res_q3.C33BF3D1.0, i64 12, i1 %read_bool335.i)
  br label %__hugr__.__main__.main.1.exit

cond_417_case_1.i:                                ; preds = %cond_403_case_1.i
  %lazy_measure87.i = tail call i64 @___lazy_measure(i64 %qalloc.i487.i)
  tail call void @___qfree(i64 %qalloc.i487.i)
  %read_bool100.i = tail call i1 @___read_future_bool(i64 %lazy_measure87.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure87.i)
  tail call void @print_bool(ptr nonnull @res_q2.2A5B30FD.0, i64 12, i1 %read_bool100.i)
  %lazy_measure_leaked.i492.i = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i489.i)
  tail call void @___qfree(i64 %qalloc.i489.i)
  %read_uint.i493.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i492.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i492.i)
  %.not498.i = icmp eq i64 %read_uint.i493.i, 2
  %4 = icmp eq i64 %read_uint.i493.i, 1
  %"135_0.0.i" = zext i1 %4 to i64
  %"139_0.0.i" = select i1 %.not498.i, i64 2, i64 %"135_0.0.i"
  tail call void @print_int(ptr nonnull @res_q3.D71179D6.0, i64 11, i64 %"139_0.0.i")
  br label %__hugr__.__main__.main.1.exit

__hugr__.__main__.main.1.exit:                    ; preds = %cond_exit_79.i, %cond_417_case_1.i
  %5 = tail call i64 @teardown()
  ret i64 %5
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
