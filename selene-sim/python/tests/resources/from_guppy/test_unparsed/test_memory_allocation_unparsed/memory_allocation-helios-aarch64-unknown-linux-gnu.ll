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

2:                                                ; preds = %finish, %__barray_mask_return.exit678
  %exitcond726.not = icmp eq i64 %139, 70
  br i1 %exitcond726.not, label %cond_exit_113, label %finish

cond_20_case_1:                                   ; preds = %alloca_block, %cond_exit_20
  %"15_0.sroa.0.0721" = phi i64 [ 0, %alloca_block ], [ %3, %cond_exit_20 ]
  %3 = add nuw nsw i64 %"15_0.sroa.0.0721", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_492_case_0.i, label %__barray_check_bounds.exit

cond_492_case_0.i:                                ; preds = %cond_20_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_20_case_1
  tail call void @___reset(i64 %qalloc.i)
  %4 = lshr i64 %"15_0.sroa.0.0721", 6
  %5 = getelementptr inbounds nuw i64, ptr %1, i64 %4
  %6 = load i64, ptr %5, align 4
  %7 = and i64 %"15_0.sroa.0.0721", 63
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
  %12 = getelementptr inbounds nuw i64, ptr %0, i64 %"15_0.sroa.0.0721"
  store i64 %qalloc.i, ptr %12, align 4
  %exitcond.not = icmp eq i64 %3, 70
  br i1 %exitcond.not, label %loop_out, label %cond_20_case_1

loop_out:                                         ; preds = %cond_exit_20
  %"117.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"117.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"117.fca.0.insert", ptr %1, 1
  %"117.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"117.fca.1.insert", i64 0, 2
  br label %finish

loop_body.preheader.i:                            ; preds = %loop_body121
  %"512_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %79, 2
  %"512_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %79, 1
  %"512_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %79, 0
  br label %__barray_check_bounds.exit224.i

__barray_check_bounds.exit.i:                     ; preds = %loop_body121, %"__hugr__.guppylang.std.quantum.measure_array$70.289.exit"
  %13 = phi { ptr, ptr, i64 } [ %"124.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$70.289.exit" ], [ %79, %loop_body121 ]
  %"79_0.sroa.15.0725" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$70.289.exit" ], [ %14, %loop_body121 ]
  %.pn713724 = phi { { ptr, ptr, i64 }, i64 } [ %136, %"__hugr__.guppylang.std.quantum.measure_array$70.289.exit" ], [ %75, %loop_body121 ]
  %14 = add nuw nsw i64 %"79_0.sroa.15.0725", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %13, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %13, 1
  %15 = add i64 %.fca.2.extract208.i, %"79_0.sroa.15.0725"
  %16 = lshr i64 %15, 6
  %17 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %16
  %18 = load i64, ptr %17, align 4
  %19 = and i64 %15, 63
  %20 = lshr i64 %18, %19
  %21 = trunc i64 %20 to i1
  br i1 %21, label %panic.i.i, label %__barray_check_bounds.exit221.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %13, 0
  %22 = shl nuw i64 1, %19
  %23 = xor i64 %18, %22
  store i64 %23, ptr %17, align 4
  %24 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %15
  %25 = load i64, ptr %24, align 4
  tail call void @___inc_future_refcount(i64 %25)
  %26 = load i64, ptr %17, align 4
  %27 = lshr i64 %26, %19
  %28 = trunc i64 %27 to i1
  br i1 %28, label %__barray_check_bounds.exit664, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_515_case_0.i:                                ; preds = %cond_exit_515.thread.i
  %29 = lshr i64 %"512_1.sroa.10.0.i", 6
  %30 = getelementptr i64, ptr %"512_1.sroa.5.0.i", i64 %29
  %31 = load i64, ptr %30, align 4
  %32 = and i64 %"512_1.sroa.10.0.i", 63
  %33 = sub nuw nsw i64 64, %32
  %34 = lshr i64 -1, %33
  %35 = icmp eq i64 %32, 0
  %36 = select i1 %35, i64 0, i64 %34
  %37 = or i64 %31, %36
  store i64 %37, ptr %30, align 4
  %last_valid.i.i = add i64 %"512_1.sroa.10.0.i", 69
  %38 = lshr i64 %last_valid.i.i, 6
  %39 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i", i64 %38
  %40 = load i64, ptr %39, align 4
  %41 = and i64 %last_valid.i.i, 63
  %42 = shl nsw i64 -2, %41
  %43 = icmp eq i64 %41, 63
  %44 = select i1 %43, i64 0, i64 %42
  %45 = or i64 %40, %44
  store i64 %45, ptr %39, align 4
  %reass.sub.i.i = sub nsw i64 %38, %29
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&70.330.exit", label %mask_block_ok.i.i

