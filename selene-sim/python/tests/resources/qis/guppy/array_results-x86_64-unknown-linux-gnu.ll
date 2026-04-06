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

define private fastcc void @__hugr__.__main__.array_results.1() unnamed_addr {
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
  br i1 %.fca.0.extract.i, label %__barray_check_bounds.exit919, label %cond_412_case_0.i

cond_412_case_0.i:                                ; preds = %id_bb.i
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

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit"
  %26 = tail call i8* @heap_alloc(i64 240)
  %27 = bitcast i8* %26 to { i1, i64, i1 }*
  %28 = tail call i8* @heap_alloc(i64 8)
  %29 = bitcast i8* %28 to i64*
  store i64 0, i64* %29, align 1
  %30 = bitcast i8* %525 to { i1, { i1, i64, i1 } }*
  br label %31

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

31:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_389.392.exit
  %storemerge9061026 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %49, %__hugr__.const_fun_389.392.exit ]
  %32 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %47, %__hugr__.const_fun_389.392.exit ]
  %33 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %519, i64 %storemerge9061026
  %34 = load { i1, i64, i1 }, { i1, i64, i1 }* %33, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %34, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %34, 1
  br i1 %.fca.0.extract118.i, label %cond_657_case_1.i, label %cond_exit_657.i

cond_657_case_1.i:                                ; preds = %31
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %35 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %cond_exit_657.i

cond_exit_657.i:                                  ; preds = %cond_657_case_1.i, %31
  %.pn.i = phi { i1, i64, i1 } [ %35, %cond_657_case_1.i ], [ %34, %31 ]
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %36 = icmp ult i64 %32, 10
  br i1 %36, label %37, label %cond_660_case_0.i

37:                                               ; preds = %cond_exit_657.i
  %38 = lshr i64 %32, 6
  %39 = getelementptr inbounds i64, i64* %527, i64 %38
  %40 = load i64, i64* %39, align 4
  %41 = shl nuw nsw i64 1, %32
  %42 = and i64 %40, %41
  %.not.i.i = icmp eq i64 %42, 0
  br i1 %.not.i.i, label %cond_660_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %37
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_660_case_0.i:                                ; preds = %cond_exit_657.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_660_case_1.i:                                ; preds = %37
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %34, i1 %"04.sroa.6.0.i", 2
  %43 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %44 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %30, i64 %32
  %45 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %44, i64 0, i32 0
  %46 = load i1, i1* %45, align 1
  store { i1, { i1, i64, i1 } } %43, { i1, { i1, i64, i1 } }* %44, align 4
  br i1 %46, label %cond_661_case_1.i, label %__hugr__.const_fun_389.392.exit

cond_661_case_1.i:                                ; preds = %cond_660_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_389.392.exit:                  ; preds = %cond_660_case_1.i
  %47 = add nuw nsw i64 %32, 1
  %48 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %27, i64 %storemerge9061026
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %48, align 4
  %49 = add nuw nsw i64 %storemerge9061026, 1
  %exitcond1039.not = icmp eq i64 %49, 10
  br i1 %exitcond1039.not, label %mask_block_ok.i926, label %31

mask_block_ok.i926:                               ; preds = %__hugr__.const_fun_389.392.exit
  tail call void @heap_free(i8* nonnull %518)
  tail call void @heap_free(i8* %520)
  %50 = load i64, i64* %527, align 4
  %51 = and i64 %50, 1023
  store i64 %51, i64* %527, align 4
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
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_385.389.exit, label %cond_702_case_0.i

cond_702_case_0.i:                                ; preds = %__hugr__.const_fun_385.389.exit.8, %__hugr__.const_fun_385.389.exit.7, %__hugr__.const_fun_385.389.exit.6, %__hugr__.const_fun_385.389.exit.5, %__hugr__.const_fun_385.389.exit.4, %__hugr__.const_fun_385.389.exit.3, %__hugr__.const_fun_385.389.exit.2, %__hugr__.const_fun_385.389.exit.1, %__hugr__.const_fun_385.389.exit, %__barray_check_none_borrowed.exit928
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_385.389.exit:                  ; preds = %__barray_check_none_borrowed.exit928
  %58 = extractvalue { i1, { i1, i64, i1 } } %57, 1
  store { i1, i64, i1 } %58, { i1, i64, i1 }* %54, align 4
  %59 = getelementptr inbounds i8, i8* %525, i64 32
  %60 = bitcast i8* %59 to { i1, { i1, i64, i1 } }*
  %61 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %60, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %61, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_385.389.exit.1, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.1:                ; preds = %__hugr__.const_fun_385.389.exit
  %62 = extractvalue { i1, { i1, i64, i1 } } %61, 1
  %63 = getelementptr inbounds i8, i8* %53, i64 24
  %64 = bitcast i8* %63 to { i1, i64, i1 }*
  store { i1, i64, i1 } %62, { i1, i64, i1 }* %64, align 4
  %65 = getelementptr inbounds i8, i8* %525, i64 64
  %66 = bitcast i8* %65 to { i1, { i1, i64, i1 } }*
  %67 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %66, align 4
  %.fca.0.extract11.i.2 = extractvalue { i1, { i1, i64, i1 } } %67, 0
  br i1 %.fca.0.extract11.i.2, label %__hugr__.const_fun_385.389.exit.2, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.2:                ; preds = %__hugr__.const_fun_385.389.exit.1
  %68 = extractvalue { i1, { i1, i64, i1 } } %67, 1
  %69 = getelementptr inbounds i8, i8* %53, i64 48
  %70 = bitcast i8* %69 to { i1, i64, i1 }*
  store { i1, i64, i1 } %68, { i1, i64, i1 }* %70, align 4
  %71 = getelementptr inbounds i8, i8* %525, i64 96
  %72 = bitcast i8* %71 to { i1, { i1, i64, i1 } }*
  %73 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %72, align 4
  %.fca.0.extract11.i.3 = extractvalue { i1, { i1, i64, i1 } } %73, 0
  br i1 %.fca.0.extract11.i.3, label %__hugr__.const_fun_385.389.exit.3, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.3:                ; preds = %__hugr__.const_fun_385.389.exit.2
  %74 = extractvalue { i1, { i1, i64, i1 } } %73, 1
  %75 = getelementptr inbounds i8, i8* %53, i64 72
  %76 = bitcast i8* %75 to { i1, i64, i1 }*
  store { i1, i64, i1 } %74, { i1, i64, i1 }* %76, align 4
  %77 = getelementptr inbounds i8, i8* %525, i64 128
  %78 = bitcast i8* %77 to { i1, { i1, i64, i1 } }*
  %79 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %78, align 4
  %.fca.0.extract11.i.4 = extractvalue { i1, { i1, i64, i1 } } %79, 0
  br i1 %.fca.0.extract11.i.4, label %__hugr__.const_fun_385.389.exit.4, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.4:                ; preds = %__hugr__.const_fun_385.389.exit.3
  %80 = extractvalue { i1, { i1, i64, i1 } } %79, 1
  %81 = getelementptr inbounds i8, i8* %53, i64 96
  %82 = bitcast i8* %81 to { i1, i64, i1 }*
  store { i1, i64, i1 } %80, { i1, i64, i1 }* %82, align 4
  %83 = getelementptr inbounds i8, i8* %525, i64 160
  %84 = bitcast i8* %83 to { i1, { i1, i64, i1 } }*
  %85 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %84, align 4
  %.fca.0.extract11.i.5 = extractvalue { i1, { i1, i64, i1 } } %85, 0
  br i1 %.fca.0.extract11.i.5, label %__hugr__.const_fun_385.389.exit.5, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.5:                ; preds = %__hugr__.const_fun_385.389.exit.4
  %86 = extractvalue { i1, { i1, i64, i1 } } %85, 1
  %87 = getelementptr inbounds i8, i8* %53, i64 120
  %88 = bitcast i8* %87 to { i1, i64, i1 }*
  store { i1, i64, i1 } %86, { i1, i64, i1 }* %88, align 4
  %89 = getelementptr inbounds i8, i8* %525, i64 192
  %90 = bitcast i8* %89 to { i1, { i1, i64, i1 } }*
  %91 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %90, align 4
  %.fca.0.extract11.i.6 = extractvalue { i1, { i1, i64, i1 } } %91, 0
  br i1 %.fca.0.extract11.i.6, label %__hugr__.const_fun_385.389.exit.6, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.6:                ; preds = %__hugr__.const_fun_385.389.exit.5
  %92 = extractvalue { i1, { i1, i64, i1 } } %91, 1
  %93 = getelementptr inbounds i8, i8* %53, i64 144
  %94 = bitcast i8* %93 to { i1, i64, i1 }*
  store { i1, i64, i1 } %92, { i1, i64, i1 }* %94, align 4
  %95 = getelementptr inbounds i8, i8* %525, i64 224
  %96 = bitcast i8* %95 to { i1, { i1, i64, i1 } }*
  %97 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %96, align 4
  %.fca.0.extract11.i.7 = extractvalue { i1, { i1, i64, i1 } } %97, 0
  br i1 %.fca.0.extract11.i.7, label %__hugr__.const_fun_385.389.exit.7, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.7:                ; preds = %__hugr__.const_fun_385.389.exit.6
  %98 = extractvalue { i1, { i1, i64, i1 } } %97, 1
  %99 = getelementptr inbounds i8, i8* %53, i64 168
  %100 = bitcast i8* %99 to { i1, i64, i1 }*
  store { i1, i64, i1 } %98, { i1, i64, i1 }* %100, align 4
  %101 = getelementptr inbounds i8, i8* %525, i64 256
  %102 = bitcast i8* %101 to { i1, { i1, i64, i1 } }*
  %103 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %102, align 4
  %.fca.0.extract11.i.8 = extractvalue { i1, { i1, i64, i1 } } %103, 0
  br i1 %.fca.0.extract11.i.8, label %__hugr__.const_fun_385.389.exit.8, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.8:                ; preds = %__hugr__.const_fun_385.389.exit.7
  %104 = extractvalue { i1, { i1, i64, i1 } } %103, 1
  %105 = getelementptr inbounds i8, i8* %53, i64 192
  %106 = bitcast i8* %105 to { i1, i64, i1 }*
  store { i1, i64, i1 } %104, { i1, i64, i1 }* %106, align 4
  %107 = getelementptr inbounds i8, i8* %525, i64 288
  %108 = bitcast i8* %107 to { i1, { i1, i64, i1 } }*
  %109 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %108, align 4
  %.fca.0.extract11.i.9 = extractvalue { i1, { i1, i64, i1 } } %109, 0
  br i1 %.fca.0.extract11.i.9, label %__hugr__.const_fun_385.389.exit.9, label %cond_702_case_0.i

