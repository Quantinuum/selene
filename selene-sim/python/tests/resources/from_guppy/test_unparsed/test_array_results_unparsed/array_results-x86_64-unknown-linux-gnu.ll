; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@res_floats.8646C2EF.0 = private constant [21 x i8] c"\14USER:FLOATARR:floats"
@res_ints.B3BC9D53.0 = private constant [17 x i8] c"\10USER:INTARR:ints"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call i8* @heap_alloc(i64 80)
  %1 = bitcast i8* %0 to i64*
  %2 = tail call i8* @heap_alloc(i64 8)
  %3 = bitcast i8* %2 to i64*
  store i64 -1, i64* %3, align 1
  br label %cond_20_case_1

__barray_check_bounds.exit:                       ; preds = %cond_exit_20, %__barray_mask_return.exit
  %"47_0.01019" = phi i64 [ %4, %__barray_mask_return.exit ], [ 0, %cond_exit_20 ]
  %4 = add nuw nsw i64 %"47_0.01019", 1
  %5 = lshr i64 %"47_0.01019", 6
  %6 = getelementptr inbounds i64, i64* %3, i64 %5
  %7 = load i64, i64* %6, align 4
  %8 = shl nuw nsw i64 1, %"47_0.01019"
  %9 = and i64 %7, %8
  %.not.i = icmp eq i64 %9, 0
  br i1 %.not.i, label %__barray_check_bounds.exit909, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit909:                    ; preds = %__barray_check_bounds.exit
  %10 = xor i64 %7, %8
  store i64 %10, i64* %6, align 4
  %11 = getelementptr inbounds i64, i64* %1, i64 %"47_0.01019"
  %12 = load i64, i64* %11, align 4
  tail call void @___rxy(i64 %12, double 0x400921FB54442D18, double 0.000000e+00)
  %13 = load i64, i64* %6, align 4
  %14 = and i64 %13, %8
  %.not.i910 = icmp eq i64 %14, 0
  br i1 %.not.i910, label %panic.i911, label %__barray_mask_return.exit

panic.i911:                                       ; preds = %__barray_check_bounds.exit909
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit909
  %15 = xor i64 %13, %8
  store i64 %15, i64* %6, align 4
  store i64 %12, i64* %11, align 4
  %exitcond1037.not = icmp eq i64 %4, 10
  br i1 %exitcond1037.not, label %cond_exit_163, label %__barray_check_bounds.exit

cond_20_case_1:                                   ; preds = %alloca_block, %cond_exit_20
  %"15_0.sroa.0.01018" = phi i64 [ 0, %alloca_block ], [ %16, %cond_exit_20 ]
  %16 = add nuw nsw i64 %"15_0.sroa.0.01018", 1
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
  br i1 %.fca.0.extract.i, label %__barray_check_bounds.exit919, label %cond_409_case_0.i

cond_409_case_0.i:                                ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit919:                    ; preds = %id_bb.i
  %19 = lshr i64 %"15_0.sroa.0.01018", 6
  %20 = getelementptr inbounds i64, i64* %3, i64 %19
  %21 = load i64, i64* %20, align 4
  %22 = shl nuw nsw i64 1, %"15_0.sroa.0.01018"
  %23 = and i64 %21, %22
  %.not.i920 = icmp eq i64 %23, 0
  br i1 %.not.i920, label %panic.i921, label %cond_exit_20

panic.i921:                                       ; preds = %__barray_check_bounds.exit919
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_20:                                     ; preds = %__barray_check_bounds.exit919
  %.fca.1.extract.i = extractvalue { i1, i64 } %18, 1
  %24 = xor i64 %21, %22
  store i64 %24, i64* %20, align 4
  %25 = getelementptr inbounds i64, i64* %1, i64 %"15_0.sroa.0.01018"
  store i64 %.fca.1.extract.i, i64* %25, align 4
  %exitcond.not = icmp eq i64 %16, 10
  br i1 %exitcond.not, label %__barray_check_bounds.exit, label %cond_20_case_1

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$measure_array$$n(10).484.exit"
  %26 = tail call i8* @heap_alloc(i64 240)
  %27 = bitcast i8* %26 to { i1, i64, i1 }*
  %28 = tail call i8* @heap_alloc(i64 8)
  %29 = bitcast i8* %28 to i64*
  store i64 0, i64* %29, align 1
  %30 = bitcast i8* %260 to { i1, { i1, i64, i1 } }*
  br label %31

mask_block_err.i:                                 ; preds = %"__hugr__.$measure_array$$n(10).484.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

31:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_386.389.exit
  %storemerge9061026 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %49, %__hugr__.const_fun_386.389.exit ]
  %32 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %47, %__hugr__.const_fun_386.389.exit ]
  %33 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %254, i64 %storemerge9061026
  %34 = load { i1, i64, i1 }, { i1, i64, i1 }* %33, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %34, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %34, 1
  br i1 %.fca.0.extract118.i, label %cond_653_case_1.i, label %cond_exit_653.i

cond_653_case_1.i:                                ; preds = %31
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %35 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %cond_exit_653.i

cond_exit_653.i:                                  ; preds = %cond_653_case_1.i, %31
  %.pn.i = phi { i1, i64, i1 } [ %35, %cond_653_case_1.i ], [ %34, %31 ]
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %36 = icmp ult i64 %32, 10
  br i1 %36, label %37, label %cond_656_case_0.i

37:                                               ; preds = %cond_exit_653.i
  %38 = lshr i64 %32, 6
  %39 = getelementptr inbounds i64, i64* %262, i64 %38
  %40 = load i64, i64* %39, align 4
  %41 = shl nuw nsw i64 1, %32
  %42 = and i64 %40, %41
  %.not.i.i = icmp eq i64 %42, 0
  br i1 %.not.i.i, label %cond_656_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %37
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_656_case_0.i:                                ; preds = %cond_exit_653.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_656_case_1.i:                                ; preds = %37
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %34, i1 %"04.sroa.6.0.i", 2
  %43 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %44 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %30, i64 %32
  %45 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %44, i64 0, i32 0
  %46 = load i1, i1* %45, align 1
  store { i1, { i1, i64, i1 } } %43, { i1, { i1, i64, i1 } }* %44, align 4
  br i1 %46, label %cond_657_case_1.i, label %__hugr__.const_fun_386.389.exit

