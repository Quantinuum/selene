; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

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
  %exitcond992.not = icmp eq i64 %4, 8
  br i1 %exitcond992.not, label %cond_exit_91, label %__barray_check_bounds.exit

__barray_check_bounds.exit:                       ; preds = %cond_exit_20, %cond_exit_174.loopexit
  %"45_0.0976" = phi i64 [ %4, %cond_exit_174.loopexit ], [ 0, %cond_exit_20 ]
  %4 = add nuw nsw i64 %"45_0.0976", 1
  %5 = sub nuw nsw i64 7, %"45_0.0976"
  %6 = lshr i64 %"45_0.0976", 6
  %7 = getelementptr inbounds i64, i64* %3, i64 %6
  %8 = load i64, i64* %7, align 4
  %9 = shl nuw nsw i64 1, %"45_0.0976"
  %10 = and i64 %8, %9
  %.not.i = icmp eq i64 %10, 0
  br i1 %.not.i, label %__barray_check_bounds.exit873, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit873:                    ; preds = %__barray_check_bounds.exit
  %11 = xor i64 %8, %9
  store i64 %11, i64* %7, align 4
  %12 = getelementptr inbounds i64, i64* %1, i64 %"45_0.0976"
  %13 = load i64, i64* %12, align 4
  tail call void @___rxy(i64 %13, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %13, double 0x400921FB54442D18)
  %14 = load i64, i64* %7, align 4
  %15 = and i64 %14, %9
  %.not.i874 = icmp eq i64 %15, 0
  br i1 %.not.i874, label %panic.i875, label %__barray_mask_return.exit

panic.i875:                                       ; preds = %__barray_check_bounds.exit873
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit873
  %16 = xor i64 %14, %9
  store i64 %16, i64* %7, align 4
  store i64 %13, i64* %12, align 4
  %.not997 = icmp eq i64 %"45_0.0976", 7
  br i1 %.not997, label %cond_exit_91, label %__barray_check_bounds.exit932

cond_20_case_1:                                   ; preds = %alloca_block, %cond_exit_20
  %"15_0.sroa.0.0974" = phi i64 [ 0, %alloca_block ], [ %17, %cond_exit_20 ]
  %17 = add nuw nsw i64 %"15_0.sroa.0.0974", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.i, label %id_bb.i, label %reset_bb.i

reset_bb.i:                                       ; preds = %cond_20_case_1
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %cond_20_case_1
  %18 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %19 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %18
  %.fca.0.extract.i = extractvalue { i1, i64 } %19, 0
  br i1 %.fca.0.extract.i, label %__barray_check_bounds.exit889, label %cond_441_case_0.i

cond_441_case_0.i:                                ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit889:                    ; preds = %id_bb.i
  %20 = lshr i64 %"15_0.sroa.0.0974", 6
  %21 = getelementptr inbounds i64, i64* %3, i64 %20
  %22 = load i64, i64* %21, align 4
  %23 = shl nuw nsw i64 1, %"15_0.sroa.0.0974"
  %24 = and i64 %22, %23
  %.not.i890 = icmp eq i64 %24, 0
  br i1 %.not.i890, label %panic.i891, label %cond_exit_20

panic.i891:                                       ; preds = %__barray_check_bounds.exit889
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_20:                                     ; preds = %__barray_check_bounds.exit889
  %.fca.1.extract.i = extractvalue { i1, i64 } %19, 1
  %25 = xor i64 %22, %23
  store i64 %25, i64* %21, align 4
  %26 = getelementptr inbounds i64, i64* %1, i64 %"15_0.sroa.0.0974"
  store i64 %.fca.1.extract.i, i64* %26, align 4
  %exitcond.not = icmp eq i64 %17, 8
  br i1 %exitcond.not, label %__barray_check_bounds.exit, label %cond_20_case_1

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$measure_array$$n(8).508.exit"
  %27 = tail call i8* @heap_alloc(i64 192)
  %28 = bitcast i8* %27 to { i1, i64, i1 }*
  %29 = tail call i8* @heap_alloc(i64 8)
  %30 = bitcast i8* %29 to i64*
  store i64 0, i64* %30, align 1
  %31 = bitcast i8* %216 to { i1, { i1, i64, i1 } }*
  br label %32

mask_block_err.i:                                 ; preds = %"__hugr__.$measure_array$$n(8).508.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

32:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_324.327.exit
  %storemerge870983 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %50, %__hugr__.const_fun_324.327.exit ]
  %33 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %48, %__hugr__.const_fun_324.327.exit ]
  %34 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %210, i64 %storemerge870983
  %35 = load { i1, i64, i1 }, { i1, i64, i1 }* %34, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %35, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %35, 1
  br i1 %.fca.0.extract118.i, label %cond_693_case_1.i, label %cond_exit_693.i

cond_693_case_1.i:                                ; preds = %32
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %36 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %cond_exit_693.i

cond_exit_693.i:                                  ; preds = %cond_693_case_1.i, %32
  %.pn.i = phi { i1, i64, i1 } [ %36, %cond_693_case_1.i ], [ %35, %32 ]
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %37 = icmp ult i64 %33, 8
  br i1 %37, label %38, label %cond_696_case_0.i

