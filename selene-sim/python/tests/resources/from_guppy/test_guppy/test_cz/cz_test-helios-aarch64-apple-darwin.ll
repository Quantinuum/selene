; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_c.19197FA6.0 = private constant [15 x i8] c"\0EUSER:BOOLARR:c"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_51_case_0.i, label %__hugr__.__tk2_helios_qalloc.47.exit

cond_51_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.47.exit:             ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %qalloc.i49 = tail call i64 @___qalloc()
  %not_max.not.not.i50 = icmp eq i64 %qalloc.i49, -1
  br i1 %not_max.not.not.i50, label %cond_65_case_0.i, label %__hugr__.__tk2_helios_qalloc.61.exit

cond_65_case_0.i:                                 ; preds = %__hugr__.__tk2_helios_qalloc.47.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.61.exit:             ; preds = %__hugr__.__tk2_helios_qalloc.47.exit
  tail call void @___reset(i64 %qalloc.i49)
  tail call void @___rxy(i64 %qalloc.i, double 0x40316444CB580C0B, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %qalloc.i, i64 %qalloc.i49, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i49, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %qalloc.i, double 0x40316444CB580C0B, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %qalloc.i, i64 %qalloc.i49, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i49, double 0xBFF921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  %lazy_measure10 = tail call i64 @___lazy_measure(i64 %qalloc.i49)
  tail call void @___qfree(i64 %qalloc.i49)
  %read_bool = tail call i1 @___read_future_bool(i64 %lazy_measure10)
  tail call void @___dec_future_refcount(i64 %lazy_measure10)
  %read_bool13 = tail call i1 @___read_future_bool(i64 %lazy_measure)
  tail call void @___dec_future_refcount(i64 %lazy_measure)
  %0 = tail call ptr @heap_alloc(i64 2)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %1, align 1
  store i1 %read_bool13, ptr %0, align 1
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 1
  store i1 %read_bool, ptr %2, align 1
  %3 = load i64, ptr %1, align 4
  %4 = and i64 %3, 3
  store i64 %4, ptr %1, align 4
  %5 = icmp eq i64 %4, 0
  br i1 %5, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_helios_qalloc.61.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %__hugr__.__tk2_helios_qalloc.61.exit
  %6 = tail call ptr @heap_alloc(i64 2)
  %7 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %7, align 1
  %8 = load i16, ptr %0, align 1
  store i16 %8, ptr %6, align 1
  tail call void @heap_free(ptr nonnull %6)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 3
  store i64 %10, ptr %1, align 4
  %11 = icmp eq i64 %10, 0
  br i1 %11, label %__barray_check_none_borrowed.exit54, label %mask_block_err.i53

mask_block_err.i53:                               ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit54:              ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %12 = alloca [2 x i1], align 1
  store i1 false, ptr %12, align 1
  %.repack48 = getelementptr inbounds nuw i8, ptr %12, i64 1
  store i1 false, ptr %.repack48, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %12, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_c.19197FA6.0, i64 14, ptr nonnull %out_arr_alloca)
  ret void
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

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
