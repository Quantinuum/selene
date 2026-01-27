; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@e_Option.unw.32D4E82D.0 = private constant [43 x i8] c"*EXIT:INT:Option.unwrap: value is `Nothing`"
@res_head_leake.F4F32972.0 = private constant [21 x i8] c"\14USER:INT:head_leaked"
@res_head.AFE8E005.0 = private constant [15 x i8] c"\0EUSER:BOOL:head"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@res_tail.AD5A440E.0 = private constant [18 x i8] c"\11USER:BOOLARR:tail"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define internal fastcc void @__hugr__.__main__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 160)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_397_case_0.i, label %__hugr__.__tk2_qalloc.402.exit

cond_397_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.402.exit:                   ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18)
  br label %cond_21_case_1

2:                                                ; preds = %cond_185_case_0, %90
  %"165_0280.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"165_0280.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"165_0280.fca.0.insert", ptr %1, 1
  %"165_0280.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"165_0280.fca.1.insert", i64 0, 2
  %3 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"165_0280.fca.2.insert", 0
  %4 = tail call ptr @heap_alloc(i64 480)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  br label %__barray_check_bounds.exit.i.i

6:                                                ; preds = %loop_body.i
  %7 = lshr i64 %.fca.2.extract82.i.i, 6
  %8 = getelementptr i64, ptr %.fca.1.extract81.i.i, i64 %7
  %9 = load i64, ptr %8, align 4
  %10 = and i64 %.fca.2.extract82.i.i, 63
  %11 = sub nuw nsw i64 64, %10
  %12 = lshr i64 -1, %11
  %13 = icmp eq i64 %10, 0
  %14 = select i1 %13, i64 0, i64 %12
  %15 = or i64 %9, %14
  store i64 %15, ptr %8, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract82.i.i, 19
  %16 = lshr i64 %last_valid.i.i.i, 6
  %17 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i.i, i64 %16
  %18 = load i64, ptr %17, align 4
  %19 = and i64 %last_valid.i.i.i, 63
  %20 = shl nsw i64 -2, %19
  %21 = icmp eq i64 %19, 63
  %22 = select i1 %21, i64 0, i64 %20
  %23 = or i64 %18, %22
  store i64 %23, ptr %17, align 4
  %reass.sub.i.i.i = sub nsw i64 %16, %7
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(20).480.exit", label %mask_block_ok.i.i.i

24:                                               ; preds = %mask_block_ok.i.i.i
  %25 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(20).480.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %6, %24
  %.02.i.i.i = phi i64 [ %25, %24 ], [ 0, %6 ]
  %gep.i.i.i = getelementptr i64, ptr %8, i64 %.02.i.i.i
  %26 = load i64, ptr %gep.i.i.i, align 4
  %27 = icmp eq i64 %26, -1
  br i1 %27, label %24, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %2
  %.fca.2.extract82.i187.i = phi i64 [ 0, %2 ], [ %.fca.2.extract82.i.i, %loop_body.i ]
  %.fca.1.extract81.i186.i = phi ptr [ %1, %2 ], [ %.fca.1.extract81.i.i, %loop_body.i ]
  %.fca.0.extract80.i185.i = phi ptr [ %0, %2 ], [ %.fca.0.extract80.i.i, %loop_body.i ]
  %"506_0.sroa.15.0184.i" = phi i64 [ 0, %2 ], [ %28, %loop_body.i ]
  %.pn165183.i = phi { { ptr, ptr, i64 }, i64 } [ %3, %2 ], [ %43, %loop_body.i ]
  %28 = add nuw nsw i64 %"506_0.sroa.15.0184.i", 1
  %29 = add i64 %"506_0.sroa.15.0184.i", %.fca.2.extract82.i187.i
  %30 = lshr i64 %29, 6
  %31 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i186.i, i64 %30
  %32 = load i64, ptr %31, align 4
  %33 = and i64 %29, 63
  %34 = lshr i64 %32, %33
  %35 = trunc i64 %34 to i1
  br i1 %35, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %36 = shl nuw i64 1, %33
  %37 = xor i64 %36, %32
  store i64 %37, ptr %31, align 4
  %38 = getelementptr inbounds i64, ptr %.fca.0.extract80.i185.i, i64 %29
  %39 = load i64, ptr %38, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %39)
  tail call void @___qfree(i64 %39)
  %40 = load i64, ptr %5, align 4
  %41 = lshr i64 %40, %"506_0.sroa.15.0184.i"
  %42 = trunc i64 %41 to i1
  br i1 %42, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"571_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"571_054.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"571_054.fca.1.insert.i", i1 undef, 2
  %43 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, i64 %28, 1
  %44 = shl nuw nsw i64 1, %"506_0.sroa.15.0184.i"
  %45 = xor i64 %40, %44
  store i64 %45, ptr %5, align 4
  %46 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %4, i64 %"506_0.sroa.15.0184.i"
  store { i1, i64, i1 } %"571_054.fca.2.insert.i", ptr %46, align 4
  %47 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %47, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %47, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %47, 2
  %exitcond.not.i = icmp eq i64 %28, 20
  br i1 %exitcond.not.i, label %6, label %__barray_check_bounds.exit.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(20).480.exit": ; preds = %24, %6
  tail call void @heap_free(ptr %.fca.0.extract80.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract81.i.i)
  %48 = tail call ptr @heap_alloc(i64 640)
  %49 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %49, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(640) %48, i8 0, i64 640, i1 false)
  %50 = load i64, ptr %5, align 4
  %51 = and i64 %50, 1048575
  store i64 %51, ptr %5, align 4
  %52 = icmp eq i64 %51, 0
  br i1 %52, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

