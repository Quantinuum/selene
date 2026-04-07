; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_array_stat.71E0AE77.0 = private constant [23 x i8] c"\16USER:STATE:array_state"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
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

__barray_check_bounds.exit321:                    ; preds = %cond_exit_20.1
  %4 = xor i64 %31, 1
  store i64 %4, i64* %3, align 4
  %5 = load i64, i64* %1, align 4
  tail call void @___rxy(i64 %5, double 0x400921FB54442D18, double 0.000000e+00)
  %6 = load i64, i64* %3, align 4
  %7 = and i64 %6, 1
  %.not.i322 = icmp eq i64 %7, 0
  br i1 %.not.i322, label %panic.i323, label %__barray_check_bounds.exit.1

panic.i323:                                       ; preds = %__barray_check_bounds.exit321.1, %__barray_check_bounds.exit321
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.1:                     ; preds = %__barray_check_bounds.exit321
  %8 = xor i64 %6, 1
  store i64 %8, i64* %3, align 4
  store i64 %5, i64* %1, align 4
  %9 = load i64, i64* %3, align 4
  %10 = and i64 %9, 2
  %.not.i.1 = icmp eq i64 %10, 0
  br i1 %.not.i.1, label %__barray_check_bounds.exit321.1, label %panic.i

__barray_check_bounds.exit321.1:                  ; preds = %__barray_check_bounds.exit.1
  %11 = xor i64 %9, 2
  store i64 %11, i64* %3, align 4
  %12 = load i64, i64* %30, align 4
  tail call void @___rxy(i64 %12, double 0x400921FB54442D18, double 0.000000e+00)
  %13 = load i64, i64* %3, align 4
  %14 = and i64 %13, 2
  %.not.i322.1 = icmp eq i64 %14, 0
  br i1 %.not.i322.1, label %panic.i323, label %__barray_mask_return.exit.1

__barray_mask_return.exit.1:                      ; preds = %__barray_check_bounds.exit321.1
  %15 = xor i64 %13, 2
  store i64 %15, i64* %3, align 4
  store i64 %12, i64* %30, align 4
  %16 = load i64, i64* %3, align 4
  %17 = and i64 %16, 3
  store i64 %17, i64* %3, align 4
  %18 = icmp eq i64 %17, 0
  br i1 %18, label %cond_456_case_1.i, label %mask_block_err.i

reset_bb.i:                                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %alloca_block
  %19 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %20 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %19
  %.fca.0.extract.i = extractvalue { i1, i64 } %20, 0
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.287.exit, label %cond_282_case_0.i

cond_282_case_0.i:                                ; preds = %id_bb.i.1, %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.287.exit:                   ; preds = %id_bb.i
  %21 = load i64, i64* %3, align 4
  %22 = and i64 %21, 1
  %.not.i332 = icmp eq i64 %22, 0
  br i1 %.not.i332, label %panic.i333, label %cond_exit_20

panic.i333:                                       ; preds = %__barray_check_bounds.exit331.1, %__hugr__.__tk2_qalloc.287.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_qalloc.287.exit
  %.fca.1.extract.i = extractvalue { i1, i64 } %20, 1
  %23 = xor i64 %21, 1
  store i64 %23, i64* %3, align 4
  store i64 %.fca.1.extract.i, i64* %1, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.i.1, label %id_bb.i.1, label %reset_bb.i.1

reset_bb.i.1:                                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  br label %id_bb.i.1

id_bb.i.1:                                        ; preds = %reset_bb.i.1, %cond_exit_20
  %24 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.1, 1
  %25 = select i1 %not_max.not.i.1, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %24
  %.fca.0.extract.i.1 = extractvalue { i1, i64 } %25, 0
  br i1 %.fca.0.extract.i.1, label %__barray_check_bounds.exit331.1, label %cond_282_case_0.i

__barray_check_bounds.exit331.1:                  ; preds = %id_bb.i.1
  %26 = load i64, i64* %3, align 4
  %27 = and i64 %26, 2
  %.not.i332.1 = icmp eq i64 %27, 0
  br i1 %.not.i332.1, label %panic.i333, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit331.1
  %.fca.1.extract.i.1 = extractvalue { i1, i64 } %25, 1
  %28 = xor i64 %26, 2
  store i64 %28, i64* %3, align 4
  %29 = getelementptr inbounds i8, i8* %0, i64 8
  %30 = bitcast i8* %29 to i64*
  store i64 %.fca.1.extract.i.1, i64* %30, align 4
  %31 = load i64, i64* %3, align 4
  %32 = and i64 %31, 1
  %.not.i = icmp eq i64 %32, 0
  br i1 %.not.i, label %__barray_check_bounds.exit321, label %panic.i

mask_block_err.i:                                 ; preds = %__barray_mask_return.exit.1
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

"__hugr__.$discard_array$$n(2).343.exit":         ; preds = %cond_456_case_1.i.1
  call void @heap_free(i8* nonnull %0)
  call void @heap_free(i8* nonnull %35)
  ret void

mask_block_err.i.i.i:                             ; preds = %cond_456_case_1.i.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

panic.i.i.i:                                      ; preds = %cond_456_case_1.i
  call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_456_case_1.i:                                ; preds = %__barray_mask_return.exit.1
  %out_arr_alloca = alloca <{ i32, i32, i64*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %33 = alloca [2 x i1], align 1
  %.sub = getelementptr inbounds [2 x i1], [2 x i1]* %33, i64 0, i64 0
  store i1 false, i1* %.sub, align 1
  %.repack319 = getelementptr inbounds [2 x i1], [2 x i1]* %33, i64 0, i64 1
  store i1 false, i1* %.repack319, align 1
  store i32 2, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %34 = bitcast i64** %arr_ptr to i8**
  store i8* %0, i8** %34, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_state_result(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @res_array_stat.71E0AE77.0, i64 0, i64 0), i64 22, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca)
  %35 = call i8* @heap_alloc(i64 8)
  %36 = bitcast i8* %35 to i64*
  store i64 1, i64* %36, align 4
  %37 = load i64, i64* %1, align 4
  call void @___qfree(i64 %37)
  %38 = load i64, i64* %36, align 4
  %39 = and i64 %38, 2
  %.not.i99.i.i.1 = icmp eq i64 %39, 0
  br i1 %.not.i99.i.i.1, label %cond_456_case_1.i.1, label %panic.i.i.i

cond_456_case_1.i.1:                              ; preds = %cond_456_case_1.i
  %40 = xor i64 %38, 2
  store i64 %40, i64* %36, align 4
  %41 = load i64, i64* %30, align 4
  call void @___qfree(i64 %41)
  %42 = load i64, i64* %36, align 4
  %43 = or i64 %42, -4
  store i64 %43, i64* %36, align 4
  %44 = icmp eq i64 %43, -1
  br i1 %44, label %"__hugr__.$discard_array$$n(2).343.exit", label %mask_block_err.i.i.i
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
