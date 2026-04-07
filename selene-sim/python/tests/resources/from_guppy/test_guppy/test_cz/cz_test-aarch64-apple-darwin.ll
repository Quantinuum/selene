; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-apple-darwin"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_c.19197FA6.0 = private constant [15 x i8] c"\0EUSER:BOOLARR:c"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

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
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.51.exit, label %cond_55_case_0.i

cond_55_case_0.i:                                 ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.51.exit:                    ; preds = %id_bb.i
  %.fca.1.extract.i = extractvalue { i1, i64 } %1, 1
  %qalloc.i180 = tail call i64 @___qalloc()
  %not_max.not.i181 = icmp eq i64 %qalloc.i180, -1
  br i1 %not_max.not.i181, label %id_bb.i184, label %reset_bb.i182

reset_bb.i182:                                    ; preds = %__hugr__.__tk2_qalloc.51.exit
  tail call void @___reset(i64 %qalloc.i180)
  br label %id_bb.i184

id_bb.i184:                                       ; preds = %reset_bb.i182, %__hugr__.__tk2_qalloc.51.exit
  %2 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i180, 1
  %3 = select i1 %not_max.not.i181, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %2
  %.fca.0.extract.i183 = extractvalue { i1, i64 } %3, 0
  br i1 %.fca.0.extract.i183, label %__hugr__.__tk2_qalloc.51.exit187, label %cond_55_case_0.i186

cond_55_case_0.i186:                              ; preds = %id_bb.i184
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.51.exit187:                 ; preds = %id_bb.i184
  %.fca.1.extract.i185 = extractvalue { i1, i64 } %3, 1
  tail call void @___rxy(i64 %.fca.1.extract.i, double 0x40316444CB580C0B, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i, i64 %.fca.1.extract.i185, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i185, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i, double 0x40316444CB580C0B, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i, i64 %.fca.1.extract.i185, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i185, double 0xBFF921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i)
  tail call void @___qfree(i64 %.fca.1.extract.i)
  %lazy_measure14 = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i185)
  tail call void @___qfree(i64 %.fca.1.extract.i185)
  %"16_017.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure, 1
  %"17_018.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure14, 1
  %4 = tail call i8* @heap_alloc(i64 48)
  %5 = bitcast i8* %4 to { i1, i64, i1 }*
  %6 = tail call i8* @heap_alloc(i64 8)
  %7 = bitcast i8* %6 to i64*
  store i64 0, i64* %7, align 1
  store { i1, i64, i1 } %"16_017.fca.1.insert", { i1, i64, i1 }* %5, align 4
  %8 = getelementptr inbounds i8, i8* %4, i64 24
  %9 = bitcast i8* %8 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"17_018.fca.1.insert", { i1, i64, i1 }* %9, align 4
  %10 = tail call i8* @heap_alloc(i64 64)
  %11 = tail call i8* @heap_alloc(i64 8)
  %12 = bitcast i8* %11 to i64*
  store i64 0, i64* %12, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(64) %10, i8 0, i64 64, i1 false)
  %13 = load i64, i64* %7, align 4
  %14 = and i64 %13, 3
  store i64 %14, i64* %7, align 4
  %15 = icmp eq i64 %14, 0
  br i1 %15, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %__hugr__.__tk2_qalloc.51.exit187
  %16 = tail call i8* @heap_alloc(i64 48)
  %17 = bitcast i8* %16 to { i1, i64, i1 }*
  %18 = tail call i8* @heap_alloc(i64 8)
  %19 = bitcast i8* %18 to i64*
  store i64 0, i64* %19, align 1
  %20 = bitcast i8* %10 to { i1, { i1, i64, i1 } }*
  %21 = load { i1, i64, i1 }, { i1, i64, i1 }* %5, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %21, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %21, 1
  br i1 %.fca.0.extract118.i, label %cond_178_case_1.i, label %23

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_qalloc.51.exit187
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_178_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %22 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %23

