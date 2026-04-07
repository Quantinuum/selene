; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call i8* @heap_alloc(i64 560)
  %1 = bitcast i8* %0 to i64*
  %2 = tail call i8* @heap_alloc(i64 16)
  %3 = bitcast i8* %2 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %3, i8 -1, i64 16, i1 false)
  br label %cond_20_case_1

loop_out:                                         ; preds = %finish, %__barray_mask_return.exit738
  %exitcond767.not = icmp eq i64 %139, 70
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
  br i1 %.fca.0.extract.i, label %__barray_check_bounds.exit, label %cond_324_case_0.i

cond_324_case_0.i:                                ; preds = %id_bb.i
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

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$measure_array$$n(70).396.exit"
  %15 = tail call i8* @heap_alloc(i64 1680)
  %16 = bitcast i8* %15 to { i1, i64, i1 }*
  %17 = tail call i8* @heap_alloc(i64 16)
  %18 = bitcast i8* %17 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %18, i8 0, i64 16, i1 false)
  %19 = bitcast i8* %113 to { i1, { i1, i64, i1 } }*
  br label %20

mask_block_err.i:                                 ; preds = %"__hugr__.$measure_array$$n(70).396.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

20:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_301.304.exit
  %storemerge680760 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %38, %__hugr__.const_fun_301.304.exit ]
  %21 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %36, %__hugr__.const_fun_301.304.exit ]
  %22 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %103, i64 %storemerge680760
  %23 = load { i1, i64, i1 }, { i1, i64, i1 }* %22, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %23, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %23, 1
  br i1 %.fca.0.extract118.i, label %cond_543_case_1.i, label %cond_exit_543.i

cond_543_case_1.i:                                ; preds = %20
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %24 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %cond_exit_543.i

cond_exit_543.i:                                  ; preds = %cond_543_case_1.i, %20
  %.pn.i = phi { i1, i64, i1 } [ %24, %cond_543_case_1.i ], [ %23, %20 ]
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %exitcond769.not = icmp eq i64 %storemerge680760, 70
  br i1 %exitcond769.not, label %cond_546_case_0.i, label %25

25:                                               ; preds = %cond_exit_543.i
  %26 = lshr i64 %21, 6
  %27 = getelementptr inbounds i64, i64* %115, i64 %26
  %28 = load i64, i64* %27, align 4
  %29 = and i64 %21, 63
  %30 = shl nuw i64 1, %29
  %31 = and i64 %28, %30
  %.not.i.i = icmp eq i64 %31, 0
  br i1 %.not.i.i, label %cond_546_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %25
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_546_case_0.i:                                ; preds = %cond_exit_543.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_546_case_1.i:                                ; preds = %25
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %23, i1 %"04.sroa.6.0.i", 2
  %32 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %33 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %19, i64 %21
  %34 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %33, i64 0, i32 0
  %35 = load i1, i1* %34, align 1
  store { i1, { i1, i64, i1 } } %32, { i1, { i1, i64, i1 } }* %33, align 4
  br i1 %35, label %cond_547_case_1.i, label %__hugr__.const_fun_301.304.exit

cond_547_case_1.i:                                ; preds = %cond_546_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_301.304.exit:                  ; preds = %cond_546_case_1.i
  %36 = add nuw nsw i64 %21, 1
  %37 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %16, i64 %storemerge680760
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %37, align 4
  %38 = add nuw nsw i64 %storemerge680760, 1
  %exitcond770.not = icmp eq i64 %38, 70
  br i1 %exitcond770.not, label %mask_block_ok.i701.preheader, label %20

mask_block_ok.i701.preheader:                     ; preds = %__hugr__.const_fun_301.304.exit
  tail call void @heap_free(i8* nonnull %102)
  tail call void @heap_free(i8* %104)
  %39 = load i64, i64* %115, align 4
  %40 = getelementptr inbounds i8, i8* %114, i64 8
  %41 = bitcast i8* %40 to i64*
  %42 = load i64, i64* %41, align 4
  %43 = and i64 %42, 63
  store i64 %43, i64* %41, align 4
  %44 = icmp eq i64 %39, 0
  br i1 %44, label %.mask_block_ok.i701_crit_edge, label %mask_block_err.i702

.mask_block_ok.i701_crit_edge:                    ; preds = %mask_block_ok.i701.preheader
  %.phi.trans.insert = getelementptr inbounds i8, i8* %114, i64 8
  %45 = bitcast i8* %.phi.trans.insert to i64*
  %.pre = load i64, i64* %45, align 4
  %46 = icmp eq i64 %.pre, 0
  br i1 %46, label %__barray_check_none_borrowed.exit703, label %mask_block_err.i702

