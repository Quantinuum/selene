; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@res_measuremen.F30240EB.0 = private constant [26 x i8] c"\19USER:BOOLARR:measurements"
@e_tket.rotat.20D0216B.0 = private constant [55 x i8] c"6EXIT:INT:tket.rotation.from_halfturns_unchecked failed"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call i8* @heap_alloc(i64 64)
  %1 = bitcast i8* %0 to i64*
  %2 = tail call i8* @heap_alloc(i64 8)
  %3 = bitcast i8* %2 to i64*
  store i64 -1, i64* %3, align 1
  br label %cond_20_case_1

cond_exit_174.loopexit:                           ; preds = %__barray_mask_return.exit951
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %exitcond993.not = icmp eq i64 %4, 8
  br i1 %exitcond993.not, label %cond_exit_91, label %__barray_check_bounds.exit

__barray_check_bounds.exit:                       ; preds = %cond_exit_20, %cond_exit_174.loopexit
  %indvars.iv = phi i64 [ %indvars.iv.next, %cond_exit_174.loopexit ], [ 7, %cond_exit_20 ]
  %"45_0.0976" = phi i64 [ %4, %cond_exit_174.loopexit ], [ 0, %cond_exit_20 ]
  %4 = add nuw nsw i64 %"45_0.0976", 1
  %5 = lshr i64 %"45_0.0976", 6
  %6 = getelementptr inbounds i64, i64* %3, i64 %5
  %7 = load i64, i64* %6, align 4
  %8 = shl nuw nsw i64 1, %"45_0.0976"
  %9 = and i64 %7, %8
  %.not.i = icmp eq i64 %9, 0
  br i1 %.not.i, label %__barray_check_bounds.exit873, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit873:                    ; preds = %__barray_check_bounds.exit
  %10 = xor i64 %7, %8
  store i64 %10, i64* %6, align 4
  %11 = getelementptr inbounds i64, i64* %1, i64 %"45_0.0976"
  %12 = load i64, i64* %11, align 4
  tail call void @___rxy(i64 %12, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %12, double 0x400921FB54442D18)
  %13 = load i64, i64* %6, align 4
  %14 = and i64 %13, %8
  %.not.i874 = icmp eq i64 %14, 0
  br i1 %.not.i874, label %panic.i875, label %__barray_mask_return.exit

panic.i875:                                       ; preds = %__barray_check_bounds.exit873
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit873
  %15 = xor i64 %13, %8
  store i64 %15, i64* %6, align 4
  store i64 %12, i64* %11, align 4
  %.not999 = icmp eq i64 %"45_0.0976", 7
  br i1 %.not999, label %cond_exit_91, label %__barray_check_bounds.exit932

cond_20_case_1:                                   ; preds = %alloca_block, %cond_exit_20
  %"15_0.sroa.0.0974" = phi i64 [ 0, %alloca_block ], [ %16, %cond_exit_20 ]
  %16 = add nuw nsw i64 %"15_0.sroa.0.0974", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.i, label %id_bb.i, label %reset_bb.i

reset_bb.i:                                       ; preds = %cond_20_case_1
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %cond_20_case_1
  %17 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %18 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %17
  %.fca.0.extract.i = extractvalue { i1, i64 } %18, 0
  br i1 %.fca.0.extract.i, label %__barray_check_bounds.exit889, label %cond_441_case_0.i

cond_441_case_0.i:                                ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit889:                    ; preds = %id_bb.i
  %19 = lshr i64 %"15_0.sroa.0.0974", 6
  %20 = getelementptr inbounds i64, i64* %3, i64 %19
  %21 = load i64, i64* %20, align 4
  %22 = shl nuw nsw i64 1, %"15_0.sroa.0.0974"
  %23 = and i64 %21, %22
  %.not.i890 = icmp eq i64 %23, 0
  br i1 %.not.i890, label %panic.i891, label %cond_exit_20

panic.i891:                                       ; preds = %__barray_check_bounds.exit889
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_20:                                     ; preds = %__barray_check_bounds.exit889
  %.fca.1.extract.i = extractvalue { i1, i64 } %18, 1
  %24 = xor i64 %21, %22
  store i64 %24, i64* %20, align 4
  %25 = getelementptr inbounds i64, i64* %1, i64 %"15_0.sroa.0.0974"
  store i64 %.fca.1.extract.i, i64* %25, align 4
  %exitcond.not = icmp eq i64 %16, 8
  br i1 %exitcond.not, label %__barray_check_bounds.exit, label %cond_20_case_1

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$measure_array$$n(8).508.exit"
  %26 = tail call i8* @heap_alloc(i64 192)
  %27 = bitcast i8* %26 to { i1, i64, i1 }*
  %28 = tail call i8* @heap_alloc(i64 8)
  %29 = bitcast i8* %28 to i64*
  store i64 0, i64* %29, align 1
  %30 = bitcast i8* %215 to { i1, { i1, i64, i1 } }*
  br label %31

mask_block_err.i:                                 ; preds = %"__hugr__.$measure_array$$n(8).508.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

31:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_324.327.exit
  %storemerge870983 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %49, %__hugr__.const_fun_324.327.exit ]
  %32 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %47, %__hugr__.const_fun_324.327.exit ]
  %33 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %209, i64 %storemerge870983
  %34 = load { i1, i64, i1 }, { i1, i64, i1 }* %33, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %34, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %34, 1
  br i1 %.fca.0.extract118.i, label %cond_693_case_1.i, label %cond_exit_693.i

cond_693_case_1.i:                                ; preds = %31
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %35 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %cond_exit_693.i

cond_exit_693.i:                                  ; preds = %cond_693_case_1.i, %31
  %.pn.i = phi { i1, i64, i1 } [ %35, %cond_693_case_1.i ], [ %34, %31 ]
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %exitcond995.not = icmp eq i64 %storemerge870983, 8
  br i1 %exitcond995.not, label %cond_696_case_0.i, label %36