cond_21_case_1:                                   ; preds = %__hugr__.__tk2_qalloc.402.exit, %cond_exit_21
  %"16_0.sroa.0.0704" = phi i64 [ 0, %__hugr__.__tk2_qalloc.402.exit ], [ %53, %cond_exit_21 ]
  %53 = add nuw nsw i64 %"16_0.sroa.0.0704", 1
  %qalloc.i634 = tail call i64 @___qalloc()
  %not_max.not.not.i635 = icmp eq i64 %qalloc.i634, -1
  br i1 %not_max.not.not.i635, label %cond_356_case_0.i, label %__barray_check_bounds.exit

cond_356_case_0.i:                                ; preds = %cond_21_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_21_case_1
  tail call void @___reset(i64 %qalloc.i634)
  %54 = load i64, ptr %1, align 4
  %55 = lshr i64 %54, %"16_0.sroa.0.0704"
  %56 = trunc i64 %55 to i1
  br i1 %56, label %cond_exit_21, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_21:                                     ; preds = %__barray_check_bounds.exit
  %57 = shl nuw nsw i64 1, %"16_0.sroa.0.0704"
  %58 = xor i64 %54, %57
  store i64 %58, ptr %1, align 4
  %59 = getelementptr inbounds nuw i64, ptr %0, i64 %"16_0.sroa.0.0704"
  store i64 %qalloc.i634, ptr %59, align 4
  %exitcond.not = icmp eq i64 %53, 20
  br i1 %exitcond.not, label %loop_out, label %cond_21_case_1

loop_out:                                         ; preds = %cond_exit_21
  %60 = load i64, ptr %1, align 4
  %61 = trunc i64 %60 to i1
  br i1 %61, label %panic.i636, label %__barray_mask_borrow.exit

panic.i636:                                       ; preds = %loop_out
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %loop_out
  %62 = or disjoint i64 %60, 1
  store i64 %62, ptr %1, align 4
  %63 = load i64, ptr %0, align 4
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i, i64 %63, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %63, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  %64 = load i64, ptr %1, align 4
  %65 = trunc i64 %64 to i1
  br i1 %65, label %__barray_mask_return.exit638, label %panic.i637

panic.i637:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit638:                     ; preds = %__barray_mask_borrow.exit
  %66 = and i64 %64, -2
  store i64 %66, ptr %1, align 4
  store i64 %63, ptr %0, align 4
  br label %__barray_check_bounds.exit640

__barray_check_bounds.exit640:                    ; preds = %__barray_mask_return.exit656, %__barray_mask_return.exit638
  %"57_0.0705" = phi i64 [ 0, %__barray_mask_return.exit638 ], [ %67, %__barray_mask_return.exit656 ]
  %67 = add nuw nsw i64 %"57_0.0705", 1
  %68 = load i64, ptr %1, align 4
  %69 = lshr i64 %68, %"57_0.0705"
  %70 = trunc i64 %69 to i1
  br i1 %70, label %panic.i641, label %__barray_mask_borrow.exit642