mask_block_err.i702:                              ; preds = %.mask_block_ok.i701_crit_edge, %mask_block_ok.i701.preheader
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit703:             ; preds = %.mask_block_ok.i701_crit_edge
  %47 = tail call i8* @heap_alloc(i64 1680)
  %48 = bitcast i8* %47 to { i1, i64, i1 }*
  %49 = tail call i8* @heap_alloc(i64 16)
  %50 = bitcast i8* %49 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %50, i8 0, i64 16, i1 false)
  br label %51

51:                                               ; preds = %__barray_check_none_borrowed.exit703, %__hugr__.const_fun_297.301.exit
  %storemerge667761 = phi i64 [ 0, %__barray_check_none_borrowed.exit703 ], [ %56, %__hugr__.const_fun_297.301.exit ]
  %52 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %19, i64 %storemerge667761
  %53 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %52, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %53, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_297.301.exit, label %cond_588_case_0.i

cond_588_case_0.i:                                ; preds = %51
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_297.301.exit:                  ; preds = %51
  %54 = extractvalue { i1, { i1, i64, i1 } } %53, 1
  %55 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %48, i64 %storemerge667761
  store { i1, i64, i1 } %54, { i1, i64, i1 }* %55, align 4
  %56 = add nuw nsw i64 %storemerge667761, 1
  %exitcond771.not = icmp eq i64 %56, 70
  br i1 %exitcond771.not, label %57, label %51

57:                                               ; preds = %__hugr__.const_fun_297.301.exit
  tail call void @heap_free(i8* nonnull %113)
  tail call void @heap_free(i8* %114)
  %58 = getelementptr inbounds i8, i8* %49, i64 8
  %59 = bitcast i8* %58 to i64*
  br label %__barray_check_bounds.exit709

cond_502_case_0:                                  ; preds = %cond_exit_502
  %60 = load i64, i64* %59, align 4
  %61 = or i64 %60, -64
  store i64 %61, i64* %59, align 4
  %62 = load i64, i64* %50, align 4
  %63 = icmp eq i64 %62, -1
  %64 = icmp eq i64 %61, -1
  %or.cond774 = select i1 %63, i1 %64, i1 false
  br i1 %or.cond774, label %loop_out150, label %mask_block_err.i707

mask_block_err.i707:                              ; preds = %cond_502_case_0
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit709:                    ; preds = %57, %cond_exit_502
  %"499_0.0778" = phi i64 [ 0, %57 ], [ %65, %cond_exit_502 ]
  %65 = add nuw nsw i64 %"499_0.0778", 1
  %66 = lshr i64 %"499_0.0778", 6
  %67 = getelementptr inbounds i64, i64* %50, i64 %66
  %68 = load i64, i64* %67, align 4
  %69 = and i64 %"499_0.0778", 63
  %70 = shl nuw i64 1, %69
  %71 = and i64 %68, %70
  %.not = icmp eq i64 %71, 0
  br i1 %.not, label %__barray_mask_borrow.exit, label %cond_exit_502

__barray_mask_borrow.exit:                        ; preds = %__barray_check_bounds.exit709
  %72 = xor i64 %68, %70
  store i64 %72, i64* %67, align 4
  %73 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %48, i64 %"499_0.0778"
  %74 = load { i1, i64, i1 }, { i1, i64, i1 }* %73, align 4
  %.fca.0.extract399 = extractvalue { i1, i64, i1 } %74, 0
  br i1 %.fca.0.extract399, label %cond_525_case_1, label %cond_exit_502

cond_exit_502:                                    ; preds = %cond_525_case_1, %__barray_mask_borrow.exit, %__barray_check_bounds.exit709
  %75 = icmp ult i64 %"499_0.0778", 69
  br i1 %75, label %__barray_check_bounds.exit709, label %cond_502_case_0

loop_out150:                                      ; preds = %cond_502_case_0
  tail call void @heap_free(i8* %47)
  tail call void @heap_free(i8* nonnull %49)
  %76 = getelementptr inbounds i8, i8* %17, i64 8
  %77 = bitcast i8* %76 to i64*
  %78 = load i64, i64* %77, align 4
  %79 = and i64 %78, 63
  store i64 %79, i64* %77, align 4
  %80 = load i64, i64* %18, align 4
  %81 = icmp eq i64 %80, 0
  %82 = icmp eq i64 %79, 0
  %or.cond775 = select i1 %81, i1 %82, i1 false
  br i1 %or.cond775, label %__barray_check_none_borrowed.exit718, label %mask_block_err.i717