38:                                               ; preds = %cond_exit_693.i
  %39 = lshr i64 %33, 6
  %40 = getelementptr inbounds i64, i64* %218, i64 %39
  %41 = load i64, i64* %40, align 4
  %42 = shl nuw nsw i64 1, %33
  %43 = and i64 %41, %42
  %.not.i.i = icmp eq i64 %43, 0
  br i1 %.not.i.i, label %cond_696_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %38
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_696_case_0.i:                                ; preds = %cond_exit_693.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_696_case_1.i:                                ; preds = %38
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %35, i1 %"04.sroa.6.0.i", 2
  %44 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %45 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %31, i64 %33
  %46 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %45, i64 0, i32 0
  %47 = load i1, i1* %46, align 1
  store { i1, { i1, i64, i1 } } %44, { i1, { i1, i64, i1 } }* %45, align 4
  br i1 %47, label %cond_697_case_1.i, label %__hugr__.const_fun_324.327.exit

cond_697_case_1.i:                                ; preds = %cond_696_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_324.327.exit:                  ; preds = %cond_696_case_1.i
  %48 = add nuw nsw i64 %33, 1
  %49 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %28, i64 %storemerge870983
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %49, align 4
  %50 = add nuw nsw i64 %storemerge870983, 1
  %exitcond994.not = icmp eq i64 %50, 8
  br i1 %exitcond994.not, label %mask_block_ok.i896, label %32

mask_block_ok.i896:                               ; preds = %__hugr__.const_fun_324.327.exit
  tail call void @heap_free(i8* nonnull %209)
  tail call void @heap_free(i8* %211)
  %51 = load i64, i64* %218, align 4
  %52 = and i64 %51, 255
  store i64 %52, i64* %218, align 4
  %53 = icmp eq i64 %52, 0
  br i1 %53, label %__barray_check_none_borrowed.exit898, label %mask_block_err.i897

mask_block_err.i897:                              ; preds = %mask_block_ok.i896
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit898:             ; preds = %mask_block_ok.i896
  %54 = tail call i8* @heap_alloc(i64 192)
  %55 = bitcast i8* %54 to { i1, i64, i1 }*
  %56 = tail call i8* @heap_alloc(i64 8)
  %57 = bitcast i8* %56 to i64*
  store i64 0, i64* %57, align 1
  %58 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %31, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %58, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_319.324.exit, label %cond_738_case_0.i

cond_738_case_0.i:                                ; preds = %__hugr__.const_fun_319.324.exit.6, %__hugr__.const_fun_319.324.exit.5, %__hugr__.const_fun_319.324.exit.4, %__hugr__.const_fun_319.324.exit.3, %__hugr__.const_fun_319.324.exit.2, %__hugr__.const_fun_319.324.exit.1, %__hugr__.const_fun_319.324.exit, %__barray_check_none_borrowed.exit898
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_319.324.exit:                  ; preds = %__barray_check_none_borrowed.exit898
  %59 = extractvalue { i1, { i1, i64, i1 } } %58, 1
  store { i1, i64, i1 } %59, { i1, i64, i1 }* %55, align 4
  %60 = getelementptr inbounds i8, i8* %216, i64 32
  %61 = bitcast i8* %60 to { i1, { i1, i64, i1 } }*
  %62 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %61, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %62, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_319.324.exit.1, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.1:                ; preds = %__hugr__.const_fun_319.324.exit
  %63 = extractvalue { i1, { i1, i64, i1 } } %62, 1
  %64 = getelementptr inbounds i8, i8* %54, i64 24
  %65 = bitcast i8* %64 to { i1, i64, i1 }*
  store { i1, i64, i1 } %63, { i1, i64, i1 }* %65, align 4
  %66 = getelementptr inbounds i8, i8* %216, i64 64
  %67 = bitcast i8* %66 to { i1, { i1, i64, i1 } }*
  %68 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %67, align 4
  %.fca.0.extract11.i.2 = extractvalue { i1, { i1, i64, i1 } } %68, 0
  br i1 %.fca.0.extract11.i.2, label %__hugr__.const_fun_319.324.exit.2, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.2:                ; preds = %__hugr__.const_fun_319.324.exit.1
  %69 = extractvalue { i1, { i1, i64, i1 } } %68, 1
  %70 = getelementptr inbounds i8, i8* %54, i64 48
  %71 = bitcast i8* %70 to { i1, i64, i1 }*
  store { i1, i64, i1 } %69, { i1, i64, i1 }* %71, align 4
  %72 = getelementptr inbounds i8, i8* %216, i64 96
  %73 = bitcast i8* %72 to { i1, { i1, i64, i1 } }*
  %74 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %73, align 4
  %.fca.0.extract11.i.3 = extractvalue { i1, { i1, i64, i1 } } %74, 0
  br i1 %.fca.0.extract11.i.3, label %__hugr__.const_fun_319.324.exit.3, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.3:                ; preds = %__hugr__.const_fun_319.324.exit.2
  %75 = extractvalue { i1, { i1, i64, i1 } } %74, 1
  %76 = getelementptr inbounds i8, i8* %54, i64 72
  %77 = bitcast i8* %76 to { i1, i64, i1 }*
  store { i1, i64, i1 } %75, { i1, i64, i1 }* %77, align 4
  %78 = getelementptr inbounds i8, i8* %216, i64 128
  %79 = bitcast i8* %78 to { i1, { i1, i64, i1 } }*
  %80 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %79, align 4
  %.fca.0.extract11.i.4 = extractvalue { i1, { i1, i64, i1 } } %80, 0
  br i1 %.fca.0.extract11.i.4, label %__hugr__.const_fun_319.324.exit.4, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.4:                ; preds = %__hugr__.const_fun_319.324.exit.3
  %81 = extractvalue { i1, { i1, i64, i1 } } %80, 1
  %82 = getelementptr inbounds i8, i8* %54, i64 96
  %83 = bitcast i8* %82 to { i1, i64, i1 }*
  store { i1, i64, i1 } %81, { i1, i64, i1 }* %83, align 4
  %84 = getelementptr inbounds i8, i8* %216, i64 160
  %85 = bitcast i8* %84 to { i1, { i1, i64, i1 } }*
  %86 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %85, align 4
  %.fca.0.extract11.i.5 = extractvalue { i1, { i1, i64, i1 } } %86, 0
  br i1 %.fca.0.extract11.i.5, label %__hugr__.const_fun_319.324.exit.5, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.5:                ; preds = %__hugr__.const_fun_319.324.exit.4
  %87 = extractvalue { i1, { i1, i64, i1 } } %86, 1
  %88 = getelementptr inbounds i8, i8* %54, i64 120
  %89 = bitcast i8* %88 to { i1, i64, i1 }*
  store { i1, i64, i1 } %87, { i1, i64, i1 }* %89, align 4
  %90 = getelementptr inbounds i8, i8* %216, i64 192
  %91 = bitcast i8* %90 to { i1, { i1, i64, i1 } }*
  %92 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %91, align 4
  %.fca.0.extract11.i.6 = extractvalue { i1, { i1, i64, i1 } } %92, 0
  br i1 %.fca.0.extract11.i.6, label %__hugr__.const_fun_319.324.exit.6, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.6:                ; preds = %__hugr__.const_fun_319.324.exit.5
  %93 = extractvalue { i1, { i1, i64, i1 } } %92, 1
  %94 = getelementptr inbounds i8, i8* %54, i64 144
  %95 = bitcast i8* %94 to { i1, i64, i1 }*
  store { i1, i64, i1 } %93, { i1, i64, i1 }* %95, align 4
  %96 = getelementptr inbounds i8, i8* %216, i64 224
  %97 = bitcast i8* %96 to { i1, { i1, i64, i1 } }*
  %98 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %97, align 4
  %.fca.0.extract11.i.7 = extractvalue { i1, { i1, i64, i1 } } %98, 0
  br i1 %.fca.0.extract11.i.7, label %__hugr__.const_fun_319.324.exit.7, label %cond_738_case_0.i