__hugr__.const_fun_385.389.exit.9:                ; preds = %__hugr__.const_fun_385.389.exit.8
  %110 = extractvalue { i1, { i1, i64, i1 } } %109, 1
  %111 = getelementptr inbounds i8, i8* %53, i64 216
  %112 = bitcast i8* %111 to { i1, i64, i1 }*
  store { i1, i64, i1 } %110, { i1, i64, i1 }* %112, align 4
  tail call void @heap_free(i8* nonnull %525)
  tail call void @heap_free(i8* nonnull %526)
  br label %__barray_check_bounds.exit933

cond_610_case_0:                                  ; preds = %cond_exit_610
  %113 = load i64, i64* %56, align 4
  %114 = or i64 %113, -1024
  store i64 %114, i64* %56, align 4
  %115 = icmp eq i64 %114, -1
  br i1 %115, label %loop_out150, label %mask_block_err.i931

mask_block_err.i931:                              ; preds = %cond_610_case_0
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit933:                    ; preds = %__hugr__.const_fun_385.389.exit.9, %cond_exit_610
  %"607_0.01049" = phi i64 [ 0, %__hugr__.const_fun_385.389.exit.9 ], [ %116, %cond_exit_610 ]
  %116 = add nuw nsw i64 %"607_0.01049", 1
  %117 = lshr i64 %"607_0.01049", 6
  %118 = getelementptr inbounds i64, i64* %56, i64 %117
  %119 = load i64, i64* %118, align 4
  %120 = shl nuw nsw i64 1, %"607_0.01049"
  %121 = and i64 %119, %120
  %.not = icmp eq i64 %121, 0
  br i1 %.not, label %__barray_mask_borrow.exit938, label %cond_exit_610

__barray_mask_borrow.exit938:                     ; preds = %__barray_check_bounds.exit933
  %122 = xor i64 %119, %120
  store i64 %122, i64* %118, align 4
  %123 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %54, i64 %"607_0.01049"
  %124 = load { i1, i64, i1 }, { i1, i64, i1 }* %123, align 4
  %.fca.0.extract593 = extractvalue { i1, i64, i1 } %124, 0
  br i1 %.fca.0.extract593, label %cond_633_case_1, label %cond_exit_610

cond_exit_610:                                    ; preds = %cond_633_case_1, %__barray_mask_borrow.exit938, %__barray_check_bounds.exit933
  %125 = icmp ult i64 %"607_0.01049", 9
  br i1 %125, label %__barray_check_bounds.exit933, label %cond_610_case_0

loop_out150:                                      ; preds = %cond_610_case_0
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
  br i1 %.fca.0.extract.i944, label %cond_456_case_1.i, label %cond_456_case_0.i

mask_block_err.i942:                              ; preds = %loop_out150
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_633_case_1:                                  ; preds = %__barray_mask_borrow.exit938
  %.fca.1.extract594 = extractvalue { i1, i64, i1 } %124, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract594)
  br label %cond_exit_610

cond_456_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit943
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %132, 2
  br label %__hugr__.array.__read_bool.3.345.exit

cond_456_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit943
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945)
  br label %__hugr__.array.__read_bool.3.345.exit

__hugr__.array.__read_bool.3.345.exit:            ; preds = %cond_456_case_0.i, %cond_456_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_456_case_1.i ], [ %.fca.2.extract.i, %cond_456_case_0.i ]
  %133 = bitcast i8* %129 to i1*
  store i1 %"03.0.i", i1* %133, align 1
  %134 = getelementptr inbounds i8, i8* %26, i64 24
  %135 = bitcast i8* %134 to { i1, i64, i1 }*
  %136 = load { i1, i64, i1 }, { i1, i64, i1 }* %135, align 4
  %.fca.0.extract.i944.1 = extractvalue { i1, i64, i1 } %136, 0
  %.fca.1.extract.i945.1 = extractvalue { i1, i64, i1 } %136, 1
  br i1 %.fca.0.extract.i944.1, label %cond_456_case_1.i.1, label %cond_456_case_0.i.1

cond_456_case_0.i.1:                              ; preds = %__hugr__.array.__read_bool.3.345.exit
  %.fca.2.extract.i.1 = extractvalue { i1, i64, i1 } %136, 2
  br label %__hugr__.array.__read_bool.3.345.exit.1

cond_456_case_1.i.1:                              ; preds = %__hugr__.array.__read_bool.3.345.exit
  %read_bool.i.1 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.1)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.1)
  br label %__hugr__.array.__read_bool.3.345.exit.1

__hugr__.array.__read_bool.3.345.exit.1:          ; preds = %cond_456_case_1.i.1, %cond_456_case_0.i.1
  %"03.0.i.1" = phi i1 [ %read_bool.i.1, %cond_456_case_1.i.1 ], [ %.fca.2.extract.i.1, %cond_456_case_0.i.1 ]
  %137 = getelementptr inbounds i8, i8* %129, i64 1
  %138 = bitcast i8* %137 to i1*
  store i1 %"03.0.i.1", i1* %138, align 1
  %139 = getelementptr inbounds i8, i8* %26, i64 48
  %140 = bitcast i8* %139 to { i1, i64, i1 }*
  %141 = load { i1, i64, i1 }, { i1, i64, i1 }* %140, align 4
  %.fca.0.extract.i944.2 = extractvalue { i1, i64, i1 } %141, 0
  %.fca.1.extract.i945.2 = extractvalue { i1, i64, i1 } %141, 1
  br i1 %.fca.0.extract.i944.2, label %cond_456_case_1.i.2, label %cond_456_case_0.i.2

cond_456_case_0.i.2:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.1
  %.fca.2.extract.i.2 = extractvalue { i1, i64, i1 } %141, 2
  br label %__hugr__.array.__read_bool.3.345.exit.2

cond_456_case_1.i.2:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.1
  %read_bool.i.2 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.2)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.2)
  br label %__hugr__.array.__read_bool.3.345.exit.2

__hugr__.array.__read_bool.3.345.exit.2:          ; preds = %cond_456_case_1.i.2, %cond_456_case_0.i.2
  %"03.0.i.2" = phi i1 [ %read_bool.i.2, %cond_456_case_1.i.2 ], [ %.fca.2.extract.i.2, %cond_456_case_0.i.2 ]
  %142 = getelementptr inbounds i8, i8* %129, i64 2
  %143 = bitcast i8* %142 to i1*
  store i1 %"03.0.i.2", i1* %143, align 1
  %144 = getelementptr inbounds i8, i8* %26, i64 72
  %145 = bitcast i8* %144 to { i1, i64, i1 }*
  %146 = load { i1, i64, i1 }, { i1, i64, i1 }* %145, align 4
  %.fca.0.extract.i944.3 = extractvalue { i1, i64, i1 } %146, 0
  %.fca.1.extract.i945.3 = extractvalue { i1, i64, i1 } %146, 1
  br i1 %.fca.0.extract.i944.3, label %cond_456_case_1.i.3, label %cond_456_case_0.i.3

cond_456_case_0.i.3:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.2
  %.fca.2.extract.i.3 = extractvalue { i1, i64, i1 } %146, 2
  br label %__hugr__.array.__read_bool.3.345.exit.3

cond_456_case_1.i.3:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.2
  %read_bool.i.3 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.3)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.3)
  br label %__hugr__.array.__read_bool.3.345.exit.3

__hugr__.array.__read_bool.3.345.exit.3:          ; preds = %cond_456_case_1.i.3, %cond_456_case_0.i.3
  %"03.0.i.3" = phi i1 [ %read_bool.i.3, %cond_456_case_1.i.3 ], [ %.fca.2.extract.i.3, %cond_456_case_0.i.3 ]
  %147 = getelementptr inbounds i8, i8* %129, i64 3
  %148 = bitcast i8* %147 to i1*
  store i1 %"03.0.i.3", i1* %148, align 1
  %149 = getelementptr inbounds i8, i8* %26, i64 96
  %150 = bitcast i8* %149 to { i1, i64, i1 }*
  %151 = load { i1, i64, i1 }, { i1, i64, i1 }* %150, align 4
  %.fca.0.extract.i944.4 = extractvalue { i1, i64, i1 } %151, 0
  %.fca.1.extract.i945.4 = extractvalue { i1, i64, i1 } %151, 1
  br i1 %.fca.0.extract.i944.4, label %cond_456_case_1.i.4, label %cond_456_case_0.i.4