36:                                               ; preds = %cond_exit_693.i
  %37 = lshr i64 %32, 6
  %38 = getelementptr inbounds i64, i64* %217, i64 %37
  %39 = load i64, i64* %38, align 4
  %40 = and i64 %32, 63
  %41 = shl nuw i64 1, %40
  %42 = and i64 %39, %41
  %.not.i.i = icmp eq i64 %42, 0
  br i1 %.not.i.i, label %cond_696_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %36
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_696_case_0.i:                                ; preds = %cond_exit_693.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_696_case_1.i:                                ; preds = %36
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %34, i1 %"04.sroa.6.0.i", 2
  %43 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %44 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %30, i64 %32
  %45 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %44, i64 0, i32 0
  %46 = load i1, i1* %45, align 1
  store { i1, { i1, i64, i1 } } %43, { i1, { i1, i64, i1 } }* %44, align 4
  br i1 %46, label %cond_697_case_1.i, label %__hugr__.const_fun_324.327.exit

cond_697_case_1.i:                                ; preds = %cond_696_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_324.327.exit:                  ; preds = %cond_696_case_1.i
  %47 = add nuw nsw i64 %32, 1
  %48 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %27, i64 %storemerge870983
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %48, align 4
  %49 = add nuw nsw i64 %storemerge870983, 1
  %exitcond996.not = icmp eq i64 %49, 8
  br i1 %exitcond996.not, label %mask_block_ok.i896, label %31

mask_block_ok.i896:                               ; preds = %__hugr__.const_fun_324.327.exit
  tail call void @heap_free(i8* nonnull %208)
  tail call void @heap_free(i8* %210)
  %50 = load i64, i64* %217, align 4
  %51 = and i64 %50, 255
  store i64 %51, i64* %217, align 4
  %52 = icmp eq i64 %51, 0
  br i1 %52, label %__barray_check_none_borrowed.exit898, label %mask_block_err.i897

mask_block_err.i897:                              ; preds = %mask_block_ok.i896
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit898:             ; preds = %mask_block_ok.i896
  %53 = tail call i8* @heap_alloc(i64 192)
  %54 = bitcast i8* %53 to { i1, i64, i1 }*
  %55 = tail call i8* @heap_alloc(i64 8)
  %56 = bitcast i8* %55 to i64*
  store i64 0, i64* %56, align 1
  %57 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %30, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %57, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_319.324.exit, label %cond_738_case_0.i

cond_738_case_0.i:                                ; preds = %__hugr__.const_fun_319.324.exit.6, %__hugr__.const_fun_319.324.exit.5, %__hugr__.const_fun_319.324.exit.4, %__hugr__.const_fun_319.324.exit.3, %__hugr__.const_fun_319.324.exit.2, %__hugr__.const_fun_319.324.exit.1, %__hugr__.const_fun_319.324.exit, %__barray_check_none_borrowed.exit898
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_319.324.exit:                  ; preds = %__barray_check_none_borrowed.exit898
  %58 = extractvalue { i1, { i1, i64, i1 } } %57, 1
  store { i1, i64, i1 } %58, { i1, i64, i1 }* %54, align 4
  %59 = getelementptr inbounds i8, i8* %215, i64 32
  %60 = bitcast i8* %59 to { i1, { i1, i64, i1 } }*
  %61 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %60, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %61, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_319.324.exit.1, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.1:                ; preds = %__hugr__.const_fun_319.324.exit
  %62 = extractvalue { i1, { i1, i64, i1 } } %61, 1
  %63 = getelementptr inbounds i8, i8* %53, i64 24
  %64 = bitcast i8* %63 to { i1, i64, i1 }*
  store { i1, i64, i1 } %62, { i1, i64, i1 }* %64, align 4
  %65 = getelementptr inbounds i8, i8* %215, i64 64
  %66 = bitcast i8* %65 to { i1, { i1, i64, i1 } }*
  %67 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %66, align 4
  %.fca.0.extract11.i.2 = extractvalue { i1, { i1, i64, i1 } } %67, 0
  br i1 %.fca.0.extract11.i.2, label %__hugr__.const_fun_319.324.exit.2, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.2:                ; preds = %__hugr__.const_fun_319.324.exit.1
  %68 = extractvalue { i1, { i1, i64, i1 } } %67, 1
  %69 = getelementptr inbounds i8, i8* %53, i64 48
  %70 = bitcast i8* %69 to { i1, i64, i1 }*
  store { i1, i64, i1 } %68, { i1, i64, i1 }* %70, align 4
  %71 = getelementptr inbounds i8, i8* %215, i64 96
  %72 = bitcast i8* %71 to { i1, { i1, i64, i1 } }*
  %73 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %72, align 4
  %.fca.0.extract11.i.3 = extractvalue { i1, { i1, i64, i1 } } %73, 0
  br i1 %.fca.0.extract11.i.3, label %__hugr__.const_fun_319.324.exit.3, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.3:                ; preds = %__hugr__.const_fun_319.324.exit.2
  %74 = extractvalue { i1, { i1, i64, i1 } } %73, 1
  %75 = getelementptr inbounds i8, i8* %53, i64 72
  %76 = bitcast i8* %75 to { i1, i64, i1 }*
  store { i1, i64, i1 } %74, { i1, i64, i1 }* %76, align 4
  %77 = getelementptr inbounds i8, i8* %215, i64 128
  %78 = bitcast i8* %77 to { i1, { i1, i64, i1 } }*
  %79 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %78, align 4
  %.fca.0.extract11.i.4 = extractvalue { i1, { i1, i64, i1 } } %79, 0
  br i1 %.fca.0.extract11.i.4, label %__hugr__.const_fun_319.324.exit.4, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.4:                ; preds = %__hugr__.const_fun_319.324.exit.3
  %80 = extractvalue { i1, { i1, i64, i1 } } %79, 1
  %81 = getelementptr inbounds i8, i8* %53, i64 96
  %82 = bitcast i8* %81 to { i1, i64, i1 }*
  store { i1, i64, i1 } %80, { i1, i64, i1 }* %82, align 4
  %83 = getelementptr inbounds i8, i8* %215, i64 160
  %84 = bitcast i8* %83 to { i1, { i1, i64, i1 } }*
  %85 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %84, align 4
  %.fca.0.extract11.i.5 = extractvalue { i1, { i1, i64, i1 } } %85, 0
  br i1 %.fca.0.extract11.i.5, label %__hugr__.const_fun_319.324.exit.5, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.5:                ; preds = %__hugr__.const_fun_319.324.exit.4
  %86 = extractvalue { i1, { i1, i64, i1 } } %85, 1
  %87 = getelementptr inbounds i8, i8* %53, i64 120
  %88 = bitcast i8* %87 to { i1, i64, i1 }*
  store { i1, i64, i1 } %86, { i1, i64, i1 }* %88, align 4
  %89 = getelementptr inbounds i8, i8* %215, i64 192
  %90 = bitcast i8* %89 to { i1, { i1, i64, i1 } }*
  %91 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %90, align 4
  %.fca.0.extract11.i.6 = extractvalue { i1, { i1, i64, i1 } } %91, 0
  br i1 %.fca.0.extract11.i.6, label %__hugr__.const_fun_319.324.exit.6, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.6:                ; preds = %__hugr__.const_fun_319.324.exit.5
  %92 = extractvalue { i1, { i1, i64, i1 } } %91, 1
  %93 = getelementptr inbounds i8, i8* %53, i64 144
  %94 = bitcast i8* %93 to { i1, i64, i1 }*
  store { i1, i64, i1 } %92, { i1, i64, i1 }* %94, align 4
  %95 = getelementptr inbounds i8, i8* %215, i64 224
  %96 = bitcast i8* %95 to { i1, { i1, i64, i1 } }*
  %97 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %96, align 4
  %.fca.0.extract11.i.7 = extractvalue { i1, { i1, i64, i1 } } %97, 0
  br i1 %.fca.0.extract11.i.7, label %__hugr__.const_fun_319.324.exit.7, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.7:                ; preds = %__hugr__.const_fun_319.324.exit.6
  %98 = extractvalue { i1, { i1, i64, i1 } } %97, 1
  %99 = getelementptr inbounds i8, i8* %53, i64 168
  %100 = bitcast i8* %99 to { i1, i64, i1 }*
  store { i1, i64, i1 } %98, { i1, i64, i1 }* %100, align 4
  tail call void @heap_free(i8* nonnull %215)
  tail call void @heap_free(i8* nonnull %216)
  %101 = load i64, i64* %56, align 4
  %102 = and i64 %101, 1
  %.not = icmp eq i64 %102, 0
  br i1 %.not, label %__barray_mask_borrow.exit909, label %cond_exit_652

