; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

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
  %exitcond767.not = icmp eq i64 %145, 70
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
  %19 = bitcast i8* %119 to { i1, { i1, i64, i1 } }*
  br label %20

mask_block_err.i:                                 ; preds = %"__hugr__.$measure_array$$n(70).396.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

20:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_301.304.exit
  %storemerge680760 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %39, %__hugr__.const_fun_301.304.exit ]
  %21 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %37, %__hugr__.const_fun_301.304.exit ]
  %22 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %109, i64 %storemerge680760
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
  %25 = icmp ult i64 %21, 70
  br i1 %25, label %26, label %cond_546_case_0.i

26:                                               ; preds = %cond_exit_543.i
  %27 = lshr i64 %21, 6
  %28 = getelementptr inbounds i64, i64* %121, i64 %27
  %29 = load i64, i64* %28, align 4
  %30 = and i64 %21, 63
  %31 = shl nuw i64 1, %30
  %32 = and i64 %29, %31
  %.not.i.i = icmp eq i64 %32, 0
  br i1 %.not.i.i, label %cond_546_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %26
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_546_case_0.i:                                ; preds = %cond_exit_543.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_546_case_1.i:                                ; preds = %26
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %23, i1 %"04.sroa.6.0.i", 2
  %33 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %34 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %19, i64 %21
  %35 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %34, i64 0, i32 0
  %36 = load i1, i1* %35, align 1
  store { i1, { i1, i64, i1 } } %33, { i1, { i1, i64, i1 } }* %34, align 4
  br i1 %36, label %cond_547_case_1.i, label %__hugr__.const_fun_301.304.exit

cond_547_case_1.i:                                ; preds = %cond_546_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_301.304.exit:                  ; preds = %cond_546_case_1.i
  %37 = add nuw nsw i64 %21, 1
  %38 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %16, i64 %storemerge680760
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %38, align 4
  %39 = add nuw nsw i64 %storemerge680760, 1
  %exitcond769.not = icmp eq i64 %39, 70
  br i1 %exitcond769.not, label %mask_block_ok.i701.preheader, label %20

mask_block_ok.i701.preheader:                     ; preds = %__hugr__.const_fun_301.304.exit
  tail call void @heap_free(i8* nonnull %108)
  tail call void @heap_free(i8* %110)
  %40 = load i64, i64* %121, align 4
  %41 = getelementptr inbounds i8, i8* %120, i64 8
  %42 = bitcast i8* %41 to i64*
  %43 = load i64, i64* %42, align 4
  %44 = and i64 %43, 63
  store i64 %44, i64* %42, align 4
  %45 = icmp eq i64 %40, 0
  br i1 %45, label %.mask_block_ok.i701_crit_edge, label %mask_block_err.i702

.mask_block_ok.i701_crit_edge:                    ; preds = %mask_block_ok.i701.preheader
  %.phi.trans.insert = getelementptr inbounds i8, i8* %120, i64 8
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
  br label %52

52:                                               ; preds = %__hugr__.const_fun_297.301.exit.1, %__barray_check_none_borrowed.exit703
  %storemerge667761 = phi i64 [ 0, %__barray_check_none_borrowed.exit703 ], [ %62, %__hugr__.const_fun_297.301.exit.1 ]
  %53 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %19, i64 %storemerge667761
  %54 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %53, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %54, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_297.301.exit, label %cond_588_case_0.i

cond_588_case_0.i:                                ; preds = %__hugr__.const_fun_297.301.exit, %52
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_297.301.exit:                  ; preds = %52
  %55 = extractvalue { i1, { i1, i64, i1 } } %54, 1
  %56 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %49, i64 %storemerge667761
  store { i1, i64, i1 } %55, { i1, i64, i1 }* %56, align 4
  %57 = or i64 %storemerge667761, 1
  %58 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %19, i64 %57
  %59 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %58, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %59, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_297.301.exit.1, label %cond_588_case_0.i

