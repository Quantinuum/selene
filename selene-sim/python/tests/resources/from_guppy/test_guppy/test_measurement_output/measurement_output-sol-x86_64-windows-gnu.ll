; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@res_q2.2A5B30FD.0 = private constant [13 x i8] c"\0CUSER:BOOL:q2"
@res_q3.D71179D6.0 = private constant [12 x i8] c"\0BUSER:INT:q3"
@res_q2.798C5BAD.0 = private constant [12 x i8] c"\0BUSER:INT:q2"
@res_q3.C33BF3D1.0 = private constant [13 x i8] c"\0CUSER:BOOL:q3"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_277_case_0.i, label %__hugr__.__tk2_sol_qalloc.273.exit

cond_277_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.273.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rp(i64 %qalloc.i, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i378 = tail call i64 @___qalloc()
  %not_max.not.not.i379 = icmp eq i64 %qalloc.i378, -1
  br i1 %not_max.not.not.i379, label %cond_277_case_0.i380, label %__hugr__.__tk2_sol_qalloc.273.exit381

cond_277_case_0.i380:                             ; preds = %__hugr__.__tk2_sol_qalloc.273.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.273.exit381:            ; preds = %__hugr__.__tk2_sol_qalloc.273.exit
  tail call void @___reset(i64 %qalloc.i378)
  %qalloc.i382 = tail call i64 @___qalloc()
  %not_max.not.not.i383 = icmp eq i64 %qalloc.i382, -1
  br i1 %not_max.not.not.i383, label %cond_277_case_0.i384, label %__hugr__.__tk2_sol_qalloc.273.exit385

cond_277_case_0.i384:                             ; preds = %__hugr__.__tk2_sol_qalloc.273.exit381
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.273.exit385:            ; preds = %__hugr__.__tk2_sol_qalloc.273.exit381
  tail call void @___reset(i64 %qalloc.i382)
  %qalloc.i386 = tail call i64 @___qalloc()
  %not_max.not.not.i387 = icmp eq i64 %qalloc.i386, -1
  br i1 %not_max.not.not.i387, label %cond_277_case_0.i388, label %__hugr__.__tk2_sol_qalloc.273.exit389

cond_277_case_0.i388:                             ; preds = %__hugr__.__tk2_sol_qalloc.273.exit385
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.273.exit389:            ; preds = %__hugr__.__tk2_sol_qalloc.273.exit385
  tail call void @___reset(i64 %qalloc.i386)
  %___future_measure = tail call i64 @___future_measure(i64 %qalloc.i, i64 0)
  tail call void @___qfree(i64 %qalloc.i)
  %read_bool = tail call i1 @___read_future_bool(i64 %___future_measure)
  tail call void @___dec_future_refcount(i64 %___future_measure)
  br i1 %read_bool, label %1, label %0

0:                                                ; preds = %__hugr__.__tk2_sol_qalloc.273.exit389
  tail call void @___rp(i64 %qalloc.i386, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i378, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i382, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i378, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i378, i64 %qalloc.i382, double 0x3FF921FB54442D18, double 0xC00921FB54442D18)
  tail call void @___rp(i64 %qalloc.i382, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i382, double 0xBFF921FB54442D18)
  br label %2

1:                                                ; preds = %__hugr__.__tk2_sol_qalloc.273.exit389
  tail call void @___rz(i64 %qalloc.i386, double 0x400921FB54442D18)
  tail call void @___rp(i64 %qalloc.i378, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i378, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i378, i64 %qalloc.i382, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i382, double 0xBFF921FB54442D18, double 0.000000e+00)
  br label %2

2:                                                ; preds = %0, %1
  %.sink = phi double [ 0x3FF921FB54442D18, %0 ], [ 0xBFF921FB54442D18, %1 ]
  tail call void @___rp(i64 %qalloc.i378, double %.sink, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i378, double 0xBFF921FB54442D18)
  %___future_measure46 = tail call i64 @___future_measure(i64 %qalloc.i378, i64 0)
  tail call void @___qfree(i64 %qalloc.i378)
  %read_bool48 = tail call i1 @___read_future_bool(i64 %___future_measure46)
  tail call void @___dec_future_refcount(i64 %___future_measure46)
  br i1 %read_bool48, label %cond_exit_76, label %cond_exit_141

cond_exit_141:                                    ; preds = %2
  %___future_measure127 = tail call i64 @___future_measure(i64 %qalloc.i382, i64 1)
  tail call void @___qfree(i64 %qalloc.i382)
  %read_uint134 = tail call i64 @___read_future_uint(i64 %___future_measure127)
  tail call void @___dec_future_refcount(i64 %___future_measure127)
  %.not.not = icmp eq i64 %read_uint134, 2
  %3 = icmp eq i64 %read_uint134, 1
  %"250_0.0" = zext i1 %3 to i64
  %"255_0.0" = select i1 %.not.not, i64 2, i64 %"250_0.0"
  tail call void @print_int(ptr nonnull @res_q2.798C5BAD.0, i64 11, i64 %"255_0.0")
  %___future_measure274 = tail call i64 @___future_measure(i64 %qalloc.i386, i64 0)
  tail call void @___qfree(i64 %qalloc.i386)
  %read_bool276 = tail call i1 @___read_future_bool(i64 %___future_measure274)
  tail call void @___dec_future_refcount(i64 %___future_measure274)
  tail call void @print_bool(ptr nonnull @res_q3.C33BF3D1.0, i64 12, i1 %read_bool276)
  br label %5

cond_exit_76:                                     ; preds = %2
  %___future_measure59 = tail call i64 @___future_measure(i64 %qalloc.i386, i64 1)
  tail call void @___qfree(i64 %qalloc.i386)
  %___future_measure61 = tail call i64 @___future_measure(i64 %qalloc.i382, i64 0)
  tail call void @___qfree(i64 %qalloc.i382)
  %read_uint = tail call i64 @___read_future_uint(i64 %___future_measure59)
  tail call void @___dec_future_refcount(i64 %___future_measure59)
  %.not.not377 = icmp eq i64 %read_uint, 2
  %4 = icmp eq i64 %read_uint, 1
  %read_bool118 = tail call i1 @___read_future_bool(i64 %___future_measure61)
  tail call void @___dec_future_refcount(i64 %___future_measure61)
  tail call void @print_bool(ptr nonnull @res_q2.2A5B30FD.0, i64 12, i1 %read_bool118)
  %"205_0.0" = zext i1 %4 to i64
  %"210_0.0" = select i1 %.not.not377, i64 2, i64 %"205_0.0"
  tail call void @print_int(ptr nonnull @res_q3.D71179D6.0, i64 11, i64 %"210_0.0")
  br label %5

5:                                                ; preds = %cond_exit_141, %cond_exit_76
  ret void
}

declare i64 @___future_measure(i64, i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i64 @___read_future_uint(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

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
