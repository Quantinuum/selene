; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

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
  br i1 %not_max.not.not.i, label %cond_547_case_0.i, label %__hugr__.__tk2_sol_qalloc.543.exit

cond_547_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.543.exit:               ; preds = %alloca_block
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
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$20.372.exit", label %mask_block_ok.i.i.i

27:                                               ; preds = %mask_block_ok.i.i.i
  %28 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$20.372.exit", label %mask_block_ok.i.i.i

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
  %"386_0.sroa.15.0178.i" = phi i64 [ 0, %5 ], [ %31, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %6, %5 ], [ %46, %loop_body.i ]
  %31 = add nuw nsw i64 %"386_0.sroa.15.0178.i", 1
  %32 = add i64 %"386_0.sroa.15.0178.i", %.fca.2.extract.i181.i
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
  %44 = lshr i64 %43, %"386_0.sroa.15.0178.i"
  %45 = trunc i64 %44 to i1
  br i1 %45, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %46 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %31, 1
  %47 = shl nuw nsw i64 1, %"386_0.sroa.15.0178.i"
  %48 = xor i64 %43, %47
  store i64 %48, ptr %8, align 4
  %49 = getelementptr inbounds nuw i64, ptr %7, i64 %"386_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %49, align 4
  %50 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %50, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %50, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %50, 2
  %exitcond.not.i = icmp eq i64 %31, 20
  br i1 %exitcond.not.i, label %9, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$20.372.exit": ; preds = %27, %9
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %7, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %8, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %51 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %52 = tail call ptr @heap_alloc(i64 20)
  %53 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %53, align 1
  br label %__barray_check_bounds.exit.i621

cond_21_case_1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.543.exit, %cond_exit_21
  %"16_0.sroa.0.0671" = phi i64 [ 0, %__hugr__.__tk2_sol_qalloc.543.exit ], [ %54, %cond_exit_21 ]
  %54 = add nuw nsw i64 %"16_0.sroa.0.0671", 1
  %qalloc.i596 = tail call i64 @___qalloc()
  %not_max.not.not.i597 = icmp eq i64 %qalloc.i596, -1
  br i1 %not_max.not.not.i597, label %cond_629_case_0.i, label %__barray_check_bounds.exit

cond_629_case_0.i:                                ; preds = %cond_21_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_21_case_1
  tail call void @___reset(i64 %qalloc.i596)
  %55 = load i64, ptr %1, align 4
  %56 = lshr i64 %55, %"16_0.sroa.0.0671"
  %57 = trunc i64 %56 to i1
  br i1 %57, label %cond_exit_21, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_21:                                     ; preds = %__barray_check_bounds.exit
  %58 = shl nuw nsw i64 1, %"16_0.sroa.0.0671"
  %59 = xor i64 %55, %58
  store i64 %59, ptr %1, align 4
  %60 = getelementptr inbounds nuw i64, ptr %0, i64 %"16_0.sroa.0.0671"
  store i64 %qalloc.i596, ptr %60, align 4
  %exitcond.not = icmp eq i64 %54, 20
  br i1 %exitcond.not, label %loop_out, label %cond_21_case_1

loop_out:                                         ; preds = %cond_exit_21
  %61 = load i64, ptr %1, align 4
  %62 = trunc i64 %61 to i1
  br i1 %62, label %panic.i598, label %__barray_mask_borrow.exit

panic.i598:                                       ; preds = %loop_out
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %loop_out
  %63 = or disjoint i64 %61, 1
  store i64 %63, ptr %1, align 4
  %64 = load i64, ptr %0, align 4
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i, i64 %64, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %64, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  %65 = load i64, ptr %1, align 4
  %66 = trunc i64 %65 to i1
  br i1 %66, label %__barray_mask_return.exit600, label %panic.i599

panic.i599:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit600:                     ; preds = %__barray_mask_borrow.exit
  %67 = and i64 %65, -2
  store i64 %67, ptr %1, align 4
  store i64 %64, ptr %0, align 4
  br label %__barray_check_bounds.exit602

__barray_check_bounds.exit602:                    ; preds = %__barray_mask_return.exit618, %__barray_mask_return.exit600
  %"57_0.0672" = phi i64 [ 0, %__barray_mask_return.exit600 ], [ %68, %__barray_mask_return.exit618 ]
  %68 = add nuw nsw i64 %"57_0.0672", 1
  %69 = load i64, ptr %1, align 4
  %70 = lshr i64 %69, %"57_0.0672"
  %71 = trunc i64 %70 to i1
  br i1 %71, label %panic.i603, label %__barray_mask_borrow.exit604

panic.i603:                                       ; preds = %__barray_check_bounds.exit602
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit604:                     ; preds = %__barray_check_bounds.exit602
  %72 = shl nuw nsw i64 1, %"57_0.0672"
  %73 = xor i64 %69, %72
  store i64 %73, ptr %1, align 4
  %74 = getelementptr inbounds nuw i64, ptr %0, i64 %"57_0.0672"
  %75 = load i64, ptr %74, align 4
  %76 = lshr i64 %73, %68
  %77 = trunc i64 %76 to i1
  br i1 %77, label %panic.i607, label %__barray_check_bounds.exit612

