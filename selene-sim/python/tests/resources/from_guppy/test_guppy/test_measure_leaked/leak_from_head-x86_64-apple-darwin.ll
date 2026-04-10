; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@e_Option.unw.32D4E82D.0 = private constant [43 x i8] c"*EXIT:INT:Option.unwrap: value is `Nothing`"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
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
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.383.exit, label %cond_378_case_0.i

cond_378_case_0.i:                                ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.383.exit:                   ; preds = %id_bb.i
  %.fca.1.extract.i = extractvalue { i1, i64 } %5, 1
  tail call void @___rxy(i64 %.fca.1.extract.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0x400921FB54442D18)
  br label %cond_21_case_1

__barray_check_bounds.exit:                       ; preds = %cond_exit_21, %__barray_mask_return.exit
  %"48_0.0684" = phi i64 [ %6, %__barray_mask_return.exit ], [ 0, %cond_exit_21 ]
  %6 = add nuw nsw i64 %"48_0.0684", 1
  %7 = lshr i64 %"48_0.0684", 6
  %8 = getelementptr inbounds i64, i64* %3, i64 %7
  %9 = load i64, i64* %8, align 4
  %10 = shl nuw nsw i64 1, %"48_0.0684"
  %11 = and i64 %9, %10
  %.not.i = icmp eq i64 %11, 0
  br i1 %.not.i, label %__barray_check_bounds.exit612, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit612:                    ; preds = %__barray_check_bounds.exit
  %12 = xor i64 %9, %10
  store i64 %12, i64* %8, align 4
  %13 = getelementptr inbounds i64, i64* %1, i64 %"48_0.0684"
  %14 = load i64, i64* %13, align 4
  tail call void @___rxy(i64 %14, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i, i64 %14, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %14, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %14, double 0xBFF921FB54442D18)
  %15 = load i64, i64* %8, align 4
  %16 = and i64 %15, %10
  %.not.i613 = icmp eq i64 %16, 0
  br i1 %.not.i613, label %panic.i614, label %__barray_mask_return.exit

panic.i614:                                       ; preds = %__barray_check_bounds.exit612
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit612
  %17 = xor i64 %15, %10
  store i64 %17, i64* %8, align 4
  store i64 %14, i64* %13, align 4
  %exitcond698.not = icmp eq i64 %6, 20
  br i1 %exitcond698.not, label %cond_exit_82, label %__barray_check_bounds.exit

18:                                               ; preds = %cond_324_case_0, %58
  %19 = tail call i8* @heap_alloc(i64 480)
  %20 = bitcast i8* %19 to { i1, i64, i1 }*
  %21 = tail call i8* @heap_alloc(i64 8)
  %22 = bitcast i8* %21 to i64*
  store i64 -1, i64* %22, align 1
  br label %32

mask_block_ok.i.i.i:                              ; preds = %cond_exit_518.i
  %23 = load i64, i64* %3, align 4
  %24 = or i64 %23, -1048576
  store i64 %24, i64* %3, align 4
  %25 = icmp eq i64 %24, -1
  br i1 %25, label %"__hugr__.$measure_array$$n(20).442.exit", label %mask_block_err.i.i.i

"__hugr__.$measure_array$$n(20).442.exit":        ; preds = %mask_block_ok.i.i.i
  tail call void @heap_free(i8* nonnull %0)
  tail call void @heap_free(i8* nonnull %2)
  %26 = tail call i8* @heap_alloc(i64 640)
  %27 = tail call i8* @heap_alloc(i64 8)
  %28 = bitcast i8* %27 to i64*
  store i64 0, i64* %28, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(640) %26, i8 0, i64 640, i1 false)
  %29 = load i64, i64* %22, align 4
  %30 = and i64 %29, 1048575
  store i64 %30, i64* %22, align 4
  %31 = icmp eq i64 %30, 0
  br i1 %31, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

