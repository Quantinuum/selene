; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@res_q2.2A5B30FD.0 = private constant [13 x i8] c"\0CUSER:BOOL:q2"
@res_q3.D71179D6.0 = private constant [12 x i8] c"\0BUSER:INT:q3"
@res_q2.798C5BAD.0 = private constant [12 x i8] c"\0BUSER:INT:q2"
@res_q3.C33BF3D1.0 = private constant [13 x i8] c"\0CUSER:BOOL:q3"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool(i8*, i64, i1) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare void @print_int(i8*, i64, i64) local_unnamed_addr

declare i64 @___read_future_uint(i64) local_unnamed_addr

declare i64 @___lazy_measure_leaked(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  %qalloc.i.i = tail call i64 @___qalloc()
  %not_max.not.i.i = icmp eq i64 %qalloc.i.i, -1
  br i1 %not_max.not.i.i, label %id_bb.i.i, label %reset_bb.i.i

reset_bb.i.i:                                     ; preds = %entry
  tail call void @___reset(i64 %qalloc.i.i)
  br label %id_bb.i.i

id_bb.i.i:                                        ; preds = %reset_bb.i.i, %entry
  %1 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.i, 1
  %2 = select i1 %not_max.not.i.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %1
  %.fca.0.extract.i.i = extractvalue { i1, i64 } %2, 0
  br i1 %.fca.0.extract.i.i, label %__hugr__.__tk2_qalloc.253.exit.i, label %cond_257_case_0.i.i

cond_257_case_0.i.i:                              ; preds = %id_bb.i.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.253.exit.i:                 ; preds = %id_bb.i.i
  %.fca.1.extract.i.i = extractvalue { i1, i64 } %2, 1
  tail call void @___rxy(i64 %.fca.1.extract.i.i, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i486.i = tail call i64 @___qalloc()
  %not_max.not.i487.i = icmp eq i64 %qalloc.i486.i, -1
  br i1 %not_max.not.i487.i, label %id_bb.i490.i, label %reset_bb.i488.i

reset_bb.i488.i:                                  ; preds = %__hugr__.__tk2_qalloc.253.exit.i
  tail call void @___reset(i64 %qalloc.i486.i)
  br label %id_bb.i490.i

id_bb.i490.i:                                     ; preds = %reset_bb.i488.i, %__hugr__.__tk2_qalloc.253.exit.i
  %3 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i486.i, 1
  %4 = select i1 %not_max.not.i487.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %3
  %.fca.0.extract.i489.i = extractvalue { i1, i64 } %4, 0
  br i1 %.fca.0.extract.i489.i, label %__hugr__.__tk2_qalloc.253.exit493.i, label %cond_257_case_0.i492.i

cond_257_case_0.i492.i:                           ; preds = %id_bb.i490.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.253.exit493.i:              ; preds = %id_bb.i490.i
  %.fca.1.extract.i491.i = extractvalue { i1, i64 } %4, 1
  %qalloc.i494.i = tail call i64 @___qalloc()
  %not_max.not.i495.i = icmp eq i64 %qalloc.i494.i, -1
  br i1 %not_max.not.i495.i, label %id_bb.i498.i, label %reset_bb.i496.i

reset_bb.i496.i:                                  ; preds = %__hugr__.__tk2_qalloc.253.exit493.i
  tail call void @___reset(i64 %qalloc.i494.i)
  br label %id_bb.i498.i

id_bb.i498.i:                                     ; preds = %reset_bb.i496.i, %__hugr__.__tk2_qalloc.253.exit493.i
  %5 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i494.i, 1
  %6 = select i1 %not_max.not.i495.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %5
  %.fca.0.extract.i497.i = extractvalue { i1, i64 } %6, 0
  br i1 %.fca.0.extract.i497.i, label %__hugr__.__tk2_qalloc.253.exit501.i, label %cond_257_case_0.i500.i

cond_257_case_0.i500.i:                           ; preds = %id_bb.i498.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.253.exit501.i:              ; preds = %id_bb.i498.i
  %.fca.1.extract.i499.i = extractvalue { i1, i64 } %6, 1
  %qalloc.i502.i = tail call i64 @___qalloc()
  %not_max.not.i503.i = icmp eq i64 %qalloc.i502.i, -1
  br i1 %not_max.not.i503.i, label %id_bb.i506.i, label %reset_bb.i504.i

reset_bb.i504.i:                                  ; preds = %__hugr__.__tk2_qalloc.253.exit501.i
  tail call void @___reset(i64 %qalloc.i502.i)
  br label %id_bb.i506.i

id_bb.i506.i:                                     ; preds = %reset_bb.i504.i, %__hugr__.__tk2_qalloc.253.exit501.i
  %7 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i502.i, 1
  %8 = select i1 %not_max.not.i503.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %7
  %.fca.0.extract.i505.i = extractvalue { i1, i64 } %8, 0
  br i1 %.fca.0.extract.i505.i, label %__hugr__.__tk2_qalloc.253.exit509.i, label %cond_257_case_0.i508.i

cond_257_case_0.i508.i:                           ; preds = %id_bb.i506.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.253.exit509.i:              ; preds = %id_bb.i506.i
  %.fca.1.extract.i507.i = extractvalue { i1, i64 } %8, 1
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i.i)
  tail call void @___qfree(i64 %.fca.1.extract.i.i)
  %read_bool.i = tail call i1 @___read_future_bool(i64 %lazy_measure.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure.i)
  br i1 %read_bool.i, label %10, label %9

cond_341_case_1.i:                                ; preds = %10, %9
  tail call void @___rz(i64 %.fca.1.extract.i499.i, double 0xBFF921FB54442D18)
  %lazy_measure60.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i491.i)
  tail call void @___qfree(i64 %.fca.1.extract.i491.i)
  %read_bool73.i = tail call i1 @___read_future_bool(i64 %lazy_measure60.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure60.i)
  br i1 %read_bool73.i, label %cond_355_case_1.i, label %cond_exit_79.i