__barray_check_none_borrowed.exit718:             ; preds = %loop_out150
  %83 = tail call i8* @heap_alloc(i64 70)
  %84 = tail call i8* @heap_alloc(i64 16)
  %85 = bitcast i8* %84 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %85, i8 0, i64 16, i1 false)
  br label %86

mask_block_err.i717:                              ; preds = %loop_out150
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_525_case_1:                                  ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract400 = extractvalue { i1, i64, i1 } %74, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract400)
  br label %cond_exit_502

86:                                               ; preds = %__barray_check_none_borrowed.exit718, %__hugr__.array.__read_bool.3.292.exit
  %storemerge762 = phi i64 [ 0, %__barray_check_none_borrowed.exit718 ], [ %91, %__hugr__.array.__read_bool.3.292.exit ]
  %87 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %16, i64 %storemerge762
  %88 = load { i1, i64, i1 }, { i1, i64, i1 }* %87, align 4
  %.fca.0.extract.i719 = extractvalue { i1, i64, i1 } %88, 0
  %.fca.1.extract.i720 = extractvalue { i1, i64, i1 } %88, 1
  br i1 %.fca.0.extract.i719, label %cond_365_case_1.i, label %cond_365_case_0.i

cond_365_case_0.i:                                ; preds = %86
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %88, 2
  br label %__hugr__.array.__read_bool.3.292.exit

cond_365_case_1.i:                                ; preds = %86
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i720)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i720)
  br label %__hugr__.array.__read_bool.3.292.exit

__hugr__.array.__read_bool.3.292.exit:            ; preds = %cond_365_case_0.i, %cond_365_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_365_case_1.i ], [ %.fca.2.extract.i, %cond_365_case_0.i ]
  %89 = getelementptr inbounds i8, i8* %83, i64 %storemerge762
  %90 = bitcast i8* %89 to i1*
  store i1 %"03.0.i", i1* %90, align 1
  %91 = add nuw nsw i64 %storemerge762, 1
  %exitcond772.not = icmp eq i64 %91, 70
  br i1 %exitcond772.not, label %mask_block_ok.i723, label %86

mask_block_ok.i723:                               ; preds = %__hugr__.array.__read_bool.3.292.exit
  tail call void @heap_free(i8* nonnull %15)
  tail call void @heap_free(i8* %17)
  %92 = getelementptr inbounds i8, i8* %84, i64 8
  %93 = bitcast i8* %92 to i64*
  %94 = load i64, i64* %93, align 4
  %95 = and i64 %94, 63
  store i64 %95, i64* %93, align 4
  %96 = load i64, i64* %85, align 4
  %97 = icmp eq i64 %96, 0
  %98 = icmp eq i64 %95, 0
  %or.cond776 = select i1 %97, i1 %98, i1 false
  br i1 %or.cond776, label %__barray_check_none_borrowed.exit725, label %mask_block_err.i724

__barray_check_none_borrowed.exit725:             ; preds = %mask_block_ok.i723
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %99 = alloca [70 x i1], align 1
  %.sub = getelementptr inbounds [70 x i1], [70 x i1]* %99, i64 0, i64 0
  %100 = bitcast [70 x i1]* %99 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(70) %100, i8 0, i64 70, i1 false)
  store i32 70, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %101 = bitcast i1** %arr_ptr to i8**
  store i8* %83, i8** %101, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @res_bools.B1D99BB9.0, i64 0, i64 0), i64 18, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  ret void

mask_block_err.i724:                              ; preds = %mask_block_ok.i723
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_exit_84:                                     ; preds = %loop_out
  %102 = tail call i8* @heap_alloc(i64 1680)
  %103 = bitcast i8* %102 to { i1, i64, i1 }*
  %104 = tail call i8* @heap_alloc(i64 16)
  %105 = bitcast i8* %104 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %105, i8 -1, i64 16, i1 false)
  %106 = getelementptr inbounds i8, i8* %2, i64 8
  %107 = bitcast i8* %106 to i64*
  br label %123

mask_block_ok.i.i.i:                              ; preds = %cond_exit_472.i
  %108 = load i64, i64* %107, align 4
  %109 = or i64 %108, -64
  store i64 %109, i64* %107, align 4
  %110 = load i64, i64* %3, align 4
  %111 = icmp eq i64 %110, -1
  %112 = icmp eq i64 %109, -1
  %or.cond777 = select i1 %111, i1 %112, i1 false
  br i1 %or.cond777, label %"__hugr__.$measure_array$$n(70).396.exit", label %mask_block_err.i.i.i