mask_block_err.i902:                              ; preds = %cond_exit_652.7
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit909:                     ; preds = %__hugr__.const_fun_319.324.exit.7
  %103 = xor i64 %101, 1
  store i64 %103, i64* %56, align 4
  %104 = load { i1, i64, i1 }, { i1, i64, i1 }* %54, align 4
  %.fca.0.extract608 = extractvalue { i1, i64, i1 } %104, 0
  br i1 %.fca.0.extract608, label %cond_675_case_1, label %cond_exit_652

cond_exit_652:                                    ; preds = %cond_675_case_1, %__barray_mask_borrow.exit909, %__hugr__.const_fun_319.324.exit.7
  %105 = load i64, i64* %56, align 4
  %106 = and i64 %105, 2
  %.not.1 = icmp eq i64 %106, 0
  br i1 %.not.1, label %__barray_mask_borrow.exit909.1, label %cond_exit_652.1

__barray_mask_borrow.exit909.1:                   ; preds = %cond_exit_652
  %107 = xor i64 %105, 2
  store i64 %107, i64* %56, align 4
  %108 = getelementptr inbounds i8, i8* %53, i64 24
  %109 = bitcast i8* %108 to { i1, i64, i1 }*
  %110 = load { i1, i64, i1 }, { i1, i64, i1 }* %109, align 4
  %.fca.0.extract608.1 = extractvalue { i1, i64, i1 } %110, 0
  br i1 %.fca.0.extract608.1, label %cond_675_case_1.1, label %cond_exit_652.1

cond_675_case_1.1:                                ; preds = %__barray_mask_borrow.exit909.1
  %.fca.1.extract609.1 = extractvalue { i1, i64, i1 } %110, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.1)
  br label %cond_exit_652.1

cond_exit_652.1:                                  ; preds = %cond_675_case_1.1, %__barray_mask_borrow.exit909.1, %cond_exit_652
  %111 = load i64, i64* %56, align 4
  %112 = and i64 %111, 4
  %.not.2 = icmp eq i64 %112, 0
  br i1 %.not.2, label %__barray_mask_borrow.exit909.2, label %cond_exit_652.2

__barray_mask_borrow.exit909.2:                   ; preds = %cond_exit_652.1
  %113 = xor i64 %111, 4
  store i64 %113, i64* %56, align 4
  %114 = getelementptr inbounds i8, i8* %53, i64 48
  %115 = bitcast i8* %114 to { i1, i64, i1 }*
  %116 = load { i1, i64, i1 }, { i1, i64, i1 }* %115, align 4
  %.fca.0.extract608.2 = extractvalue { i1, i64, i1 } %116, 0
  br i1 %.fca.0.extract608.2, label %cond_675_case_1.2, label %cond_exit_652.2

