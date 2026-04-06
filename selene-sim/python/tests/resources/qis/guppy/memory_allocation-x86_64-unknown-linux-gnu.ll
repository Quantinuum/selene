; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define private fastcc void @__hugr__.__main__.memory_allocation.1() unnamed_addr {
alloca_block:
  %0 = tail call i8* @heap_alloc(i64 560)
  %1 = bitcast i8* %0 to i64*
  %2 = tail call i8* @heap_alloc(i64 16)
  %3 = bitcast i8* %2 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %3, i8 -1, i64 16, i1 false)
  br label %cond_20_case_1

loop_out:                                         ; preds = %finish, %__barray_mask_return.exit738
  %exitcond767.not = icmp eq i64 %549, 70
  br i1 %exitcond767.not, label %cond_exit_84, label %finish

cond_20_case_1:                                   ; preds = %alloca_block, %cond_exit_20
  %"15_0.sroa.0.0752" = phi i64 [ 0, %alloca_block ], [ %4, %cond_exit_20 ]
  %4 = add nuw nsw i64 %"15_0.sroa.0.0752", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.i, label %id_bb.i, label %reset_bb.i

reset_bb.i:                                       ; preds = %cond_20_case_1
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %cond_20_case_1
  %5 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %6 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %5
  %.fca.0.extract.i = extractvalue { i1, i64 } %6, 0
  br i1 %.fca.0.extract.i, label %__barray_check_bounds.exit, label %cond_327_case_0.i

cond_327_case_0.i:                                ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit:                       ; preds = %id_bb.i
  %7 = lshr i64 %"15_0.sroa.0.0752", 6
  %8 = getelementptr inbounds i64, i64* %3, i64 %7
  %9 = load i64, i64* %8, align 4
  %10 = and i64 %"15_0.sroa.0.0752", 63
  %11 = shl nuw i64 1, %10
  %12 = and i64 %9, %11
  %.not.i = icmp eq i64 %12, 0
  br i1 %.not.i, label %panic.i, label %cond_exit_20

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_20:                                     ; preds = %__barray_check_bounds.exit
  %.fca.1.extract.i = extractvalue { i1, i64 } %6, 1
  %13 = xor i64 %9, %11
  store i64 %13, i64* %8, align 4
  %14 = getelementptr inbounds i64, i64* %1, i64 %"15_0.sroa.0.0752"
  store i64 %.fca.1.extract.i, i64* %14, align 4
  %exitcond.not = icmp eq i64 %4, 70
  br i1 %exitcond.not, label %finish, label %cond_20_case_1

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit"
  %15 = tail call i8* @heap_alloc(i64 1680)
  %16 = bitcast i8* %15 to { i1, i64, i1 }*
  %17 = tail call i8* @heap_alloc(i64 16)
  %18 = bitcast i8* %17 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %18, i8 0, i64 16, i1 false)
  %19 = bitcast i8* %523 to { i1, { i1, i64, i1 } }*
  br label %20

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

20:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_304.307.exit
  %storemerge680760 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %39, %__hugr__.const_fun_304.307.exit ]
  %21 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %37, %__hugr__.const_fun_304.307.exit ]
  %22 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %513, i64 %storemerge680760
  %23 = load { i1, i64, i1 }, { i1, i64, i1 }* %22, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %23, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %23, 1
  br i1 %.fca.0.extract118.i, label %cond_546_case_1.i, label %cond_exit_546.i

cond_546_case_1.i:                                ; preds = %20
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %24 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %cond_exit_546.i

cond_exit_546.i:                                  ; preds = %cond_546_case_1.i, %20
  %.pn.i = phi { i1, i64, i1 } [ %24, %cond_546_case_1.i ], [ %23, %20 ]
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %25 = icmp ult i64 %21, 70
  br i1 %25, label %26, label %cond_549_case_0.i

26:                                               ; preds = %cond_exit_546.i
  %27 = lshr i64 %21, 6
  %28 = getelementptr inbounds i64, i64* %525, i64 %27
  %29 = load i64, i64* %28, align 4
  %30 = and i64 %21, 63
  %31 = shl nuw i64 1, %30
  %32 = and i64 %29, %31
  %.not.i.i = icmp eq i64 %32, 0
  br i1 %.not.i.i, label %cond_549_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %26
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_549_case_0.i:                                ; preds = %cond_exit_546.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_549_case_1.i:                                ; preds = %26
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %23, i1 %"04.sroa.6.0.i", 2
  %33 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %34 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %19, i64 %21
  %35 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %34, i64 0, i32 0
  %36 = load i1, i1* %35, align 1
  store { i1, { i1, i64, i1 } } %33, { i1, { i1, i64, i1 } }* %34, align 4
  br i1 %36, label %cond_550_case_1.i, label %__hugr__.const_fun_304.307.exit

cond_550_case_1.i:                                ; preds = %cond_549_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_304.307.exit:                  ; preds = %cond_549_case_1.i
  %37 = add nuw nsw i64 %21, 1
  %38 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %16, i64 %storemerge680760
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %38, align 4
  %39 = add nuw nsw i64 %storemerge680760, 1
  %exitcond769.not = icmp eq i64 %39, 70
  br i1 %exitcond769.not, label %mask_block_ok.i701.preheader, label %20

mask_block_ok.i701.preheader:                     ; preds = %__hugr__.const_fun_304.307.exit
  tail call void @heap_free(i8* nonnull %512)
  tail call void @heap_free(i8* %514)
  %40 = load i64, i64* %525, align 4
  %41 = getelementptr inbounds i8, i8* %524, i64 8
  %42 = bitcast i8* %41 to i64*
  %43 = load i64, i64* %42, align 4
  %44 = and i64 %43, 63
  store i64 %44, i64* %42, align 4
  %45 = icmp eq i64 %40, 0
  br i1 %45, label %.mask_block_ok.i701_crit_edge, label %mask_block_err.i702

.mask_block_ok.i701_crit_edge:                    ; preds = %mask_block_ok.i701.preheader
  %.phi.trans.insert = getelementptr inbounds i8, i8* %524, i64 8
  %46 = bitcast i8* %.phi.trans.insert to i64*
  %.pre = load i64, i64* %46, align 4
  %47 = icmp eq i64 %.pre, 0
  br i1 %47, label %__barray_check_none_borrowed.exit703, label %mask_block_err.i702

mask_block_err.i702:                              ; preds = %.mask_block_ok.i701_crit_edge, %mask_block_ok.i701.preheader
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit703:             ; preds = %.mask_block_ok.i701_crit_edge
  %48 = tail call i8* @heap_alloc(i64 1680)
  %49 = bitcast i8* %48 to { i1, i64, i1 }*
  %50 = tail call i8* @heap_alloc(i64 16)
  %51 = bitcast i8* %50 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %51, i8 0, i64 16, i1 false)
  %52 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %19, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %52, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_300.304.exit, label %cond_591_case_0.i

