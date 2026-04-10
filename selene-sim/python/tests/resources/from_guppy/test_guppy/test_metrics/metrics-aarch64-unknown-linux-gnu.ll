; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

@res_c0.7C14CD6E.0 = private constant [13 x i8] c"\0CUSER:BOOL:c0"
@res_c1.1F7A6571.0 = private constant [13 x i8] c"\0CUSER:BOOL:c1"
@res_c2.60825383.0 = private constant [13 x i8] c"\0CUSER:BOOL:c2"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool(i8*, i64, i1) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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
  br i1 %.fca.0.extract.i.i, label %__hugr__.__tk2_qalloc.29.exit.i, label %cond_33_case_0.i.i

cond_33_case_0.i.i:                               ; preds = %id_bb.i.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.29.exit.i:                  ; preds = %id_bb.i.i
  %.fca.1.extract.i.i = extractvalue { i1, i64 } %2, 1
  tail call void @___rxy(i64 %.fca.1.extract.i.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i.i, double 0x400921FB54442D18)
  %qalloc.i76.i = tail call i64 @___qalloc()
  %not_max.not.i77.i = icmp eq i64 %qalloc.i76.i, -1
  br i1 %not_max.not.i77.i, label %id_bb.i80.i, label %reset_bb.i78.i

reset_bb.i78.i:                                   ; preds = %__hugr__.__tk2_qalloc.29.exit.i
  tail call void @___reset(i64 %qalloc.i76.i)
  br label %id_bb.i80.i

id_bb.i80.i:                                      ; preds = %reset_bb.i78.i, %__hugr__.__tk2_qalloc.29.exit.i
  %3 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i76.i, 1
  %4 = select i1 %not_max.not.i77.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %3
  %.fca.0.extract.i79.i = extractvalue { i1, i64 } %4, 0
  br i1 %.fca.0.extract.i79.i, label %__hugr__.__tk2_qalloc.29.exit83.i, label %cond_33_case_0.i82.i

cond_33_case_0.i82.i:                             ; preds = %id_bb.i80.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.29.exit83.i:                ; preds = %id_bb.i80.i
  %.fca.1.extract.i81.i = extractvalue { i1, i64 } %4, 1
  %qalloc.i84.i = tail call i64 @___qalloc()
  %not_max.not.i85.i = icmp eq i64 %qalloc.i84.i, -1
  br i1 %not_max.not.i85.i, label %id_bb.i88.i, label %reset_bb.i86.i

reset_bb.i86.i:                                   ; preds = %__hugr__.__tk2_qalloc.29.exit83.i
  tail call void @___reset(i64 %qalloc.i84.i)
  br label %id_bb.i88.i

id_bb.i88.i:                                      ; preds = %reset_bb.i86.i, %__hugr__.__tk2_qalloc.29.exit83.i
  %5 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i84.i, 1
  %6 = select i1 %not_max.not.i85.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %5
  %.fca.0.extract.i87.i = extractvalue { i1, i64 } %6, 0
  br i1 %.fca.0.extract.i87.i, label %__hugr__.main.1.exit, label %cond_33_case_0.i90.i

cond_33_case_0.i90.i:                             ; preds = %id_bb.i88.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.main.1.exit:                             ; preds = %id_bb.i88.i
  %.fca.1.extract.i89.i = extractvalue { i1, i64 } %6, 1
  tail call void @___rxy(i64 %.fca.1.extract.i89.i, double 0x400921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i81.i, i64 %.fca.1.extract.i89.i, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i89.i, double 0x3FE921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i.i, i64 %.fca.1.extract.i89.i, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i89.i, double 0x3FE921FB54442D18, double 0.000000e+00)
  tail call void @___rzz(i64 %.fca.1.extract.i81.i, i64 %.fca.1.extract.i89.i, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i89.i, double 0x3FE921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i.i, i64 %.fca.1.extract.i89.i, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i89.i, double 0xC002D97C7F3321D2, double 0x400921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i89.i, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i.i, double 0x400921FB54442D18, double 0x3FE921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i.i, i64 %.fca.1.extract.i81.i, double 0x3FE921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i81.i, double 0xC002D97C7F3321D2)
  tail call void @___rxy(i64 %.fca.1.extract.i.i, double 0x400921FB54442D18, double 0xBFE921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i.i, double 0x3FE921FB54442D18)
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i.i)
  tail call void @___qfree(i64 %.fca.1.extract.i.i)
  %read_bool.i = tail call i1 @___read_future_bool(i64 %lazy_measure.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure.i)
  tail call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_c0.7C14CD6E.0, i64 0, i64 0), i64 12, i1 %read_bool.i)
  %lazy_measure24.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i81.i)
  tail call void @___qfree(i64 %.fca.1.extract.i81.i)
  %read_bool37.i = tail call i1 @___read_future_bool(i64 %lazy_measure24.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure24.i)
  tail call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_c1.1F7A6571.0, i64 0, i64 0), i64 12, i1 %read_bool37.i)
  %lazy_measure46.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i89.i)
  tail call void @___qfree(i64 %.fca.1.extract.i89.i)
  %read_bool59.i = tail call i1 @___read_future_bool(i64 %lazy_measure46.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure46.i)
  tail call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_c2.60825383.0, i64 0, i64 0), i64 12, i1 %read_bool59.i)
  %7 = tail call i64 @teardown()
  ret i64 %7
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