9:                                                ; preds = %__hugr__.__tk2_qalloc.253.exit509.i
  tail call void @___rxy(i64 %.fca.1.extract.i507.i, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rxy(i64 %.fca.1.extract.i491.i, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i491.i, i64 %.fca.1.extract.i499.i, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i491.i, double 0xBFF921FB54442D18)
  br label %cond_341_case_1.i

10:                                               ; preds = %__hugr__.__tk2_qalloc.253.exit509.i
  tail call void @___rz(i64 %.fca.1.extract.i507.i, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i491.i, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rxy(i64 %.fca.1.extract.i499.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i491.i, i64 %.fca.1.extract.i499.i, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i491.i, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i499.i, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  br label %cond_341_case_1.i

cond_exit_79.i:                                   ; preds = %cond_341_case_1.i
  %lazy_measure_leaked.i.i = tail call i64 @___lazy_measure_leaked(i64 %.fca.1.extract.i499.i)
  tail call void @___qfree(i64 %.fca.1.extract.i499.i)
  %read_uint.i.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i.i)
  %.not.i = icmp eq i64 %read_uint.i.i, 2
  %11 = icmp eq i64 %read_uint.i.i, 1
  %"177_0.0.i" = zext i1 %11 to i64
  %"181_0.0.i" = select i1 %.not.i, i64 2, i64 %"177_0.0.i"
  tail call void @print_int(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @res_q2.798C5BAD.0, i64 0, i64 0), i64 11, i64 %"181_0.0.i")
  %lazy_measure322.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i507.i)
  tail call void @___qfree(i64 %.fca.1.extract.i507.i)
  %read_bool335.i = tail call i1 @___read_future_bool(i64 %lazy_measure322.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure322.i)
  tail call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_q3.C33BF3D1.0, i64 0, i64 0), i64 12, i1 %read_bool335.i)
  br label %__hugr__.__main__.measurement_output_prog.1.exit

cond_355_case_1.i:                                ; preds = %cond_341_case_1.i
  %lazy_measure87.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i499.i)
  tail call void @___qfree(i64 %.fca.1.extract.i499.i)
  %read_bool100.i = tail call i1 @___read_future_bool(i64 %lazy_measure87.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure87.i)
  tail call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_q2.2A5B30FD.0, i64 0, i64 0), i64 12, i1 %read_bool100.i)
  %lazy_measure_leaked.i511.i = tail call i64 @___lazy_measure_leaked(i64 %.fca.1.extract.i507.i)
  tail call void @___qfree(i64 %.fca.1.extract.i507.i)
  %read_uint.i512.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i511.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i511.i)
  %.not517.i = icmp eq i64 %read_uint.i512.i, 2
  %12 = icmp eq i64 %read_uint.i512.i, 1
  %"135_0.0.i" = zext i1 %12 to i64
  %"139_0.0.i" = select i1 %.not517.i, i64 2, i64 %"135_0.0.i"
  tail call void @print_int(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @res_q3.D71179D6.0, i64 0, i64 0), i64 11, i64 %"139_0.0.i")
  br label %__hugr__.__main__.measurement_output_prog.1.exit

__hugr__.__main__.measurement_output_prog.1.exit: ; preds = %cond_exit_79.i, %cond_355_case_1.i
  %13 = tail call i64 @teardown()
  ret i64 %13
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