cond_456_case_0.i.4:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.3
  %.fca.2.extract.i.4 = extractvalue { i1, i64, i1 } %151, 2
  br label %__hugr__.array.__read_bool.3.345.exit.4

cond_456_case_1.i.4:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.3
  %read_bool.i.4 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.4)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.4)
  br label %__hugr__.array.__read_bool.3.345.exit.4

__hugr__.array.__read_bool.3.345.exit.4:          ; preds = %cond_456_case_1.i.4, %cond_456_case_0.i.4
  %"03.0.i.4" = phi i1 [ %read_bool.i.4, %cond_456_case_1.i.4 ], [ %.fca.2.extract.i.4, %cond_456_case_0.i.4 ]
  %152 = getelementptr inbounds i8, i8* %129, i64 4
  %153 = bitcast i8* %152 to i1*
  store i1 %"03.0.i.4", i1* %153, align 1
  %154 = getelementptr inbounds i8, i8* %26, i64 120
  %155 = bitcast i8* %154 to { i1, i64, i1 }*
  %156 = load { i1, i64, i1 }, { i1, i64, i1 }* %155, align 4
  %.fca.0.extract.i944.5 = extractvalue { i1, i64, i1 } %156, 0
  %.fca.1.extract.i945.5 = extractvalue { i1, i64, i1 } %156, 1
  br i1 %.fca.0.extract.i944.5, label %cond_456_case_1.i.5, label %cond_456_case_0.i.5

cond_456_case_0.i.5:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.4
  %.fca.2.extract.i.5 = extractvalue { i1, i64, i1 } %156, 2
  br label %__hugr__.array.__read_bool.3.345.exit.5

cond_456_case_1.i.5:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.4
  %read_bool.i.5 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.5)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.5)
  br label %__hugr__.array.__read_bool.3.345.exit.5

__hugr__.array.__read_bool.3.345.exit.5:          ; preds = %cond_456_case_1.i.5, %cond_456_case_0.i.5
  %"03.0.i.5" = phi i1 [ %read_bool.i.5, %cond_456_case_1.i.5 ], [ %.fca.2.extract.i.5, %cond_456_case_0.i.5 ]
  %157 = getelementptr inbounds i8, i8* %129, i64 5
  %158 = bitcast i8* %157 to i1*
  store i1 %"03.0.i.5", i1* %158, align 1
  %159 = getelementptr inbounds i8, i8* %26, i64 144
  %160 = bitcast i8* %159 to { i1, i64, i1 }*
  %161 = load { i1, i64, i1 }, { i1, i64, i1 }* %160, align 4
  %.fca.0.extract.i944.6 = extractvalue { i1, i64, i1 } %161, 0
  %.fca.1.extract.i945.6 = extractvalue { i1, i64, i1 } %161, 1
  br i1 %.fca.0.extract.i944.6, label %cond_456_case_1.i.6, label %cond_456_case_0.i.6

cond_456_case_0.i.6:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.5
  %.fca.2.extract.i.6 = extractvalue { i1, i64, i1 } %161, 2
  br label %__hugr__.array.__read_bool.3.345.exit.6

cond_456_case_1.i.6:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.5
  %read_bool.i.6 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.6)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.6)
  br label %__hugr__.array.__read_bool.3.345.exit.6

__hugr__.array.__read_bool.3.345.exit.6:          ; preds = %cond_456_case_1.i.6, %cond_456_case_0.i.6
  %"03.0.i.6" = phi i1 [ %read_bool.i.6, %cond_456_case_1.i.6 ], [ %.fca.2.extract.i.6, %cond_456_case_0.i.6 ]
  %162 = getelementptr inbounds i8, i8* %129, i64 6
  %163 = bitcast i8* %162 to i1*
  store i1 %"03.0.i.6", i1* %163, align 1
  %164 = getelementptr inbounds i8, i8* %26, i64 168
  %165 = bitcast i8* %164 to { i1, i64, i1 }*
  %166 = load { i1, i64, i1 }, { i1, i64, i1 }* %165, align 4
  %.fca.0.extract.i944.7 = extractvalue { i1, i64, i1 } %166, 0
  %.fca.1.extract.i945.7 = extractvalue { i1, i64, i1 } %166, 1
  br i1 %.fca.0.extract.i944.7, label %cond_456_case_1.i.7, label %cond_456_case_0.i.7

cond_456_case_0.i.7:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.6
  %.fca.2.extract.i.7 = extractvalue { i1, i64, i1 } %166, 2
  br label %__hugr__.array.__read_bool.3.345.exit.7

cond_456_case_1.i.7:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.6
  %read_bool.i.7 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.7)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.7)
  br label %__hugr__.array.__read_bool.3.345.exit.7

__hugr__.array.__read_bool.3.345.exit.7:          ; preds = %cond_456_case_1.i.7, %cond_456_case_0.i.7
  %"03.0.i.7" = phi i1 [ %read_bool.i.7, %cond_456_case_1.i.7 ], [ %.fca.2.extract.i.7, %cond_456_case_0.i.7 ]
  %167 = getelementptr inbounds i8, i8* %129, i64 7
  %168 = bitcast i8* %167 to i1*
  store i1 %"03.0.i.7", i1* %168, align 1
  %169 = getelementptr inbounds i8, i8* %26, i64 192
  %170 = bitcast i8* %169 to { i1, i64, i1 }*
  %171 = load { i1, i64, i1 }, { i1, i64, i1 }* %170, align 4
  %.fca.0.extract.i944.8 = extractvalue { i1, i64, i1 } %171, 0
  %.fca.1.extract.i945.8 = extractvalue { i1, i64, i1 } %171, 1
  br i1 %.fca.0.extract.i944.8, label %cond_456_case_1.i.8, label %cond_456_case_0.i.8

cond_456_case_0.i.8:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.7
  %.fca.2.extract.i.8 = extractvalue { i1, i64, i1 } %171, 2
  br label %__hugr__.array.__read_bool.3.345.exit.8

cond_456_case_1.i.8:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.7
  %read_bool.i.8 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.8)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.8)
  br label %__hugr__.array.__read_bool.3.345.exit.8

__hugr__.array.__read_bool.3.345.exit.8:          ; preds = %cond_456_case_1.i.8, %cond_456_case_0.i.8
  %"03.0.i.8" = phi i1 [ %read_bool.i.8, %cond_456_case_1.i.8 ], [ %.fca.2.extract.i.8, %cond_456_case_0.i.8 ]
  %172 = getelementptr inbounds i8, i8* %129, i64 8
  %173 = bitcast i8* %172 to i1*
  store i1 %"03.0.i.8", i1* %173, align 1
  %174 = getelementptr inbounds i8, i8* %26, i64 216
  %175 = bitcast i8* %174 to { i1, i64, i1 }*
  %176 = load { i1, i64, i1 }, { i1, i64, i1 }* %175, align 4
  %.fca.0.extract.i944.9 = extractvalue { i1, i64, i1 } %176, 0
  %.fca.1.extract.i945.9 = extractvalue { i1, i64, i1 } %176, 1
  br i1 %.fca.0.extract.i944.9, label %cond_456_case_1.i.9, label %cond_456_case_0.i.9

cond_456_case_0.i.9:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.8
  %.fca.2.extract.i.9 = extractvalue { i1, i64, i1 } %176, 2
  br label %__hugr__.array.__read_bool.3.345.exit.9

cond_456_case_1.i.9:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.8
  %read_bool.i.9 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i945.9)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i945.9)
  br label %__hugr__.array.__read_bool.3.345.exit.9

__hugr__.array.__read_bool.3.345.exit.9:          ; preds = %cond_456_case_1.i.9, %cond_456_case_0.i.9
  %"03.0.i.9" = phi i1 [ %read_bool.i.9, %cond_456_case_1.i.9 ], [ %.fca.2.extract.i.9, %cond_456_case_0.i.9 ]
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

__barray_check_none_borrowed.exit950:             ; preds = %__hugr__.array.__read_bool.3.345.exit.9
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
  br label %pow.i

mask_block_err.i949:                              ; preds = %__hugr__.array.__read_bool.3.345.exit.9
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

pow.i:                                            ; preds = %__barray_check_none_borrowed.exit950, %pow_body.i
  %storemerge1.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %__barray_check_none_borrowed.exit950 ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ 0, %__barray_check_none_borrowed.exit950 ]
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
  %185 = load i64, i64* %517, align 4
  %186 = and i64 %185, 1
  %.not.i959 = icmp eq i64 %186, 0
  br i1 %.not.i959, label %panic.i960, label %cond_exit_91

panic.i960:                                       ; preds = %__barray_check_bounds.exit958.9, %__barray_check_bounds.exit958.8, %__barray_check_bounds.exit958.7, %__barray_check_bounds.exit958.6, %__barray_check_bounds.exit958.5, %__barray_check_bounds.exit958.4, %__barray_check_bounds.exit958.3, %__barray_check_bounds.exit958.2, %__barray_check_bounds.exit958.1, %__barray_check_bounds.exit958
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_91:                                     ; preds = %__barray_check_bounds.exit958
  %187 = sitofp i64 %storemerge3.i to double
  %188 = fdiv double 1.000000e+00, %187
  %189 = xor i64 %185, 1
  store i64 %189, i64* %517, align 4
  store double %188, double* %515, align 8
  br label %pow.i.1

