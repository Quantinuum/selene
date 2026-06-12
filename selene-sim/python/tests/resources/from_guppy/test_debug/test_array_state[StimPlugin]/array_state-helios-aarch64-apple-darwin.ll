; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_array_stat.71E0AE77.0 = private constant [23 x i8] c"\16USER:STATE:array_state"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 16)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_307_case_0.i, label %__hugr__.__tk2_helios_qalloc.303.exit

cond_307_case_0.i:                                ; preds = %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.303.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.1, %__hugr__.__tk2_helios_qalloc.303.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.303.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_307_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not = icmp eq i64 %6, 0
  br i1 %.not, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %9 = load i64, ptr %1, align 4
  %10 = trunc i64 %9 to i1
  br i1 %10, label %panic.i318, label %__barray_check_bounds.exit320

panic.i318:                                       ; preds = %__barray_check_bounds.exit317.1, %cond_exit_20.1
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit320:                    ; preds = %cond_exit_20.1
  %11 = or disjoint i64 %9, 1
  store i64 %11, ptr %1, align 4
  %12 = load i64, ptr %0, align 4
  tail call void @___rxy(i64 %12, double 0x400921FB54442D18, double 0.000000e+00)
  %13 = load i64, ptr %1, align 4
  %14 = trunc i64 %13 to i1
  br i1 %14, label %__barray_check_bounds.exit317.1, label %panic.i321

panic.i321:                                       ; preds = %__barray_check_bounds.exit320.1, %__barray_check_bounds.exit320
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit317.1:                  ; preds = %__barray_check_bounds.exit320
  %15 = and i64 %13, -2
  store i64 %15, ptr %1, align 4
  store i64 %12, ptr %0, align 4
  %16 = load i64, ptr %1, align 4
  %17 = and i64 %16, 2
  %.not338 = icmp eq i64 %17, 0
  br i1 %.not338, label %__barray_check_bounds.exit320.1, label %panic.i318

__barray_check_bounds.exit320.1:                  ; preds = %__barray_check_bounds.exit317.1
  %18 = or disjoint i64 %16, 2
  store i64 %18, ptr %1, align 4
  %19 = load i64, ptr %8, align 4
  tail call void @___rxy(i64 %19, double 0x400921FB54442D18, double 0.000000e+00)
  %20 = load i64, ptr %1, align 4
  %21 = and i64 %20, 2
  %.not339 = icmp eq i64 %21, 0
  br i1 %.not339, label %panic.i321, label %__barray_mask_return.exit322.1

__barray_mask_return.exit322.1:                   ; preds = %__barray_check_bounds.exit320.1
  %22 = and i64 %20, -3
  store i64 %22, ptr %1, align 4
  store i64 %19, ptr %8, align 4
  %23 = load i64, ptr %1, align 4
  %24 = and i64 %23, 3
  store i64 %24, ptr %1, align 4
  %25 = icmp eq i64 %24, 0
  br i1 %25, label %__barray_check_bounds.exit.1.i, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__barray_mask_return.exit322.1
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit.1.i:                   ; preds = %__barray_mask_return.exit322.1
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %26 = alloca [2 x i1], align 1
  store i1 false, ptr %26, align 1
  %.repack309 = getelementptr inbounds nuw i8, ptr %26, i64 1
  store i1 false, ptr %.repack309, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %26, ptr %mask_ptr, align 8
  call void @print_state_result(ptr nonnull @res_array_stat.71E0AE77.0, i64 22, ptr nonnull %out_arr_alloca)
  %27 = call ptr @heap_alloc(i64 8)
  store i64 1, ptr %27, align 4
  %28 = load i64, ptr %0, align 4
  call void @___qfree(i64 %28)
  %29 = load i64, ptr %27, align 4
  %30 = and i64 %29, 2
  %.not.i = icmp eq i64 %30, 0
  br i1 %.not.i, label %__barray_mask_borrow.exit.1.i, label %cond_exit_222.i

__barray_mask_borrow.exit.1.i:                    ; preds = %__barray_check_bounds.exit.1.i
  %31 = or disjoint i64 %29, 2
  store i64 %31, ptr %27, align 4
  %32 = load i64, ptr %8, align 4
  call void @___qfree(i64 %32)
  %.pre.i = load i64, ptr %27, align 4
  br label %cond_exit_222.i

cond_exit_222.i:                                  ; preds = %__barray_mask_borrow.exit.1.i, %__barray_check_bounds.exit.1.i
  %33 = phi i64 [ %.pre.i, %__barray_mask_borrow.exit.1.i ], [ %29, %__barray_check_bounds.exit.1.i ]
  %34 = or i64 %33, -4
  store i64 %34, ptr %27, align 4
  %35 = icmp eq i64 %34, -1
  br i1 %35, label %"__hugr__.guppylang.std.quantum.discard_array$2.180.exit", label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %cond_exit_222.i
  call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

"__hugr__.guppylang.std.quantum.discard_array$2.180.exit": ; preds = %cond_exit_222.i
  call void @heap_free(ptr nonnull %0)
  call void @heap_free(ptr nonnull %27)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @print_state_result(ptr, i64, ptr) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

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
