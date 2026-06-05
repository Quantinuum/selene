; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_00.00F9F73D.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:00"
@res_01.2F21FB33.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:01"
@res_10.90CD55C3.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:10"
@res_11.7D0DF573.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:11"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define internal fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_89_case_0.i, label %__hugr__.__tk2_sol_qalloc.85.exit

cond_89_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.85.exit:                ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %qalloc.i241 = tail call i64 @___qalloc()
  %not_max.not.not.i242 = icmp eq i64 %qalloc.i241, -1
  br i1 %not_max.not.not.i242, label %cond_103_case_0.i, label %__hugr__.__tk2_sol_qalloc.99.exit

cond_103_case_0.i:                                ; preds = %__hugr__.__tk2_sol_qalloc.85.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.99.exit:                ; preds = %__hugr__.__tk2_sol_qalloc.85.exit
  tail call void @___reset(i64 %qalloc.i241)
  tail call void @___rz(i64 %qalloc.i241, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i, i64 %qalloc.i241, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i241, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rz(i64 %qalloc.i241, double 0x3FF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___rp(i64 %qalloc.i241, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure6 = tail call i64 @___lazy_measure(i64 %qalloc.i241)
  tail call void @___qfree(i64 %qalloc.i241)
  %read_bool = tail call i1 @___read_future_bool(i64 %lazy_measure6)
  tail call void @___dec_future_refcount(i64 %lazy_measure6)
  %read_bool9 = tail call i1 @___read_future_bool(i64 %lazy_measure)
  tail call void @___dec_future_refcount(i64 %lazy_measure)
  %0 = tail call ptr @heap_alloc(i64 2)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %1, align 1
  store i1 %read_bool9, ptr %0, align 1
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 1
  store i1 %read_bool, ptr %2, align 1
  %3 = load i64, ptr %1, align 4
  %4 = and i64 %3, 3
  store i64 %4, ptr %1, align 4
  %5 = icmp eq i64 %4, 0
  br i1 %5, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_sol_qalloc.99.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %__hugr__.__tk2_sol_qalloc.99.exit
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
  br i1 %11, label %__barray_check_none_borrowed.exit244, label %mask_block_err.i243

mask_block_err.i243:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit244:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %12 = alloca [2 x i1], align 1
  store i1 false, ptr %12, align 1
  %.repack237 = getelementptr inbounds nuw i8, ptr %12, i64 1
  store i1 false, ptr %.repack237, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %12, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_00.00F9F73D.0, i64 15, ptr nonnull %out_arr_alloca)
  %qalloc.i245 = call i64 @___qalloc()
  %not_max.not.not.i246 = icmp eq i64 %qalloc.i245, -1
  br i1 %not_max.not.not.i246, label %cond_144_case_0.i, label %__hugr__.__tk2_sol_qalloc.140.exit

cond_144_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit244
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.140.exit:               ; preds = %__barray_check_none_borrowed.exit244
  call void @___reset(i64 %qalloc.i245)
  %qalloc.i247 = call i64 @___qalloc()
  %not_max.not.not.i248 = icmp eq i64 %qalloc.i247, -1
  br i1 %not_max.not.not.i248, label %cond_158_case_0.i, label %__hugr__.__tk2_sol_qalloc.154.exit

cond_158_case_0.i:                                ; preds = %__hugr__.__tk2_sol_qalloc.140.exit
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.154.exit:               ; preds = %__hugr__.__tk2_sol_qalloc.140.exit
  call void @___reset(i64 %qalloc.i247)
  call void @___rp(i64 %qalloc.i247, double 0x400921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i247, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i245, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i245, i64 %qalloc.i247, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i247, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i247, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i245, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i245, double 0xBFF921FB54442D18)
  %lazy_measure29 = call i64 @___lazy_measure(i64 %qalloc.i245)
  call void @___qfree(i64 %qalloc.i245)
  call void @___rp(i64 %qalloc.i247, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure32 = call i64 @___lazy_measure(i64 %qalloc.i247)
  call void @___qfree(i64 %qalloc.i247)
  %read_bool34 = call i1 @___read_future_bool(i64 %lazy_measure32)
  call void @___dec_future_refcount(i64 %lazy_measure32)
  %read_bool37 = call i1 @___read_future_bool(i64 %lazy_measure29)
  call void @___dec_future_refcount(i64 %lazy_measure29)
  %13 = call ptr @heap_alloc(i64 2)
  %14 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %14, align 1
  store i1 %read_bool37, ptr %13, align 1
  %15 = getelementptr inbounds nuw i8, ptr %13, i64 1
  store i1 %read_bool34, ptr %15, align 1
  %16 = load i64, ptr %14, align 4
  %17 = and i64 %16, 3
  store i64 %17, ptr %14, align 4
  %18 = icmp eq i64 %17, 0
  br i1 %18, label %__barray_check_none_borrowed.exit252, label %mask_block_err.i251

mask_block_err.i251:                              ; preds = %__hugr__.__tk2_sol_qalloc.154.exit
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit252:             ; preds = %__hugr__.__tk2_sol_qalloc.154.exit
  %19 = call ptr @heap_alloc(i64 2)
  %20 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %20, align 1
  %21 = load i16, ptr %13, align 1
  store i16 %21, ptr %19, align 1
  call void @heap_free(ptr nonnull %19)
  %22 = load i64, ptr %14, align 4
  %23 = and i64 %22, 3
  store i64 %23, ptr %14, align 4
  %24 = icmp eq i64 %23, 0
  br i1 %24, label %__barray_check_none_borrowed.exit254, label %mask_block_err.i253

mask_block_err.i253:                              ; preds = %__barray_check_none_borrowed.exit252
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit254:             ; preds = %__barray_check_none_borrowed.exit252
  %out_arr_alloca58 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr60 = getelementptr inbounds nuw i8, ptr %out_arr_alloca58, i64 4
  %arr_ptr61 = getelementptr inbounds nuw i8, ptr %out_arr_alloca58, i64 8
  %mask_ptr62 = getelementptr inbounds nuw i8, ptr %out_arr_alloca58, i64 16
  %25 = alloca [2 x i1], align 1
  store i1 false, ptr %25, align 1
  %.repack238 = getelementptr inbounds nuw i8, ptr %25, i64 1
  store i1 false, ptr %.repack238, align 1
  store i32 2, ptr %out_arr_alloca58, align 8
  store i32 1, ptr %y_ptr60, align 4
  store ptr %13, ptr %arr_ptr61, align 8
  store ptr %25, ptr %mask_ptr62, align 8
  call void @print_bool_arr(ptr nonnull @res_01.2F21FB33.0, i64 15, ptr nonnull %out_arr_alloca58)
  %qalloc.i255 = call i64 @___qalloc()
  %not_max.not.not.i256 = icmp eq i64 %qalloc.i255, -1
  br i1 %not_max.not.not.i256, label %cond_207_case_0.i, label %__hugr__.__tk2_sol_qalloc.203.exit

cond_207_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit254
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.203.exit:               ; preds = %__barray_check_none_borrowed.exit254
  call void @___reset(i64 %qalloc.i255)
  call void @___rp(i64 %qalloc.i255, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i257 = call i64 @___qalloc()
  %not_max.not.not.i258 = icmp eq i64 %qalloc.i257, -1
  br i1 %not_max.not.not.i258, label %cond_221_case_0.i, label %__hugr__.__tk2_sol_qalloc.217.exit

cond_221_case_0.i:                                ; preds = %__hugr__.__tk2_sol_qalloc.203.exit
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.217.exit:               ; preds = %__hugr__.__tk2_sol_qalloc.203.exit
  call void @___reset(i64 %qalloc.i257)
  call void @___rz(i64 %qalloc.i257, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i255, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i255, i64 %qalloc.i257, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i257, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i257, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i255, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i255, double 0xBFF921FB54442D18)
  %lazy_measure67 = call i64 @___lazy_measure(i64 %qalloc.i255)
  call void @___qfree(i64 %qalloc.i255)
  call void @___rp(i64 %qalloc.i257, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure70 = call i64 @___lazy_measure(i64 %qalloc.i257)
  call void @___qfree(i64 %qalloc.i257)
  %read_bool72 = call i1 @___read_future_bool(i64 %lazy_measure70)
  call void @___dec_future_refcount(i64 %lazy_measure70)
  %read_bool75 = call i1 @___read_future_bool(i64 %lazy_measure67)
  call void @___dec_future_refcount(i64 %lazy_measure67)
  %26 = call ptr @heap_alloc(i64 2)
  %27 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %27, align 1
  store i1 %read_bool75, ptr %26, align 1
  %28 = getelementptr inbounds nuw i8, ptr %26, i64 1
  store i1 %read_bool72, ptr %28, align 1
  %29 = load i64, ptr %27, align 4
  %30 = and i64 %29, 3
  store i64 %30, ptr %27, align 4
  %31 = icmp eq i64 %30, 0
  br i1 %31, label %__barray_check_none_borrowed.exit262, label %mask_block_err.i261

mask_block_err.i261:                              ; preds = %__hugr__.__tk2_sol_qalloc.217.exit
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit262:             ; preds = %__hugr__.__tk2_sol_qalloc.217.exit
  %32 = call ptr @heap_alloc(i64 2)
  %33 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %33, align 1
  %34 = load i16, ptr %26, align 1
  store i16 %34, ptr %32, align 1
  call void @heap_free(ptr nonnull %32)
  %35 = load i64, ptr %27, align 4
  %36 = and i64 %35, 3
  store i64 %36, ptr %27, align 4
  %37 = icmp eq i64 %36, 0
  br i1 %37, label %__barray_check_none_borrowed.exit264, label %mask_block_err.i263

mask_block_err.i263:                              ; preds = %__barray_check_none_borrowed.exit262
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit264:             ; preds = %__barray_check_none_borrowed.exit262
  %out_arr_alloca96 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr98 = getelementptr inbounds nuw i8, ptr %out_arr_alloca96, i64 4
  %arr_ptr99 = getelementptr inbounds nuw i8, ptr %out_arr_alloca96, i64 8
  %mask_ptr100 = getelementptr inbounds nuw i8, ptr %out_arr_alloca96, i64 16
  %38 = alloca [2 x i1], align 1
  store i1 false, ptr %38, align 1
  %.repack239 = getelementptr inbounds nuw i8, ptr %38, i64 1
  store i1 false, ptr %.repack239, align 1
  store i32 2, ptr %out_arr_alloca96, align 8
  store i32 1, ptr %y_ptr98, align 4
  store ptr %26, ptr %arr_ptr99, align 8
  store ptr %38, ptr %mask_ptr100, align 8
  call void @print_bool_arr(ptr nonnull @res_10.90CD55C3.0, i64 15, ptr nonnull %out_arr_alloca96)
  %qalloc.i265 = call i64 @___qalloc()
  %not_max.not.not.i266 = icmp eq i64 %qalloc.i265, -1
  br i1 %not_max.not.not.i266, label %cond_270_case_0.i, label %__hugr__.__tk2_sol_qalloc.266.exit

cond_270_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit264
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.266.exit:               ; preds = %__barray_check_none_borrowed.exit264
  call void @___reset(i64 %qalloc.i265)
  call void @___rp(i64 %qalloc.i265, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i267 = call i64 @___qalloc()
  %not_max.not.not.i268 = icmp eq i64 %qalloc.i267, -1
  br i1 %not_max.not.not.i268, label %cond_284_case_0.i, label %__hugr__.__tk2_sol_qalloc.280.exit

cond_284_case_0.i:                                ; preds = %__hugr__.__tk2_sol_qalloc.266.exit
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.280.exit:               ; preds = %__hugr__.__tk2_sol_qalloc.266.exit
  call void @___reset(i64 %qalloc.i267)
  call void @___rp(i64 %qalloc.i267, double 0x400921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i267, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i265, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i265, i64 %qalloc.i267, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i267, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i267, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i265, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i265, double 0xBFF921FB54442D18)
  %lazy_measure106 = call i64 @___lazy_measure(i64 %qalloc.i265)
  call void @___qfree(i64 %qalloc.i265)
  call void @___rp(i64 %qalloc.i267, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure109 = call i64 @___lazy_measure(i64 %qalloc.i267)
  call void @___qfree(i64 %qalloc.i267)
  %read_bool111 = call i1 @___read_future_bool(i64 %lazy_measure109)
  call void @___dec_future_refcount(i64 %lazy_measure109)
  %read_bool114 = call i1 @___read_future_bool(i64 %lazy_measure106)
  call void @___dec_future_refcount(i64 %lazy_measure106)
  %39 = call ptr @heap_alloc(i64 2)
  %40 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %40, align 1
  store i1 %read_bool114, ptr %39, align 1
  %41 = getelementptr inbounds nuw i8, ptr %39, i64 1
  store i1 %read_bool111, ptr %41, align 1
  %42 = load i64, ptr %40, align 4
  %43 = and i64 %42, 3
  store i64 %43, ptr %40, align 4
  %44 = icmp eq i64 %43, 0
  br i1 %44, label %__barray_check_none_borrowed.exit272, label %mask_block_err.i271

mask_block_err.i271:                              ; preds = %__hugr__.__tk2_sol_qalloc.280.exit
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit272:             ; preds = %__hugr__.__tk2_sol_qalloc.280.exit
  %45 = call ptr @heap_alloc(i64 2)
  %46 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %46, align 1
  %47 = load i16, ptr %39, align 1
  store i16 %47, ptr %45, align 1
  call void @heap_free(ptr nonnull %45)
  %48 = load i64, ptr %40, align 4
  %49 = and i64 %48, 3
  store i64 %49, ptr %40, align 4
  %50 = icmp eq i64 %49, 0
  br i1 %50, label %__barray_check_none_borrowed.exit274, label %mask_block_err.i273

mask_block_err.i273:                              ; preds = %__barray_check_none_borrowed.exit272
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit274:             ; preds = %__barray_check_none_borrowed.exit272
  %out_arr_alloca135 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr137 = getelementptr inbounds nuw i8, ptr %out_arr_alloca135, i64 4
  %arr_ptr138 = getelementptr inbounds nuw i8, ptr %out_arr_alloca135, i64 8
  %mask_ptr139 = getelementptr inbounds nuw i8, ptr %out_arr_alloca135, i64 16
  %51 = alloca [2 x i1], align 1
  store i1 false, ptr %51, align 1
  %.repack240 = getelementptr inbounds nuw i8, ptr %51, i64 1
  store i1 false, ptr %.repack240, align 1
  store i32 2, ptr %out_arr_alloca135, align 8
  store i32 1, ptr %y_ptr137, align 4
  store ptr %39, ptr %arr_ptr138, align 8
  store ptr %51, ptr %mask_ptr139, align 8
  call void @print_bool_arr(ptr nonnull @res_11.7D0DF573.0, i64 15, ptr nonnull %out_arr_alloca135)
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

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

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
