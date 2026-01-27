; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

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

define internal fastcc void @__hugr__.__main__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 160)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_380_case_0.i, label %__hugr__.__tk2_qalloc.385.exit

cond_380_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.385.exit:                   ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rxy(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18)
  br label %cond_21_case_1

2:                                                ; preds = %cond_314_case_0, %73
  %"148_0252.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"148_0252.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"148_0252.fca.0.insert", ptr %1, 1
  %"148_0252.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"148_0252.fca.1.insert", i64 0, 2
  %3 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"148_0252.fca.2.insert", 0
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
  br i1 %.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(20).445.exit", label %mask_block_ok.i.i.i

24:                                               ; preds = %mask_block_ok.i.i.i
  %25 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(20).445.exit", label %mask_block_ok.i.i.i

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
  %"471_0.sroa.15.0184.i" = phi i64 [ 0, %2 ], [ %28, %loop_body.i ]
  %.pn165183.i = phi { { ptr, ptr, i64 }, i64 } [ %3, %2 ], [ %43, %loop_body.i ]
  %28 = add nuw nsw i64 %"471_0.sroa.15.0184.i", 1
  %29 = add i64 %"471_0.sroa.15.0184.i", %.fca.2.extract82.i187.i
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
  %41 = lshr i64 %40, %"471_0.sroa.15.0184.i"
  %42 = trunc i64 %41 to i1
  br i1 %42, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"536_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"536_054.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"536_054.fca.1.insert.i", i1 undef, 2
  %43 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, i64 %28, 1
  %44 = shl nuw nsw i64 1, %"471_0.sroa.15.0184.i"
  %45 = xor i64 %40, %44
  store i64 %45, ptr %5, align 4
  %46 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %4, i64 %"471_0.sroa.15.0184.i"
  store { i1, i64, i1 } %"536_054.fca.2.insert.i", ptr %46, align 4
  %47 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %47, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %47, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %47, 2
  %exitcond.not.i = icmp eq i64 %28, 20
  br i1 %exitcond.not.i, label %6, label %__barray_check_bounds.exit.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(20).445.exit": ; preds = %24, %6
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

cond_21_case_1:                                   ; preds = %__hugr__.__tk2_qalloc.385.exit, %cond_exit_21
  %"16_0.sroa.0.0660" = phi i64 [ 0, %__hugr__.__tk2_qalloc.385.exit ], [ %53, %cond_exit_21 ]
  %53 = add nuw nsw i64 %"16_0.sroa.0.0660", 1
  %qalloc.i604 = tail call i64 @___qalloc()
  %not_max.not.not.i605 = icmp eq i64 %qalloc.i604, -1
  br i1 %not_max.not.not.i605, label %cond_360_case_0.i, label %__barray_check_bounds.exit

cond_360_case_0.i:                                ; preds = %cond_21_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_21_case_1
  tail call void @___reset(i64 %qalloc.i604)
  %54 = load i64, ptr %1, align 4
  %55 = lshr i64 %54, %"16_0.sroa.0.0660"
  %56 = trunc i64 %55 to i1
  br i1 %56, label %cond_exit_21, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_21:                                     ; preds = %__barray_check_bounds.exit
  %57 = shl nuw nsw i64 1, %"16_0.sroa.0.0660"
  %58 = xor i64 %54, %57
  store i64 %58, ptr %1, align 4
  %59 = getelementptr inbounds nuw i64, ptr %0, i64 %"16_0.sroa.0.0660"
  store i64 %qalloc.i604, ptr %59, align 4
  %exitcond.not = icmp eq i64 %53, 20
  br i1 %exitcond.not, label %__barray_check_bounds.exit607, label %cond_21_case_1

__barray_check_bounds.exit607:                    ; preds = %cond_exit_21, %__barray_mask_return.exit612
  %"48_0.0661" = phi i64 [ %60, %__barray_mask_return.exit612 ], [ 0, %cond_exit_21 ]
  %60 = add nuw nsw i64 %"48_0.0661", 1
  %61 = load i64, ptr %1, align 4
  %62 = lshr i64 %61, %"48_0.0661"
  %63 = trunc i64 %62 to i1
  br i1 %63, label %panic.i608, label %__barray_check_bounds.exit610