pow.i.1:                                          ; preds = %pow_body.i.1, %cond_exit_91
  %storemerge1.i.1 = phi i64 [ %new_acc.i.1, %pow_body.i.1 ], [ 2, %cond_exit_91 ]
  %storemerge.i.1 = phi i64 [ %new_exp.i.1, %pow_body.i.1 ], [ 1, %cond_exit_91 ]
  switch i64 %storemerge.i.1, label %pow_body.i.1 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.1
    i64 0, label %__barray_check_bounds.exit958.1
  ]

__barray_check_bounds.exit958.loopexit.1:         ; preds = %pow.i.1
  br label %__barray_check_bounds.exit958.1

__barray_check_bounds.exit958.1:                  ; preds = %pow.i.1, %__barray_check_bounds.exit958.loopexit.1
  %storemerge3.i.1 = phi i64 [ %storemerge1.i.1, %__barray_check_bounds.exit958.loopexit.1 ], [ 1, %pow.i.1 ]
  %190 = load i64, i64* %517, align 4
  %191 = and i64 %190, 2
  %.not.i959.1 = icmp eq i64 %191, 0
  br i1 %.not.i959.1, label %panic.i960, label %cond_exit_91.1

cond_exit_91.1:                                   ; preds = %__barray_check_bounds.exit958.1
  %192 = sitofp i64 %storemerge3.i.1 to double
  %193 = fdiv double 1.000000e+00, %192
  %194 = xor i64 %190, 2
  store i64 %194, i64* %517, align 4
  %195 = getelementptr inbounds i8, i8* %514, i64 8
  %196 = bitcast i8* %195 to double*
  store double %193, double* %196, align 8
  br label %pow.i.2

pow_body.i.1:                                     ; preds = %pow.i.1
  %new_acc.i.1 = shl i64 %storemerge1.i.1, 1
  %new_exp.i.1 = add i64 %storemerge.i.1, -1
  br label %pow.i.1

pow.i.2:                                          ; preds = %pow_body.i.2, %cond_exit_91.1
  %storemerge1.i.2 = phi i64 [ %new_acc.i.2, %pow_body.i.2 ], [ 2, %cond_exit_91.1 ]
  %storemerge.i.2 = phi i64 [ %new_exp.i.2, %pow_body.i.2 ], [ 2, %cond_exit_91.1 ]
  switch i64 %storemerge.i.2, label %pow_body.i.2 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.2
    i64 0, label %__barray_check_bounds.exit958.2
  ]

__barray_check_bounds.exit958.loopexit.2:         ; preds = %pow.i.2
  br label %__barray_check_bounds.exit958.2

__barray_check_bounds.exit958.2:                  ; preds = %pow.i.2, %__barray_check_bounds.exit958.loopexit.2
  %storemerge3.i.2 = phi i64 [ %storemerge1.i.2, %__barray_check_bounds.exit958.loopexit.2 ], [ 1, %pow.i.2 ]
  %197 = load i64, i64* %517, align 4
  %198 = and i64 %197, 4
  %.not.i959.2 = icmp eq i64 %198, 0
  br i1 %.not.i959.2, label %panic.i960, label %cond_exit_91.2

cond_exit_91.2:                                   ; preds = %__barray_check_bounds.exit958.2
  %199 = sitofp i64 %storemerge3.i.2 to double
  %200 = fdiv double 1.000000e+00, %199
  %201 = xor i64 %197, 4
  store i64 %201, i64* %517, align 4
  %202 = getelementptr inbounds i8, i8* %514, i64 16
  %203 = bitcast i8* %202 to double*
  store double %200, double* %203, align 8
  br label %pow.i.3

pow_body.i.2:                                     ; preds = %pow.i.2
  %new_acc.i.2 = shl i64 %storemerge1.i.2, 1
  %new_exp.i.2 = add i64 %storemerge.i.2, -1
  br label %pow.i.2

pow.i.3:                                          ; preds = %pow_body.i.3, %cond_exit_91.2
  %storemerge1.i.3 = phi i64 [ %new_acc.i.3, %pow_body.i.3 ], [ 2, %cond_exit_91.2 ]
  %storemerge.i.3 = phi i64 [ %new_exp.i.3, %pow_body.i.3 ], [ 3, %cond_exit_91.2 ]
  switch i64 %storemerge.i.3, label %pow_body.i.3 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.3
    i64 0, label %__barray_check_bounds.exit958.3
  ]

__barray_check_bounds.exit958.loopexit.3:         ; preds = %pow.i.3
  br label %__barray_check_bounds.exit958.3

__barray_check_bounds.exit958.3:                  ; preds = %pow.i.3, %__barray_check_bounds.exit958.loopexit.3
  %storemerge3.i.3 = phi i64 [ %storemerge1.i.3, %__barray_check_bounds.exit958.loopexit.3 ], [ 1, %pow.i.3 ]
  %204 = load i64, i64* %517, align 4
  %205 = and i64 %204, 8
  %.not.i959.3 = icmp eq i64 %205, 0
  br i1 %.not.i959.3, label %panic.i960, label %cond_exit_91.3

cond_exit_91.3:                                   ; preds = %__barray_check_bounds.exit958.3
  %206 = sitofp i64 %storemerge3.i.3 to double
  %207 = fdiv double 1.000000e+00, %206
  %208 = xor i64 %204, 8
  store i64 %208, i64* %517, align 4
  %209 = getelementptr inbounds i8, i8* %514, i64 24
  %210 = bitcast i8* %209 to double*
  store double %207, double* %210, align 8
  br label %pow.i.4

pow_body.i.3:                                     ; preds = %pow.i.3
  %new_acc.i.3 = shl i64 %storemerge1.i.3, 1
  %new_exp.i.3 = add i64 %storemerge.i.3, -1
  br label %pow.i.3

pow.i.4:                                          ; preds = %pow_body.i.4, %cond_exit_91.3
  %storemerge1.i.4 = phi i64 [ %new_acc.i.4, %pow_body.i.4 ], [ 2, %cond_exit_91.3 ]
  %storemerge.i.4 = phi i64 [ %new_exp.i.4, %pow_body.i.4 ], [ 4, %cond_exit_91.3 ]
  switch i64 %storemerge.i.4, label %pow_body.i.4 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.4
    i64 0, label %__barray_check_bounds.exit958.4
  ]

__barray_check_bounds.exit958.loopexit.4:         ; preds = %pow.i.4
  br label %__barray_check_bounds.exit958.4

__barray_check_bounds.exit958.4:                  ; preds = %pow.i.4, %__barray_check_bounds.exit958.loopexit.4
  %storemerge3.i.4 = phi i64 [ %storemerge1.i.4, %__barray_check_bounds.exit958.loopexit.4 ], [ 1, %pow.i.4 ]
  %211 = load i64, i64* %517, align 4
  %212 = and i64 %211, 16
  %.not.i959.4 = icmp eq i64 %212, 0
  br i1 %.not.i959.4, label %panic.i960, label %cond_exit_91.4

cond_exit_91.4:                                   ; preds = %__barray_check_bounds.exit958.4
  %213 = sitofp i64 %storemerge3.i.4 to double
  %214 = fdiv double 1.000000e+00, %213
  %215 = xor i64 %211, 16
  store i64 %215, i64* %517, align 4
  %216 = getelementptr inbounds i8, i8* %514, i64 32
  %217 = bitcast i8* %216 to double*
  store double %214, double* %217, align 8
  br label %pow.i.5

pow_body.i.4:                                     ; preds = %pow.i.4
  %new_acc.i.4 = shl i64 %storemerge1.i.4, 1
  %new_exp.i.4 = add i64 %storemerge.i.4, -1
  br label %pow.i.4

pow.i.5:                                          ; preds = %pow_body.i.5, %cond_exit_91.4
  %storemerge1.i.5 = phi i64 [ %new_acc.i.5, %pow_body.i.5 ], [ 2, %cond_exit_91.4 ]
  %storemerge.i.5 = phi i64 [ %new_exp.i.5, %pow_body.i.5 ], [ 5, %cond_exit_91.4 ]
  switch i64 %storemerge.i.5, label %pow_body.i.5 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.5
    i64 0, label %__barray_check_bounds.exit958.5
  ]

__barray_check_bounds.exit958.loopexit.5:         ; preds = %pow.i.5
  br label %__barray_check_bounds.exit958.5

__barray_check_bounds.exit958.5:                  ; preds = %pow.i.5, %__barray_check_bounds.exit958.loopexit.5
  %storemerge3.i.5 = phi i64 [ %storemerge1.i.5, %__barray_check_bounds.exit958.loopexit.5 ], [ 1, %pow.i.5 ]
  %218 = load i64, i64* %517, align 4
  %219 = and i64 %218, 32
  %.not.i959.5 = icmp eq i64 %219, 0
  br i1 %.not.i959.5, label %panic.i960, label %cond_exit_91.5

cond_exit_91.5:                                   ; preds = %__barray_check_bounds.exit958.5
  %220 = sitofp i64 %storemerge3.i.5 to double
  %221 = fdiv double 1.000000e+00, %220
  %222 = xor i64 %218, 32
  store i64 %222, i64* %517, align 4
  %223 = getelementptr inbounds i8, i8* %514, i64 40
  %224 = bitcast i8* %223 to double*
  store double %221, double* %224, align 8
  br label %pow.i.6

