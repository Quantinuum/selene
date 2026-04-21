; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
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

define internal fastcc void @__hugr__.__main__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 64)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_425_case_0.i, label %__hugr__.__tk2_qalloc.422.exit

cond_exit_174.loopexit:                           ; preds = %__barray_mask_return.exit926
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %exitcond977.not = icmp eq i64 %39, 8
  br i1 %exitcond977.not, label %cond_exit_91, label %__barray_check_bounds.exit869

cond_189_case_1:                                  ; preds = %__barray_check_bounds.exit911
  %2 = xor i64 %254, %43
  store i64 %2, ptr %1, align 4
  %3 = load i64, ptr %45, align 4
  br label %pow.i

pow.i:                                            ; preds = %cond_189_case_1, %pow_body.i
  %storemerge71.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %cond_189_case_1 ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"45_0.0966", %cond_189_case_1 ]
  switch i64 %storemerge.i, label %pow_body.i [
    i64 1, label %__hugr__.guppylang.std.num.int.__pow__.380.exit.loopexit
    i64 0, label %__hugr__.guppylang.std.num.int.__pow__.380.exit
  ]

pow_body.i:                                       ; preds = %pow.i
  %new_acc.i = shl i64 %storemerge71.i, 1
  %new_exp.i = add i64 %storemerge.i, -1
  br label %pow.i

__hugr__.guppylang.std.num.int.__pow__.380.exit.loopexit: ; preds = %pow.i
  %4 = sitofp i64 %storemerge71.i to double
  br label %__hugr__.guppylang.std.num.int.__pow__.380.exit

__hugr__.guppylang.std.num.int.__pow__.380.exit:  ; preds = %pow.i, %__hugr__.guppylang.std.num.int.__pow__.380.exit.loopexit
  %storemerge73.i = phi double [ %4, %__hugr__.guppylang.std.num.int.__pow__.380.exit.loopexit ], [ 1.000000e+00, %pow.i ]
  %5 = fdiv double 1.000000e+00, %storemerge73.i
  %6 = tail call double @llvm.fabs.f64(double %5)
  %7 = fcmp ueq double %6, 0x7FF0000000000000
  br i1 %7, label %257, label %__barray_check_bounds.exit915

cond_425_case_0.i:                                ; preds = %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.422.exit:                   ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %8 = load i64, ptr %1, align 4
  %9 = trunc i64 %8 to i1
  br i1 %9, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.7, %__hugr__.__tk2_qalloc.422.exit.6, %__hugr__.__tk2_qalloc.422.exit.5, %__hugr__.__tk2_qalloc.422.exit.4, %__hugr__.__tk2_qalloc.422.exit.3, %__hugr__.__tk2_qalloc.422.exit.2, %__hugr__.__tk2_qalloc.422.exit.1, %__hugr__.__tk2_qalloc.422.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_qalloc.422.exit
  %10 = and i64 %8, -2
  store i64 %10, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_425_case_0.i, label %__hugr__.__tk2_qalloc.422.exit.1

__hugr__.__tk2_qalloc.422.exit.1:                 ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %11 = load i64, ptr %1, align 4
  %12 = and i64 %11, 2
  %.not981 = icmp eq i64 %12, 0
  br i1 %.not981, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_qalloc.422.exit.1
  %13 = and i64 %11, -3
  store i64 %13, ptr %1, align 4
  %14 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %14, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_425_case_0.i, label %__hugr__.__tk2_qalloc.422.exit.2

__hugr__.__tk2_qalloc.422.exit.2:                 ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %15 = load i64, ptr %1, align 4
  %16 = and i64 %15, 4
  %.not982 = icmp eq i64 %16, 0
  br i1 %.not982, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_qalloc.422.exit.2
  %17 = and i64 %15, -5
  store i64 %17, ptr %1, align 4
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %18, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_425_case_0.i, label %__hugr__.__tk2_qalloc.422.exit.3

__hugr__.__tk2_qalloc.422.exit.3:                 ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %19 = load i64, ptr %1, align 4
  %20 = and i64 %19, 8
  %.not983 = icmp eq i64 %20, 0
  br i1 %.not983, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_qalloc.422.exit.3
  %21 = and i64 %19, -9
  store i64 %21, ptr %1, align 4
  %22 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %22, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_425_case_0.i, label %__hugr__.__tk2_qalloc.422.exit.4

__hugr__.__tk2_qalloc.422.exit.4:                 ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %23 = load i64, ptr %1, align 4
  %24 = and i64 %23, 16
  %.not984 = icmp eq i64 %24, 0
  br i1 %.not984, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_qalloc.422.exit.4
  %25 = and i64 %23, -17
  store i64 %25, ptr %1, align 4
  %26 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %26, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_425_case_0.i, label %__hugr__.__tk2_qalloc.422.exit.5