__hugr__.const_fun_297.301.exit.1:                ; preds = %__hugr__.const_fun_297.301.exit
  %60 = extractvalue { i1, { i1, i64, i1 } } %59, 1
  %61 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %49, i64 %57
  store { i1, i64, i1 } %60, { i1, i64, i1 }* %61, align 4
  %62 = add nuw nsw i64 %storemerge667761, 2
  %exitcond770.not.1 = icmp eq i64 %62, 70
  br i1 %exitcond770.not.1, label %63, label %52

63:                                               ; preds = %__hugr__.const_fun_297.301.exit.1
  tail call void @heap_free(i8* nonnull %119)
  tail call void @heap_free(i8* %120)
  %64 = getelementptr inbounds i8, i8* %50, i64 8
  %65 = bitcast i8* %64 to i64*
  br label %__barray_check_bounds.exit709

cond_502_case_0:                                  ; preds = %cond_exit_502
  %66 = load i64, i64* %65, align 4
  %67 = or i64 %66, -64
  store i64 %67, i64* %65, align 4
  %68 = load i64, i64* %51, align 4
  %69 = icmp eq i64 %68, -1
  %70 = icmp eq i64 %67, -1
  %or.cond773 = select i1 %69, i1 %70, i1 false
  br i1 %or.cond773, label %loop_out150, label %mask_block_err.i707

mask_block_err.i707:                              ; preds = %cond_502_case_0
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit709:                    ; preds = %63, %cond_exit_502
  %"499_0.0777" = phi i64 [ 0, %63 ], [ %71, %cond_exit_502 ]
  %71 = add nuw nsw i64 %"499_0.0777", 1
  %72 = lshr i64 %"499_0.0777", 6
  %73 = getelementptr inbounds i64, i64* %51, i64 %72
  %74 = load i64, i64* %73, align 4
  %75 = and i64 %"499_0.0777", 63
  %76 = shl nuw i64 1, %75
  %77 = and i64 %74, %76
  %.not = icmp eq i64 %77, 0
  br i1 %.not, label %__barray_mask_borrow.exit, label %cond_exit_502

__barray_mask_borrow.exit:                        ; preds = %__barray_check_bounds.exit709
  %78 = xor i64 %74, %76
  store i64 %78, i64* %73, align 4
  %79 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %49, i64 %"499_0.0777"
  %80 = load { i1, i64, i1 }, { i1, i64, i1 }* %79, align 4
  %.fca.0.extract399 = extractvalue { i1, i64, i1 } %80, 0
  br i1 %.fca.0.extract399, label %cond_525_case_1, label %cond_exit_502

cond_exit_502:                                    ; preds = %cond_525_case_1, %__barray_mask_borrow.exit, %__barray_check_bounds.exit709
  %81 = icmp ult i64 %"499_0.0777", 69
  br i1 %81, label %__barray_check_bounds.exit709, label %cond_502_case_0

loop_out150:                                      ; preds = %cond_502_case_0
  tail call void @heap_free(i8* %48)
  tail call void @heap_free(i8* nonnull %50)
  %82 = getelementptr inbounds i8, i8* %17, i64 8
  %83 = bitcast i8* %82 to i64*
  %84 = load i64, i64* %83, align 4
  %85 = and i64 %84, 63
  store i64 %85, i64* %83, align 4
  %86 = load i64, i64* %18, align 4
  %87 = icmp eq i64 %86, 0
  %88 = icmp eq i64 %85, 0
  %or.cond774 = select i1 %87, i1 %88, i1 false
  br i1 %or.cond774, label %__barray_check_none_borrowed.exit718, label %mask_block_err.i717

__barray_check_none_borrowed.exit718:             ; preds = %loop_out150
  %89 = tail call i8* @heap_alloc(i64 70)
  %90 = tail call i8* @heap_alloc(i64 16)
  %91 = bitcast i8* %90 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %91, i8 0, i64 16, i1 false)
  br label %92

mask_block_err.i717:                              ; preds = %loop_out150
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_525_case_1:                                  ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract400 = extractvalue { i1, i64, i1 } %80, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract400)
  br label %cond_exit_502