cond_657_case_1.i:                                ; preds = %cond_656_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_386.389.exit:                  ; preds = %cond_656_case_1.i
  %47 = add nuw nsw i64 %32, 1
  %48 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %27, i64 %storemerge9061026
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %48, align 4
  %49 = add nuw nsw i64 %storemerge9061026, 1
  %exitcond1039.not = icmp eq i64 %49, 10
  br i1 %exitcond1039.not, label %mask_block_ok.i926, label %31

mask_block_ok.i926:                               ; preds = %__hugr__.const_fun_386.389.exit
  tail call void @heap_free(i8* nonnull %253)
  tail call void @heap_free(i8* %255)
  %50 = load i64, i64* %262, align 4
  %51 = and i64 %50, 1023
  store i64 %51, i64* %262, align 4
  %52 = icmp eq i64 %51, 0
  br i1 %52, label %__barray_check_none_borrowed.exit928, label %mask_block_err.i927

mask_block_err.i927:                              ; preds = %mask_block_ok.i926
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit928:             ; preds = %mask_block_ok.i926
  %53 = tail call i8* @heap_alloc(i64 240)
  %54 = bitcast i8* %53 to { i1, i64, i1 }*
  %55 = tail call i8* @heap_alloc(i64 8)
  %56 = bitcast i8* %55 to i64*
  store i64 0, i64* %56, align 1
  %57 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %30, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %57, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_382.386.exit, label %cond_698_case_0.i

cond_698_case_0.i:                                ; preds = %__hugr__.const_fun_382.386.exit.8, %__hugr__.const_fun_382.386.exit.7, %__hugr__.const_fun_382.386.exit.6, %__hugr__.const_fun_382.386.exit.5, %__hugr__.const_fun_382.386.exit.4, %__hugr__.const_fun_382.386.exit.3, %__hugr__.const_fun_382.386.exit.2, %__hugr__.const_fun_382.386.exit.1, %__hugr__.const_fun_382.386.exit, %__barray_check_none_borrowed.exit928
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_382.386.exit:                  ; preds = %__barray_check_none_borrowed.exit928
  %58 = extractvalue { i1, { i1, i64, i1 } } %57, 1
  store { i1, i64, i1 } %58, { i1, i64, i1 }* %54, align 4
  %59 = getelementptr inbounds i8, i8* %260, i64 32
  %60 = bitcast i8* %59 to { i1, { i1, i64, i1 } }*
  %61 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %60, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %61, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_382.386.exit.1, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.1:                ; preds = %__hugr__.const_fun_382.386.exit
  %62 = extractvalue { i1, { i1, i64, i1 } } %61, 1
  %63 = getelementptr inbounds i8, i8* %53, i64 24
  %64 = bitcast i8* %63 to { i1, i64, i1 }*
  store { i1, i64, i1 } %62, { i1, i64, i1 }* %64, align 4
  %65 = getelementptr inbounds i8, i8* %260, i64 64
  %66 = bitcast i8* %65 to { i1, { i1, i64, i1 } }*
  %67 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %66, align 4
  %.fca.0.extract11.i.2 = extractvalue { i1, { i1, i64, i1 } } %67, 0
  br i1 %.fca.0.extract11.i.2, label %__hugr__.const_fun_382.386.exit.2, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.2:                ; preds = %__hugr__.const_fun_382.386.exit.1
  %68 = extractvalue { i1, { i1, i64, i1 } } %67, 1
  %69 = getelementptr inbounds i8, i8* %53, i64 48
  %70 = bitcast i8* %69 to { i1, i64, i1 }*
  store { i1, i64, i1 } %68, { i1, i64, i1 }* %70, align 4
  %71 = getelementptr inbounds i8, i8* %260, i64 96
  %72 = bitcast i8* %71 to { i1, { i1, i64, i1 } }*
  %73 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %72, align 4
  %.fca.0.extract11.i.3 = extractvalue { i1, { i1, i64, i1 } } %73, 0
  br i1 %.fca.0.extract11.i.3, label %__hugr__.const_fun_382.386.exit.3, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.3:                ; preds = %__hugr__.const_fun_382.386.exit.2
  %74 = extractvalue { i1, { i1, i64, i1 } } %73, 1
  %75 = getelementptr inbounds i8, i8* %53, i64 72
  %76 = bitcast i8* %75 to { i1, i64, i1 }*
  store { i1, i64, i1 } %74, { i1, i64, i1 }* %76, align 4
  %77 = getelementptr inbounds i8, i8* %260, i64 128
  %78 = bitcast i8* %77 to { i1, { i1, i64, i1 } }*
  %79 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %78, align 4
  %.fca.0.extract11.i.4 = extractvalue { i1, { i1, i64, i1 } } %79, 0
  br i1 %.fca.0.extract11.i.4, label %__hugr__.const_fun_382.386.exit.4, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.4:                ; preds = %__hugr__.const_fun_382.386.exit.3
  %80 = extractvalue { i1, { i1, i64, i1 } } %79, 1
  %81 = getelementptr inbounds i8, i8* %53, i64 96
  %82 = bitcast i8* %81 to { i1, i64, i1 }*
  store { i1, i64, i1 } %80, { i1, i64, i1 }* %82, align 4
  %83 = getelementptr inbounds i8, i8* %260, i64 160
  %84 = bitcast i8* %83 to { i1, { i1, i64, i1 } }*
  %85 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %84, align 4
  %.fca.0.extract11.i.5 = extractvalue { i1, { i1, i64, i1 } } %85, 0
  br i1 %.fca.0.extract11.i.5, label %__hugr__.const_fun_382.386.exit.5, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.5:                ; preds = %__hugr__.const_fun_382.386.exit.4
  %86 = extractvalue { i1, { i1, i64, i1 } } %85, 1
  %87 = getelementptr inbounds i8, i8* %53, i64 120
  %88 = bitcast i8* %87 to { i1, i64, i1 }*
  store { i1, i64, i1 } %86, { i1, i64, i1 }* %88, align 4
  %89 = getelementptr inbounds i8, i8* %260, i64 192
  %90 = bitcast i8* %89 to { i1, { i1, i64, i1 } }*
  %91 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %90, align 4
  %.fca.0.extract11.i.6 = extractvalue { i1, { i1, i64, i1 } } %91, 0
  br i1 %.fca.0.extract11.i.6, label %__hugr__.const_fun_382.386.exit.6, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.6:                ; preds = %__hugr__.const_fun_382.386.exit.5
  %92 = extractvalue { i1, { i1, i64, i1 } } %91, 1
  %93 = getelementptr inbounds i8, i8* %53, i64 144
  %94 = bitcast i8* %93 to { i1, i64, i1 }*
  store { i1, i64, i1 } %92, { i1, i64, i1 }* %94, align 4
  %95 = getelementptr inbounds i8, i8* %260, i64 224
  %96 = bitcast i8* %95 to { i1, { i1, i64, i1 } }*
  %97 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %96, align 4
  %.fca.0.extract11.i.7 = extractvalue { i1, { i1, i64, i1 } } %97, 0
  br i1 %.fca.0.extract11.i.7, label %__hugr__.const_fun_382.386.exit.7, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.7:                ; preds = %__hugr__.const_fun_382.386.exit.6
  %98 = extractvalue { i1, { i1, i64, i1 } } %97, 1
  %99 = getelementptr inbounds i8, i8* %53, i64 168
  %100 = bitcast i8* %99 to { i1, i64, i1 }*
  store { i1, i64, i1 } %98, { i1, i64, i1 }* %100, align 4
  %101 = getelementptr inbounds i8, i8* %260, i64 256
  %102 = bitcast i8* %101 to { i1, { i1, i64, i1 } }*
  %103 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %102, align 4
  %.fca.0.extract11.i.8 = extractvalue { i1, { i1, i64, i1 } } %103, 0
  br i1 %.fca.0.extract11.i.8, label %__hugr__.const_fun_382.386.exit.8, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.8:                ; preds = %__hugr__.const_fun_382.386.exit.7
  %104 = extractvalue { i1, { i1, i64, i1 } } %103, 1
  %105 = getelementptr inbounds i8, i8* %53, i64 192
  %106 = bitcast i8* %105 to { i1, i64, i1 }*
  store { i1, i64, i1 } %104, { i1, i64, i1 }* %106, align 4
  %107 = getelementptr inbounds i8, i8* %260, i64 288
  %108 = bitcast i8* %107 to { i1, { i1, i64, i1 } }*
  %109 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %108, align 4
  %.fca.0.extract11.i.9 = extractvalue { i1, { i1, i64, i1 } } %109, 0
  br i1 %.fca.0.extract11.i.9, label %__hugr__.const_fun_382.386.exit.9, label %cond_698_case_0.i