__hugr__.__tk2_qalloc.422.exit.5:                 ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %27 = load i64, ptr %1, align 4
  %28 = and i64 %27, 32
  %.not985 = icmp eq i64 %28, 0
  br i1 %.not985, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_qalloc.422.exit.5
  %29 = and i64 %27, -33
  store i64 %29, ptr %1, align 4
  %30 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %30, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_425_case_0.i, label %__hugr__.__tk2_qalloc.422.exit.6

__hugr__.__tk2_qalloc.422.exit.6:                 ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %31 = load i64, ptr %1, align 4
  %32 = and i64 %31, 64
  %.not986 = icmp eq i64 %32, 0
  br i1 %.not986, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_qalloc.422.exit.6
  %33 = and i64 %31, -65
  store i64 %33, ptr %1, align 4
  %34 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %34, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_425_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %35 = load i64, ptr %1, align 4
  %36 = and i64 %35, 128
  %.not987 = icmp eq i64 %36, 0
  br i1 %.not987, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %37 = and i64 %35, -129
  store i64 %37, ptr %1, align 4
  %38 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %38, align 4
  br label %__barray_check_bounds.exit869

__barray_check_bounds.exit869:                    ; preds = %cond_exit_174.loopexit, %cond_exit_20.7
  %indvars.iv = phi i64 [ 7, %cond_exit_20.7 ], [ %indvars.iv.next, %cond_exit_174.loopexit ]
  %"45_0.0966" = phi i64 [ 0, %cond_exit_20.7 ], [ %39, %cond_exit_174.loopexit ]
  %smax = tail call i64 @llvm.smax.i64(i64 %indvars.iv, i64 1)
  %39 = add nuw nsw i64 %"45_0.0966", 1
  %40 = load i64, ptr %1, align 4
  %41 = lshr i64 %40, %"45_0.0966"
  %42 = trunc i64 %41 to i1
  br i1 %42, label %panic.i870, label %__barray_check_bounds.exit872

panic.i870:                                       ; preds = %__barray_check_bounds.exit869
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit872:                    ; preds = %__barray_check_bounds.exit869
  %43 = shl nuw nsw i64 1, %"45_0.0966"
  %44 = xor i64 %40, %43
  store i64 %44, ptr %1, align 4
  %45 = getelementptr inbounds nuw i64, ptr %0, i64 %"45_0.0966"
  %46 = load i64, ptr %45, align 4
  tail call void @___rp(i64 %46, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %46, double 0x400921FB54442D18)
  %47 = load i64, ptr %1, align 4
  %48 = lshr i64 %47, %"45_0.0966"
  %49 = trunc i64 %48 to i1
  br i1 %49, label %__barray_mask_return.exit874, label %panic.i873

panic.i873:                                       ; preds = %__barray_check_bounds.exit872
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit874:                     ; preds = %__barray_check_bounds.exit872
  %50 = xor i64 %47, %43
  store i64 %50, ptr %1, align 4
  store i64 %46, ptr %45, align 4
  %.not974 = icmp eq i64 %"45_0.0966", 7
  br i1 %.not974, label %cond_exit_91, label %__barray_check_bounds.exit911

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(8).511.exit"
  %51 = tail call ptr @heap_alloc(i64 192)
  %52 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %52, align 1
  br label %53

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(8).511.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

53:                                               ; preds = %__barray_check_none_borrowed.exit, %"__hugr__.$__copy_scan$$n(8)$t([Bool]+[Future(Bool)])$n(1).300.exit"
  %storemerge832971 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %61, %"__hugr__.$__copy_scan$$n(8)$t([Bool]+[Future(Bool)])$n(1).300.exit" ]
  %54 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %203, i64 %storemerge832971
  %55 = load { i1, i64, i1 }, ptr %54, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %55, 0
  br i1 %.fca.0.extract118.i, label %cond_243_case_1.i, label %cond_243_case_0.i

cond_243_case_0.i:                                ; preds = %53
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %55, 2
  br label %cond_exit_243.i

cond_243_case_1.i:                                ; preds = %53
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %55, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_243.i

cond_exit_243.i:                                  ; preds = %cond_243_case_0.i, %cond_243_case_1.i
  %"03.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_243_case_1.i ], [ undef, %cond_243_case_0.i ]
  %"03.sroa.6.0.i" = phi i1 [ undef, %cond_243_case_1.i ], [ %.fca.2.extract120.i, %cond_243_case_0.i ]
  %56 = load i64, ptr %248, align 4
  %57 = lshr i64 %56, %storemerge832971
  %58 = trunc i64 %57 to i1
  br i1 %58, label %panic.i.i, label %cond_240_case_1.i