__hugr__.const_fun_319.324.exit.7:                ; preds = %__hugr__.const_fun_319.324.exit.6
  %99 = extractvalue { i1, { i1, i64, i1 } } %98, 1
  %100 = getelementptr inbounds i8, i8* %54, i64 168
  %101 = bitcast i8* %100 to { i1, i64, i1 }*
  store { i1, i64, i1 } %99, { i1, i64, i1 }* %101, align 4
  tail call void @heap_free(i8* nonnull %216)
  tail call void @heap_free(i8* nonnull %217)
  %102 = load i64, i64* %57, align 4
  %103 = and i64 %102, 1
  %.not = icmp eq i64 %103, 0
  br i1 %.not, label %__barray_mask_borrow.exit909, label %cond_exit_652

mask_block_err.i902:                              ; preds = %cond_exit_652.7
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit909:                     ; preds = %__hugr__.const_fun_319.324.exit.7
  %104 = xor i64 %102, 1
  store i64 %104, i64* %57, align 4
  %105 = load { i1, i64, i1 }, { i1, i64, i1 }* %55, align 4
  %.fca.0.extract608 = extractvalue { i1, i64, i1 } %105, 0
  br i1 %.fca.0.extract608, label %cond_675_case_1, label %cond_exit_652

cond_exit_652:                                    ; preds = %cond_675_case_1, %__barray_mask_borrow.exit909, %__hugr__.const_fun_319.324.exit.7
  %106 = load i64, i64* %57, align 4
  %107 = and i64 %106, 2
  %.not.1 = icmp eq i64 %107, 0
  br i1 %.not.1, label %__barray_mask_borrow.exit909.1, label %cond_exit_652.1

__barray_mask_borrow.exit909.1:                   ; preds = %cond_exit_652
  %108 = xor i64 %106, 2
  store i64 %108, i64* %57, align 4
  %109 = getelementptr inbounds i8, i8* %54, i64 24
  %110 = bitcast i8* %109 to { i1, i64, i1 }*
  %111 = load { i1, i64, i1 }, { i1, i64, i1 }* %110, align 4
  %.fca.0.extract608.1 = extractvalue { i1, i64, i1 } %111, 0
  br i1 %.fca.0.extract608.1, label %cond_675_case_1.1, label %cond_exit_652.1

cond_675_case_1.1:                                ; preds = %__barray_mask_borrow.exit909.1
  %.fca.1.extract609.1 = extractvalue { i1, i64, i1 } %111, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.1)
  br label %cond_exit_652.1

cond_exit_652.1:                                  ; preds = %cond_675_case_1.1, %__barray_mask_borrow.exit909.1, %cond_exit_652
  %112 = load i64, i64* %57, align 4
  %113 = and i64 %112, 4
  %.not.2 = icmp eq i64 %113, 0
  br i1 %.not.2, label %__barray_mask_borrow.exit909.2, label %cond_exit_652.2

__barray_mask_borrow.exit909.2:                   ; preds = %cond_exit_652.1
  %114 = xor i64 %112, 4
  store i64 %114, i64* %57, align 4
  %115 = getelementptr inbounds i8, i8* %54, i64 48
  %116 = bitcast i8* %115 to { i1, i64, i1 }*
  %117 = load { i1, i64, i1 }, { i1, i64, i1 }* %116, align 4
  %.fca.0.extract608.2 = extractvalue { i1, i64, i1 } %117, 0
  br i1 %.fca.0.extract608.2, label %cond_675_case_1.2, label %cond_exit_652.2

