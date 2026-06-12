; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 560)
  %1 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %1, i8 -1, i64 16, i1 false)
  br label %cond_20_case_1

2:                                                ; preds = %finish, %__barray_mask_return.exit552
  %exitcond568.not = icmp eq i64 %139, 70
  br i1 %exitcond568.not, label %cond_exit_82, label %finish

cond_20_case_1:                                   ; preds = %alloca_block, %cond_exit_20
  %"15_0.sroa.0.0566" = phi i64 [ 0, %alloca_block ], [ %3, %cond_exit_20 ]
  %3 = add nuw nsw i64 %"15_0.sroa.0.0566", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_502_case_0.i, label %__barray_check_bounds.exit

cond_502_case_0.i:                                ; preds = %cond_20_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_20_case_1
  tail call void @___reset(i64 %qalloc.i)
  %4 = lshr i64 %"15_0.sroa.0.0566", 6
  %5 = getelementptr inbounds nuw i64, ptr %1, i64 %4
  %6 = load i64, ptr %5, align 4
  %7 = and i64 %"15_0.sroa.0.0566", 63
  %8 = lshr i64 %6, %7
  %9 = trunc i64 %8 to i1
  br i1 %9, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__barray_check_bounds.exit
  %10 = shl nuw i64 1, %7
  %11 = xor i64 %6, %10
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i64, ptr %0, i64 %"15_0.sroa.0.0566"
  store i64 %qalloc.i, ptr %12, align 4
  %exitcond.not = icmp eq i64 %3, 70
  br i1 %exitcond.not, label %loop_out, label %cond_20_case_1

loop_out:                                         ; preds = %cond_exit_20
  %"117.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"117.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"117.fca.0.insert", ptr %1, 1
  %"117.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"117.fca.1.insert", i64 0, 2
  br label %finish

cond_exit_82:                                     ; preds = %2
  %13 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"117.fca.2.insert", 0
  %14 = tail call ptr @heap_alloc(i64 560)
  %15 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %15, i8 -1, i64 16, i1 false)
  br label %__barray_check_bounds.exit.i.i

16:                                               ; preds = %loop_body.i
  %17 = lshr i64 %.fca.2.extract.i.i, 6
  %18 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %17
  %19 = load i64, ptr %18, align 4
  %20 = and i64 %.fca.2.extract.i.i, 63
  %21 = sub nuw nsw i64 64, %20
  %22 = lshr i64 -1, %21
  %23 = icmp eq i64 %20, 0
  %24 = select i1 %23, i64 0, i64 %22
  %25 = or i64 %19, %24
  store i64 %25, ptr %18, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 69
  %26 = lshr i64 %last_valid.i.i.i, 6
  %27 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %26
  %28 = load i64, ptr %27, align 4
  %29 = and i64 %last_valid.i.i.i, 63
  %30 = shl nsw i64 -2, %29
  %31 = icmp eq i64 %29, 63
  %32 = select i1 %31, i64 0, i64 %30
  %33 = or i64 %28, %32
  store i64 %33, ptr %27, align 4
  %reass.sub.i.i.i = sub nsw i64 %26, %17
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$70.246.exit", label %mask_block_ok.i.i.i