32:                                               ; preds = %18, %cond_exit_518.i
  %"468_0.sroa.15.0.i686" = phi i64 [ 0, %18 ], [ %33, %cond_exit_518.i ]
  %33 = add nuw nsw i64 %"468_0.sroa.15.0.i686", 1
  %34 = lshr i64 %"468_0.sroa.15.0.i686", 6
  %35 = getelementptr inbounds i64, i64* %3, i64 %34
  %36 = load i64, i64* %35, align 4
  %37 = shl nuw nsw i64 1, %"468_0.sroa.15.0.i686"
  %38 = and i64 %36, %37
  %.not.i99.i.i = icmp eq i64 %38, 0
  br i1 %.not.i99.i.i, label %__barray_check_bounds.exit.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %32
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %32
  %39 = xor i64 %36, %37
  store i64 %39, i64* %35, align 4
  %40 = getelementptr inbounds i64, i64* %1, i64 %"468_0.sroa.15.0.i686"
  %41 = load i64, i64* %40, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %41)
  tail call void @___qfree(i64 %41)
  %42 = getelementptr inbounds i64, i64* %22, i64 %34
  %43 = load i64, i64* %42, align 4
  %44 = and i64 %43, %37
  %.not.i.i = icmp eq i64 %44, 0
  br i1 %.not.i.i, label %panic.i.i, label %cond_exit_518.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_518.i:                                  ; preds = %__barray_check_bounds.exit.i
  %"532_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %45 = xor i64 %43, %37
  store i64 %45, i64* %42, align 4
  %46 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %20, i64 %"468_0.sroa.15.0.i686"
  store { i1, i64, i1 } %"532_054.fca.1.insert.i", { i1, i64, i1 }* %46, align 4
  %exitcond699.not = icmp eq i64 %33, 20
  br i1 %exitcond699.not, label %mask_block_ok.i.i.i, label %32

cond_21_case_1:                                   ; preds = %__hugr__.__tk2_qalloc.383.exit, %cond_exit_21
  %"16_0.sroa.0.0683" = phi i64 [ 0, %__hugr__.__tk2_qalloc.383.exit ], [ %47, %cond_exit_21 ]
  %47 = add nuw nsw i64 %"16_0.sroa.0.0683", 1
  %qalloc.i621 = tail call i64 @___qalloc()
  %not_max.not.i622 = icmp eq i64 %qalloc.i621, -1
  br i1 %not_max.not.i622, label %id_bb.i625, label %reset_bb.i623

reset_bb.i623:                                    ; preds = %cond_21_case_1
  tail call void @___reset(i64 %qalloc.i621)
  br label %id_bb.i625

id_bb.i625:                                       ; preds = %reset_bb.i623, %cond_21_case_1
  %48 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i621, 1
  %49 = select i1 %not_max.not.i622, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %48
  %.fca.0.extract.i624 = extractvalue { i1, i64 } %49, 0
  br i1 %.fca.0.extract.i624, label %__barray_check_bounds.exit630, label %cond_378_case_0.i627

cond_378_case_0.i627:                             ; preds = %id_bb.i625
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit630:                    ; preds = %id_bb.i625
  %50 = lshr i64 %"16_0.sroa.0.0683", 6
  %51 = getelementptr inbounds i64, i64* %3, i64 %50
  %52 = load i64, i64* %51, align 4
  %53 = shl nuw nsw i64 1, %"16_0.sroa.0.0683"
  %54 = and i64 %52, %53
  %.not.i631 = icmp eq i64 %54, 0
  br i1 %.not.i631, label %panic.i632, label %cond_exit_21

panic.i632:                                       ; preds = %__barray_check_bounds.exit630
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_21:                                     ; preds = %__barray_check_bounds.exit630
  %.fca.1.extract.i626 = extractvalue { i1, i64 } %49, 1
  %55 = xor i64 %52, %53
  store i64 %55, i64* %51, align 4
  %56 = getelementptr inbounds i64, i64* %1, i64 %"16_0.sroa.0.0683"
  store i64 %.fca.1.extract.i626, i64* %56, align 4
  %exitcond.not = icmp eq i64 %47, 20
  br i1 %exitcond.not, label %__barray_check_bounds.exit, label %cond_21_case_1

57:                                               ; preds = %cond_exit_82
  %read_uint.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %.not = icmp eq i64 %read_uint.i, 2
  br i1 %.not, label %cond_133_case_0, label %cond_324_case_0

58:                                               ; preds = %cond_exit_82
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  tail call void @print_int(i8* getelementptr inbounds ([21 x i8], [21 x i8]* @res_head_leake.F4F32972.0, i64 0, i64 0), i64 20, i64 1)
  br label %18

cond_exit_82:                                     ; preds = %__barray_mask_return.exit
  %lazy_measure_leaked.i = tail call i64 @___lazy_measure_leaked(i64 %.fca.1.extract.i)
  tail call void @___qfree(i64 %.fca.1.extract.i)
  tail call void @___inc_future_refcount(i64 %lazy_measure_leaked.i)
  %read_uint.i634 = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %59 = icmp eq i64 %read_uint.i634, 2
  br i1 %59, label %58, label %57