__hugr__.const_fun_382.386.exit.9:                ; preds = %__hugr__.const_fun_382.386.exit.8
  %110 = extractvalue { i1, { i1, i64, i1 } } %109, 1
  %111 = getelementptr inbounds i8, i8* %53, i64 216
  %112 = bitcast i8* %111 to { i1, i64, i1 }*
  store { i1, i64, i1 } %110, { i1, i64, i1 }* %112, align 4
  tail call void @heap_free(i8* nonnull %260)
  tail call void @heap_free(i8* nonnull %261)
  br label %__barray_check_bounds.exit933

cond_606_case_0:                                  ; preds = %cond_exit_606
  %113 = load i64, i64* %56, align 4
  %114 = or i64 %113, -1024
  store i64 %114, i64* %56, align 4
  %115 = icmp eq i64 %114, -1
  br i1 %115, label %loop_out150, label %mask_block_err.i931

mask_block_err.i931:                              ; preds = %cond_606_case_0
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit933:                    ; preds = %__hugr__.const_fun_382.386.exit.9, %cond_exit_606
  %"603_0.01049" = phi i64 [ 0, %__hugr__.const_fun_382.386.exit.9 ], [ %116, %cond_exit_606 ]
  %116 = add nuw nsw i64 %"603_0.01049", 1
  %117 = lshr i64 %"603_0.01049", 6
  %118 = getelementptr inbounds i64, i64* %56, i64 %117
  %119 = load i64, i64* %118, align 4
  %120 = shl nuw nsw i64 1, %"603_0.01049"
  %121 = and i64 %119, %120
  %.not = icmp eq i64 %121, 0
  br i1 %.not, label %__barray_mask_borrow.exit938, label %cond_exit_606

__barray_mask_borrow.exit938:                     ; preds = %__barray_check_bounds.exit933
  %122 = xor i64 %119, %120
  store i64 %122, i64* %118, align 4
  %123 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %54, i64 %"603_0.01049"
  %124 = load { i1, i64, i1 }, { i1, i64, i1 }* %123, align 4
  %.fca.0.extract593 = extractvalue { i1, i64, i1 } %124, 0
  br i1 %.fca.0.extract593, label %cond_629_case_1, label %cond_exit_606

cond_exit_606:                                    ; preds = %cond_629_case_1, %__barray_mask_borrow.exit938, %__barray_check_bounds.exit933
  %125 = icmp ult i64 %"603_0.01049", 9
  br i1 %125, label %__barray_check_bounds.exit933, label %cond_606_case_0

loop_out150:                                      ; preds = %cond_606_case_0
  tail call void @heap_free(i8* %53)
  tail call void @heap_free(i8* nonnull %55)
  %126 = load i64, i64* %29, align 4
  %127 = and i64 %126, 1023
  store i64 %127, i64* %29, align 4
  %128 = icmp eq i64 %127, 0
  br i1 %128, label %__barray_check_none_borrowed.exit943, label %mask_block_err.i942