cond_591_case_0.i:                                ; preds = %__hugr__.const_fun_300.304.exit.68, %__hugr__.const_fun_300.304.exit.67, %__hugr__.const_fun_300.304.exit.66, %__hugr__.const_fun_300.304.exit.65, %__hugr__.const_fun_300.304.exit.64, %__hugr__.const_fun_300.304.exit.63, %__hugr__.const_fun_300.304.exit.62, %__hugr__.const_fun_300.304.exit.61, %__hugr__.const_fun_300.304.exit.60, %__hugr__.const_fun_300.304.exit.59, %__hugr__.const_fun_300.304.exit.58, %__hugr__.const_fun_300.304.exit.57, %__hugr__.const_fun_300.304.exit.56, %__hugr__.const_fun_300.304.exit.55, %__hugr__.const_fun_300.304.exit.54, %__hugr__.const_fun_300.304.exit.53, %__hugr__.const_fun_300.304.exit.52, %__hugr__.const_fun_300.304.exit.51, %__hugr__.const_fun_300.304.exit.50, %__hugr__.const_fun_300.304.exit.49, %__hugr__.const_fun_300.304.exit.48, %__hugr__.const_fun_300.304.exit.47, %__hugr__.const_fun_300.304.exit.46, %__hugr__.const_fun_300.304.exit.45, %__hugr__.const_fun_300.304.exit.44, %__hugr__.const_fun_300.304.exit.43, %__hugr__.const_fun_300.304.exit.42, %__hugr__.const_fun_300.304.exit.41, %__hugr__.const_fun_300.304.exit.40, %__hugr__.const_fun_300.304.exit.39, %__hugr__.const_fun_300.304.exit.38, %__hugr__.const_fun_300.304.exit.37, %__hugr__.const_fun_300.304.exit.36, %__hugr__.const_fun_300.304.exit.35, %__hugr__.const_fun_300.304.exit.34, %__hugr__.const_fun_300.304.exit.33, %__hugr__.const_fun_300.304.exit.32, %__hugr__.const_fun_300.304.exit.31, %__hugr__.const_fun_300.304.exit.30, %__hugr__.const_fun_300.304.exit.29, %__hugr__.const_fun_300.304.exit.28, %__hugr__.const_fun_300.304.exit.27, %__hugr__.const_fun_300.304.exit.26, %__hugr__.const_fun_300.304.exit.25, %__hugr__.const_fun_300.304.exit.24, %__hugr__.const_fun_300.304.exit.23, %__hugr__.const_fun_300.304.exit.22, %__hugr__.const_fun_300.304.exit.21, %__hugr__.const_fun_300.304.exit.20, %__hugr__.const_fun_300.304.exit.19, %__hugr__.const_fun_300.304.exit.18, %__hugr__.const_fun_300.304.exit.17, %__hugr__.const_fun_300.304.exit.16, %__hugr__.const_fun_300.304.exit.15, %__hugr__.const_fun_300.304.exit.14, %__hugr__.const_fun_300.304.exit.13, %__hugr__.const_fun_300.304.exit.12, %__hugr__.const_fun_300.304.exit.11, %__hugr__.const_fun_300.304.exit.10, %__hugr__.const_fun_300.304.exit.9, %__hugr__.const_fun_300.304.exit.8, %__hugr__.const_fun_300.304.exit.7, %__hugr__.const_fun_300.304.exit.6, %__hugr__.const_fun_300.304.exit.5, %__hugr__.const_fun_300.304.exit.4, %__hugr__.const_fun_300.304.exit.3, %__hugr__.const_fun_300.304.exit.2, %__hugr__.const_fun_300.304.exit.1, %__hugr__.const_fun_300.304.exit, %__barray_check_none_borrowed.exit703
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_300.304.exit:                  ; preds = %__barray_check_none_borrowed.exit703
  %53 = extractvalue { i1, { i1, i64, i1 } } %52, 1
  store { i1, i64, i1 } %53, { i1, i64, i1 }* %49, align 4
  %54 = getelementptr inbounds i8, i8* %523, i64 32
  %55 = bitcast i8* %54 to { i1, { i1, i64, i1 } }*
  %56 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %55, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %56, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_300.304.exit.1, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.1:                ; preds = %__hugr__.const_fun_300.304.exit
  %57 = extractvalue { i1, { i1, i64, i1 } } %56, 1
  %58 = getelementptr inbounds i8, i8* %48, i64 24
  %59 = bitcast i8* %58 to { i1, i64, i1 }*
  store { i1, i64, i1 } %57, { i1, i64, i1 }* %59, align 4
  %60 = getelementptr inbounds i8, i8* %523, i64 64
  %61 = bitcast i8* %60 to { i1, { i1, i64, i1 } }*
  %62 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %61, align 4
  %.fca.0.extract11.i.2 = extractvalue { i1, { i1, i64, i1 } } %62, 0
  br i1 %.fca.0.extract11.i.2, label %__hugr__.const_fun_300.304.exit.2, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.2:                ; preds = %__hugr__.const_fun_300.304.exit.1
  %63 = extractvalue { i1, { i1, i64, i1 } } %62, 1
  %64 = getelementptr inbounds i8, i8* %48, i64 48
  %65 = bitcast i8* %64 to { i1, i64, i1 }*
  store { i1, i64, i1 } %63, { i1, i64, i1 }* %65, align 4
  %66 = getelementptr inbounds i8, i8* %523, i64 96
  %67 = bitcast i8* %66 to { i1, { i1, i64, i1 } }*
  %68 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %67, align 4
  %.fca.0.extract11.i.3 = extractvalue { i1, { i1, i64, i1 } } %68, 0
  br i1 %.fca.0.extract11.i.3, label %__hugr__.const_fun_300.304.exit.3, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.3:                ; preds = %__hugr__.const_fun_300.304.exit.2
  %69 = extractvalue { i1, { i1, i64, i1 } } %68, 1
  %70 = getelementptr inbounds i8, i8* %48, i64 72
  %71 = bitcast i8* %70 to { i1, i64, i1 }*
  store { i1, i64, i1 } %69, { i1, i64, i1 }* %71, align 4
  %72 = getelementptr inbounds i8, i8* %523, i64 128
  %73 = bitcast i8* %72 to { i1, { i1, i64, i1 } }*
  %74 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %73, align 4
  %.fca.0.extract11.i.4 = extractvalue { i1, { i1, i64, i1 } } %74, 0
  br i1 %.fca.0.extract11.i.4, label %__hugr__.const_fun_300.304.exit.4, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.4:                ; preds = %__hugr__.const_fun_300.304.exit.3
  %75 = extractvalue { i1, { i1, i64, i1 } } %74, 1
  %76 = getelementptr inbounds i8, i8* %48, i64 96
  %77 = bitcast i8* %76 to { i1, i64, i1 }*
  store { i1, i64, i1 } %75, { i1, i64, i1 }* %77, align 4
  %78 = getelementptr inbounds i8, i8* %523, i64 160
  %79 = bitcast i8* %78 to { i1, { i1, i64, i1 } }*
  %80 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %79, align 4
  %.fca.0.extract11.i.5 = extractvalue { i1, { i1, i64, i1 } } %80, 0
  br i1 %.fca.0.extract11.i.5, label %__hugr__.const_fun_300.304.exit.5, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.5:                ; preds = %__hugr__.const_fun_300.304.exit.4
  %81 = extractvalue { i1, { i1, i64, i1 } } %80, 1
  %82 = getelementptr inbounds i8, i8* %48, i64 120
  %83 = bitcast i8* %82 to { i1, i64, i1 }*
  store { i1, i64, i1 } %81, { i1, i64, i1 }* %83, align 4
  %84 = getelementptr inbounds i8, i8* %523, i64 192
  %85 = bitcast i8* %84 to { i1, { i1, i64, i1 } }*
  %86 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %85, align 4
  %.fca.0.extract11.i.6 = extractvalue { i1, { i1, i64, i1 } } %86, 0
  br i1 %.fca.0.extract11.i.6, label %__hugr__.const_fun_300.304.exit.6, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.6:                ; preds = %__hugr__.const_fun_300.304.exit.5
  %87 = extractvalue { i1, { i1, i64, i1 } } %86, 1
  %88 = getelementptr inbounds i8, i8* %48, i64 144
  %89 = bitcast i8* %88 to { i1, i64, i1 }*
  store { i1, i64, i1 } %87, { i1, i64, i1 }* %89, align 4
  %90 = getelementptr inbounds i8, i8* %523, i64 224
  %91 = bitcast i8* %90 to { i1, { i1, i64, i1 } }*
  %92 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %91, align 4
  %.fca.0.extract11.i.7 = extractvalue { i1, { i1, i64, i1 } } %92, 0
  br i1 %.fca.0.extract11.i.7, label %__hugr__.const_fun_300.304.exit.7, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.7:                ; preds = %__hugr__.const_fun_300.304.exit.6
  %93 = extractvalue { i1, { i1, i64, i1 } } %92, 1
  %94 = getelementptr inbounds i8, i8* %48, i64 168
  %95 = bitcast i8* %94 to { i1, i64, i1 }*
  store { i1, i64, i1 } %93, { i1, i64, i1 }* %95, align 4
  %96 = getelementptr inbounds i8, i8* %523, i64 256
  %97 = bitcast i8* %96 to { i1, { i1, i64, i1 } }*
  %98 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %97, align 4
  %.fca.0.extract11.i.8 = extractvalue { i1, { i1, i64, i1 } } %98, 0
  br i1 %.fca.0.extract11.i.8, label %__hugr__.const_fun_300.304.exit.8, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.8:                ; preds = %__hugr__.const_fun_300.304.exit.7
  %99 = extractvalue { i1, { i1, i64, i1 } } %98, 1
  %100 = getelementptr inbounds i8, i8* %48, i64 192
  %101 = bitcast i8* %100 to { i1, i64, i1 }*
  store { i1, i64, i1 } %99, { i1, i64, i1 }* %101, align 4
  %102 = getelementptr inbounds i8, i8* %523, i64 288
  %103 = bitcast i8* %102 to { i1, { i1, i64, i1 } }*
  %104 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %103, align 4
  %.fca.0.extract11.i.9 = extractvalue { i1, { i1, i64, i1 } } %104, 0
  br i1 %.fca.0.extract11.i.9, label %__hugr__.const_fun_300.304.exit.9, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.9:                ; preds = %__hugr__.const_fun_300.304.exit.8
  %105 = extractvalue { i1, { i1, i64, i1 } } %104, 1
  %106 = getelementptr inbounds i8, i8* %48, i64 216
  %107 = bitcast i8* %106 to { i1, i64, i1 }*
  store { i1, i64, i1 } %105, { i1, i64, i1 }* %107, align 4
  %108 = getelementptr inbounds i8, i8* %523, i64 320
  %109 = bitcast i8* %108 to { i1, { i1, i64, i1 } }*
  %110 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %109, align 4
  %.fca.0.extract11.i.10 = extractvalue { i1, { i1, i64, i1 } } %110, 0
  br i1 %.fca.0.extract11.i.10, label %__hugr__.const_fun_300.304.exit.10, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.10:               ; preds = %__hugr__.const_fun_300.304.exit.9
  %111 = extractvalue { i1, { i1, i64, i1 } } %110, 1
  %112 = getelementptr inbounds i8, i8* %48, i64 240
  %113 = bitcast i8* %112 to { i1, i64, i1 }*
  store { i1, i64, i1 } %111, { i1, i64, i1 }* %113, align 4
  %114 = getelementptr inbounds i8, i8* %523, i64 352
  %115 = bitcast i8* %114 to { i1, { i1, i64, i1 } }*
  %116 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %115, align 4
  %.fca.0.extract11.i.11 = extractvalue { i1, { i1, i64, i1 } } %116, 0
  br i1 %.fca.0.extract11.i.11, label %__hugr__.const_fun_300.304.exit.11, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.11:               ; preds = %__hugr__.const_fun_300.304.exit.10
  %117 = extractvalue { i1, { i1, i64, i1 } } %116, 1
  %118 = getelementptr inbounds i8, i8* %48, i64 264
  %119 = bitcast i8* %118 to { i1, i64, i1 }*
  store { i1, i64, i1 } %117, { i1, i64, i1 }* %119, align 4
  %120 = getelementptr inbounds i8, i8* %523, i64 384
  %121 = bitcast i8* %120 to { i1, { i1, i64, i1 } }*
  %122 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %121, align 4
  %.fca.0.extract11.i.12 = extractvalue { i1, { i1, i64, i1 } } %122, 0
  br i1 %.fca.0.extract11.i.12, label %__hugr__.const_fun_300.304.exit.12, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.12:               ; preds = %__hugr__.const_fun_300.304.exit.11
  %123 = extractvalue { i1, { i1, i64, i1 } } %122, 1
  %124 = getelementptr inbounds i8, i8* %48, i64 288
  %125 = bitcast i8* %124 to { i1, i64, i1 }*
  store { i1, i64, i1 } %123, { i1, i64, i1 }* %125, align 4
  %126 = getelementptr inbounds i8, i8* %523, i64 416
  %127 = bitcast i8* %126 to { i1, { i1, i64, i1 } }*
  %128 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %127, align 4
  %.fca.0.extract11.i.13 = extractvalue { i1, { i1, i64, i1 } } %128, 0
  br i1 %.fca.0.extract11.i.13, label %__hugr__.const_fun_300.304.exit.13, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.13:               ; preds = %__hugr__.const_fun_300.304.exit.12
  %129 = extractvalue { i1, { i1, i64, i1 } } %128, 1
  %130 = getelementptr inbounds i8, i8* %48, i64 312
  %131 = bitcast i8* %130 to { i1, i64, i1 }*
  store { i1, i64, i1 } %129, { i1, i64, i1 }* %131, align 4
  %132 = getelementptr inbounds i8, i8* %523, i64 448
  %133 = bitcast i8* %132 to { i1, { i1, i64, i1 } }*
  %134 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %133, align 4
  %.fca.0.extract11.i.14 = extractvalue { i1, { i1, i64, i1 } } %134, 0
  br i1 %.fca.0.extract11.i.14, label %__hugr__.const_fun_300.304.exit.14, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.14:               ; preds = %__hugr__.const_fun_300.304.exit.13
  %135 = extractvalue { i1, { i1, i64, i1 } } %134, 1
  %136 = getelementptr inbounds i8, i8* %48, i64 336
  %137 = bitcast i8* %136 to { i1, i64, i1 }*
  store { i1, i64, i1 } %135, { i1, i64, i1 }* %137, align 4
  %138 = getelementptr inbounds i8, i8* %523, i64 480
  %139 = bitcast i8* %138 to { i1, { i1, i64, i1 } }*
  %140 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %139, align 4
  %.fca.0.extract11.i.15 = extractvalue { i1, { i1, i64, i1 } } %140, 0
  br i1 %.fca.0.extract11.i.15, label %__hugr__.const_fun_300.304.exit.15, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.15:               ; preds = %__hugr__.const_fun_300.304.exit.14
  %141 = extractvalue { i1, { i1, i64, i1 } } %140, 1
  %142 = getelementptr inbounds i8, i8* %48, i64 360
  %143 = bitcast i8* %142 to { i1, i64, i1 }*
  store { i1, i64, i1 } %141, { i1, i64, i1 }* %143, align 4
  %144 = getelementptr inbounds i8, i8* %523, i64 512
  %145 = bitcast i8* %144 to { i1, { i1, i64, i1 } }*
  %146 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %145, align 4
  %.fca.0.extract11.i.16 = extractvalue { i1, { i1, i64, i1 } } %146, 0
  br i1 %.fca.0.extract11.i.16, label %__hugr__.const_fun_300.304.exit.16, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.16:               ; preds = %__hugr__.const_fun_300.304.exit.15
  %147 = extractvalue { i1, { i1, i64, i1 } } %146, 1
  %148 = getelementptr inbounds i8, i8* %48, i64 384
  %149 = bitcast i8* %148 to { i1, i64, i1 }*
  store { i1, i64, i1 } %147, { i1, i64, i1 }* %149, align 4
  %150 = getelementptr inbounds i8, i8* %523, i64 544
  %151 = bitcast i8* %150 to { i1, { i1, i64, i1 } }*
  %152 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %151, align 4
  %.fca.0.extract11.i.17 = extractvalue { i1, { i1, i64, i1 } } %152, 0
  br i1 %.fca.0.extract11.i.17, label %__hugr__.const_fun_300.304.exit.17, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.17:               ; preds = %__hugr__.const_fun_300.304.exit.16
  %153 = extractvalue { i1, { i1, i64, i1 } } %152, 1
  %154 = getelementptr inbounds i8, i8* %48, i64 408
  %155 = bitcast i8* %154 to { i1, i64, i1 }*
  store { i1, i64, i1 } %153, { i1, i64, i1 }* %155, align 4
  %156 = getelementptr inbounds i8, i8* %523, i64 576
  %157 = bitcast i8* %156 to { i1, { i1, i64, i1 } }*
  %158 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %157, align 4
  %.fca.0.extract11.i.18 = extractvalue { i1, { i1, i64, i1 } } %158, 0
  br i1 %.fca.0.extract11.i.18, label %__hugr__.const_fun_300.304.exit.18, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.18:               ; preds = %__hugr__.const_fun_300.304.exit.17
  %159 = extractvalue { i1, { i1, i64, i1 } } %158, 1
  %160 = getelementptr inbounds i8, i8* %48, i64 432
  %161 = bitcast i8* %160 to { i1, i64, i1 }*
  store { i1, i64, i1 } %159, { i1, i64, i1 }* %161, align 4
  %162 = getelementptr inbounds i8, i8* %523, i64 608
  %163 = bitcast i8* %162 to { i1, { i1, i64, i1 } }*
  %164 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %163, align 4
  %.fca.0.extract11.i.19 = extractvalue { i1, { i1, i64, i1 } } %164, 0
  br i1 %.fca.0.extract11.i.19, label %__hugr__.const_fun_300.304.exit.19, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.19:               ; preds = %__hugr__.const_fun_300.304.exit.18
  %165 = extractvalue { i1, { i1, i64, i1 } } %164, 1
  %166 = getelementptr inbounds i8, i8* %48, i64 456
  %167 = bitcast i8* %166 to { i1, i64, i1 }*
  store { i1, i64, i1 } %165, { i1, i64, i1 }* %167, align 4
  %168 = getelementptr inbounds i8, i8* %523, i64 640
  %169 = bitcast i8* %168 to { i1, { i1, i64, i1 } }*
  %170 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %169, align 4
  %.fca.0.extract11.i.20 = extractvalue { i1, { i1, i64, i1 } } %170, 0
  br i1 %.fca.0.extract11.i.20, label %__hugr__.const_fun_300.304.exit.20, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.20:               ; preds = %__hugr__.const_fun_300.304.exit.19
  %171 = extractvalue { i1, { i1, i64, i1 } } %170, 1
  %172 = getelementptr inbounds i8, i8* %48, i64 480
  %173 = bitcast i8* %172 to { i1, i64, i1 }*
  store { i1, i64, i1 } %171, { i1, i64, i1 }* %173, align 4
  %174 = getelementptr inbounds i8, i8* %523, i64 672
  %175 = bitcast i8* %174 to { i1, { i1, i64, i1 } }*
  %176 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %175, align 4
  %.fca.0.extract11.i.21 = extractvalue { i1, { i1, i64, i1 } } %176, 0
  br i1 %.fca.0.extract11.i.21, label %__hugr__.const_fun_300.304.exit.21, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.21:               ; preds = %__hugr__.const_fun_300.304.exit.20
  %177 = extractvalue { i1, { i1, i64, i1 } } %176, 1
  %178 = getelementptr inbounds i8, i8* %48, i64 504
  %179 = bitcast i8* %178 to { i1, i64, i1 }*
  store { i1, i64, i1 } %177, { i1, i64, i1 }* %179, align 4
  %180 = getelementptr inbounds i8, i8* %523, i64 704
  %181 = bitcast i8* %180 to { i1, { i1, i64, i1 } }*
  %182 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %181, align 4
  %.fca.0.extract11.i.22 = extractvalue { i1, { i1, i64, i1 } } %182, 0
  br i1 %.fca.0.extract11.i.22, label %__hugr__.const_fun_300.304.exit.22, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.22:               ; preds = %__hugr__.const_fun_300.304.exit.21
  %183 = extractvalue { i1, { i1, i64, i1 } } %182, 1
  %184 = getelementptr inbounds i8, i8* %48, i64 528
  %185 = bitcast i8* %184 to { i1, i64, i1 }*
  store { i1, i64, i1 } %183, { i1, i64, i1 }* %185, align 4
  %186 = getelementptr inbounds i8, i8* %523, i64 736
  %187 = bitcast i8* %186 to { i1, { i1, i64, i1 } }*
  %188 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %187, align 4
  %.fca.0.extract11.i.23 = extractvalue { i1, { i1, i64, i1 } } %188, 0
  br i1 %.fca.0.extract11.i.23, label %__hugr__.const_fun_300.304.exit.23, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.23:               ; preds = %__hugr__.const_fun_300.304.exit.22
  %189 = extractvalue { i1, { i1, i64, i1 } } %188, 1
  %190 = getelementptr inbounds i8, i8* %48, i64 552
  %191 = bitcast i8* %190 to { i1, i64, i1 }*
  store { i1, i64, i1 } %189, { i1, i64, i1 }* %191, align 4
  %192 = getelementptr inbounds i8, i8* %523, i64 768
  %193 = bitcast i8* %192 to { i1, { i1, i64, i1 } }*
  %194 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %193, align 4
  %.fca.0.extract11.i.24 = extractvalue { i1, { i1, i64, i1 } } %194, 0
  br i1 %.fca.0.extract11.i.24, label %__hugr__.const_fun_300.304.exit.24, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.24:               ; preds = %__hugr__.const_fun_300.304.exit.23
  %195 = extractvalue { i1, { i1, i64, i1 } } %194, 1
  %196 = getelementptr inbounds i8, i8* %48, i64 576
  %197 = bitcast i8* %196 to { i1, i64, i1 }*
  store { i1, i64, i1 } %195, { i1, i64, i1 }* %197, align 4
  %198 = getelementptr inbounds i8, i8* %523, i64 800
  %199 = bitcast i8* %198 to { i1, { i1, i64, i1 } }*
  %200 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %199, align 4
  %.fca.0.extract11.i.25 = extractvalue { i1, { i1, i64, i1 } } %200, 0
  br i1 %.fca.0.extract11.i.25, label %__hugr__.const_fun_300.304.exit.25, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.25:               ; preds = %__hugr__.const_fun_300.304.exit.24
  %201 = extractvalue { i1, { i1, i64, i1 } } %200, 1
  %202 = getelementptr inbounds i8, i8* %48, i64 600
  %203 = bitcast i8* %202 to { i1, i64, i1 }*
  store { i1, i64, i1 } %201, { i1, i64, i1 }* %203, align 4
  %204 = getelementptr inbounds i8, i8* %523, i64 832
  %205 = bitcast i8* %204 to { i1, { i1, i64, i1 } }*
  %206 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %205, align 4
  %.fca.0.extract11.i.26 = extractvalue { i1, { i1, i64, i1 } } %206, 0
  br i1 %.fca.0.extract11.i.26, label %__hugr__.const_fun_300.304.exit.26, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.26:               ; preds = %__hugr__.const_fun_300.304.exit.25
  %207 = extractvalue { i1, { i1, i64, i1 } } %206, 1
  %208 = getelementptr inbounds i8, i8* %48, i64 624
  %209 = bitcast i8* %208 to { i1, i64, i1 }*
  store { i1, i64, i1 } %207, { i1, i64, i1 }* %209, align 4
  %210 = getelementptr inbounds i8, i8* %523, i64 864
  %211 = bitcast i8* %210 to { i1, { i1, i64, i1 } }*
  %212 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %211, align 4
  %.fca.0.extract11.i.27 = extractvalue { i1, { i1, i64, i1 } } %212, 0
  br i1 %.fca.0.extract11.i.27, label %__hugr__.const_fun_300.304.exit.27, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.27:               ; preds = %__hugr__.const_fun_300.304.exit.26
  %213 = extractvalue { i1, { i1, i64, i1 } } %212, 1
  %214 = getelementptr inbounds i8, i8* %48, i64 648
  %215 = bitcast i8* %214 to { i1, i64, i1 }*
  store { i1, i64, i1 } %213, { i1, i64, i1 }* %215, align 4
  %216 = getelementptr inbounds i8, i8* %523, i64 896
  %217 = bitcast i8* %216 to { i1, { i1, i64, i1 } }*
  %218 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %217, align 4
  %.fca.0.extract11.i.28 = extractvalue { i1, { i1, i64, i1 } } %218, 0
  br i1 %.fca.0.extract11.i.28, label %__hugr__.const_fun_300.304.exit.28, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.28:               ; preds = %__hugr__.const_fun_300.304.exit.27
  %219 = extractvalue { i1, { i1, i64, i1 } } %218, 1
  %220 = getelementptr inbounds i8, i8* %48, i64 672
  %221 = bitcast i8* %220 to { i1, i64, i1 }*
  store { i1, i64, i1 } %219, { i1, i64, i1 }* %221, align 4
  %222 = getelementptr inbounds i8, i8* %523, i64 928
  %223 = bitcast i8* %222 to { i1, { i1, i64, i1 } }*
  %224 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %223, align 4
  %.fca.0.extract11.i.29 = extractvalue { i1, { i1, i64, i1 } } %224, 0
  br i1 %.fca.0.extract11.i.29, label %__hugr__.const_fun_300.304.exit.29, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.29:               ; preds = %__hugr__.const_fun_300.304.exit.28
  %225 = extractvalue { i1, { i1, i64, i1 } } %224, 1
  %226 = getelementptr inbounds i8, i8* %48, i64 696
  %227 = bitcast i8* %226 to { i1, i64, i1 }*
  store { i1, i64, i1 } %225, { i1, i64, i1 }* %227, align 4
  %228 = getelementptr inbounds i8, i8* %523, i64 960
  %229 = bitcast i8* %228 to { i1, { i1, i64, i1 } }*
  %230 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %229, align 4
  %.fca.0.extract11.i.30 = extractvalue { i1, { i1, i64, i1 } } %230, 0
  br i1 %.fca.0.extract11.i.30, label %__hugr__.const_fun_300.304.exit.30, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.30:               ; preds = %__hugr__.const_fun_300.304.exit.29
  %231 = extractvalue { i1, { i1, i64, i1 } } %230, 1
  %232 = getelementptr inbounds i8, i8* %48, i64 720
  %233 = bitcast i8* %232 to { i1, i64, i1 }*
  store { i1, i64, i1 } %231, { i1, i64, i1 }* %233, align 4
  %234 = getelementptr inbounds i8, i8* %523, i64 992
  %235 = bitcast i8* %234 to { i1, { i1, i64, i1 } }*
  %236 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %235, align 4
  %.fca.0.extract11.i.31 = extractvalue { i1, { i1, i64, i1 } } %236, 0
  br i1 %.fca.0.extract11.i.31, label %__hugr__.const_fun_300.304.exit.31, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.31:               ; preds = %__hugr__.const_fun_300.304.exit.30
  %237 = extractvalue { i1, { i1, i64, i1 } } %236, 1
  %238 = getelementptr inbounds i8, i8* %48, i64 744
  %239 = bitcast i8* %238 to { i1, i64, i1 }*
  store { i1, i64, i1 } %237, { i1, i64, i1 }* %239, align 4
  %240 = getelementptr inbounds i8, i8* %523, i64 1024
  %241 = bitcast i8* %240 to { i1, { i1, i64, i1 } }*
  %242 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %241, align 4
  %.fca.0.extract11.i.32 = extractvalue { i1, { i1, i64, i1 } } %242, 0
  br i1 %.fca.0.extract11.i.32, label %__hugr__.const_fun_300.304.exit.32, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.32:               ; preds = %__hugr__.const_fun_300.304.exit.31
  %243 = extractvalue { i1, { i1, i64, i1 } } %242, 1
  %244 = getelementptr inbounds i8, i8* %48, i64 768
  %245 = bitcast i8* %244 to { i1, i64, i1 }*
  store { i1, i64, i1 } %243, { i1, i64, i1 }* %245, align 4
  %246 = getelementptr inbounds i8, i8* %523, i64 1056
  %247 = bitcast i8* %246 to { i1, { i1, i64, i1 } }*
  %248 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %247, align 4
  %.fca.0.extract11.i.33 = extractvalue { i1, { i1, i64, i1 } } %248, 0
  br i1 %.fca.0.extract11.i.33, label %__hugr__.const_fun_300.304.exit.33, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.33:               ; preds = %__hugr__.const_fun_300.304.exit.32
  %249 = extractvalue { i1, { i1, i64, i1 } } %248, 1
  %250 = getelementptr inbounds i8, i8* %48, i64 792
  %251 = bitcast i8* %250 to { i1, i64, i1 }*
  store { i1, i64, i1 } %249, { i1, i64, i1 }* %251, align 4
  %252 = getelementptr inbounds i8, i8* %523, i64 1088
  %253 = bitcast i8* %252 to { i1, { i1, i64, i1 } }*
  %254 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %253, align 4
  %.fca.0.extract11.i.34 = extractvalue { i1, { i1, i64, i1 } } %254, 0
  br i1 %.fca.0.extract11.i.34, label %__hugr__.const_fun_300.304.exit.34, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.34:               ; preds = %__hugr__.const_fun_300.304.exit.33
  %255 = extractvalue { i1, { i1, i64, i1 } } %254, 1
  %256 = getelementptr inbounds i8, i8* %48, i64 816
  %257 = bitcast i8* %256 to { i1, i64, i1 }*
  store { i1, i64, i1 } %255, { i1, i64, i1 }* %257, align 4
  %258 = getelementptr inbounds i8, i8* %523, i64 1120
  %259 = bitcast i8* %258 to { i1, { i1, i64, i1 } }*
  %260 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %259, align 4
  %.fca.0.extract11.i.35 = extractvalue { i1, { i1, i64, i1 } } %260, 0
  br i1 %.fca.0.extract11.i.35, label %__hugr__.const_fun_300.304.exit.35, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.35:               ; preds = %__hugr__.const_fun_300.304.exit.34
  %261 = extractvalue { i1, { i1, i64, i1 } } %260, 1
  %262 = getelementptr inbounds i8, i8* %48, i64 840
  %263 = bitcast i8* %262 to { i1, i64, i1 }*
  store { i1, i64, i1 } %261, { i1, i64, i1 }* %263, align 4
  %264 = getelementptr inbounds i8, i8* %523, i64 1152
  %265 = bitcast i8* %264 to { i1, { i1, i64, i1 } }*
  %266 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %265, align 4
  %.fca.0.extract11.i.36 = extractvalue { i1, { i1, i64, i1 } } %266, 0
  br i1 %.fca.0.extract11.i.36, label %__hugr__.const_fun_300.304.exit.36, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.36:               ; preds = %__hugr__.const_fun_300.304.exit.35
  %267 = extractvalue { i1, { i1, i64, i1 } } %266, 1
  %268 = getelementptr inbounds i8, i8* %48, i64 864
  %269 = bitcast i8* %268 to { i1, i64, i1 }*
  store { i1, i64, i1 } %267, { i1, i64, i1 }* %269, align 4
  %270 = getelementptr inbounds i8, i8* %523, i64 1184
  %271 = bitcast i8* %270 to { i1, { i1, i64, i1 } }*
  %272 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %271, align 4
  %.fca.0.extract11.i.37 = extractvalue { i1, { i1, i64, i1 } } %272, 0
  br i1 %.fca.0.extract11.i.37, label %__hugr__.const_fun_300.304.exit.37, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.37:               ; preds = %__hugr__.const_fun_300.304.exit.36
  %273 = extractvalue { i1, { i1, i64, i1 } } %272, 1
  %274 = getelementptr inbounds i8, i8* %48, i64 888
  %275 = bitcast i8* %274 to { i1, i64, i1 }*
  store { i1, i64, i1 } %273, { i1, i64, i1 }* %275, align 4
  %276 = getelementptr inbounds i8, i8* %523, i64 1216
  %277 = bitcast i8* %276 to { i1, { i1, i64, i1 } }*
  %278 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %277, align 4
  %.fca.0.extract11.i.38 = extractvalue { i1, { i1, i64, i1 } } %278, 0
  br i1 %.fca.0.extract11.i.38, label %__hugr__.const_fun_300.304.exit.38, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.38:               ; preds = %__hugr__.const_fun_300.304.exit.37
  %279 = extractvalue { i1, { i1, i64, i1 } } %278, 1
  %280 = getelementptr inbounds i8, i8* %48, i64 912
  %281 = bitcast i8* %280 to { i1, i64, i1 }*
  store { i1, i64, i1 } %279, { i1, i64, i1 }* %281, align 4
  %282 = getelementptr inbounds i8, i8* %523, i64 1248
  %283 = bitcast i8* %282 to { i1, { i1, i64, i1 } }*
  %284 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %283, align 4
  %.fca.0.extract11.i.39 = extractvalue { i1, { i1, i64, i1 } } %284, 0
  br i1 %.fca.0.extract11.i.39, label %__hugr__.const_fun_300.304.exit.39, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.39:               ; preds = %__hugr__.const_fun_300.304.exit.38
  %285 = extractvalue { i1, { i1, i64, i1 } } %284, 1
  %286 = getelementptr inbounds i8, i8* %48, i64 936
  %287 = bitcast i8* %286 to { i1, i64, i1 }*
  store { i1, i64, i1 } %285, { i1, i64, i1 }* %287, align 4
  %288 = getelementptr inbounds i8, i8* %523, i64 1280
  %289 = bitcast i8* %288 to { i1, { i1, i64, i1 } }*
  %290 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %289, align 4
  %.fca.0.extract11.i.40 = extractvalue { i1, { i1, i64, i1 } } %290, 0
  br i1 %.fca.0.extract11.i.40, label %__hugr__.const_fun_300.304.exit.40, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.40:               ; preds = %__hugr__.const_fun_300.304.exit.39
  %291 = extractvalue { i1, { i1, i64, i1 } } %290, 1
  %292 = getelementptr inbounds i8, i8* %48, i64 960
  %293 = bitcast i8* %292 to { i1, i64, i1 }*
  store { i1, i64, i1 } %291, { i1, i64, i1 }* %293, align 4
  %294 = getelementptr inbounds i8, i8* %523, i64 1312
  %295 = bitcast i8* %294 to { i1, { i1, i64, i1 } }*
  %296 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %295, align 4
  %.fca.0.extract11.i.41 = extractvalue { i1, { i1, i64, i1 } } %296, 0
  br i1 %.fca.0.extract11.i.41, label %__hugr__.const_fun_300.304.exit.41, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.41:               ; preds = %__hugr__.const_fun_300.304.exit.40
  %297 = extractvalue { i1, { i1, i64, i1 } } %296, 1
  %298 = getelementptr inbounds i8, i8* %48, i64 984
  %299 = bitcast i8* %298 to { i1, i64, i1 }*
  store { i1, i64, i1 } %297, { i1, i64, i1 }* %299, align 4
  %300 = getelementptr inbounds i8, i8* %523, i64 1344
  %301 = bitcast i8* %300 to { i1, { i1, i64, i1 } }*
  %302 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %301, align 4
  %.fca.0.extract11.i.42 = extractvalue { i1, { i1, i64, i1 } } %302, 0
  br i1 %.fca.0.extract11.i.42, label %__hugr__.const_fun_300.304.exit.42, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.42:               ; preds = %__hugr__.const_fun_300.304.exit.41
  %303 = extractvalue { i1, { i1, i64, i1 } } %302, 1
  %304 = getelementptr inbounds i8, i8* %48, i64 1008
  %305 = bitcast i8* %304 to { i1, i64, i1 }*
  store { i1, i64, i1 } %303, { i1, i64, i1 }* %305, align 4
  %306 = getelementptr inbounds i8, i8* %523, i64 1376
  %307 = bitcast i8* %306 to { i1, { i1, i64, i1 } }*
  %308 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %307, align 4
  %.fca.0.extract11.i.43 = extractvalue { i1, { i1, i64, i1 } } %308, 0
  br i1 %.fca.0.extract11.i.43, label %__hugr__.const_fun_300.304.exit.43, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.43:               ; preds = %__hugr__.const_fun_300.304.exit.42
  %309 = extractvalue { i1, { i1, i64, i1 } } %308, 1
  %310 = getelementptr inbounds i8, i8* %48, i64 1032
  %311 = bitcast i8* %310 to { i1, i64, i1 }*
  store { i1, i64, i1 } %309, { i1, i64, i1 }* %311, align 4
  %312 = getelementptr inbounds i8, i8* %523, i64 1408
  %313 = bitcast i8* %312 to { i1, { i1, i64, i1 } }*
  %314 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %313, align 4
  %.fca.0.extract11.i.44 = extractvalue { i1, { i1, i64, i1 } } %314, 0
  br i1 %.fca.0.extract11.i.44, label %__hugr__.const_fun_300.304.exit.44, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.44:               ; preds = %__hugr__.const_fun_300.304.exit.43
  %315 = extractvalue { i1, { i1, i64, i1 } } %314, 1
  %316 = getelementptr inbounds i8, i8* %48, i64 1056
  %317 = bitcast i8* %316 to { i1, i64, i1 }*
  store { i1, i64, i1 } %315, { i1, i64, i1 }* %317, align 4
  %318 = getelementptr inbounds i8, i8* %523, i64 1440
  %319 = bitcast i8* %318 to { i1, { i1, i64, i1 } }*
  %320 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %319, align 4
  %.fca.0.extract11.i.45 = extractvalue { i1, { i1, i64, i1 } } %320, 0
  br i1 %.fca.0.extract11.i.45, label %__hugr__.const_fun_300.304.exit.45, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.45:               ; preds = %__hugr__.const_fun_300.304.exit.44
  %321 = extractvalue { i1, { i1, i64, i1 } } %320, 1
  %322 = getelementptr inbounds i8, i8* %48, i64 1080
  %323 = bitcast i8* %322 to { i1, i64, i1 }*
  store { i1, i64, i1 } %321, { i1, i64, i1 }* %323, align 4
  %324 = getelementptr inbounds i8, i8* %523, i64 1472
  %325 = bitcast i8* %324 to { i1, { i1, i64, i1 } }*
  %326 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %325, align 4
  %.fca.0.extract11.i.46 = extractvalue { i1, { i1, i64, i1 } } %326, 0
  br i1 %.fca.0.extract11.i.46, label %__hugr__.const_fun_300.304.exit.46, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.46:               ; preds = %__hugr__.const_fun_300.304.exit.45
  %327 = extractvalue { i1, { i1, i64, i1 } } %326, 1
  %328 = getelementptr inbounds i8, i8* %48, i64 1104
  %329 = bitcast i8* %328 to { i1, i64, i1 }*
  store { i1, i64, i1 } %327, { i1, i64, i1 }* %329, align 4
  %330 = getelementptr inbounds i8, i8* %523, i64 1504
  %331 = bitcast i8* %330 to { i1, { i1, i64, i1 } }*
  %332 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %331, align 4
  %.fca.0.extract11.i.47 = extractvalue { i1, { i1, i64, i1 } } %332, 0
  br i1 %.fca.0.extract11.i.47, label %__hugr__.const_fun_300.304.exit.47, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.47:               ; preds = %__hugr__.const_fun_300.304.exit.46
  %333 = extractvalue { i1, { i1, i64, i1 } } %332, 1
  %334 = getelementptr inbounds i8, i8* %48, i64 1128
  %335 = bitcast i8* %334 to { i1, i64, i1 }*
  store { i1, i64, i1 } %333, { i1, i64, i1 }* %335, align 4
  %336 = getelementptr inbounds i8, i8* %523, i64 1536
  %337 = bitcast i8* %336 to { i1, { i1, i64, i1 } }*
  %338 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %337, align 4
  %.fca.0.extract11.i.48 = extractvalue { i1, { i1, i64, i1 } } %338, 0
  br i1 %.fca.0.extract11.i.48, label %__hugr__.const_fun_300.304.exit.48, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.48:               ; preds = %__hugr__.const_fun_300.304.exit.47
  %339 = extractvalue { i1, { i1, i64, i1 } } %338, 1
  %340 = getelementptr inbounds i8, i8* %48, i64 1152
  %341 = bitcast i8* %340 to { i1, i64, i1 }*
  store { i1, i64, i1 } %339, { i1, i64, i1 }* %341, align 4
  %342 = getelementptr inbounds i8, i8* %523, i64 1568
  %343 = bitcast i8* %342 to { i1, { i1, i64, i1 } }*
  %344 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %343, align 4
  %.fca.0.extract11.i.49 = extractvalue { i1, { i1, i64, i1 } } %344, 0
  br i1 %.fca.0.extract11.i.49, label %__hugr__.const_fun_300.304.exit.49, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.49:               ; preds = %__hugr__.const_fun_300.304.exit.48
  %345 = extractvalue { i1, { i1, i64, i1 } } %344, 1
  %346 = getelementptr inbounds i8, i8* %48, i64 1176
  %347 = bitcast i8* %346 to { i1, i64, i1 }*
  store { i1, i64, i1 } %345, { i1, i64, i1 }* %347, align 4
  %348 = getelementptr inbounds i8, i8* %523, i64 1600
  %349 = bitcast i8* %348 to { i1, { i1, i64, i1 } }*
  %350 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %349, align 4
  %.fca.0.extract11.i.50 = extractvalue { i1, { i1, i64, i1 } } %350, 0
  br i1 %.fca.0.extract11.i.50, label %__hugr__.const_fun_300.304.exit.50, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.50:               ; preds = %__hugr__.const_fun_300.304.exit.49
  %351 = extractvalue { i1, { i1, i64, i1 } } %350, 1
  %352 = getelementptr inbounds i8, i8* %48, i64 1200
  %353 = bitcast i8* %352 to { i1, i64, i1 }*
  store { i1, i64, i1 } %351, { i1, i64, i1 }* %353, align 4
  %354 = getelementptr inbounds i8, i8* %523, i64 1632
  %355 = bitcast i8* %354 to { i1, { i1, i64, i1 } }*
  %356 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %355, align 4
  %.fca.0.extract11.i.51 = extractvalue { i1, { i1, i64, i1 } } %356, 0
  br i1 %.fca.0.extract11.i.51, label %__hugr__.const_fun_300.304.exit.51, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.51:               ; preds = %__hugr__.const_fun_300.304.exit.50
  %357 = extractvalue { i1, { i1, i64, i1 } } %356, 1
  %358 = getelementptr inbounds i8, i8* %48, i64 1224
  %359 = bitcast i8* %358 to { i1, i64, i1 }*
  store { i1, i64, i1 } %357, { i1, i64, i1 }* %359, align 4
  %360 = getelementptr inbounds i8, i8* %523, i64 1664
  %361 = bitcast i8* %360 to { i1, { i1, i64, i1 } }*
  %362 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %361, align 4
  %.fca.0.extract11.i.52 = extractvalue { i1, { i1, i64, i1 } } %362, 0
  br i1 %.fca.0.extract11.i.52, label %__hugr__.const_fun_300.304.exit.52, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.52:               ; preds = %__hugr__.const_fun_300.304.exit.51
  %363 = extractvalue { i1, { i1, i64, i1 } } %362, 1
  %364 = getelementptr inbounds i8, i8* %48, i64 1248
  %365 = bitcast i8* %364 to { i1, i64, i1 }*
  store { i1, i64, i1 } %363, { i1, i64, i1 }* %365, align 4
  %366 = getelementptr inbounds i8, i8* %523, i64 1696
  %367 = bitcast i8* %366 to { i1, { i1, i64, i1 } }*
  %368 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %367, align 4
  %.fca.0.extract11.i.53 = extractvalue { i1, { i1, i64, i1 } } %368, 0
  br i1 %.fca.0.extract11.i.53, label %__hugr__.const_fun_300.304.exit.53, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.53:               ; preds = %__hugr__.const_fun_300.304.exit.52
  %369 = extractvalue { i1, { i1, i64, i1 } } %368, 1
  %370 = getelementptr inbounds i8, i8* %48, i64 1272
  %371 = bitcast i8* %370 to { i1, i64, i1 }*
  store { i1, i64, i1 } %369, { i1, i64, i1 }* %371, align 4
  %372 = getelementptr inbounds i8, i8* %523, i64 1728
  %373 = bitcast i8* %372 to { i1, { i1, i64, i1 } }*
  %374 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %373, align 4
  %.fca.0.extract11.i.54 = extractvalue { i1, { i1, i64, i1 } } %374, 0
  br i1 %.fca.0.extract11.i.54, label %__hugr__.const_fun_300.304.exit.54, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.54:               ; preds = %__hugr__.const_fun_300.304.exit.53
  %375 = extractvalue { i1, { i1, i64, i1 } } %374, 1
  %376 = getelementptr inbounds i8, i8* %48, i64 1296
  %377 = bitcast i8* %376 to { i1, i64, i1 }*
  store { i1, i64, i1 } %375, { i1, i64, i1 }* %377, align 4
  %378 = getelementptr inbounds i8, i8* %523, i64 1760
  %379 = bitcast i8* %378 to { i1, { i1, i64, i1 } }*
  %380 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %379, align 4
  %.fca.0.extract11.i.55 = extractvalue { i1, { i1, i64, i1 } } %380, 0
  br i1 %.fca.0.extract11.i.55, label %__hugr__.const_fun_300.304.exit.55, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.55:               ; preds = %__hugr__.const_fun_300.304.exit.54
  %381 = extractvalue { i1, { i1, i64, i1 } } %380, 1
  %382 = getelementptr inbounds i8, i8* %48, i64 1320
  %383 = bitcast i8* %382 to { i1, i64, i1 }*
  store { i1, i64, i1 } %381, { i1, i64, i1 }* %383, align 4
  %384 = getelementptr inbounds i8, i8* %523, i64 1792
  %385 = bitcast i8* %384 to { i1, { i1, i64, i1 } }*
  %386 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %385, align 4
  %.fca.0.extract11.i.56 = extractvalue { i1, { i1, i64, i1 } } %386, 0
  br i1 %.fca.0.extract11.i.56, label %__hugr__.const_fun_300.304.exit.56, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.56:               ; preds = %__hugr__.const_fun_300.304.exit.55
  %387 = extractvalue { i1, { i1, i64, i1 } } %386, 1
  %388 = getelementptr inbounds i8, i8* %48, i64 1344
  %389 = bitcast i8* %388 to { i1, i64, i1 }*
  store { i1, i64, i1 } %387, { i1, i64, i1 }* %389, align 4
  %390 = getelementptr inbounds i8, i8* %523, i64 1824
  %391 = bitcast i8* %390 to { i1, { i1, i64, i1 } }*
  %392 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %391, align 4
  %.fca.0.extract11.i.57 = extractvalue { i1, { i1, i64, i1 } } %392, 0
  br i1 %.fca.0.extract11.i.57, label %__hugr__.const_fun_300.304.exit.57, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.57:               ; preds = %__hugr__.const_fun_300.304.exit.56
  %393 = extractvalue { i1, { i1, i64, i1 } } %392, 1
  %394 = getelementptr inbounds i8, i8* %48, i64 1368
  %395 = bitcast i8* %394 to { i1, i64, i1 }*
  store { i1, i64, i1 } %393, { i1, i64, i1 }* %395, align 4
  %396 = getelementptr inbounds i8, i8* %523, i64 1856
  %397 = bitcast i8* %396 to { i1, { i1, i64, i1 } }*
  %398 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %397, align 4
  %.fca.0.extract11.i.58 = extractvalue { i1, { i1, i64, i1 } } %398, 0
  br i1 %.fca.0.extract11.i.58, label %__hugr__.const_fun_300.304.exit.58, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.58:               ; preds = %__hugr__.const_fun_300.304.exit.57
  %399 = extractvalue { i1, { i1, i64, i1 } } %398, 1
  %400 = getelementptr inbounds i8, i8* %48, i64 1392
  %401 = bitcast i8* %400 to { i1, i64, i1 }*
  store { i1, i64, i1 } %399, { i1, i64, i1 }* %401, align 4
  %402 = getelementptr inbounds i8, i8* %523, i64 1888
  %403 = bitcast i8* %402 to { i1, { i1, i64, i1 } }*
  %404 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %403, align 4
  %.fca.0.extract11.i.59 = extractvalue { i1, { i1, i64, i1 } } %404, 0
  br i1 %.fca.0.extract11.i.59, label %__hugr__.const_fun_300.304.exit.59, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.59:               ; preds = %__hugr__.const_fun_300.304.exit.58
  %405 = extractvalue { i1, { i1, i64, i1 } } %404, 1
  %406 = getelementptr inbounds i8, i8* %48, i64 1416
  %407 = bitcast i8* %406 to { i1, i64, i1 }*
  store { i1, i64, i1 } %405, { i1, i64, i1 }* %407, align 4
  %408 = getelementptr inbounds i8, i8* %523, i64 1920
  %409 = bitcast i8* %408 to { i1, { i1, i64, i1 } }*
  %410 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %409, align 4
  %.fca.0.extract11.i.60 = extractvalue { i1, { i1, i64, i1 } } %410, 0
  br i1 %.fca.0.extract11.i.60, label %__hugr__.const_fun_300.304.exit.60, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.60:               ; preds = %__hugr__.const_fun_300.304.exit.59
  %411 = extractvalue { i1, { i1, i64, i1 } } %410, 1
  %412 = getelementptr inbounds i8, i8* %48, i64 1440
  %413 = bitcast i8* %412 to { i1, i64, i1 }*
  store { i1, i64, i1 } %411, { i1, i64, i1 }* %413, align 4
  %414 = getelementptr inbounds i8, i8* %523, i64 1952
  %415 = bitcast i8* %414 to { i1, { i1, i64, i1 } }*
  %416 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %415, align 4
  %.fca.0.extract11.i.61 = extractvalue { i1, { i1, i64, i1 } } %416, 0
  br i1 %.fca.0.extract11.i.61, label %__hugr__.const_fun_300.304.exit.61, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.61:               ; preds = %__hugr__.const_fun_300.304.exit.60
  %417 = extractvalue { i1, { i1, i64, i1 } } %416, 1
  %418 = getelementptr inbounds i8, i8* %48, i64 1464
  %419 = bitcast i8* %418 to { i1, i64, i1 }*
  store { i1, i64, i1 } %417, { i1, i64, i1 }* %419, align 4
  %420 = getelementptr inbounds i8, i8* %523, i64 1984
  %421 = bitcast i8* %420 to { i1, { i1, i64, i1 } }*
  %422 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %421, align 4
  %.fca.0.extract11.i.62 = extractvalue { i1, { i1, i64, i1 } } %422, 0
  br i1 %.fca.0.extract11.i.62, label %__hugr__.const_fun_300.304.exit.62, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.62:               ; preds = %__hugr__.const_fun_300.304.exit.61
  %423 = extractvalue { i1, { i1, i64, i1 } } %422, 1
  %424 = getelementptr inbounds i8, i8* %48, i64 1488
  %425 = bitcast i8* %424 to { i1, i64, i1 }*
  store { i1, i64, i1 } %423, { i1, i64, i1 }* %425, align 4
  %426 = getelementptr inbounds i8, i8* %523, i64 2016
  %427 = bitcast i8* %426 to { i1, { i1, i64, i1 } }*
  %428 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %427, align 4
  %.fca.0.extract11.i.63 = extractvalue { i1, { i1, i64, i1 } } %428, 0
  br i1 %.fca.0.extract11.i.63, label %__hugr__.const_fun_300.304.exit.63, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.63:               ; preds = %__hugr__.const_fun_300.304.exit.62
  %429 = extractvalue { i1, { i1, i64, i1 } } %428, 1
  %430 = getelementptr inbounds i8, i8* %48, i64 1512
  %431 = bitcast i8* %430 to { i1, i64, i1 }*
  store { i1, i64, i1 } %429, { i1, i64, i1 }* %431, align 4
  %432 = getelementptr inbounds i8, i8* %523, i64 2048
  %433 = bitcast i8* %432 to { i1, { i1, i64, i1 } }*
  %434 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %433, align 4
  %.fca.0.extract11.i.64 = extractvalue { i1, { i1, i64, i1 } } %434, 0
  br i1 %.fca.0.extract11.i.64, label %__hugr__.const_fun_300.304.exit.64, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.64:               ; preds = %__hugr__.const_fun_300.304.exit.63
  %435 = extractvalue { i1, { i1, i64, i1 } } %434, 1
  %436 = getelementptr inbounds i8, i8* %48, i64 1536
  %437 = bitcast i8* %436 to { i1, i64, i1 }*
  store { i1, i64, i1 } %435, { i1, i64, i1 }* %437, align 4
  %438 = getelementptr inbounds i8, i8* %523, i64 2080
  %439 = bitcast i8* %438 to { i1, { i1, i64, i1 } }*
  %440 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %439, align 4
  %.fca.0.extract11.i.65 = extractvalue { i1, { i1, i64, i1 } } %440, 0
  br i1 %.fca.0.extract11.i.65, label %__hugr__.const_fun_300.304.exit.65, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.65:               ; preds = %__hugr__.const_fun_300.304.exit.64
  %441 = extractvalue { i1, { i1, i64, i1 } } %440, 1
  %442 = getelementptr inbounds i8, i8* %48, i64 1560
  %443 = bitcast i8* %442 to { i1, i64, i1 }*
  store { i1, i64, i1 } %441, { i1, i64, i1 }* %443, align 4
  %444 = getelementptr inbounds i8, i8* %523, i64 2112
  %445 = bitcast i8* %444 to { i1, { i1, i64, i1 } }*
  %446 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %445, align 4
  %.fca.0.extract11.i.66 = extractvalue { i1, { i1, i64, i1 } } %446, 0
  br i1 %.fca.0.extract11.i.66, label %__hugr__.const_fun_300.304.exit.66, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.66:               ; preds = %__hugr__.const_fun_300.304.exit.65
  %447 = extractvalue { i1, { i1, i64, i1 } } %446, 1
  %448 = getelementptr inbounds i8, i8* %48, i64 1584
  %449 = bitcast i8* %448 to { i1, i64, i1 }*
  store { i1, i64, i1 } %447, { i1, i64, i1 }* %449, align 4
  %450 = getelementptr inbounds i8, i8* %523, i64 2144
  %451 = bitcast i8* %450 to { i1, { i1, i64, i1 } }*
  %452 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %451, align 4
  %.fca.0.extract11.i.67 = extractvalue { i1, { i1, i64, i1 } } %452, 0
  br i1 %.fca.0.extract11.i.67, label %__hugr__.const_fun_300.304.exit.67, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.67:               ; preds = %__hugr__.const_fun_300.304.exit.66
  %453 = extractvalue { i1, { i1, i64, i1 } } %452, 1
  %454 = getelementptr inbounds i8, i8* %48, i64 1608
  %455 = bitcast i8* %454 to { i1, i64, i1 }*
  store { i1, i64, i1 } %453, { i1, i64, i1 }* %455, align 4
  %456 = getelementptr inbounds i8, i8* %523, i64 2176
  %457 = bitcast i8* %456 to { i1, { i1, i64, i1 } }*
  %458 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %457, align 4
  %.fca.0.extract11.i.68 = extractvalue { i1, { i1, i64, i1 } } %458, 0
  br i1 %.fca.0.extract11.i.68, label %__hugr__.const_fun_300.304.exit.68, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.68:               ; preds = %__hugr__.const_fun_300.304.exit.67
  %459 = extractvalue { i1, { i1, i64, i1 } } %458, 1
  %460 = getelementptr inbounds i8, i8* %48, i64 1632
  %461 = bitcast i8* %460 to { i1, i64, i1 }*
  store { i1, i64, i1 } %459, { i1, i64, i1 }* %461, align 4
  %462 = getelementptr inbounds i8, i8* %523, i64 2208
  %463 = bitcast i8* %462 to { i1, { i1, i64, i1 } }*
  %464 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %463, align 4
  %.fca.0.extract11.i.69 = extractvalue { i1, { i1, i64, i1 } } %464, 0
  br i1 %.fca.0.extract11.i.69, label %__hugr__.const_fun_300.304.exit.69, label %cond_591_case_0.i

