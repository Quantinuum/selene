; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_measuremen.F30240EB.0 = private constant [26 x i8] c"\19USER:BOOLARR:measurements"
@e_tket.rotat.20D0216B.0 = private constant [55 x i8] c"6EXIT:INT:tket.rotation.from_halfturns_unchecked failed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 64)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_642_case_0.i, label %__hugr__.__tk2_helios_qalloc.615.exit

cond_exit_204.loopexit:                           ; preds = %__barray_mask_return.exit898
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %exitcond973.not = icmp eq i64 %39, 8
  br i1 %exitcond973.not, label %cond_exit_120, label %__barray_check_bounds.exit865

cond_219_case_1:                                  ; preds = %__barray_check_bounds.exit884
  %2 = xor i64 %245, %43
  store i64 %2, ptr %1, align 4
  %3 = load i64, ptr %45, align 4
  br label %pow.i

pow.i:                                            ; preds = %cond_219_case_1, %pow_body.i
  %storemerge53.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %cond_219_case_1 ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"45_0.0966", %cond_219_case_1 ]
  switch i64 %storemerge.i, label %pow_body.i [
    i64 1, label %__hugr__.guppylang.std.num.int.__pow__.466.exit.loopexit
    i64 0, label %__hugr__.guppylang.std.num.int.__pow__.466.exit
  ]

pow_body.i:                                       ; preds = %pow.i
  %new_acc.i = shl i64 %storemerge53.i, 1
  %new_exp.i = add i64 %storemerge.i, -1
  br label %pow.i

__hugr__.guppylang.std.num.int.__pow__.466.exit.loopexit: ; preds = %pow.i
  %4 = sitofp i64 %storemerge53.i to double
  br label %__hugr__.guppylang.std.num.int.__pow__.466.exit

__hugr__.guppylang.std.num.int.__pow__.466.exit:  ; preds = %pow.i, %__hugr__.guppylang.std.num.int.__pow__.466.exit.loopexit
  %storemerge55.i = phi double [ %4, %__hugr__.guppylang.std.num.int.__pow__.466.exit.loopexit ], [ 1.000000e+00, %pow.i ]
  %5 = fdiv double 1.000000e+00, %storemerge55.i
  %6 = tail call double @llvm.fabs.f64(double %5)
  %7 = fcmp ueq double %6, 0x7FF0000000000000
  br i1 %7, label %248, label %__barray_check_bounds.exit888

cond_642_case_0.i:                                ; preds = %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.615.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %8 = load i64, ptr %1, align 4
  %9 = trunc i64 %8 to i1
  br i1 %9, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.7, %__hugr__.__tk2_helios_qalloc.615.exit.6, %__hugr__.__tk2_helios_qalloc.615.exit.5, %__hugr__.__tk2_helios_qalloc.615.exit.4, %__hugr__.__tk2_helios_qalloc.615.exit.3, %__hugr__.__tk2_helios_qalloc.615.exit.2, %__hugr__.__tk2_helios_qalloc.615.exit.1, %__hugr__.__tk2_helios_qalloc.615.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.615.exit
  %10 = and i64 %8, -2
  store i64 %10, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_642_case_0.i, label %__hugr__.__tk2_helios_qalloc.615.exit.1

__hugr__.__tk2_helios_qalloc.615.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %11 = load i64, ptr %1, align 4
  %12 = and i64 %11, 2
  %.not975 = icmp eq i64 %12, 0
  br i1 %.not975, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.615.exit.1
  %13 = and i64 %11, -3
  store i64 %13, ptr %1, align 4
  %14 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %14, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_642_case_0.i, label %__hugr__.__tk2_helios_qalloc.615.exit.2

__hugr__.__tk2_helios_qalloc.615.exit.2:          ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %15 = load i64, ptr %1, align 4
  %16 = and i64 %15, 4
  %.not976 = icmp eq i64 %16, 0
  br i1 %.not976, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_helios_qalloc.615.exit.2
  %17 = and i64 %15, -5
  store i64 %17, ptr %1, align 4
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %18, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_642_case_0.i, label %__hugr__.__tk2_helios_qalloc.615.exit.3