"__hugr__.$measure_array$$n(70).396.exit":        ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %113 = tail call i8* @heap_alloc(i64 2240)
  %114 = tail call i8* @heap_alloc(i64 16)
  %115 = bitcast i8* %114 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %115, i8 0, i64 16, i1 false)
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(2240) %113, i8 0, i64 2240, i1 false)
  %116 = getelementptr inbounds i8, i8* %104, i64 8
  %117 = bitcast i8* %116 to i64*
  %118 = load i64, i64* %117, align 4
  %119 = and i64 %118, 63
  store i64 %119, i64* %117, align 4
  %120 = load i64, i64* %105, align 4
  %121 = icmp eq i64 %120, 0
  %122 = icmp eq i64 %119, 0
  %or.cond = select i1 %121, i1 %122, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

123:                                              ; preds = %cond_exit_84, %cond_exit_472.i
  %"422_0.sroa.15.0.i755" = phi i64 [ 0, %cond_exit_84 ], [ %124, %cond_exit_472.i ]
  %124 = add nuw nsw i64 %"422_0.sroa.15.0.i755", 1
  %125 = lshr i64 %"422_0.sroa.15.0.i755", 6
  %126 = getelementptr inbounds i64, i64* %3, i64 %125
  %127 = load i64, i64* %126, align 4
  %128 = and i64 %"422_0.sroa.15.0.i755", 63
  %129 = shl nuw i64 1, %128
  %130 = and i64 %127, %129
  %.not.i99.i.i = icmp eq i64 %130, 0
  br i1 %.not.i99.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %123
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %123
  %131 = xor i64 %127, %129
  store i64 %131, i64* %126, align 4
  %132 = getelementptr inbounds i64, i64* %1, i64 %"422_0.sroa.15.0.i755"
  %133 = load i64, i64* %132, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %133)
  tail call void @___qfree(i64 %133)
  %134 = getelementptr inbounds i64, i64* %105, i64 %125
  %135 = load i64, i64* %134, align 4
  %136 = and i64 %135, %129
  %.not.i.i727 = icmp eq i64 %136, 0
  br i1 %.not.i.i727, label %panic.i.i728, label %cond_exit_472.i

panic.i.i728:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_472.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"486_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %137 = xor i64 %135, %129
  store i64 %137, i64* %134, align 4
  %138 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %103, i64 %"422_0.sroa.15.0.i755"
  store { i1, i64, i1 } %"486_054.fca.1.insert.i", { i1, i64, i1 }* %138, align 4
  %exitcond768.not = icmp eq i64 %124, 70
  br i1 %exitcond768.not, label %mask_block_ok.i.i.i, label %123

finish:                                           ; preds = %cond_exit_20, %loop_out
  %"47_0.0753" = phi i64 [ %139, %loop_out ], [ 0, %cond_exit_20 ]
  %139 = add nuw nsw i64 %"47_0.0753", 1
  %remainder.urem = and i64 %"47_0.0753", 1
  %140 = icmp eq i64 %remainder.urem, 0
  br i1 %140, label %__barray_check_bounds.exit730, label %loop_out

__barray_check_bounds.exit730:                    ; preds = %finish
  %141 = lshr i64 %"47_0.0753", 6
  %142 = getelementptr inbounds i64, i64* %3, i64 %141
  %143 = load i64, i64* %142, align 4
  %144 = and i64 %"47_0.0753", 63
  %145 = shl nuw i64 1, %144
  %146 = and i64 %143, %145
  %.not.i731 = icmp eq i64 %146, 0
  br i1 %.not.i731, label %__barray_check_bounds.exit735, label %panic.i732

panic.i732:                                       ; preds = %__barray_check_bounds.exit730
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit735:                    ; preds = %__barray_check_bounds.exit730
  %147 = xor i64 %143, %145
  store i64 %147, i64* %142, align 4
  %148 = getelementptr inbounds i64, i64* %1, i64 %"47_0.0753"
  %149 = load i64, i64* %148, align 4
  tail call void @___rxy(i64 %149, double 0x400921FB54442D18, double 0.000000e+00)
  %150 = load i64, i64* %142, align 4
  %151 = and i64 %150, %145
  %.not.i736 = icmp eq i64 %151, 0
  br i1 %.not.i736, label %panic.i737, label %__barray_mask_return.exit738

panic.i737:                                       ; preds = %__barray_check_bounds.exit735
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit738:                     ; preds = %__barray_check_bounds.exit735
  %152 = xor i64 %150, %145
  store i64 %152, i64* %142, align 4
  store i64 %149, i64* %148, align 4
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
  tail call fastcc void @__hugr__.main.1()
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