cond_675_case_1.2:                                ; preds = %__barray_mask_borrow.exit909.2
  %.fca.1.extract609.2 = extractvalue { i1, i64, i1 } %117, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.2)
  br label %cond_exit_652.2

cond_exit_652.2:                                  ; preds = %cond_675_case_1.2, %__barray_mask_borrow.exit909.2, %cond_exit_652.1
  %118 = load i64, i64* %57, align 4
  %119 = and i64 %118, 8
  %.not.3 = icmp eq i64 %119, 0
  br i1 %.not.3, label %__barray_mask_borrow.exit909.3, label %cond_exit_652.3

__barray_mask_borrow.exit909.3:                   ; preds = %cond_exit_652.2
  %120 = xor i64 %118, 8
  store i64 %120, i64* %57, align 4
  %121 = getelementptr inbounds i8, i8* %54, i64 72
  %122 = bitcast i8* %121 to { i1, i64, i1 }*
  %123 = load { i1, i64, i1 }, { i1, i64, i1 }* %122, align 4
  %.fca.0.extract608.3 = extractvalue { i1, i64, i1 } %123, 0
  br i1 %.fca.0.extract608.3, label %cond_675_case_1.3, label %cond_exit_652.3

cond_675_case_1.3:                                ; preds = %__barray_mask_borrow.exit909.3
  %.fca.1.extract609.3 = extractvalue { i1, i64, i1 } %123, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.3)
  br label %cond_exit_652.3

cond_exit_652.3:                                  ; preds = %cond_675_case_1.3, %__barray_mask_borrow.exit909.3, %cond_exit_652.2
  %124 = load i64, i64* %57, align 4
  %125 = and i64 %124, 16
  %.not.4 = icmp eq i64 %125, 0
  br i1 %.not.4, label %__barray_mask_borrow.exit909.4, label %cond_exit_652.4

__barray_mask_borrow.exit909.4:                   ; preds = %cond_exit_652.3
  %126 = xor i64 %124, 16
  store i64 %126, i64* %57, align 4
  %127 = getelementptr inbounds i8, i8* %54, i64 96
  %128 = bitcast i8* %127 to { i1, i64, i1 }*
  %129 = load { i1, i64, i1 }, { i1, i64, i1 }* %128, align 4
  %.fca.0.extract608.4 = extractvalue { i1, i64, i1 } %129, 0
  br i1 %.fca.0.extract608.4, label %cond_675_case_1.4, label %cond_exit_652.4

cond_675_case_1.4:                                ; preds = %__barray_mask_borrow.exit909.4
  %.fca.1.extract609.4 = extractvalue { i1, i64, i1 } %129, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.4)
  br label %cond_exit_652.4

cond_exit_652.4:                                  ; preds = %cond_675_case_1.4, %__barray_mask_borrow.exit909.4, %cond_exit_652.3
  %130 = load i64, i64* %57, align 4
  %131 = and i64 %130, 32
  %.not.5 = icmp eq i64 %131, 0
  br i1 %.not.5, label %__barray_mask_borrow.exit909.5, label %cond_exit_652.5

__barray_mask_borrow.exit909.5:                   ; preds = %cond_exit_652.4
  %132 = xor i64 %130, 32
  store i64 %132, i64* %57, align 4
  %133 = getelementptr inbounds i8, i8* %54, i64 120
  %134 = bitcast i8* %133 to { i1, i64, i1 }*
  %135 = load { i1, i64, i1 }, { i1, i64, i1 }* %134, align 4
  %.fca.0.extract608.5 = extractvalue { i1, i64, i1 } %135, 0
  br i1 %.fca.0.extract608.5, label %cond_675_case_1.5, label %cond_exit_652.5

cond_675_case_1.5:                                ; preds = %__barray_mask_borrow.exit909.5
  %.fca.1.extract609.5 = extractvalue { i1, i64, i1 } %135, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.5)
  br label %cond_exit_652.5

cond_exit_652.5:                                  ; preds = %cond_675_case_1.5, %__barray_mask_borrow.exit909.5, %cond_exit_652.4
  %136 = load i64, i64* %57, align 4
  %137 = and i64 %136, 64
  %.not.6 = icmp eq i64 %137, 0
  br i1 %.not.6, label %__barray_mask_borrow.exit909.6, label %cond_exit_652.6

__barray_mask_borrow.exit909.6:                   ; preds = %cond_exit_652.5
  %138 = xor i64 %136, 64
  store i64 %138, i64* %57, align 4
  %139 = getelementptr inbounds i8, i8* %54, i64 144
  %140 = bitcast i8* %139 to { i1, i64, i1 }*
  %141 = load { i1, i64, i1 }, { i1, i64, i1 }* %140, align 4
  %.fca.0.extract608.6 = extractvalue { i1, i64, i1 } %141, 0
  br i1 %.fca.0.extract608.6, label %cond_675_case_1.6, label %cond_exit_652.6

cond_675_case_1.6:                                ; preds = %__barray_mask_borrow.exit909.6
  %.fca.1.extract609.6 = extractvalue { i1, i64, i1 } %141, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.6)
  br label %cond_exit_652.6

cond_exit_652.6:                                  ; preds = %cond_675_case_1.6, %__barray_mask_borrow.exit909.6, %cond_exit_652.5
  %142 = load i64, i64* %57, align 4
  %143 = and i64 %142, 128
  %.not.7 = icmp eq i64 %143, 0
  br i1 %.not.7, label %__barray_mask_borrow.exit909.7, label %cond_exit_652.7