panic.i.i:                                        ; preds = %cond_exit_243.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_240_case_1.i:                                ; preds = %cond_exit_243.i
  %"16.fca.1.insert.i" = insertvalue { i1, i64, i1 } %55, i64 %"03.sroa.3.0.i", 1
  %"16.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i", i1 %"03.sroa.6.0.i", 2
  %59 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i", 1
  %60 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %247, i64 %storemerge832971
  %.fca.2.0.extract.i = load i1, ptr %60, align 1
  store { i1, { i1, i64, i1 } } %59, ptr %60, align 4
  br i1 %.fca.2.0.extract.i, label %cond_239_case_1.i, label %"__hugr__.$__copy_scan$$n(8)$t([Bool]+[Future(Bool)])$n(1).300.exit"

cond_239_case_1.i:                                ; preds = %cond_240_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(8)$t([Bool]+[Future(Bool)])$n(1).300.exit": ; preds = %cond_240_case_1.i
  %61 = add nuw nsw i64 %storemerge832971, 1
  %62 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %51, i64 %storemerge832971
  store { i1, i64, i1 } %"16.fca.2.insert.i", ptr %62, align 4
  %exitcond978.not = icmp eq i64 %61, 8
  br i1 %exitcond978.not, label %mask_block_ok.i875, label %53

mask_block_ok.i875:                               ; preds = %"__hugr__.$__copy_scan$$n(8)$t([Bool]+[Future(Bool)])$n(1).300.exit"
  tail call void @heap_free(ptr nonnull %203)
  tail call void @heap_free(ptr nonnull %204)
  %63 = load i64, ptr %248, align 4
  %64 = and i64 %63, 255
  store i64 %64, ptr %248, align 4
  %65 = icmp eq i64 %64, 0
  br i1 %65, label %__barray_check_none_borrowed.exit880, label %mask_block_err.i878

__barray_check_none_borrowed.exit880:             ; preds = %mask_block_ok.i875
  %66 = tail call ptr @heap_alloc(i64 192)
  %67 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %67, align 1
  %68 = load { i1, { i1, i64, i1 } }, ptr %247, align 4
  %69 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %68)
  %70 = extractvalue { { i1, i64, i1 } } %69, 0
  store { i1, i64, i1 } %70, ptr %66, align 4
  %71 = getelementptr i8, ptr %247, i64 32
  %72 = load { i1, { i1, i64, i1 } }, ptr %71, align 4
  %73 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %72)
  %74 = getelementptr inbounds nuw i8, ptr %66, i64 24
  %75 = extractvalue { { i1, i64, i1 } } %73, 0
  store { i1, i64, i1 } %75, ptr %74, align 4
  %76 = getelementptr i8, ptr %247, i64 64
  %77 = load { i1, { i1, i64, i1 } }, ptr %76, align 4
  %78 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %77)
  %79 = getelementptr inbounds nuw i8, ptr %66, i64 48
  %80 = extractvalue { { i1, i64, i1 } } %78, 0
  store { i1, i64, i1 } %80, ptr %79, align 4
  %81 = getelementptr i8, ptr %247, i64 96
  %82 = load { i1, { i1, i64, i1 } }, ptr %81, align 4
  %83 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %82)
  %84 = getelementptr inbounds nuw i8, ptr %66, i64 72
  %85 = extractvalue { { i1, i64, i1 } } %83, 0
  store { i1, i64, i1 } %85, ptr %84, align 4
  %86 = getelementptr i8, ptr %247, i64 128
  %87 = load { i1, { i1, i64, i1 } }, ptr %86, align 4
  %88 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %87)
  %89 = getelementptr inbounds nuw i8, ptr %66, i64 96
  %90 = extractvalue { { i1, i64, i1 } } %88, 0
  store { i1, i64, i1 } %90, ptr %89, align 4
  %91 = getelementptr i8, ptr %247, i64 160
  %92 = load { i1, { i1, i64, i1 } }, ptr %91, align 4
  %93 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %92)
  %94 = getelementptr inbounds nuw i8, ptr %66, i64 120
  %95 = extractvalue { { i1, i64, i1 } } %93, 0
  store { i1, i64, i1 } %95, ptr %94, align 4
  %96 = getelementptr i8, ptr %247, i64 192
  %97 = load { i1, { i1, i64, i1 } }, ptr %96, align 4
  %98 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %97)
  %99 = getelementptr inbounds nuw i8, ptr %66, i64 144
  %100 = extractvalue { { i1, i64, i1 } } %98, 0
  store { i1, i64, i1 } %100, ptr %99, align 4
  %101 = getelementptr i8, ptr %247, i64 224
  %102 = load { i1, { i1, i64, i1 } }, ptr %101, align 4
  %103 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %102)
  %104 = getelementptr inbounds nuw i8, ptr %66, i64 168
  %105 = extractvalue { { i1, i64, i1 } } %103, 0
  store { i1, i64, i1 } %105, ptr %104, align 4
  tail call void @heap_free(ptr nonnull %247)
  tail call void @heap_free(ptr nonnull %248)
  %106 = load i64, ptr %67, align 4
  %107 = trunc i64 %106 to i1
  br i1 %107, label %cond_exit_731, label %__barray_mask_borrow.exit891