panic.i641:                                       ; preds = %__barray_check_bounds.exit640
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit642:                     ; preds = %__barray_check_bounds.exit640
  %71 = shl nuw nsw i64 1, %"57_0.0705"
  %72 = xor i64 %68, %71
  store i64 %72, ptr %1, align 4
  %73 = getelementptr inbounds nuw i64, ptr %0, i64 %"57_0.0705"
  %74 = load i64, ptr %73, align 4
  %75 = lshr i64 %72, %67
  %76 = trunc i64 %75 to i1
  br i1 %76, label %panic.i645, label %__barray_check_bounds.exit650

panic.i645:                                       ; preds = %__barray_mask_borrow.exit642
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit650:                    ; preds = %__barray_mask_borrow.exit642
  %77 = shl nuw nsw i64 2, %"57_0.0705"
  %78 = xor i64 %72, %77
  store i64 %78, ptr %1, align 4
  %79 = getelementptr inbounds nuw i64, ptr %0, i64 %67
  %80 = load i64, ptr %79, align 4
  tail call void @___rp(i64 %74, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %74, i64 %80, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %74, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %74, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %80, double 0xBFF921FB54442D18, double 0.000000e+00)
  %81 = load i64, ptr %1, align 4
  %82 = lshr i64 %81, %"57_0.0705"
  %83 = trunc i64 %82 to i1
  br i1 %83, label %__barray_check_bounds.exit654, label %panic.i651

panic.i651:                                       ; preds = %__barray_check_bounds.exit650
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit654:                    ; preds = %__barray_check_bounds.exit650
  %84 = xor i64 %81, %71
  store i64 %84, ptr %1, align 4
  store i64 %74, ptr %73, align 4
  %85 = load i64, ptr %1, align 4
  %86 = lshr i64 %85, %67
  %87 = trunc i64 %86 to i1
  br i1 %87, label %__barray_mask_return.exit656, label %panic.i655

panic.i655:                                       ; preds = %__barray_check_bounds.exit654
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit656:                     ; preds = %__barray_check_bounds.exit654
  %88 = xor i64 %85, %77
  store i64 %88, ptr %1, align 4
  store i64 %80, ptr %79, align 4
  %exitcond713.not = icmp eq i64 %67, 19
  br i1 %exitcond713.not, label %cond_exit_91, label %__barray_check_bounds.exit640

89:                                               ; preds = %cond_exit_91
  %read_uint.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %.not = icmp eq i64 %read_uint.i, 2
  br i1 %.not, label %cond_150_case_0, label %cond_185_case_0

90:                                               ; preds = %cond_exit_91
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  tail call void @print_int(ptr nonnull @res_head_leake.F4F32972.0, i64 20, i64 1)
  br label %2

cond_exit_91:                                     ; preds = %__barray_mask_return.exit656
  %lazy_measure_leaked.i = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___inc_future_refcount(i64 %lazy_measure_leaked.i)
  %read_uint.i657 = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %91 = icmp eq i64 %read_uint.i657, 2
  br i1 %91, label %90, label %89

cond_150_case_0:                                  ; preds = %89
  tail call void @panic(i32 1001, ptr nonnull @e_Option.unw.32D4E82D.0)
  unreachable

cond_185_case_0:                                  ; preds = %89
  %92 = icmp eq i64 %read_uint.i, 1
  tail call void @print_bool(ptr nonnull @res_head.AFE8E005.0, i64 14, i1 %92)
  br label %2

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(20).480.exit"
  %93 = tail call ptr @heap_alloc(i64 480)
  %94 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %94, align 1
  br label %95

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(20).480.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

95:                                               ; preds = %__barray_check_none_borrowed.exit, %"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).590.exit"
  %storemerge593710 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %103, %"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).590.exit" ]
  %96 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %4, i64 %storemerge593710
  %97 = load { i1, i64, i1 }, ptr %96, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %97, 0
  br i1 %.fca.0.extract118.i, label %cond_594_case_1.i, label %cond_594_case_0.i

cond_594_case_0.i:                                ; preds = %95
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %97, 2
  br label %cond_exit_594.i

cond_594_case_1.i:                                ; preds = %95
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %97, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_594.i

cond_exit_594.i:                                  ; preds = %cond_594_case_0.i, %cond_594_case_1.i
  %"04.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_594_case_1.i ], [ undef, %cond_594_case_0.i ]
  %"04.sroa.6.0.i" = phi i1 [ undef, %cond_594_case_1.i ], [ %.fca.2.extract120.i, %cond_594_case_0.i ]
  %98 = load i64, ptr %49, align 4
  %99 = lshr i64 %98, %storemerge593710
  %100 = trunc i64 %99 to i1
  br i1 %100, label %panic.i.i661, label %cond_597_case_1.i