92:                                               ; preds = %__barray_check_none_borrowed.exit718, %__hugr__.array.__read_bool.3.292.exit
  %storemerge762 = phi i64 [ 0, %__barray_check_none_borrowed.exit718 ], [ %97, %__hugr__.array.__read_bool.3.292.exit ]
  %93 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %16, i64 %storemerge762
  %94 = load { i1, i64, i1 }, { i1, i64, i1 }* %93, align 4
  %.fca.0.extract.i719 = extractvalue { i1, i64, i1 } %94, 0
  %.fca.1.extract.i720 = extractvalue { i1, i64, i1 } %94, 1
  br i1 %.fca.0.extract.i719, label %cond_365_case_1.i, label %cond_365_case_0.i

cond_365_case_0.i:                                ; preds = %92
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %94, 2
  br label %__hugr__.array.__read_bool.3.292.exit

cond_365_case_1.i:                                ; preds = %92
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i720)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i720)
  br label %__hugr__.array.__read_bool.3.292.exit

__hugr__.array.__read_bool.3.292.exit:            ; preds = %cond_365_case_0.i, %cond_365_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_365_case_1.i ], [ %.fca.2.extract.i, %cond_365_case_0.i ]
  %95 = getelementptr inbounds i8, i8* %89, i64 %storemerge762
  %96 = bitcast i8* %95 to i1*
  store i1 %"03.0.i", i1* %96, align 1
  %97 = add nuw nsw i64 %storemerge762, 1
  %exitcond771.not = icmp eq i64 %97, 70
  br i1 %exitcond771.not, label %mask_block_ok.i723, label %92

mask_block_ok.i723:                               ; preds = %__hugr__.array.__read_bool.3.292.exit
  tail call void @heap_free(i8* nonnull %15)
  tail call void @heap_free(i8* %17)
  %98 = getelementptr inbounds i8, i8* %90, i64 8
  %99 = bitcast i8* %98 to i64*
  %100 = load i64, i64* %99, align 4
  %101 = and i64 %100, 63
  store i64 %101, i64* %99, align 4
  %102 = load i64, i64* %91, align 4
  %103 = icmp eq i64 %102, 0
  %104 = icmp eq i64 %101, 0
  %or.cond775 = select i1 %103, i1 %104, i1 false
  br i1 %or.cond775, label %__barray_check_none_borrowed.exit725, label %mask_block_err.i724

__barray_check_none_borrowed.exit725:             ; preds = %mask_block_ok.i723
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %105 = alloca [70 x i1], align 1
  %.sub = getelementptr inbounds [70 x i1], [70 x i1]* %105, i64 0, i64 0
  %106 = bitcast [70 x i1]* %105 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(70) %106, i8 0, i64 70, i1 false)
  store i32 70, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %107 = bitcast i1** %arr_ptr to i8**
  store i8* %89, i8** %107, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @res_bools.B1D99BB9.0, i64 0, i64 0), i64 18, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  ret void

mask_block_err.i724:                              ; preds = %mask_block_ok.i723
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_exit_84:                                     ; preds = %loop_out
  %108 = tail call i8* @heap_alloc(i64 1680)
  %109 = bitcast i8* %108 to { i1, i64, i1 }*
  %110 = tail call i8* @heap_alloc(i64 16)
  %111 = bitcast i8* %110 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %111, i8 -1, i64 16, i1 false)
  %112 = getelementptr inbounds i8, i8* %2, i64 8
  %113 = bitcast i8* %112 to i64*
  br label %129

mask_block_ok.i.i.i:                              ; preds = %cond_exit_472.i
  %114 = load i64, i64* %113, align 4
  %115 = or i64 %114, -64
  store i64 %115, i64* %113, align 4
  %116 = load i64, i64* %3, align 4
  %117 = icmp eq i64 %116, -1
  %118 = icmp eq i64 %115, -1
  %or.cond776 = select i1 %117, i1 %118, i1 false
  br i1 %or.cond776, label %"__hugr__.$measure_array$$n(70).396.exit", label %mask_block_err.i.i.i

"__hugr__.$measure_array$$n(70).396.exit":        ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %119 = tail call i8* @heap_alloc(i64 2240)
  %120 = tail call i8* @heap_alloc(i64 16)
  %121 = bitcast i8* %120 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %121, i8 0, i64 16, i1 false)
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(2240) %119, i8 0, i64 2240, i1 false)
  %122 = getelementptr inbounds i8, i8* %110, i64 8
  %123 = bitcast i8* %122 to i64*
  %124 = load i64, i64* %123, align 4
  %125 = and i64 %124, 63
  store i64 %125, i64* %123, align 4
  %126 = load i64, i64* %111, align 4
  %127 = icmp eq i64 %126, 0
  %128 = icmp eq i64 %125, 0
  %or.cond = select i1 %127, i1 %128, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