cond_675_case_1.2:                                ; preds = %__barray_mask_borrow.exit909.2
  %.fca.1.extract609.2 = extractvalue { i1, i64, i1 } %116, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.2)
  br label %cond_exit_652.2

cond_exit_652.2:                                  ; preds = %cond_675_case_1.2, %__barray_mask_borrow.exit909.2, %cond_exit_652.1
  %117 = load i64, i64* %56, align 4
  %118 = and i64 %117, 8
  %.not.3 = icmp eq i64 %118, 0
  br i1 %.not.3, label %__barray_mask_borrow.exit909.3, label %cond_exit_652.3

__barray_mask_borrow.exit909.3:                   ; preds = %cond_exit_652.2
  %119 = xor i64 %117, 8
  store i64 %119, i64* %56, align 4
  %120 = getelementptr inbounds i8, i8* %53, i64 72
  %121 = bitcast i8* %120 to { i1, i64, i1 }*
  %122 = load { i1, i64, i1 }, { i1, i64, i1 }* %121, align 4
  %.fca.0.extract608.3 = extractvalue { i1, i64, i1 } %122, 0
  br i1 %.fca.0.extract608.3, label %cond_675_case_1.3, label %cond_exit_652.3

cond_675_case_1.3:                                ; preds = %__barray_mask_borrow.exit909.3
  %.fca.1.extract609.3 = extractvalue { i1, i64, i1 } %122, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.3)
  br label %cond_exit_652.3

cond_exit_652.3:                                  ; preds = %cond_675_case_1.3, %__barray_mask_borrow.exit909.3, %cond_exit_652.2
  %123 = load i64, i64* %56, align 4
  %124 = and i64 %123, 16
  %.not.4 = icmp eq i64 %124, 0
  br i1 %.not.4, label %__barray_mask_borrow.exit909.4, label %cond_exit_652.4

__barray_mask_borrow.exit909.4:                   ; preds = %cond_exit_652.3
  %125 = xor i64 %123, 16
  store i64 %125, i64* %56, align 4
  %126 = getelementptr inbounds i8, i8* %53, i64 96
  %127 = bitcast i8* %126 to { i1, i64, i1 }*
  %128 = load { i1, i64, i1 }, { i1, i64, i1 }* %127, align 4
  %.fca.0.extract608.4 = extractvalue { i1, i64, i1 } %128, 0
  br i1 %.fca.0.extract608.4, label %cond_675_case_1.4, label %cond_exit_652.4

cond_675_case_1.4:                                ; preds = %__barray_mask_borrow.exit909.4
  %.fca.1.extract609.4 = extractvalue { i1, i64, i1 } %128, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.4)
  br label %cond_exit_652.4

cond_exit_652.4:                                  ; preds = %cond_675_case_1.4, %__barray_mask_borrow.exit909.4, %cond_exit_652.3
  %129 = load i64, i64* %56, align 4
  %130 = and i64 %129, 32
  %.not.5 = icmp eq i64 %130, 0
  br i1 %.not.5, label %__barray_mask_borrow.exit909.5, label %cond_exit_652.5

__barray_mask_borrow.exit909.5:                   ; preds = %cond_exit_652.4
  %131 = xor i64 %129, 32
  store i64 %131, i64* %56, align 4
  %132 = getelementptr inbounds i8, i8* %53, i64 120
  %133 = bitcast i8* %132 to { i1, i64, i1 }*
  %134 = load { i1, i64, i1 }, { i1, i64, i1 }* %133, align 4
  %.fca.0.extract608.5 = extractvalue { i1, i64, i1 } %134, 0
  br i1 %.fca.0.extract608.5, label %cond_675_case_1.5, label %cond_exit_652.5

cond_675_case_1.5:                                ; preds = %__barray_mask_borrow.exit909.5
  %.fca.1.extract609.5 = extractvalue { i1, i64, i1 } %134, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.5)
  br label %cond_exit_652.5

cond_exit_652.5:                                  ; preds = %cond_675_case_1.5, %__barray_mask_borrow.exit909.5, %cond_exit_652.4
  %135 = load i64, i64* %56, align 4
  %136 = and i64 %135, 64
  %.not.6 = icmp eq i64 %136, 0
  br i1 %.not.6, label %__barray_mask_borrow.exit909.6, label %cond_exit_652.6

__barray_mask_borrow.exit909.6:                   ; preds = %cond_exit_652.5
  %137 = xor i64 %135, 64
  store i64 %137, i64* %56, align 4
  %138 = getelementptr inbounds i8, i8* %53, i64 144
  %139 = bitcast i8* %138 to { i1, i64, i1 }*
  %140 = load { i1, i64, i1 }, { i1, i64, i1 }* %139, align 4
  %.fca.0.extract608.6 = extractvalue { i1, i64, i1 } %140, 0
  br i1 %.fca.0.extract608.6, label %cond_675_case_1.6, label %cond_exit_652.6

cond_675_case_1.6:                                ; preds = %__barray_mask_borrow.exit909.6
  %.fca.1.extract609.6 = extractvalue { i1, i64, i1 } %140, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.6)
  br label %cond_exit_652.6

cond_exit_652.6:                                  ; preds = %cond_675_case_1.6, %__barray_mask_borrow.exit909.6, %cond_exit_652.5
  %141 = load i64, i64* %56, align 4
  %142 = and i64 %141, 128
  %.not.7 = icmp eq i64 %142, 0
  br i1 %.not.7, label %__barray_mask_borrow.exit909.7, label %cond_exit_652.7

__barray_mask_borrow.exit909.7:                   ; preds = %cond_exit_652.6
  %143 = xor i64 %141, 128
  store i64 %143, i64* %56, align 4
  %144 = getelementptr inbounds i8, i8* %53, i64 168
  %145 = bitcast i8* %144 to { i1, i64, i1 }*
  %146 = load { i1, i64, i1 }, { i1, i64, i1 }* %145, align 4
  %.fca.0.extract608.7 = extractvalue { i1, i64, i1 } %146, 0
  br i1 %.fca.0.extract608.7, label %cond_675_case_1.7, label %cond_exit_652.7

