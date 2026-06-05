; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_entangled_.CC58B637.0 = private constant [27 x i8] c"\1AUSER:STATE:entangled_state"
@res_c0.7C14CD6E.0 = private constant [13 x i8] c"\0CUSER:BOOL:c0"
@res_post_measu.3B49B396.0 = private constant [34 x i8] c"!USER:STATE:post_measurement_state"
@res_c1.1F7A6571.0 = private constant [13 x i8] c"\0CUSER:BOOL:c1"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_40_case_0.i, label %__hugr__.__tk2_sol_qalloc.36.exit

cond_40_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.36.exit:                ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18)
  %qalloc.i100 = tail call i64 @___qalloc()
  %not_max.not.not.i101 = icmp eq i64 %qalloc.i100, -1
  br i1 %not_max.not.not.i101, label %cond_54_case_0.i, label %__hugr__.__tk2_sol_qalloc.50.exit

cond_54_case_0.i:                                 ; preds = %__hugr__.__tk2_sol_qalloc.36.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.50.exit:                ; preds = %__hugr__.__tk2_sol_qalloc.36.exit
  tail call void @___reset(i64 %qalloc.i100)
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i, i64 %qalloc.i100, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i100, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  %0 = tail call ptr @heap_alloc(i64 16)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %1, align 1
  store i64 %qalloc.i, ptr %0, align 4
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i100, ptr %2, align 4
  %3 = load i64, ptr %1, align 4
  %4 = and i64 %3, 3
  store i64 %4, ptr %1, align 4
  %5 = icmp eq i64 %4, 0
  br i1 %5, label %__barray_mask_check_not_borrowed.exit103, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_sol_qalloc.50.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_mask_check_not_borrowed.exit103:         ; preds = %__hugr__.__tk2_sol_qalloc.50.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %6 = alloca [2 x i1], align 1
  store i1 false, ptr %6, align 1
  %.repack99 = getelementptr inbounds nuw i8, ptr %6, i64 1
  store i1 false, ptr %.repack99, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %6, ptr %mask_ptr, align 8
  call void @print_state_result(ptr nonnull @res_entangled_.CC58B637.0, i64 26, ptr nonnull %out_arr_alloca)
  %7 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %7, align 1
  %8 = load i64, ptr %0, align 4
  %9 = load i64, ptr %2, align 4
  %10 = call ptr @heap_alloc(i64 8)
  %11 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %11, align 1
  store i64 %9, ptr %10, align 4
  %12 = load i64, ptr %11, align 4
  %13 = and i64 %12, 1
  store i64 %13, ptr %11, align 4
  %14 = icmp eq i64 %13, 0
  br i1 %14, label %__barray_mask_check_not_borrowed.exit107, label %mask_block_err.i104

mask_block_err.i104:                              ; preds = %__barray_mask_check_not_borrowed.exit103
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_mask_check_not_borrowed.exit107:         ; preds = %__barray_mask_check_not_borrowed.exit103
  %lazy_measure = call i64 @___lazy_measure(i64 %8)
  call void @___qfree(i64 %8)
  %read_bool = call i1 @___read_future_bool(i64 %lazy_measure)
  call void @___dec_future_refcount(i64 %lazy_measure)
  call void @print_bool(ptr nonnull @res_c0.7C14CD6E.0, i64 12, i1 %read_bool)
  %out_arr_alloca34 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr36 = getelementptr inbounds nuw i8, ptr %out_arr_alloca34, i64 4
  %arr_ptr37 = getelementptr inbounds nuw i8, ptr %out_arr_alloca34, i64 8
  %mask_ptr38 = getelementptr inbounds nuw i8, ptr %out_arr_alloca34, i64 16
  %15 = alloca i1, align 1
  store i1 false, ptr %15, align 1
  store i32 1, ptr %out_arr_alloca34, align 8
  store i32 1, ptr %y_ptr36, align 4
  store ptr %10, ptr %arr_ptr37, align 8
  store ptr %15, ptr %mask_ptr38, align 8
  call void @print_state_result(ptr nonnull @res_post_measu.3B49B396.0, i64 33, ptr nonnull %out_arr_alloca34)
  %16 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %16, align 1
  %17 = load i64, ptr %10, align 4
  %lazy_measure48 = call i64 @___lazy_measure(i64 %17)
  call void @___qfree(i64 %17)
  %read_bool50 = call i1 @___read_future_bool(i64 %lazy_measure48)
  call void @___dec_future_refcount(i64 %lazy_measure48)
  call void @print_bool(ptr nonnull @res_c1.1F7A6571.0, i64 12, i1 %read_bool50)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @print_state_result(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

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