mask_block_err.i878:                              ; preds = %mask_block_ok.i875
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

mask_block_err.i884:                              ; preds = %cond_exit_731.7
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit891:                     ; preds = %__barray_check_none_borrowed.exit880
  %108 = or disjoint i64 %106, 1
  store i64 %108, ptr %67, align 4
  %109 = load { i1, i64, i1 }, ptr %66, align 4
  %.fca.0.extract601 = extractvalue { i1, i64, i1 } %109, 0
  br i1 %.fca.0.extract601, label %cond_754_case_1, label %cond_exit_731

cond_exit_731:                                    ; preds = %cond_754_case_1, %__barray_mask_borrow.exit891, %__barray_check_none_borrowed.exit880
  %110 = load i64, ptr %67, align 4
  %111 = and i64 %110, 2
  %.not998 = icmp eq i64 %111, 0
  br i1 %.not998, label %__barray_mask_borrow.exit891.1, label %cond_exit_731.1

__barray_mask_borrow.exit891.1:                   ; preds = %cond_exit_731
  %112 = or disjoint i64 %110, 2
  store i64 %112, ptr %67, align 4
  %113 = getelementptr inbounds nuw i8, ptr %66, i64 24
  %114 = load { i1, i64, i1 }, ptr %113, align 4
  %.fca.0.extract601.1 = extractvalue { i1, i64, i1 } %114, 0
  br i1 %.fca.0.extract601.1, label %cond_754_case_1.1, label %cond_exit_731.1

cond_754_case_1.1:                                ; preds = %__barray_mask_borrow.exit891.1
  %.fca.1.extract602.1 = extractvalue { i1, i64, i1 } %114, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract602.1)
  br label %cond_exit_731.1

cond_exit_731.1:                                  ; preds = %cond_754_case_1.1, %__barray_mask_borrow.exit891.1, %cond_exit_731
  %115 = load i64, ptr %67, align 4
  %116 = and i64 %115, 4
  %.not999 = icmp eq i64 %116, 0
  br i1 %.not999, label %__barray_mask_borrow.exit891.2, label %cond_exit_731.2

__barray_mask_borrow.exit891.2:                   ; preds = %cond_exit_731.1
  %117 = or disjoint i64 %115, 4
  store i64 %117, ptr %67, align 4
  %118 = getelementptr inbounds nuw i8, ptr %66, i64 48
  %119 = load { i1, i64, i1 }, ptr %118, align 4
  %.fca.0.extract601.2 = extractvalue { i1, i64, i1 } %119, 0
  br i1 %.fca.0.extract601.2, label %cond_754_case_1.2, label %cond_exit_731.2

cond_754_case_1.2:                                ; preds = %__barray_mask_borrow.exit891.2
  %.fca.1.extract602.2 = extractvalue { i1, i64, i1 } %119, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract602.2)
  br label %cond_exit_731.2

cond_exit_731.2:                                  ; preds = %cond_754_case_1.2, %__barray_mask_borrow.exit891.2, %cond_exit_731.1
  %120 = load i64, ptr %67, align 4
  %121 = and i64 %120, 8
  %.not1000 = icmp eq i64 %121, 0
  br i1 %.not1000, label %__barray_mask_borrow.exit891.3, label %cond_exit_731.3

__barray_mask_borrow.exit891.3:                   ; preds = %cond_exit_731.2
  %122 = or disjoint i64 %120, 8
  store i64 %122, ptr %67, align 4
  %123 = getelementptr inbounds nuw i8, ptr %66, i64 72
  %124 = load { i1, i64, i1 }, ptr %123, align 4
  %.fca.0.extract601.3 = extractvalue { i1, i64, i1 } %124, 0
  br i1 %.fca.0.extract601.3, label %cond_754_case_1.3, label %cond_exit_731.3

cond_754_case_1.3:                                ; preds = %__barray_mask_borrow.exit891.3
  %.fca.1.extract602.3 = extractvalue { i1, i64, i1 } %124, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract602.3)
  br label %cond_exit_731.3

cond_exit_731.3:                                  ; preds = %cond_754_case_1.3, %__barray_mask_borrow.exit891.3, %cond_exit_731.2
  %125 = load i64, ptr %67, align 4
  %126 = and i64 %125, 16
  %.not1001 = icmp eq i64 %126, 0
  br i1 %.not1001, label %__barray_mask_borrow.exit891.4, label %cond_exit_731.4

__barray_mask_borrow.exit891.4:                   ; preds = %cond_exit_731.3
  %127 = or disjoint i64 %125, 16
  store i64 %127, ptr %67, align 4
  %128 = getelementptr inbounds nuw i8, ptr %66, i64 96
  %129 = load { i1, i64, i1 }, ptr %128, align 4
  %.fca.0.extract601.4 = extractvalue { i1, i64, i1 } %129, 0
  br i1 %.fca.0.extract601.4, label %cond_754_case_1.4, label %cond_exit_731.4