cond_675_case_1.7:                                ; preds = %__barray_mask_borrow.exit909.7
  %.fca.1.extract609.7 = extractvalue { i1, i64, i1 } %146, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.7)
  br label %cond_exit_652.7

cond_exit_652.7:                                  ; preds = %cond_675_case_1.7, %__barray_mask_borrow.exit909.7, %cond_exit_652.6
  %147 = load i64, i64* %56, align 4
  %148 = or i64 %147, -256
  store i64 %148, i64* %56, align 4
  %149 = icmp eq i64 %148, -1
  br i1 %149, label %loop_out161, label %mask_block_err.i902

loop_out161:                                      ; preds = %cond_exit_652.7
  tail call void @heap_free(i8* %53)
  tail call void @heap_free(i8* nonnull %55)
  %150 = load i64, i64* %29, align 4
  %151 = and i64 %150, 255
  store i64 %151, i64* %29, align 4
  %152 = icmp eq i64 %151, 0
  br i1 %152, label %__barray_check_none_borrowed.exit914, label %mask_block_err.i913

__barray_check_none_borrowed.exit914:             ; preds = %loop_out161
  %153 = tail call i8* @heap_alloc(i64 8)
  %154 = tail call i8* @heap_alloc(i64 8)
  %155 = bitcast i8* %154 to i64*
  store i64 0, i64* %155, align 1
  %156 = load { i1, i64, i1 }, { i1, i64, i1 }* %27, align 4
  %.fca.0.extract.i915 = extractvalue { i1, i64, i1 } %156, 0
  %.fca.1.extract.i916 = extractvalue { i1, i64, i1 } %156, 1
  br i1 %.fca.0.extract.i915, label %cond_426_case_1.i, label %cond_426_case_0.i

mask_block_err.i913:                              ; preds = %loop_out161
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_675_case_1:                                  ; preds = %__barray_mask_borrow.exit909
  %.fca.1.extract609 = extractvalue { i1, i64, i1 } %104, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609)
  br label %cond_exit_652

cond_426_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit914
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %156, 2
  br label %__hugr__.array.__read_bool.3.338.exit

cond_426_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit914
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916)
  br label %__hugr__.array.__read_bool.3.338.exit

__hugr__.array.__read_bool.3.338.exit:            ; preds = %cond_426_case_0.i, %cond_426_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_426_case_1.i ], [ %.fca.2.extract.i, %cond_426_case_0.i ]
  %157 = bitcast i8* %153 to i1*
  store i1 %"03.0.i", i1* %157, align 1
  %158 = getelementptr inbounds i8, i8* %26, i64 24
  %159 = bitcast i8* %158 to { i1, i64, i1 }*
  %160 = load { i1, i64, i1 }, { i1, i64, i1 }* %159, align 4
  %.fca.0.extract.i915.1 = extractvalue { i1, i64, i1 } %160, 0
  %.fca.1.extract.i916.1 = extractvalue { i1, i64, i1 } %160, 1
  br i1 %.fca.0.extract.i915.1, label %cond_426_case_1.i.1, label %cond_426_case_0.i.1

cond_426_case_0.i.1:                              ; preds = %__hugr__.array.__read_bool.3.338.exit
  %.fca.2.extract.i.1 = extractvalue { i1, i64, i1 } %160, 2
  br label %__hugr__.array.__read_bool.3.338.exit.1

cond_426_case_1.i.1:                              ; preds = %__hugr__.array.__read_bool.3.338.exit
  %read_bool.i.1 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.1)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.1)
  br label %__hugr__.array.__read_bool.3.338.exit.1

__hugr__.array.__read_bool.3.338.exit.1:          ; preds = %cond_426_case_1.i.1, %cond_426_case_0.i.1
  %"03.0.i.1" = phi i1 [ %read_bool.i.1, %cond_426_case_1.i.1 ], [ %.fca.2.extract.i.1, %cond_426_case_0.i.1 ]
  %161 = getelementptr inbounds i8, i8* %153, i64 1
  %162 = bitcast i8* %161 to i1*
  store i1 %"03.0.i.1", i1* %162, align 1
  %163 = getelementptr inbounds i8, i8* %26, i64 48
  %164 = bitcast i8* %163 to { i1, i64, i1 }*
  %165 = load { i1, i64, i1 }, { i1, i64, i1 }* %164, align 4
  %.fca.0.extract.i915.2 = extractvalue { i1, i64, i1 } %165, 0
  %.fca.1.extract.i916.2 = extractvalue { i1, i64, i1 } %165, 1
  br i1 %.fca.0.extract.i915.2, label %cond_426_case_1.i.2, label %cond_426_case_0.i.2

cond_426_case_0.i.2:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.1
  %.fca.2.extract.i.2 = extractvalue { i1, i64, i1 } %165, 2
  br label %__hugr__.array.__read_bool.3.338.exit.2

cond_426_case_1.i.2:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.1
  %read_bool.i.2 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.2)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.2)
  br label %__hugr__.array.__read_bool.3.338.exit.2

__hugr__.array.__read_bool.3.338.exit.2:          ; preds = %cond_426_case_1.i.2, %cond_426_case_0.i.2
  %"03.0.i.2" = phi i1 [ %read_bool.i.2, %cond_426_case_1.i.2 ], [ %.fca.2.extract.i.2, %cond_426_case_0.i.2 ]
  %166 = getelementptr inbounds i8, i8* %153, i64 2
  %167 = bitcast i8* %166 to i1*
  store i1 %"03.0.i.2", i1* %167, align 1
  %168 = getelementptr inbounds i8, i8* %26, i64 72
  %169 = bitcast i8* %168 to { i1, i64, i1 }*
  %170 = load { i1, i64, i1 }, { i1, i64, i1 }* %169, align 4
  %.fca.0.extract.i915.3 = extractvalue { i1, i64, i1 } %170, 0
  %.fca.1.extract.i916.3 = extractvalue { i1, i64, i1 } %170, 1
  br i1 %.fca.0.extract.i915.3, label %cond_426_case_1.i.3, label %cond_426_case_0.i.3