panic.i607:                                       ; preds = %__barray_mask_borrow.exit604
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit612:                    ; preds = %__barray_mask_borrow.exit604
  %78 = shl nuw nsw i64 2, %"57_0.0672"
  %79 = xor i64 %73, %78
  store i64 %79, ptr %1, align 4
  %80 = getelementptr inbounds nuw i64, ptr %0, i64 %68
  %81 = load i64, ptr %80, align 4
  tail call void @___rp(i64 %75, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %75, i64 %81, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %81, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %75, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %75, double 0xBFF921FB54442D18)
  %82 = load i64, ptr %1, align 4
  %83 = lshr i64 %82, %"57_0.0672"
  %84 = trunc i64 %83 to i1
  br i1 %84, label %__barray_check_bounds.exit616, label %panic.i613

panic.i613:                                       ; preds = %__barray_check_bounds.exit612
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit616:                    ; preds = %__barray_check_bounds.exit612
  %85 = xor i64 %82, %72
  store i64 %85, ptr %1, align 4
  store i64 %75, ptr %74, align 4
  %86 = load i64, ptr %1, align 4
  %87 = lshr i64 %86, %68
  %88 = trunc i64 %87 to i1
  br i1 %88, label %__barray_mask_return.exit618, label %panic.i617

panic.i617:                                       ; preds = %__barray_check_bounds.exit616
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit618:                     ; preds = %__barray_check_bounds.exit616
  %89 = xor i64 %86, %78
  store i64 %89, ptr %1, align 4
  store i64 %81, ptr %80, align 4
  %exitcond676.not = icmp eq i64 %68, 19
  br i1 %exitcond676.not, label %cond_exit_89, label %__barray_check_bounds.exit602

cond_exit_89:                                     ; preds = %__barray_mask_return.exit618
  %lazy_measure_leaked.i = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___inc_future_refcount(i64 %lazy_measure_leaked.i)
  %read_uint.i619 = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %90 = icmp eq i64 %read_uint.i619, 2
  br i1 %90, label %3, label %2

cond_150_case_0:                                  ; preds = %2
  tail call void @panic(i32 1001, ptr nonnull @e_Option.unw.32D4E82D.0)
  unreachable

loop_body.preheader.i:                            ; preds = %loop_body254
  %"649_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %151, 2
  %"649_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %151, 1
  %"649_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %151, 0
  br label %__barray_check_bounds.exit224.i

__barray_check_bounds.exit.i621:                  ; preds = %loop_body254, %"__hugr__.guppylang.std.quantum.measure_array$20.372.exit"
  %91 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$20.372.exit" ], [ %151, %loop_body254 ]
  %"174_0.sroa.15.0675" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$20.372.exit" ], [ %92, %loop_body254 ]
  %.pn663674 = phi { { ptr, ptr, i64 }, i64 } [ %51, %"__hugr__.guppylang.std.quantum.measure_array$20.372.exit" ], [ %147, %loop_body254 ]
  %92 = add nuw nsw i64 %"174_0.sroa.15.0675", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %91, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %91, 1
  %93 = add i64 %.fca.2.extract208.i, %"174_0.sroa.15.0675"
  %94 = lshr i64 %93, 6
  %95 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %94
  %96 = load i64, ptr %95, align 4
  %97 = and i64 %93, 63
  %98 = lshr i64 %96, %97
  %99 = trunc i64 %98 to i1
  br i1 %99, label %panic.i.i622, label %__barray_check_bounds.exit221.i

panic.i.i622:                                     ; preds = %__barray_check_bounds.exit.i621
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i621
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %91, 0
  %100 = shl nuw i64 1, %97
  %101 = xor i64 %96, %100
  store i64 %101, ptr %95, align 4
  %102 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %93
  %103 = load i64, ptr %102, align 4
  tail call void @___inc_future_refcount(i64 %103)
  %104 = load i64, ptr %95, align 4
  %105 = lshr i64 %104, %97
  %106 = trunc i64 %105 to i1
  br i1 %106, label %__barray_check_bounds.exit624, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_652_case_0.i:                                ; preds = %cond_exit_652.thread.i
  %107 = lshr i64 %"649_1.sroa.10.0.i", 6
  %108 = getelementptr i64, ptr %"649_1.sroa.5.0.i", i64 %107
  %109 = load i64, ptr %108, align 4
  %110 = and i64 %"649_1.sroa.10.0.i", 63
  %111 = sub nuw nsw i64 64, %110
  %112 = lshr i64 -1, %111
  %113 = icmp eq i64 %110, 0
  %114 = select i1 %113, i64 0, i64 %112
  %115 = or i64 %109, %114
  store i64 %115, ptr %108, align 4
  %last_valid.i.i = add i64 %"649_1.sroa.10.0.i", 19
  %116 = lshr i64 %last_valid.i.i, 6
  %117 = getelementptr inbounds nuw i64, ptr %"649_1.sroa.5.0.i", i64 %116
  %118 = load i64, ptr %117, align 4
  %119 = and i64 %last_valid.i.i, 63
  %120 = shl nsw i64 -2, %119
  %121 = icmp eq i64 %119, 63
  %122 = select i1 %121, i64 0, i64 %120
  %123 = or i64 %118, %122
  store i64 %123, ptr %117, align 4
  %reass.sub.i.i = sub nsw i64 %116, %107
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.413.exit", label %mask_block_ok.i.i