pow_body.i.5:                                     ; preds = %pow.i.5
  %new_acc.i.5 = shl i64 %storemerge1.i.5, 1
  %new_exp.i.5 = add i64 %storemerge.i.5, -1
  br label %pow.i.5

pow.i.6:                                          ; preds = %pow_body.i.6, %cond_exit_91.5
  %storemerge1.i.6 = phi i64 [ %new_acc.i.6, %pow_body.i.6 ], [ 2, %cond_exit_91.5 ]
  %storemerge.i.6 = phi i64 [ %new_exp.i.6, %pow_body.i.6 ], [ 6, %cond_exit_91.5 ]
  switch i64 %storemerge.i.6, label %pow_body.i.6 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.6
    i64 0, label %__barray_check_bounds.exit958.6
  ]

__barray_check_bounds.exit958.loopexit.6:         ; preds = %pow.i.6
  br label %__barray_check_bounds.exit958.6

__barray_check_bounds.exit958.6:                  ; preds = %pow.i.6, %__barray_check_bounds.exit958.loopexit.6
  %storemerge3.i.6 = phi i64 [ %storemerge1.i.6, %__barray_check_bounds.exit958.loopexit.6 ], [ 1, %pow.i.6 ]
  %225 = load i64, i64* %517, align 4
  %226 = and i64 %225, 64
  %.not.i959.6 = icmp eq i64 %226, 0
  br i1 %.not.i959.6, label %panic.i960, label %cond_exit_91.6

cond_exit_91.6:                                   ; preds = %__barray_check_bounds.exit958.6
  %227 = sitofp i64 %storemerge3.i.6 to double
  %228 = fdiv double 1.000000e+00, %227
  %229 = xor i64 %225, 64
  store i64 %229, i64* %517, align 4
  %230 = getelementptr inbounds i8, i8* %514, i64 48
  %231 = bitcast i8* %230 to double*
  store double %228, double* %231, align 8
  br label %pow.i.7

pow_body.i.6:                                     ; preds = %pow.i.6
  %new_acc.i.6 = shl i64 %storemerge1.i.6, 1
  %new_exp.i.6 = add i64 %storemerge.i.6, -1
  br label %pow.i.6

pow.i.7:                                          ; preds = %pow_body.i.7, %cond_exit_91.6
  %storemerge1.i.7 = phi i64 [ %new_acc.i.7, %pow_body.i.7 ], [ 2, %cond_exit_91.6 ]
  %storemerge.i.7 = phi i64 [ %new_exp.i.7, %pow_body.i.7 ], [ 7, %cond_exit_91.6 ]
  switch i64 %storemerge.i.7, label %pow_body.i.7 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.7
    i64 0, label %__barray_check_bounds.exit958.7
  ]

__barray_check_bounds.exit958.loopexit.7:         ; preds = %pow.i.7
  br label %__barray_check_bounds.exit958.7

__barray_check_bounds.exit958.7:                  ; preds = %pow.i.7, %__barray_check_bounds.exit958.loopexit.7
  %storemerge3.i.7 = phi i64 [ %storemerge1.i.7, %__barray_check_bounds.exit958.loopexit.7 ], [ 1, %pow.i.7 ]
  %232 = load i64, i64* %517, align 4
  %233 = and i64 %232, 128
  %.not.i959.7 = icmp eq i64 %233, 0
  br i1 %.not.i959.7, label %panic.i960, label %cond_exit_91.7

cond_exit_91.7:                                   ; preds = %__barray_check_bounds.exit958.7
  %234 = sitofp i64 %storemerge3.i.7 to double
  %235 = fdiv double 1.000000e+00, %234
  %236 = xor i64 %232, 128
  store i64 %236, i64* %517, align 4
  %237 = getelementptr inbounds i8, i8* %514, i64 56
  %238 = bitcast i8* %237 to double*
  store double %235, double* %238, align 8
  br label %pow.i.8

pow_body.i.7:                                     ; preds = %pow.i.7
  %new_acc.i.7 = shl i64 %storemerge1.i.7, 1
  %new_exp.i.7 = add i64 %storemerge.i.7, -1
  br label %pow.i.7

pow.i.8:                                          ; preds = %pow_body.i.8, %cond_exit_91.7
  %storemerge1.i.8 = phi i64 [ %new_acc.i.8, %pow_body.i.8 ], [ 2, %cond_exit_91.7 ]
  %storemerge.i.8 = phi i64 [ %new_exp.i.8, %pow_body.i.8 ], [ 8, %cond_exit_91.7 ]
  switch i64 %storemerge.i.8, label %pow_body.i.8 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.8
    i64 0, label %__barray_check_bounds.exit958.8
  ]

__barray_check_bounds.exit958.loopexit.8:         ; preds = %pow.i.8
  br label %__barray_check_bounds.exit958.8

__barray_check_bounds.exit958.8:                  ; preds = %pow.i.8, %__barray_check_bounds.exit958.loopexit.8
  %storemerge3.i.8 = phi i64 [ %storemerge1.i.8, %__barray_check_bounds.exit958.loopexit.8 ], [ 1, %pow.i.8 ]
  %239 = load i64, i64* %517, align 4
  %240 = and i64 %239, 256
  %.not.i959.8 = icmp eq i64 %240, 0
  br i1 %.not.i959.8, label %panic.i960, label %cond_exit_91.8

cond_exit_91.8:                                   ; preds = %__barray_check_bounds.exit958.8
  %241 = sitofp i64 %storemerge3.i.8 to double
  %242 = fdiv double 1.000000e+00, %241
  %243 = xor i64 %239, 256
  store i64 %243, i64* %517, align 4
  %244 = getelementptr inbounds i8, i8* %514, i64 64
  %245 = bitcast i8* %244 to double*
  store double %242, double* %245, align 8
  br label %pow.i.9

pow_body.i.8:                                     ; preds = %pow.i.8
  %new_acc.i.8 = shl i64 %storemerge1.i.8, 1
  %new_exp.i.8 = add i64 %storemerge.i.8, -1
  br label %pow.i.8

pow.i.9:                                          ; preds = %pow_body.i.9, %cond_exit_91.8
  %storemerge1.i.9 = phi i64 [ %new_acc.i.9, %pow_body.i.9 ], [ 2, %cond_exit_91.8 ]
  %storemerge.i.9 = phi i64 [ %new_exp.i.9, %pow_body.i.9 ], [ 9, %cond_exit_91.8 ]
  switch i64 %storemerge.i.9, label %pow_body.i.9 [
    i64 1, label %__barray_check_bounds.exit958.loopexit.9
    i64 0, label %__barray_check_bounds.exit958.9
  ]

__barray_check_bounds.exit958.loopexit.9:         ; preds = %pow.i.9
  br label %__barray_check_bounds.exit958.9

__barray_check_bounds.exit958.9:                  ; preds = %pow.i.9, %__barray_check_bounds.exit958.loopexit.9
  %storemerge3.i.9 = phi i64 [ %storemerge1.i.9, %__barray_check_bounds.exit958.loopexit.9 ], [ 1, %pow.i.9 ]
  %246 = load i64, i64* %517, align 4
  %247 = and i64 %246, 512
  %.not.i959.9 = icmp eq i64 %247, 0
  br i1 %.not.i959.9, label %panic.i960, label %cond_exit_91.9

cond_exit_91.9:                                   ; preds = %__barray_check_bounds.exit958.9
  %248 = sitofp i64 %storemerge3.i.9 to double
  %249 = fdiv double 1.000000e+00, %248
  %250 = xor i64 %246, 512
  store i64 %250, i64* %517, align 4
  %251 = getelementptr inbounds i8, i8* %514, i64 72
  %252 = bitcast i8* %251 to double*
  store double %249, double* %252, align 8
  %253 = load i64, i64* %517, align 4
  %254 = and i64 %253, 1023
  store i64 %254, i64* %517, align 4
  %255 = icmp eq i64 %254, 0
  br i1 %255, label %__barray_check_none_borrowed.exit966, label %mask_block_err.i965

pow_body.i.9:                                     ; preds = %pow.i.9
  %new_acc.i.9 = shl i64 %storemerge1.i.9, 1
  %new_exp.i.9 = add i64 %storemerge.i.9, -1
  br label %pow.i.9

__barray_check_none_borrowed.exit966:             ; preds = %cond_exit_91.9
  %256 = call i8* @heap_alloc(i64 80)
  %257 = bitcast i8* %256 to double*
  %258 = call i8* @heap_alloc(i64 8)
  %259 = bitcast i8* %258 to i64*
  store i64 0, i64* %259, align 1
  call void @llvm.memcpy.p0f64.p0f64.i64(double* noundef nonnull align 1 dereferenceable(80) %257, double* noundef nonnull align 1 dereferenceable(80) %515, i64 80, i1 false)
  call void @heap_free(i8* %256)
  %260 = load i64, i64* %517, align 4
  %261 = and i64 %260, 1023
  store i64 %261, i64* %517, align 4
  %262 = icmp eq i64 %261, 0
  br i1 %262, label %__barray_check_none_borrowed.exit971, label %mask_block_err.i970

