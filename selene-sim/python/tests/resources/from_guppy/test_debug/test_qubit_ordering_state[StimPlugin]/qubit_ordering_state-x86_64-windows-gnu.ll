; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_default.C29723C4.0 = private constant [19 x i8] c"\12USER:STATE:default"
@res_reversed.22BDFB76.0 = private constant [20 x i8] c"\13USER:STATE:reversed"
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

reset_bb.i:                                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %alloca_block
  %4 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %5 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %4
  %.fca.0.extract.i = extractvalue { i1, i64 } %5, 0
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.265.exit, label %cond_260_case_0.i

cond_260_case_0.i:                                ; preds = %id_bb.i.1, %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.265.exit:                   ; preds = %id_bb.i
  %6 = load i64, i64* %3, align 4
  %7 = and i64 %6, 1
  %.not.i = icmp eq i64 %7, 0
  br i1 %.not.i, label %panic.i, label %cond_exit_20

panic.i:                                          ; preds = %__barray_check_bounds.exit.1, %__hugr__.__tk2_qalloc.265.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_qalloc.265.exit
  %.fca.1.extract.i = extractvalue { i1, i64 } %5, 1
  %8 = xor i64 %6, 1
  store i64 %8, i64* %3, align 4
  store i64 %.fca.1.extract.i, i64* %1, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.i.1, label %id_bb.i.1, label %reset_bb.i.1

reset_bb.i.1:                                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  br label %id_bb.i.1

id_bb.i.1:                                        ; preds = %reset_bb.i.1, %cond_exit_20
  %9 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.1, 1
  %10 = select i1 %not_max.not.i.1, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %9
  %.fca.0.extract.i.1 = extractvalue { i1, i64 } %10, 0
  br i1 %.fca.0.extract.i.1, label %__barray_check_bounds.exit.1, label %cond_260_case_0.i

__barray_check_bounds.exit.1:                     ; preds = %id_bb.i.1
  %11 = load i64, i64* %3, align 4
  %12 = and i64 %11, 2
  %.not.i.1 = icmp eq i64 %12, 0
  br i1 %.not.i.1, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit.1
  %.fca.1.extract.i.1 = extractvalue { i1, i64 } %10, 1
  %13 = xor i64 %11, 2
  store i64 %13, i64* %3, align 4
  %14 = getelementptr inbounds i8, i8* %0, i64 8
  %15 = bitcast i8* %14 to i64*
  store i64 %.fca.1.extract.i.1, i64* %15, align 4
  %16 = load i64, i64* %3, align 4
  %17 = and i64 %16, 1
  %.not.i241 = icmp eq i64 %17, 0
  br i1 %.not.i241, label %__barray_mask_borrow.exit, label %panic.i242

panic.i242:                                       ; preds = %cond_exit_20.1
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.1
  %18 = xor i64 %16, 1
  store i64 %18, i64* %3, align 4
  %19 = load i64, i64* %1, align 4
  tail call void @___rxy(i64 %19, double 0x400921FB54442D18, double 0.000000e+00)
  %20 = load i64, i64* %3, align 4
  %21 = and i64 %20, 1
  %.not.i243 = icmp eq i64 %21, 0
  br i1 %.not.i243, label %panic.i244, label %__barray_mask_return.exit245

panic.i244:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit245:                     ; preds = %__barray_mask_borrow.exit
  %22 = xor i64 %20, 1
  store i64 %22, i64* %3, align 4
  store i64 %19, i64* %1, align 4
  %23 = load i64, i64* %3, align 4
  %24 = and i64 %23, 1
  %.not.i246 = icmp eq i64 %24, 0
  br i1 %.not.i246, label %__barray_mask_borrow.exit248, label %panic.i247

panic.i247:                                       ; preds = %__barray_mask_return.exit245
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit248:                     ; preds = %__barray_mask_return.exit245
  %25 = xor i64 %23, 1
  store i64 %25, i64* %3, align 4
  %26 = and i64 %23, 2
  %.not.i249 = icmp eq i64 %26, 0
  br i1 %.not.i249, label %__barray_mask_borrow.exit251, label %panic.i250