129:                                              ; preds = %cond_exit_84, %cond_exit_472.i
  %"422_0.sroa.15.0.i755" = phi i64 [ 0, %cond_exit_84 ], [ %130, %cond_exit_472.i ]
  %130 = add nuw nsw i64 %"422_0.sroa.15.0.i755", 1
  %131 = lshr i64 %"422_0.sroa.15.0.i755", 6
  %132 = getelementptr inbounds i64, i64* %3, i64 %131
  %133 = load i64, i64* %132, align 4
  %134 = and i64 %"422_0.sroa.15.0.i755", 63
  %135 = shl nuw i64 1, %134
  %136 = and i64 %133, %135
  %.not.i99.i.i = icmp eq i64 %136, 0
  br i1 %.not.i99.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %129
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %129
  %137 = xor i64 %133, %135
  store i64 %137, i64* %132, align 4
  %138 = getelementptr inbounds i64, i64* %1, i64 %"422_0.sroa.15.0.i755"
  %139 = load i64, i64* %138, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %139)
  tail call void @___qfree(i64 %139)
  %140 = getelementptr inbounds i64, i64* %111, i64 %131
  %141 = load i64, i64* %140, align 4
  %142 = and i64 %141, %135
  %.not.i.i727 = icmp eq i64 %142, 0
  br i1 %.not.i.i727, label %panic.i.i728, label %cond_exit_472.i

panic.i.i728:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_472.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"486_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %143 = xor i64 %141, %135
  store i64 %143, i64* %140, align 4
  %144 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %109, i64 %"422_0.sroa.15.0.i755"
  store { i1, i64, i1 } %"486_054.fca.1.insert.i", { i1, i64, i1 }* %144, align 4
  %exitcond768.not = icmp eq i64 %130, 70
  br i1 %exitcond768.not, label %mask_block_ok.i.i.i, label %129

finish:                                           ; preds = %cond_exit_20, %loop_out
  %"47_0.0753" = phi i64 [ %145, %loop_out ], [ 0, %cond_exit_20 ]
  %145 = add nuw nsw i64 %"47_0.0753", 1
  %remainder.urem = and i64 %"47_0.0753", 1
  %146 = icmp eq i64 %remainder.urem, 0
  br i1 %146, label %__barray_check_bounds.exit730, label %loop_out

__barray_check_bounds.exit730:                    ; preds = %finish
  %147 = lshr i64 %"47_0.0753", 6
  %148 = getelementptr inbounds i64, i64* %3, i64 %147
  %149 = load i64, i64* %148, align 4
  %150 = and i64 %"47_0.0753", 63
  %151 = shl nuw i64 1, %150
  %152 = and i64 %149, %151
  %.not.i731 = icmp eq i64 %152, 0
  br i1 %.not.i731, label %__barray_check_bounds.exit735, label %panic.i732

panic.i732:                                       ; preds = %__barray_check_bounds.exit730
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit735:                    ; preds = %__barray_check_bounds.exit730
  %153 = xor i64 %149, %151
  store i64 %153, i64* %148, align 4
  %154 = getelementptr inbounds i64, i64* %1, i64 %"47_0.0753"
  %155 = load i64, i64* %154, align 4
  tail call void @___rxy(i64 %155, double 0x400921FB54442D18, double 0.000000e+00)
  %156 = load i64, i64* %148, align 4
  %157 = and i64 %156, %151
  %.not.i736 = icmp eq i64 %157, 0
  br i1 %.not.i736, label %panic.i737, label %__barray_mask_return.exit738

panic.i737:                                       ; preds = %__barray_check_bounds.exit735
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit738:                     ; preds = %__barray_check_bounds.exit735
  %158 = xor i64 %156, %151
  store i64 %158, i64* %148, align 4
  store i64 %155, i64* %154, align 4
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