__barray_check_none_borrowed.exit943:             ; preds = %loop_out150
  %129 = tail call i8* @heap_alloc(i64 10)
  %130 = tail call i8* @heap_alloc(i64 8)
  %131 = bitcast i8* %130 to i64*
  store i64 0, i64* %131, align 1
  %132 = load { i1, i64, i1 }, { i1, i64, i1 }* %27, align 4
  %.fca.0.extract.i944 = extractvalue { i1, i64, i1 } %132, 0
  %.fca.1.extract.i945 = extractvalue { i1, i64, i1 } %132, 1
  br i1 %.fca.0.extract.i944, label %cond_453_case_1.i, label %cond_453_case_0.i

mask_block_err.i942:                              ; preds = %loop_out150
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_629_case_1:                                  ; preds = %__barray_mask_borrow.exit938
  %.fca.1.extract594 = extractvalue { i1, i64, i1 } %124, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract594)
  br label %cond_exit_606

cond_453_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit943
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %132, 2
  br label %__hugr__.array.__read_bool.3.343.exit

cond_453_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit943
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945)
  br label %__hugr__.array.__read_bool.3.343.exit

__hugr__.array.__read_bool.3.343.exit:            ; preds = %cond_453_case_0.i, %cond_453_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_453_case_1.i ], [ %.fca.2.extract.i, %cond_453_case_0.i ]
  %133 = bitcast i8* %129 to i1*
  store i1 %"03.0.i", i1* %133, align 1
  %134 = getelementptr inbounds i8, i8* %26, i64 24
  %135 = bitcast i8* %134 to { i1, i64, i1 }*
  %136 = load { i1, i64, i1 }, { i1, i64, i1 }* %135, align 4
  %.fca.0.extract.i944.1 = extractvalue { i1, i64, i1 } %136, 0
  %.fca.1.extract.i945.1 = extractvalue { i1, i64, i1 } %136, 1
  br i1 %.fca.0.extract.i944.1, label %cond_453_case_1.i.1, label %cond_453_case_0.i.1

cond_453_case_0.i.1:                              ; preds = %__hugr__.array.__read_bool.3.343.exit
  %.fca.2.extract.i.1 = extractvalue { i1, i64, i1 } %136, 2
  br label %__hugr__.array.__read_bool.3.343.exit.1

cond_453_case_1.i.1:                              ; preds = %__hugr__.array.__read_bool.3.343.exit
  %read_bool.i.1 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.1)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.1)
  br label %__hugr__.array.__read_bool.3.343.exit.1

__hugr__.array.__read_bool.3.343.exit.1:          ; preds = %cond_453_case_1.i.1, %cond_453_case_0.i.1
  %"03.0.i.1" = phi i1 [ %read_bool.i.1, %cond_453_case_1.i.1 ], [ %.fca.2.extract.i.1, %cond_453_case_0.i.1 ]
  %137 = getelementptr inbounds i8, i8* %129, i64 1
  %138 = bitcast i8* %137 to i1*
  store i1 %"03.0.i.1", i1* %138, align 1
  %139 = getelementptr inbounds i8, i8* %26, i64 48
  %140 = bitcast i8* %139 to { i1, i64, i1 }*
  %141 = load { i1, i64, i1 }, { i1, i64, i1 }* %140, align 4
  %.fca.0.extract.i944.2 = extractvalue { i1, i64, i1 } %141, 0
  %.fca.1.extract.i945.2 = extractvalue { i1, i64, i1 } %141, 1
  br i1 %.fca.0.extract.i944.2, label %cond_453_case_1.i.2, label %cond_453_case_0.i.2

cond_453_case_0.i.2:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.1
  %.fca.2.extract.i.2 = extractvalue { i1, i64, i1 } %141, 2
  br label %__hugr__.array.__read_bool.3.343.exit.2

cond_453_case_1.i.2:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.1
  %read_bool.i.2 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.2)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.2)
  br label %__hugr__.array.__read_bool.3.343.exit.2

__hugr__.array.__read_bool.3.343.exit.2:          ; preds = %cond_453_case_1.i.2, %cond_453_case_0.i.2
  %"03.0.i.2" = phi i1 [ %read_bool.i.2, %cond_453_case_1.i.2 ], [ %.fca.2.extract.i.2, %cond_453_case_0.i.2 ]
  %142 = getelementptr inbounds i8, i8* %129, i64 2
  %143 = bitcast i8* %142 to i1*
  store i1 %"03.0.i.2", i1* %143, align 1
  %144 = getelementptr inbounds i8, i8* %26, i64 72
  %145 = bitcast i8* %144 to { i1, i64, i1 }*
  %146 = load { i1, i64, i1 }, { i1, i64, i1 }* %145, align 4
  %.fca.0.extract.i944.3 = extractvalue { i1, i64, i1 } %146, 0
  %.fca.1.extract.i945.3 = extractvalue { i1, i64, i1 } %146, 1
  br i1 %.fca.0.extract.i944.3, label %cond_453_case_1.i.3, label %cond_453_case_0.i.3

cond_453_case_0.i.3:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.2
  %.fca.2.extract.i.3 = extractvalue { i1, i64, i1 } %146, 2
  br label %__hugr__.array.__read_bool.3.343.exit.3

cond_453_case_1.i.3:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.2
  %read_bool.i.3 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.3)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.3)
  br label %__hugr__.array.__read_bool.3.343.exit.3

__hugr__.array.__read_bool.3.343.exit.3:          ; preds = %cond_453_case_1.i.3, %cond_453_case_0.i.3
  %"03.0.i.3" = phi i1 [ %read_bool.i.3, %cond_453_case_1.i.3 ], [ %.fca.2.extract.i.3, %cond_453_case_0.i.3 ]
  %147 = getelementptr inbounds i8, i8* %129, i64 3
  %148 = bitcast i8* %147 to i1*
  store i1 %"03.0.i.3", i1* %148, align 1
  %149 = getelementptr inbounds i8, i8* %26, i64 96
  %150 = bitcast i8* %149 to { i1, i64, i1 }*
  %151 = load { i1, i64, i1 }, { i1, i64, i1 }* %150, align 4
  %.fca.0.extract.i944.4 = extractvalue { i1, i64, i1 } %151, 0
  %.fca.1.extract.i945.4 = extractvalue { i1, i64, i1 } %151, 1
  br i1 %.fca.0.extract.i944.4, label %cond_453_case_1.i.4, label %cond_453_case_0.i.4