panic.i608:                                       ; preds = %__barray_check_bounds.exit607
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit610:                    ; preds = %__barray_check_bounds.exit607
  %64 = shl nuw nsw i64 1, %"48_0.0661"
  %65 = xor i64 %61, %64
  store i64 %65, ptr %1, align 4
  %66 = getelementptr inbounds nuw i64, ptr %0, i64 %"48_0.0661"
  %67 = load i64, ptr %66, align 4
  tail call void @___rxy(i64 %67, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %qalloc.i, i64 %67, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %67, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %67, double 0xBFF921FB54442D18)
  %68 = load i64, ptr %1, align 4
  %69 = lshr i64 %68, %"48_0.0661"
  %70 = trunc i64 %69 to i1
  br i1 %70, label %__barray_mask_return.exit612, label %panic.i611

panic.i611:                                       ; preds = %__barray_check_bounds.exit610
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit612:                     ; preds = %__barray_check_bounds.exit610
  %71 = xor i64 %68, %64
  store i64 %71, ptr %1, align 4
  store i64 %67, ptr %66, align 4
  %exitcond669.not = icmp eq i64 %60, 20
  br i1 %exitcond669.not, label %cond_exit_82, label %__barray_check_bounds.exit607

72:                                               ; preds = %cond_exit_82
  %read_uint.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %.not = icmp eq i64 %read_uint.i, 2
  br i1 %.not, label %cond_133_case_0, label %cond_314_case_0

73:                                               ; preds = %cond_exit_82
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  tail call void @print_int(ptr nonnull @res_head_leake.F4F32972.0, i64 20, i64 1)
  br label %2

cond_exit_82:                                     ; preds = %__barray_mask_return.exit612
  %lazy_measure_leaked.i = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___inc_future_refcount(i64 %lazy_measure_leaked.i)
  %read_uint.i613 = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %74 = icmp eq i64 %read_uint.i613, 2
  br i1 %74, label %73, label %72

cond_133_case_0:                                  ; preds = %72
  tail call void @panic(i32 1001, ptr nonnull @e_Option.unw.32D4E82D.0)
  unreachable

cond_314_case_0:                                  ; preds = %72
  %75 = icmp eq i64 %read_uint.i, 1
  tail call void @print_bool(ptr nonnull @res_head.AFE8E005.0, i64 14, i1 %75)
  br label %2

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(20).445.exit"
  %76 = tail call ptr @heap_alloc(i64 480)
  %77 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %77, align 1
  br label %78

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(20).445.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

78:                                               ; preds = %__barray_check_none_borrowed.exit, %"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).163.exit"
  %storemerge563666 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %86, %"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).163.exit" ]
  %79 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %4, i64 %storemerge563666
  %80 = load { i1, i64, i1 }, ptr %79, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %80, 0
  br i1 %.fca.0.extract118.i, label %cond_159_case_1.i, label %cond_159_case_0.i

cond_159_case_0.i:                                ; preds = %78
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %80, 2
  br label %cond_exit_159.i

cond_159_case_1.i:                                ; preds = %78
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %80, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_159.i

cond_exit_159.i:                                  ; preds = %cond_159_case_0.i, %cond_159_case_1.i
  %"05.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_159_case_1.i ], [ undef, %cond_159_case_0.i ]
  %"05.sroa.6.0.i" = phi i1 [ undef, %cond_159_case_1.i ], [ %.fca.2.extract120.i, %cond_159_case_0.i ]
  %81 = load i64, ptr %49, align 4
  %82 = lshr i64 %81, %storemerge563666
  %83 = trunc i64 %82 to i1
  br i1 %83, label %panic.i.i617, label %cond_546_case_1.i