cond_133_case_0:                                  ; preds = %57
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @e_Option.unw.32D4E82D.0, i64 0, i64 0))
  unreachable

cond_324_case_0:                                  ; preds = %57
  %60 = icmp eq i64 %read_uint.i, 1
  tail call void @print_bool(i8* getelementptr inbounds ([15 x i8], [15 x i8]* @res_head.AFE8E005.0, i64 0, i64 0), i64 14, i1 %60)
  br label %18

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$measure_array$$n(20).442.exit"
  %61 = tail call i8* @heap_alloc(i64 480)
  %62 = bitcast i8* %61 to { i1, i64, i1 }*
  %63 = tail call i8* @heap_alloc(i64 8)
  %64 = bitcast i8* %63 to i64*
  store i64 0, i64* %64, align 1
  %65 = bitcast i8* %26 to { i1, { i1, i64, i1 } }*
  br label %66

mask_block_err.i:                                 ; preds = %"__hugr__.$measure_array$$n(20).442.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

66:                                               ; preds = %__barray_check_none_borrowed.exit, %__hugr__.const_fun_310.313.exit
  %storemerge609691 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %84, %__hugr__.const_fun_310.313.exit ]
  %67 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %82, %__hugr__.const_fun_310.313.exit ]
  %68 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %20, i64 %storemerge609691
  %69 = load { i1, i64, i1 }, { i1, i64, i1 }* %68, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %69, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %69, 1
  br i1 %.fca.0.extract118.i, label %cond_647_case_1.i, label %cond_exit_647.i

cond_647_case_1.i:                                ; preds = %66
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %70 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %cond_exit_647.i

cond_exit_647.i:                                  ; preds = %cond_647_case_1.i, %66
  %.pn.i = phi { i1, i64, i1 } [ %70, %cond_647_case_1.i ], [ %69, %66 ]
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %71 = icmp ult i64 %67, 20
  br i1 %71, label %72, label %cond_650_case_0.i

72:                                               ; preds = %cond_exit_647.i
  %73 = lshr i64 %67, 6
  %74 = getelementptr inbounds i64, i64* %28, i64 %73
  %75 = load i64, i64* %74, align 4
  %76 = shl nuw nsw i64 1, %67
  %77 = and i64 %75, %76
  %.not.i.i637 = icmp eq i64 %77, 0
  br i1 %.not.i.i637, label %cond_650_case_1.i, label %panic.i.i638

panic.i.i638:                                     ; preds = %72
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_650_case_0.i:                                ; preds = %cond_exit_647.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