cond_426_case_0.i.3:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.2
  %.fca.2.extract.i.3 = extractvalue { i1, i64, i1 } %170, 2
  br label %__hugr__.array.__read_bool.3.338.exit.3

cond_426_case_1.i.3:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.2
  %read_bool.i.3 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.3)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.3)
  br label %__hugr__.array.__read_bool.3.338.exit.3

__hugr__.array.__read_bool.3.338.exit.3:          ; preds = %cond_426_case_1.i.3, %cond_426_case_0.i.3
  %"03.0.i.3" = phi i1 [ %read_bool.i.3, %cond_426_case_1.i.3 ], [ %.fca.2.extract.i.3, %cond_426_case_0.i.3 ]
  %171 = getelementptr inbounds i8, i8* %153, i64 3
  %172 = bitcast i8* %171 to i1*
  store i1 %"03.0.i.3", i1* %172, align 1
  %173 = getelementptr inbounds i8, i8* %26, i64 96
  %174 = bitcast i8* %173 to { i1, i64, i1 }*
  %175 = load { i1, i64, i1 }, { i1, i64, i1 }* %174, align 4
  %.fca.0.extract.i915.4 = extractvalue { i1, i64, i1 } %175, 0
  %.fca.1.extract.i916.4 = extractvalue { i1, i64, i1 } %175, 1
  br i1 %.fca.0.extract.i915.4, label %cond_426_case_1.i.4, label %cond_426_case_0.i.4

cond_426_case_0.i.4:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.3
  %.fca.2.extract.i.4 = extractvalue { i1, i64, i1 } %175, 2
  br label %__hugr__.array.__read_bool.3.338.exit.4

cond_426_case_1.i.4:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.3
  %read_bool.i.4 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.4)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.4)
  br label %__hugr__.array.__read_bool.3.338.exit.4

__hugr__.array.__read_bool.3.338.exit.4:          ; preds = %cond_426_case_1.i.4, %cond_426_case_0.i.4
  %"03.0.i.4" = phi i1 [ %read_bool.i.4, %cond_426_case_1.i.4 ], [ %.fca.2.extract.i.4, %cond_426_case_0.i.4 ]
  %176 = getelementptr inbounds i8, i8* %153, i64 4
  %177 = bitcast i8* %176 to i1*
  store i1 %"03.0.i.4", i1* %177, align 1
  %178 = getelementptr inbounds i8, i8* %26, i64 120
  %179 = bitcast i8* %178 to { i1, i64, i1 }*
  %180 = load { i1, i64, i1 }, { i1, i64, i1 }* %179, align 4
  %.fca.0.extract.i915.5 = extractvalue { i1, i64, i1 } %180, 0
  %.fca.1.extract.i916.5 = extractvalue { i1, i64, i1 } %180, 1
  br i1 %.fca.0.extract.i915.5, label %cond_426_case_1.i.5, label %cond_426_case_0.i.5

cond_426_case_0.i.5:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.4
  %.fca.2.extract.i.5 = extractvalue { i1, i64, i1 } %180, 2
  br label %__hugr__.array.__read_bool.3.338.exit.5

cond_426_case_1.i.5:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.4
  %read_bool.i.5 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.5)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.5)
  br label %__hugr__.array.__read_bool.3.338.exit.5

__hugr__.array.__read_bool.3.338.exit.5:          ; preds = %cond_426_case_1.i.5, %cond_426_case_0.i.5
  %"03.0.i.5" = phi i1 [ %read_bool.i.5, %cond_426_case_1.i.5 ], [ %.fca.2.extract.i.5, %cond_426_case_0.i.5 ]
  %181 = getelementptr inbounds i8, i8* %153, i64 5
  %182 = bitcast i8* %181 to i1*
  store i1 %"03.0.i.5", i1* %182, align 1
  %183 = getelementptr inbounds i8, i8* %26, i64 144
  %184 = bitcast i8* %183 to { i1, i64, i1 }*
  %185 = load { i1, i64, i1 }, { i1, i64, i1 }* %184, align 4
  %.fca.0.extract.i915.6 = extractvalue { i1, i64, i1 } %185, 0
  %.fca.1.extract.i916.6 = extractvalue { i1, i64, i1 } %185, 1
  br i1 %.fca.0.extract.i915.6, label %cond_426_case_1.i.6, label %cond_426_case_0.i.6

cond_426_case_0.i.6:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.5
  %.fca.2.extract.i.6 = extractvalue { i1, i64, i1 } %185, 2
  br label %__hugr__.array.__read_bool.3.338.exit.6

cond_426_case_1.i.6:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.5
  %read_bool.i.6 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.6)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.6)
  br label %__hugr__.array.__read_bool.3.338.exit.6

__hugr__.array.__read_bool.3.338.exit.6:          ; preds = %cond_426_case_1.i.6, %cond_426_case_0.i.6
  %"03.0.i.6" = phi i1 [ %read_bool.i.6, %cond_426_case_1.i.6 ], [ %.fca.2.extract.i.6, %cond_426_case_0.i.6 ]
  %186 = getelementptr inbounds i8, i8* %153, i64 6
  %187 = bitcast i8* %186 to i1*
  store i1 %"03.0.i.6", i1* %187, align 1
  %188 = getelementptr inbounds i8, i8* %26, i64 168
  %189 = bitcast i8* %188 to { i1, i64, i1 }*
  %190 = load { i1, i64, i1 }, { i1, i64, i1 }* %189, align 4
  %.fca.0.extract.i915.7 = extractvalue { i1, i64, i1 } %190, 0
  %.fca.1.extract.i916.7 = extractvalue { i1, i64, i1 } %190, 1
  br i1 %.fca.0.extract.i915.7, label %cond_426_case_1.i.7, label %cond_426_case_0.i.7