panic.i250:                                       ; preds = %__barray_mask_borrow.exit248
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit251:                     ; preds = %__barray_mask_borrow.exit248
  %27 = load i64, i64* %1, align 4
  %28 = xor i64 %23, 3
  store i64 %28, i64* %3, align 4
  %29 = getelementptr inbounds i8, i8* %0, i64 8
  %30 = bitcast i8* %29 to i64*
  %31 = load i64, i64* %30, align 4
  %32 = tail call i8* @heap_alloc(i64 16)
  %33 = bitcast i8* %32 to i64*
  %34 = tail call i8* @heap_alloc(i64 8)
  %35 = bitcast i8* %34 to i64*
  store i64 0, i64* %35, align 1
  store i64 %27, i64* %33, align 4
  %36 = getelementptr inbounds i8, i8* %32, i64 8
  %37 = bitcast i8* %36 to i64*
  store i64 %31, i64* %37, align 4
  %38 = load i64, i64* %35, align 4
  %39 = and i64 %38, 3
  store i64 %39, i64* %35, align 4
  %40 = icmp eq i64 %39, 0
  br i1 %40, label %__barray_mask_check_not_borrowed.exit256, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__barray_mask_borrow.exit251
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_mask_check_not_borrowed.exit256:         ; preds = %__barray_mask_borrow.exit251
  %out_arr_alloca = alloca <{ i32, i32, i64*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %41 = alloca [2 x i1], align 1
  %.sub = getelementptr inbounds [2 x i1], [2 x i1]* %41, i64 0, i64 0
  store i1 false, i1* %.sub, align 1
  %.repack237 = getelementptr inbounds [2 x i1], [2 x i1]* %41, i64 0, i64 1
  store i1 false, i1* %.repack237, align 1
  store i32 2, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %42 = bitcast i64** %arr_ptr to i8**
  store i8* %32, i8** %42, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_state_result(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @res_default.C29723C4.0, i64 0, i64 0), i64 18, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca)
  %43 = call i8* @heap_alloc(i64 8)
  %44 = bitcast i8* %43 to i64*
  store i64 0, i64* %44, align 1
  %45 = load i64, i64* %37, align 4
  %46 = load i64, i64* %3, align 4
  %47 = and i64 %46, 1
  %.not.i257 = icmp eq i64 %47, 0
  br i1 %.not.i257, label %panic.i258, label %__barray_mask_return.exit259

panic.i258:                                       ; preds = %__barray_mask_check_not_borrowed.exit256
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit259:                     ; preds = %__barray_mask_check_not_borrowed.exit256
  %48 = load i64, i64* %33, align 4
  %49 = xor i64 %46, 1
  store i64 %49, i64* %3, align 4
  store i64 %48, i64* %1, align 4
  %50 = load i64, i64* %3, align 4
  %51 = and i64 %50, 2
  %.not.i260 = icmp eq i64 %51, 0
  br i1 %.not.i260, label %panic.i261, label %__barray_mask_return.exit262

panic.i261:                                       ; preds = %__barray_mask_return.exit259
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit262:                     ; preds = %__barray_mask_return.exit259
  %52 = xor i64 %50, 2
  store i64 %52, i64* %3, align 4
  store i64 %45, i64* %30, align 4
  %53 = load i64, i64* %3, align 4
  %54 = and i64 %53, 2
  %.not.i263 = icmp eq i64 %54, 0
  br i1 %.not.i263, label %__barray_mask_borrow.exit265, label %panic.i264

panic.i264:                                       ; preds = %__barray_mask_return.exit262
  call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit265:                     ; preds = %__barray_mask_return.exit262
  %55 = xor i64 %53, 2
  store i64 %55, i64* %3, align 4
  %56 = and i64 %53, 1
  %.not.i266 = icmp eq i64 %56, 0
  br i1 %.not.i266, label %__barray_mask_borrow.exit268, label %panic.i267

panic.i267:                                       ; preds = %__barray_mask_borrow.exit265
  call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit268:                     ; preds = %__barray_mask_borrow.exit265
  %57 = load i64, i64* %30, align 4
  %58 = xor i64 %53, 3
  store i64 %58, i64* %3, align 4
  %59 = load i64, i64* %1, align 4
  %60 = call i8* @heap_alloc(i64 16)
  %61 = bitcast i8* %60 to i64*
  %62 = call i8* @heap_alloc(i64 8)
  %63 = bitcast i8* %62 to i64*
  store i64 0, i64* %63, align 1
  store i64 %57, i64* %61, align 4
  %64 = getelementptr inbounds i8, i8* %60, i64 8
  %65 = bitcast i8* %64 to i64*
  store i64 %59, i64* %65, align 4
  %66 = load i64, i64* %63, align 4
  %67 = and i64 %66, 3
  store i64 %67, i64* %63, align 4
  %68 = icmp eq i64 %67, 0
  br i1 %68, label %__barray_mask_check_not_borrowed.exit276, label %mask_block_err.i269

