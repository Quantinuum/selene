; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@res_q2.2A5B30FD.0 = private constant [13 x i8] c"\0CUSER:BOOL:q2"
@res_q3.D71179D6.0 = private constant [12 x i8] c"\0BUSER:INT:q3"
@res_q2.798C5BAD.0 = private constant [12 x i8] c"\0BUSER:INT:q2"
@res_q3.C33BF3D1.0 = private constant [13 x i8] c"\0CUSER:BOOL:q3"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_250_case_0.i, label %__hugr__.__tk2_sol_qalloc.246.exit

cond_250_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.246.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rp(i64 %qalloc.i, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i295 = tail call i64 @___qalloc()
  %not_max.not.not.i296 = icmp eq i64 %qalloc.i295, -1
  br i1 %not_max.not.not.i296, label %cond_264_case_0.i, label %__hugr__.__tk2_sol_qalloc.260.exit

cond_264_case_0.i:                                ; preds = %__hugr__.__tk2_sol_qalloc.246.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.260.exit:               ; preds = %__hugr__.__tk2_sol_qalloc.246.exit
  tail call void @___reset(i64 %qalloc.i295)
  %qalloc.i297 = tail call i64 @___qalloc()
  %not_max.not.not.i298 = icmp eq i64 %qalloc.i297, -1
  br i1 %not_max.not.not.i298, label %cond_278_case_0.i, label %__hugr__.__tk2_sol_qalloc.274.exit

cond_278_case_0.i:                                ; preds = %__hugr__.__tk2_sol_qalloc.260.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.274.exit:               ; preds = %__hugr__.__tk2_sol_qalloc.260.exit
  tail call void @___reset(i64 %qalloc.i297)
  %qalloc.i299 = tail call i64 @___qalloc()
  %not_max.not.not.i300 = icmp eq i64 %qalloc.i299, -1
  br i1 %not_max.not.not.i300, label %cond_292_case_0.i, label %__hugr__.__tk2_sol_qalloc.288.exit

cond_292_case_0.i:                                ; preds = %__hugr__.__tk2_sol_qalloc.274.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.288.exit:               ; preds = %__hugr__.__tk2_sol_qalloc.274.exit
  tail call void @___reset(i64 %qalloc.i299)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  %read_bool = tail call i1 @___read_future_bool(i64 %lazy_measure)
  tail call void @___dec_future_refcount(i64 %lazy_measure)
  br i1 %read_bool, label %1, label %0

0:                                                ; preds = %__hugr__.__tk2_sol_qalloc.288.exit
  tail call void @___rp(i64 %qalloc.i299, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i295, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i297, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i295, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i295, i64 %qalloc.i297, double 0x3FF921FB54442D18, double 0xC00921FB54442D18)
  tail call void @___rp(i64 %qalloc.i297, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i297, double 0xBFF921FB54442D18)
  br label %2

1:                                                ; preds = %__hugr__.__tk2_sol_qalloc.288.exit
  tail call void @___rz(i64 %qalloc.i299, double 0x400921FB54442D18)
  tail call void @___rp(i64 %qalloc.i295, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i295, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i295, i64 %qalloc.i297, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i297, double 0xBFF921FB54442D18, double 0.000000e+00)
  br label %2

2:                                                ; preds = %0, %1
  %.sink = phi double [ 0x3FF921FB54442D18, %0 ], [ 0xBFF921FB54442D18, %1 ]
  tail call void @___rp(i64 %qalloc.i295, double %.sink, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i295, double 0xBFF921FB54442D18)
  %lazy_measure46 = tail call i64 @___lazy_measure(i64 %qalloc.i295)
  tail call void @___qfree(i64 %qalloc.i295)
  %read_bool48 = tail call i1 @___read_future_bool(i64 %lazy_measure46)
  tail call void @___dec_future_refcount(i64 %lazy_measure46)
  br i1 %read_bool48, label %cond_exit_51, label %cond_exit_78

cond_exit_78:                                     ; preds = %2
  %lazy_measure_leaked.i = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i297)
  tail call void @___qfree(i64 %qalloc.i297)
  %read_uint.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %.not = icmp eq i64 %read_uint.i, 2
  %3 = icmp eq i64 %read_uint.i, 1
  %.294 = zext i1 %3 to i64
  %spec.select = select i1 %.not, i64 2, i64 %.294
  tail call void @print_int(ptr nonnull @res_q2.798C5BAD.0, i64 11, i64 %spec.select)
  %lazy_measure205 = tail call i64 @___lazy_measure(i64 %qalloc.i299)
  tail call void @___qfree(i64 %qalloc.i299)
  %read_bool207 = tail call i1 @___read_future_bool(i64 %lazy_measure205)
  tail call void @___dec_future_refcount(i64 %lazy_measure205)
  tail call void @print_bool(ptr nonnull @res_q3.C33BF3D1.0, i64 12, i1 %read_bool207)
  br label %5

cond_exit_51:                                     ; preds = %2
  %lazy_measure59 = tail call i64 @___lazy_measure(i64 %qalloc.i297)
  tail call void @___qfree(i64 %qalloc.i297)
  %read_bool61 = tail call i1 @___read_future_bool(i64 %lazy_measure59)
  tail call void @___dec_future_refcount(i64 %lazy_measure59)
  tail call void @print_bool(ptr nonnull @res_q2.2A5B30FD.0, i64 12, i1 %read_bool61)
  %lazy_measure_leaked.i302 = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i299)
  tail call void @___qfree(i64 %qalloc.i299)
  %read_uint.i303 = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i302)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i302)
  %.not308 = icmp eq i64 %read_uint.i303, 2
  %4 = icmp eq i64 %read_uint.i303, 1
  %. = zext i1 %4 to i64
  %spec.select306 = select i1 %.not308, i64 2, i64 %.
  tail call void @print_int(ptr nonnull @res_q3.D71179D6.0, i64 11, i64 %spec.select306)
  br label %5

5:                                                ; preds = %cond_exit_78, %cond_exit_51
  ret void
}

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
  tail call void @__hugr__.__main__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