__hugr__.const_fun_300.304.exit.69:               ; preds = %__hugr__.const_fun_300.304.exit.68
  %465 = extractvalue { i1, { i1, i64, i1 } } %464, 1
  %466 = getelementptr inbounds i8, i8* %48, i64 1656
  %467 = bitcast i8* %466 to { i1, i64, i1 }*
  store { i1, i64, i1 } %465, { i1, i64, i1 }* %467, align 4
  tail call void @heap_free(i8* nonnull %523)
  tail call void @heap_free(i8* %524)
  %468 = getelementptr inbounds i8, i8* %50, i64 8
  %469 = bitcast i8* %468 to i64*
  br label %__barray_check_bounds.exit709

cond_505_case_0:                                  ; preds = %cond_exit_505
  %470 = load i64, i64* %469, align 4
  %471 = or i64 %470, -64
  store i64 %471, i64* %469, align 4
  %472 = load i64, i64* %51, align 4
  %473 = icmp eq i64 %472, -1
  %474 = icmp eq i64 %471, -1
  %or.cond773 = select i1 %473, i1 %474, i1 false
  br i1 %or.cond773, label %loop_out150, label %mask_block_err.i707

mask_block_err.i707:                              ; preds = %cond_505_case_0
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit709:                    ; preds = %__hugr__.const_fun_300.304.exit.69, %cond_exit_505
  %"502_0.0777" = phi i64 [ 0, %__hugr__.const_fun_300.304.exit.69 ], [ %475, %cond_exit_505 ]
  %475 = add nuw nsw i64 %"502_0.0777", 1
  %476 = lshr i64 %"502_0.0777", 6
  %477 = getelementptr inbounds i64, i64* %51, i64 %476
  %478 = load i64, i64* %477, align 4
  %479 = and i64 %"502_0.0777", 63
  %480 = shl nuw i64 1, %479
  %481 = and i64 %478, %480
  %.not = icmp eq i64 %481, 0
  br i1 %.not, label %__barray_mask_borrow.exit, label %cond_exit_505