124:                                              ; preds = %mask_block_ok.i.i
  %125 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.413.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_652_case_0.i, %124
  %.02.i.i = phi i64 [ %125, %124 ], [ 0, %cond_652_case_0.i ]
  %gep.i.i = getelementptr i64, ptr %108, i64 %.02.i.i
  %126 = load i64, ptr %gep.i.i, align 4
  %127 = icmp eq i64 %126, -1
  br i1 %127, label %124, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i:                  ; preds = %cond_exit_652.thread.i, %loop_body.preheader.i
  %"649_0.0239.i" = phi i64 [ 0, %loop_body.preheader.i ], [ %128, %cond_exit_652.thread.i ]
  %128 = add nuw nsw i64 %"649_0.0239.i", 1
  %129 = add i64 %"649_0.0239.i", %"649_1.sroa.10.0.i"
  %130 = lshr i64 %129, 6
  %131 = getelementptr inbounds nuw i64, ptr %"649_1.sroa.5.0.i", i64 %130
  %132 = load i64, ptr %131, align 4
  %133 = and i64 %129, 63
  %134 = lshr i64 %132, %133
  %135 = trunc i64 %134 to i1
  br i1 %135, label %cond_exit_652.thread.i, label %__barray_mask_borrow.exit228.i

__barray_mask_borrow.exit228.i:                   ; preds = %__barray_check_bounds.exit224.i
  %136 = shl nuw i64 1, %133
  %137 = xor i64 %136, %132
  store i64 %137, ptr %131, align 4
  %138 = getelementptr inbounds i64, ptr %"649_1.sroa.0.0.i", i64 %129
  %139 = load i64, ptr %138, align 4
  tail call void @___dec_future_refcount(i64 %139)
  br label %cond_exit_652.thread.i

cond_exit_652.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %__barray_check_bounds.exit224.i
  %exitcond.i = icmp eq i64 %128, 20
  br i1 %exitcond.i, label %cond_652_case_0.i, label %__barray_check_bounds.exit224.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.413.exit": ; preds = %124, %cond_652_case_0.i
  tail call void @heap_free(ptr %"649_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"649_1.sroa.5.0.i")
  %140 = load i64, ptr %53, align 4
  %141 = and i64 %140, 1048575
  store i64 %141, ptr %53, align 4
  %142 = icmp eq i64 %141, 0
  br i1 %142, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit624:                    ; preds = %__barray_check_bounds.exit221.i
  %143 = xor i64 %104, %100
  store i64 %143, ptr %95, align 4
  store i64 %103, ptr %102, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %103)
  tail call void @___dec_future_refcount(i64 %103)
  %144 = load i64, ptr %53, align 4
  %145 = lshr i64 %144, %"174_0.sroa.15.0675"
  %146 = trunc i64 %145 to i1
  br i1 %146, label %loop_body254, label %panic.i625

panic.i625:                                       ; preds = %__barray_check_bounds.exit624
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body254:                                     ; preds = %__barray_check_bounds.exit624
  %147 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn663674, i64 %92, 1
  %148 = shl nuw nsw i64 1, %"174_0.sroa.15.0675"
  %149 = xor i64 %144, %148
  store i64 %149, ptr %53, align 4
  %150 = getelementptr inbounds nuw i1, ptr %52, i64 %"174_0.sroa.15.0675"
  store i1 %read_bool, ptr %150, align 1
  %151 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn663674, 0
  %exitcond677.not = icmp eq i64 %92, 20
  br i1 %exitcond677.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i621

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.413.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.413.exit"
  %152 = tail call ptr @heap_alloc(i64 20)
  %153 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %153, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %152, ptr noundef nonnull align 1 dereferenceable(20) %52, i64 20, i1 false)
  tail call void @heap_free(ptr nonnull %152)
  %154 = load i64, ptr %53, align 4
  %155 = and i64 %154, 1048575
  store i64 %155, ptr %53, align 4
  %156 = icmp eq i64 %155, 0
  br i1 %156, label %__barray_check_none_borrowed.exit628, label %mask_block_err.i627

mask_block_err.i627:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit628:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %157 = alloca [20 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %157, i8 0, i64 20, i1 false)
  store i32 20, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %52, ptr %arr_ptr, align 8
  store ptr %157, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_tail.AD5A440E.0, i64 17, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure_leaked(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare i64 @___read_future_uint(i64) local_unnamed_addr

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