panic.i.i617:                                     ; preds = %cond_exit_159.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_546_case_1.i:                                ; preds = %cond_exit_159.i
  %"18.fca.1.insert.i" = insertvalue { i1, i64, i1 } %80, i64 %"05.sroa.3.0.i", 1
  %"18.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"18.fca.1.insert.i", i1 %"05.sroa.6.0.i", 2
  %84 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"18.fca.2.insert.i", 1
  %85 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %48, i64 %storemerge563666
  %.fca.2.0.extract.i = load i1, ptr %85, align 1
  store { i1, { i1, i64, i1 } } %84, ptr %85, align 4
  br i1 %.fca.2.0.extract.i, label %cond_547_case_1.i, label %"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).163.exit"

cond_547_case_1.i:                                ; preds = %cond_546_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).163.exit": ; preds = %cond_546_case_1.i
  %86 = add nuw nsw i64 %storemerge563666, 1
  %87 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %76, i64 %storemerge563666
  store { i1, i64, i1 } %"18.fca.2.insert.i", ptr %87, align 4
  %exitcond670.not = icmp eq i64 %86, 20
  br i1 %exitcond670.not, label %mask_block_ok.i618, label %78

mask_block_ok.i618:                               ; preds = %"__hugr__.$__copy_scan$$n(20)$t([Bool]+[Future(Bool)])$n(1).163.exit"
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  %88 = load i64, ptr %49, align 4
  %89 = and i64 %88, 1048575
  store i64 %89, ptr %49, align 4
  %90 = icmp eq i64 %89, 0
  br i1 %90, label %__barray_check_none_borrowed.exit623, label %mask_block_err.i621

__barray_check_none_borrowed.exit623:             ; preds = %mask_block_ok.i618
  %91 = tail call ptr @heap_alloc(i64 480)
  %92 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %92, align 1
  br label %93

mask_block_err.i621:                              ; preds = %mask_block_ok.i618
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

93:                                               ; preds = %__barray_check_none_borrowed.exit623, %93
  %storemerge568667 = phi i64 [ 0, %__barray_check_none_borrowed.exit623 ], [ %99, %93 ]
  %94 = getelementptr { i1, { i1, i64, i1 } }, ptr %48, i64 %storemerge568667
  %95 = load { i1, { i1, i64, i1 } }, ptr %94, align 4
  %96 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).585"({ i1, { i1, i64, i1 } } %95)
  %97 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %91, i64 %storemerge568667
  %98 = extractvalue { { i1, i64, i1 } } %96, 0
  store { i1, i64, i1 } %98, ptr %97, align 4
  %99 = add nuw nsw i64 %storemerge568667, 1
  %exitcond671.not = icmp eq i64 %99, 20
  br i1 %exitcond671.not, label %100, label %93

100:                                              ; preds = %93
  tail call void @heap_free(ptr nonnull %48)
  tail call void @heap_free(ptr nonnull %49)
  br label %__barray_check_bounds.exit630

cond_676_case_0:                                  ; preds = %cond_exit_676
  %101 = load i64, ptr %92, align 4
  %102 = or i64 %101, -1048576
  store i64 %102, ptr %92, align 4
  %103 = icmp eq i64 %102, -1
  br i1 %103, label %loop_out276, label %mask_block_err.i627

mask_block_err.i627:                              ; preds = %cond_676_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit630:                    ; preds = %100, %cond_exit_676
  %"673_0.0674" = phi i64 [ 0, %100 ], [ %104, %cond_exit_676 ]
  %104 = add nuw nsw i64 %"673_0.0674", 1
  %105 = load i64, ptr %92, align 4
  %106 = lshr i64 %105, %"673_0.0674"
  %107 = trunc i64 %106 to i1
  br i1 %107, label %cond_exit_676, label %__barray_mask_borrow.exit634

__barray_mask_borrow.exit634:                     ; preds = %__barray_check_bounds.exit630
  %108 = shl nuw nsw i64 1, %"673_0.0674"
  %109 = xor i64 %105, %108
  store i64 %109, ptr %92, align 4
  %110 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %91, i64 %"673_0.0674"
  %111 = load { i1, i64, i1 }, ptr %110, align 4
  %.fca.0.extract364 = extractvalue { i1, i64, i1 } %111, 0
  br i1 %.fca.0.extract364, label %cond_699_case_1, label %cond_exit_676