__barray_mask_borrow.exit:                        ; preds = %__barray_check_bounds.exit709
  %482 = xor i64 %478, %480
  store i64 %482, i64* %477, align 4
  %483 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %49, i64 %"502_0.0777"
  %484 = load { i1, i64, i1 }, { i1, i64, i1 }* %483, align 4
  %.fca.0.extract399 = extractvalue { i1, i64, i1 } %484, 0
  br i1 %.fca.0.extract399, label %cond_528_case_1, label %cond_exit_505

cond_exit_505:                                    ; preds = %cond_528_case_1, %__barray_mask_borrow.exit, %__barray_check_bounds.exit709
  %485 = icmp ult i64 %"502_0.0777", 69
  br i1 %485, label %__barray_check_bounds.exit709, label %cond_505_case_0

loop_out150:                                      ; preds = %cond_505_case_0
  tail call void @heap_free(i8* %48)
  tail call void @heap_free(i8* nonnull %50)
  %486 = getelementptr inbounds i8, i8* %17, i64 8
  %487 = bitcast i8* %486 to i64*
  %488 = load i64, i64* %487, align 4
  %489 = and i64 %488, 63
  store i64 %489, i64* %487, align 4
  %490 = load i64, i64* %18, align 4
  %491 = icmp eq i64 %490, 0
  %492 = icmp eq i64 %489, 0
  %or.cond774 = select i1 %491, i1 %492, i1 false
  br i1 %or.cond774, label %__barray_check_none_borrowed.exit718, label %mask_block_err.i717