__hugr__.__tk2_helios_qalloc.615.exit.3:          ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %19 = load i64, ptr %1, align 4
  %20 = and i64 %19, 8
  %.not977 = icmp eq i64 %20, 0
  br i1 %.not977, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_helios_qalloc.615.exit.3
  %21 = and i64 %19, -9
  store i64 %21, ptr %1, align 4
  %22 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %22, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_642_case_0.i, label %__hugr__.__tk2_helios_qalloc.615.exit.4

__hugr__.__tk2_helios_qalloc.615.exit.4:          ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %23 = load i64, ptr %1, align 4
  %24 = and i64 %23, 16
  %.not978 = icmp eq i64 %24, 0
  br i1 %.not978, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_helios_qalloc.615.exit.4
  %25 = and i64 %23, -17
  store i64 %25, ptr %1, align 4
  %26 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %26, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_642_case_0.i, label %__hugr__.__tk2_helios_qalloc.615.exit.5

__hugr__.__tk2_helios_qalloc.615.exit.5:          ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %27 = load i64, ptr %1, align 4
  %28 = and i64 %27, 32
  %.not979 = icmp eq i64 %28, 0
  br i1 %.not979, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_helios_qalloc.615.exit.5
  %29 = and i64 %27, -33
  store i64 %29, ptr %1, align 4
  %30 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %30, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_642_case_0.i, label %__hugr__.__tk2_helios_qalloc.615.exit.6

__hugr__.__tk2_helios_qalloc.615.exit.6:          ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %31 = load i64, ptr %1, align 4
  %32 = and i64 %31, 64
  %.not980 = icmp eq i64 %32, 0
  br i1 %.not980, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_helios_qalloc.615.exit.6
  %33 = and i64 %31, -65
  store i64 %33, ptr %1, align 4
  %34 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %34, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_642_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %35 = load i64, ptr %1, align 4
  %36 = and i64 %35, 128
  %.not981 = icmp eq i64 %36, 0
  br i1 %.not981, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %37 = and i64 %35, -129
  store i64 %37, ptr %1, align 4
  %38 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %38, align 4
  br label %__barray_check_bounds.exit865

__barray_check_bounds.exit865:                    ; preds = %cond_exit_204.loopexit, %cond_exit_20.7
  %indvars.iv = phi i64 [ 7, %cond_exit_20.7 ], [ %indvars.iv.next, %cond_exit_204.loopexit ]
  %"45_0.0966" = phi i64 [ 0, %cond_exit_20.7 ], [ %39, %cond_exit_204.loopexit ]
  %smax = tail call i64 @llvm.smax.i64(i64 %indvars.iv, i64 1)
  %39 = add nuw nsw i64 %"45_0.0966", 1
  %40 = load i64, ptr %1, align 4
  %41 = lshr i64 %40, %"45_0.0966"
  %42 = trunc i64 %41 to i1
  br i1 %42, label %panic.i866, label %__barray_check_bounds.exit868

panic.i866:                                       ; preds = %__barray_check_bounds.exit865
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit868:                    ; preds = %__barray_check_bounds.exit865
  %43 = shl nuw nsw i64 1, %"45_0.0966"
  %44 = xor i64 %40, %43
  store i64 %44, ptr %1, align 4
  %45 = getelementptr inbounds nuw i64, ptr %0, i64 %"45_0.0966"
  %46 = load i64, ptr %45, align 4
  tail call void @___rxy(i64 %46, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %46, double 0x400921FB54442D18)
  %47 = load i64, ptr %1, align 4
  %48 = lshr i64 %47, %"45_0.0966"
  %49 = trunc i64 %48 to i1
  br i1 %49, label %__barray_mask_return.exit870, label %panic.i869

