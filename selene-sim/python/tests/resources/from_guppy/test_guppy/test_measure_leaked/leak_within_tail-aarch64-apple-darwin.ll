; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-apple-darwin"

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

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call i8* @heap_alloc(i64 160)
  %1 = bitcast i8* %0 to i64*
  %2 = tail call i8* @heap_alloc(i64 8)
  %3 = bitcast i8* %2 to i64*
  store i64 -1, i64* %3, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.i, label %id_bb.i, label %reset_bb.i

reset_bb.i:                                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %alloca_block
  %4 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %5 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %4
  %.fca.0.extract.i = extractvalue { i1, i64 } %5, 0
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.400.exit, label %cond_395_case_0.i

cond_395_case_0.i:                                ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.400.exit:                   ; preds = %id_bb.i
  %.fca.1.extract.i = extractvalue { i1, i64 } %5, 1
  tail call void @___rxy(i64 %.fca.1.extract.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0x400921FB54442D18)
  br label %cond_21_case_1

__barray_check_bounds.exit:                       ; preds = %__barray_mask_return.exit657, %__barray_mask_return.exit684
  %"57_0.0735" = phi i64 [ 0, %__barray_mask_return.exit684 ], [ %6, %__barray_mask_return.exit657 ]
  %6 = add nuw nsw i64 %"57_0.0735", 1
  %7 = lshr i64 %"57_0.0735", 6
  %8 = getelementptr inbounds i64, i64* %3, i64 %7
  %9 = load i64, i64* %8, align 4
  %10 = shl nuw nsw i64 1, %"57_0.0735"
  %11 = and i64 %9, %10
  %.not.i = icmp eq i64 %11, 0
  br i1 %.not.i, label %__barray_check_bounds.exit645, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit645:                    ; preds = %__barray_check_bounds.exit
  %12 = xor i64 %9, %10
  store i64 %12, i64* %8, align 4
  %13 = getelementptr inbounds i64, i64* %1, i64 %"57_0.0735"
  %14 = load i64, i64* %13, align 4
  %15 = lshr i64 %6, 6
  %16 = getelementptr inbounds i64, i64* %3, i64 %15
  %17 = load i64, i64* %16, align 4
  %18 = shl i64 2, %"57_0.0735"
  %19 = and i64 %17, %18
  %.not.i646 = icmp eq i64 %19, 0
  br i1 %.not.i646, label %__barray_check_bounds.exit650, label %panic.i647

panic.i647:                                       ; preds = %__barray_check_bounds.exit645
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit650:                    ; preds = %__barray_check_bounds.exit645
  %20 = xor i64 %17, %18
  store i64 %20, i64* %16, align 4
  %21 = getelementptr inbounds i64, i64* %1, i64 %6
  %22 = load i64, i64* %21, align 4
  tail call void @___rxy(i64 %22, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %14, i64 %22, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %14, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %22, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %22, double 0xBFF921FB54442D18)
  %23 = load i64, i64* %8, align 4
  %24 = and i64 %23, %10
  %.not.i651 = icmp eq i64 %24, 0
  br i1 %.not.i651, label %panic.i652, label %__barray_check_bounds.exit654

panic.i652:                                       ; preds = %__barray_check_bounds.exit650
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit654:                    ; preds = %__barray_check_bounds.exit650
  %25 = xor i64 %23, %10
  store i64 %25, i64* %8, align 4
  store i64 %14, i64* %13, align 4
  %26 = load i64, i64* %16, align 4
  %27 = and i64 %26, %18
  %.not.i655 = icmp eq i64 %27, 0
  br i1 %.not.i655, label %panic.i656, label %__barray_mask_return.exit657

panic.i656:                                       ; preds = %__barray_check_bounds.exit654
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit657:                     ; preds = %__barray_check_bounds.exit654
  %28 = xor i64 %26, %18
  store i64 %28, i64* %16, align 4
  store i64 %22, i64* %21, align 4
  %exitcond749.not = icmp eq i64 %6, 19
  br i1 %exitcond749.not, label %cond_exit_91, label %__barray_check_bounds.exit

29:                                               ; preds = %cond_340_case_0, %76
  %30 = tail call i8* @heap_alloc(i64 480)
  %31 = bitcast i8* %30 to { i1, i64, i1 }*
  %32 = tail call i8* @heap_alloc(i64 8)
  %33 = bitcast i8* %32 to i64*
  store i64 -1, i64* %33, align 1
  br label %43