__barray_check_none_borrowed.exit718:             ; preds = %loop_out150
  %493 = tail call i8* @heap_alloc(i64 70)
  %494 = tail call i8* @heap_alloc(i64 16)
  %495 = bitcast i8* %494 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %495, i8 0, i64 16, i1 false)
  br label %496

mask_block_err.i717:                              ; preds = %loop_out150
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_528_case_1:                                  ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract400 = extractvalue { i1, i64, i1 } %484, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract400)
  br label %cond_exit_505

496:                                              ; preds = %__barray_check_none_borrowed.exit718, %__hugr__.array.__read_bool.3.294.exit
  %storemerge762 = phi i64 [ 0, %__barray_check_none_borrowed.exit718 ], [ %501, %__hugr__.array.__read_bool.3.294.exit ]
  %497 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %16, i64 %storemerge762
  %498 = load { i1, i64, i1 }, { i1, i64, i1 }* %497, align 4
  %.fca.0.extract.i719 = extractvalue { i1, i64, i1 } %498, 0
  %.fca.1.extract.i720 = extractvalue { i1, i64, i1 } %498, 1
  br i1 %.fca.0.extract.i719, label %cond_366_case_1.i, label %cond_366_case_0.i

cond_366_case_0.i:                                ; preds = %496
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %498, 2
  br label %__hugr__.array.__read_bool.3.294.exit