__barray_mask_borrow.exit909.7:                   ; preds = %cond_exit_652.6
  %144 = xor i64 %142, 128
  store i64 %144, i64* %57, align 4
  %145 = getelementptr inbounds i8, i8* %54, i64 168
  %146 = bitcast i8* %145 to { i1, i64, i1 }*
  %147 = load { i1, i64, i1 }, { i1, i64, i1 }* %146, align 4
  %.fca.0.extract608.7 = extractvalue { i1, i64, i1 } %147, 0
  br i1 %.fca.0.extract608.7, label %cond_675_case_1.7, label %cond_exit_652.7

cond_675_case_1.7:                                ; preds = %__barray_mask_borrow.exit909.7
  %.fca.1.extract609.7 = extractvalue { i1, i64, i1 } %147, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609.7)
  br label %cond_exit_652.7

cond_exit_652.7:                                  ; preds = %cond_675_case_1.7, %__barray_mask_borrow.exit909.7, %cond_exit_652.6
  %148 = load i64, i64* %57, align 4
  %149 = or i64 %148, -256
  store i64 %149, i64* %57, align 4
  %150 = icmp eq i64 %149, -1
  br i1 %150, label %loop_out161, label %mask_block_err.i902

loop_out161:                                      ; preds = %cond_exit_652.7
  tail call void @heap_free(i8* %54)
  tail call void @heap_free(i8* nonnull %56)
  %151 = load i64, i64* %30, align 4
  %152 = and i64 %151, 255
  store i64 %152, i64* %30, align 4
  %153 = icmp eq i64 %152, 0
  br i1 %153, label %__barray_check_none_borrowed.exit914, label %mask_block_err.i913

__barray_check_none_borrowed.exit914:             ; preds = %loop_out161
  %154 = tail call i8* @heap_alloc(i64 8)
  %155 = tail call i8* @heap_alloc(i64 8)
  %156 = bitcast i8* %155 to i64*
  store i64 0, i64* %156, align 1
  %157 = load { i1, i64, i1 }, { i1, i64, i1 }* %28, align 4
  %.fca.0.extract.i915 = extractvalue { i1, i64, i1 } %157, 0
  %.fca.1.extract.i916 = extractvalue { i1, i64, i1 } %157, 1
  br i1 %.fca.0.extract.i915, label %cond_426_case_1.i, label %cond_426_case_0.i

mask_block_err.i913:                              ; preds = %loop_out161
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_675_case_1:                                  ; preds = %__barray_mask_borrow.exit909
  %.fca.1.extract609 = extractvalue { i1, i64, i1 } %105, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract609)
  br label %cond_exit_652

cond_426_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit914
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %157, 2
  br label %__hugr__.array.__read_bool.3.338.exit

cond_426_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit914
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916)
  br label %__hugr__.array.__read_bool.3.338.exit

__hugr__.array.__read_bool.3.338.exit:            ; preds = %cond_426_case_0.i, %cond_426_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_426_case_1.i ], [ %.fca.2.extract.i, %cond_426_case_0.i ]
  %158 = bitcast i8* %154 to i1*
  store i1 %"03.0.i", i1* %158, align 1
  %159 = getelementptr inbounds i8, i8* %27, i64 24
  %160 = bitcast i8* %159 to { i1, i64, i1 }*
  %161 = load { i1, i64, i1 }, { i1, i64, i1 }* %160, align 4
  %.fca.0.extract.i915.1 = extractvalue { i1, i64, i1 } %161, 0
  %.fca.1.extract.i916.1 = extractvalue { i1, i64, i1 } %161, 1
  br i1 %.fca.0.extract.i915.1, label %cond_426_case_1.i.1, label %cond_426_case_0.i.1

cond_426_case_0.i.1:                              ; preds = %__hugr__.array.__read_bool.3.338.exit
  %.fca.2.extract.i.1 = extractvalue { i1, i64, i1 } %161, 2
  br label %__hugr__.array.__read_bool.3.338.exit.1

cond_426_case_1.i.1:                              ; preds = %__hugr__.array.__read_bool.3.338.exit
  %read_bool.i.1 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.1)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.1)
  br label %__hugr__.array.__read_bool.3.338.exit.1

__hugr__.array.__read_bool.3.338.exit.1:          ; preds = %cond_426_case_1.i.1, %cond_426_case_0.i.1
  %"03.0.i.1" = phi i1 [ %read_bool.i.1, %cond_426_case_1.i.1 ], [ %.fca.2.extract.i.1, %cond_426_case_0.i.1 ]
  %162 = getelementptr inbounds i8, i8* %154, i64 1
  %163 = bitcast i8* %162 to i1*
  store i1 %"03.0.i.1", i1* %163, align 1
  %164 = getelementptr inbounds i8, i8* %27, i64 48
  %165 = bitcast i8* %164 to { i1, i64, i1 }*
  %166 = load { i1, i64, i1 }, { i1, i64, i1 }* %165, align 4
  %.fca.0.extract.i915.2 = extractvalue { i1, i64, i1 } %166, 0
  %.fca.1.extract.i916.2 = extractvalue { i1, i64, i1 } %166, 1
  br i1 %.fca.0.extract.i915.2, label %cond_426_case_1.i.2, label %cond_426_case_0.i.2

cond_426_case_0.i.2:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.1
  %.fca.2.extract.i.2 = extractvalue { i1, i64, i1 } %166, 2
  br label %__hugr__.array.__read_bool.3.338.exit.2

cond_426_case_1.i.2:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.1
  %read_bool.i.2 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.2)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.2)
  br label %__hugr__.array.__read_bool.3.338.exit.2