mask_block_ok.i.i.i:                              ; preds = %cond_exit_552.i
  %34 = load i64, i64* %3, align 4
  %35 = or i64 %34, -1048576
  store i64 %35, i64* %3, align 4
  %36 = icmp eq i64 %35, -1
  br i1 %36, label %"__hugr__.$measure_array$$n(20).476.exit", label %mask_block_err.i.i.i

"__hugr__.$measure_array$$n(20).476.exit":        ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %37 = tail call i8* @heap_alloc(i64 640)
  %38 = tail call i8* @heap_alloc(i64 8)
  %39 = bitcast i8* %38 to i64*
  store i64 0, i64* %39, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(640) %37, i8 0, i64 640, i1 false)
  %40 = load i64, i64* %33, align 4
  %41 = and i64 %40, 1048575
  store i64 %41, i64* %33, align 4
  %42 = icmp eq i64 %41, 0
  br i1 %42, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

43:                                               ; preds = %29, %cond_exit_552.i
  %"502_0.sroa.15.0.i737" = phi i64 [ 0, %29 ], [ %44, %cond_exit_552.i ]
  %44 = add nuw nsw i64 %"502_0.sroa.15.0.i737", 1
  %45 = lshr i64 %"502_0.sroa.15.0.i737", 6
  %46 = getelementptr inbounds i64, i64* %3, i64 %45
  %47 = load i64, i64* %46, align 4
  %48 = shl nuw nsw i64 1, %"502_0.sroa.15.0.i737"
  %49 = and i64 %47, %48
  %.not.i99.i.i = icmp eq i64 %49, 0
  br i1 %.not.i99.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %43
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %43
  %50 = xor i64 %47, %48
  store i64 %50, i64* %46, align 4
  %51 = getelementptr inbounds i64, i64* %1, i64 %"502_0.sroa.15.0.i737"
  %52 = load i64, i64* %51, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %52)
  tail call void @___qfree(i64 %52)
  %53 = getelementptr inbounds i64, i64* %33, i64 %45
  %54 = load i64, i64* %53, align 4
  %55 = and i64 %54, %48
  %.not.i.i = icmp eq i64 %55, 0
  br i1 %.not.i.i, label %panic.i.i, label %cond_exit_552.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_552.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"566_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %56 = xor i64 %54, %48
  store i64 %56, i64* %53, align 4
  %57 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %31, i64 %"502_0.sroa.15.0.i737"
  store { i1, i64, i1 } %"566_054.fca.1.insert.i", { i1, i64, i1 }* %57, align 4
  %exitcond750.not = icmp eq i64 %44, 20
  br i1 %exitcond750.not, label %mask_block_ok.i.i.i, label %43

cond_21_case_1:                                   ; preds = %__hugr__.__tk2_qalloc.400.exit, %cond_exit_21
  %"16_0.sroa.0.0734" = phi i64 [ 0, %__hugr__.__tk2_qalloc.400.exit ], [ %58, %cond_exit_21 ]
  %58 = add nuw nsw i64 %"16_0.sroa.0.0734", 1
  %qalloc.i664 = tail call i64 @___qalloc()
  %not_max.not.i665 = icmp eq i64 %qalloc.i664, -1
  br i1 %not_max.not.i665, label %id_bb.i668, label %reset_bb.i666

reset_bb.i666:                                    ; preds = %cond_21_case_1
  tail call void @___reset(i64 %qalloc.i664)
  br label %id_bb.i668

id_bb.i668:                                       ; preds = %reset_bb.i666, %cond_21_case_1
  %59 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i664, 1
  %60 = select i1 %not_max.not.i665, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %59
  %.fca.0.extract.i667 = extractvalue { i1, i64 } %60, 0
  br i1 %.fca.0.extract.i667, label %__barray_check_bounds.exit673, label %cond_395_case_0.i670

cond_395_case_0.i670:                             ; preds = %id_bb.i668
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit673:                    ; preds = %id_bb.i668
  %61 = lshr i64 %"16_0.sroa.0.0734", 6
  %62 = getelementptr inbounds i64, i64* %3, i64 %61
  %63 = load i64, i64* %62, align 4
  %64 = shl nuw nsw i64 1, %"16_0.sroa.0.0734"
  %65 = and i64 %63, %64
  %.not.i674 = icmp eq i64 %65, 0
  br i1 %.not.i674, label %panic.i675, label %cond_exit_21

panic.i675:                                       ; preds = %__barray_check_bounds.exit673
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_21:                                     ; preds = %__barray_check_bounds.exit673
  %.fca.1.extract.i669 = extractvalue { i1, i64 } %60, 1
  %66 = xor i64 %63, %64
  store i64 %66, i64* %62, align 4
  %67 = getelementptr inbounds i64, i64* %1, i64 %"16_0.sroa.0.0734"
  store i64 %.fca.1.extract.i669, i64* %67, align 4
  %exitcond.not = icmp eq i64 %58, 20
  br i1 %exitcond.not, label %loop_out, label %cond_21_case_1