cond_426_case_0.i.7:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.6
  %.fca.2.extract.i.7 = extractvalue { i1, i64, i1 } %190, 2
  br label %__hugr__.array.__read_bool.3.338.exit.7

cond_426_case_1.i.7:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.6
  %read_bool.i.7 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.7)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.7)
  br label %__hugr__.array.__read_bool.3.338.exit.7

__hugr__.array.__read_bool.3.338.exit.7:          ; preds = %cond_426_case_1.i.7, %cond_426_case_0.i.7
  %"03.0.i.7" = phi i1 [ %read_bool.i.7, %cond_426_case_1.i.7 ], [ %.fca.2.extract.i.7, %cond_426_case_0.i.7 ]
  %191 = getelementptr inbounds i8, i8* %153, i64 7
  %192 = bitcast i8* %191 to i1*
  store i1 %"03.0.i.7", i1* %192, align 1
  tail call void @heap_free(i8* nonnull %26)
  tail call void @heap_free(i8* nonnull %28)
  %193 = load i64, i64* %155, align 4
  %194 = and i64 %193, 255
  store i64 %194, i64* %155, align 4
  %195 = icmp eq i64 %194, 0
  br i1 %195, label %__barray_check_none_borrowed.exit921, label %mask_block_err.i920

__barray_check_none_borrowed.exit921:             ; preds = %__hugr__.array.__read_bool.3.338.exit.7
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %196 = alloca i64, align 8
  store i64 0, i64* %196, align 8
  store i32 8, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %197 = bitcast i1** %arr_ptr to i8**
  store i8* %153, i8** %197, align 8
  %198 = bitcast i1** %mask_ptr to i64**
  store i64* %196, i64** %198, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @res_measuremen.F30240EB.0, i64 0, i64 0), i64 25, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  ret void

mask_block_err.i920:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.7
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_exit_91:                                     ; preds = %__barray_mask_return.exit, %cond_exit_174.loopexit
  %199 = load i64, i64* %3, align 4
  %200 = and i64 %199, 128
  %.not.i922 = icmp eq i64 %200, 0
  br i1 %.not.i922, label %__barray_mask_borrow.exit924, label %panic.i923

panic.i923:                                       ; preds = %cond_exit_91
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit924:                     ; preds = %cond_exit_91
  %201 = xor i64 %199, 128
  store i64 %201, i64* %3, align 4
  %202 = getelementptr inbounds i8, i8* %0, i64 56
  %203 = bitcast i8* %202 to i64*
  %204 = load i64, i64* %203, align 4
  tail call void @___rxy(i64 %204, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %204, double 0x400921FB54442D18)
  %205 = load i64, i64* %3, align 4
  %206 = and i64 %205, 128
  %.not.i925 = icmp eq i64 %206, 0
  br i1 %.not.i925, label %panic.i926, label %__barray_mask_return.exit927

panic.i926:                                       ; preds = %__barray_mask_borrow.exit924
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit927:                     ; preds = %__barray_mask_borrow.exit924
  %207 = xor i64 %205, 128
  store i64 %207, i64* %3, align 4
  store i64 %204, i64* %203, align 4
  %208 = tail call i8* @heap_alloc(i64 192)
  %209 = bitcast i8* %208 to { i1, i64, i1 }*
  %210 = tail call i8* @heap_alloc(i64 8)
  %211 = bitcast i8* %210 to i64*
  store i64 -1, i64* %211, align 1
  br label %221

mask_block_ok.i.i.i:                              ; preds = %cond_exit_584.i
  %212 = load i64, i64* %3, align 4
  %213 = or i64 %212, -256
  store i64 %213, i64* %3, align 4
  %214 = icmp eq i64 %213, -1
  br i1 %214, label %"__hugr__.$measure_array$$n(8).508.exit", label %mask_block_err.i.i.i

"__hugr__.$measure_array$$n(8).508.exit":         ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %215 = tail call i8* @heap_alloc(i64 256)
  %216 = tail call i8* @heap_alloc(i64 8)
  %217 = bitcast i8* %216 to i64*
  store i64 0, i64* %217, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(256) %215, i8 0, i64 256, i1 false)
  %218 = load i64, i64* %211, align 4
  %219 = and i64 %218, 255
  store i64 %219, i64* %211, align 4
  %220 = icmp eq i64 %219, 0
  br i1 %220, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

221:                                              ; preds = %__barray_mask_return.exit927, %cond_exit_584.i
  %"534_0.sroa.15.0.i978" = phi i64 [ 0, %__barray_mask_return.exit927 ], [ %222, %cond_exit_584.i ]
  %222 = add nuw nsw i64 %"534_0.sroa.15.0.i978", 1
  %223 = lshr i64 %"534_0.sroa.15.0.i978", 6
  %224 = getelementptr inbounds i64, i64* %3, i64 %223
  %225 = load i64, i64* %224, align 4
  %226 = shl nuw nsw i64 1, %"534_0.sroa.15.0.i978"
  %227 = and i64 %225, %226
  %.not.i99.i.i = icmp eq i64 %227, 0
  br i1 %.not.i99.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %221
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %221
  %228 = xor i64 %225, %226
  store i64 %228, i64* %224, align 4
  %229 = getelementptr inbounds i64, i64* %1, i64 %"534_0.sroa.15.0.i978"
  %230 = load i64, i64* %229, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %230)
  tail call void @___qfree(i64 %230)
  %231 = getelementptr inbounds i64, i64* %211, i64 %223
  %232 = load i64, i64* %231, align 4
  %233 = and i64 %232, %226
  %.not.i.i929 = icmp eq i64 %233, 0
  br i1 %.not.i.i929, label %panic.i.i930, label %cond_exit_584.i

