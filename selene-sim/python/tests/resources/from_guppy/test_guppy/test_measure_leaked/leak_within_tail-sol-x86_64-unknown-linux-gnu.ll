; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@e_Option.unw.32D4E82D.0 = private constant [43 x i8] c"*EXIT:INT:Option.unwrap: value is `Nothing`"
@res_head_leake.F4F32972.0 = private constant [21 x i8] c"\14USER:INT:head_leaked"
@res_head.AFE8E005.0 = private constant [15 x i8] c"\0EUSER:BOOL:head"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_tail.AD5A440E.0 = private constant [18 x i8] c"\11USER:BOOLARR:tail"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 160)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_557_case_0.i, label %__hugr__.__tk2_sol_qalloc.553.exit

cond_557_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.553.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18)
  br label %cond_21_case_1

2:                                                ; preds = %cond_exit_89
  %read_uint.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %.not = icmp eq i64 %read_uint.i, 2
  br i1 %.not, label %cond_150_case_0, label %cond_150_case_1

3:                                                ; preds = %cond_exit_89
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  tail call void @print_int(ptr nonnull @res_head_leake.F4F32972.0, i64 20, i64 1)
  br label %5

cond_150_case_1:                                  ; preds = %2
  %4 = icmp eq i64 %read_uint.i, 1
  tail call void @print_bool(ptr nonnull @res_head.AFE8E005.0, i64 14, i1 %4)
  br label %5

5:                                                ; preds = %cond_150_case_1, %3
  %"164_0243.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"164_0243.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"164_0243.fca.0.insert", ptr %1, 1
  %"164_0243.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"164_0243.fca.1.insert", i64 0, 2
  %6 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"164_0243.fca.2.insert", 0
  %7 = tail call ptr @heap_alloc(i64 160)
  %8 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %8, align 1
  br label %__barray_check_bounds.exit.i.i

9:                                                ; preds = %loop_body.i
  %10 = lshr i64 %.fca.2.extract.i.i, 6
  %11 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %10
  %12 = load i64, ptr %11, align 4
  %13 = and i64 %.fca.2.extract.i.i, 63
  %14 = sub nuw nsw i64 64, %13
  %15 = lshr i64 -1, %14
  %16 = icmp eq i64 %13, 0
  %17 = select i1 %16, i64 0, i64 %15
  %18 = or i64 %12, %17
  store i64 %18, ptr %11, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 19
  %19 = lshr i64 %last_valid.i.i.i, 6
  %20 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %19
  %21 = load i64, ptr %20, align 4
  %22 = and i64 %last_valid.i.i.i, 63
  %23 = shl nsw i64 -2, %22
  %24 = icmp eq i64 %22, 63
  %25 = select i1 %24, i64 0, i64 %23
  %26 = or i64 %21, %25
  store i64 %26, ptr %20, align 4
  %reass.sub.i.i.i = sub nsw i64 %19, %10
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$20.370.exit", label %mask_block_ok.i.i.i

