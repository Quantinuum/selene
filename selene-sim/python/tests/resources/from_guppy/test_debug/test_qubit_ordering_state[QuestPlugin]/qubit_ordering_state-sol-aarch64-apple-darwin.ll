; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

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
  br i1 %not_max.not.not.i, label %cond_287_case_0.i, label %__hugr__.__tk2_sol_qalloc.283.exit

cond_287_case_0.i:                                ; preds = %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.283.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.1, %__hugr__.__tk2_sol_qalloc.283.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_sol_qalloc.283.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_287_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not257 = icmp eq i64 %6, 0
  br i1 %.not257, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %9 = load i64, ptr %1, align 4
  %10 = trunc i64 %9 to i1
  br i1 %10, label %panic.i220, label %__barray_mask_borrow.exit

panic.i220:                                       ; preds = %cond_exit_20.1
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.1
  %11 = or disjoint i64 %9, 1
  store i64 %11, ptr %1, align 4
  %12 = load i64, ptr %0, align 4
  tail call void @___rp(i64 %12, double 0x400921FB54442D18, double 0.000000e+00)
  %13 = load i64, ptr %1, align 4
  %14 = trunc i64 %13 to i1
  br i1 %14, label %__barray_mask_return.exit222, label %panic.i221

panic.i221:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit222:                     ; preds = %__barray_mask_borrow.exit
  %15 = and i64 %13, -2
  store i64 %15, ptr %1, align 4
  store i64 %12, ptr %0, align 4
  %16 = load i64, ptr %1, align 4
  %17 = trunc i64 %16 to i1
  br i1 %17, label %panic.i223, label %__barray_mask_borrow.exit224

panic.i223:                                       ; preds = %__barray_mask_return.exit222
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit224:                     ; preds = %__barray_mask_return.exit222
  %18 = or disjoint i64 %16, 1
  store i64 %18, ptr %1, align 4
  %19 = and i64 %16, 2
  %.not = icmp eq i64 %19, 0
  br i1 %.not, label %__barray_mask_borrow.exit226, label %panic.i225

panic.i225:                                       ; preds = %__barray_mask_borrow.exit224
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit226:                     ; preds = %__barray_mask_borrow.exit224
  %20 = load i64, ptr %0, align 4
  %21 = or disjoint i64 %16, 3
  store i64 %21, ptr %1, align 4
  %22 = load i64, ptr %8, align 4
  %23 = tail call ptr @heap_alloc(i64 16)
  %24 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %24, align 1
  store i64 %20, ptr %23, align 4
  %25 = getelementptr inbounds nuw i8, ptr %23, i64 8
  store i64 %22, ptr %25, align 4
  %26 = load i64, ptr %24, align 4
  %27 = and i64 %26, 3
  store i64 %27, ptr %24, align 4
  %28 = icmp eq i64 %27, 0
  br i1 %28, label %__barray_mask_check_not_borrowed.exit229, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__barray_mask_borrow.exit226
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_mask_check_not_borrowed.exit229:         ; preds = %__barray_mask_borrow.exit226
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %29 = alloca [2 x i1], align 1
  store i1 false, ptr %29, align 1
  %.repack218 = getelementptr inbounds nuw i8, ptr %29, i64 1
  store i1 false, ptr %.repack218, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %23, ptr %arr_ptr, align 8
  store ptr %29, ptr %mask_ptr, align 8
  call void @print_state_result(ptr nonnull @res_default.C29723C4.0, i64 18, ptr nonnull %out_arr_alloca)
  %30 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %30, align 1
  %31 = load i64, ptr %25, align 4
  %32 = load i64, ptr %1, align 4
  %33 = trunc i64 %32 to i1
  br i1 %33, label %__barray_mask_return.exit231, label %panic.i230

panic.i230:                                       ; preds = %__barray_mask_check_not_borrowed.exit229
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit231:                     ; preds = %__barray_mask_check_not_borrowed.exit229
  %34 = load i64, ptr %23, align 4
  %35 = and i64 %32, -2
  store i64 %35, ptr %1, align 4
  store i64 %34, ptr %0, align 4
  %36 = load i64, ptr %1, align 4
  %37 = and i64 %36, 2
  %.not252 = icmp eq i64 %37, 0
  br i1 %.not252, label %panic.i232, label %__barray_mask_return.exit233

panic.i232:                                       ; preds = %__barray_mask_return.exit231
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit233:                     ; preds = %__barray_mask_return.exit231
  %38 = and i64 %36, -3
  store i64 %38, ptr %1, align 4
  store i64 %31, ptr %8, align 4
  %39 = load i64, ptr %1, align 4
  %40 = and i64 %39, 2
  %.not253 = icmp eq i64 %40, 0
  br i1 %.not253, label %__barray_mask_borrow.exit235, label %panic.i234

panic.i234:                                       ; preds = %__barray_mask_return.exit233
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit235:                     ; preds = %__barray_mask_return.exit233
  %41 = or disjoint i64 %39, 2
  store i64 %41, ptr %1, align 4
  %42 = trunc i64 %39 to i1
  br i1 %42, label %panic.i236, label %__barray_mask_borrow.exit237

