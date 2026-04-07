; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"s_Testing ex.5E6E1E51.0" = private constant [26 x i8] c"\19Testing exit with metrics"
@res_c0.7C14CD6E.0 = private constant [13 x i8] c"\0CUSER:BOOL:c0"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define private fastcc i64 @__hugr__.__tk2_qalloc.37() unnamed_addr {
alloca_block:
  %qalloc = tail call i64 @___qalloc()
  %not_max.not = icmp eq i64 %qalloc, -1
  br i1 %not_max.not, label %id_bb, label %reset_bb

reset_bb:                                         ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc)
  br label %id_bb

id_bb:                                            ; preds = %alloca_block, %reset_bb
  %0 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc, 1
  %1 = select i1 %not_max.not, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %0
  %.fca.0.extract = extractvalue { i1, i64 } %1, 0
  br i1 %.fca.0.extract, label %cond_41_case_1, label %cond_41_case_0

cond_41_case_1:                                   ; preds = %id_bb
  %.fca.1.extract = extractvalue { i1, i64 } %1, 1
  ret i64 %.fca.1.extract

cond_41_case_0:                                   ; preds = %id_bb
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable
}

define private fastcc i64 @__hugr__.__tk2_h.51(i64 returned %0) unnamed_addr {
alloca_block:
  tail call void @___rxy(i64 %0, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %0, double 0x400921FB54442D18)
  ret i64 %0
}

define private fastcc i64 @__hugr__.__tk2_toffoli.62(i64 returned %0, i64 %1, i64 %2) unnamed_addr {
alloca_block:
  tail call void @___rxy(i64 %2, double 0x400921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rzz(i64 %1, i64 %2, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %2, double 0x3FE921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %0, i64 %2, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %2, double 0x3FE921FB54442D18, double 0.000000e+00)
  tail call void @___rzz(i64 %1, i64 %2, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %2, double 0x3FE921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rzz(i64 %0, i64 %2, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %2, double 0xC002D97C7F3321D2, double 0x400921FB54442D18)
  tail call void @___rz(i64 %2, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %0, double 0x400921FB54442D18, double 0x3FE921FB54442D18)
  tail call void @___rzz(i64 %0, i64 %1, double 0x3FE921FB54442D18)
  tail call void @___rz(i64 %1, double 0xC002D97C7F3321D2)
  tail call void @___rxy(i64 %0, double 0x400921FB54442D18, double 0xBFE921FB54442D18)
  tail call void @___rz(i64 %0, double 0x3FE921FB54442D18)
  ret i64 %0
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool(i8*, i64, i1) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

; Function Attrs: noreturn
define i64 @qmain(i64 %0) local_unnamed_addr #0 {
entry:
  tail call void @setup(i64 %0)
  %1 = tail call fastcc i64 @__hugr__.__tk2_qalloc.37()
  %2 = tail call fastcc i64 @__hugr__.__tk2_h.51(i64 %1)
  %3 = tail call fastcc i64 @__hugr__.__tk2_qalloc.37()
  %4 = tail call fastcc i64 @__hugr__.__tk2_qalloc.37()
  %5 = tail call fastcc i64 @__hugr__.__tk2_toffoli.62(i64 %1, i64 %3, i64 %4)
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %1)
  tail call void @___qfree(i64 %1)
  %read_bool.i = tail call i1 @___read_future_bool(i64 %lazy_measure.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure.i)
  tail call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_c0.7C14CD6E.0, i64 0, i64 0), i64 12, i1 %read_bool.i)
  tail call void @panic(i32 0, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @"s_Testing ex.5E6E1E51.0", i64 0, i64 0))
  unreachable
}

declare void @setup(i64) local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