panic.i869:                                       ; preds = %__barray_check_bounds.exit868
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit870:                     ; preds = %__barray_check_bounds.exit868
  %50 = xor i64 %47, %43
  store i64 %50, ptr %1, align 4
  store i64 %46, ptr %45, align 4
  %.not970 = icmp eq i64 %"45_0.0966", 7
  br i1 %.not970, label %cond_exit_120, label %__barray_check_bounds.exit884

loop_body.preheader.i:                            ; preds = %loop_body128
  %"662_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %180, 2
  %"662_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %180, 1
  %"662_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %180, 0
  %51 = lshr i64 %"662_1.sroa.10.0.i", 6
  %52 = getelementptr i64, ptr %"662_1.sroa.5.0.i", i64 %51
  %53 = load i64, ptr %52, align 4
  %54 = and i64 %"662_1.sroa.10.0.i", 63
  %55 = lshr i64 %53, %54
  %56 = trunc i64 %55 to i1
  br i1 %56, label %cond_exit_665.thread.i, label %__barray_mask_borrow.exit228.i

__barray_check_bounds.exit.i:                     ; preds = %loop_body128, %"__hugr__.guppylang.std.quantum.measure_array$8.337.exit"
  %57 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$8.337.exit" ], [ %180, %loop_body128 ]
  %"86_0.sroa.15.0969" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$8.337.exit" ], [ %58, %loop_body128 ]
  %.pn944968 = phi { { ptr, ptr, i64 }, i64 } [ %242, %"__hugr__.guppylang.std.quantum.measure_array$8.337.exit" ], [ %176, %loop_body128 ]
  %58 = add nuw nsw i64 %"86_0.sroa.15.0969", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %57, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %57, 1
  %59 = add i64 %.fca.2.extract208.i, %"86_0.sroa.15.0969"
  %60 = lshr i64 %59, 6
  %61 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %60
  %62 = load i64, ptr %61, align 4
  %63 = and i64 %59, 63
  %64 = lshr i64 %62, %63
  %65 = trunc i64 %64 to i1
  br i1 %65, label %panic.i.i, label %__barray_check_bounds.exit221.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %57, 0
  %66 = shl nuw i64 1, %63
  %67 = xor i64 %62, %66
  store i64 %67, ptr %61, align 4
  %68 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %59
  %69 = load i64, ptr %68, align 4
  tail call void @___inc_future_refcount(i64 %69)
  %70 = load i64, ptr %61, align 4
  %71 = lshr i64 %70, %63
  %72 = trunc i64 %71 to i1
  br i1 %72, label %__barray_check_bounds.exit872, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

73:                                               ; preds = %mask_block_ok.i.i
  %74 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&8.378.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_exit_665.thread.7.i, %73
  %.02.i.i = phi i64 [ %74, %73 ], [ 0, %cond_exit_665.thread.7.i ]
  %gep.i.i = getelementptr i64, ptr %52, i64 %.02.i.i
  %75 = load i64, ptr %gep.i.i, align 4
  %76 = icmp eq i64 %75, -1
  br i1 %76, label %73, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i:                   ; preds = %loop_body.preheader.i
  %77 = shl nuw i64 1, %54
  %78 = xor i64 %53, %77
  store i64 %78, ptr %52, align 4
  %79 = getelementptr inbounds i64, ptr %"662_1.sroa.0.0.i", i64 %"662_1.sroa.10.0.i"
  %80 = load i64, ptr %79, align 4
  tail call void @___dec_future_refcount(i64 %80)
  br label %cond_exit_665.thread.i

cond_exit_665.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %loop_body.preheader.i
  %81 = add i64 %"662_1.sroa.10.0.i", 1
  %82 = lshr i64 %81, 6
  %83 = getelementptr inbounds nuw i64, ptr %"662_1.sroa.5.0.i", i64 %82
  %84 = load i64, ptr %83, align 4
  %85 = and i64 %81, 63
  %86 = lshr i64 %84, %85
  %87 = trunc i64 %86 to i1
  br i1 %87, label %cond_exit_665.thread.1.i, label %__barray_mask_borrow.exit228.1.i

