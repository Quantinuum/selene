; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-msvc"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_entangled_.CC58B637.0 = private constant [27 x i8] c"\1AUSER:STATE:entangled_state"
@res_c0.7C14CD6E.0 = private constant [13 x i8] c"\0CUSER:BOOL:c0"
@res_post_measu.3B49B396.0 = private constant [34 x i8] c"!USER:STATE:post_measurement_state"
@res_c1.1F7A6571.0 = private constant [13 x i8] c"\0CUSER:BOOL:c1"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.i, label %id_bb.i, label %reset_bb.i

reset_bb.i:                                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %alloca_block
  %0 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %1 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %0
  %.fca.0.extract.i = extractvalue { i1, i64 } %1, 0
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.36.exit, label %cond_40_case_0.i

cond_40_case_0.i:                                 ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.36.exit:                    ; preds = %id_bb.i
  %.fca.1.extract.i = extractvalue { i1, i64 } %1, 1
  tail call void @___rxy(i64 %.fca.1.extract.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0x400921FB54442D18)
  %qalloc.i126 = tail call i64 @___qalloc()
  %not_max.not.i127 = icmp eq i64 %qalloc.i126, -1
  br i1 %not_max.not.i127, label %id_bb.i130, label %reset_bb.i128

reset_bb.i128:                                    ; preds = %__hugr__.__tk2_qalloc.36.exit
  tail call void @___reset(i64 %qalloc.i126)
  br label %id_bb.i130

id_bb.i130:                                       ; preds = %reset_bb.i128, %__hugr__.__tk2_qalloc.36.exit
  %2 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i126, 1
  %3 = select i1 %not_max.not.i127, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %2
  %.fca.0.extract.i129 = extractvalue { i1, i64 } %3, 0
  br i1 %.fca.0.extract.i129, label %__hugr__.__tk2_qalloc.36.exit133, label %cond_40_case_0.i132

cond_40_case_0.i132:                              ; preds = %id_bb.i130
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.36.exit133:                 ; preds = %id_bb.i130
  %.fca.1.extract.i131 = extractvalue { i1, i64 } %3, 1
  tail call void @___rxy(i64 %.fca.1.extract.i131, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i, i64 %.fca.1.extract.i131, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i131, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i131, double 0xBFF921FB54442D18)
  %4 = tail call i8* @heap_alloc(i64 16)
  %5 = bitcast i8* %4 to i64*
  %6 = tail call i8* @heap_alloc(i64 8)
  %7 = bitcast i8* %6 to i64*
  store i64 0, i64* %7, align 1
  store i64 %.fca.1.extract.i, i64* %5, align 4
  %8 = getelementptr inbounds i8, i8* %4, i64 8
  %9 = bitcast i8* %8 to i64*
  store i64 %.fca.1.extract.i131, i64* %9, align 4
  %10 = load i64, i64* %7, align 4
  %11 = and i64 %10, 3
  store i64 %11, i64* %7, align 4
  %12 = icmp eq i64 %11, 0
  br i1 %12, label %__barray_mask_check_not_borrowed.exit136, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_qalloc.36.exit133
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_mask_check_not_borrowed.exit136:         ; preds = %__hugr__.__tk2_qalloc.36.exit133
  %out_arr_alloca = alloca <{ i32, i32, i64*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %13 = alloca [2 x i1], align 1
  %.sub = getelementptr inbounds [2 x i1], [2 x i1]* %13, i64 0, i64 0
  store i1 false, i1* %.sub, align 1
  %.repack125 = getelementptr inbounds [2 x i1], [2 x i1]* %13, i64 0, i64 1
  store i1 false, i1* %.repack125, align 1
  store i32 2, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %14 = bitcast i64** %arr_ptr to i8**
  store i8* %4, i8** %14, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_state_result(i8* getelementptr inbounds ([27 x i8], [27 x i8]* @res_entangled_.CC58B637.0, i64 0, i64 0), i64 26, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca)
  %15 = call i8* @heap_alloc(i64 8)
  %16 = bitcast i8* %15 to i64*
  store i64 0, i64* %16, align 1
  %17 = load i64, i64* %5, align 4
  %18 = load i64, i64* %9, align 4
  %19 = call i8* @heap_alloc(i64 8)
  %20 = bitcast i8* %19 to i64*
  %21 = call i8* @heap_alloc(i64 8)
  %22 = bitcast i8* %21 to i64*
  store i64 0, i64* %22, align 1
  store i64 %18, i64* %20, align 4
  %23 = load i64, i64* %22, align 4
  %24 = and i64 %23, 1
  store i64 %24, i64* %22, align 4
  %25 = icmp eq i64 %24, 0
  br i1 %25, label %__barray_mask_check_not_borrowed.exit141, label %mask_block_err.i137

mask_block_err.i137:                              ; preds = %__barray_mask_check_not_borrowed.exit136
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_mask_check_not_borrowed.exit141:         ; preds = %__barray_mask_check_not_borrowed.exit136
  %lazy_measure = call i64 @___lazy_measure(i64 %17)
  call void @___qfree(i64 %17)
  %read_bool = call i1 @___read_future_bool(i64 %lazy_measure)
  call void @___dec_future_refcount(i64 %lazy_measure)
  call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_c0.7C14CD6E.0, i64 0, i64 0), i64 12, i1 %read_bool)
  %out_arr_alloca46 = alloca <{ i32, i32, i64*, i1* }>, align 8
  %x_ptr47 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca46, i64 0, i32 0
  %y_ptr48 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca46, i64 0, i32 1
  %arr_ptr49 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca46, i64 0, i32 2
  %mask_ptr50 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca46, i64 0, i32 3
  %26 = alloca i1, align 1
  store i1 false, i1* %26, align 1
  store i32 1, i32* %x_ptr47, align 8
  store i32 1, i32* %y_ptr48, align 4
  %27 = bitcast i64** %arr_ptr49 to i8**
  store i8* %19, i8** %27, align 8
  store i1* %26, i1** %mask_ptr50, align 8
  call void @print_state_result(i8* getelementptr inbounds ([34 x i8], [34 x i8]* @res_post_measu.3B49B396.0, i64 0, i64 0), i64 33, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca46)
  %28 = call i8* @heap_alloc(i64 8)
  %29 = bitcast i8* %28 to i64*
  store i64 0, i64* %29, align 1
  %30 = load i64, i64* %20, align 4
  %lazy_measure61 = call i64 @___lazy_measure(i64 %30)
  call void @___qfree(i64 %30)
  %read_bool74 = call i1 @___read_future_bool(i64 %lazy_measure61)
  call void @___dec_future_refcount(i64 %lazy_measure61)
  call void @print_bool(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @res_c1.1F7A6571.0, i64 0, i64 0), i64 12, i1 %read_bool74)
  ret void
}

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare void @print_state_result(i8*, i64, <{ i32, i32, i64*, i1* }>*) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool(i8*, i64, i1) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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
