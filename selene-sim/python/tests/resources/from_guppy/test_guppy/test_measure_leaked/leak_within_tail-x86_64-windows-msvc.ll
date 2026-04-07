; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-msvc"

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
  %89 = icmp ult i64 %85, 20
  br i1 %89, label %90, label %cond_685_case_0.i

90:                                               ; preds = %cond_exit_682.i
  %91 = lshr i64 %85, 6
  %92 = getelementptr inbounds i64, i64* %39, i64 %91
  %93 = load i64, i64* %92, align 4
  %94 = shl nuw nsw i64 1, %85
  %95 = and i64 %93, %94
  %.not.i.i688 = icmp eq i64 %95, 0
  br i1 %.not.i.i688, label %cond_685_case_1.i, label %panic.i.i689

panic.i.i689:                                     ; preds = %90
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_685_case_0.i:                                ; preds = %cond_exit_682.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_685_case_1.i:                                ; preds = %90
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
  %exitcond751.not = icmp eq i64 %102, 20
  br i1 %exitcond751.not, label %mask_block_ok.i694, label %84

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
  %110 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %83, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %110, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_322.362.exit, label %cond_727_case_0.i

cond_727_case_0.i:                                ; preds = %__hugr__.const_fun_322.362.exit.18, %__hugr__.const_fun_322.362.exit.17, %__hugr__.const_fun_322.362.exit.16, %__hugr__.const_fun_322.362.exit.15, %__hugr__.const_fun_322.362.exit.14, %__hugr__.const_fun_322.362.exit.13, %__hugr__.const_fun_322.362.exit.12, %__hugr__.const_fun_322.362.exit.11, %__hugr__.const_fun_322.362.exit.10, %__hugr__.const_fun_322.362.exit.9, %__hugr__.const_fun_322.362.exit.8, %__hugr__.const_fun_322.362.exit.7, %__hugr__.const_fun_322.362.exit.6, %__hugr__.const_fun_322.362.exit.5, %__hugr__.const_fun_322.362.exit.4, %__hugr__.const_fun_322.362.exit.3, %__hugr__.const_fun_322.362.exit.2, %__hugr__.const_fun_322.362.exit.1, %__hugr__.const_fun_322.362.exit, %__barray_check_none_borrowed.exit696
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_322.362.exit:                  ; preds = %__barray_check_none_borrowed.exit696
  %111 = extractvalue { i1, { i1, i64, i1 } } %110, 1
  store { i1, i64, i1 } %111, { i1, i64, i1 }* %107, align 4
  %112 = getelementptr inbounds i8, i8* %37, i64 32
  %113 = bitcast i8* %112 to { i1, { i1, i64, i1 } }*
  %114 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %113, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %114, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_322.362.exit.1, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.1:                ; preds = %__hugr__.const_fun_322.362.exit
  %115 = extractvalue { i1, { i1, i64, i1 } } %114, 1
  %116 = getelementptr inbounds i8, i8* %106, i64 24
  %117 = bitcast i8* %116 to { i1, i64, i1 }*
  store { i1, i64, i1 } %115, { i1, i64, i1 }* %117, align 4
  %118 = getelementptr inbounds i8, i8* %37, i64 64
  %119 = bitcast i8* %118 to { i1, { i1, i64, i1 } }*
  %120 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %119, align 4
  %.fca.0.extract11.i.2 = extractvalue { i1, { i1, i64, i1 } } %120, 0
  br i1 %.fca.0.extract11.i.2, label %__hugr__.const_fun_322.362.exit.2, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.2:                ; preds = %__hugr__.const_fun_322.362.exit.1
  %121 = extractvalue { i1, { i1, i64, i1 } } %120, 1
  %122 = getelementptr inbounds i8, i8* %106, i64 48
  %123 = bitcast i8* %122 to { i1, i64, i1 }*
  store { i1, i64, i1 } %121, { i1, i64, i1 }* %123, align 4
  %124 = getelementptr inbounds i8, i8* %37, i64 96
  %125 = bitcast i8* %124 to { i1, { i1, i64, i1 } }*
  %126 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %125, align 4
  %.fca.0.extract11.i.3 = extractvalue { i1, { i1, i64, i1 } } %126, 0
  br i1 %.fca.0.extract11.i.3, label %__hugr__.const_fun_322.362.exit.3, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.3:                ; preds = %__hugr__.const_fun_322.362.exit.2
  %127 = extractvalue { i1, { i1, i64, i1 } } %126, 1
  %128 = getelementptr inbounds i8, i8* %106, i64 72
  %129 = bitcast i8* %128 to { i1, i64, i1 }*
  store { i1, i64, i1 } %127, { i1, i64, i1 }* %129, align 4
  %130 = getelementptr inbounds i8, i8* %37, i64 128
  %131 = bitcast i8* %130 to { i1, { i1, i64, i1 } }*
  %132 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %131, align 4
  %.fca.0.extract11.i.4 = extractvalue { i1, { i1, i64, i1 } } %132, 0
  br i1 %.fca.0.extract11.i.4, label %__hugr__.const_fun_322.362.exit.4, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.4:                ; preds = %__hugr__.const_fun_322.362.exit.3
  %133 = extractvalue { i1, { i1, i64, i1 } } %132, 1
  %134 = getelementptr inbounds i8, i8* %106, i64 96
  %135 = bitcast i8* %134 to { i1, i64, i1 }*
  store { i1, i64, i1 } %133, { i1, i64, i1 }* %135, align 4
  %136 = getelementptr inbounds i8, i8* %37, i64 160
  %137 = bitcast i8* %136 to { i1, { i1, i64, i1 } }*
  %138 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %137, align 4
  %.fca.0.extract11.i.5 = extractvalue { i1, { i1, i64, i1 } } %138, 0
  br i1 %.fca.0.extract11.i.5, label %__hugr__.const_fun_322.362.exit.5, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.5:                ; preds = %__hugr__.const_fun_322.362.exit.4
  %139 = extractvalue { i1, { i1, i64, i1 } } %138, 1
  %140 = getelementptr inbounds i8, i8* %106, i64 120
  %141 = bitcast i8* %140 to { i1, i64, i1 }*
  store { i1, i64, i1 } %139, { i1, i64, i1 }* %141, align 4
  %142 = getelementptr inbounds i8, i8* %37, i64 192
  %143 = bitcast i8* %142 to { i1, { i1, i64, i1 } }*
  %144 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %143, align 4
  %.fca.0.extract11.i.6 = extractvalue { i1, { i1, i64, i1 } } %144, 0
  br i1 %.fca.0.extract11.i.6, label %__hugr__.const_fun_322.362.exit.6, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.6:                ; preds = %__hugr__.const_fun_322.362.exit.5
  %145 = extractvalue { i1, { i1, i64, i1 } } %144, 1
  %146 = getelementptr inbounds i8, i8* %106, i64 144
  %147 = bitcast i8* %146 to { i1, i64, i1 }*
  store { i1, i64, i1 } %145, { i1, i64, i1 }* %147, align 4
  %148 = getelementptr inbounds i8, i8* %37, i64 224
  %149 = bitcast i8* %148 to { i1, { i1, i64, i1 } }*
  %150 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %149, align 4
  %.fca.0.extract11.i.7 = extractvalue { i1, { i1, i64, i1 } } %150, 0
  br i1 %.fca.0.extract11.i.7, label %__hugr__.const_fun_322.362.exit.7, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.7:                ; preds = %__hugr__.const_fun_322.362.exit.6
  %151 = extractvalue { i1, { i1, i64, i1 } } %150, 1
  %152 = getelementptr inbounds i8, i8* %106, i64 168
  %153 = bitcast i8* %152 to { i1, i64, i1 }*
  store { i1, i64, i1 } %151, { i1, i64, i1 }* %153, align 4
  %154 = getelementptr inbounds i8, i8* %37, i64 256
  %155 = bitcast i8* %154 to { i1, { i1, i64, i1 } }*
  %156 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %155, align 4
  %.fca.0.extract11.i.8 = extractvalue { i1, { i1, i64, i1 } } %156, 0
  br i1 %.fca.0.extract11.i.8, label %__hugr__.const_fun_322.362.exit.8, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.8:                ; preds = %__hugr__.const_fun_322.362.exit.7
  %157 = extractvalue { i1, { i1, i64, i1 } } %156, 1
  %158 = getelementptr inbounds i8, i8* %106, i64 192
  %159 = bitcast i8* %158 to { i1, i64, i1 }*
  store { i1, i64, i1 } %157, { i1, i64, i1 }* %159, align 4
  %160 = getelementptr inbounds i8, i8* %37, i64 288
  %161 = bitcast i8* %160 to { i1, { i1, i64, i1 } }*
  %162 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %161, align 4
  %.fca.0.extract11.i.9 = extractvalue { i1, { i1, i64, i1 } } %162, 0
  br i1 %.fca.0.extract11.i.9, label %__hugr__.const_fun_322.362.exit.9, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.9:                ; preds = %__hugr__.const_fun_322.362.exit.8
  %163 = extractvalue { i1, { i1, i64, i1 } } %162, 1
  %164 = getelementptr inbounds i8, i8* %106, i64 216
  %165 = bitcast i8* %164 to { i1, i64, i1 }*
  store { i1, i64, i1 } %163, { i1, i64, i1 }* %165, align 4
  %166 = getelementptr inbounds i8, i8* %37, i64 320
  %167 = bitcast i8* %166 to { i1, { i1, i64, i1 } }*
  %168 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %167, align 4
  %.fca.0.extract11.i.10 = extractvalue { i1, { i1, i64, i1 } } %168, 0
  br i1 %.fca.0.extract11.i.10, label %__hugr__.const_fun_322.362.exit.10, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.10:               ; preds = %__hugr__.const_fun_322.362.exit.9
  %169 = extractvalue { i1, { i1, i64, i1 } } %168, 1
  %170 = getelementptr inbounds i8, i8* %106, i64 240
  %171 = bitcast i8* %170 to { i1, i64, i1 }*
  store { i1, i64, i1 } %169, { i1, i64, i1 }* %171, align 4
  %172 = getelementptr inbounds i8, i8* %37, i64 352
  %173 = bitcast i8* %172 to { i1, { i1, i64, i1 } }*
  %174 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %173, align 4
  %.fca.0.extract11.i.11 = extractvalue { i1, { i1, i64, i1 } } %174, 0
  br i1 %.fca.0.extract11.i.11, label %__hugr__.const_fun_322.362.exit.11, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.11:               ; preds = %__hugr__.const_fun_322.362.exit.10
  %175 = extractvalue { i1, { i1, i64, i1 } } %174, 1
  %176 = getelementptr inbounds i8, i8* %106, i64 264
  %177 = bitcast i8* %176 to { i1, i64, i1 }*
  store { i1, i64, i1 } %175, { i1, i64, i1 }* %177, align 4
  %178 = getelementptr inbounds i8, i8* %37, i64 384
  %179 = bitcast i8* %178 to { i1, { i1, i64, i1 } }*
  %180 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %179, align 4
  %.fca.0.extract11.i.12 = extractvalue { i1, { i1, i64, i1 } } %180, 0
  br i1 %.fca.0.extract11.i.12, label %__hugr__.const_fun_322.362.exit.12, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.12:               ; preds = %__hugr__.const_fun_322.362.exit.11
  %181 = extractvalue { i1, { i1, i64, i1 } } %180, 1
  %182 = getelementptr inbounds i8, i8* %106, i64 288
  %183 = bitcast i8* %182 to { i1, i64, i1 }*
  store { i1, i64, i1 } %181, { i1, i64, i1 }* %183, align 4
  %184 = getelementptr inbounds i8, i8* %37, i64 416
  %185 = bitcast i8* %184 to { i1, { i1, i64, i1 } }*
  %186 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %185, align 4
  %.fca.0.extract11.i.13 = extractvalue { i1, { i1, i64, i1 } } %186, 0
  br i1 %.fca.0.extract11.i.13, label %__hugr__.const_fun_322.362.exit.13, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.13:               ; preds = %__hugr__.const_fun_322.362.exit.12
  %187 = extractvalue { i1, { i1, i64, i1 } } %186, 1
  %188 = getelementptr inbounds i8, i8* %106, i64 312
  %189 = bitcast i8* %188 to { i1, i64, i1 }*
  store { i1, i64, i1 } %187, { i1, i64, i1 }* %189, align 4
  %190 = getelementptr inbounds i8, i8* %37, i64 448
  %191 = bitcast i8* %190 to { i1, { i1, i64, i1 } }*
  %192 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %191, align 4
  %.fca.0.extract11.i.14 = extractvalue { i1, { i1, i64, i1 } } %192, 0
  br i1 %.fca.0.extract11.i.14, label %__hugr__.const_fun_322.362.exit.14, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.14:               ; preds = %__hugr__.const_fun_322.362.exit.13
  %193 = extractvalue { i1, { i1, i64, i1 } } %192, 1
  %194 = getelementptr inbounds i8, i8* %106, i64 336
  %195 = bitcast i8* %194 to { i1, i64, i1 }*
  store { i1, i64, i1 } %193, { i1, i64, i1 }* %195, align 4
  %196 = getelementptr inbounds i8, i8* %37, i64 480
  %197 = bitcast i8* %196 to { i1, { i1, i64, i1 } }*
  %198 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %197, align 4
  %.fca.0.extract11.i.15 = extractvalue { i1, { i1, i64, i1 } } %198, 0
  br i1 %.fca.0.extract11.i.15, label %__hugr__.const_fun_322.362.exit.15, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.15:               ; preds = %__hugr__.const_fun_322.362.exit.14
  %199 = extractvalue { i1, { i1, i64, i1 } } %198, 1
  %200 = getelementptr inbounds i8, i8* %106, i64 360
  %201 = bitcast i8* %200 to { i1, i64, i1 }*
  store { i1, i64, i1 } %199, { i1, i64, i1 }* %201, align 4
  %202 = getelementptr inbounds i8, i8* %37, i64 512
  %203 = bitcast i8* %202 to { i1, { i1, i64, i1 } }*
  %204 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %203, align 4
  %.fca.0.extract11.i.16 = extractvalue { i1, { i1, i64, i1 } } %204, 0
  br i1 %.fca.0.extract11.i.16, label %__hugr__.const_fun_322.362.exit.16, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.16:               ; preds = %__hugr__.const_fun_322.362.exit.15
  %205 = extractvalue { i1, { i1, i64, i1 } } %204, 1
  %206 = getelementptr inbounds i8, i8* %106, i64 384
  %207 = bitcast i8* %206 to { i1, i64, i1 }*
  store { i1, i64, i1 } %205, { i1, i64, i1 }* %207, align 4
  %208 = getelementptr inbounds i8, i8* %37, i64 544
  %209 = bitcast i8* %208 to { i1, { i1, i64, i1 } }*
  %210 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %209, align 4
  %.fca.0.extract11.i.17 = extractvalue { i1, { i1, i64, i1 } } %210, 0
  br i1 %.fca.0.extract11.i.17, label %__hugr__.const_fun_322.362.exit.17, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.17:               ; preds = %__hugr__.const_fun_322.362.exit.16
  %211 = extractvalue { i1, { i1, i64, i1 } } %210, 1
  %212 = getelementptr inbounds i8, i8* %106, i64 408
  %213 = bitcast i8* %212 to { i1, i64, i1 }*
  store { i1, i64, i1 } %211, { i1, i64, i1 }* %213, align 4
  %214 = getelementptr inbounds i8, i8* %37, i64 576
  %215 = bitcast i8* %214 to { i1, { i1, i64, i1 } }*
  %216 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %215, align 4
  %.fca.0.extract11.i.18 = extractvalue { i1, { i1, i64, i1 } } %216, 0
  br i1 %.fca.0.extract11.i.18, label %__hugr__.const_fun_322.362.exit.18, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.18:               ; preds = %__hugr__.const_fun_322.362.exit.17
  %217 = extractvalue { i1, { i1, i64, i1 } } %216, 1
  %218 = getelementptr inbounds i8, i8* %106, i64 432
  %219 = bitcast i8* %218 to { i1, i64, i1 }*
  store { i1, i64, i1 } %217, { i1, i64, i1 }* %219, align 4
  %220 = getelementptr inbounds i8, i8* %37, i64 608
  %221 = bitcast i8* %220 to { i1, { i1, i64, i1 } }*
  %222 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %221, align 4
  %.fca.0.extract11.i.19 = extractvalue { i1, { i1, i64, i1 } } %222, 0
  br i1 %.fca.0.extract11.i.19, label %__hugr__.const_fun_322.362.exit.19, label %cond_727_case_0.i

