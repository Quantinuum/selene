; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_default.C29723C4.0 = private constant [19 x i8] c"\12USER:STATE:default"
@res_reversed.22BDFB76.0 = private constant [20 x i8] c"\13USER:STATE:reversed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 16)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_312_case_0.i, label %__hugr__.__tk2_sol_qalloc.308.exit

cond_312_case_0.i:                                ; preds = %cond_exit_12, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.308.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_12, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.1, %__hugr__.__tk2_sol_qalloc.308.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_12:                                     ; preds = %__hugr__.__tk2_sol_qalloc.308.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_312_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_12
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not329 = icmp eq i64 %6, 0
  br i1 %.not329, label %panic.i, label %cond_exit_12.1

cond_exit_12.1:                                   ; preds = %__barray_check_bounds.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %9 = load i64, ptr %1, align 4
  %10 = trunc i64 %9 to i1
  br i1 %10, label %panic.i310, label %__barray_mask_borrow.exit

panic.i310:                                       ; preds = %cond_exit_12.1
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_12.1
  %11 = or disjoint i64 %9, 1
  store i64 %11, ptr %1, align 4
  %12 = and i64 %9, 2
  %.not = icmp eq i64 %12, 0
  br i1 %.not, label %__barray_mask_borrow.exit312, label %panic.i311

panic.i311:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit312:                     ; preds = %__barray_mask_borrow.exit
  %13 = load i64, ptr %0, align 4
  %14 = or disjoint i64 %9, 3
  store i64 %14, ptr %1, align 4
  %15 = load i64, ptr %8, align 4
  tail call void @___rp(i64 %13, double 0x400921FB54442D18, double 0.000000e+00)
  %16 = tail call ptr @heap_alloc(i64 16)
  %17 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %17, align 1
  store i64 %13, ptr %16, align 4
  %18 = getelementptr inbounds nuw i8, ptr %16, i64 8
  store i64 %15, ptr %18, align 4
  %19 = load i64, ptr %17, align 4
  %20 = and i64 %19, 3
  store i64 %20, ptr %17, align 4
  %21 = icmp eq i64 %20, 0
  br i1 %21, label %__barray_mask_check_not_borrowed.exit315, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__barray_mask_borrow.exit312
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_mask_check_not_borrowed.exit315:         ; preds = %__barray_mask_borrow.exit312
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %22 = alloca [2 x i1], align 1
  store i1 false, ptr %22, align 1
  %.repack308 = getelementptr inbounds nuw i8, ptr %22, i64 1
  store i1 false, ptr %.repack308, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %16, ptr %arr_ptr, align 8
  store ptr %22, ptr %mask_ptr, align 8
  call void @print_state_result(ptr nonnull @res_default.C29723C4.0, i64 18, ptr nonnull %out_arr_alloca)
  %23 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %23, align 1
  %24 = load <2 x i64>, ptr %16, align 4
  %25 = call ptr @heap_alloc(i64 16)
  %26 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %26, align 1
  %27 = shufflevector <2 x i64> %24, <2 x i64> poison, <2 x i32> <i32 1, i32 0>
  store <2 x i64> %27, ptr %25, align 4
  %28 = load i64, ptr %26, align 4
  %29 = and i64 %28, 3
  store i64 %29, ptr %26, align 4
  %30 = icmp eq i64 %29, 0
  br i1 %30, label %__barray_mask_check_not_borrowed.exit321, label %mask_block_err.i316