cond_754_case_1.4:                                ; preds = %__barray_mask_borrow.exit891.4
  %.fca.1.extract602.4 = extractvalue { i1, i64, i1 } %129, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract602.4)
  br label %cond_exit_731.4

cond_exit_731.4:                                  ; preds = %cond_754_case_1.4, %__barray_mask_borrow.exit891.4, %cond_exit_731.3
  %130 = load i64, ptr %67, align 4
  %131 = and i64 %130, 32
  %.not1002 = icmp eq i64 %131, 0
  br i1 %.not1002, label %__barray_mask_borrow.exit891.5, label %cond_exit_731.5

__barray_mask_borrow.exit891.5:                   ; preds = %cond_exit_731.4
  %132 = or disjoint i64 %130, 32
  store i64 %132, ptr %67, align 4
  %133 = getelementptr inbounds nuw i8, ptr %66, i64 120
  %134 = load { i1, i64, i1 }, ptr %133, align 4
  %.fca.0.extract601.5 = extractvalue { i1, i64, i1 } %134, 0
  br i1 %.fca.0.extract601.5, label %cond_754_case_1.5, label %cond_exit_731.5

cond_754_case_1.5:                                ; preds = %__barray_mask_borrow.exit891.5
  %.fca.1.extract602.5 = extractvalue { i1, i64, i1 } %134, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract602.5)
  br label %cond_exit_731.5

cond_exit_731.5:                                  ; preds = %cond_754_case_1.5, %__barray_mask_borrow.exit891.5, %cond_exit_731.4
  %135 = load i64, ptr %67, align 4
  %136 = and i64 %135, 64
  %.not1003 = icmp eq i64 %136, 0
  br i1 %.not1003, label %__barray_mask_borrow.exit891.6, label %cond_exit_731.6

__barray_mask_borrow.exit891.6:                   ; preds = %cond_exit_731.5
  %137 = or disjoint i64 %135, 64
  store i64 %137, ptr %67, align 4
  %138 = getelementptr inbounds nuw i8, ptr %66, i64 144
  %139 = load { i1, i64, i1 }, ptr %138, align 4
  %.fca.0.extract601.6 = extractvalue { i1, i64, i1 } %139, 0
  br i1 %.fca.0.extract601.6, label %cond_754_case_1.6, label %cond_exit_731.6

cond_754_case_1.6:                                ; preds = %__barray_mask_borrow.exit891.6
  %.fca.1.extract602.6 = extractvalue { i1, i64, i1 } %139, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract602.6)
  br label %cond_exit_731.6

cond_exit_731.6:                                  ; preds = %cond_754_case_1.6, %__barray_mask_borrow.exit891.6, %cond_exit_731.5
  %140 = load i64, ptr %67, align 4
  %141 = and i64 %140, 128
  %.not1004 = icmp eq i64 %141, 0
  br i1 %.not1004, label %__barray_mask_borrow.exit891.7, label %cond_exit_731.7

__barray_mask_borrow.exit891.7:                   ; preds = %cond_exit_731.6
  %142 = or disjoint i64 %140, 128
  store i64 %142, ptr %67, align 4
  %143 = getelementptr inbounds nuw i8, ptr %66, i64 168
  %144 = load { i1, i64, i1 }, ptr %143, align 4
  %.fca.0.extract601.7 = extractvalue { i1, i64, i1 } %144, 0
  br i1 %.fca.0.extract601.7, label %cond_754_case_1.7, label %cond_exit_731.7

cond_754_case_1.7:                                ; preds = %__barray_mask_borrow.exit891.7
  %.fca.1.extract602.7 = extractvalue { i1, i64, i1 } %144, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract602.7)
  br label %cond_exit_731.7

cond_exit_731.7:                                  ; preds = %cond_754_case_1.7, %__barray_mask_borrow.exit891.7, %cond_exit_731.6
  %145 = load i64, ptr %67, align 4
  %146 = or i64 %145, -256
  store i64 %146, ptr %67, align 4
  %147 = icmp eq i64 %146, -1
  br i1 %147, label %loop_out153, label %mask_block_err.i884

loop_out153:                                      ; preds = %cond_exit_731.7
  tail call void @heap_free(ptr nonnull %66)
  tail call void @heap_free(ptr nonnull %67)
  %148 = load i64, ptr %52, align 4
  %149 = and i64 %148, 255
  store i64 %149, ptr %52, align 4
  %150 = icmp eq i64 %149, 0
  br i1 %150, label %__barray_check_none_borrowed.exit897, label %mask_block_err.i895