27:                                               ; preds = %mask_block_ok.i.i.i
  %28 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$20.370.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %9, %27
  %.02.i.i.i = phi i64 [ %28, %27 ], [ 0, %9 ]
  %gep.i.i.i = getelementptr i64, ptr %11, i64 %.02.i.i.i
  %29 = load i64, ptr %gep.i.i.i, align 4
  %30 = icmp eq i64 %29, -1
  br i1 %30, label %27, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %5
  %.fca.2.extract.i181.i = phi i64 [ 0, %5 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %5 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %5 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"384_0.sroa.15.0178.i" = phi i64 [ 0, %5 ], [ %31, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %6, %5 ], [ %46, %loop_body.i ]
  %31 = add nuw nsw i64 %"384_0.sroa.15.0178.i", 1
  %32 = add i64 %"384_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %33 = lshr i64 %32, 6
  %34 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %33
  %35 = load i64, ptr %34, align 4
  %36 = and i64 %32, 63
  %37 = lshr i64 %35, %36
  %38 = trunc i64 %37 to i1
  br i1 %38, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %39 = shl nuw i64 1, %36
  %40 = xor i64 %39, %35
  store i64 %40, ptr %34, align 4
  %41 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %32
  %42 = load i64, ptr %41, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %42)
  tail call void @___qfree(i64 %42)
  %43 = load i64, ptr %8, align 4
  %44 = lshr i64 %43, %"384_0.sroa.15.0178.i"
  %45 = trunc i64 %44 to i1
  br i1 %45, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %46 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %31, 1
  %47 = shl nuw nsw i64 1, %"384_0.sroa.15.0178.i"
  %48 = xor i64 %43, %47
  store i64 %48, ptr %8, align 4
  %49 = getelementptr inbounds nuw i64, ptr %7, i64 %"384_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %49, align 4
  %50 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %50, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %50, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %50, 2
  %exitcond.not.i = icmp eq i64 %31, 20
  br i1 %exitcond.not.i, label %9, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$20.370.exit": ; preds = %27, %9
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %7, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %8, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %51 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %52 = tail call ptr @heap_alloc(i64 20)
  %53 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %53, align 1
  br label %__barray_check_bounds.exit.i.i454

loop_body.preheader.i.i:                          ; preds = %loop_body.i457
  %"659_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %111, 2
  %"659_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %111, 1
  %"659_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %111, 0
  br label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i.i454:                ; preds = %loop_body.i457, %"__hugr__.guppylang.std.quantum.measure_array$20.370.exit"
  %54 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$20.370.exit" ], [ %111, %loop_body.i457 ]
  %"343_0.sroa.15.0168.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$20.370.exit" ], [ %55, %loop_body.i457 ]
  %.pn159167.i = phi { { ptr, ptr, i64 }, i64 } [ %51, %"__hugr__.guppylang.std.quantum.measure_array$20.370.exit" ], [ %107, %loop_body.i457 ]
  %55 = add nuw nsw i64 %"343_0.sroa.15.0168.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %54, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %54, 1
  %56 = add i64 %.fca.2.extract208.i.i, %"343_0.sroa.15.0168.i"
  %57 = lshr i64 %56, 6
  %58 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %57
  %59 = load i64, ptr %58, align 4
  %60 = and i64 %56, 63
  %61 = lshr i64 %59, %60
  %62 = trunc i64 %61 to i1
  br i1 %62, label %panic.i.i.i470, label %__barray_check_bounds.exit221.i.i

panic.i.i.i470:                                   ; preds = %__barray_check_bounds.exit.i.i454
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i454
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %54, 0
  %63 = shl nuw i64 1, %60
  %64 = xor i64 %63, %59
  store i64 %64, ptr %58, align 4
  %65 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %56
  %66 = load i64, ptr %65, align 4
  tail call void @___inc_future_refcount(i64 %66)
  %67 = load i64, ptr %58, align 4
  %68 = lshr i64 %67, %60
  %69 = trunc i64 %68 to i1
  br i1 %69, label %__barray_check_bounds.exit.i455, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_662_case_0.i.i:                              ; preds = %cond_exit_662.thread.i.i
  %70 = lshr i64 %"659_1.sroa.10.0.i.i", 6
  %71 = getelementptr i64, ptr %"659_1.sroa.5.0.i.i", i64 %70
  %72 = load i64, ptr %71, align 4
  %73 = and i64 %"659_1.sroa.10.0.i.i", 63
  %74 = sub nuw nsw i64 64, %73
  %75 = lshr i64 -1, %74
  %76 = icmp eq i64 %73, 0
  %77 = select i1 %76, i64 0, i64 %75
  %78 = or i64 %72, %77
  store i64 %78, ptr %71, align 4
  %last_valid.i.i.i459 = add i64 %"659_1.sroa.10.0.i.i", 19
  %79 = lshr i64 %last_valid.i.i.i459, 6
  %80 = getelementptr inbounds nuw i64, ptr %"659_1.sroa.5.0.i.i", i64 %79
  %81 = load i64, ptr %80, align 4
  %82 = and i64 %last_valid.i.i.i459, 63
  %83 = shl nsw i64 -2, %82
  %84 = icmp eq i64 %82, 63
  %85 = select i1 %84, i64 0, i64 %83
  %86 = or i64 %81, %85
  store i64 %86, ptr %80, align 4
  %reass.sub.i.i.i460 = sub nsw i64 %79, %70
  %.not.i.i.i461 = icmp eq i64 %reass.sub.i.i.i460, -1
  br i1 %.not.i.i.i461, label %"__hugr__.guppylang.std.quantum.collect_measurements$20.329.exit", label %mask_block_ok.i.i.i462