cond_366_case_1.i:                                ; preds = %496
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i720)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i720)
  br label %__hugr__.array.__read_bool.3.294.exit

__hugr__.array.__read_bool.3.294.exit:            ; preds = %cond_366_case_0.i, %cond_366_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_366_case_1.i ], [ %.fca.2.extract.i, %cond_366_case_0.i ]
  %499 = getelementptr inbounds i8, i8* %493, i64 %storemerge762
  %500 = bitcast i8* %499 to i1*
  store i1 %"03.0.i", i1* %500, align 1
  %501 = add nuw nsw i64 %storemerge762, 1
  %exitcond771.not = icmp eq i64 %501, 70
  br i1 %exitcond771.not, label %mask_block_ok.i723, label %496

mask_block_ok.i723:                               ; preds = %__hugr__.array.__read_bool.3.294.exit
  tail call void @heap_free(i8* nonnull %15)
  tail call void @heap_free(i8* %17)
  %502 = getelementptr inbounds i8, i8* %494, i64 8
  %503 = bitcast i8* %502 to i64*
  %504 = load i64, i64* %503, align 4
  %505 = and i64 %504, 63
  store i64 %505, i64* %503, align 4
  %506 = load i64, i64* %495, align 4
  %507 = icmp eq i64 %506, 0
  %508 = icmp eq i64 %505, 0
  %or.cond775 = select i1 %507, i1 %508, i1 false
  br i1 %or.cond775, label %__barray_check_none_borrowed.exit725, label %mask_block_err.i724