46:                                               ; preds = %mask_block_ok.i.i
  %47 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&70.330.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_515_case_0.i, %46
  %.02.i.i = phi i64 [ %47, %46 ], [ 0, %cond_515_case_0.i ]
  %gep.i.i = getelementptr i64, ptr %30, i64 %.02.i.i
  %48 = load i64, ptr %gep.i.i, align 4
  %49 = icmp eq i64 %48, -1
  br i1 %49, label %46, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i:                  ; preds = %cond_exit_515.thread.i, %loop_body.preheader.i
  %"512_0.0239.i" = phi i64 [ 0, %loop_body.preheader.i ], [ %50, %cond_exit_515.thread.i ]
  %50 = add nuw nsw i64 %"512_0.0239.i", 1
  %51 = add i64 %"512_0.0239.i", %"512_1.sroa.10.0.i"
  %52 = lshr i64 %51, 6
  %53 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i", i64 %52
  %54 = load i64, ptr %53, align 4
  %55 = and i64 %51, 63
  %56 = lshr i64 %54, %55
  %57 = trunc i64 %56 to i1
  br i1 %57, label %cond_exit_515.thread.i, label %__barray_mask_borrow.exit228.i

__barray_mask_borrow.exit228.i:                   ; preds = %__barray_check_bounds.exit224.i
  %58 = shl nuw i64 1, %55
  %59 = xor i64 %58, %54
  store i64 %59, ptr %53, align 4
  %60 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i", i64 %51
  %61 = load i64, ptr %60, align 4
  tail call void @___dec_future_refcount(i64 %61)
  br label %cond_exit_515.thread.i

cond_exit_515.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %__barray_check_bounds.exit224.i
  %exitcond.i = icmp eq i64 %50, 70
  br i1 %exitcond.i, label %cond_515_case_0.i, label %__barray_check_bounds.exit224.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&70.330.exit": ; preds = %46, %cond_515_case_0.i
  tail call void @heap_free(ptr %"512_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"512_1.sroa.5.0.i")
  %62 = getelementptr inbounds nuw i8, ptr %138, i64 8
  %63 = load i64, ptr %62, align 4
  %64 = and i64 %63, 63
  store i64 %64, ptr %62, align 4
  %65 = load i64, ptr %138, align 4
  %66 = icmp eq i64 %65, 0
  %67 = icmp eq i64 %64, 0
  %or.cond.i = select i1 %66, i1 %67, i1 false
  br i1 %or.cond.i, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit664:                    ; preds = %__barray_check_bounds.exit221.i
  %68 = xor i64 %26, %22
  store i64 %68, ptr %17, align 4
  store i64 %25, ptr %24, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %25)
  tail call void @___dec_future_refcount(i64 %25)
  %69 = lshr i64 %"79_0.sroa.15.0725", 6
  %70 = getelementptr inbounds nuw i64, ptr %138, i64 %69
  %71 = load i64, ptr %70, align 4
  %72 = and i64 %"79_0.sroa.15.0725", 63
  %73 = lshr i64 %71, %72
  %74 = trunc i64 %73 to i1
  br i1 %74, label %loop_body121, label %panic.i665