__barray_check_none_borrowed.exit897:             ; preds = %loop_out153
  %151 = tail call ptr @heap_alloc(i64 8)
  %152 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %152, align 1
  %153 = load { i1, i64, i1 }, ptr %51, align 4
  %154 = tail call { i1 } @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %153)
  %155 = extractvalue { i1 } %154, 0
  store i1 %155, ptr %151, align 1
  %156 = getelementptr inbounds nuw i8, ptr %51, i64 24
  %157 = load { i1, i64, i1 }, ptr %156, align 4
  %158 = tail call { i1 } @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %157)
  %159 = getelementptr inbounds nuw i8, ptr %151, i64 1
  %160 = extractvalue { i1 } %158, 0
  store i1 %160, ptr %159, align 1
  %161 = getelementptr inbounds nuw i8, ptr %51, i64 48
  %162 = load { i1, i64, i1 }, ptr %161, align 4
  %163 = tail call { i1 } @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %162)
  %164 = getelementptr inbounds nuw i8, ptr %151, i64 2
  %165 = extractvalue { i1 } %163, 0
  store i1 %165, ptr %164, align 1
  %166 = getelementptr inbounds nuw i8, ptr %51, i64 72
  %167 = load { i1, i64, i1 }, ptr %166, align 4
  %168 = tail call { i1 } @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %167)
  %169 = getelementptr inbounds nuw i8, ptr %151, i64 3
  %170 = extractvalue { i1 } %168, 0
  store i1 %170, ptr %169, align 1
  %171 = getelementptr inbounds nuw i8, ptr %51, i64 96
  %172 = load { i1, i64, i1 }, ptr %171, align 4
  %173 = tail call { i1 } @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %172)
  %174 = getelementptr inbounds nuw i8, ptr %151, i64 4
  %175 = extractvalue { i1 } %173, 0
  store i1 %175, ptr %174, align 1
  %176 = getelementptr inbounds nuw i8, ptr %51, i64 120
  %177 = load { i1, i64, i1 }, ptr %176, align 4
  %178 = tail call { i1 } @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %177)
  %179 = getelementptr inbounds nuw i8, ptr %151, i64 5
  %180 = extractvalue { i1 } %178, 0
  store i1 %180, ptr %179, align 1
  %181 = getelementptr inbounds nuw i8, ptr %51, i64 144
  %182 = load { i1, i64, i1 }, ptr %181, align 4
  %183 = tail call { i1 } @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %182)
  %184 = getelementptr inbounds nuw i8, ptr %151, i64 6
  %185 = extractvalue { i1 } %183, 0
  store i1 %185, ptr %184, align 1
  %186 = getelementptr inbounds nuw i8, ptr %51, i64 168
  %187 = load { i1, i64, i1 }, ptr %186, align 4
  %188 = tail call { i1 } @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %187)
  %189 = getelementptr inbounds nuw i8, ptr %151, i64 7
  %190 = extractvalue { i1 } %188, 0
  store i1 %190, ptr %189, align 1
  tail call void @heap_free(ptr nonnull %51)
  tail call void @heap_free(ptr nonnull %52)
  %191 = load i64, ptr %152, align 4
  %192 = and i64 %191, 255
  store i64 %192, ptr %152, align 4
  %193 = icmp eq i64 %192, 0
  br i1 %193, label %__barray_check_none_borrowed.exit903, label %mask_block_err.i901

mask_block_err.i895:                              ; preds = %loop_out153
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_754_case_1:                                  ; preds = %__barray_mask_borrow.exit891
  %.fca.1.extract602 = extractvalue { i1, i64, i1 } %109, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract602)
  br label %cond_exit_731

__barray_check_none_borrowed.exit903:             ; preds = %__barray_check_none_borrowed.exit897
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %194 = alloca [8 x i1], align 8
  store i64 0, ptr %194, align 8
  store i32 8, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %151, ptr %arr_ptr, align 8
  store ptr %194, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_measuremen.F30240EB.0, i64 25, ptr nonnull %out_arr_alloca)
  ret void

mask_block_err.i901:                              ; preds = %__barray_check_none_borrowed.exit897
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_91:                                     ; preds = %__barray_mask_return.exit874, %cond_exit_174.loopexit
  %"45_368.fca.0.insert.le" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"45_368.fca.1.insert.le" = insertvalue { ptr, ptr, i64 } %"45_368.fca.0.insert.le", ptr %1, 1
  %"45_368.fca.2.insert.le" = insertvalue { ptr, ptr, i64 } %"45_368.fca.1.insert.le", i64 0, 2
  %195 = load i64, ptr %1, align 4
  %196 = and i64 %195, 128
  %.not = icmp eq i64 %196, 0
  br i1 %.not, label %__barray_mask_borrow.exit905, label %panic.i904