panic.i.i661:                                     ; preds = %cond_exit_594.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_597_case_1.i:                                ; preds = %cond_exit_594.i
  %"17.fca.1.insert.i" = insertvalue { i1, i64, i1 } %97, i64 %"04.sroa.3.0.i", 1
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"17.fca.1.insert.i", i1 %"04.sroa.6.0.i", 2
  %101 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %102 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %48, i64 %storemerge593710
  %.fca.2.0.extract.i = load i1, ptr %102, align 1
  store { i1, { i1, i64, i1 } } %101, ptr %102, align 4
  br i1 %.fca.2.0.extract.i, label %cond_598_case_1.i, label %"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).590.exit"

cond_598_case_1.i:                                ; preds = %cond_597_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).590.exit": ; preds = %cond_597_case_1.i
  %103 = add nuw nsw i64 %storemerge593710, 1
  %104 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %93, i64 %storemerge593710
  store { i1, i64, i1 } %"17.fca.2.insert.i", ptr %104, align 4
  %exitcond714.not = icmp eq i64 %103, 20
  br i1 %exitcond714.not, label %mask_block_ok.i662, label %95

mask_block_ok.i662:                               ; preds = %"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).590.exit"
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  %105 = load i64, ptr %49, align 4
  %106 = and i64 %105, 1048575
  store i64 %106, ptr %49, align 4
  %107 = icmp eq i64 %106, 0
  br i1 %107, label %__barray_check_none_borrowed.exit667, label %mask_block_err.i665

__barray_check_none_borrowed.exit667:             ; preds = %mask_block_ok.i662
  %108 = tail call ptr @heap_alloc(i64 480)
  %109 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %109, align 1
  br label %110

mask_block_err.i665:                              ; preds = %mask_block_ok.i662
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

110:                                              ; preds = %__barray_check_none_borrowed.exit667, %110
  %storemerge598711 = phi i64 [ 0, %__barray_check_none_borrowed.exit667 ], [ %116, %110 ]
  %111 = getelementptr { i1, { i1, i64, i1 } }, ptr %48, i64 %storemerge598711
  %112 = load { i1, { i1, i64, i1 } }, ptr %111, align 4
  %113 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).636"({ i1, { i1, i64, i1 } } %112)
  %114 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %108, i64 %storemerge598711
  %115 = extractvalue { { i1, i64, i1 } } %113, 0
  store { i1, i64, i1 } %115, ptr %114, align 4
  %116 = add nuw nsw i64 %storemerge598711, 1
  %exitcond715.not = icmp eq i64 %116, 20
  br i1 %exitcond715.not, label %117, label %110

117:                                              ; preds = %110
  tail call void @heap_free(ptr nonnull %48)
  tail call void @heap_free(ptr nonnull %49)
  br label %__barray_check_bounds.exit674

cond_727_case_0:                                  ; preds = %cond_exit_727
  %118 = load i64, ptr %109, align 4
  %119 = or i64 %118, -1048576
  store i64 %119, ptr %109, align 4
  %120 = icmp eq i64 %119, -1
  br i1 %120, label %loop_out304, label %mask_block_err.i671

mask_block_err.i671:                              ; preds = %cond_727_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit674:                    ; preds = %117, %cond_exit_727
  %"724_0.0718" = phi i64 [ 0, %117 ], [ %121, %cond_exit_727 ]
  %121 = add nuw nsw i64 %"724_0.0718", 1
  %122 = load i64, ptr %109, align 4
  %123 = lshr i64 %122, %"724_0.0718"
  %124 = trunc i64 %123 to i1
  br i1 %124, label %cond_exit_727, label %__barray_mask_borrow.exit678

__barray_mask_borrow.exit678:                     ; preds = %__barray_check_bounds.exit674
  %125 = shl nuw nsw i64 1, %"724_0.0718"
  %126 = xor i64 %122, %125
  store i64 %126, ptr %109, align 4
  %127 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %108, i64 %"724_0.0718"
  %128 = load { i1, i64, i1 }, ptr %127, align 4
  %.fca.0.extract392 = extractvalue { i1, i64, i1 } %128, 0
  br i1 %.fca.0.extract392, label %cond_750_case_1, label %cond_exit_727

cond_exit_727:                                    ; preds = %cond_750_case_1, %__barray_mask_borrow.exit678, %__barray_check_bounds.exit674
  %129 = icmp samesign ugt i64 %"724_0.0718", 18
  br i1 %129, label %cond_727_case_0, label %__barray_check_bounds.exit674