panic.i665:                                       ; preds = %__barray_check_bounds.exit664
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body121:                                     ; preds = %__barray_check_bounds.exit664
  %75 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn713724, i64 %14, 1
  %76 = shl nuw i64 1, %72
  %77 = xor i64 %71, %76
  store i64 %77, ptr %70, align 4
  %78 = getelementptr inbounds nuw i1, ptr %137, i64 %"79_0.sroa.15.0725"
  store i1 %read_bool, ptr %78, align 1
  %79 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn713724, 0
  %exitcond727.not = icmp eq i64 %14, 70
  br i1 %exitcond727.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&70.330.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&70.330.exit"
  %80 = tail call ptr @heap_alloc(i64 70)
  %81 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %81, i8 0, i64 16, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(70) %80, ptr noundef nonnull align 1 dereferenceable(70) %137, i64 70, i1 false)
  tail call void @heap_free(ptr nonnull %80)
  %82 = load i64, ptr %62, align 4
  %83 = and i64 %82, 63
  store i64 %83, ptr %62, align 4
  %84 = load i64, ptr %138, align 4
  %85 = icmp eq i64 %84, 0
  %86 = icmp eq i64 %83, 0
  %or.cond.i667 = select i1 %85, i1 %86, i1 false
  br i1 %or.cond.i667, label %__barray_check_none_borrowed.exit669, label %mask_block_err.i668

mask_block_err.i668:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit669:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %87 = alloca [70 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(70) %87, i8 0, i64 70, i1 false)
  store i32 70, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %137, ptr %arr_ptr, align 8
  store ptr %87, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  ret void

cond_exit_113:                                    ; preds = %2
  %88 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"117.fca.2.insert", 0
  %89 = tail call ptr @heap_alloc(i64 560)
  %90 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %90, i8 -1, i64 16, i1 false)
  br label %__barray_check_bounds.exit.i.i

91:                                               ; preds = %loop_body.i
  %92 = lshr i64 %.fca.2.extract.i.i, 6
  %93 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %92
  %94 = load i64, ptr %93, align 4
  %95 = and i64 %.fca.2.extract.i.i, 63
  %96 = sub nuw nsw i64 64, %95
  %97 = lshr i64 -1, %96
  %98 = icmp eq i64 %95, 0
  %99 = select i1 %98, i64 0, i64 %97
  %100 = or i64 %94, %99
  store i64 %100, ptr %93, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 69
  %101 = lshr i64 %last_valid.i.i.i, 6
  %102 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %101
  %103 = load i64, ptr %102, align 4
  %104 = and i64 %last_valid.i.i.i, 63
  %105 = shl nsw i64 -2, %104
  %106 = icmp eq i64 %104, 63
  %107 = select i1 %106, i64 0, i64 %105
  %108 = or i64 %103, %107
  store i64 %108, ptr %102, align 4
  %reass.sub.i.i.i = sub nsw i64 %101, %92
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$70.289.exit", label %mask_block_ok.i.i.i