panic.i904:                                       ; preds = %cond_exit_91
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit905:                     ; preds = %cond_exit_91
  %197 = or disjoint i64 %195, 128
  store i64 %197, ptr %1, align 4
  %198 = load i64, ptr %38, align 4
  tail call void @___rp(i64 %198, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %198, double 0x400921FB54442D18)
  %199 = load i64, ptr %1, align 4
  %200 = and i64 %199, 128
  %.not949 = icmp eq i64 %200, 0
  br i1 %.not949, label %panic.i906, label %__barray_mask_return.exit907

panic.i906:                                       ; preds = %__barray_mask_borrow.exit905
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit907:                     ; preds = %__barray_mask_borrow.exit905
  %201 = and i64 %199, -129
  store i64 %201, ptr %1, align 4
  store i64 %198, ptr %38, align 4
  %202 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"45_368.fca.2.insert.le", 0
  %203 = tail call ptr @heap_alloc(i64 192)
  %204 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %204, align 1
  br label %__barray_check_bounds.exit.i.i

205:                                              ; preds = %loop_body.i
  %206 = lshr i64 %.fca.2.extract82.i.i, 6
  %207 = getelementptr i64, ptr %.fca.1.extract81.i.i, i64 %206
  %208 = load i64, ptr %207, align 4
  %209 = and i64 %.fca.2.extract82.i.i, 63
  %210 = sub nuw nsw i64 64, %209
  %211 = lshr i64 -1, %210
  %212 = icmp eq i64 %209, 0
  %213 = select i1 %212, i64 0, i64 %211
  %214 = or i64 %208, %213
  store i64 %214, ptr %207, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract82.i.i, 7
  %215 = lshr i64 %last_valid.i.i.i, 6
  %216 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i.i, i64 %215
  %217 = load i64, ptr %216, align 4
  %218 = and i64 %last_valid.i.i.i, 63
  %219 = shl nsw i64 -2, %218
  %220 = icmp eq i64 %218, 63
  %221 = select i1 %220, i64 0, i64 %219
  %222 = or i64 %217, %221
  store i64 %222, ptr %216, align 4
  %reass.sub.i.i.i = sub nsw i64 %215, %206
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(8).511.exit", label %mask_block_ok.i.i.i

223:                                              ; preds = %mask_block_ok.i.i.i
  %224 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(8).511.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %205, %223
  %.02.i.i.i = phi i64 [ %224, %223 ], [ 0, %205 ]
  %gep.i.i.i = getelementptr i64, ptr %207, i64 %.02.i.i.i
  %225 = load i64, ptr %gep.i.i.i, align 4
  %226 = icmp eq i64 %225, -1
  br i1 %226, label %223, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit907
  %.fca.2.extract82.i187.i = phi i64 [ 0, %__barray_mask_return.exit907 ], [ %.fca.2.extract82.i.i, %loop_body.i ]
  %.fca.1.extract81.i186.i = phi ptr [ %1, %__barray_mask_return.exit907 ], [ %.fca.1.extract81.i.i, %loop_body.i ]
  %.fca.0.extract80.i185.i = phi ptr [ %0, %__barray_mask_return.exit907 ], [ %.fca.0.extract80.i.i, %loop_body.i ]
  %"537_0.sroa.15.0184.i" = phi i64 [ 0, %__barray_mask_return.exit907 ], [ %227, %loop_body.i ]
  %.pn165183.i = phi { { ptr, ptr, i64 }, i64 } [ %202, %__barray_mask_return.exit907 ], [ %242, %loop_body.i ]
  %227 = add nuw nsw i64 %"537_0.sroa.15.0184.i", 1
  %228 = add i64 %"537_0.sroa.15.0184.i", %.fca.2.extract82.i187.i
  %229 = lshr i64 %228, 6
  %230 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i186.i, i64 %229
  %231 = load i64, ptr %230, align 4
  %232 = and i64 %228, 63
  %233 = lshr i64 %231, %232
  %234 = trunc i64 %233 to i1
  br i1 %234, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %235 = shl nuw i64 1, %232
  %236 = xor i64 %235, %231
  store i64 %236, ptr %230, align 4
  %237 = getelementptr inbounds i64, ptr %.fca.0.extract80.i185.i, i64 %228
  %238 = load i64, ptr %237, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %238)
  tail call void @___qfree(i64 %238)
  %239 = load i64, ptr %204, align 4
  %240 = lshr i64 %239, %"537_0.sroa.15.0184.i"
  %241 = trunc i64 %240 to i1
  br i1 %241, label %loop_body.i, label %panic.i.i908