__hugr__.array.__read_bool.3.338.exit.2:          ; preds = %cond_426_case_1.i.2, %cond_426_case_0.i.2
  %"03.0.i.2" = phi i1 [ %read_bool.i.2, %cond_426_case_1.i.2 ], [ %.fca.2.extract.i.2, %cond_426_case_0.i.2 ]
  %167 = getelementptr inbounds i8, i8* %154, i64 2
  %168 = bitcast i8* %167 to i1*
  store i1 %"03.0.i.2", i1* %168, align 1
  %169 = getelementptr inbounds i8, i8* %27, i64 72
  %170 = bitcast i8* %169 to { i1, i64, i1 }*
  %171 = load { i1, i64, i1 }, { i1, i64, i1 }* %170, align 4
  %.fca.0.extract.i915.3 = extractvalue { i1, i64, i1 } %171, 0
  %.fca.1.extract.i916.3 = extractvalue { i1, i64, i1 } %171, 1
  br i1 %.fca.0.extract.i915.3, label %cond_426_case_1.i.3, label %cond_426_case_0.i.3

cond_426_case_0.i.3:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.2
  %.fca.2.extract.i.3 = extractvalue { i1, i64, i1 } %171, 2
  br label %__hugr__.array.__read_bool.3.338.exit.3

cond_426_case_1.i.3:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.2
  %read_bool.i.3 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.3)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.3)
  br label %__hugr__.array.__read_bool.3.338.exit.3

__hugr__.array.__read_bool.3.338.exit.3:          ; preds = %cond_426_case_1.i.3, %cond_426_case_0.i.3
  %"03.0.i.3" = phi i1 [ %read_bool.i.3, %cond_426_case_1.i.3 ], [ %.fca.2.extract.i.3, %cond_426_case_0.i.3 ]
  %172 = getelementptr inbounds i8, i8* %154, i64 3
  %173 = bitcast i8* %172 to i1*
  store i1 %"03.0.i.3", i1* %173, align 1
  %174 = getelementptr inbounds i8, i8* %27, i64 96
  %175 = bitcast i8* %174 to { i1, i64, i1 }*
  %176 = load { i1, i64, i1 }, { i1, i64, i1 }* %175, align 4
  %.fca.0.extract.i915.4 = extractvalue { i1, i64, i1 } %176, 0
  %.fca.1.extract.i916.4 = extractvalue { i1, i64, i1 } %176, 1
  br i1 %.fca.0.extract.i915.4, label %cond_426_case_1.i.4, label %cond_426_case_0.i.4

cond_426_case_0.i.4:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.3
  %.fca.2.extract.i.4 = extractvalue { i1, i64, i1 } %176, 2
  br label %__hugr__.array.__read_bool.3.338.exit.4

cond_426_case_1.i.4:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.3
  %read_bool.i.4 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.4)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.4)
  br label %__hugr__.array.__read_bool.3.338.exit.4

__hugr__.array.__read_bool.3.338.exit.4:          ; preds = %cond_426_case_1.i.4, %cond_426_case_0.i.4
  %"03.0.i.4" = phi i1 [ %read_bool.i.4, %cond_426_case_1.i.4 ], [ %.fca.2.extract.i.4, %cond_426_case_0.i.4 ]
  %177 = getelementptr inbounds i8, i8* %154, i64 4
  %178 = bitcast i8* %177 to i1*
  store i1 %"03.0.i.4", i1* %178, align 1
  %179 = getelementptr inbounds i8, i8* %27, i64 120
  %180 = bitcast i8* %179 to { i1, i64, i1 }*
  %181 = load { i1, i64, i1 }, { i1, i64, i1 }* %180, align 4
  %.fca.0.extract.i915.5 = extractvalue { i1, i64, i1 } %181, 0
  %.fca.1.extract.i916.5 = extractvalue { i1, i64, i1 } %181, 1
  br i1 %.fca.0.extract.i915.5, label %cond_426_case_1.i.5, label %cond_426_case_0.i.5

cond_426_case_0.i.5:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.4
  %.fca.2.extract.i.5 = extractvalue { i1, i64, i1 } %181, 2
  br label %__hugr__.array.__read_bool.3.338.exit.5

cond_426_case_1.i.5:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.4
  %read_bool.i.5 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.5)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.5)
  br label %__hugr__.array.__read_bool.3.338.exit.5

__hugr__.array.__read_bool.3.338.exit.5:          ; preds = %cond_426_case_1.i.5, %cond_426_case_0.i.5
  %"03.0.i.5" = phi i1 [ %read_bool.i.5, %cond_426_case_1.i.5 ], [ %.fca.2.extract.i.5, %cond_426_case_0.i.5 ]
  %182 = getelementptr inbounds i8, i8* %154, i64 5
  %183 = bitcast i8* %182 to i1*
  store i1 %"03.0.i.5", i1* %183, align 1
  %184 = getelementptr inbounds i8, i8* %27, i64 144
  %185 = bitcast i8* %184 to { i1, i64, i1 }*
  %186 = load { i1, i64, i1 }, { i1, i64, i1 }* %185, align 4
  %.fca.0.extract.i915.6 = extractvalue { i1, i64, i1 } %186, 0
  %.fca.1.extract.i916.6 = extractvalue { i1, i64, i1 } %186, 1
  br i1 %.fca.0.extract.i915.6, label %cond_426_case_1.i.6, label %cond_426_case_0.i.6

cond_426_case_0.i.6:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.5
  %.fca.2.extract.i.6 = extractvalue { i1, i64, i1 } %186, 2
  br label %__hugr__.array.__read_bool.3.338.exit.6

cond_426_case_1.i.6:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.5
  %read_bool.i.6 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.6)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.6)
  br label %__hugr__.array.__read_bool.3.338.exit.6