cond_650_case_1.i:                                ; preds = %72
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %69, i1 %"04.sroa.6.0.i", 2
  %78 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %79 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %65, i64 %67
  %80 = getelementptr inbounds { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %79, i64 0, i32 0
  %81 = load i1, i1* %80, align 1
  store { i1, { i1, i64, i1 } } %78, { i1, { i1, i64, i1 } }* %79, align 4
  br i1 %81, label %cond_651_case_1.i, label %__hugr__.const_fun_310.313.exit

cond_651_case_1.i:                                ; preds = %cond_650_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_310.313.exit:                  ; preds = %cond_650_case_1.i
  %82 = add nuw nsw i64 %67, 1
  %83 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %62, i64 %storemerge609691
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %83, align 4
  %84 = add nuw nsw i64 %storemerge609691, 1
  %exitcond700.not = icmp eq i64 %84, 20
  br i1 %exitcond700.not, label %mask_block_ok.i643, label %66

mask_block_ok.i643:                               ; preds = %__hugr__.const_fun_310.313.exit
  tail call void @heap_free(i8* nonnull %19)
  tail call void @heap_free(i8* %21)
  %85 = load i64, i64* %28, align 4
  %86 = and i64 %85, 1048575
  store i64 %86, i64* %28, align 4
  %87 = icmp eq i64 %86, 0
  br i1 %87, label %__barray_check_none_borrowed.exit645, label %mask_block_err.i644

mask_block_err.i644:                              ; preds = %mask_block_ok.i643
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit645:             ; preds = %mask_block_ok.i643
  %88 = tail call i8* @heap_alloc(i64 480)
  %89 = bitcast i8* %88 to { i1, i64, i1 }*
  %90 = tail call i8* @heap_alloc(i64 8)
  %91 = bitcast i8* %90 to i64*
  store i64 0, i64* %91, align 1
  %92 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %65, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %92, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_306.310.exit, label %cond_692_case_0.i

cond_692_case_0.i:                                ; preds = %__hugr__.const_fun_306.310.exit.18, %__hugr__.const_fun_306.310.exit.17, %__hugr__.const_fun_306.310.exit.16, %__hugr__.const_fun_306.310.exit.15, %__hugr__.const_fun_306.310.exit.14, %__hugr__.const_fun_306.310.exit.13, %__hugr__.const_fun_306.310.exit.12, %__hugr__.const_fun_306.310.exit.11, %__hugr__.const_fun_306.310.exit.10, %__hugr__.const_fun_306.310.exit.9, %__hugr__.const_fun_306.310.exit.8, %__hugr__.const_fun_306.310.exit.7, %__hugr__.const_fun_306.310.exit.6, %__hugr__.const_fun_306.310.exit.5, %__hugr__.const_fun_306.310.exit.4, %__hugr__.const_fun_306.310.exit.3, %__hugr__.const_fun_306.310.exit.2, %__hugr__.const_fun_306.310.exit.1, %__hugr__.const_fun_306.310.exit, %__barray_check_none_borrowed.exit645
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_306.310.exit:                  ; preds = %__barray_check_none_borrowed.exit645
  %93 = extractvalue { i1, { i1, i64, i1 } } %92, 1
  store { i1, i64, i1 } %93, { i1, i64, i1 }* %89, align 4
  %94 = getelementptr inbounds i8, i8* %26, i64 32
  %95 = bitcast i8* %94 to { i1, { i1, i64, i1 } }*
  %96 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %95, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %96, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_306.310.exit.1, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.1:                ; preds = %__hugr__.const_fun_306.310.exit
  %97 = extractvalue { i1, { i1, i64, i1 } } %96, 1
  %98 = getelementptr inbounds i8, i8* %88, i64 24
  %99 = bitcast i8* %98 to { i1, i64, i1 }*
  store { i1, i64, i1 } %97, { i1, i64, i1 }* %99, align 4
  %100 = getelementptr inbounds i8, i8* %26, i64 64
  %101 = bitcast i8* %100 to { i1, { i1, i64, i1 } }*
  %102 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %101, align 4
  %.fca.0.extract11.i.2 = extractvalue { i1, { i1, i64, i1 } } %102, 0
  br i1 %.fca.0.extract11.i.2, label %__hugr__.const_fun_306.310.exit.2, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.2:                ; preds = %__hugr__.const_fun_306.310.exit.1
  %103 = extractvalue { i1, { i1, i64, i1 } } %102, 1
  %104 = getelementptr inbounds i8, i8* %88, i64 48
  %105 = bitcast i8* %104 to { i1, i64, i1 }*
  store { i1, i64, i1 } %103, { i1, i64, i1 }* %105, align 4
  %106 = getelementptr inbounds i8, i8* %26, i64 96
  %107 = bitcast i8* %106 to { i1, { i1, i64, i1 } }*
  %108 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %107, align 4
  %.fca.0.extract11.i.3 = extractvalue { i1, { i1, i64, i1 } } %108, 0
  br i1 %.fca.0.extract11.i.3, label %__hugr__.const_fun_306.310.exit.3, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.3:                ; preds = %__hugr__.const_fun_306.310.exit.2
  %109 = extractvalue { i1, { i1, i64, i1 } } %108, 1
  %110 = getelementptr inbounds i8, i8* %88, i64 72
  %111 = bitcast i8* %110 to { i1, i64, i1 }*
  store { i1, i64, i1 } %109, { i1, i64, i1 }* %111, align 4
  %112 = getelementptr inbounds i8, i8* %26, i64 128
  %113 = bitcast i8* %112 to { i1, { i1, i64, i1 } }*
  %114 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %113, align 4
  %.fca.0.extract11.i.4 = extractvalue { i1, { i1, i64, i1 } } %114, 0
  br i1 %.fca.0.extract11.i.4, label %__hugr__.const_fun_306.310.exit.4, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.4:                ; preds = %__hugr__.const_fun_306.310.exit.3
  %115 = extractvalue { i1, { i1, i64, i1 } } %114, 1
  %116 = getelementptr inbounds i8, i8* %88, i64 96
  %117 = bitcast i8* %116 to { i1, i64, i1 }*
  store { i1, i64, i1 } %115, { i1, i64, i1 }* %117, align 4
  %118 = getelementptr inbounds i8, i8* %26, i64 160
  %119 = bitcast i8* %118 to { i1, { i1, i64, i1 } }*
  %120 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %119, align 4
  %.fca.0.extract11.i.5 = extractvalue { i1, { i1, i64, i1 } } %120, 0
  br i1 %.fca.0.extract11.i.5, label %__hugr__.const_fun_306.310.exit.5, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.5:                ; preds = %__hugr__.const_fun_306.310.exit.4
  %121 = extractvalue { i1, { i1, i64, i1 } } %120, 1
  %122 = getelementptr inbounds i8, i8* %88, i64 120
  %123 = bitcast i8* %122 to { i1, i64, i1 }*
  store { i1, i64, i1 } %121, { i1, i64, i1 }* %123, align 4
  %124 = getelementptr inbounds i8, i8* %26, i64 192
  %125 = bitcast i8* %124 to { i1, { i1, i64, i1 } }*
  %126 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %125, align 4
  %.fca.0.extract11.i.6 = extractvalue { i1, { i1, i64, i1 } } %126, 0
  br i1 %.fca.0.extract11.i.6, label %__hugr__.const_fun_306.310.exit.6, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.6:                ; preds = %__hugr__.const_fun_306.310.exit.5
  %127 = extractvalue { i1, { i1, i64, i1 } } %126, 1
  %128 = getelementptr inbounds i8, i8* %88, i64 144
  %129 = bitcast i8* %128 to { i1, i64, i1 }*
  store { i1, i64, i1 } %127, { i1, i64, i1 }* %129, align 4
  %130 = getelementptr inbounds i8, i8* %26, i64 224
  %131 = bitcast i8* %130 to { i1, { i1, i64, i1 } }*
  %132 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %131, align 4
  %.fca.0.extract11.i.7 = extractvalue { i1, { i1, i64, i1 } } %132, 0
  br i1 %.fca.0.extract11.i.7, label %__hugr__.const_fun_306.310.exit.7, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.7:                ; preds = %__hugr__.const_fun_306.310.exit.6
  %133 = extractvalue { i1, { i1, i64, i1 } } %132, 1
  %134 = getelementptr inbounds i8, i8* %88, i64 168
  %135 = bitcast i8* %134 to { i1, i64, i1 }*
  store { i1, i64, i1 } %133, { i1, i64, i1 }* %135, align 4
  %136 = getelementptr inbounds i8, i8* %26, i64 256
  %137 = bitcast i8* %136 to { i1, { i1, i64, i1 } }*
  %138 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %137, align 4
  %.fca.0.extract11.i.8 = extractvalue { i1, { i1, i64, i1 } } %138, 0
  br i1 %.fca.0.extract11.i.8, label %__hugr__.const_fun_306.310.exit.8, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.8:                ; preds = %__hugr__.const_fun_306.310.exit.7
  %139 = extractvalue { i1, { i1, i64, i1 } } %138, 1
  %140 = getelementptr inbounds i8, i8* %88, i64 192
  %141 = bitcast i8* %140 to { i1, i64, i1 }*
  store { i1, i64, i1 } %139, { i1, i64, i1 }* %141, align 4
  %142 = getelementptr inbounds i8, i8* %26, i64 288
  %143 = bitcast i8* %142 to { i1, { i1, i64, i1 } }*
  %144 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %143, align 4
  %.fca.0.extract11.i.9 = extractvalue { i1, { i1, i64, i1 } } %144, 0
  br i1 %.fca.0.extract11.i.9, label %__hugr__.const_fun_306.310.exit.9, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.9:                ; preds = %__hugr__.const_fun_306.310.exit.8
  %145 = extractvalue { i1, { i1, i64, i1 } } %144, 1
  %146 = getelementptr inbounds i8, i8* %88, i64 216
  %147 = bitcast i8* %146 to { i1, i64, i1 }*
  store { i1, i64, i1 } %145, { i1, i64, i1 }* %147, align 4
  %148 = getelementptr inbounds i8, i8* %26, i64 320
  %149 = bitcast i8* %148 to { i1, { i1, i64, i1 } }*
  %150 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %149, align 4
  %.fca.0.extract11.i.10 = extractvalue { i1, { i1, i64, i1 } } %150, 0
  br i1 %.fca.0.extract11.i.10, label %__hugr__.const_fun_306.310.exit.10, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.10:               ; preds = %__hugr__.const_fun_306.310.exit.9
  %151 = extractvalue { i1, { i1, i64, i1 } } %150, 1
  %152 = getelementptr inbounds i8, i8* %88, i64 240
  %153 = bitcast i8* %152 to { i1, i64, i1 }*
  store { i1, i64, i1 } %151, { i1, i64, i1 }* %153, align 4
  %154 = getelementptr inbounds i8, i8* %26, i64 352
  %155 = bitcast i8* %154 to { i1, { i1, i64, i1 } }*
  %156 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %155, align 4
  %.fca.0.extract11.i.11 = extractvalue { i1, { i1, i64, i1 } } %156, 0
  br i1 %.fca.0.extract11.i.11, label %__hugr__.const_fun_306.310.exit.11, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.11:               ; preds = %__hugr__.const_fun_306.310.exit.10
  %157 = extractvalue { i1, { i1, i64, i1 } } %156, 1
  %158 = getelementptr inbounds i8, i8* %88, i64 264
  %159 = bitcast i8* %158 to { i1, i64, i1 }*
  store { i1, i64, i1 } %157, { i1, i64, i1 }* %159, align 4
  %160 = getelementptr inbounds i8, i8* %26, i64 384
  %161 = bitcast i8* %160 to { i1, { i1, i64, i1 } }*
  %162 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %161, align 4
  %.fca.0.extract11.i.12 = extractvalue { i1, { i1, i64, i1 } } %162, 0
  br i1 %.fca.0.extract11.i.12, label %__hugr__.const_fun_306.310.exit.12, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.12:               ; preds = %__hugr__.const_fun_306.310.exit.11
  %163 = extractvalue { i1, { i1, i64, i1 } } %162, 1
  %164 = getelementptr inbounds i8, i8* %88, i64 288
  %165 = bitcast i8* %164 to { i1, i64, i1 }*
  store { i1, i64, i1 } %163, { i1, i64, i1 }* %165, align 4
  %166 = getelementptr inbounds i8, i8* %26, i64 416
  %167 = bitcast i8* %166 to { i1, { i1, i64, i1 } }*
  %168 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %167, align 4
  %.fca.0.extract11.i.13 = extractvalue { i1, { i1, i64, i1 } } %168, 0
  br i1 %.fca.0.extract11.i.13, label %__hugr__.const_fun_306.310.exit.13, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.13:               ; preds = %__hugr__.const_fun_306.310.exit.12
  %169 = extractvalue { i1, { i1, i64, i1 } } %168, 1
  %170 = getelementptr inbounds i8, i8* %88, i64 312
  %171 = bitcast i8* %170 to { i1, i64, i1 }*
  store { i1, i64, i1 } %169, { i1, i64, i1 }* %171, align 4
  %172 = getelementptr inbounds i8, i8* %26, i64 448
  %173 = bitcast i8* %172 to { i1, { i1, i64, i1 } }*
  %174 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %173, align 4
  %.fca.0.extract11.i.14 = extractvalue { i1, { i1, i64, i1 } } %174, 0
  br i1 %.fca.0.extract11.i.14, label %__hugr__.const_fun_306.310.exit.14, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.14:               ; preds = %__hugr__.const_fun_306.310.exit.13
  %175 = extractvalue { i1, { i1, i64, i1 } } %174, 1
  %176 = getelementptr inbounds i8, i8* %88, i64 336
  %177 = bitcast i8* %176 to { i1, i64, i1 }*
  store { i1, i64, i1 } %175, { i1, i64, i1 }* %177, align 4
  %178 = getelementptr inbounds i8, i8* %26, i64 480
  %179 = bitcast i8* %178 to { i1, { i1, i64, i1 } }*
  %180 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %179, align 4
  %.fca.0.extract11.i.15 = extractvalue { i1, { i1, i64, i1 } } %180, 0
  br i1 %.fca.0.extract11.i.15, label %__hugr__.const_fun_306.310.exit.15, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.15:               ; preds = %__hugr__.const_fun_306.310.exit.14
  %181 = extractvalue { i1, { i1, i64, i1 } } %180, 1
  %182 = getelementptr inbounds i8, i8* %88, i64 360
  %183 = bitcast i8* %182 to { i1, i64, i1 }*
  store { i1, i64, i1 } %181, { i1, i64, i1 }* %183, align 4
  %184 = getelementptr inbounds i8, i8* %26, i64 512
  %185 = bitcast i8* %184 to { i1, { i1, i64, i1 } }*
  %186 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %185, align 4
  %.fca.0.extract11.i.16 = extractvalue { i1, { i1, i64, i1 } } %186, 0
  br i1 %.fca.0.extract11.i.16, label %__hugr__.const_fun_306.310.exit.16, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.16:               ; preds = %__hugr__.const_fun_306.310.exit.15
  %187 = extractvalue { i1, { i1, i64, i1 } } %186, 1
  %188 = getelementptr inbounds i8, i8* %88, i64 384
  %189 = bitcast i8* %188 to { i1, i64, i1 }*
  store { i1, i64, i1 } %187, { i1, i64, i1 }* %189, align 4
  %190 = getelementptr inbounds i8, i8* %26, i64 544
  %191 = bitcast i8* %190 to { i1, { i1, i64, i1 } }*
  %192 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %191, align 4
  %.fca.0.extract11.i.17 = extractvalue { i1, { i1, i64, i1 } } %192, 0
  br i1 %.fca.0.extract11.i.17, label %__hugr__.const_fun_306.310.exit.17, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.17:               ; preds = %__hugr__.const_fun_306.310.exit.16
  %193 = extractvalue { i1, { i1, i64, i1 } } %192, 1
  %194 = getelementptr inbounds i8, i8* %88, i64 408
  %195 = bitcast i8* %194 to { i1, i64, i1 }*
  store { i1, i64, i1 } %193, { i1, i64, i1 }* %195, align 4
  %196 = getelementptr inbounds i8, i8* %26, i64 576
  %197 = bitcast i8* %196 to { i1, { i1, i64, i1 } }*
  %198 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %197, align 4
  %.fca.0.extract11.i.18 = extractvalue { i1, { i1, i64, i1 } } %198, 0
  br i1 %.fca.0.extract11.i.18, label %__hugr__.const_fun_306.310.exit.18, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.18:               ; preds = %__hugr__.const_fun_306.310.exit.17
  %199 = extractvalue { i1, { i1, i64, i1 } } %198, 1
  %200 = getelementptr inbounds i8, i8* %88, i64 432
  %201 = bitcast i8* %200 to { i1, i64, i1 }*
  store { i1, i64, i1 } %199, { i1, i64, i1 }* %201, align 4
  %202 = getelementptr inbounds i8, i8* %26, i64 608
  %203 = bitcast i8* %202 to { i1, { i1, i64, i1 } }*
  %204 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %203, align 4
  %.fca.0.extract11.i.19 = extractvalue { i1, { i1, i64, i1 } } %204, 0
  br i1 %.fca.0.extract11.i.19, label %__hugr__.const_fun_306.310.exit.19, label %cond_692_case_0.i

__hugr__.const_fun_306.310.exit.19:               ; preds = %__hugr__.const_fun_306.310.exit.18
  %205 = extractvalue { i1, { i1, i64, i1 } } %204, 1
  %206 = getelementptr inbounds i8, i8* %88, i64 456
  %207 = bitcast i8* %206 to { i1, i64, i1 }*
  store { i1, i64, i1 } %205, { i1, i64, i1 }* %207, align 4
  tail call void @heap_free(i8* nonnull %26)
  tail call void @heap_free(i8* %27)
  br label %__barray_check_bounds.exit651

cond_606_case_0:                                  ; preds = %cond_exit_606
  %208 = load i64, i64* %91, align 4
  %209 = or i64 %208, -1048576
  store i64 %209, i64* %91, align 4
  %210 = icmp eq i64 %209, -1
  br i1 %210, label %loop_out282, label %mask_block_err.i649

mask_block_err.i649:                              ; preds = %cond_606_case_0
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit651:                    ; preds = %__hugr__.const_fun_306.310.exit.19, %cond_exit_606
  %"603_0.0704" = phi i64 [ 0, %__hugr__.const_fun_306.310.exit.19 ], [ %211, %cond_exit_606 ]
  %211 = add nuw nsw i64 %"603_0.0704", 1
  %212 = lshr i64 %"603_0.0704", 6
  %213 = getelementptr inbounds i64, i64* %91, i64 %212
  %214 = load i64, i64* %213, align 4
  %215 = shl nuw nsw i64 1, %"603_0.0704"
  %216 = and i64 %214, %215
  %.not681 = icmp eq i64 %216, 0
  br i1 %.not681, label %__barray_mask_borrow.exit656, label %cond_exit_606

__barray_mask_borrow.exit656:                     ; preds = %__barray_check_bounds.exit651
  %217 = xor i64 %214, %215
  store i64 %217, i64* %213, align 4
  %218 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %89, i64 %"603_0.0704"
  %219 = load { i1, i64, i1 }, { i1, i64, i1 }* %218, align 4
  %.fca.0.extract369 = extractvalue { i1, i64, i1 } %219, 0
  br i1 %.fca.0.extract369, label %cond_629_case_1, label %cond_exit_606

cond_exit_606:                                    ; preds = %cond_629_case_1, %__barray_mask_borrow.exit656, %__barray_check_bounds.exit651
  %220 = icmp ult i64 %"603_0.0704", 19
  br i1 %220, label %__barray_check_bounds.exit651, label %cond_606_case_0

loop_out282:                                      ; preds = %cond_606_case_0
  tail call void @heap_free(i8* %88)
  tail call void @heap_free(i8* nonnull %90)
  %221 = load i64, i64* %64, align 4
  %222 = and i64 %221, 1048575
  store i64 %222, i64* %64, align 4
  %223 = icmp eq i64 %222, 0
  br i1 %223, label %__barray_check_none_borrowed.exit661, label %mask_block_err.i660

__barray_check_none_borrowed.exit661:             ; preds = %loop_out282
  %224 = tail call i8* @heap_alloc(i64 20)
  %225 = tail call i8* @heap_alloc(i64 8)
  %226 = bitcast i8* %225 to i64*
  store i64 0, i64* %226, align 1
  br label %227

mask_block_err.i660:                              ; preds = %loop_out282
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_629_case_1:                                  ; preds = %__barray_mask_borrow.exit656
  %.fca.1.extract370 = extractvalue { i1, i64, i1 } %219, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract370)
  br label %cond_exit_606