cond_453_case_0.i.4:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.3
  %.fca.2.extract.i.4 = extractvalue { i1, i64, i1 } %151, 2
  br label %__hugr__.array.__read_bool.3.343.exit.4

cond_453_case_1.i.4:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.3
  %read_bool.i.4 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.4)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.4)
  br label %__hugr__.array.__read_bool.3.343.exit.4

__hugr__.array.__read_bool.3.343.exit.4:          ; preds = %cond_453_case_1.i.4, %cond_453_case_0.i.4
  %"03.0.i.4" = phi i1 [ %read_bool.i.4, %cond_453_case_1.i.4 ], [ %.fca.2.extract.i.4, %cond_453_case_0.i.4 ]
  %152 = getelementptr inbounds i8, i8* %129, i64 4
  %153 = bitcast i8* %152 to i1*
  store i1 %"03.0.i.4", i1* %153, align 1
  %154 = getelementptr inbounds i8, i8* %26, i64 120
  %155 = bitcast i8* %154 to { i1, i64, i1 }*
  %156 = load { i1, i64, i1 }, { i1, i64, i1 }* %155, align 4
  %.fca.0.extract.i944.5 = extractvalue { i1, i64, i1 } %156, 0
  %.fca.1.extract.i945.5 = extractvalue { i1, i64, i1 } %156, 1
  br i1 %.fca.0.extract.i944.5, label %cond_453_case_1.i.5, label %cond_453_case_0.i.5

cond_453_case_0.i.5:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.4
  %.fca.2.extract.i.5 = extractvalue { i1, i64, i1 } %156, 2
  br label %__hugr__.array.__read_bool.3.343.exit.5

cond_453_case_1.i.5:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.4
  %read_bool.i.5 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.5)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.5)
  br label %__hugr__.array.__read_bool.3.343.exit.5

__hugr__.array.__read_bool.3.343.exit.5:          ; preds = %cond_453_case_1.i.5, %cond_453_case_0.i.5
  %"03.0.i.5" = phi i1 [ %read_bool.i.5, %cond_453_case_1.i.5 ], [ %.fca.2.extract.i.5, %cond_453_case_0.i.5 ]
  %157 = getelementptr inbounds i8, i8* %129, i64 5
  %158 = bitcast i8* %157 to i1*
  store i1 %"03.0.i.5", i1* %158, align 1
  %159 = getelementptr inbounds i8, i8* %26, i64 144
  %160 = bitcast i8* %159 to { i1, i64, i1 }*
  %161 = load { i1, i64, i1 }, { i1, i64, i1 }* %160, align 4
  %.fca.0.extract.i944.6 = extractvalue { i1, i64, i1 } %161, 0
  %.fca.1.extract.i945.6 = extractvalue { i1, i64, i1 } %161, 1
  br i1 %.fca.0.extract.i944.6, label %cond_453_case_1.i.6, label %cond_453_case_0.i.6

cond_453_case_0.i.6:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.5
  %.fca.2.extract.i.6 = extractvalue { i1, i64, i1 } %161, 2
  br label %__hugr__.array.__read_bool.3.343.exit.6

cond_453_case_1.i.6:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.5
  %read_bool.i.6 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.6)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.6)
  br label %__hugr__.array.__read_bool.3.343.exit.6

__hugr__.array.__read_bool.3.343.exit.6:          ; preds = %cond_453_case_1.i.6, %cond_453_case_0.i.6
  %"03.0.i.6" = phi i1 [ %read_bool.i.6, %cond_453_case_1.i.6 ], [ %.fca.2.extract.i.6, %cond_453_case_0.i.6 ]
  %162 = getelementptr inbounds i8, i8* %129, i64 6
  %163 = bitcast i8* %162 to i1*
  store i1 %"03.0.i.6", i1* %163, align 1
  %164 = getelementptr inbounds i8, i8* %26, i64 168
  %165 = bitcast i8* %164 to { i1, i64, i1 }*
  %166 = load { i1, i64, i1 }, { i1, i64, i1 }* %165, align 4
  %.fca.0.extract.i944.7 = extractvalue { i1, i64, i1 } %166, 0
  %.fca.1.extract.i945.7 = extractvalue { i1, i64, i1 } %166, 1
  br i1 %.fca.0.extract.i944.7, label %cond_453_case_1.i.7, label %cond_453_case_0.i.7

cond_453_case_0.i.7:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.6
  %.fca.2.extract.i.7 = extractvalue { i1, i64, i1 } %166, 2
  br label %__hugr__.array.__read_bool.3.343.exit.7

cond_453_case_1.i.7:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.6
  %read_bool.i.7 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.7)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.7)
  br label %__hugr__.array.__read_bool.3.343.exit.7

__hugr__.array.__read_bool.3.343.exit.7:          ; preds = %cond_453_case_1.i.7, %cond_453_case_0.i.7
  %"03.0.i.7" = phi i1 [ %read_bool.i.7, %cond_453_case_1.i.7 ], [ %.fca.2.extract.i.7, %cond_453_case_0.i.7 ]
  %167 = getelementptr inbounds i8, i8* %129, i64 7
  %168 = bitcast i8* %167 to i1*
  store i1 %"03.0.i.7", i1* %168, align 1
  %169 = getelementptr inbounds i8, i8* %26, i64 192
  %170 = bitcast i8* %169 to { i1, i64, i1 }*
  %171 = load { i1, i64, i1 }, { i1, i64, i1 }* %170, align 4
  %.fca.0.extract.i944.8 = extractvalue { i1, i64, i1 } %171, 0
  %.fca.1.extract.i945.8 = extractvalue { i1, i64, i1 } %171, 1
  br i1 %.fca.0.extract.i944.8, label %cond_453_case_1.i.8, label %cond_453_case_0.i.8

cond_453_case_0.i.8:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.7
  %.fca.2.extract.i.8 = extractvalue { i1, i64, i1 } %171, 2
  br label %__hugr__.array.__read_bool.3.343.exit.8