34:                                               ; preds = %mask_block_ok.i.i.i
  %35 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$70.246.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %16, %34
  %.02.i.i.i = phi i64 [ %35, %34 ], [ 0, %16 ]
  %gep.i.i.i = getelementptr i64, ptr %18, i64 %.02.i.i.i
  %36 = load i64, ptr %gep.i.i.i, align 4
  %37 = icmp eq i64 %36, -1
  br i1 %37, label %34, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_82
  %.fca.2.extract.i182.i = phi i64 [ 0, %cond_exit_82 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i181.i = phi ptr [ %1, %cond_exit_82 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i180.i = phi ptr [ %0, %cond_exit_82 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"260_0.sroa.15.0179.i" = phi i64 [ 0, %cond_exit_82 ], [ %38, %loop_body.i ]
  %.pn160178.i = phi { { ptr, ptr, i64 }, i64 } [ %13, %cond_exit_82 ], [ %56, %loop_body.i ]
  %38 = add nuw nsw i64 %"260_0.sroa.15.0179.i", 1
  %39 = add i64 %"260_0.sroa.15.0179.i", %.fca.2.extract.i182.i
  %40 = lshr i64 %39, 6
  %41 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i181.i, i64 %40
  %42 = load i64, ptr %41, align 4
  %43 = and i64 %39, 63
  %44 = lshr i64 %42, %43
  %45 = trunc i64 %44 to i1
  br i1 %45, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %46 = shl nuw i64 1, %43
  %47 = xor i64 %46, %42
  store i64 %47, ptr %41, align 4
  %48 = getelementptr inbounds i64, ptr %.fca.0.extract62.i180.i, i64 %39
  %49 = load i64, ptr %48, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %49)
  tail call void @___qfree(i64 %49)
  %50 = lshr i64 %"260_0.sroa.15.0179.i", 6
  %51 = getelementptr inbounds nuw i64, ptr %15, i64 %50
  %52 = load i64, ptr %51, align 4
  %53 = and i64 %"260_0.sroa.15.0179.i", 63
  %54 = lshr i64 %52, %53
  %55 = trunc i64 %54 to i1
  br i1 %55, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %56 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn160178.i, i64 %38, 1
  %57 = shl nuw i64 1, %53
  %58 = xor i64 %52, %57
  store i64 %58, ptr %51, align 4
  %59 = getelementptr inbounds nuw i64, ptr %14, i64 %"260_0.sroa.15.0179.i"
  store i64 %lazy_measure.i, ptr %59, align 4
  %60 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn160178.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %60, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %60, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %60, 2
  %exitcond.not.i = icmp eq i64 %38, 70
  br i1 %exitcond.not.i, label %16, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$70.246.exit": ; preds = %34, %16
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"124.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %14, 0
  %"124.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"124.fca.0.insert.i", ptr %15, 1
  %"124.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"124.fca.1.insert.i", i64 0, 2
  %61 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"124.fca.2.insert.i", 0
  %62 = tail call ptr @heap_alloc(i64 70)
  %63 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %63, i8 -1, i64 16, i1 false)
  br label %__barray_check_bounds.exit.i.i526

loop_body.preheader.i.i:                          ; preds = %loop_body.i529
  %"522_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %124, 2
  %"522_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %124, 1
  %"522_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %124, 0
  br label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i.i526:                ; preds = %loop_body.i529, %"__hugr__.guppylang.std.quantum.measure_array$70.246.exit"
  %64 = phi { ptr, ptr, i64 } [ %"124.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$70.246.exit" ], [ %124, %loop_body.i529 ]
  %"301_0.sroa.15.0169.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$70.246.exit" ], [ %65, %loop_body.i529 ]
  %.pn160168.i = phi { { ptr, ptr, i64 }, i64 } [ %61, %"__hugr__.guppylang.std.quantum.measure_array$70.246.exit" ], [ %120, %loop_body.i529 ]
  %65 = add nuw nsw i64 %"301_0.sroa.15.0169.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %64, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %64, 1
  %66 = add i64 %.fca.2.extract208.i.i, %"301_0.sroa.15.0169.i"
  %67 = lshr i64 %66, 6
  %68 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %67
  %69 = load i64, ptr %68, align 4
  %70 = and i64 %66, 63
  %71 = lshr i64 %69, %70
  %72 = trunc i64 %71 to i1
  br i1 %72, label %panic.i.i.i542, label %__barray_check_bounds.exit221.i.i

panic.i.i.i542:                                   ; preds = %__barray_check_bounds.exit.i.i526
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i526
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %64, 0
  %73 = shl nuw i64 1, %70
  %74 = xor i64 %73, %69
  store i64 %74, ptr %68, align 4
  %75 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %66
  %76 = load i64, ptr %75, align 4
  tail call void @___inc_future_refcount(i64 %76)
  %77 = load i64, ptr %68, align 4
  %78 = lshr i64 %77, %70
  %79 = trunc i64 %78 to i1
  br i1 %79, label %__barray_check_bounds.exit.i527, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_525_case_0.i.i:                              ; preds = %cond_exit_525.thread.i.i
  %80 = lshr i64 %"522_1.sroa.10.0.i.i", 6
  %81 = getelementptr i64, ptr %"522_1.sroa.5.0.i.i", i64 %80
  %82 = load i64, ptr %81, align 4
  %83 = and i64 %"522_1.sroa.10.0.i.i", 63
  %84 = sub nuw nsw i64 64, %83
  %85 = lshr i64 -1, %84
  %86 = icmp eq i64 %83, 0
  %87 = select i1 %86, i64 0, i64 %85
  %88 = or i64 %82, %87
  store i64 %88, ptr %81, align 4
  %last_valid.i.i.i531 = add i64 %"522_1.sroa.10.0.i.i", 69
  %89 = lshr i64 %last_valid.i.i.i531, 6
  %90 = getelementptr inbounds nuw i64, ptr %"522_1.sroa.5.0.i.i", i64 %89
  %91 = load i64, ptr %90, align 4
  %92 = and i64 %last_valid.i.i.i531, 63
  %93 = shl nsw i64 -2, %92
  %94 = icmp eq i64 %92, 63
  %95 = select i1 %94, i64 0, i64 %93
  %96 = or i64 %91, %95
  store i64 %96, ptr %90, align 4
  %reass.sub.i.i.i532 = sub nsw i64 %89, %80
  %.not.i.i.i533 = icmp eq i64 %reass.sub.i.i.i532, -1
  br i1 %.not.i.i.i533, label %"__hugr__.guppylang.std.quantum.collect_measurements$70.287.exit", label %mask_block_ok.i.i.i534