mask_block_err.i269:                              ; preds = %__barray_mask_borrow.exit268
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_mask_check_not_borrowed.exit276:         ; preds = %__barray_mask_borrow.exit268
  %out_arr_alloca141 = alloca <{ i32, i32, i64*, i1* }>, align 8
  %x_ptr142 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca141, i64 0, i32 0
  %y_ptr143 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca141, i64 0, i32 1
  %arr_ptr144 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca141, i64 0, i32 2
  %mask_ptr145 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca141, i64 0, i32 3
  %69 = alloca [2 x i1], align 1
  %.sub238 = getelementptr inbounds [2 x i1], [2 x i1]* %69, i64 0, i64 0
  store i1 false, i1* %.sub238, align 1
  %.repack240 = getelementptr inbounds [2 x i1], [2 x i1]* %69, i64 0, i64 1
  store i1 false, i1* %.repack240, align 1
  store i32 2, i32* %x_ptr142, align 8
  store i32 1, i32* %y_ptr143, align 4
  %70 = bitcast i64** %arr_ptr144 to i8**
  store i8* %60, i8** %70, align 8
  store i1* %.sub238, i1** %mask_ptr145, align 8
  call void @print_state_result(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @res_reversed.22BDFB76.0, i64 0, i64 0), i64 19, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca141)
  %71 = call i8* @heap_alloc(i64 8)
  %72 = bitcast i8* %71 to i64*
  store i64 0, i64* %72, align 1
  %73 = load i64, i64* %65, align 4
  %74 = load i64, i64* %3, align 4
  %75 = and i64 %74, 2
  %.not.i277 = icmp eq i64 %75, 0
  br i1 %.not.i277, label %panic.i278, label %__barray_mask_return.exit279

panic.i278:                                       ; preds = %__barray_mask_check_not_borrowed.exit276
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit279:                     ; preds = %__barray_mask_check_not_borrowed.exit276
  %76 = load i64, i64* %61, align 4
  %77 = xor i64 %74, 2
  store i64 %77, i64* %3, align 4
  store i64 %76, i64* %30, align 4
  %78 = load i64, i64* %3, align 4
  %79 = and i64 %78, 1
  %.not.i280 = icmp eq i64 %79, 0
  br i1 %.not.i280, label %panic.i281, label %__barray_mask_return.exit282

panic.i281:                                       ; preds = %__barray_mask_return.exit279
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit282:                     ; preds = %__barray_mask_return.exit279
  %80 = xor i64 %78, 1
  store i64 %80, i64* %3, align 4
  store i64 %73, i64* %1, align 4
  %81 = load i64, i64* %3, align 4
  %82 = and i64 %81, 1
  %.not.i99.i.i = icmp eq i64 %82, 0
  br i1 %.not.i99.i.i, label %cond_434_case_1.i, label %panic.i.i.i

"__hugr__.$discard_array$$n(2).321.exit":         ; preds = %cond_434_case_1.i.1
  call void @heap_free(i8* nonnull %0)
  call void @heap_free(i8* nonnull %2)
  ret void

mask_block_err.i.i.i:                             ; preds = %cond_434_case_1.i.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

panic.i.i.i:                                      ; preds = %cond_434_case_1.i, %__barray_mask_return.exit282
  call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_434_case_1.i:                                ; preds = %__barray_mask_return.exit282
  %83 = xor i64 %81, 1
  store i64 %83, i64* %3, align 4
  %84 = load i64, i64* %1, align 4
  call void @___qfree(i64 %84)
  %85 = load i64, i64* %3, align 4
  %86 = and i64 %85, 2
  %.not.i99.i.i.1 = icmp eq i64 %86, 0
  br i1 %.not.i99.i.i.1, label %cond_434_case_1.i.1, label %panic.i.i.i

cond_434_case_1.i.1:                              ; preds = %cond_434_case_1.i
  %87 = xor i64 %85, 2
  store i64 %87, i64* %3, align 4
  %88 = load i64, i64* %15, align 4
  call void @___qfree(i64 %88)
  %89 = load i64, i64* %3, align 4
  %90 = or i64 %89, -4
  store i64 %90, i64* %3, align 4
  %91 = icmp eq i64 %90, -1
  br i1 %91, label %"__hugr__.$discard_array$$n(2).321.exit", label %mask_block_err.i.i.i
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