23:                                               ; preds = %__barray_check_none_borrowed.exit, %cond_178_case_1.i
  %.pn.i = phi { i1, i64, i1 } [ %22, %cond_178_case_1.i ], [ %21, %__barray_check_none_borrowed.exit ]
  %24 = load i64, i64* %12, align 4
  %25 = and i64 %24, 1
  %.not.i.i = icmp eq i64 %25, 0
  br i1 %.not.i.i, label %cond_181_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %33, %23
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_181_case_1.i:                                ; preds = %23
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %21, i1 %"04.sroa.6.0.i", 2
  %26 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %27 = bitcast i8* %10 to i1*
  %28 = load i1, i1* %27, align 1
  store { i1, { i1, i64, i1 } } %26, { i1, { i1, i64, i1 } }* %20, align 4
  br i1 %28, label %cond_182_case_1.i, label %__hugr__.const_fun_113.110.exit

cond_182_case_1.i:                                ; preds = %cond_181_case_1.i.1, %cond_181_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_113.110.exit:                  ; preds = %cond_181_case_1.i
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %17, align 4
  %29 = getelementptr inbounds i8, i8* %4, i64 24
  %30 = bitcast i8* %29 to { i1, i64, i1 }*
  %31 = load { i1, i64, i1 }, { i1, i64, i1 }* %30, align 4
  %.fca.0.extract118.i.1 = extractvalue { i1, i64, i1 } %31, 0
  %.fca.1.extract119.i.1 = extractvalue { i1, i64, i1 } %31, 1
  br i1 %.fca.0.extract118.i.1, label %cond_178_case_1.i.1, label %33

cond_178_case_1.i.1:                              ; preds = %__hugr__.const_fun_113.110.exit
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i.1)
  %32 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i.1, 1
  br label %33

33:                                               ; preds = %__hugr__.const_fun_113.110.exit, %cond_178_case_1.i.1
  %.pn.i.1 = phi { i1, i64, i1 } [ %32, %cond_178_case_1.i.1 ], [ %31, %__hugr__.const_fun_113.110.exit ]
  %34 = load i64, i64* %12, align 4
  %35 = and i64 %34, 2
  %.not.i.i.1 = icmp eq i64 %35, 0
  br i1 %.not.i.i.1, label %cond_181_case_1.i.1, label %panic.i.i

cond_181_case_1.i.1:                              ; preds = %33
  %"04.sroa.6.0.i.1" = extractvalue { i1, i64, i1 } %.pn.i.1, 2
  %"17.fca.2.insert.i.1" = insertvalue { i1, i64, i1 } %31, i1 %"04.sroa.6.0.i.1", 2
  %36 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i.1", 1
  %37 = getelementptr inbounds i8, i8* %10, i64 32
  %38 = bitcast i8* %37 to { i1, { i1, i64, i1 } }*
  %39 = bitcast i8* %37 to i1*
  %40 = load i1, i1* %39, align 1
  store { i1, { i1, i64, i1 } } %36, { i1, { i1, i64, i1 } }* %38, align 4
  br i1 %40, label %cond_182_case_1.i, label %mask_block_ok.i190

mask_block_ok.i190:                               ; preds = %cond_181_case_1.i.1
  %41 = getelementptr inbounds i8, i8* %16, i64 24
  %42 = bitcast i8* %41 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"17.fca.2.insert.i.1", { i1, i64, i1 }* %42, align 4
  tail call void @heap_free(i8* nonnull %4)
  tail call void @heap_free(i8* nonnull %6)
  %43 = load i64, i64* %12, align 4
  %44 = and i64 %43, 3
  store i64 %44, i64* %12, align 4
  %45 = icmp eq i64 %44, 0
  br i1 %45, label %__barray_check_none_borrowed.exit192, label %mask_block_err.i191

mask_block_err.i191:                              ; preds = %mask_block_ok.i190
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit192:             ; preds = %mask_block_ok.i190
  %46 = tail call i8* @heap_alloc(i64 48)
  %47 = bitcast i8* %46 to { i1, i64, i1 }*
  %48 = tail call i8* @heap_alloc(i64 8)
  %49 = bitcast i8* %48 to i64*
  store i64 0, i64* %49, align 1
  %50 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %20, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %50, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_118.113.exit, label %cond_223_case_0.i