__hugr__.const_fun_322.362.exit.19:               ; preds = %__hugr__.const_fun_322.362.exit.18
  %223 = extractvalue { i1, { i1, i64, i1 } } %222, 1
  %224 = getelementptr inbounds i8, i8* %106, i64 456
  %225 = bitcast i8* %224 to { i1, i64, i1 }*
  store { i1, i64, i1 } %223, { i1, i64, i1 }* %225, align 4
  tail call void @heap_free(i8* nonnull %37)
  tail call void @heap_free(i8* %38)
  br label %__barray_check_bounds.exit702

cond_641_case_0:                                  ; preds = %cond_exit_641
  %226 = load i64, i64* %109, align 4
  %227 = or i64 %226, -1048576
  store i64 %227, i64* %109, align 4
  %228 = icmp eq i64 %227, -1
  br i1 %228, label %loop_out312, label %mask_block_err.i700

mask_block_err.i700:                              ; preds = %cond_641_case_0
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit702:                    ; preds = %__hugr__.const_fun_322.362.exit.19, %cond_exit_641
  %"638_0.0755" = phi i64 [ 0, %__hugr__.const_fun_322.362.exit.19 ], [ %229, %cond_exit_641 ]
  %229 = add nuw nsw i64 %"638_0.0755", 1
  %230 = lshr i64 %"638_0.0755", 6
  %231 = getelementptr inbounds i64, i64* %109, i64 %230
  %232 = load i64, i64* %231, align 4
  %233 = shl nuw nsw i64 1, %"638_0.0755"
  %234 = and i64 %232, %233
  %.not732 = icmp eq i64 %234, 0
  br i1 %.not732, label %__barray_mask_borrow.exit707, label %cond_exit_641