__barray_mask_borrow.exit228.1.i:                 ; preds = %cond_exit_665.thread.i
  %88 = shl nuw i64 1, %85
  %89 = xor i64 %84, %88
  store i64 %89, ptr %83, align 4
  %90 = getelementptr inbounds i64, ptr %"662_1.sroa.0.0.i", i64 %81
  %91 = load i64, ptr %90, align 4
  tail call void @___dec_future_refcount(i64 %91)
  br label %cond_exit_665.thread.1.i

cond_exit_665.thread.1.i:                         ; preds = %__barray_mask_borrow.exit228.1.i, %cond_exit_665.thread.i
  %92 = add i64 %"662_1.sroa.10.0.i", 2
  %93 = lshr i64 %92, 6
  %94 = getelementptr inbounds nuw i64, ptr %"662_1.sroa.5.0.i", i64 %93
  %95 = load i64, ptr %94, align 4
  %96 = and i64 %92, 63
  %97 = lshr i64 %95, %96
  %98 = trunc i64 %97 to i1
  br i1 %98, label %cond_exit_665.thread.2.i, label %__barray_mask_borrow.exit228.2.i

__barray_mask_borrow.exit228.2.i:                 ; preds = %cond_exit_665.thread.1.i
  %99 = shl nuw i64 1, %96
  %100 = xor i64 %95, %99
  store i64 %100, ptr %94, align 4
  %101 = getelementptr inbounds i64, ptr %"662_1.sroa.0.0.i", i64 %92
  %102 = load i64, ptr %101, align 4
  tail call void @___dec_future_refcount(i64 %102)
  br label %cond_exit_665.thread.2.i

cond_exit_665.thread.2.i:                         ; preds = %__barray_mask_borrow.exit228.2.i, %cond_exit_665.thread.1.i
  %103 = add i64 %"662_1.sroa.10.0.i", 3
  %104 = lshr i64 %103, 6
  %105 = getelementptr inbounds nuw i64, ptr %"662_1.sroa.5.0.i", i64 %104
  %106 = load i64, ptr %105, align 4
  %107 = and i64 %103, 63
  %108 = lshr i64 %106, %107
  %109 = trunc i64 %108 to i1
  br i1 %109, label %cond_exit_665.thread.3.i, label %__barray_mask_borrow.exit228.3.i

__barray_mask_borrow.exit228.3.i:                 ; preds = %cond_exit_665.thread.2.i
  %110 = shl nuw i64 1, %107
  %111 = xor i64 %106, %110
  store i64 %111, ptr %105, align 4
  %112 = getelementptr inbounds i64, ptr %"662_1.sroa.0.0.i", i64 %103
  %113 = load i64, ptr %112, align 4
  tail call void @___dec_future_refcount(i64 %113)
  br label %cond_exit_665.thread.3.i

cond_exit_665.thread.3.i:                         ; preds = %__barray_mask_borrow.exit228.3.i, %cond_exit_665.thread.2.i
  %114 = add i64 %"662_1.sroa.10.0.i", 4
  %115 = lshr i64 %114, 6
  %116 = getelementptr inbounds nuw i64, ptr %"662_1.sroa.5.0.i", i64 %115
  %117 = load i64, ptr %116, align 4
  %118 = and i64 %114, 63
  %119 = lshr i64 %117, %118
  %120 = trunc i64 %119 to i1
  br i1 %120, label %cond_exit_665.thread.4.i, label %__barray_mask_borrow.exit228.4.i

__barray_mask_borrow.exit228.4.i:                 ; preds = %cond_exit_665.thread.3.i
  %121 = shl nuw i64 1, %118
  %122 = xor i64 %117, %121
  store i64 %122, ptr %116, align 4
  %123 = getelementptr inbounds i64, ptr %"662_1.sroa.0.0.i", i64 %114
  %124 = load i64, ptr %123, align 4
  tail call void @___dec_future_refcount(i64 %124)
  br label %cond_exit_665.thread.4.i