panic.i.i930:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_584.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"598_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %234 = xor i64 %232, %226
  store i64 %234, i64* %231, align 4
  %235 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %209, i64 %"534_0.sroa.15.0.i978"
  store { i1, i64, i1 } %"598_054.fca.1.insert.i", { i1, i64, i1 }* %235, align 4
  %exitcond994.not = icmp eq i64 %222, 8
  br i1 %exitcond994.not, label %mask_block_ok.i.i.i, label %221

__barray_check_bounds.exit932:                    ; preds = %__barray_mask_return.exit, %__barray_mask_return.exit951
  %"136_3.0975" = phi i64 [ %236, %__barray_mask_return.exit951 ], [ 0, %__barray_mask_return.exit ]
  %236 = add nuw nsw i64 %"136_3.0975", 1
  %237 = load i64, i64* %6, align 4
  %238 = and i64 %237, %8
  %.not.i933 = icmp eq i64 %238, 0
  br i1 %.not.i933, label %pow.i.preheader, label %panic.i934

panic.i934:                                       ; preds = %__barray_check_bounds.exit932
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

pow.i.preheader:                                  ; preds = %__barray_check_bounds.exit932
  %239 = xor i64 %237, %8
  store i64 %239, i64* %6, align 4
  %240 = load i64, i64* %11, align 4
  br label %pow.i

pow.i:                                            ; preds = %pow.i.preheader, %pow_body.i
  %storemerge1.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %pow.i.preheader ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"45_0.0976", %pow.i.preheader ]
  switch i64 %storemerge.i, label %pow_body.i [
    i64 1, label %__hugr__.__pow__.379.exit.loopexit
    i64 0, label %__hugr__.__pow__.379.exit
  ]

pow_body.i:                                       ; preds = %pow.i
  %new_acc.i = shl i64 %storemerge1.i, 1
  %new_exp.i = add i64 %storemerge.i, -1
  br label %pow.i

__hugr__.__pow__.379.exit.loopexit:               ; preds = %pow.i
  br label %__hugr__.__pow__.379.exit

__hugr__.__pow__.379.exit:                        ; preds = %pow.i, %__hugr__.__pow__.379.exit.loopexit
  %storemerge3.i = phi i64 [ %storemerge1.i, %__hugr__.__pow__.379.exit.loopexit ], [ 1, %pow.i ]
  %241 = sitofp i64 %storemerge3.i to double
  %242 = fdiv double 1.000000e+00, %241
  %243 = fcmp oeq double %242, 0x7FF0000000000000
  %244 = fcmp oeq double %242, 0xFFF0000000000000
  %245 = fcmp uno double %242, 0.000000e+00
  %246 = or i1 %243, %244
  %247 = or i1 %245, %246
  br i1 %247, label %248, label %__barray_check_bounds.exit937

248:                                              ; preds = %__hugr__.__pow__.379.exit
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([55 x i8], [55 x i8]* @e_tket.rotat.20D0216B.0, i64 0, i64 0))
  unreachable

__barray_check_bounds.exit937:                    ; preds = %__hugr__.__pow__.379.exit
  %249 = sub nuw nsw i64 7, %"136_3.0975"
  %250 = lshr i64 %249, 6
  %251 = getelementptr inbounds i64, i64* %3, i64 %250
  %252 = load i64, i64* %251, align 4
  %253 = shl nuw nsw i64 1, %249
  %254 = and i64 %252, %253
  %.not.i938 = icmp eq i64 %254, 0
  br i1 %.not.i938, label %__barray_check_bounds.exit943, label %panic.i939

panic.i939:                                       ; preds = %__barray_check_bounds.exit937
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit943:                    ; preds = %__barray_check_bounds.exit937
  %255 = xor i64 %252, %253
  store i64 %255, i64* %251, align 4
  %256 = getelementptr inbounds i64, i64* %1, i64 %249
  %257 = load i64, i64* %256, align 4
  %258 = fmul double %242, 0x400921FB54442D18
  %259 = fmul double %258, 5.000000e-01
  %260 = fneg double %259
  tail call void @___rzz(i64 %240, i64 %257, double %260)
  tail call void @___rz(i64 %257, double %259)
  %261 = load i64, i64* %6, align 4
  %262 = and i64 %261, %8
  %.not.i944 = icmp eq i64 %262, 0
  br i1 %.not.i944, label %panic.i945, label %__barray_check_bounds.exit948

panic.i945:                                       ; preds = %__barray_check_bounds.exit943
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit948:                    ; preds = %__barray_check_bounds.exit943
  %263 = xor i64 %261, %8
  store i64 %263, i64* %6, align 4
  store i64 %240, i64* %11, align 4
  %264 = load i64, i64* %251, align 4
  %265 = and i64 %264, %253
  %.not.i949 = icmp eq i64 %265, 0
  br i1 %.not.i949, label %panic.i950, label %__barray_mask_return.exit951

panic.i950:                                       ; preds = %__barray_check_bounds.exit948
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit951:                     ; preds = %__barray_check_bounds.exit948
  %266 = xor i64 %264, %253
  store i64 %266, i64* %251, align 4
  store i64 %257, i64* %256, align 4
  %exitcond992.not = icmp eq i64 %236, %indvars.iv
  br i1 %exitcond992.not, label %cond_exit_174.loopexit, label %__barray_check_bounds.exit932
}

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @heap_free(i8*) local_unnamed_addr

declare void @print_bool_arr(i8*, i64, <{ i32, i32, i1*, i1* }>*) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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