97:                                               ; preds = %mask_block_ok.i.i.i534
  %98 = add nuw i64 %.02.i.i.i535, 1
  %exitcond.not.i.i.i538 = icmp eq i64 %.02.i.i.i535, %reass.sub.i.i.i532
  br i1 %exitcond.not.i.i.i538, label %"__hugr__.guppylang.std.quantum.collect_measurements$70.287.exit", label %mask_block_ok.i.i.i534

mask_block_ok.i.i.i534:                           ; preds = %cond_525_case_0.i.i, %97
  %.02.i.i.i535 = phi i64 [ %98, %97 ], [ 0, %cond_525_case_0.i.i ]
  %gep.i.i.i536 = getelementptr i64, ptr %81, i64 %.02.i.i.i535
  %99 = load i64, ptr %gep.i.i.i536, align 4
  %100 = icmp eq i64 %99, -1
  br i1 %100, label %97, label %mask_block_err.i.i.i537

mask_block_err.i.i.i537:                          ; preds = %mask_block_ok.i.i.i534
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i.i:                ; preds = %cond_exit_525.thread.i.i, %loop_body.preheader.i.i
  %"522_0.0239.i.i" = phi i64 [ 0, %loop_body.preheader.i.i ], [ %101, %cond_exit_525.thread.i.i ]
  %101 = add nuw nsw i64 %"522_0.0239.i.i", 1
  %102 = add i64 %"522_0.0239.i.i", %"522_1.sroa.10.0.i.i"
  %103 = lshr i64 %102, 6
  %104 = getelementptr inbounds nuw i64, ptr %"522_1.sroa.5.0.i.i", i64 %103
  %105 = load i64, ptr %104, align 4
  %106 = and i64 %102, 63
  %107 = lshr i64 %105, %106
  %108 = trunc i64 %107 to i1
  br i1 %108, label %cond_exit_525.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_mask_borrow.exit228.i.i:                 ; preds = %__barray_check_bounds.exit224.i.i
  %109 = shl nuw i64 1, %106
  %110 = xor i64 %109, %105
  store i64 %110, ptr %104, align 4
  %111 = getelementptr inbounds i64, ptr %"522_1.sroa.0.0.i.i", i64 %102
  %112 = load i64, ptr %111, align 4
  tail call void @___dec_future_refcount(i64 %112)
  br label %cond_exit_525.thread.i.i

cond_exit_525.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %__barray_check_bounds.exit224.i.i
  %exitcond.i.i = icmp eq i64 %101, 70
  br i1 %exitcond.i.i, label %cond_525_case_0.i.i, label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i527:                  ; preds = %__barray_check_bounds.exit221.i.i
  %113 = xor i64 %77, %73
  store i64 %113, ptr %68, align 4
  store i64 %76, ptr %75, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %76)
  tail call void @___dec_future_refcount(i64 %76)
  %114 = lshr i64 %"301_0.sroa.15.0169.i", 6
  %115 = getelementptr inbounds nuw i64, ptr %63, i64 %114
  %116 = load i64, ptr %115, align 4
  %117 = and i64 %"301_0.sroa.15.0169.i", 63
  %118 = lshr i64 %116, %117
  %119 = trunc i64 %118 to i1
  br i1 %119, label %loop_body.i529, label %panic.i.i528