mask_block_err.i965:                              ; preds = %cond_exit_91.9
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit971:             ; preds = %__barray_check_none_borrowed.exit966
  %out_arr_alloca303 = alloca <{ i32, i32, double*, i1* }>, align 8
  %x_ptr304 = getelementptr inbounds <{ i32, i32, double*, i1* }>, <{ i32, i32, double*, i1* }>* %out_arr_alloca303, i64 0, i32 0
  %y_ptr305 = getelementptr inbounds <{ i32, i32, double*, i1* }>, <{ i32, i32, double*, i1* }>* %out_arr_alloca303, i64 0, i32 1
  %arr_ptr306 = getelementptr inbounds <{ i32, i32, double*, i1* }>, <{ i32, i32, double*, i1* }>* %out_arr_alloca303, i64 0, i32 2
  %mask_ptr307 = getelementptr inbounds <{ i32, i32, double*, i1* }>, <{ i32, i32, double*, i1* }>* %out_arr_alloca303, i64 0, i32 3
  %263 = alloca [10 x i1], align 1
  %.sub781 = getelementptr inbounds [10 x i1], [10 x i1]* %263, i64 0, i64 0
  %264 = bitcast [10 x i1]* %263 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(10) %264, i8 0, i64 10, i1 false)
  store i32 10, i32* %x_ptr304, align 8
  store i32 1, i32* %y_ptr305, align 4
  %265 = bitcast double** %arr_ptr306 to i8**
  store i8* %514, i8** %265, align 8
  store i1* %.sub781, i1** %mask_ptr307, align 8
  call void @print_float_arr(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @res_floats.8646C2EF.0, i64 0, i64 0), i64 20, <{ i32, i32, double*, i1* }>* nonnull %out_arr_alloca303)
  br label %__barray_check_bounds.exit979

mask_block_err.i970:                              ; preds = %__barray_check_none_borrowed.exit966
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit979:                    ; preds = %cond_exit_133.24, %__barray_check_none_borrowed.exit971
  %"128_0.sroa.0.01030" = phi i64 [ 0, %__barray_check_none_borrowed.exit971 ], [ %482, %cond_exit_133.24 ]
  %266 = add nuw nsw i64 %"128_0.sroa.0.01030", 1
  %267 = lshr i64 %"128_0.sroa.0.01030", 6
  %268 = getelementptr inbounds i64, i64* %513, i64 %267
  %269 = load i64, i64* %268, align 4
  %270 = and i64 %"128_0.sroa.0.01030", 63
  %271 = shl nuw i64 1, %270
  %272 = and i64 %269, %271
  %.not.i980 = icmp eq i64 %272, 0
  br i1 %.not.i980, label %panic.i981, label %cond_exit_133

panic.i981:                                       ; preds = %cond_exit_133.23, %cond_exit_133.22, %cond_exit_133.21, %cond_exit_133.20, %cond_exit_133.19, %cond_exit_133.18, %cond_exit_133.17, %cond_exit_133.16, %cond_exit_133.15, %cond_exit_133.14, %cond_exit_133.13, %cond_exit_133.12, %cond_exit_133.11, %cond_exit_133.10, %cond_exit_133.9, %cond_exit_133.8, %cond_exit_133.7, %cond_exit_133.6, %cond_exit_133.5, %cond_exit_133.4, %cond_exit_133.3, %cond_exit_133.2, %cond_exit_133.1, %cond_exit_133, %__barray_check_bounds.exit979
  call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_133:                                    ; preds = %__barray_check_bounds.exit979
  %273 = xor i64 %269, %271
  store i64 %273, i64* %268, align 4
  %274 = getelementptr inbounds i64, i64* %511, i64 %"128_0.sroa.0.01030"
  store i64 %"128_0.sroa.0.01030", i64* %274, align 4
  %275 = add nuw nsw i64 %"128_0.sroa.0.01030", 2
  %276 = lshr i64 %266, 6
  %277 = getelementptr inbounds i64, i64* %513, i64 %276
  %278 = load i64, i64* %277, align 4
  %279 = and i64 %266, 63
  %280 = shl nuw i64 1, %279
  %281 = and i64 %278, %280
  %.not.i980.1 = icmp eq i64 %281, 0
  br i1 %.not.i980.1, label %panic.i981, label %cond_exit_133.1

cond_exit_133.1:                                  ; preds = %cond_exit_133
  %282 = xor i64 %278, %280
  store i64 %282, i64* %277, align 4
  %283 = getelementptr inbounds i64, i64* %511, i64 %266
  store i64 %266, i64* %283, align 4
  %284 = add nuw nsw i64 %"128_0.sroa.0.01030", 3
  %285 = lshr i64 %275, 6
  %286 = getelementptr inbounds i64, i64* %513, i64 %285
  %287 = load i64, i64* %286, align 4
  %288 = and i64 %275, 63
  %289 = shl nuw i64 1, %288
  %290 = and i64 %287, %289
  %.not.i980.2 = icmp eq i64 %290, 0
  br i1 %.not.i980.2, label %panic.i981, label %cond_exit_133.2

cond_exit_133.2:                                  ; preds = %cond_exit_133.1
  %291 = xor i64 %287, %289
  store i64 %291, i64* %286, align 4
  %292 = getelementptr inbounds i64, i64* %511, i64 %275
  store i64 %275, i64* %292, align 4
  %293 = add nuw nsw i64 %"128_0.sroa.0.01030", 4
  %294 = lshr i64 %284, 6
  %295 = getelementptr inbounds i64, i64* %513, i64 %294
  %296 = load i64, i64* %295, align 4
  %297 = and i64 %284, 63
  %298 = shl nuw i64 1, %297
  %299 = and i64 %296, %298
  %.not.i980.3 = icmp eq i64 %299, 0
  br i1 %.not.i980.3, label %panic.i981, label %cond_exit_133.3

cond_exit_133.3:                                  ; preds = %cond_exit_133.2
  %300 = xor i64 %296, %298
  store i64 %300, i64* %295, align 4
  %301 = getelementptr inbounds i64, i64* %511, i64 %284
  store i64 %284, i64* %301, align 4
  %302 = add nuw nsw i64 %"128_0.sroa.0.01030", 5
  %303 = lshr i64 %293, 6
  %304 = getelementptr inbounds i64, i64* %513, i64 %303
  %305 = load i64, i64* %304, align 4
  %306 = and i64 %293, 63
  %307 = shl nuw i64 1, %306
  %308 = and i64 %305, %307
  %.not.i980.4 = icmp eq i64 %308, 0
  br i1 %.not.i980.4, label %panic.i981, label %cond_exit_133.4

cond_exit_133.4:                                  ; preds = %cond_exit_133.3
  %309 = xor i64 %305, %307
  store i64 %309, i64* %304, align 4
  %310 = getelementptr inbounds i64, i64* %511, i64 %293
  store i64 %293, i64* %310, align 4
  %311 = add nuw nsw i64 %"128_0.sroa.0.01030", 6
  %312 = lshr i64 %302, 6
  %313 = getelementptr inbounds i64, i64* %513, i64 %312
  %314 = load i64, i64* %313, align 4
  %315 = and i64 %302, 63
  %316 = shl nuw i64 1, %315
  %317 = and i64 %314, %316
  %.not.i980.5 = icmp eq i64 %317, 0
  br i1 %.not.i980.5, label %panic.i981, label %cond_exit_133.5

cond_exit_133.5:                                  ; preds = %cond_exit_133.4
  %318 = xor i64 %314, %316
  store i64 %318, i64* %313, align 4
  %319 = getelementptr inbounds i64, i64* %511, i64 %302
  store i64 %302, i64* %319, align 4
  %320 = add nuw nsw i64 %"128_0.sroa.0.01030", 7
  %321 = lshr i64 %311, 6
  %322 = getelementptr inbounds i64, i64* %513, i64 %321
  %323 = load i64, i64* %322, align 4
  %324 = and i64 %311, 63
  %325 = shl nuw i64 1, %324
  %326 = and i64 %323, %325
  %.not.i980.6 = icmp eq i64 %326, 0
  br i1 %.not.i980.6, label %panic.i981, label %cond_exit_133.6

cond_exit_133.6:                                  ; preds = %cond_exit_133.5
  %327 = xor i64 %323, %325
  store i64 %327, i64* %322, align 4
  %328 = getelementptr inbounds i64, i64* %511, i64 %311
  store i64 %311, i64* %328, align 4
  %329 = add nuw nsw i64 %"128_0.sroa.0.01030", 8
  %330 = lshr i64 %320, 6
  %331 = getelementptr inbounds i64, i64* %513, i64 %330
  %332 = load i64, i64* %331, align 4
  %333 = and i64 %320, 63
  %334 = shl nuw i64 1, %333
  %335 = and i64 %332, %334
  %.not.i980.7 = icmp eq i64 %335, 0
  br i1 %.not.i980.7, label %panic.i981, label %cond_exit_133.7

cond_exit_133.7:                                  ; preds = %cond_exit_133.6
  %336 = xor i64 %332, %334
  store i64 %336, i64* %331, align 4
  %337 = getelementptr inbounds i64, i64* %511, i64 %320
  store i64 %320, i64* %337, align 4
  %338 = add nuw nsw i64 %"128_0.sroa.0.01030", 9
  %339 = lshr i64 %329, 6
  %340 = getelementptr inbounds i64, i64* %513, i64 %339
  %341 = load i64, i64* %340, align 4
  %342 = and i64 %329, 63
  %343 = shl nuw i64 1, %342
  %344 = and i64 %341, %343
  %.not.i980.8 = icmp eq i64 %344, 0
  br i1 %.not.i980.8, label %panic.i981, label %cond_exit_133.8

