; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_00.00F9F73D.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:00"
@res_01.2F21FB33.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:01"
@res_10.90CD55C3.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:10"
@res_11.7D0DF573.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:11"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define internal fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_64_case_0.i, label %__hugr__.__tk2_sol_qalloc.60.exit

cond_64_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.60.exit:                ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %qalloc.i249 = tail call i64 @___qalloc()
  %not_max.not.not.i250 = icmp eq i64 %qalloc.i249, -1
  br i1 %not_max.not.not.i250, label %cond_64_case_0.i251, label %__hugr__.__tk2_sol_qalloc.60.exit252

cond_64_case_0.i251:                              ; preds = %__hugr__.__tk2_sol_qalloc.60.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.60.exit252:             ; preds = %__hugr__.__tk2_sol_qalloc.60.exit
  tail call void @___reset(i64 %qalloc.i249)
  tail call void @___rz(i64 %qalloc.i249, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i, i64 %qalloc.i249, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i249, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rz(i64 %qalloc.i249, double 0x3FF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___rp(i64 %qalloc.i249, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure6 = tail call i64 @___lazy_measure(i64 %qalloc.i249)
  tail call void @___qfree(i64 %qalloc.i249)
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

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_sol_qalloc.60.exit252
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %__hugr__.__tk2_sol_qalloc.60.exit252
  %6 = tail call ptr @heap_alloc(i64 2)
  %7 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %7, align 1
  %8 = load i16, ptr %0, align 1
  store i16 %8, ptr %6, align 1
  %9 = load i64, ptr %7, align 4
  %10 = trunc i64 %9 to i1
  br i1 %10, label %panic.i, label %__barray_mask_check_not_borrowed.exit

panic.i:                                          ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit:            ; preds = %__barray_check_none_borrowed.exit
  %11 = and i64 %9, 2
  %.not = icmp eq i64 %11, 0
  br i1 %.not, label %__barray_mask_check_not_borrowed.exit254, label %panic.i253

panic.i253:                                       ; preds = %__barray_mask_check_not_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit254:         ; preds = %__barray_mask_check_not_borrowed.exit
  %12 = load i64, ptr %1, align 4
  %13 = and i64 %12, 3
  store i64 %13, ptr %1, align 4
  %14 = icmp eq i64 %13, 0
  br i1 %14, label %__barray_check_none_borrowed.exit256, label %mask_block_err.i255

mask_block_err.i255:                              ; preds = %__barray_mask_check_not_borrowed.exit254
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit256:             ; preds = %__barray_mask_check_not_borrowed.exit254
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %15 = alloca [2 x i1], align 1
  store i1 false, ptr %15, align 1
  %.repack245 = getelementptr inbounds nuw i8, ptr %15, i64 1
  store i1 false, ptr %.repack245, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %15, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_00.00F9F73D.0, i64 15, ptr nonnull %out_arr_alloca)
  %qalloc.i257 = call i64 @___qalloc()
  %not_max.not.not.i258 = icmp eq i64 %qalloc.i257, -1
  br i1 %not_max.not.not.i258, label %cond_64_case_0.i259, label %__hugr__.__tk2_sol_qalloc.60.exit260

cond_64_case_0.i259:                              ; preds = %__barray_check_none_borrowed.exit256
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.60.exit260:             ; preds = %__barray_check_none_borrowed.exit256
  call void @___reset(i64 %qalloc.i257)
  %qalloc.i261 = call i64 @___qalloc()
  %not_max.not.not.i262 = icmp eq i64 %qalloc.i261, -1
  br i1 %not_max.not.not.i262, label %cond_64_case_0.i263, label %__hugr__.__tk2_sol_qalloc.60.exit264

cond_64_case_0.i263:                              ; preds = %__hugr__.__tk2_sol_qalloc.60.exit260
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.60.exit264:             ; preds = %__hugr__.__tk2_sol_qalloc.60.exit260
  call void @___reset(i64 %qalloc.i261)
  call void @___rp(i64 %qalloc.i261, double 0x400921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i261, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i257, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i257, i64 %qalloc.i261, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i261, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i261, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i257, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i257, double 0xBFF921FB54442D18)
  %lazy_measure31 = call i64 @___lazy_measure(i64 %qalloc.i257)
  call void @___qfree(i64 %qalloc.i257)
  call void @___rp(i64 %qalloc.i261, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure34 = call i64 @___lazy_measure(i64 %qalloc.i261)
  call void @___qfree(i64 %qalloc.i261)
  %read_bool36 = call i1 @___read_future_bool(i64 %lazy_measure34)
  call void @___dec_future_refcount(i64 %lazy_measure34)
  %read_bool39 = call i1 @___read_future_bool(i64 %lazy_measure31)
  call void @___dec_future_refcount(i64 %lazy_measure31)
  %16 = call ptr @heap_alloc(i64 2)
  %17 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %17, align 1
  store i1 %read_bool39, ptr %16, align 1
  %18 = getelementptr inbounds nuw i8, ptr %16, i64 1
  store i1 %read_bool36, ptr %18, align 1
  %19 = load i64, ptr %17, align 4
  %20 = and i64 %19, 3
  store i64 %20, ptr %17, align 4
  %21 = icmp eq i64 %20, 0
  br i1 %21, label %__barray_check_none_borrowed.exit268, label %mask_block_err.i267

mask_block_err.i267:                              ; preds = %__hugr__.__tk2_sol_qalloc.60.exit264
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit268:             ; preds = %__hugr__.__tk2_sol_qalloc.60.exit264
  %22 = call ptr @heap_alloc(i64 2)
  %23 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %23, align 1
  %24 = load i16, ptr %16, align 1
  store i16 %24, ptr %22, align 1
  %25 = load i64, ptr %23, align 4
  %26 = trunc i64 %25 to i1
  br i1 %26, label %panic.i269, label %__barray_mask_check_not_borrowed.exit270

panic.i269:                                       ; preds = %__barray_check_none_borrowed.exit268
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit270:         ; preds = %__barray_check_none_borrowed.exit268
  %27 = and i64 %25, 2
  %.not311 = icmp eq i64 %27, 0
  br i1 %.not311, label %__barray_mask_check_not_borrowed.exit272, label %panic.i271

panic.i271:                                       ; preds = %__barray_mask_check_not_borrowed.exit270
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit272:         ; preds = %__barray_mask_check_not_borrowed.exit270
  %28 = load i64, ptr %17, align 4
  %29 = and i64 %28, 3
  store i64 %29, ptr %17, align 4
  %30 = icmp eq i64 %29, 0
  br i1 %30, label %__barray_check_none_borrowed.exit274, label %mask_block_err.i273

mask_block_err.i273:                              ; preds = %__barray_mask_check_not_borrowed.exit272
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit274:             ; preds = %__barray_mask_check_not_borrowed.exit272
  %out_arr_alloca62 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr64 = getelementptr inbounds nuw i8, ptr %out_arr_alloca62, i64 4
  %arr_ptr65 = getelementptr inbounds nuw i8, ptr %out_arr_alloca62, i64 8
  %mask_ptr66 = getelementptr inbounds nuw i8, ptr %out_arr_alloca62, i64 16
  %31 = alloca [2 x i1], align 1
  store i1 false, ptr %31, align 1
  %.repack246 = getelementptr inbounds nuw i8, ptr %31, i64 1
  store i1 false, ptr %.repack246, align 1
  store i32 2, ptr %out_arr_alloca62, align 8
  store i32 1, ptr %y_ptr64, align 4
  store ptr %16, ptr %arr_ptr65, align 8
  store ptr %31, ptr %mask_ptr66, align 8
  call void @print_bool_arr(ptr nonnull @res_01.2F21FB33.0, i64 15, ptr nonnull %out_arr_alloca62)
  %qalloc.i275 = call i64 @___qalloc()
  %not_max.not.not.i276 = icmp eq i64 %qalloc.i275, -1
  br i1 %not_max.not.not.i276, label %cond_64_case_0.i277, label %__hugr__.__tk2_sol_qalloc.60.exit278

cond_64_case_0.i277:                              ; preds = %__barray_check_none_borrowed.exit274
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.60.exit278:             ; preds = %__barray_check_none_borrowed.exit274
  call void @___reset(i64 %qalloc.i275)
  call void @___rp(i64 %qalloc.i275, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i279 = call i64 @___qalloc()
  %not_max.not.not.i280 = icmp eq i64 %qalloc.i279, -1
  br i1 %not_max.not.not.i280, label %cond_64_case_0.i281, label %__hugr__.__tk2_sol_qalloc.60.exit282

cond_64_case_0.i281:                              ; preds = %__hugr__.__tk2_sol_qalloc.60.exit278
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.60.exit282:             ; preds = %__hugr__.__tk2_sol_qalloc.60.exit278
  call void @___reset(i64 %qalloc.i279)
  call void @___rz(i64 %qalloc.i279, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i275, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i275, i64 %qalloc.i279, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i279, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i279, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i275, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i275, double 0xBFF921FB54442D18)
  %lazy_measure71 = call i64 @___lazy_measure(i64 %qalloc.i275)
  call void @___qfree(i64 %qalloc.i275)
  call void @___rp(i64 %qalloc.i279, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure74 = call i64 @___lazy_measure(i64 %qalloc.i279)
  call void @___qfree(i64 %qalloc.i279)
  %read_bool76 = call i1 @___read_future_bool(i64 %lazy_measure74)
  call void @___dec_future_refcount(i64 %lazy_measure74)
  %read_bool79 = call i1 @___read_future_bool(i64 %lazy_measure71)
  call void @___dec_future_refcount(i64 %lazy_measure71)
  %32 = call ptr @heap_alloc(i64 2)
  %33 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %33, align 1
  store i1 %read_bool79, ptr %32, align 1
  %34 = getelementptr inbounds nuw i8, ptr %32, i64 1
  store i1 %read_bool76, ptr %34, align 1
  %35 = load i64, ptr %33, align 4
  %36 = and i64 %35, 3
  store i64 %36, ptr %33, align 4
  %37 = icmp eq i64 %36, 0
  br i1 %37, label %__barray_check_none_borrowed.exit286, label %mask_block_err.i285

mask_block_err.i285:                              ; preds = %__hugr__.__tk2_sol_qalloc.60.exit282
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit286:             ; preds = %__hugr__.__tk2_sol_qalloc.60.exit282
  %38 = call ptr @heap_alloc(i64 2)
  %39 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %39, align 1
  %40 = load i16, ptr %32, align 1
  store i16 %40, ptr %38, align 1
  %41 = load i64, ptr %39, align 4
  %42 = trunc i64 %41 to i1
  br i1 %42, label %panic.i287, label %__barray_mask_check_not_borrowed.exit288

panic.i287:                                       ; preds = %__barray_check_none_borrowed.exit286
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit288:         ; preds = %__barray_check_none_borrowed.exit286
  %43 = and i64 %41, 2
  %.not312 = icmp eq i64 %43, 0
  br i1 %.not312, label %__barray_mask_check_not_borrowed.exit290, label %panic.i289

panic.i289:                                       ; preds = %__barray_mask_check_not_borrowed.exit288
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit290:         ; preds = %__barray_mask_check_not_borrowed.exit288
  %44 = load i64, ptr %33, align 4
  %45 = and i64 %44, 3
  store i64 %45, ptr %33, align 4
  %46 = icmp eq i64 %45, 0
  br i1 %46, label %__barray_check_none_borrowed.exit292, label %mask_block_err.i291

mask_block_err.i291:                              ; preds = %__barray_mask_check_not_borrowed.exit290
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit292:             ; preds = %__barray_mask_check_not_borrowed.exit290
  %out_arr_alloca102 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr104 = getelementptr inbounds nuw i8, ptr %out_arr_alloca102, i64 4
  %arr_ptr105 = getelementptr inbounds nuw i8, ptr %out_arr_alloca102, i64 8
  %mask_ptr106 = getelementptr inbounds nuw i8, ptr %out_arr_alloca102, i64 16
  %47 = alloca [2 x i1], align 1
  store i1 false, ptr %47, align 1
  %.repack247 = getelementptr inbounds nuw i8, ptr %47, i64 1
  store i1 false, ptr %.repack247, align 1
  store i32 2, ptr %out_arr_alloca102, align 8
  store i32 1, ptr %y_ptr104, align 4
  store ptr %32, ptr %arr_ptr105, align 8
  store ptr %47, ptr %mask_ptr106, align 8
  call void @print_bool_arr(ptr nonnull @res_10.90CD55C3.0, i64 15, ptr nonnull %out_arr_alloca102)
  %qalloc.i293 = call i64 @___qalloc()
  %not_max.not.not.i294 = icmp eq i64 %qalloc.i293, -1
  br i1 %not_max.not.not.i294, label %cond_64_case_0.i295, label %__hugr__.__tk2_sol_qalloc.60.exit296

cond_64_case_0.i295:                              ; preds = %__barray_check_none_borrowed.exit292
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.60.exit296:             ; preds = %__barray_check_none_borrowed.exit292
  call void @___reset(i64 %qalloc.i293)
  call void @___rp(i64 %qalloc.i293, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i297 = call i64 @___qalloc()
  %not_max.not.not.i298 = icmp eq i64 %qalloc.i297, -1
  br i1 %not_max.not.not.i298, label %cond_64_case_0.i299, label %__hugr__.__tk2_sol_qalloc.60.exit300

cond_64_case_0.i299:                              ; preds = %__hugr__.__tk2_sol_qalloc.60.exit296
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.60.exit300:             ; preds = %__hugr__.__tk2_sol_qalloc.60.exit296
  call void @___reset(i64 %qalloc.i297)
  call void @___rp(i64 %qalloc.i297, double 0x400921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i297, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i293, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i293, i64 %qalloc.i297, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i297, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i297, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i293, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i293, double 0xBFF921FB54442D18)
  %lazy_measure112 = call i64 @___lazy_measure(i64 %qalloc.i293)
  call void @___qfree(i64 %qalloc.i293)
  call void @___rp(i64 %qalloc.i297, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure115 = call i64 @___lazy_measure(i64 %qalloc.i297)
  call void @___qfree(i64 %qalloc.i297)
  %read_bool117 = call i1 @___read_future_bool(i64 %lazy_measure115)
  call void @___dec_future_refcount(i64 %lazy_measure115)
  %read_bool120 = call i1 @___read_future_bool(i64 %lazy_measure112)
  call void @___dec_future_refcount(i64 %lazy_measure112)
  %48 = call ptr @heap_alloc(i64 2)
  %49 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %49, align 1
  store i1 %read_bool120, ptr %48, align 1
  %50 = getelementptr inbounds nuw i8, ptr %48, i64 1
  store i1 %read_bool117, ptr %50, align 1
  %51 = load i64, ptr %49, align 4
  %52 = and i64 %51, 3
  store i64 %52, ptr %49, align 4
  %53 = icmp eq i64 %52, 0
  br i1 %53, label %__barray_check_none_borrowed.exit304, label %mask_block_err.i303

mask_block_err.i303:                              ; preds = %__hugr__.__tk2_sol_qalloc.60.exit300
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit304:             ; preds = %__hugr__.__tk2_sol_qalloc.60.exit300
  %54 = call ptr @heap_alloc(i64 2)
  %55 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %55, align 1
  %56 = load i16, ptr %48, align 1
  store i16 %56, ptr %54, align 1
  %57 = load i64, ptr %55, align 4
  %58 = trunc i64 %57 to i1
  br i1 %58, label %panic.i305, label %__barray_mask_check_not_borrowed.exit306

panic.i305:                                       ; preds = %__barray_check_none_borrowed.exit304
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit306:         ; preds = %__barray_check_none_borrowed.exit304
  %59 = and i64 %57, 2
  %.not313 = icmp eq i64 %59, 0
  br i1 %.not313, label %__barray_mask_check_not_borrowed.exit308, label %panic.i307

panic.i307:                                       ; preds = %__barray_mask_check_not_borrowed.exit306
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit308:         ; preds = %__barray_mask_check_not_borrowed.exit306
  %60 = load i64, ptr %49, align 4
  %61 = and i64 %60, 3
  store i64 %61, ptr %49, align 4
  %62 = icmp eq i64 %61, 0
  br i1 %62, label %__barray_check_none_borrowed.exit310, label %mask_block_err.i309

mask_block_err.i309:                              ; preds = %__barray_mask_check_not_borrowed.exit308
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit310:             ; preds = %__barray_mask_check_not_borrowed.exit308
  %out_arr_alloca143 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr145 = getelementptr inbounds nuw i8, ptr %out_arr_alloca143, i64 4
  %arr_ptr146 = getelementptr inbounds nuw i8, ptr %out_arr_alloca143, i64 8
  %mask_ptr147 = getelementptr inbounds nuw i8, ptr %out_arr_alloca143, i64 16
  %63 = alloca [2 x i1], align 1
  store i1 false, ptr %63, align 1
  %.repack248 = getelementptr inbounds nuw i8, ptr %63, i64 1
  store i1 false, ptr %.repack248, align 1
  store i32 2, ptr %out_arr_alloca143, align 8
  store i32 1, ptr %y_ptr145, align 4
  store ptr %48, ptr %arr_ptr146, align 8
  store ptr %63, ptr %mask_ptr147, align 8
  call void @print_bool_arr(ptr nonnull @res_11.7D0DF573.0, i64 15, ptr nonnull %out_arr_alloca143)
  ret void
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

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