__barray_mask_borrow.exit707:                     ; preds = %__barray_check_bounds.exit702
  %235 = xor i64 %232, %233
  store i64 %235, i64* %231, align 4
  %236 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %107, i64 %"638_0.0755"
  %237 = load { i1, i64, i1 }, { i1, i64, i1 }* %236, align 4
  %.fca.0.extract399 = extractvalue { i1, i64, i1 } %237, 0
  br i1 %.fca.0.extract399, label %cond_664_case_1, label %cond_exit_641

cond_exit_641:                                    ; preds = %cond_664_case_1, %__barray_mask_borrow.exit707, %__barray_check_bounds.exit702
  %238 = icmp ult i64 %"638_0.0755", 19
  br i1 %238, label %__barray_check_bounds.exit702, label %cond_641_case_0

loop_out312:                                      ; preds = %cond_641_case_0
  tail call void @heap_free(i8* %106)
  tail call void @heap_free(i8* nonnull %108)
  %239 = load i64, i64* %82, align 4
  %240 = and i64 %239, 1048575
  store i64 %240, i64* %82, align 4
  %241 = icmp eq i64 %240, 0
  br i1 %241, label %__barray_check_none_borrowed.exit712, label %mask_block_err.i711

__barray_check_none_borrowed.exit712:             ; preds = %loop_out312
  %242 = tail call i8* @heap_alloc(i64 20)
  %243 = tail call i8* @heap_alloc(i64 8)
  %244 = bitcast i8* %243 to i64*
  store i64 0, i64* %244, align 1
  br label %245