cond_exit_665.thread.4.i:                         ; preds = %__barray_mask_borrow.exit228.4.i, %cond_exit_665.thread.3.i
  %125 = add i64 %"662_1.sroa.10.0.i", 5
  %126 = lshr i64 %125, 6
  %127 = getelementptr inbounds nuw i64, ptr %"662_1.sroa.5.0.i", i64 %126
  %128 = load i64, ptr %127, align 4
  %129 = and i64 %125, 63
  %130 = lshr i64 %128, %129
  %131 = trunc i64 %130 to i1
  br i1 %131, label %cond_exit_665.thread.5.i, label %__barray_mask_borrow.exit228.5.i

__barray_mask_borrow.exit228.5.i:                 ; preds = %cond_exit_665.thread.4.i
  %132 = shl nuw i64 1, %129
  %133 = xor i64 %128, %132
  store i64 %133, ptr %127, align 4
  %134 = getelementptr inbounds i64, ptr %"662_1.sroa.0.0.i", i64 %125
  %135 = load i64, ptr %134, align 4
  tail call void @___dec_future_refcount(i64 %135)
  br label %cond_exit_665.thread.5.i

cond_exit_665.thread.5.i:                         ; preds = %__barray_mask_borrow.exit228.5.i, %cond_exit_665.thread.4.i
  %136 = add i64 %"662_1.sroa.10.0.i", 6
  %137 = lshr i64 %136, 6
  %138 = getelementptr inbounds nuw i64, ptr %"662_1.sroa.5.0.i", i64 %137
  %139 = load i64, ptr %138, align 4
  %140 = and i64 %136, 63
  %141 = lshr i64 %139, %140
  %142 = trunc i64 %141 to i1
  br i1 %142, label %cond_exit_665.thread.6.i, label %__barray_mask_borrow.exit228.6.i

__barray_mask_borrow.exit228.6.i:                 ; preds = %cond_exit_665.thread.5.i
  %143 = shl nuw i64 1, %140
  %144 = xor i64 %139, %143
  store i64 %144, ptr %138, align 4
  %145 = getelementptr inbounds i64, ptr %"662_1.sroa.0.0.i", i64 %136
  %146 = load i64, ptr %145, align 4
  tail call void @___dec_future_refcount(i64 %146)
  br label %cond_exit_665.thread.6.i

cond_exit_665.thread.6.i:                         ; preds = %__barray_mask_borrow.exit228.6.i, %cond_exit_665.thread.5.i
  %147 = add i64 %"662_1.sroa.10.0.i", 7
  %148 = lshr i64 %147, 6
  %149 = getelementptr inbounds nuw i64, ptr %"662_1.sroa.5.0.i", i64 %148
  %150 = load i64, ptr %149, align 4
  %151 = and i64 %147, 63
  %152 = lshr i64 %150, %151
  %153 = trunc i64 %152 to i1
  br i1 %153, label %cond_exit_665.thread.7.i, label %__barray_mask_borrow.exit228.7.i

__barray_mask_borrow.exit228.7.i:                 ; preds = %cond_exit_665.thread.6.i
  %154 = shl nuw i64 1, %151
  %155 = xor i64 %150, %154
  store i64 %155, ptr %149, align 4
  %156 = getelementptr inbounds i64, ptr %"662_1.sroa.0.0.i", i64 %147
  %157 = load i64, ptr %156, align 4
  tail call void @___dec_future_refcount(i64 %157)
  br label %cond_exit_665.thread.7.i