__barray_check_none_borrowed.exit725:             ; preds = %mask_block_ok.i723
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %509 = alloca [70 x i1], align 1
  %.sub = getelementptr inbounds [70 x i1], [70 x i1]* %509, i64 0, i64 0
  %510 = bitcast [70 x i1]* %509 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(70) %510, i8 0, i64 70, i1 false)
  store i32 70, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %511 = bitcast i1** %arr_ptr to i8**
  store i8* %493, i8** %511, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @res_bools.B1D99BB9.0, i64 0, i64 0), i64 18, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  ret void

mask_block_err.i724:                              ; preds = %mask_block_ok.i723
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_exit_84:                                     ; preds = %loop_out
  %512 = tail call i8* @heap_alloc(i64 1680)
  %513 = bitcast i8* %512 to { i1, i64, i1 }*
  %514 = tail call i8* @heap_alloc(i64 16)
  %515 = bitcast i8* %514 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %515, i8 -1, i64 16, i1 false)
  %516 = getelementptr inbounds i8, i8* %2, i64 8
  %517 = bitcast i8* %516 to i64*
  br label %533

mask_block_ok.i.i.i:                              ; preds = %cond_exit_478.i
  %518 = load i64, i64* %517, align 4
  %519 = or i64 %518, -64
  store i64 %519, i64* %517, align 4
  %520 = load i64, i64* %3, align 4
  %521 = icmp eq i64 %520, -1
  %522 = icmp eq i64 %519, -1
  %or.cond776 = select i1 %521, i1 %522, i1 false
  br i1 %or.cond776, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit", label %mask_block_err.i.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit": ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %523 = tail call i8* @heap_alloc(i64 2240)
  %524 = tail call i8* @heap_alloc(i64 16)
  %525 = bitcast i8* %524 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %525, i8 0, i64 16, i1 false)
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(2240) %523, i8 0, i64 2240, i1 false)
  %526 = getelementptr inbounds i8, i8* %514, i64 8
  %527 = bitcast i8* %526 to i64*
  %528 = load i64, i64* %527, align 4
  %529 = and i64 %528, 63
  store i64 %529, i64* %527, align 4
  %530 = load i64, i64* %515, align 4
  %531 = icmp eq i64 %530, 0
  %532 = icmp eq i64 %529, 0
  %or.cond = select i1 %531, i1 %532, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