cond_exit_676:                                    ; preds = %cond_699_case_1, %__barray_mask_borrow.exit634, %__barray_check_bounds.exit630
  %112 = icmp samesign ugt i64 %"673_0.0674", 18
  br i1 %112, label %cond_676_case_0, label %__barray_check_bounds.exit630

loop_out276:                                      ; preds = %cond_676_case_0
  tail call void @heap_free(ptr %91)
  tail call void @heap_free(ptr nonnull %92)
  %113 = load i64, ptr %77, align 4
  %114 = and i64 %113, 1048575
  store i64 %114, ptr %77, align 4
  %115 = icmp eq i64 %114, 0
  br i1 %115, label %__barray_check_none_borrowed.exit640, label %mask_block_err.i638

__barray_check_none_borrowed.exit640:             ; preds = %loop_out276
  %116 = tail call ptr @heap_alloc(i64 20)
  %117 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %117, align 1
  br label %118

mask_block_err.i638:                              ; preds = %loop_out276
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_699_case_1:                                  ; preds = %__barray_mask_borrow.exit634
  %.fca.1.extract365 = extractvalue { i1, i64, i1 } %111, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract365)
  br label %cond_exit_676

118:                                              ; preds = %__barray_check_none_borrowed.exit640, %118
  %storemerge569668 = phi i64 [ 0, %__barray_check_none_borrowed.exit640 ], [ %124, %118 ]
  %119 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %76, i64 %storemerge569668
  %120 = load { i1, i64, i1 }, ptr %119, align 4
  %121 = tail call { i1 } @__hugr__.array.__read_bool.3.347({ i1, i64, i1 } %120)
  %122 = getelementptr inbounds nuw i1, ptr %116, i64 %storemerge569668
  %123 = extractvalue { i1 } %121, 0
  store i1 %123, ptr %122, align 1
  %124 = add nuw nsw i64 %storemerge569668, 1
  %exitcond672.not = icmp eq i64 %124, 20
  br i1 %exitcond672.not, label %mask_block_ok.i641, label %118

mask_block_ok.i641:                               ; preds = %118
  tail call void @heap_free(ptr nonnull %76)
  tail call void @heap_free(ptr nonnull %77)
  %125 = load i64, ptr %117, align 4
  %126 = and i64 %125, 1048575
  store i64 %126, ptr %117, align 4
  %127 = icmp eq i64 %126, 0
  br i1 %127, label %__barray_check_none_borrowed.exit646, label %mask_block_err.i644

__barray_check_none_borrowed.exit646:             ; preds = %mask_block_ok.i641
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %128 = alloca [20 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %128, i8 0, i64 20, i1 false)
  store i32 20, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %116, ptr %arr_ptr, align 8
  store ptr %128, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_tail.AD5A440E.0, i64 17, ptr nonnull %out_arr_alloca)
  ret void

mask_block_err.i644:                              ; preds = %mask_block_ok.i641
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

define internal i1 @__hugr__.array.__read_bool.3.347({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_342_case_1, label %cond_342_case_0

cond_342_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_342

cond_342_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_342

cond_exit_342:                                    ; preds = %cond_342_case_1, %cond_342_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_342_case_1 ], [ %.fca.2.extract, %cond_342_case_0 ]
  ret i1 %"03.0"
}

declare void @heap_free(ptr) local_unnamed_addr

define internal { i1, i64, i1 } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).585"({ i1, { i1, i64, i1 } } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract11 = extractvalue { i1, { i1, i64, i1 } } %0, 0
  br i1 %.fca.0.extract11, label %cond_588_case_1, label %cond_588_case_0

cond_588_case_1:                                  ; preds = %alloca_block
  %1 = extractvalue { i1, { i1, i64, i1 } } %0, 1
  ret { i1, i64, i1 } %1

cond_588_case_0:                                  ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.E6312129.0")
  unreachable
}

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

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