panic.i236:                                       ; preds = %__barray_mask_borrow.exit235
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit237:                     ; preds = %__barray_mask_borrow.exit235
  %43 = load i64, ptr %8, align 4
  %44 = or disjoint i64 %39, 3
  store i64 %44, ptr %1, align 4
  %45 = load i64, ptr %0, align 4
  %46 = call ptr @heap_alloc(i64 16)
  %47 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %47, align 1
  store i64 %43, ptr %46, align 4
  %48 = getelementptr inbounds nuw i8, ptr %46, i64 8
  store i64 %45, ptr %48, align 4
  %49 = load i64, ptr %47, align 4
  %50 = and i64 %49, 3
  store i64 %50, ptr %47, align 4
  %51 = icmp eq i64 %50, 0
  br i1 %51, label %__barray_mask_check_not_borrowed.exit243, label %mask_block_err.i238

mask_block_err.i238:                              ; preds = %__barray_mask_borrow.exit237
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_mask_check_not_borrowed.exit243:         ; preds = %__barray_mask_borrow.exit237
  %out_arr_alloca130 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr132 = getelementptr inbounds nuw i8, ptr %out_arr_alloca130, i64 4
  %arr_ptr133 = getelementptr inbounds nuw i8, ptr %out_arr_alloca130, i64 8
  %mask_ptr134 = getelementptr inbounds nuw i8, ptr %out_arr_alloca130, i64 16
  %52 = alloca [2 x i1], align 1
  store i1 false, ptr %52, align 1
  %.repack219 = getelementptr inbounds nuw i8, ptr %52, i64 1
  store i1 false, ptr %.repack219, align 1
  store i32 2, ptr %out_arr_alloca130, align 8
  store i32 1, ptr %y_ptr132, align 4
  store ptr %46, ptr %arr_ptr133, align 8
  store ptr %52, ptr %mask_ptr134, align 8
  call void @print_state_result(ptr nonnull @res_reversed.22BDFB76.0, i64 19, ptr nonnull %out_arr_alloca130)
  %53 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %53, align 1
  %54 = load i64, ptr %48, align 4
  %55 = load i64, ptr %1, align 4
  %56 = and i64 %55, 2
  %.not254 = icmp eq i64 %56, 0
  br i1 %.not254, label %panic.i244, label %__barray_mask_return.exit245

panic.i244:                                       ; preds = %__barray_mask_check_not_borrowed.exit243
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit245:                     ; preds = %__barray_mask_check_not_borrowed.exit243
  %57 = load i64, ptr %46, align 4
  %58 = and i64 %55, -3
  store i64 %58, ptr %1, align 4
  store i64 %57, ptr %8, align 4
  %59 = load i64, ptr %1, align 4
  %60 = trunc i64 %59 to i1
  br i1 %60, label %__barray_mask_return.exit247, label %panic.i246

panic.i246:                                       ; preds = %__barray_mask_return.exit245
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit247:                     ; preds = %__barray_mask_return.exit245
  %61 = and i64 %59, -2
  store i64 %61, ptr %1, align 4
  store i64 %54, ptr %0, align 4
  %62 = load i64, ptr %1, align 4
  %63 = trunc i64 %62 to i1
  br i1 %63, label %__barray_check_bounds.exit.1.i, label %__barray_mask_borrow.exit.i

__barray_check_bounds.exit.1.i:                   ; preds = %__barray_mask_borrow.exit.i, %__barray_mask_return.exit247
  %64 = phi i64 [ %.pre, %__barray_mask_borrow.exit.i ], [ %62, %__barray_mask_return.exit247 ]
  %65 = and i64 %64, 2
  %.not.i = icmp eq i64 %65, 0
  br i1 %.not.i, label %__barray_mask_borrow.exit.1.i, label %cond_exit_199.i

__barray_mask_borrow.exit.1.i:                    ; preds = %__barray_check_bounds.exit.1.i
  %66 = or disjoint i64 %64, 2
  store i64 %66, ptr %1, align 4
  %67 = load i64, ptr %8, align 4
  call void @___qfree(i64 %67)
  %.pre.i = load i64, ptr %1, align 4
  br label %cond_exit_199.i

cond_exit_199.i:                                  ; preds = %__barray_mask_borrow.exit.1.i, %__barray_check_bounds.exit.1.i
  %68 = phi i64 [ %.pre.i, %__barray_mask_borrow.exit.1.i ], [ %64, %__barray_check_bounds.exit.1.i ]
  %69 = or i64 %68, -4
  store i64 %69, ptr %1, align 4
  %70 = icmp eq i64 %69, -1
  br i1 %70, label %"__hugr__.guppylang.std.quantum.discard_array$2.157.exit", label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %cond_exit_199.i
  call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit.i:                      ; preds = %__barray_mask_return.exit247
  %71 = or disjoint i64 %62, 1
  store i64 %71, ptr %1, align 4
  %72 = load i64, ptr %0, align 4
  call void @___qfree(i64 %72)
  %.pre = load i64, ptr %1, align 4
  br label %__barray_check_bounds.exit.1.i

"__hugr__.guppylang.std.quantum.discard_array$2.157.exit": ; preds = %cond_exit_199.i
  call void @heap_free(ptr nonnull %0)
  call void @heap_free(ptr nonnull %1)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @print_state_result(ptr, i64, ptr) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

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