109:                                              ; preds = %mask_block_ok.i.i.i
  %110 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$70.289.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %91, %109
  %.02.i.i.i = phi i64 [ %110, %109 ], [ 0, %91 ]
  %gep.i.i.i = getelementptr i64, ptr %93, i64 %.02.i.i.i
  %111 = load i64, ptr %gep.i.i.i, align 4
  %112 = icmp eq i64 %111, -1
  br i1 %112, label %109, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_113
  %.fca.2.extract.i182.i = phi i64 [ 0, %cond_exit_113 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i181.i = phi ptr [ %1, %cond_exit_113 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i180.i = phi ptr [ %0, %cond_exit_113 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"303_0.sroa.15.0179.i" = phi i64 [ 0, %cond_exit_113 ], [ %113, %loop_body.i ]
  %.pn160178.i = phi { { ptr, ptr, i64 }, i64 } [ %88, %cond_exit_113 ], [ %131, %loop_body.i ]
  %113 = add nuw nsw i64 %"303_0.sroa.15.0179.i", 1
  %114 = add i64 %"303_0.sroa.15.0179.i", %.fca.2.extract.i182.i
  %115 = lshr i64 %114, 6
  %116 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i181.i, i64 %115
  %117 = load i64, ptr %116, align 4
  %118 = and i64 %114, 63
  %119 = lshr i64 %117, %118
  %120 = trunc i64 %119 to i1
  br i1 %120, label %panic.i.i.i, label %__barray_check_bounds.exit.i670

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i670:                  ; preds = %__barray_check_bounds.exit.i.i
  %121 = shl nuw i64 1, %118
  %122 = xor i64 %121, %117
  store i64 %122, ptr %116, align 4
  %123 = getelementptr inbounds i64, ptr %.fca.0.extract62.i180.i, i64 %114
  %124 = load i64, ptr %123, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %124)
  tail call void @___qfree(i64 %124)
  %125 = lshr i64 %"303_0.sroa.15.0179.i", 6
  %126 = getelementptr inbounds nuw i64, ptr %90, i64 %125
  %127 = load i64, ptr %126, align 4
  %128 = and i64 %"303_0.sroa.15.0179.i", 63
  %129 = lshr i64 %127, %128
  %130 = trunc i64 %129 to i1
  br i1 %130, label %loop_body.i, label %panic.i.i671

panic.i.i671:                                     ; preds = %__barray_check_bounds.exit.i670
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i670
  %131 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn160178.i, i64 %113, 1
  %132 = shl nuw i64 1, %128
  %133 = xor i64 %127, %132
  store i64 %133, ptr %126, align 4
  %134 = getelementptr inbounds nuw i64, ptr %89, i64 %"303_0.sroa.15.0179.i"
  store i64 %lazy_measure.i, ptr %134, align 4
  %135 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn160178.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %135, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %135, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %135, 2
  %exitcond.not.i = icmp eq i64 %113, 70
  br i1 %exitcond.not.i, label %91, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$70.289.exit": ; preds = %109, %91
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"124.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %89, 0
  %"124.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"124.fca.0.insert.i", ptr %90, 1
  %"124.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"124.fca.1.insert.i", i64 0, 2
  %136 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"124.fca.2.insert.i", 0
  %137 = tail call ptr @heap_alloc(i64 70)
  %138 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %138, i8 -1, i64 16, i1 false)
  br label %__barray_check_bounds.exit.i

finish:                                           ; preds = %loop_out, %2
  %"47_0.0722" = phi i64 [ 0, %loop_out ], [ %139, %2 ]
  %139 = add nuw nsw i64 %"47_0.0722", 1
  %remainder.urem = and i64 %"47_0.0722", 1
  %140 = icmp eq i64 %remainder.urem, 0
  br i1 %140, label %__barray_check_bounds.exit673, label %2

__barray_check_bounds.exit673:                    ; preds = %finish
  %141 = lshr i64 %"47_0.0722", 6
  %142 = getelementptr inbounds nuw i64, ptr %1, i64 %141
  %143 = load i64, ptr %142, align 4
  %144 = and i64 %"47_0.0722", 62
  %145 = lshr i64 %143, %144
  %146 = trunc i64 %145 to i1
  br i1 %146, label %panic.i674, label %__barray_check_bounds.exit676

panic.i674:                                       ; preds = %__barray_check_bounds.exit673
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit676:                    ; preds = %__barray_check_bounds.exit673
  %147 = shl nuw nsw i64 1, %144
  %148 = xor i64 %143, %147
  store i64 %148, ptr %142, align 4
  %149 = getelementptr inbounds nuw i64, ptr %0, i64 %"47_0.0722"
  %150 = load i64, ptr %149, align 4
  tail call void @___rxy(i64 %150, double 0x400921FB54442D18, double 0.000000e+00)
  %151 = load i64, ptr %142, align 4
  %152 = lshr i64 %151, %144
  %153 = trunc i64 %152 to i1
  br i1 %153, label %__barray_mask_return.exit678, label %panic.i677

panic.i677:                                       ; preds = %__barray_check_bounds.exit676
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit678:                     ; preds = %__barray_check_bounds.exit676
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

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

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