cond_exit_665.thread.7.i:                         ; preds = %__barray_mask_borrow.exit228.7.i, %cond_exit_665.thread.6.i
  %158 = load i64, ptr %52, align 4
  %159 = sub nuw nsw i64 64, %54
  %160 = lshr i64 -1, %159
  %161 = icmp eq i64 %54, 0
  %162 = select i1 %161, i64 0, i64 %160
  %163 = or i64 %158, %162
  store i64 %163, ptr %52, align 4
  %164 = load i64, ptr %149, align 4
  %165 = shl nsw i64 -2, %151
  %166 = icmp eq i64 %151, 63
  %167 = select i1 %166, i64 0, i64 %165
  %168 = or i64 %164, %167
  store i64 %168, ptr %149, align 4
  %reass.sub.i.i = sub nsw i64 %148, %51
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&8.378.exit", label %mask_block_ok.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&8.378.exit": ; preds = %73, %cond_exit_665.thread.7.i
  tail call void @heap_free(ptr %"662_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"662_1.sroa.5.0.i")
  %169 = load i64, ptr %189, align 4
  %170 = and i64 %169, 255
  store i64 %170, ptr %189, align 4
  %171 = icmp eq i64 %170, 0
  br i1 %171, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit872:                    ; preds = %__barray_check_bounds.exit221.i
  %172 = xor i64 %70, %66
  store i64 %172, ptr %61, align 4
  store i64 %69, ptr %68, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %69)
  tail call void @___dec_future_refcount(i64 %69)
  %173 = load i64, ptr %189, align 4
  %174 = lshr i64 %173, %"86_0.sroa.15.0969"
  %175 = trunc i64 %174 to i1
  br i1 %175, label %loop_body128, label %panic.i873

panic.i873:                                       ; preds = %__barray_check_bounds.exit872
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body128:                                     ; preds = %__barray_check_bounds.exit872
  %176 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn944968, i64 %58, 1
  %177 = shl nuw nsw i64 1, %"86_0.sroa.15.0969"
  %178 = xor i64 %173, %177
  store i64 %178, ptr %189, align 4
  %179 = getelementptr inbounds nuw i1, ptr %188, i64 %"86_0.sroa.15.0969"
  store i1 %read_bool, ptr %179, align 1
  %180 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn944968, 0
  %exitcond974.not = icmp eq i64 %58, 8
  br i1 %exitcond974.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&8.378.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&8.378.exit"
  %181 = tail call ptr @heap_alloc(i64 8)
  %182 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %182, align 1
  %183 = load i64, ptr %188, align 1
  store i64 %183, ptr %181, align 1
  tail call void @heap_free(ptr nonnull %181)
  %184 = load i64, ptr %189, align 4
  %185 = and i64 %184, 255
  store i64 %185, ptr %189, align 4
  %186 = icmp eq i64 %185, 0
  br i1 %186, label %__barray_check_none_borrowed.exit876, label %mask_block_err.i875

mask_block_err.i875:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit876:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %187 = alloca [8 x i1], align 8
  store i64 0, ptr %187, align 8
  store i32 8, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %188, ptr %arr_ptr, align 8
  store ptr %187, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_measuremen.F30240EB.0, i64 25, ptr nonnull %out_arr_alloca)
  ret void

cond_exit_120:                                    ; preds = %__barray_mask_return.exit870, %cond_exit_204.loopexit
  %"45_368.fca.0.insert.le" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"45_368.fca.1.insert.le" = insertvalue { ptr, ptr, i64 } %"45_368.fca.0.insert.le", ptr %1, 1
  %"45_368.fca.2.insert.le" = insertvalue { ptr, ptr, i64 } %"45_368.fca.1.insert.le", i64 0, 2
  %188 = tail call ptr @heap_alloc(i64 8)
  %189 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %189, align 1
  %190 = load i64, ptr %1, align 4
  %191 = and i64 %190, 128
  %.not = icmp eq i64 %191, 0
  br i1 %.not, label %__barray_mask_borrow.exit878, label %panic.i877