cond_223_case_0.i:                                ; preds = %__hugr__.const_fun_118.113.exit, %__barray_check_none_borrowed.exit192
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_118.113.exit:                  ; preds = %__barray_check_none_borrowed.exit192
  %51 = extractvalue { i1, { i1, i64, i1 } } %50, 1
  store { i1, i64, i1 } %51, { i1, i64, i1 }* %47, align 4
  %52 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %38, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %52, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_118.113.exit.1, label %cond_223_case_0.i

__hugr__.const_fun_118.113.exit.1:                ; preds = %__hugr__.const_fun_118.113.exit
  %53 = extractvalue { i1, { i1, i64, i1 } } %52, 1
  %54 = getelementptr inbounds i8, i8* %46, i64 24
  %55 = bitcast i8* %54 to { i1, i64, i1 }*
  store { i1, i64, i1 } %53, { i1, i64, i1 }* %55, align 4
  tail call void @heap_free(i8* nonnull %10)
  tail call void @heap_free(i8* nonnull %11)
  %56 = load i64, i64* %49, align 4
  %57 = and i64 %56, 1
  %.not = icmp eq i64 %57, 0
  br i1 %.not, label %__barray_mask_borrow.exit, label %cond_exit_137

mask_block_err.i196:                              ; preds = %cond_exit_137.1
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit:                        ; preds = %__hugr__.const_fun_118.113.exit.1
  %58 = xor i64 %56, 1
  store i64 %58, i64* %49, align 4
  %59 = load { i1, i64, i1 }, { i1, i64, i1 }* %47, align 4
  %.fca.0.extract112 = extractvalue { i1, i64, i1 } %59, 0
  br i1 %.fca.0.extract112, label %cond_160_case_1, label %cond_exit_137

cond_exit_137:                                    ; preds = %cond_160_case_1, %__barray_mask_borrow.exit, %__hugr__.const_fun_118.113.exit.1
  %60 = load i64, i64* %49, align 4
  %61 = and i64 %60, 2
  %.not.1 = icmp eq i64 %61, 0
  br i1 %.not.1, label %__barray_mask_borrow.exit.1, label %cond_exit_137.1

__barray_mask_borrow.exit.1:                      ; preds = %cond_exit_137
  %62 = xor i64 %60, 2
  store i64 %62, i64* %49, align 4
  %63 = getelementptr inbounds i8, i8* %46, i64 24
  %64 = bitcast i8* %63 to { i1, i64, i1 }*
  %65 = load { i1, i64, i1 }, { i1, i64, i1 }* %64, align 4
  %.fca.0.extract112.1 = extractvalue { i1, i64, i1 } %65, 0
  br i1 %.fca.0.extract112.1, label %cond_160_case_1.1, label %cond_exit_137.1

cond_160_case_1.1:                                ; preds = %__barray_mask_borrow.exit.1
  %.fca.1.extract113.1 = extractvalue { i1, i64, i1 } %65, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract113.1)
  br label %cond_exit_137.1

cond_exit_137.1:                                  ; preds = %cond_160_case_1.1, %__barray_mask_borrow.exit.1, %cond_exit_137
  %66 = load i64, i64* %49, align 4
  %67 = or i64 %66, -4
  store i64 %67, i64* %49, align 4
  %68 = icmp eq i64 %67, -1
  br i1 %68, label %loop_out, label %mask_block_err.i196

loop_out:                                         ; preds = %cond_exit_137.1
  tail call void @heap_free(i8* %46)
  tail call void @heap_free(i8* nonnull %48)
  %69 = load i64, i64* %19, align 4
  %70 = and i64 %69, 3
  store i64 %70, i64* %19, align 4
  %71 = icmp eq i64 %70, 0
  br i1 %71, label %__barray_check_none_borrowed.exit202, label %mask_block_err.i201

__barray_check_none_borrowed.exit202:             ; preds = %loop_out
  %72 = tail call i8* @heap_alloc(i64 2)
  %73 = tail call i8* @heap_alloc(i64 8)
  %74 = bitcast i8* %73 to i64*
  store i64 0, i64* %74, align 1
  %75 = load { i1, i64, i1 }, { i1, i64, i1 }* %17, align 4
  %.fca.0.extract.i203 = extractvalue { i1, i64, i1 } %75, 0
  %.fca.1.extract.i204 = extractvalue { i1, i64, i1 } %75, 1
  br i1 %.fca.0.extract.i203, label %cond_90_case_1.i, label %cond_90_case_0.i