227:                                              ; preds = %__barray_check_none_borrowed.exit661, %__hugr__.array.__read_bool.3.346.exit
  %storemerge693 = phi i64 [ 0, %__barray_check_none_borrowed.exit661 ], [ %232, %__hugr__.array.__read_bool.3.346.exit ]
  %228 = getelementptr inbounds { i1, i64, i1 }, { i1, i64, i1 }* %62, i64 %storemerge693
  %229 = load { i1, i64, i1 }, { i1, i64, i1 }* %228, align 4
  %.fca.0.extract.i662 = extractvalue { i1, i64, i1 } %229, 0
  %.fca.1.extract.i663 = extractvalue { i1, i64, i1 } %229, 1
  br i1 %.fca.0.extract.i662, label %cond_358_case_1.i, label %cond_358_case_0.i

cond_358_case_0.i:                                ; preds = %227
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %229, 2
  br label %__hugr__.array.__read_bool.3.346.exit

cond_358_case_1.i:                                ; preds = %227
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i663)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i663)
  br label %__hugr__.array.__read_bool.3.346.exit

__hugr__.array.__read_bool.3.346.exit:            ; preds = %cond_358_case_0.i, %cond_358_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_358_case_1.i ], [ %.fca.2.extract.i, %cond_358_case_0.i ]
  %230 = getelementptr inbounds i8, i8* %224, i64 %storemerge693
  %231 = bitcast i8* %230 to i1*
  store i1 %"03.0.i", i1* %231, align 1
  %232 = add nuw nsw i64 %storemerge693, 1
  %exitcond702.not = icmp eq i64 %232, 20
  br i1 %exitcond702.not, label %mask_block_ok.i666, label %227

mask_block_ok.i666:                               ; preds = %__hugr__.array.__read_bool.3.346.exit
  tail call void @heap_free(i8* nonnull %61)
  tail call void @heap_free(i8* %63)
  %233 = load i64, i64* %226, align 4
  %234 = and i64 %233, 1048575
  store i64 %234, i64* %226, align 4
  %235 = icmp eq i64 %234, 0
  br i1 %235, label %__barray_check_none_borrowed.exit668, label %mask_block_err.i667

__barray_check_none_borrowed.exit668:             ; preds = %mask_block_ok.i666
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %236 = alloca [20 x i1], align 1
  %.sub = getelementptr inbounds [20 x i1], [20 x i1]* %236, i64 0, i64 0
  %237 = bitcast [20 x i1]* %236 to i8*
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(20) %237, i8 0, i64 20, i1 false)
  store i32 20, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %238 = bitcast i1** %arr_ptr to i8**
  store i8* %224, i8** %238, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @res_tail.AD5A440E.0, i64 0, i64 0), i64 17, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  ret void

mask_block_err.i667:                              ; preds = %mask_block_ok.i666
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