loop_out304:                                      ; preds = %cond_727_case_0
  tail call void @heap_free(ptr %108)
  tail call void @heap_free(ptr nonnull %109)
  %130 = load i64, ptr %94, align 4
  %131 = and i64 %130, 1048575
  store i64 %131, ptr %94, align 4
  %132 = icmp eq i64 %131, 0
  br i1 %132, label %__barray_check_none_borrowed.exit684, label %mask_block_err.i682

__barray_check_none_borrowed.exit684:             ; preds = %loop_out304
  %133 = tail call ptr @heap_alloc(i64 20)
  %134 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %134, align 1
  %135 = load { i1, i64, i1 }, ptr %93, align 4
  %136 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %135)
  %137 = extractvalue { i1 } %136, 0
  store i1 %137, ptr %133, align 1
  %138 = getelementptr inbounds nuw i8, ptr %93, i64 24
  %139 = load { i1, i64, i1 }, ptr %138, align 4
  %140 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %139)
  %141 = getelementptr inbounds nuw i8, ptr %133, i64 1
  %142 = extractvalue { i1 } %140, 0
  store i1 %142, ptr %141, align 1
  %143 = getelementptr inbounds nuw i8, ptr %93, i64 48
  %144 = load { i1, i64, i1 }, ptr %143, align 4
  %145 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %144)
  %146 = getelementptr inbounds nuw i8, ptr %133, i64 2
  %147 = extractvalue { i1 } %145, 0
  store i1 %147, ptr %146, align 1
  %148 = getelementptr inbounds nuw i8, ptr %93, i64 72
  %149 = load { i1, i64, i1 }, ptr %148, align 4
  %150 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %149)
  %151 = getelementptr inbounds nuw i8, ptr %133, i64 3
  %152 = extractvalue { i1 } %150, 0
  store i1 %152, ptr %151, align 1
  %153 = getelementptr inbounds nuw i8, ptr %93, i64 96
  %154 = load { i1, i64, i1 }, ptr %153, align 4
  %155 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %154)
  %156 = getelementptr inbounds nuw i8, ptr %133, i64 4
  %157 = extractvalue { i1 } %155, 0
  store i1 %157, ptr %156, align 1
  %158 = getelementptr inbounds nuw i8, ptr %93, i64 120
  %159 = load { i1, i64, i1 }, ptr %158, align 4
  %160 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %159)
  %161 = getelementptr inbounds nuw i8, ptr %133, i64 5
  %162 = extractvalue { i1 } %160, 0
  store i1 %162, ptr %161, align 1
  %163 = getelementptr inbounds nuw i8, ptr %93, i64 144
  %164 = load { i1, i64, i1 }, ptr %163, align 4
  %165 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %164)
  %166 = getelementptr inbounds nuw i8, ptr %133, i64 6
  %167 = extractvalue { i1 } %165, 0
  store i1 %167, ptr %166, align 1
  %168 = getelementptr inbounds nuw i8, ptr %93, i64 168
  %169 = load { i1, i64, i1 }, ptr %168, align 4
  %170 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %169)
  %171 = getelementptr inbounds nuw i8, ptr %133, i64 7
  %172 = extractvalue { i1 } %170, 0
  store i1 %172, ptr %171, align 1
  %173 = getelementptr inbounds nuw i8, ptr %93, i64 192
  %174 = load { i1, i64, i1 }, ptr %173, align 4
  %175 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %174)
  %176 = getelementptr inbounds nuw i8, ptr %133, i64 8
  %177 = extractvalue { i1 } %175, 0
  store i1 %177, ptr %176, align 1
  %178 = getelementptr inbounds nuw i8, ptr %93, i64 216
  %179 = load { i1, i64, i1 }, ptr %178, align 4
  %180 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %179)
  %181 = getelementptr inbounds nuw i8, ptr %133, i64 9
  %182 = extractvalue { i1 } %180, 0
  store i1 %182, ptr %181, align 1
  %183 = getelementptr inbounds nuw i8, ptr %93, i64 240
  %184 = load { i1, i64, i1 }, ptr %183, align 4
  %185 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %184)
  %186 = getelementptr inbounds nuw i8, ptr %133, i64 10
  %187 = extractvalue { i1 } %185, 0
  store i1 %187, ptr %186, align 1
  %188 = getelementptr inbounds nuw i8, ptr %93, i64 264
  %189 = load { i1, i64, i1 }, ptr %188, align 4
  %190 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %189)
  %191 = getelementptr inbounds nuw i8, ptr %133, i64 11
  %192 = extractvalue { i1 } %190, 0
  store i1 %192, ptr %191, align 1
  %193 = getelementptr inbounds nuw i8, ptr %93, i64 288
  %194 = load { i1, i64, i1 }, ptr %193, align 4
  %195 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %194)
  %196 = getelementptr inbounds nuw i8, ptr %133, i64 12
  %197 = extractvalue { i1 } %195, 0
  store i1 %197, ptr %196, align 1
  %198 = getelementptr inbounds nuw i8, ptr %93, i64 312
  %199 = load { i1, i64, i1 }, ptr %198, align 4
  %200 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %199)
  %201 = getelementptr inbounds nuw i8, ptr %133, i64 13
  %202 = extractvalue { i1 } %200, 0
  store i1 %202, ptr %201, align 1
  %203 = getelementptr inbounds nuw i8, ptr %93, i64 336
  %204 = load { i1, i64, i1 }, ptr %203, align 4
  %205 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %204)
  %206 = getelementptr inbounds nuw i8, ptr %133, i64 14
  %207 = extractvalue { i1 } %205, 0
  store i1 %207, ptr %206, align 1
  %208 = getelementptr inbounds nuw i8, ptr %93, i64 360
  %209 = load { i1, i64, i1 }, ptr %208, align 4
  %210 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %209)
  %211 = getelementptr inbounds nuw i8, ptr %133, i64 15
  %212 = extractvalue { i1 } %210, 0
  store i1 %212, ptr %211, align 1
  %213 = getelementptr inbounds nuw i8, ptr %93, i64 384
  %214 = load { i1, i64, i1 }, ptr %213, align 4
  %215 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %214)
  %216 = getelementptr inbounds nuw i8, ptr %133, i64 16
  %217 = extractvalue { i1 } %215, 0
  store i1 %217, ptr %216, align 1
  %218 = getelementptr inbounds nuw i8, ptr %93, i64 408
  %219 = load { i1, i64, i1 }, ptr %218, align 4
  %220 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %219)
  %221 = getelementptr inbounds nuw i8, ptr %133, i64 17
  %222 = extractvalue { i1 } %220, 0
  store i1 %222, ptr %221, align 1
  %223 = getelementptr inbounds nuw i8, ptr %93, i64 432
  %224 = load { i1, i64, i1 }, ptr %223, align 4
  %225 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %224)
  %226 = getelementptr inbounds nuw i8, ptr %133, i64 18
  %227 = extractvalue { i1 } %225, 0
  store i1 %227, ptr %226, align 1
  %228 = getelementptr inbounds nuw i8, ptr %93, i64 456
  %229 = load { i1, i64, i1 }, ptr %228, align 4
  %230 = tail call { i1 } @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %229)
  %231 = getelementptr inbounds nuw i8, ptr %133, i64 19
  %232 = extractvalue { i1 } %230, 0
  store i1 %232, ptr %231, align 1
  tail call void @heap_free(ptr nonnull %93)
  tail call void @heap_free(ptr nonnull %94)
  %233 = load i64, ptr %134, align 4
  %234 = and i64 %233, 1048575
  store i64 %234, ptr %134, align 4
  %235 = icmp eq i64 %234, 0
  br i1 %235, label %__barray_check_none_borrowed.exit690, label %mask_block_err.i688

mask_block_err.i682:                              ; preds = %loop_out304
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_750_case_1:                                  ; preds = %__barray_mask_borrow.exit678
  %.fca.1.extract393 = extractvalue { i1, i64, i1 } %128, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract393)
  br label %cond_exit_727

__barray_check_none_borrowed.exit690:             ; preds = %__barray_check_none_borrowed.exit684
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %236 = alloca [20 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %236, i8 0, i64 20, i1 false)
  store i32 20, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %133, ptr %arr_ptr, align 8
  store ptr %236, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_tail.AD5A440E.0, i64 17, ptr nonnull %out_arr_alloca)
  ret void

mask_block_err.i688:                              ; preds = %__barray_check_none_borrowed.exit684
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

define internal i1 @__hugr__.array.__read_bool.3.364({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_347_case_1, label %cond_347_case_0

cond_347_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_347

cond_347_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_347

cond_exit_347:                                    ; preds = %cond_347_case_1, %cond_347_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_347_case_1 ], [ %.fca.2.extract, %cond_347_case_0 ]
  ret i1 %"03.0"
}

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
  tail call fastcc void @__hugr__.__main__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #1 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