panic.i877:                                       ; preds = %cond_exit_120
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit878:                     ; preds = %cond_exit_120
  %192 = or disjoint i64 %190, 128
  store i64 %192, ptr %1, align 4
  %193 = load i64, ptr %38, align 4
  tail call void @___rxy(i64 %193, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %193, double 0x400921FB54442D18)
  %194 = load i64, ptr %1, align 4
  %195 = and i64 %194, 128
  %.not943 = icmp eq i64 %195, 0
  br i1 %.not943, label %panic.i879, label %__barray_mask_return.exit880

panic.i879:                                       ; preds = %__barray_mask_borrow.exit878
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit880:                     ; preds = %__barray_mask_borrow.exit878
  %196 = and i64 %194, -129
  store i64 %196, ptr %1, align 4
  store i64 %193, ptr %38, align 4
  %197 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"45_368.fca.2.insert.le", 0
  %198 = tail call ptr @heap_alloc(i64 64)
  %199 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %199, align 1
  br label %__barray_check_bounds.exit.i.i

200:                                              ; preds = %loop_body.i
  %201 = lshr i64 %.fca.2.extract.i.i, 6
  %202 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %201
  %203 = load i64, ptr %202, align 4
  %204 = and i64 %.fca.2.extract.i.i, 63
  %205 = sub nuw nsw i64 64, %204
  %206 = lshr i64 -1, %205
  %207 = icmp eq i64 %204, 0
  %208 = select i1 %207, i64 0, i64 %206
  %209 = or i64 %203, %208
  store i64 %209, ptr %202, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 7
  %210 = lshr i64 %last_valid.i.i.i, 6
  %211 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %210
  %212 = load i64, ptr %211, align 4
  %213 = and i64 %last_valid.i.i.i, 63
  %214 = shl nsw i64 -2, %213
  %215 = icmp eq i64 %213, 63
  %216 = select i1 %215, i64 0, i64 %214
  %217 = or i64 %212, %216
  store i64 %217, ptr %211, align 4
  %reass.sub.i.i.i = sub nsw i64 %210, %201
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$8.337.exit", label %mask_block_ok.i.i.i

218:                                              ; preds = %mask_block_ok.i.i.i
  %219 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$8.337.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %200, %218
  %.02.i.i.i = phi i64 [ %219, %218 ], [ 0, %200 ]
  %gep.i.i.i = getelementptr i64, ptr %202, i64 %.02.i.i.i
  %220 = load i64, ptr %gep.i.i.i, align 4
  %221 = icmp eq i64 %220, -1
  br i1 %221, label %218, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit880
  %.fca.2.extract.i181.i = phi i64 [ 0, %__barray_mask_return.exit880 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %__barray_mask_return.exit880 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %__barray_mask_return.exit880 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"351_0.sroa.15.0178.i" = phi i64 [ 0, %__barray_mask_return.exit880 ], [ %222, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %197, %__barray_mask_return.exit880 ], [ %237, %loop_body.i ]
  %222 = add nuw nsw i64 %"351_0.sroa.15.0178.i", 1
  %223 = add i64 %"351_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %224 = lshr i64 %223, 6
  %225 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %224
  %226 = load i64, ptr %225, align 4
  %227 = and i64 %223, 63
  %228 = lshr i64 %226, %227
  %229 = trunc i64 %228 to i1
  br i1 %229, label %panic.i.i.i, label %__barray_check_bounds.exit.i881

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i881:                  ; preds = %__barray_check_bounds.exit.i.i
  %230 = shl nuw i64 1, %227
  %231 = xor i64 %230, %226
  store i64 %231, ptr %225, align 4
  %232 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %223
  %233 = load i64, ptr %232, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %233)
  tail call void @___qfree(i64 %233)
  %234 = load i64, ptr %199, align 4
  %235 = lshr i64 %234, %"351_0.sroa.15.0178.i"
  %236 = trunc i64 %235 to i1
  br i1 %236, label %loop_body.i, label %panic.i.i882