87:                                               ; preds = %mask_block_ok.i.i.i462
  %88 = add nuw i64 %.02.i.i.i463, 1
  %exitcond.not.i.i.i466 = icmp eq i64 %.02.i.i.i463, %reass.sub.i.i.i460
  br i1 %exitcond.not.i.i.i466, label %"__hugr__.guppylang.std.quantum.collect_measurements$20.329.exit", label %mask_block_ok.i.i.i462

mask_block_ok.i.i.i462:                           ; preds = %cond_662_case_0.i.i, %87
  %.02.i.i.i463 = phi i64 [ %88, %87 ], [ 0, %cond_662_case_0.i.i ]
  %gep.i.i.i464 = getelementptr i64, ptr %71, i64 %.02.i.i.i463
  %89 = load i64, ptr %gep.i.i.i464, align 4
  %90 = icmp eq i64 %89, -1
  br i1 %90, label %87, label %mask_block_err.i.i.i465

mask_block_err.i.i.i465:                          ; preds = %mask_block_ok.i.i.i462
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i.i:                ; preds = %cond_exit_662.thread.i.i, %loop_body.preheader.i.i
  %"659_0.0239.i.i" = phi i64 [ 0, %loop_body.preheader.i.i ], [ %91, %cond_exit_662.thread.i.i ]
  %91 = add nuw nsw i64 %"659_0.0239.i.i", 1
  %92 = add i64 %"659_0.0239.i.i", %"659_1.sroa.10.0.i.i"
  %93 = lshr i64 %92, 6
  %94 = getelementptr inbounds nuw i64, ptr %"659_1.sroa.5.0.i.i", i64 %93
  %95 = load i64, ptr %94, align 4
  %96 = and i64 %92, 63
  %97 = lshr i64 %95, %96
  %98 = trunc i64 %97 to i1
  br i1 %98, label %cond_exit_662.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_mask_borrow.exit228.i.i:                 ; preds = %__barray_check_bounds.exit224.i.i
  %99 = shl nuw i64 1, %96
  %100 = xor i64 %99, %95
  store i64 %100, ptr %94, align 4
  %101 = getelementptr inbounds i64, ptr %"659_1.sroa.0.0.i.i", i64 %92
  %102 = load i64, ptr %101, align 4
  tail call void @___dec_future_refcount(i64 %102)
  br label %cond_exit_662.thread.i.i

cond_exit_662.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %__barray_check_bounds.exit224.i.i
  %exitcond.i.i = icmp eq i64 %91, 20
  br i1 %exitcond.i.i, label %cond_662_case_0.i.i, label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i455:                  ; preds = %__barray_check_bounds.exit221.i.i
  %103 = xor i64 %67, %63
  store i64 %103, ptr %58, align 4
  store i64 %66, ptr %65, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %66)
  tail call void @___dec_future_refcount(i64 %66)
  %104 = load i64, ptr %53, align 4
  %105 = lshr i64 %104, %"343_0.sroa.15.0168.i"
  %106 = trunc i64 %105 to i1
  br i1 %106, label %loop_body.i457, label %panic.i.i456