cond_453_case_1.i.8:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.7
  %read_bool.i.8 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.8)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.8)
  br label %__hugr__.array.__read_bool.3.343.exit.8

__hugr__.array.__read_bool.3.343.exit.8:          ; preds = %cond_453_case_1.i.8, %cond_453_case_0.i.8
  %"03.0.i.8" = phi i1 [ %read_bool.i.8, %cond_453_case_1.i.8 ], [ %.fca.2.extract.i.8, %cond_453_case_0.i.8 ]
  %172 = getelementptr inbounds i8, i8* %129, i64 8
  %173 = bitcast i8* %172 to i1*
  store i1 %"03.0.i.8", i1* %173, align 1
  %174 = getelementptr inbounds i8, i8* %26, i64 216
  %175 = bitcast i8* %174 to { i1, i64, i1 }*
  %176 = load { i1, i64, i1 }, { i1, i64, i1 }* %175, align 4
  %.fca.0.extract.i944.9 = extractvalue { i1, i64, i1 } %176, 0
  %.fca.1.extract.i945.9 = extractvalue { i1, i64, i1 } %176, 1
  br i1 %.fca.0.extract.i944.9, label %cond_453_case_1.i.9, label %cond_453_case_0.i.9

cond_453_case_0.i.9:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.8
  %.fca.2.extract.i.9 = extractvalue { i1, i64, i1 } %176, 2
  br label %__hugr__.array.__read_bool.3.343.exit.9

cond_453_case_1.i.9:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.8
  %read_bool.i.9 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.9)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.9)
  br label %__hugr__.array.__read_bool.3.343.exit.9

__hugr__.array.__read_bool.3.343.exit.9:          ; preds = %cond_453_case_1.i.9, %cond_453_case_0.i.9
  %"03.0.i.9" = phi i1 [ %read_bool.i.9, %cond_453_case_1.i.9 ], [ %.fca.2.extract.i.9, %cond_453_case_0.i.9 ]
  %177 = getelementptr inbounds i8, i8* %129, i64 9
  %178 = bitcast i8* %177 to i1*
  store i1 %"03.0.i.9", i1* %178, align 1
  tail call void @heap_free(i8* nonnull %26)
  tail call void @heap_free(i8* nonnull %28)
  %179 = load i64, i64* %131, align 4
  %180 = and i64 %179, 1023
  store i64 %180, i64* %131, align 4
  %181 = icmp eq i64 %180, 0
  br i1 %181, label %__barray_check_none_borrowed.exit950, label %mask_block_err.i949

__barray_check_none_borrowed.exit950:             ; preds = %__hugr__.array.__read_bool.3.343.exit.9
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %182 = alloca [10 x i1], align 1
  %.sub = getelementptr inbounds [10 x i1], [10 x i1]* %182, i64 0, i64 0
  %183 = bitcast [10 x i1]* %182 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(10) %183, i8 0, i64 10, i1 false)
  store i32 10, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %184 = bitcast i1** %arr_ptr to i8**
  store i8* %129, i8** %184, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @res_bools.B1D99BB9.0, i64 0, i64 0), i64 18, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  br label %pow.i.preheader

mask_block_err.i949:                              ; preds = %__hugr__.array.__read_bool.3.343.exit.9
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

pow.i.preheader:                                  ; preds = %__barray_check_none_borrowed.exit950, %cond_exit_91
  %"86_2.01050" = phi i64 [ 0, %__barray_check_none_borrowed.exit950 ], [ %185, %cond_exit_91 ]
  %185 = add nuw nsw i64 %"86_2.01050", 1
  br label %pow.i

pow.i:                                            ; preds = %pow.i.preheader, %pow_body.i
  %storemerge1.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %pow.i.preheader ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"86_2.01050", %pow.i.preheader ]
  switch i64 %storemerge.i, label %pow_body.i [
    i64 1, label %__barray_check_bounds.exit958.loopexit
    i64 0, label %__barray_check_bounds.exit958
  ]

pow_body.i:                                       ; preds = %pow.i
  %new_acc.i = shl i64 %storemerge1.i, 1
  %new_exp.i = add i64 %storemerge.i, -1
  br label %pow.i

__barray_check_bounds.exit958.loopexit:           ; preds = %pow.i
  br label %__barray_check_bounds.exit958

__barray_check_bounds.exit958:                    ; preds = %pow.i, %__barray_check_bounds.exit958.loopexit
  %storemerge3.i = phi i64 [ %storemerge1.i, %__barray_check_bounds.exit958.loopexit ], [ 1, %pow.i ]
  %186 = lshr i64 %"86_2.01050", 6
  %187 = getelementptr inbounds i64, i64* %252, i64 %186
  %188 = load i64, i64* %187, align 4
  %189 = shl nuw nsw i64 1, %"86_2.01050"
  %190 = and i64 %188, %189
  %.not.i959 = icmp eq i64 %190, 0
  br i1 %.not.i959, label %panic.i960, label %cond_exit_91

panic.i960:                                       ; preds = %__barray_check_bounds.exit958
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_91:                                     ; preds = %__barray_check_bounds.exit958
  %191 = sitofp i64 %storemerge3.i to double
  %192 = fdiv double 1.000000e+00, %191
  %193 = xor i64 %188, %189
  store i64 %193, i64* %187, align 4
  %194 = getelementptr inbounds double, double* %250, i64 %"86_2.01050"
  store double %192, double* %194, align 8
  %exitcond1042.not = icmp eq i64 %185, 10
  br i1 %exitcond1042.not, label %loop_out223, label %pow.i.preheader

loop_out223:                                      ; preds = %cond_exit_91
  %195 = load i64, i64* %252, align 4
  %196 = and i64 %195, 1023
  store i64 %196, i64* %252, align 4
  %197 = icmp eq i64 %196, 0
  br i1 %197, label %__barray_check_none_borrowed.exit966, label %mask_block_err.i965