loop_out:                                         ; preds = %cond_exit_21
  %68 = load i64, i64* %3, align 4
  %69 = and i64 %68, 1
  %.not.i677 = icmp eq i64 %69, 0
  br i1 %.not.i677, label %__barray_mask_borrow.exit679, label %panic.i678

panic.i678:                                       ; preds = %loop_out
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit679:                     ; preds = %loop_out
  %70 = xor i64 %68, 1
  store i64 %70, i64* %3, align 4
  %71 = load i64, i64* %1, align 4
  tail call void @___rxy(i64 %71, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i, i64 %71, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %71, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %71, double 0xBFF921FB54442D18)
  %72 = load i64, i64* %3, align 4
  %73 = and i64 %72, 1
  %.not.i682 = icmp eq i64 %73, 0
  br i1 %.not.i682, label %panic.i683, label %__barray_mask_return.exit684

panic.i683:                                       ; preds = %__barray_mask_borrow.exit679
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit684:                     ; preds = %__barray_mask_borrow.exit679
  %74 = xor i64 %72, 1
  store i64 %74, i64* %3, align 4
  store i64 %71, i64* %1, align 4
  br label %__barray_check_bounds.exit

75:                                               ; preds = %cond_exit_91
  %read_uint.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %.not = icmp eq i64 %read_uint.i, 2
  br i1 %.not, label %cond_150_case_0, label %cond_340_case_0

76:                                               ; preds = %cond_exit_91
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  tail call void @print_int(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @res_head_leake.F4F32972.0, i64 0, i64 0), i64 20, i64 1)
  br label %29

cond_exit_91:                                     ; preds = %__barray_mask_return.exit657
  %lazy_measure_leaked.i = tail call i64 @___lazy_measure_leaked(i64 %.fca.1.extract.i)
  tail call void @___qfree(i64 %.fca.1.extract.i)
  tail call void @___inc_future_refcount(i64 %lazy_measure_leaked.i)
  %read_uint.i685 = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %77 = icmp eq i64 %read_uint.i685, 2
  br i1 %77, label %76, label %75

cond_150_case_0:                                  ; preds = %75
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @e_Option.unw.32D4E82D.0, i64 0, i64 0))
  unreachable

cond_340_case_0:                                  ; preds = %75
  %78 = icmp eq i64 %read_uint.i, 1
  tail call void @print_bool(i8* getelementptr inbounds ([15 x i8], [15 x i8]* @res_head.AFE8E005.0, i64 0, i64 0), i64 14, i1 %78)
  br label %29

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$measure_array$$n(20).476.exit"
  %79 = tail call i8* @heap_alloc(i64 480)
  %80 = bitcast i8* %79 to { i1, i64, i1 }*
  %81 = tail call i8* @heap_alloc(i64 8)
  %82 = bitcast i8* %81 to i64*
  store i64 0, i64* %82, align 1
  %83 = bitcast i8* %37 to { i1, { i1, i64, i1 } }*
  br label %84

mask_block_err.i:                                 ; preds = %"__hugr__.$measure_array$$n(20).476.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

84:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_362.329.exit
  %storemerge642742 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %102, %__hugr__.const_fun_362.329.exit ]
  %85 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %100, %__hugr__.const_fun_362.329.exit ]
  %86 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %31, i64 %storemerge642742
  %87 = load { i1, i64, i1 }, { i1, i64, i1 }* %86, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %87, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %87, 1
  br i1 %.fca.0.extract118.i, label %cond_682_case_1.i, label %cond_exit_682.i

cond_682_case_1.i:                                ; preds = %84
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %88 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %cond_exit_682.i

cond_exit_682.i:                                  ; preds = %cond_682_case_1.i, %84
  %.pn.i = phi { i1, i64, i1 } [ %88, %cond_682_case_1.i ], [ %87, %84 ]
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %exitcond751.not = icmp eq i64 %storemerge642742, 20
  br i1 %exitcond751.not, label %cond_685_case_0.i, label %89

89:                                               ; preds = %cond_exit_682.i
  %90 = lshr i64 %85, 6
  %91 = getelementptr inbounds i64, i64* %39, i64 %90
  %92 = load i64, i64* %91, align 4
  %93 = and i64 %85, 63
  %94 = shl nuw i64 1, %93
  %95 = and i64 %92, %94
  %.not.i.i688 = icmp eq i64 %95, 0
  br i1 %.not.i.i688, label %cond_685_case_1.i, label %panic.i.i689