mask_block_err.i711:                              ; preds = %loop_out312
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_664_case_1:                                  ; preds = %__barray_mask_borrow.exit707
  %.fca.1.extract400 = extractvalue { i1, i64, i1 } %237, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract400)
  br label %cond_exit_641

245:                                              ; preds = %__barray_check_none_borrowed.exit712, %__hugr__.array.__read_bool.3.363.exit
  %storemerge744 = phi i64 [ 0, %__barray_check_none_borrowed.exit712 ], [ %250, %__hugr__.array.__read_bool.3.363.exit ]
  %246 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %80, i64 %storemerge744
  %247 = load { i1, i64, i1 }, { i1, i64, i1 }* %246, align 4
  %.fca.0.extract.i713 = extractvalue { i1, i64, i1 } %247, 0
  %.fca.1.extract.i714 = extractvalue { i1, i64, i1 } %247, 1
  br i1 %.fca.0.extract.i713, label %cond_374_case_1.i, label %cond_374_case_0.i

cond_374_case_0.i:                                ; preds = %245
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %247, 2
  br label %__hugr__.array.__read_bool.3.363.exit

cond_374_case_1.i:                                ; preds = %245
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i714)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i714)
  br label %__hugr__.array.__read_bool.3.363.exit

__hugr__.array.__read_bool.3.363.exit:            ; preds = %cond_374_case_0.i, %cond_374_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_374_case_1.i ], [ %.fca.2.extract.i, %cond_374_case_0.i ]
  %248 = getelementptr inbounds i8, i8* %242, i64 %storemerge744
  %249 = bitcast i8* %248 to i1*
  store i1 %"03.0.i", i1* %249, align 1
  %250 = add nuw nsw i64 %storemerge744, 1
  %exitcond753.not = icmp eq i64 %250, 20
  br i1 %exitcond753.not, label %mask_block_ok.i717, label %245

mask_block_ok.i717:                               ; preds = %__hugr__.array.__read_bool.3.363.exit
  tail call void @heap_free(i8* nonnull %79)
  tail call void @heap_free(i8* %81)
  %251 = load i64, i64* %244, align 4
  %252 = and i64 %251, 1048575
  store i64 %252, i64* %244, align 4
  %253 = icmp eq i64 %252, 0
  br i1 %253, label %__barray_check_none_borrowed.exit719, label %mask_block_err.i718

__barray_check_none_borrowed.exit719:             ; preds = %mask_block_ok.i717
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %254 = alloca [20 x i1], align 1
  %.sub = getelementptr inbounds [20 x i1], [20 x i1]* %254, i64 0, i64 0
  %255 = bitcast [20 x i1]* %254 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(20) %255, i8 0, i64 20, i1 false)
  store i32 20, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %256 = bitcast i1** %arr_ptr to i8**
  store i8* %242, i8** %256, align 8
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