panic.i.i908:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"602_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"602_054.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"602_054.fca.1.insert.i", i1 undef, 2
  %242 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, i64 %227, 1
  %243 = shl nuw nsw i64 1, %"537_0.sroa.15.0184.i"
  %244 = xor i64 %239, %243
  store i64 %244, ptr %204, align 4
  %245 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %203, i64 %"537_0.sroa.15.0184.i"
  store { i1, i64, i1 } %"602_054.fca.2.insert.i", ptr %245, align 4
  %246 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %246, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %246, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %246, 2
  %exitcond.not.i909 = icmp eq i64 %227, 8
  br i1 %exitcond.not.i909, label %205, label %__barray_check_bounds.exit.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(8).511.exit": ; preds = %223, %205
  tail call void @heap_free(ptr %.fca.0.extract80.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract81.i.i)
  %247 = tail call ptr @heap_alloc(i64 256)
  %248 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %248, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(256) %247, i8 0, i64 256, i1 false)
  %249 = load i64, ptr %204, align 4
  %250 = and i64 %249, 255
  store i64 %250, ptr %204, align 4
  %251 = icmp eq i64 %250, 0
  br i1 %251, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit911:                    ; preds = %__barray_mask_return.exit874, %__barray_mask_return.exit926
  %"136_3.0965" = phi i64 [ %252, %__barray_mask_return.exit926 ], [ 0, %__barray_mask_return.exit874 ]
  %252 = add nuw nsw i64 %"136_3.0965", 1
  %253 = sub nuw nsw i64 7, %"136_3.0965"
  %254 = load i64, ptr %1, align 4
  %255 = lshr i64 %254, %"45_0.0966"
  %256 = trunc i64 %255 to i1
  br i1 %256, label %panic.i912, label %cond_189_case_1

panic.i912:                                       ; preds = %__barray_check_bounds.exit911
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

257:                                              ; preds = %__hugr__.guppylang.std.num.int.__pow__.380.exit
  tail call void @panic(i32 1001, ptr nonnull @e_tket.rotat.20D0216B.0)
  unreachable

__barray_check_bounds.exit915:                    ; preds = %__hugr__.guppylang.std.num.int.__pow__.380.exit
  %258 = lshr i64 %2, %253
  %259 = trunc i64 %258 to i1
  br i1 %259, label %panic.i916, label %__barray_check_bounds.exit920

panic.i916:                                       ; preds = %__barray_check_bounds.exit915
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit920:                    ; preds = %__barray_check_bounds.exit915
  %260 = shl nuw nsw i64 1, %253
  %261 = xor i64 %2, %260
  store i64 %261, ptr %1, align 4
  %262 = getelementptr inbounds nuw i64, ptr %0, i64 %253
  %263 = load i64, ptr %262, align 4
  %264 = fmul double %5, 0x400921FB54442D18
  %265 = fmul double %264, 5.000000e-01
  %266 = fneg double %265
  tail call void @___rp(i64 %263, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %3, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rpp(i64 %3, i64 %263, double %266, double 0xC00921FB54442D18)
  tail call void @___rp(i64 %3, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rp(i64 %263, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %263, double %265)
  %267 = load i64, ptr %1, align 4
  %268 = lshr i64 %267, %"45_0.0966"
  %269 = trunc i64 %268 to i1
  br i1 %269, label %__barray_check_bounds.exit924, label %panic.i921

panic.i921:                                       ; preds = %__barray_check_bounds.exit920
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit924:                    ; preds = %__barray_check_bounds.exit920
  %270 = xor i64 %267, %43
  store i64 %270, ptr %1, align 4
  store i64 %3, ptr %45, align 4
  %271 = load i64, ptr %1, align 4
  %272 = lshr i64 %271, %253
  %273 = trunc i64 %272 to i1
  br i1 %273, label %__barray_mask_return.exit926, label %panic.i925

panic.i925:                                       ; preds = %__barray_check_bounds.exit924
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit926:                     ; preds = %__barray_check_bounds.exit924
  %274 = xor i64 %271, %260
  store i64 %274, ptr %1, align 4
  store i64 %263, ptr %262, align 4
  %exitcond.not = icmp eq i64 %252, %smax
  br i1 %exitcond.not, label %cond_exit_174.loopexit, label %__barray_check_bounds.exit911
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

define internal i1 @__hugr__.array.__read_bool.3.339({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_329_case_1, label %cond_329_case_0

cond_329_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_329

cond_329_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_329

cond_exit_329:                                    ; preds = %cond_329_case_1, %cond_329_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_329_case_1 ], [ %.fca.2.extract, %cond_329_case_0 ]
  ret i1 %"03.0"
}

declare void @heap_free(ptr) local_unnamed_addr

define internal { i1, i64, i1 } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract11 = extractvalue { i1, { i1, i64, i1 } } %0, 0
  br i1 %.fca.0.extract11, label %cond_639_case_1, label %cond_639_case_0

cond_639_case_1:                                  ; preds = %alloca_block
  %1 = extractvalue { i1, { i1, i64, i1 } } %0, 1
  ret { i1, i64, i1 } %1

cond_639_case_0:                                  ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.E6312129.0")
  unreachable
}

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @__hugr__.__main__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fabs.f64(double) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smax.i64(i64, i64) #2

attributes #0 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #1 = { noreturn }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!name = !{!0}

!0 = !{!"mainlib"}
