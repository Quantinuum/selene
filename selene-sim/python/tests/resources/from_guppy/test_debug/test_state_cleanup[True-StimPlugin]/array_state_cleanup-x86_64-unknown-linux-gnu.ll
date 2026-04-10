; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_array_stat.71E0AE77.0 = private constant [23 x i8] c"\16USER:STATE:array_state"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call i8* @heap_alloc(i64 16)
  %1 = bitcast i8* %0 to i64*
  %2 = tail call i8* @heap_alloc(i64 8)
  %3 = bitcast i8* %2 to i64*
  store i64 -1, i64* %3, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.i, label %id_bb.i, label %reset_bb.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.1, %cond_exit_20.1
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit342:                    ; preds = %cond_exit_20.1
  %4 = xor i64 %30, 1
  store i64 %4, i64* %3, align 4
  %5 = load i64, i64* %1, align 4
  tail call void @___rxy(i64 %5, double 0x400921FB54442D18, double 0.000000e+00)
  %6 = load i64, i64* %3, align 4
  %7 = and i64 %6, 1
  %.not.i343 = icmp eq i64 %7, 0
  br i1 %.not.i343, label %panic.i344, label %__barray_check_bounds.exit.1

panic.i344:                                       ; preds = %__barray_check_bounds.exit342.1, %__barray_check_bounds.exit342
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.1:                     ; preds = %__barray_check_bounds.exit342
  %8 = xor i64 %6, 1
  store i64 %8, i64* %3, align 4
  store i64 %5, i64* %1, align 4
  %9 = load i64, i64* %3, align 4
  %10 = and i64 %9, 2
  %.not.i.1 = icmp eq i64 %10, 0
  br i1 %.not.i.1, label %__barray_check_bounds.exit342.1, label %panic.i

__barray_check_bounds.exit342.1:                  ; preds = %__barray_check_bounds.exit.1
  %11 = xor i64 %9, 2
  store i64 %11, i64* %3, align 4
  %12 = load i64, i64* %29, align 4
  tail call void @___rxy(i64 %12, double 0x400921FB54442D18, double 0.000000e+00)
  %13 = load i64, i64* %3, align 4
  %14 = and i64 %13, 2
  %.not.i343.1 = icmp eq i64 %14, 0
  br i1 %.not.i343.1, label %panic.i344, label %__barray_mask_return.exit.1

__barray_mask_return.exit.1:                      ; preds = %__barray_check_bounds.exit342.1
  %15 = xor i64 %13, 2
  store i64 %15, i64* %3, align 4
  store i64 %12, i64* %29, align 4
  %16 = load i64, i64* %3, align 4
  %17 = and i64 %16, 1
  %.not.i356 = icmp eq i64 %17, 0
  br i1 %.not.i356, label %__barray_mask_borrow.exit358, label %panic.i357

reset_bb.i:                                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %alloca_block
  %18 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %19 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %18
  %.fca.0.extract.i = extractvalue { i1, i64 } %19, 0
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.296.exit, label %cond_291_case_0.i

cond_291_case_0.i:                                ; preds = %id_bb.i.1, %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.296.exit:                   ; preds = %id_bb.i
  %20 = load i64, i64* %3, align 4
  %21 = and i64 %20, 1
  %.not.i353 = icmp eq i64 %21, 0
  br i1 %.not.i353, label %panic.i354, label %cond_exit_20

panic.i354:                                       ; preds = %__barray_check_bounds.exit352.1, %__hugr__.__tk2_qalloc.296.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_qalloc.296.exit
  %.fca.1.extract.i = extractvalue { i1, i64 } %19, 1
  %22 = xor i64 %20, 1
  store i64 %22, i64* %3, align 4
  store i64 %.fca.1.extract.i, i64* %1, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.i.1, label %id_bb.i.1, label %reset_bb.i.1

reset_bb.i.1:                                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  br label %id_bb.i.1

id_bb.i.1:                                        ; preds = %reset_bb.i.1, %cond_exit_20
  %23 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.1, 1
  %24 = select i1 %not_max.not.i.1, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %23
  %.fca.0.extract.i.1 = extractvalue { i1, i64 } %24, 0
  br i1 %.fca.0.extract.i.1, label %__barray_check_bounds.exit352.1, label %cond_291_case_0.i