__barray_check_none_borrowed.exit966:             ; preds = %loop_out223
  %198 = call i8* @heap_alloc(i64 80)
  %199 = bitcast i8* %198 to double*
  %200 = call i8* @heap_alloc(i64 8)
  %201 = bitcast i8* %200 to i64*
  store i64 0, i64* %201, align 1
  call void @llvm.memcpy.p0f64.p0f64.i64(double* noundef nonnull align 1 dereferenceable(80) %199, double* noundef nonnull align 1 dereferenceable(80) %250, i64 80, i1 false)
  call void @heap_free(i8* %198)
  %202 = load i64, i64* %252, align 4
  %203 = and i64 %202, 1023
  store i64 %203, i64* %252, align 4
  %204 = icmp eq i64 %203, 0
  br i1 %204, label %__barray_check_none_borrowed.exit971, label %mask_block_err.i970

mask_block_err.i965:                              ; preds = %loop_out223
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit971:             ; preds = %__barray_check_none_borrowed.exit966
  %out_arr_alloca303 = alloca <{ i32, i32, double*, i1* }>, align 8
  %x_ptr304 = getelementptr inbounds <{ i32, i32, double*, i1* }>, <{ i32, i32, double*, i1* }>* %out_arr_alloca303, i64 0, i32 0
  %y_ptr305 = getelementptr inbounds <{ i32, i32, double*, i1* }>, <{ i32, i32, double*, i1* }>* %out_arr_alloca303, i64 0, i32 1
  %arr_ptr306 = getelementptr inbounds <{ i32, i32, double*, i1* }>, <{ i32, i32, double*, i1* }>* %out_arr_alloca303, i64 0, i32 2
  %mask_ptr307 = getelementptr inbounds <{ i32, i32, double*, i1* }>, <{ i32, i32, double*, i1* }>* %out_arr_alloca303, i64 0, i32 3
  %205 = alloca [10 x i1], align 1
  %.sub781 = getelementptr inbounds [10 x i1], [10 x i1]* %205, i64 0, i64 0
  %206 = bitcast [10 x i1]* %205 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(10) %206, i8 0, i64 10, i1 false)
  store i32 10, i32* %x_ptr304, align 8
  store i32 1, i32* %y_ptr305, align 4
  %207 = bitcast double** %arr_ptr306 to i8**
  store i8* %249, i8** %207, align 8
  store i1* %.sub781, i1** %mask_ptr307, align 8
  call void @print_float_arr(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @res_floats.8646C2EF.0, i64 0, i64 0), i64 20, <{ i32, i32, double*, i1* }>* nonnull %out_arr_alloca303)
  br label %__barray_check_bounds.exit979

mask_block_err.i970:                              ; preds = %__barray_check_none_borrowed.exit966
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit979:                    ; preds = %cond_exit_133.1, %__barray_check_none_borrowed.exit971
  %"128_0.sroa.0.01030" = phi i64 [ 0, %__barray_check_none_borrowed.exit971 ], [ %217, %cond_exit_133.1 ]
  %208 = or i64 %"128_0.sroa.0.01030", 1
  %209 = lshr i64 %"128_0.sroa.0.01030", 6
  %210 = getelementptr inbounds i64, i64* %248, i64 %209
  %211 = load i64, i64* %210, align 4
  %212 = and i64 %"128_0.sroa.0.01030", 62
  %213 = shl nuw i64 1, %212
  %214 = and i64 %211, %213
  %.not.i980 = icmp eq i64 %214, 0
  br i1 %.not.i980, label %panic.i981, label %cond_exit_133

panic.i981:                                       ; preds = %cond_exit_133, %__barray_check_bounds.exit979
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_133:                                    ; preds = %__barray_check_bounds.exit979
  %215 = xor i64 %211, %213
  store i64 %215, i64* %210, align 4
  %216 = getelementptr inbounds i64, i64* %246, i64 %"128_0.sroa.0.01030"
  store i64 %"128_0.sroa.0.01030", i64* %216, align 4
  %217 = add nuw nsw i64 %"128_0.sroa.0.01030", 2
  %218 = lshr i64 %"128_0.sroa.0.01030", 6
  %219 = getelementptr inbounds i64, i64* %248, i64 %218
  %220 = load i64, i64* %219, align 4
  %221 = and i64 %208, 63
  %222 = shl nuw i64 1, %221
  %223 = and i64 %220, %222
  %.not.i980.1 = icmp eq i64 %223, 0
  br i1 %.not.i980.1, label %panic.i981, label %cond_exit_133.1

cond_exit_133.1:                                  ; preds = %cond_exit_133
  %224 = xor i64 %220, %222
  store i64 %224, i64* %219, align 4
  %225 = getelementptr inbounds i64, i64* %246, i64 %208
  store i64 %208, i64* %225, align 4
  %exitcond1043.not.1 = icmp eq i64 %217, 100
  br i1 %exitcond1043.not.1, label %loop_out315, label %__barray_check_bounds.exit979

loop_out315:                                      ; preds = %cond_exit_133.1
  %226 = getelementptr inbounds i8, i8* %247, i64 8
  %227 = bitcast i8* %226 to i64*
  %228 = load i64, i64* %227, align 4
  %229 = and i64 %228, 68719476735
  store i64 %229, i64* %227, align 4
  %230 = load i64, i64* %248, align 4
  %231 = icmp eq i64 %230, 0
  %232 = icmp eq i64 %229, 0
  %or.cond = select i1 %231, i1 %232, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit987, label %mask_block_err.i986

__barray_check_none_borrowed.exit987:             ; preds = %loop_out315
  %233 = call i8* @heap_alloc(i64 800)
  %234 = bitcast i8* %233 to i64*
  %235 = call i8* @heap_alloc(i64 16)
  %236 = bitcast i8* %235 to i64*
  call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %236, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0i64.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(800) %234, i64* noundef nonnull align 1 dereferenceable(800) %246, i64 800, i1 false)
  call void @heap_free(i8* %233)
  %237 = load i64, i64* %227, align 4
  %238 = and i64 %237, 68719476735
  store i64 %238, i64* %227, align 4
  %239 = load i64, i64* %248, align 4
  %240 = icmp eq i64 %239, 0
  %241 = icmp eq i64 %238, 0
  %or.cond1046 = select i1 %240, i1 %241, i1 false
  br i1 %or.cond1046, label %__barray_check_none_borrowed.exit992, label %mask_block_err.i991