__hugr__.array.__read_bool.3.338.exit.6:          ; preds = %cond_426_case_1.i.6, %cond_426_case_0.i.6
  %"03.0.i.6" = phi i1 [ %read_bool.i.6, %cond_426_case_1.i.6 ], [ %.fca.2.extract.i.6, %cond_426_case_0.i.6 ]
  %187 = getelementptr inbounds i8, i8* %154, i64 6
  %188 = bitcast i8* %187 to i1*
  store i1 %"03.0.i.6", i1* %188, align 1
  %189 = getelementptr inbounds i8, i8* %27, i64 168
  %190 = bitcast i8* %189 to { i1, i64, i1 }*
  %191 = load { i1, i64, i1 }, { i1, i64, i1 }* %190, align 4
  %.fca.0.extract.i915.7 = extractvalue { i1, i64, i1 } %191, 0
  %.fca.1.extract.i916.7 = extractvalue { i1, i64, i1 } %191, 1
  br i1 %.fca.0.extract.i915.7, label %cond_426_case_1.i.7, label %cond_426_case_0.i.7

cond_426_case_0.i.7:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.6
  %.fca.2.extract.i.7 = extractvalue { i1, i64, i1 } %191, 2
  br label %__hugr__.array.__read_bool.3.338.exit.7

cond_426_case_1.i.7:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.6
  %read_bool.i.7 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i916.7)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i916.7)
  br label %__hugr__.array.__read_bool.3.338.exit.7

__hugr__.array.__read_bool.3.338.exit.7:          ; preds = %cond_426_case_1.i.7, %cond_426_case_0.i.7
  %"03.0.i.7" = phi i1 [ %read_bool.i.7, %cond_426_case_1.i.7 ], [ %.fca.2.extract.i.7, %cond_426_case_0.i.7 ]
  %192 = getelementptr inbounds i8, i8* %154, i64 7
  %193 = bitcast i8* %192 to i1*
  store i1 %"03.0.i.7", i1* %193, align 1
  tail call void @heap_free(i8* nonnull %27)
  tail call void @heap_free(i8* nonnull %29)
  %194 = load i64, i64* %156, align 4
  %195 = and i64 %194, 255
  store i64 %195, i64* %156, align 4
  %196 = icmp eq i64 %195, 0
  br i1 %196, label %__barray_check_none_borrowed.exit921, label %mask_block_err.i920

__barray_check_none_borrowed.exit921:             ; preds = %__hugr__.array.__read_bool.3.338.exit.7
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %197 = alloca i64, align 8
  store i64 0, i64* %197, align 8
  store i32 8, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %198 = bitcast i1** %arr_ptr to i8**
  store i8* %154, i8** %198, align 8
  %199 = bitcast i1** %mask_ptr to i64**
  store i64* %197, i64** %199, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @res_measuremen.F30240EB.0, i64 0, i64 0), i64 25, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  ret void

mask_block_err.i920:                              ; preds = %__hugr__.array.__read_bool.3.338.exit.7
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_exit_91:                                     ; preds = %__barray_mask_return.exit, %cond_exit_174.loopexit
  %200 = load i64, i64* %3, align 4
  %201 = and i64 %200, 128
  %.not.i922 = icmp eq i64 %201, 0
  br i1 %.not.i922, label %__barray_mask_borrow.exit924, label %panic.i923

panic.i923:                                       ; preds = %cond_exit_91
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit924:                     ; preds = %cond_exit_91
  %202 = xor i64 %200, 128
  store i64 %202, i64* %3, align 4
  %203 = getelementptr inbounds i8, i8* %0, i64 56
  %204 = bitcast i8* %203 to i64*
  %205 = load i64, i64* %204, align 4
  tail call void @___rxy(i64 %205, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %205, double 0x400921FB54442D18)
  %206 = load i64, i64* %3, align 4
  %207 = and i64 %206, 128
  %.not.i925 = icmp eq i64 %207, 0
  br i1 %.not.i925, label %panic.i926, label %__barray_mask_return.exit927

panic.i926:                                       ; preds = %__barray_mask_borrow.exit924
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit927:                     ; preds = %__barray_mask_borrow.exit924
  %208 = xor i64 %206, 128
  store i64 %208, i64* %3, align 4
  store i64 %205, i64* %204, align 4
  %209 = tail call i8* @heap_alloc(i64 192)
  %210 = bitcast i8* %209 to { i1, i64, i1 }*
  %211 = tail call i8* @heap_alloc(i64 8)
  %212 = bitcast i8* %211 to i64*
  store i64 -1, i64* %212, align 1
  br label %222

mask_block_ok.i.i.i:                              ; preds = %cond_exit_584.i
  %213 = load i64, i64* %3, align 4
  %214 = or i64 %213, -256
  store i64 %214, i64* %3, align 4
  %215 = icmp eq i64 %214, -1
  br i1 %215, label %"__hugr__.$measure_array$$n(8).508.exit", label %mask_block_err.i.i.i

"__hugr__.$measure_array$$n(8).508.exit":         ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %216 = tail call i8* @heap_alloc(i64 256)
  %217 = tail call i8* @heap_alloc(i64 8)
  %218 = bitcast i8* %217 to i64*
  store i64 0, i64* %218, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(256) %216, i8 0, i64 256, i1 false)
  %219 = load i64, i64* %212, align 4
  %220 = and i64 %219, 255
  store i64 %220, i64* %212, align 4
  %221 = icmp eq i64 %220, 0
  br i1 %221, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