cond_exit_133.8:                                  ; preds = %cond_exit_133.7
  %345 = xor i64 %341, %343
  store i64 %345, i64* %340, align 4
  %346 = getelementptr inbounds i64, i64* %511, i64 %329
  store i64 %329, i64* %346, align 4
  %347 = add nuw nsw i64 %"128_0.sroa.0.01030", 10
  %348 = lshr i64 %338, 6
  %349 = getelementptr inbounds i64, i64* %513, i64 %348
  %350 = load i64, i64* %349, align 4
  %351 = and i64 %338, 63
  %352 = shl nuw i64 1, %351
  %353 = and i64 %350, %352
  %.not.i980.9 = icmp eq i64 %353, 0
  br i1 %.not.i980.9, label %panic.i981, label %cond_exit_133.9

cond_exit_133.9:                                  ; preds = %cond_exit_133.8
  %354 = xor i64 %350, %352
  store i64 %354, i64* %349, align 4
  %355 = getelementptr inbounds i64, i64* %511, i64 %338
  store i64 %338, i64* %355, align 4
  %356 = add nuw nsw i64 %"128_0.sroa.0.01030", 11
  %357 = lshr i64 %347, 6
  %358 = getelementptr inbounds i64, i64* %513, i64 %357
  %359 = load i64, i64* %358, align 4
  %360 = and i64 %347, 63
  %361 = shl nuw i64 1, %360
  %362 = and i64 %359, %361
  %.not.i980.10 = icmp eq i64 %362, 0
  br i1 %.not.i980.10, label %panic.i981, label %cond_exit_133.10

cond_exit_133.10:                                 ; preds = %cond_exit_133.9
  %363 = xor i64 %359, %361
  store i64 %363, i64* %358, align 4
  %364 = getelementptr inbounds i64, i64* %511, i64 %347
  store i64 %347, i64* %364, align 4
  %365 = add nuw nsw i64 %"128_0.sroa.0.01030", 12
  %366 = lshr i64 %356, 6
  %367 = getelementptr inbounds i64, i64* %513, i64 %366
  %368 = load i64, i64* %367, align 4
  %369 = and i64 %356, 63
  %370 = shl nuw i64 1, %369
  %371 = and i64 %368, %370
  %.not.i980.11 = icmp eq i64 %371, 0
  br i1 %.not.i980.11, label %panic.i981, label %cond_exit_133.11

cond_exit_133.11:                                 ; preds = %cond_exit_133.10
  %372 = xor i64 %368, %370
  store i64 %372, i64* %367, align 4
  %373 = getelementptr inbounds i64, i64* %511, i64 %356
  store i64 %356, i64* %373, align 4
  %374 = add nuw nsw i64 %"128_0.sroa.0.01030", 13
  %375 = lshr i64 %365, 6
  %376 = getelementptr inbounds i64, i64* %513, i64 %375
  %377 = load i64, i64* %376, align 4
  %378 = and i64 %365, 63
  %379 = shl nuw i64 1, %378
  %380 = and i64 %377, %379
  %.not.i980.12 = icmp eq i64 %380, 0
  br i1 %.not.i980.12, label %panic.i981, label %cond_exit_133.12

cond_exit_133.12:                                 ; preds = %cond_exit_133.11
  %381 = xor i64 %377, %379
  store i64 %381, i64* %376, align 4
  %382 = getelementptr inbounds i64, i64* %511, i64 %365
  store i64 %365, i64* %382, align 4
  %383 = add nuw nsw i64 %"128_0.sroa.0.01030", 14
  %384 = lshr i64 %374, 6
  %385 = getelementptr inbounds i64, i64* %513, i64 %384
  %386 = load i64, i64* %385, align 4
  %387 = and i64 %374, 63
  %388 = shl nuw i64 1, %387
  %389 = and i64 %386, %388
  %.not.i980.13 = icmp eq i64 %389, 0
  br i1 %.not.i980.13, label %panic.i981, label %cond_exit_133.13

cond_exit_133.13:                                 ; preds = %cond_exit_133.12
  %390 = xor i64 %386, %388
  store i64 %390, i64* %385, align 4
  %391 = getelementptr inbounds i64, i64* %511, i64 %374
  store i64 %374, i64* %391, align 4
  %392 = add nuw nsw i64 %"128_0.sroa.0.01030", 15
  %393 = lshr i64 %383, 6
  %394 = getelementptr inbounds i64, i64* %513, i64 %393
  %395 = load i64, i64* %394, align 4
  %396 = and i64 %383, 63
  %397 = shl nuw i64 1, %396
  %398 = and i64 %395, %397
  %.not.i980.14 = icmp eq i64 %398, 0
  br i1 %.not.i980.14, label %panic.i981, label %cond_exit_133.14

cond_exit_133.14:                                 ; preds = %cond_exit_133.13
  %399 = xor i64 %395, %397
  store i64 %399, i64* %394, align 4
  %400 = getelementptr inbounds i64, i64* %511, i64 %383
  store i64 %383, i64* %400, align 4
  %401 = add nuw nsw i64 %"128_0.sroa.0.01030", 16
  %402 = lshr i64 %392, 6
  %403 = getelementptr inbounds i64, i64* %513, i64 %402
  %404 = load i64, i64* %403, align 4
  %405 = and i64 %392, 63
  %406 = shl nuw i64 1, %405
  %407 = and i64 %404, %406
  %.not.i980.15 = icmp eq i64 %407, 0
  br i1 %.not.i980.15, label %panic.i981, label %cond_exit_133.15

cond_exit_133.15:                                 ; preds = %cond_exit_133.14
  %408 = xor i64 %404, %406
  store i64 %408, i64* %403, align 4
  %409 = getelementptr inbounds i64, i64* %511, i64 %392
  store i64 %392, i64* %409, align 4
  %410 = add nuw nsw i64 %"128_0.sroa.0.01030", 17
  %411 = lshr i64 %401, 6
  %412 = getelementptr inbounds i64, i64* %513, i64 %411
  %413 = load i64, i64* %412, align 4
  %414 = and i64 %401, 63
  %415 = shl nuw i64 1, %414
  %416 = and i64 %413, %415
  %.not.i980.16 = icmp eq i64 %416, 0
  br i1 %.not.i980.16, label %panic.i981, label %cond_exit_133.16

cond_exit_133.16:                                 ; preds = %cond_exit_133.15
  %417 = xor i64 %413, %415
  store i64 %417, i64* %412, align 4
  %418 = getelementptr inbounds i64, i64* %511, i64 %401
  store i64 %401, i64* %418, align 4
  %419 = add nuw nsw i64 %"128_0.sroa.0.01030", 18
  %420 = lshr i64 %410, 6
  %421 = getelementptr inbounds i64, i64* %513, i64 %420
  %422 = load i64, i64* %421, align 4
  %423 = and i64 %410, 63
  %424 = shl nuw i64 1, %423
  %425 = and i64 %422, %424
  %.not.i980.17 = icmp eq i64 %425, 0
  br i1 %.not.i980.17, label %panic.i981, label %cond_exit_133.17

cond_exit_133.17:                                 ; preds = %cond_exit_133.16
  %426 = xor i64 %422, %424
  store i64 %426, i64* %421, align 4
  %427 = getelementptr inbounds i64, i64* %511, i64 %410
  store i64 %410, i64* %427, align 4
  %428 = add nuw nsw i64 %"128_0.sroa.0.01030", 19
  %429 = lshr i64 %419, 6
  %430 = getelementptr inbounds i64, i64* %513, i64 %429
  %431 = load i64, i64* %430, align 4
  %432 = and i64 %419, 63
  %433 = shl nuw i64 1, %432
  %434 = and i64 %431, %433
  %.not.i980.18 = icmp eq i64 %434, 0
  br i1 %.not.i980.18, label %panic.i981, label %cond_exit_133.18

cond_exit_133.18:                                 ; preds = %cond_exit_133.17
  %435 = xor i64 %431, %433
  store i64 %435, i64* %430, align 4
  %436 = getelementptr inbounds i64, i64* %511, i64 %419
  store i64 %419, i64* %436, align 4
  %437 = add nuw nsw i64 %"128_0.sroa.0.01030", 20
  %438 = lshr i64 %428, 6
  %439 = getelementptr inbounds i64, i64* %513, i64 %438
  %440 = load i64, i64* %439, align 4
  %441 = and i64 %428, 63
  %442 = shl nuw i64 1, %441
  %443 = and i64 %440, %442
  %.not.i980.19 = icmp eq i64 %443, 0
  br i1 %.not.i980.19, label %panic.i981, label %cond_exit_133.19

cond_exit_133.19:                                 ; preds = %cond_exit_133.18
  %444 = xor i64 %440, %442
  store i64 %444, i64* %439, align 4
  %445 = getelementptr inbounds i64, i64* %511, i64 %428
  store i64 %428, i64* %445, align 4
  %446 = add nuw nsw i64 %"128_0.sroa.0.01030", 21
  %447 = lshr i64 %437, 6
  %448 = getelementptr inbounds i64, i64* %513, i64 %447
  %449 = load i64, i64* %448, align 4
  %450 = and i64 %437, 63
  %451 = shl nuw i64 1, %450
  %452 = and i64 %449, %451
  %.not.i980.20 = icmp eq i64 %452, 0
  br i1 %.not.i980.20, label %panic.i981, label %cond_exit_133.20