panic.i.i456:                                     ; preds = %__barray_check_bounds.exit.i455
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i457:                                   ; preds = %__barray_check_bounds.exit.i455
  %107 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, i64 %55, 1
  %108 = shl nuw nsw i64 1, %"343_0.sroa.15.0168.i"
  %109 = xor i64 %104, %108
  store i64 %109, ptr %53, align 4
  %110 = getelementptr inbounds nuw i1, ptr %52, i64 %"343_0.sroa.15.0168.i"
  store i1 %read_bool.i, ptr %110, align 1
  %111 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, 0
  %exitcond.not.i458 = icmp eq i64 %55, 20
  br i1 %exitcond.not.i458, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i454

"__hugr__.guppylang.std.quantum.collect_measurements$20.329.exit": ; preds = %87, %cond_662_case_0.i.i
  tail call void @heap_free(ptr %"659_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"659_1.sroa.5.0.i.i")
  %112 = load i64, ptr %53, align 4
  %113 = and i64 %112, 1048575
  store i64 %113, ptr %53, align 4
  %114 = icmp eq i64 %113, 0
  br i1 %114, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$20.329.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$20.329.exit"
  %115 = tail call ptr @heap_alloc(i64 20)
  %116 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %116, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %115, ptr noundef nonnull align 1 dereferenceable(20) %52, i64 20, i1 false)
  tail call void @heap_free(ptr nonnull %115)
  %117 = load i64, ptr %53, align 4
  %118 = and i64 %117, 1048575
  store i64 %118, ptr %53, align 4
  %119 = icmp eq i64 %118, 0
  br i1 %119, label %__barray_check_none_borrowed.exit472, label %mask_block_err.i471

mask_block_err.i471:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit472:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %120 = alloca [20 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %120, i8 0, i64 20, i1 false)
  store i32 20, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %52, ptr %arr_ptr, align 8
  store ptr %120, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_tail.AD5A440E.0, i64 17, ptr nonnull %out_arr_alloca)
  ret void

cond_21_case_1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.553.exit, %cond_exit_21
  %"16_0.sroa.0.0517" = phi i64 [ 0, %__hugr__.__tk2_sol_qalloc.553.exit ], [ %121, %cond_exit_21 ]
  %121 = add nuw nsw i64 %"16_0.sroa.0.0517", 1
  %qalloc.i479 = tail call i64 @___qalloc()
  %not_max.not.not.i480 = icmp eq i64 %qalloc.i479, -1
  br i1 %not_max.not.not.i480, label %cond_639_case_0.i, label %__barray_check_bounds.exit

cond_639_case_0.i:                                ; preds = %cond_21_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_21_case_1
  tail call void @___reset(i64 %qalloc.i479)
  %122 = load i64, ptr %1, align 4
  %123 = lshr i64 %122, %"16_0.sroa.0.0517"
  %124 = trunc i64 %123 to i1
  br i1 %124, label %cond_exit_21, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_21:                                     ; preds = %__barray_check_bounds.exit
  %125 = shl nuw nsw i64 1, %"16_0.sroa.0.0517"
  %126 = xor i64 %122, %125
  store i64 %126, ptr %1, align 4
  %127 = getelementptr inbounds nuw i64, ptr %0, i64 %"16_0.sroa.0.0517"
  store i64 %qalloc.i479, ptr %127, align 4
  %exitcond.not = icmp eq i64 %121, 20
  br i1 %exitcond.not, label %loop_out, label %cond_21_case_1

loop_out:                                         ; preds = %cond_exit_21
  %128 = load i64, ptr %1, align 4
  %129 = trunc i64 %128 to i1
  br i1 %129, label %panic.i481, label %__barray_mask_borrow.exit