panic.i.i689:                                     ; preds = %89
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_685_case_0.i:                                ; preds = %cond_exit_682.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_685_case_1.i:                                ; preds = %89
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %87, i1 %"04.sroa.6.0.i", 2
  %96 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %97 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %83, i64 %85
  %98 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %97, i64 0, i32 0
  %99 = load i1, i1* %98, align 1
  store { i1, { i1, i64, i1 } } %96, { i1, { i1, i64, i1 } }* %97, align 4
  br i1 %99, label %cond_686_case_1.i, label %__hugr__.const_fun_362.329.exit

cond_686_case_1.i:                                ; preds = %cond_685_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_362.329.exit:                  ; preds = %cond_685_case_1.i
  %100 = add nuw nsw i64 %85, 1
  %101 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %80, i64 %storemerge642742
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %101, align 4
  %102 = add nuw nsw i64 %storemerge642742, 1
  %exitcond752.not = icmp eq i64 %102, 20
  br i1 %exitcond752.not, label %mask_block_ok.i694, label %84

mask_block_ok.i694:                               ; preds = %__hugr__.const_fun_362.329.exit
  tail call void @heap_free(i8* nonnull %30)
  tail call void @heap_free(i8* %32)
  %103 = load i64, i64* %39, align 4
  %104 = and i64 %103, 1048575
  store i64 %104, i64* %39, align 4
  %105 = icmp eq i64 %104, 0
  br i1 %105, label %__barray_check_none_borrowed.exit696, label %mask_block_err.i695

mask_block_err.i695:                              ; preds = %mask_block_ok.i694
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit696:             ; preds = %mask_block_ok.i694
  %106 = tail call i8* @heap_alloc(i64 480)
  %107 = bitcast i8* %106 to { i1, i64, i1 }*
  %108 = tail call i8* @heap_alloc(i64 8)
  %109 = bitcast i8* %108 to i64*
  store i64 0, i64* %109, align 1
  br label %110

110:                                              ; preds = %__barray_check_none_borrowed.exit696, %__hugr__.const_fun_322.362.exit
  %storemerge629743 = phi i64 [ 0, %__barray_check_none_borrowed.exit696 ], [ %115, %__hugr__.const_fun_322.362.exit ]
  %111 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %83, i64 %storemerge629743
  %112 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %111, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %112, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_322.362.exit, label %cond_727_case_0.i

cond_727_case_0.i:                                ; preds = %110
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_322.362.exit:                  ; preds = %110
  %113 = extractvalue { i1, { i1, i64, i1 } } %112, 1
  %114 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %107, i64 %storemerge629743
  store { i1, i64, i1 } %113, { i1, i64, i1 }* %114, align 4
  %115 = add nuw nsw i64 %storemerge629743, 1
  %exitcond753.not = icmp eq i64 %115, 20
  br i1 %exitcond753.not, label %116, label %110

116:                                              ; preds = %__hugr__.const_fun_322.362.exit
  tail call void @heap_free(i8* nonnull %37)
  tail call void @heap_free(i8* %38)
  br label %__barray_check_bounds.exit702

cond_641_case_0:                                  ; preds = %cond_exit_641
  %117 = load i64, i64* %109, align 4
  %118 = or i64 %117, -1048576
  store i64 %118, i64* %109, align 4
  %119 = icmp eq i64 %118, -1
  br i1 %119, label %loop_out312, label %mask_block_err.i700

mask_block_err.i700:                              ; preds = %cond_641_case_0
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit702:                    ; preds = %116, %cond_exit_641
  %"638_0.0756" = phi i64 [ 0, %116 ], [ %120, %cond_exit_641 ]
  %120 = add nuw nsw i64 %"638_0.0756", 1
  %121 = lshr i64 %"638_0.0756", 6
  %122 = getelementptr inbounds i64, i64* %109, i64 %121
  %123 = load i64, i64* %122, align 4
  %124 = shl nuw nsw i64 1, %"638_0.0756"
  %125 = and i64 %123, %124
  %.not732 = icmp eq i64 %125, 0
  br i1 %.not732, label %__barray_mask_borrow.exit707, label %cond_exit_641

__barray_mask_borrow.exit707:                     ; preds = %__barray_check_bounds.exit702
  %126 = xor i64 %123, %124
  store i64 %126, i64* %122, align 4
  %127 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %107, i64 %"638_0.0756"
  %128 = load { i1, i64, i1 }, { i1, i64, i1 }* %127, align 4
  %.fca.0.extract399 = extractvalue { i1, i64, i1 } %128, 0
  br i1 %.fca.0.extract399, label %cond_664_case_1, label %cond_exit_641