533:                                              ; preds = %cond_exit_84, %cond_exit_478.i
  %"427_0.sroa.15.0.i755" = phi i64 [ 0, %cond_exit_84 ], [ %534, %cond_exit_478.i ]
  %534 = add nuw nsw i64 %"427_0.sroa.15.0.i755", 1
  %535 = lshr i64 %"427_0.sroa.15.0.i755", 6
  %536 = getelementptr inbounds i64, i64* %3, i64 %535
  %537 = load i64, i64* %536, align 4
  %538 = and i64 %"427_0.sroa.15.0.i755", 63
  %539 = shl nuw i64 1, %538
  %540 = and i64 %537, %539
  %.not.i101.i.i = icmp eq i64 %540, 0
  br i1 %.not.i101.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %533
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %533
  %541 = xor i64 %537, %539
  store i64 %541, i64* %536, align 4
  %542 = getelementptr inbounds i64, i64* %1, i64 %"427_0.sroa.15.0.i755"
  %543 = load i64, i64* %542, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %543)
  tail call void @___qfree(i64 %543)
  %544 = getelementptr inbounds i64, i64* %515, i64 %535
  %545 = load i64, i64* %544, align 4
  %546 = and i64 %545, %539
  %.not.i.i727 = icmp eq i64 %546, 0
  br i1 %.not.i.i727, label %panic.i.i728, label %cond_exit_478.i

panic.i.i728:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_478.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"492_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %547 = xor i64 %545, %539
  store i64 %547, i64* %544, align 4
  %548 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %513, i64 %"427_0.sroa.15.0.i755"
  store { i1, i64, i1 } %"492_054.fca.1.insert.i", { i1, i64, i1 }* %548, align 4
  %exitcond768.not = icmp eq i64 %534, 70
  br i1 %exitcond768.not, label %mask_block_ok.i.i.i, label %533

finish:                                           ; preds = %cond_exit_20, %loop_out
  %"47_0.0753" = phi i64 [ %549, %loop_out ], [ 0, %cond_exit_20 ]
  %549 = add nuw nsw i64 %"47_0.0753", 1
  %remainder.urem = and i64 %"47_0.0753", 1
  %550 = icmp eq i64 %remainder.urem, 0
  br i1 %550, label %__barray_check_bounds.exit730, label %loop_out

__barray_check_bounds.exit730:                    ; preds = %finish
  %551 = lshr i64 %"47_0.0753", 6
  %552 = getelementptr inbounds i64, i64* %3, i64 %551
  %553 = load i64, i64* %552, align 4
  %554 = and i64 %"47_0.0753", 63
  %555 = shl nuw i64 1, %554
  %556 = and i64 %553, %555
  %.not.i731 = icmp eq i64 %556, 0
  br i1 %.not.i731, label %__barray_check_bounds.exit735, label %panic.i732

panic.i732:                                       ; preds = %__barray_check_bounds.exit730
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit735:                    ; preds = %__barray_check_bounds.exit730
  %557 = xor i64 %553, %555
  store i64 %557, i64* %552, align 4
  %558 = getelementptr inbounds i64, i64* %1, i64 %"47_0.0753"
  %559 = load i64, i64* %558, align 4
  tail call void @___rxy(i64 %559, double 0x400921FB54442D18, double 0.000000e+00)
  %560 = load i64, i64* %552, align 4
  %561 = and i64 %560, %555
  %.not.i736 = icmp eq i64 %561, 0
  br i1 %.not.i736, label %panic.i737, label %__barray_mask_return.exit738

panic.i737:                                       ; preds = %__barray_check_bounds.exit735
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit738:                     ; preds = %__barray_check_bounds.exit735
  %562 = xor i64 %560, %555
  store i64 %562, i64* %552, align 4
  store i64 %559, i64* %558, align 4
  br label %loop_out
}

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i64.i64(i64* nocapture writeonly, i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #1

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @heap_free(i8*) local_unnamed_addr

declare void @print_bool_arr(i8*, i64, <{ i32, i32, i1*, i1* }>*) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @__hugr__.__main__.memory_allocation.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

attributes #0 = { argmemonly mustprogress nofree nounwind willreturn writeonly }
attributes #1 = { noreturn }
attributes #2 = { argmemonly nofree nounwind willreturn writeonly }

!name = !{!0}

!0 = !{!"mainlib"}