mask_block_err.i316:                              ; preds = %__barray_mask_check_not_borrowed.exit315
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_mask_check_not_borrowed.exit321:         ; preds = %__barray_mask_check_not_borrowed.exit315
  %31 = getelementptr inbounds nuw i8, ptr %25, i64 8
  %out_arr_alloca184 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr186 = getelementptr inbounds nuw i8, ptr %out_arr_alloca184, i64 4
  %arr_ptr187 = getelementptr inbounds nuw i8, ptr %out_arr_alloca184, i64 8
  %mask_ptr188 = getelementptr inbounds nuw i8, ptr %out_arr_alloca184, i64 16
  %32 = alloca [2 x i1], align 1
  store i1 false, ptr %32, align 1
  %.repack309 = getelementptr inbounds nuw i8, ptr %32, i64 1
  store i1 false, ptr %.repack309, align 1
  store i32 2, ptr %out_arr_alloca184, align 8
  store i32 1, ptr %y_ptr186, align 4
  store ptr %25, ptr %arr_ptr187, align 8
  store ptr %32, ptr %mask_ptr188, align 8
  call void @print_state_result(ptr nonnull @res_reversed.22BDFB76.0, i64 19, ptr nonnull %out_arr_alloca184)
  %33 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %33, align 1
  %34 = load i64, ptr %31, align 4
  %35 = load i64, ptr %1, align 4
  %36 = and i64 %35, 2
  %.not327 = icmp eq i64 %36, 0
  br i1 %.not327, label %panic.i322, label %__barray_mask_return.exit323

panic.i322:                                       ; preds = %__barray_mask_check_not_borrowed.exit321
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit323:                     ; preds = %__barray_mask_check_not_borrowed.exit321
  %37 = load i64, ptr %25, align 4
  %38 = and i64 %35, -3
  store i64 %38, ptr %1, align 4
  store i64 %37, ptr %8, align 4
  %39 = load i64, ptr %1, align 4
  %40 = trunc i64 %39 to i1
  br i1 %40, label %__barray_mask_return.exit325, label %panic.i324

panic.i324:                                       ; preds = %__barray_mask_return.exit323
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit325:                     ; preds = %__barray_mask_return.exit323
  %41 = and i64 %39, -2
  store i64 %41, ptr %1, align 4
  store i64 %34, ptr %0, align 4
  %42 = load i64, ptr %1, align 4
  %43 = trunc i64 %42 to i1
  br i1 %43, label %__barray_check_bounds.exit.1.i, label %__barray_mask_borrow.exit.i

__barray_check_bounds.exit.1.i:                   ; preds = %__barray_mask_borrow.exit.i, %__barray_mask_return.exit325
  %44 = phi i64 [ %.pre, %__barray_mask_borrow.exit.i ], [ %42, %__barray_mask_return.exit325 ]
  %45 = and i64 %44, 2
  %.not.i = icmp eq i64 %45, 0
  br i1 %.not.i, label %__barray_mask_borrow.exit.1.i, label %cond_exit_192.1.i

__barray_mask_borrow.exit.1.i:                    ; preds = %__barray_check_bounds.exit.1.i
  %46 = or disjoint i64 %44, 2
  store i64 %46, ptr %1, align 4
  %47 = load i64, ptr %8, align 4
  call void @___qfree(i64 %47)
  %.pre.i = load i64, ptr %1, align 4
  br label %cond_exit_192.1.i

cond_exit_192.1.i:                                ; preds = %__barray_mask_borrow.exit.1.i, %__barray_check_bounds.exit.1.i
  %48 = phi i64 [ %.pre.i, %__barray_mask_borrow.exit.1.i ], [ %44, %__barray_check_bounds.exit.1.i ]
  %49 = or i64 %48, -4
  store i64 %49, ptr %1, align 4
  %50 = icmp eq i64 %49, -1
  br i1 %50, label %"__hugr__.guppylang.std.quantum.discard_array$2.146.exit", label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %cond_exit_192.1.i
  call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit.i:                      ; preds = %__barray_mask_return.exit325
  %51 = or disjoint i64 %42, 1
  store i64 %51, ptr %1, align 4
  %52 = load i64, ptr %0, align 4
  call void @___qfree(i64 %52)
  %.pre = load i64, ptr %1, align 4
  br label %__barray_check_bounds.exit.1.i

"__hugr__.guppylang.std.quantum.discard_array$2.146.exit": ; preds = %cond_exit_192.1.i
  call void @heap_free(ptr nonnull %0)
  call void @heap_free(ptr nonnull %1)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @print_state_result(ptr, i64, ptr) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

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