__barray_check_bounds.exit352.1:                  ; preds = %id_bb.i.1
  %25 = load i64, i64* %3, align 4
  %26 = and i64 %25, 2
  %.not.i353.1 = icmp eq i64 %26, 0
  br i1 %.not.i353.1, label %panic.i354, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit352.1
  %.fca.1.extract.i.1 = extractvalue { i1, i64 } %24, 1
  %27 = xor i64 %25, 2
  store i64 %27, i64* %3, align 4
  %28 = getelementptr inbounds i8, i8* %0, i64 8
  %29 = bitcast i8* %28 to i64*
  store i64 %.fca.1.extract.i.1, i64* %29, align 4
  %30 = load i64, i64* %3, align 4
  %31 = and i64 %30, 1
  %.not.i = icmp eq i64 %31, 0
  br i1 %.not.i, label %__barray_check_bounds.exit342, label %panic.i

panic.i357:                                       ; preds = %__barray_mask_return.exit.1
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit358:                     ; preds = %__barray_mask_return.exit.1
  %32 = xor i64 %16, 1
  store i64 %32, i64* %3, align 4
  %33 = load i64, i64* %1, align 4
  %34 = tail call i8* @heap_alloc(i64 8)
  %35 = bitcast i8* %34 to i64*
  %36 = tail call i8* @heap_alloc(i64 8)
  %37 = bitcast i8* %36 to i64*
  store i64 0, i64* %37, align 1
  store i64 %33, i64* %35, align 4
  %38 = load i64, i64* %37, align 4
  %39 = and i64 %38, 1
  store i64 %39, i64* %37, align 4
  %40 = icmp eq i64 %39, 0
  br i1 %40, label %__barray_mask_check_not_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__barray_mask_borrow.exit358
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_mask_check_not_borrowed.exit:            ; preds = %__barray_mask_borrow.exit358
  %out_arr_alloca = alloca <{ i32, i32, i64*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %41 = alloca i1, align 1
  store i1 false, i1* %41, align 1
  store i32 1, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %42 = bitcast i64** %arr_ptr to i8**
  store i8* %34, i8** %42, align 8
  store i1* %41, i1** %mask_ptr, align 8
  call void @print_state_result(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @res_array_stat.71E0AE77.0, i64 0, i64 0), i64 22, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca)
  %43 = call i8* @heap_alloc(i64 8)
  %44 = bitcast i8* %43 to i64*
  store i64 0, i64* %44, align 1
  %45 = load i64, i64* %3, align 4
  %46 = and i64 %45, 1
  %.not.i361 = icmp eq i64 %46, 0
  br i1 %.not.i361, label %panic.i362, label %__barray_mask_return.exit363

panic.i362:                                       ; preds = %__barray_mask_check_not_borrowed.exit
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit363:                     ; preds = %__barray_mask_check_not_borrowed.exit
  %47 = load i64, i64* %35, align 4
  %48 = xor i64 %45, 1
  store i64 %48, i64* %3, align 4
  store i64 %47, i64* %1, align 4
  %49 = load i64, i64* %3, align 4
  %50 = and i64 %49, 1
  %.not.i99.i.i = icmp eq i64 %50, 0
  br i1 %.not.i99.i.i, label %cond_466_case_1.i, label %panic.i.i.i

"__hugr__.$discard_array$$n(2).353.exit":         ; preds = %cond_466_case_1.i.1
  call void @heap_free(i8* nonnull %0)
  call void @heap_free(i8* nonnull %2)
  ret void

mask_block_err.i.i.i:                             ; preds = %cond_466_case_1.i.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

panic.i.i.i:                                      ; preds = %cond_466_case_1.i, %__barray_mask_return.exit363
  call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_466_case_1.i:                                ; preds = %__barray_mask_return.exit363
  %51 = xor i64 %49, 1
  store i64 %51, i64* %3, align 4
  %52 = load i64, i64* %1, align 4
  call void @___qfree(i64 %52)
  %53 = load i64, i64* %3, align 4
  %54 = and i64 %53, 2
  %.not.i99.i.i.1 = icmp eq i64 %54, 0
  br i1 %.not.i99.i.i.1, label %cond_466_case_1.i.1, label %panic.i.i.i

cond_466_case_1.i.1:                              ; preds = %cond_466_case_1.i
  %55 = xor i64 %53, 2
  store i64 %55, i64* %3, align 4
  %56 = load i64, i64* %29, align 4
  call void @___qfree(i64 %56)
  %57 = load i64, i64* %3, align 4
  %58 = or i64 %57, -4
  store i64 %58, i64* %3, align 4
  %59 = icmp eq i64 %58, -1
  br i1 %59, label %"__hugr__.$discard_array$$n(2).353.exit", label %mask_block_err.i.i.i
}

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare void @print_state_result(i8*, i64, <{ i32, i32, i64*, i1* }>*) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @heap_free(i8*) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

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