cond_exit_641:                                    ; preds = %cond_664_case_1, %__barray_mask_borrow.exit707, %__barray_check_bounds.exit702
  %129 = icmp ult i64 %"638_0.0756", 19
  br i1 %129, label %__barray_check_bounds.exit702, label %cond_641_case_0

loop_out312:                                      ; preds = %cond_641_case_0
  tail call void @heap_free(i8* %106)
  tail call void @heap_free(i8* nonnull %108)
  %130 = load i64, i64* %82, align 4
  %131 = and i64 %130, 1048575
  store i64 %131, i64* %82, align 4
  %132 = icmp eq i64 %131, 0
  br i1 %132, label %__barray_check_none_borrowed.exit712, label %mask_block_err.i711

__barray_check_none_borrowed.exit712:             ; preds = %loop_out312
  %133 = tail call i8* @heap_alloc(i64 20)
  %134 = tail call i8* @heap_alloc(i64 8)
  %135 = bitcast i8* %134 to i64*
  store i64 0, i64* %135, align 1
  br label %136

mask_block_err.i711:                              ; preds = %loop_out312
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_664_case_1:                                  ; preds = %__barray_mask_borrow.exit707
  %.fca.1.extract400 = extractvalue { i1, i64, i1 } %128, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract400)
  br label %cond_exit_641

136:                                              ; preds = %__barray_check_none_borrowed.exit712, %__hugr__.array.__read_bool.3.363.exit
  %storemerge744 = phi i64 [ 0, %__barray_check_none_borrowed.exit712 ], [ %141, %__hugr__.array.__read_bool.3.363.exit ]
  %137 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %80, i64 %storemerge744
  %138 = load { i1, i64, i1 }, { i1, i64, i1 }* %137, align 4
  %.fca.0.extract.i713 = extractvalue { i1, i64, i1 } %138, 0
  %.fca.1.extract.i714 = extractvalue { i1, i64, i1 } %138, 1
  br i1 %.fca.0.extract.i713, label %cond_374_case_1.i, label %cond_374_case_0.i

cond_374_case_0.i:                                ; preds = %136
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %138, 2
  br label %__hugr__.array.__read_bool.3.363.exit

cond_374_case_1.i:                                ; preds = %136
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i714)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i714)
  br label %__hugr__.array.__read_bool.3.363.exit

__hugr__.array.__read_bool.3.363.exit:            ; preds = %cond_374_case_0.i, %cond_374_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_374_case_1.i ], [ %.fca.2.extract.i, %cond_374_case_0.i ]
  %139 = getelementptr inbounds i8, i8* %133, i64 %storemerge744
  %140 = bitcast i8* %139 to i1*
  store i1 %"03.0.i", i1* %140, align 1
  %141 = add nuw nsw i64 %storemerge744, 1
  %exitcond754.not = icmp eq i64 %141, 20
  br i1 %exitcond754.not, label %mask_block_ok.i717, label %136

mask_block_ok.i717:                               ; preds = %__hugr__.array.__read_bool.3.363.exit
  tail call void @heap_free(i8* nonnull %79)
  tail call void @heap_free(i8* %81)
  %142 = load i64, i64* %135, align 4
  %143 = and i64 %142, 1048575
  store i64 %143, i64* %135, align 4
  %144 = icmp eq i64 %143, 0
  br i1 %144, label %__barray_check_none_borrowed.exit719, label %mask_block_err.i718

__barray_check_none_borrowed.exit719:             ; preds = %mask_block_ok.i717
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %145 = alloca [20 x i1], align 1
  %.sub = getelementptr inbounds [20 x i1], [20 x i1]* %145, i64 0, i64 0
  %146 = bitcast [20 x i1]* %145 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(20) %146, i8 0, i64 20, i1 false)
  store i32 20, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %147 = bitcast i1** %arr_ptr to i8**
  store i8* %133, i8** %147, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @res_tail.AD5A440E.0, i64 0, i64 0), i64 17, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  ret void

mask_block_err.i718:                              ; preds = %mask_block_ok.i717
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable
}

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_int(i8*, i64, i64) local_unnamed_addr

declare void @print_bool(i8*, i64, i1) local_unnamed_addr

declare void @heap_free(i8*) local_unnamed_addr

declare void @print_bool_arr(i8*, i64, <{ i32, i32, i1*, i1* }>*) local_unnamed_addr

declare i64 @___lazy_measure_leaked(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare i64 @___read_future_uint(i64) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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