panic.i481:                                       ; preds = %loop_out
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %loop_out
  %130 = or disjoint i64 %128, 1
  store i64 %130, ptr %1, align 4
  %131 = load i64, ptr %0, align 4
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i, i64 %131, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %131, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  %132 = load i64, ptr %1, align 4
  %133 = trunc i64 %132 to i1
  br i1 %133, label %__barray_mask_return.exit483, label %panic.i482

panic.i482:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit483:                     ; preds = %__barray_mask_borrow.exit
  %134 = and i64 %132, -2
  store i64 %134, ptr %1, align 4
  store i64 %131, ptr %0, align 4
  br label %__barray_check_bounds.exit485

__barray_check_bounds.exit485:                    ; preds = %__barray_mask_return.exit501, %__barray_mask_return.exit483
  %"57_0.0518" = phi i64 [ 0, %__barray_mask_return.exit483 ], [ %135, %__barray_mask_return.exit501 ]
  %135 = add nuw nsw i64 %"57_0.0518", 1
  %136 = load i64, ptr %1, align 4
  %137 = lshr i64 %136, %"57_0.0518"
  %138 = trunc i64 %137 to i1
  br i1 %138, label %panic.i486, label %__barray_mask_borrow.exit487

panic.i486:                                       ; preds = %__barray_check_bounds.exit485
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit487:                     ; preds = %__barray_check_bounds.exit485
  %139 = shl nuw nsw i64 1, %"57_0.0518"
  %140 = xor i64 %136, %139
  store i64 %140, ptr %1, align 4
  %141 = getelementptr inbounds nuw i64, ptr %0, i64 %"57_0.0518"
  %142 = load i64, ptr %141, align 4
  %143 = lshr i64 %140, %135
  %144 = trunc i64 %143 to i1
  br i1 %144, label %panic.i490, label %__barray_check_bounds.exit495

panic.i490:                                       ; preds = %__barray_mask_borrow.exit487
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit495:                    ; preds = %__barray_mask_borrow.exit487
  %145 = shl nuw nsw i64 2, %"57_0.0518"
  %146 = xor i64 %140, %145
  store i64 %146, ptr %1, align 4
  %147 = getelementptr inbounds nuw i64, ptr %0, i64 %135
  %148 = load i64, ptr %147, align 4
  tail call void @___rp(i64 %142, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %142, i64 %148, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %148, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %142, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %142, double 0xBFF921FB54442D18)
  %149 = load i64, ptr %1, align 4
  %150 = lshr i64 %149, %"57_0.0518"
  %151 = trunc i64 %150 to i1
  br i1 %151, label %__barray_check_bounds.exit499, label %panic.i496

panic.i496:                                       ; preds = %__barray_check_bounds.exit495
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit499:                    ; preds = %__barray_check_bounds.exit495
  %152 = xor i64 %149, %139
  store i64 %152, ptr %1, align 4
  store i64 %142, ptr %141, align 4
  %153 = load i64, ptr %1, align 4
  %154 = lshr i64 %153, %135
  %155 = trunc i64 %154 to i1
  br i1 %155, label %__barray_mask_return.exit501, label %panic.i500

panic.i500:                                       ; preds = %__barray_check_bounds.exit499
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit501:                     ; preds = %__barray_check_bounds.exit499
  %156 = xor i64 %153, %145
  store i64 %156, ptr %1, align 4
  store i64 %148, ptr %147, align 4
  %exitcond519.not = icmp eq i64 %135, 19
  br i1 %exitcond519.not, label %cond_exit_89, label %__barray_check_bounds.exit485

cond_exit_89:                                     ; preds = %__barray_mask_return.exit501
  %lazy_measure_leaked.i = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___inc_future_refcount(i64 %lazy_measure_leaked.i)
  %read_uint.i502 = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %157 = icmp eq i64 %read_uint.i502, 2
  br i1 %157, label %3, label %2

cond_150_case_0:                                  ; preds = %2
  tail call void @panic(i32 1001, ptr nonnull @e_Option.unw.32D4E82D.0)
  unreachable
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure_leaked(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare i64 @___read_future_uint(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

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
