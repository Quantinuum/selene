; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

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
  br i1 %.fca.0.extract.i.i, label %__hugr__.__tk2_qalloc.20.exit.i, label %cond_24_case_0.i.i

cond_24_case_0.i.i:                               ; preds = %id_bb.i.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.20.exit.i:                  ; preds = %id_bb.i.i
  %.fca.1.extract.i.i = extractvalue { i1, i64 } %2, 1
  %qalloc.i46.i = tail call i64 @___qalloc()
  %not_max.not.i47.i = icmp eq i64 %qalloc.i46.i, -1
  br i1 %not_max.not.i47.i, label %id_bb.i50.i, label %reset_bb.i48.i

reset_bb.i48.i:                                   ; preds = %__hugr__.__tk2_qalloc.20.exit.i
  tail call void @___reset(i64 %qalloc.i46.i)
  br label %id_bb.i50.i

id_bb.i50.i:                                      ; preds = %reset_bb.i48.i, %__hugr__.__tk2_qalloc.20.exit.i
  %3 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i46.i, 1
  %4 = select i1 %not_max.not.i47.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %3
  %.fca.0.extract.i49.i = extractvalue { i1, i64 } %4, 0
  br i1 %.fca.0.extract.i49.i, label %__hugr__.main.1.exit, label %cond_24_case_0.i52.i

cond_24_case_0.i52.i:                             ; preds = %id_bb.i50.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.main.1.exit:                             ; preds = %id_bb.i50.i
  %.fca.1.extract.i51.i = extractvalue { i1, i64 } %4, 1
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i.i)
  tail call void @___qfree(i64 %.fca.1.extract.i.i)
  %read_bool.i = tail call i1 @___read_future_bool(i64 %lazy_measure.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure.i)
  tail call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_c1.1F7A6571.0, i64 0, i64 0), i64 12, i1 %read_bool.i)
  %lazy_measure20.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i51.i)
  tail call void @___qfree(i64 %.fca.1.extract.i51.i)
  %read_bool33.i = tail call i1 @___read_future_bool(i64 %lazy_measure20.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure20.i)
  tail call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_c2.60825383.0, i64 0, i64 0), i64 12, i1 %read_bool33.i)
  %5 = tail call i64 @teardown()
  ret i64 %5
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