panic.i.i882:                                     ; preds = %__barray_check_bounds.exit.i881
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i881
  %237 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %222, 1
  %238 = shl nuw nsw i64 1, %"351_0.sroa.15.0178.i"
  %239 = xor i64 %234, %238
  store i64 %239, ptr %199, align 4
  %240 = getelementptr inbounds nuw i64, ptr %198, i64 %"351_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %240, align 4
  %241 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %241, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %241, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %241, 2
  %exitcond.not.i = icmp eq i64 %222, 8
  br i1 %exitcond.not.i, label %200, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$8.337.exit": ; preds = %218, %200
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %198, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %199, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %242 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  br label %__barray_check_bounds.exit.i

__barray_check_bounds.exit884:                    ; preds = %__barray_mask_return.exit870, %__barray_mask_return.exit898
  %"167_3.0965" = phi i64 [ %243, %__barray_mask_return.exit898 ], [ 0, %__barray_mask_return.exit870 ]
  %243 = add nuw nsw i64 %"167_3.0965", 1
  %244 = sub nuw nsw i64 7, %"167_3.0965"
  %245 = load i64, ptr %1, align 4
  %246 = lshr i64 %245, %"45_0.0966"
  %247 = trunc i64 %246 to i1
  br i1 %247, label %panic.i885, label %cond_219_case_1

panic.i885:                                       ; preds = %__barray_check_bounds.exit884
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

248:                                              ; preds = %__hugr__.guppylang.std.num.int.__pow__.466.exit
  tail call void @panic(i32 1001, ptr nonnull @e_tket.rotat.20D0216B.0)
  unreachable

__barray_check_bounds.exit888:                    ; preds = %__hugr__.guppylang.std.num.int.__pow__.466.exit
  %249 = lshr i64 %2, %244
  %250 = trunc i64 %249 to i1
  br i1 %250, label %panic.i889, label %__barray_check_bounds.exit892

panic.i889:                                       ; preds = %__barray_check_bounds.exit888
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit892:                    ; preds = %__barray_check_bounds.exit888
  %251 = shl nuw nsw i64 1, %244
  %252 = xor i64 %2, %251
  store i64 %252, ptr %1, align 4
  %253 = getelementptr inbounds nuw i64, ptr %0, i64 %244
  %254 = load i64, ptr %253, align 4
  %255 = fmul double %5, 0x400921FB54442D18
  %256 = fmul double %255, 5.000000e-01
  %257 = fneg double %256
  tail call void @___rzz(i64 %3, i64 %254, double %257)
  tail call void @___rz(i64 %254, double %256)
  %258 = load i64, ptr %1, align 4
  %259 = lshr i64 %258, %"45_0.0966"
  %260 = trunc i64 %259 to i1
  br i1 %260, label %__barray_check_bounds.exit896, label %panic.i893

panic.i893:                                       ; preds = %__barray_check_bounds.exit892
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit896:                    ; preds = %__barray_check_bounds.exit892
  %261 = xor i64 %258, %43
  store i64 %261, ptr %1, align 4
  store i64 %3, ptr %45, align 4
  %262 = load i64, ptr %1, align 4
  %263 = lshr i64 %262, %244
  %264 = trunc i64 %263 to i1
  br i1 %264, label %__barray_mask_return.exit898, label %panic.i897

panic.i897:                                       ; preds = %__barray_check_bounds.exit896
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit898:                     ; preds = %__barray_check_bounds.exit896
  %265 = xor i64 %262, %251
  store i64 %265, ptr %1, align 4
  store i64 %254, ptr %253, align 4
  %exitcond.not = icmp eq i64 %243, %smax
  br i1 %exitcond.not, label %cond_exit_204.loopexit, label %__barray_check_bounds.exit884
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call void @__hugr__.__main__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fabs.f64(double) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smax.i64(i64, i64) #1

attributes #0 = { noreturn }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!name = !{!0}

!0 = !{!"mainlib"}