mask_block_err.i201:                              ; preds = %loop_out
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_160_case_1:                                  ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract113 = extractvalue { i1, i64, i1 } %59, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract113)
  br label %cond_exit_137

cond_90_case_0.i:                                 ; preds = %__barray_check_none_borrowed.exit202
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %75, 2
  br label %__hugr__.array.__read_bool.3.46.exit

cond_90_case_1.i:                                 ; preds = %__barray_check_none_borrowed.exit202
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i204)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i204)
  br label %__hugr__.array.__read_bool.3.46.exit

__hugr__.array.__read_bool.3.46.exit:             ; preds = %cond_90_case_0.i, %cond_90_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_90_case_1.i ], [ %.fca.2.extract.i, %cond_90_case_0.i ]
  %76 = bitcast i8* %72 to i1*
  store i1 %"03.0.i", i1* %76, align 1
  %77 = load { i1, i64, i1 }, { i1, i64, i1 }* %42, align 4
  %.fca.0.extract.i203.1 = extractvalue { i1, i64, i1 } %77, 0
  %.fca.1.extract.i204.1 = extractvalue { i1, i64, i1 } %77, 1
  br i1 %.fca.0.extract.i203.1, label %cond_90_case_1.i.1, label %cond_90_case_0.i.1

cond_90_case_0.i.1:                               ; preds = %__hugr__.array.__read_bool.3.46.exit
  %.fca.2.extract.i.1 = extractvalue { i1, i64, i1 } %77, 2
  br label %__hugr__.array.__read_bool.3.46.exit.1

cond_90_case_1.i.1:                               ; preds = %__hugr__.array.__read_bool.3.46.exit
  %read_bool.i.1 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i204.1)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i204.1)
  br label %__hugr__.array.__read_bool.3.46.exit.1

__hugr__.array.__read_bool.3.46.exit.1:           ; preds = %cond_90_case_1.i.1, %cond_90_case_0.i.1
  %"03.0.i.1" = phi i1 [ %read_bool.i.1, %cond_90_case_1.i.1 ], [ %.fca.2.extract.i.1, %cond_90_case_0.i.1 ]
  %78 = getelementptr inbounds i8, i8* %72, i64 1
  %79 = bitcast i8* %78 to i1*
  store i1 %"03.0.i.1", i1* %79, align 1
  tail call void @heap_free(i8* nonnull %16)
  tail call void @heap_free(i8* nonnull %18)
  %80 = load i64, i64* %74, align 4
  %81 = and i64 %80, 3
  store i64 %81, i64* %74, align 4
  %82 = icmp eq i64 %81, 0
  br i1 %82, label %__barray_check_none_borrowed.exit209, label %mask_block_err.i208

__barray_check_none_borrowed.exit209:             ; preds = %__hugr__.array.__read_bool.3.46.exit.1
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %83 = alloca [2 x i1], align 1
  %.sub = getelementptr inbounds [2 x i1], [2 x i1]* %83, i64 0, i64 0
  store i1 false, i1* %.sub, align 1
  %.repack165 = getelementptr inbounds [2 x i1], [2 x i1]* %83, i64 0, i64 1
  store i1 false, i1* %.repack165, align 1
  store i32 2, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %84 = bitcast i1** %arr_ptr to i8**
  store i8* %72, i8** %84, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([15 x i8], [15 x i8]* @res_c.19197FA6.0, i64 0, i64 0), i64 14, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  ret void

mask_block_err.i208:                              ; preds = %__hugr__.array.__read_bool.3.46.exit.1
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare void @heap_free(i8*) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool_arr(i8*, i64, <{ i32, i32, i1*, i1* }>*) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @__hugr__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #1

attributes #0 = { noreturn }
attributes #1 = { argmemonly nofree nounwind willreturn writeonly }

!name = !{!0}

!0 = !{!"mainlib"}
