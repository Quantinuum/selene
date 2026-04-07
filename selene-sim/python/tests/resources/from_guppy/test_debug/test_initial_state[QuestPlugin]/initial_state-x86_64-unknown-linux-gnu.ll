; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_initial_st.8DE11473.0 = private constant [25 x i8] c"\18USER:STATE:initial_state"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.i, label %id_bb.i, label %reset_bb.i

reset_bb.i:                                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %alloca_block
  %0 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %1 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %0
  %.fca.0.extract.i = extractvalue { i1, i64 } %1, 0
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.19.exit, label %cond_23_case_0.i

cond_23_case_0.i:                                 ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.19.exit:                    ; preds = %id_bb.i
  %.fca.1.extract.i = extractvalue { i1, i64 } %1, 1
  %2 = tail call i8* @heap_alloc(i64 8)
  %3 = bitcast i8* %2 to i64*
  %4 = tail call i8* @heap_alloc(i64 8)
  %5 = bitcast i8* %4 to i64*
  store i64 0, i64* %5, align 1
  store i64 %.fca.1.extract.i, i64* %3, align 4
  %6 = load i64, i64* %5, align 4
  %7 = and i64 %6, 1
  store i64 %7, i64* %5, align 4
  %8 = icmp eq i64 %7, 0
  br i1 %8, label %__barray_mask_check_not_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_qalloc.19.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_mask_check_not_borrowed.exit:            ; preds = %__hugr__.__tk2_qalloc.19.exit
  %out_arr_alloca = alloca <{ i32, i32, i64*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %9 = alloca i1, align 1
  store i1 false, i1* %9, align 1
  store i32 1, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %10 = bitcast i64** %arr_ptr to i8**
  store i8* %2, i8** %10, align 8
  store i1* %9, i1** %mask_ptr, align 8
  call void @print_state_result(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @res_initial_st.8DE11473.0, i64 0, i64 0), i64 24, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca)
  %11 = call i8* @heap_alloc(i64 8)
  %12 = bitcast i8* %11 to i64*
  store i64 0, i64* %12, align 1
  %13 = load i64, i64* %3, align 4
  call void @___qfree(i64 %13)
  ret void
}

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare void @print_state_result(i8*, i64, <{ i32, i32, i64*, i1* }>*) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @__hugr__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