panic.i.i528:                                     ; preds = %__barray_check_bounds.exit.i527
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i529:                                   ; preds = %__barray_check_bounds.exit.i527
  %120 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn160168.i, i64 %65, 1
  %121 = shl nuw i64 1, %117
  %122 = xor i64 %116, %121
  store i64 %122, ptr %115, align 4
  %123 = getelementptr inbounds nuw i1, ptr %62, i64 %"301_0.sroa.15.0169.i"
  store i1 %read_bool.i, ptr %123, align 1
  %124 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn160168.i, 0
  %exitcond.not.i530 = icmp eq i64 %65, 70
  br i1 %exitcond.not.i530, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i526

"__hugr__.guppylang.std.quantum.collect_measurements$70.287.exit": ; preds = %97, %cond_525_case_0.i.i
  tail call void @heap_free(ptr %"522_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"522_1.sroa.5.0.i.i")
  %125 = getelementptr inbounds nuw i8, ptr %63, i64 8
  %126 = load i64, ptr %125, align 4
  %127 = and i64 %126, 63
  store i64 %127, ptr %125, align 4
  %128 = load i64, ptr %63, align 4
  %129 = icmp eq i64 %128, 0
  %130 = icmp eq i64 %127, 0
  %or.cond.i = select i1 %129, i1 %130, i1 false
  br i1 %or.cond.i, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$70.287.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$70.287.exit"
  %131 = tail call ptr @heap_alloc(i64 70)
  %132 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %132, i8 0, i64 16, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(70) %131, ptr noundef nonnull align 1 dereferenceable(70) %62, i64 70, i1 false)
  tail call void @heap_free(ptr nonnull %131)
  %133 = load i64, ptr %125, align 4
  %134 = and i64 %133, 63
  store i64 %134, ptr %125, align 4
  %135 = load i64, ptr %63, align 4
  %136 = icmp eq i64 %135, 0
  %137 = icmp eq i64 %134, 0
  %or.cond.i543 = select i1 %136, i1 %137, i1 false
  br i1 %or.cond.i543, label %__barray_check_none_borrowed.exit545, label %mask_block_err.i544

mask_block_err.i544:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit545:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %138 = alloca [70 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(70) %138, i8 0, i64 70, i1 false)
  store i32 70, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %62, ptr %arr_ptr, align 8
  store ptr %138, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  ret void

finish:                                           ; preds = %loop_out, %2
  %"47_0.0567" = phi i64 [ 0, %loop_out ], [ %139, %2 ]
  %139 = add nuw nsw i64 %"47_0.0567", 1
  %remainder.urem = and i64 %"47_0.0567", 1
  %140 = icmp eq i64 %remainder.urem, 0
  br i1 %140, label %__barray_check_bounds.exit547, label %2

__barray_check_bounds.exit547:                    ; preds = %finish
  %141 = lshr i64 %"47_0.0567", 6
  %142 = getelementptr inbounds nuw i64, ptr %1, i64 %141
  %143 = load i64, ptr %142, align 4
  %144 = and i64 %"47_0.0567", 62
  %145 = lshr i64 %143, %144
  %146 = trunc i64 %145 to i1
  br i1 %146, label %panic.i548, label %__barray_check_bounds.exit550

panic.i548:                                       ; preds = %__barray_check_bounds.exit547
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit550:                    ; preds = %__barray_check_bounds.exit547
  %147 = shl nuw nsw i64 1, %144
  %148 = xor i64 %143, %147
  store i64 %148, ptr %142, align 4
  %149 = getelementptr inbounds nuw i64, ptr %0, i64 %"47_0.0567"
  %150 = load i64, ptr %149, align 4
  tail call void @___rxy(i64 %150, double 0x400921FB54442D18, double 0.000000e+00)
  %151 = load i64, ptr %142, align 4
  %152 = lshr i64 %151, %144
  %153 = trunc i64 %152 to i1
  br i1 %153, label %__barray_mask_return.exit552, label %panic.i551

panic.i551:                                       ; preds = %__barray_check_bounds.exit550
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit552:                     ; preds = %__barray_check_bounds.exit550
  %154 = xor i64 %151, %147
  store i64 %154, ptr %142, align 4
  store i64 %150, ptr %149, align 4
  br label %2
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

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

attributes #0 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #1 = { noreturn }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!name = !{!0}

!0 = !{!"mainlib"}