cond_exit_133.20:                                 ; preds = %cond_exit_133.19
  %453 = xor i64 %449, %451
  store i64 %453, i64* %448, align 4
  %454 = getelementptr inbounds i64, i64* %511, i64 %437
  store i64 %437, i64* %454, align 4
  %455 = add nuw nsw i64 %"128_0.sroa.0.01030", 22
  %456 = lshr i64 %446, 6
  %457 = getelementptr inbounds i64, i64* %513, i64 %456
  %458 = load i64, i64* %457, align 4
  %459 = and i64 %446, 63
  %460 = shl nuw i64 1, %459
  %461 = and i64 %458, %460
  %.not.i980.21 = icmp eq i64 %461, 0
  br i1 %.not.i980.21, label %panic.i981, label %cond_exit_133.21

cond_exit_133.21:                                 ; preds = %cond_exit_133.20
  %462 = xor i64 %458, %460
  store i64 %462, i64* %457, align 4
  %463 = getelementptr inbounds i64, i64* %511, i64 %446
  store i64 %446, i64* %463, align 4
  %464 = add nuw nsw i64 %"128_0.sroa.0.01030", 23
  %465 = lshr i64 %455, 6
  %466 = getelementptr inbounds i64, i64* %513, i64 %465
  %467 = load i64, i64* %466, align 4
  %468 = and i64 %455, 63
  %469 = shl nuw i64 1, %468
  %470 = and i64 %467, %469
  %.not.i980.22 = icmp eq i64 %470, 0
  br i1 %.not.i980.22, label %panic.i981, label %cond_exit_133.22

cond_exit_133.22:                                 ; preds = %cond_exit_133.21
  %471 = xor i64 %467, %469
  store i64 %471, i64* %466, align 4
  %472 = getelementptr inbounds i64, i64* %511, i64 %455
  store i64 %455, i64* %472, align 4
  %473 = add nuw nsw i64 %"128_0.sroa.0.01030", 24
  %474 = lshr i64 %464, 6
  %475 = getelementptr inbounds i64, i64* %513, i64 %474
  %476 = load i64, i64* %475, align 4
  %477 = and i64 %464, 63
  %478 = shl nuw i64 1, %477
  %479 = and i64 %476, %478
  %.not.i980.23 = icmp eq i64 %479, 0
  br i1 %.not.i980.23, label %panic.i981, label %cond_exit_133.23

cond_exit_133.23:                                 ; preds = %cond_exit_133.22
  %480 = xor i64 %476, %478
  store i64 %480, i64* %475, align 4
  %481 = getelementptr inbounds i64, i64* %511, i64 %464
  store i64 %464, i64* %481, align 4
  %482 = add nuw nsw i64 %"128_0.sroa.0.01030", 25
  %483 = lshr i64 %473, 6
  %484 = getelementptr inbounds i64, i64* %513, i64 %483
  %485 = load i64, i64* %484, align 4
  %486 = and i64 %473, 63
  %487 = shl nuw i64 1, %486
  %488 = and i64 %485, %487
  %.not.i980.24 = icmp eq i64 %488, 0
  br i1 %.not.i980.24, label %panic.i981, label %cond_exit_133.24

cond_exit_133.24:                                 ; preds = %cond_exit_133.23
  %489 = xor i64 %485, %487
  store i64 %489, i64* %484, align 4
  %490 = getelementptr inbounds i64, i64* %511, i64 %473
  store i64 %473, i64* %490, align 4
  %exitcond1043.not.24 = icmp eq i64 %482, 100
  br i1 %exitcond1043.not.24, label %loop_out315, label %__barray_check_bounds.exit979

loop_out315:                                      ; preds = %cond_exit_133.24
  %491 = getelementptr inbounds i8, i8* %512, i64 8
  %492 = bitcast i8* %491 to i64*
  %493 = load i64, i64* %492, align 4
  %494 = and i64 %493, 68719476735
  store i64 %494, i64* %492, align 4
  %495 = load i64, i64* %513, align 4
  %496 = icmp eq i64 %495, 0
  %497 = icmp eq i64 %494, 0
  %or.cond = select i1 %496, i1 %497, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit987, label %mask_block_err.i986

__barray_check_none_borrowed.exit987:             ; preds = %loop_out315
  %498 = call i8* @heap_alloc(i64 800)
  %499 = bitcast i8* %498 to i64*
  %500 = call i8* @heap_alloc(i64 16)
  %501 = bitcast i8* %500 to i64*
  call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %501, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0i64.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(800) %499, i64* noundef nonnull align 1 dereferenceable(800) %511, i64 800, i1 false)
  call void @heap_free(i8* %498)
  %502 = load i64, i64* %492, align 4
  %503 = and i64 %502, 68719476735
  store i64 %503, i64* %492, align 4
  %504 = load i64, i64* %513, align 4
  %505 = icmp eq i64 %504, 0
  %506 = icmp eq i64 %503, 0
  %or.cond1046 = select i1 %505, i1 %506, i1 false
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
  %507 = alloca [100 x i1], align 1
  %.sub792 = getelementptr inbounds [100 x i1], [100 x i1]* %507, i64 0, i64 0
  %508 = bitcast [100 x i1]* %507 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(100) %508, i8 0, i64 100, i1 false)
  store i32 100, i32* %x_ptr391, align 8
  store i32 1, i32* %y_ptr392, align 4
  %509 = bitcast i64** %arr_ptr393 to i8**
  store i8* %510, i8** %509, align 8
  store i1* %.sub792, i1** %mask_ptr394, align 8
  call void @print_int_arr(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @res_ints.B3BC9D53.0, i64 0, i64 0), i64 16, <{ i32, i32, i64*, i1* }>* nonnull %out_arr_alloca390)
  ret void

mask_block_err.i991:                              ; preds = %__barray_check_none_borrowed.exit987
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_exit_163:                                    ; preds = %__barray_mask_return.exit
  %510 = tail call i8* @heap_alloc(i64 800)
  %511 = bitcast i8* %510 to i64*
  %512 = tail call i8* @heap_alloc(i64 16)
  %513 = bitcast i8* %512 to i64*
  tail call void @llvm.memset.p0i64.i64(i64* noundef nonnull align 1 dereferenceable(16) %513, i8 -1, i64 16, i1 false)
  %514 = tail call i8* @heap_alloc(i64 80)
  %515 = bitcast i8* %514 to double*
  %516 = tail call i8* @heap_alloc(i64 8)
  %517 = bitcast i8* %516 to i64*
  store i64 -1, i64* %517, align 1
  %518 = tail call i8* @heap_alloc(i64 240)
  %519 = bitcast i8* %518 to { i1, i64, i1 }*
  %520 = tail call i8* @heap_alloc(i64 8)
  %521 = bitcast i8* %520 to i64*
  store i64 -1, i64* %521, align 1
  br label %531

mask_block_ok.i.i.i:                              ; preds = %cond_exit_566.i
  %522 = load i64, i64* %3, align 4
  %523 = or i64 %522, -1024
  store i64 %523, i64* %3, align 4
  %524 = icmp eq i64 %523, -1
  br i1 %524, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit", label %mask_block_err.i.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit": ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %525 = tail call i8* @heap_alloc(i64 320)
  %526 = tail call i8* @heap_alloc(i64 8)
  %527 = bitcast i8* %526 to i64*
  store i64 0, i64* %527, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(320) %525, i8 0, i64 320, i1 false)
  %528 = load i64, i64* %521, align 4
  %529 = and i64 %528, 1023
  store i64 %529, i64* %521, align 4
  %530 = icmp eq i64 %529, 0
  br i1 %530, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

531:                                              ; preds = %cond_exit_163, %cond_exit_566.i
  %"515_0.sroa.15.0.i1021" = phi i64 [ 0, %cond_exit_163 ], [ %532, %cond_exit_566.i ]
  %532 = add nuw nsw i64 %"515_0.sroa.15.0.i1021", 1
  %533 = lshr i64 %"515_0.sroa.15.0.i1021", 6
  %534 = getelementptr inbounds i64, i64* %3, i64 %533
  %535 = load i64, i64* %534, align 4
  %536 = shl nuw nsw i64 1, %"515_0.sroa.15.0.i1021"
  %537 = and i64 %535, %536
  %.not.i101.i.i = icmp eq i64 %537, 0
  br i1 %.not.i101.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %531
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %531
  %538 = xor i64 %535, %536
  store i64 %538, i64* %534, align 4
  %539 = getelementptr inbounds i64, i64* %1, i64 %"515_0.sroa.15.0.i1021"
  %540 = load i64, i64* %539, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %540)
  tail call void @___qfree(i64 %540)
  %541 = getelementptr inbounds i64, i64* %521, i64 %533
  %542 = load i64, i64* %541, align 4
  %543 = and i64 %542, %536
  %.not.i.i994 = icmp eq i64 %543, 0
  br i1 %.not.i.i994, label %panic.i.i995, label %cond_exit_566.i

panic.i.i995:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_566.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"580_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %544 = xor i64 %542, %536
  store i64 %544, i64* %541, align 4
  %545 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %519, i64 %"515_0.sroa.15.0.i1021"
  store { i1, i64, i1 } %"580_054.fca.1.insert.i", { i1, i64, i1 }* %545, align 4
  %exitcond1038.not = icmp eq i64 %532, 10
  br i1 %exitcond1038.not, label %mask_block_ok.i.i.i, label %531
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
  tail call fastcc void @__hugr__.__main__.array_results.1()
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