mask_block_err.i986:                              ; preds = %loop_out315
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit992:             ; preds = %__barray_check_none_borrowed.exit987
  %out_arr_alloca390 = alloca <{ i32, i32, i64*, i1* }>, align 8
  %x_ptr391 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca390, i64 0, i32 0
  %y_ptr392 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca390, i64 0, i32 1
  %arr_ptr393 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca390, i64 0, i32 2
  %mask_ptr394 = getelementptr inbounds <{ i32, i32, i64*, i1* }>, <{ i32, i32, i64*, i1* }>* %out_arr_alloca390, i64 0, i32 3
  %242 = alloca [100 x i1], align 1
  %.sub792 = getelementptr inbounds [100 x i1], [100 x i1]* %242, i64 0, i64 0
  %243 = bitcast [100 x i1]* %242 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(100) %243, i8 0, i64 100, i1 false)
  store i32 100, i32* %x_ptr391, align 8
  store i32 1, i32* %y_ptr392, align 4
  %244 = bitcast i64** %arr_ptr393 to i8**
  store i8* %245, i8** %244, align 8
  store i1* %.sub792, i1** %mask_ptr394, align 8
  call void @print_int_arr(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @res_ints.B3BC9D53.0, i64 0, i64 0), i64 16, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca390)
  ret void

mask_block_err.i991:                              ; preds = %__barray_check_none_borrowed.exit987
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_exit_163:                                    ; preds = %__barray_mask_return.exit
  %245 = tail call i8* @heap_alloc(i64 800)
  %246 = bitcast i8* %245 to i64*
  %247 = tail call i8* @heap_alloc(i64 16)
  %248 = bitcast i8* %247 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %248, i8 -1, i64 16, i1 false)
  %249 = tail call i8* @heap_alloc(i64 80)
  %250 = bitcast i8* %249 to double*
  %251 = tail call i8* @heap_alloc(i64 8)
  %252 = bitcast i8* %251 to i64*
  store i64 -1, i64* %252, align 1
  %253 = tail call i8* @heap_alloc(i64 240)
  %254 = bitcast i8* %253 to { i1, i64, i1 }*
  %255 = tail call i8* @heap_alloc(i64 8)
  %256 = bitcast i8* %255 to i64*
  store i64 -1, i64* %256, align 1
  br label %266

mask_block_ok.i.i.i:                              ; preds = %cond_exit_560.i
  %257 = load i64, i64* %3, align 4
  %258 = or i64 %257, -1024
  store i64 %258, i64* %3, align 4
  %259 = icmp eq i64 %258, -1
  br i1 %259, label %"__hugr__.$measure_array$$n(10).484.exit", label %mask_block_err.i.i.i

"__hugr__.$measure_array$$n(10).484.exit":        ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %260 = tail call i8* @heap_alloc(i64 320)
  %261 = tail call i8* @heap_alloc(i64 8)
  %262 = bitcast i8* %261 to i64*
  store i64 0, i64* %262, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(320) %260, i8 0, i64 320, i1 false)
  %263 = load i64, i64* %256, align 4
  %264 = and i64 %263, 1023
  store i64 %264, i64* %256, align 4
  %265 = icmp eq i64 %264, 0
  br i1 %265, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

266:                                              ; preds = %cond_exit_163, %cond_exit_560.i
  %"510_0.sroa.15.0.i1021" = phi i64 [ 0, %cond_exit_163 ], [ %267, %cond_exit_560.i ]
  %267 = add nuw nsw i64 %"510_0.sroa.15.0.i1021", 1
  %268 = lshr i64 %"510_0.sroa.15.0.i1021", 6
  %269 = getelementptr inbounds i64, i64* %3, i64 %268
  %270 = load i64, i64* %269, align 4
  %271 = shl nuw nsw i64 1, %"510_0.sroa.15.0.i1021"
  %272 = and i64 %270, %271
  %.not.i99.i.i = icmp eq i64 %272, 0
  br i1 %.not.i99.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %266
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %266
  %273 = xor i64 %270, %271
  store i64 %273, i64* %269, align 4
  %274 = getelementptr inbounds i64, i64* %1, i64 %"510_0.sroa.15.0.i1021"
  %275 = load i64, i64* %274, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %275)
  tail call void @___qfree(i64 %275)
  %276 = getelementptr inbounds i64, i64* %256, i64 %268
  %277 = load i64, i64* %276, align 4
  %278 = and i64 %277, %271
  %.not.i.i994 = icmp eq i64 %278, 0
  br i1 %.not.i.i994, label %panic.i.i995, label %cond_exit_560.i

panic.i.i995:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_560.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"574_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %279 = xor i64 %277, %271
  store i64 %279, i64* %276, align 4
  %280 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %254, i64 %"510_0.sroa.15.0.i1021"
  store { i1, i64, i1 } %"574_054.fca.1.insert.i", { i1, i64, i1 }* %280, align 4
  %exitcond1038.not = icmp eq i64 %267, 10
  br i1 %exitcond1038.not, label %mask_block_ok.i.i.i, label %266
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

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memcpy.p0f64.p0f64.i64(double* noalias nocapture writeonly, double* noalias nocapture readonly, i64, i1 immarg) #2

declare void @print_float_arr(i8*, i64, <{ i32, i32, double*, i1* }>*) local_unnamed_addr

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memcpy.p0i64.p0i64.i64(i64* noalias nocapture writeonly, i64* noalias nocapture readonly, i64, i1 immarg) #2

declare void @print_int_arr(i8*, i64, <{ i32, i32, i64*, i1* }>*) local_unnamed_addr

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
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

attributes #0 = { argmemonly mustprogress nofree nounwind willreturn writeonly }
attributes #1 = { noreturn }
attributes #2 = { argmemonly mustprogress nofree nounwind willreturn }
attributes #3 = { argmemonly nofree nounwind willreturn writeonly }

!name = !{!0}

!0 = !{!"mainlib"}