222:                                              ; preds = %__barray_mask_return.exit927, %cond_exit_584.i
  %"534_0.sroa.15.0.i978" = phi i64 [ 0, %__barray_mask_return.exit927 ], [ %223, %cond_exit_584.i ]
  %223 = add nuw nsw i64 %"534_0.sroa.15.0.i978", 1
  %224 = lshr i64 %"534_0.sroa.15.0.i978", 6
  %225 = getelementptr inbounds i64, i64* %3, i64 %224
  %226 = load i64, i64* %225, align 4
  %227 = shl nuw nsw i64 1, %"534_0.sroa.15.0.i978"
  %228 = and i64 %226, %227
  %.not.i99.i.i = icmp eq i64 %228, 0
  br i1 %.not.i99.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %222
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %222
  %229 = xor i64 %226, %227
  store i64 %229, i64* %225, align 4
  %230 = getelementptr inbounds i64, i64* %1, i64 %"534_0.sroa.15.0.i978"
  %231 = load i64, i64* %230, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %231)
  tail call void @___qfree(i64 %231)
  %232 = getelementptr inbounds i64, i64* %212, i64 %224
  %233 = load i64, i64* %232, align 4
  %234 = and i64 %233, %227
  %.not.i.i929 = icmp eq i64 %234, 0
  br i1 %.not.i.i929, label %panic.i.i930, label %cond_exit_584.i

panic.i.i930:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_584.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"598_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %235 = xor i64 %233, %227
  store i64 %235, i64* %232, align 4
  %236 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %210, i64 %"534_0.sroa.15.0.i978"
  store { i1, i64, i1 } %"598_054.fca.1.insert.i", { i1, i64, i1 }* %236, align 4
  %exitcond993.not = icmp eq i64 %223, 8
  br i1 %exitcond993.not, label %mask_block_ok.i.i.i, label %222

__barray_check_bounds.exit932:                    ; preds = %__barray_mask_return.exit, %__barray_mask_return.exit951
  %"136_3.0975" = phi i64 [ %237, %__barray_mask_return.exit951 ], [ 0, %__barray_mask_return.exit ]
  %237 = add nuw nsw i64 %"136_3.0975", 1
  %238 = load i64, i64* %7, align 4
  %239 = and i64 %238, %9
  %.not.i933 = icmp eq i64 %239, 0
  br i1 %.not.i933, label %pow.i.preheader, label %panic.i934

panic.i934:                                       ; preds = %__barray_check_bounds.exit932
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

pow.i.preheader:                                  ; preds = %__barray_check_bounds.exit932
  %240 = xor i64 %238, %9
  store i64 %240, i64* %7, align 4
  %241 = load i64, i64* %12, align 4
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
  %242 = sitofp i64 %storemerge3.i to double
  %243 = fdiv double 1.000000e+00, %242
  %244 = fcmp oeq double %243, 0x7FF0000000000000
  %245 = fcmp oeq double %243, 0xFFF0000000000000
  %246 = fcmp uno double %243, 0.000000e+00
  %247 = or i1 %244, %245
  %248 = or i1 %246, %247
  br i1 %248, label %249, label %__barray_check_bounds.exit937

249:                                              ; preds = %__hugr__.__pow__.379.exit
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([55 x i8], [55 x i8]* @e_tket.rotat.20D0216B.0, i64 0, i64 0))
  unreachable

__barray_check_bounds.exit937:                    ; preds = %__hugr__.__pow__.379.exit
  %250 = sub nuw nsw i64 7, %"136_3.0975"
  %251 = lshr i64 %250, 6
  %252 = getelementptr inbounds i64, i64* %3, i64 %251
  %253 = load i64, i64* %252, align 4
  %254 = shl nuw nsw i64 1, %250
  %255 = and i64 %253, %254
  %.not.i938 = icmp eq i64 %255, 0
  br i1 %.not.i938, label %__barray_check_bounds.exit943, label %panic.i939

panic.i939:                                       ; preds = %__barray_check_bounds.exit937
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit943:                    ; preds = %__barray_check_bounds.exit937
  %256 = xor i64 %253, %254
  store i64 %256, i64* %252, align 4
  %257 = getelementptr inbounds i64, i64* %1, i64 %250
  %258 = load i64, i64* %257, align 4
  %259 = fmul double %243, 0x400921FB54442D18
  %260 = fmul double %259, 5.000000e-01
  %261 = fneg double %260
  tail call void @___rzz(i64 %241, i64 %258, double %261)
  tail call void @___rz(i64 %258, double %260)
  %262 = load i64, i64* %7, align 4
  %263 = and i64 %262, %9
  %.not.i944 = icmp eq i64 %263, 0
  br i1 %.not.i944, label %panic.i945, label %__barray_check_bounds.exit948

panic.i945:                                       ; preds = %__barray_check_bounds.exit943
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit948:                    ; preds = %__barray_check_bounds.exit943
  %264 = xor i64 %262, %9
  store i64 %264, i64* %7, align 4
  store i64 %241, i64* %12, align 4
  %265 = load i64, i64* %252, align 4
  %266 = and i64 %265, %254
  %.not.i949 = icmp eq i64 %266, 0
  br i1 %.not.i949, label %panic.i950, label %__barray_mask_return.exit951

panic.i950:                                       ; preds = %__barray_check_bounds.exit948
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit951:                     ; preds = %__barray_check_bounds.exit948
  %267 = xor i64 %265, %254
  store i64 %267, i64* %252, align 4
  store i64 %258, i64* %257, align 4
  %268 = icmp ult i64 %237, %5
  br i1 %268, label %__barray_check_bounds.exit932, label %cond_exit_174.loopexit
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
