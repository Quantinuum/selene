; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define internal fastcc void @__hugr__.__main__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 560)
  %1 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %1, i8 -1, i64 16, i1 false)
  br label %cond_20_case_1

2:                                                ; preds = %finish, %__barray_mask_return.exit725
  %exitcond748.not = icmp eq i64 %140, 70
  br i1 %exitcond748.not, label %cond_exit_84, label %finish

cond_20_case_1:                                   ; preds = %alloca_block, %cond_exit_20
  %"15_0.sroa.0.0739" = phi i64 [ 0, %alloca_block ], [ %3, %cond_exit_20 ]
  %3 = add nuw nsw i64 %"15_0.sroa.0.0739", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_348_case_0.i, label %__barray_check_bounds.exit

cond_348_case_0.i:                                ; preds = %cond_20_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_20_case_1
  tail call void @___reset(i64 %qalloc.i)
  %4 = lshr i64 %"15_0.sroa.0.0739", 6
  %5 = getelementptr inbounds nuw i64, ptr %1, i64 %4
  %6 = load i64, ptr %5, align 4
  %7 = and i64 %"15_0.sroa.0.0739", 63
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
  %12 = getelementptr inbounds nuw i64, ptr %0, i64 %"15_0.sroa.0.0739"
  store i64 %qalloc.i, ptr %12, align 4
  %exitcond.not = icmp eq i64 %3, 70
  br i1 %exitcond.not, label %loop_out, label %cond_20_case_1

loop_out:                                         ; preds = %cond_exit_20
  %"117.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"117.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"117.fca.0.insert", ptr %1, 1
  %"117.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"117.fca.1.insert", i64 0, 2
  br label %finish

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit"
  %13 = tail call ptr @heap_alloc(i64 1680)
  %14 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %14, i8 0, i64 16, i1 false)
  br label %15

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

15:                                               ; preds = %__barray_check_none_borrowed.exit, %"__hugr__.$__copy_scan$$n(70)$t([Bool]+[Future(Bool)])$n(1).298.exit"
  %storemerge588745 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %26, %"__hugr__.$__copy_scan$$n(70)$t([Bool]+[Future(Bool)])$n(1).298.exit" ]
  %16 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %85, i64 %storemerge588745
  %17 = load { i1, i64, i1 }, ptr %16, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %17, 0
  br i1 %.fca.0.extract118.i, label %cond_288_case_1.i, label %cond_288_case_0.i

cond_288_case_0.i:                                ; preds = %15
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %17, 2
  br label %cond_exit_288.i

cond_288_case_1.i:                                ; preds = %15
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %17, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_288.i

cond_exit_288.i:                                  ; preds = %cond_288_case_0.i, %cond_288_case_1.i
  %"03.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_288_case_1.i ], [ undef, %cond_288_case_0.i ]
  %"03.sroa.6.0.i" = phi i1 [ undef, %cond_288_case_1.i ], [ %.fca.2.extract120.i, %cond_288_case_0.i ]
  %18 = lshr i64 %storemerge588745, 6
  %19 = getelementptr inbounds nuw i64, ptr %133, i64 %18
  %20 = load i64, ptr %19, align 4
  %21 = and i64 %storemerge588745, 63
  %22 = lshr i64 %20, %21
  %23 = trunc i64 %22 to i1
  br i1 %23, label %panic.i.i, label %cond_285_case_1.i

panic.i.i:                                        ; preds = %cond_exit_288.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_285_case_1.i:                                ; preds = %cond_exit_288.i
  %"16.fca.1.insert.i" = insertvalue { i1, i64, i1 } %17, i64 %"03.sroa.3.0.i", 1
  %"16.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i", i1 %"03.sroa.6.0.i", 2
  %24 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i", 1
  %25 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %132, i64 %storemerge588745
  %.fca.2.0.extract.i = load i1, ptr %25, align 1
  store { i1, { i1, i64, i1 } } %24, ptr %25, align 4
  br i1 %.fca.2.0.extract.i, label %cond_284_case_1.i, label %"__hugr__.$__copy_scan$$n(70)$t([Bool]+[Future(Bool)])$n(1).298.exit"

cond_284_case_1.i:                                ; preds = %cond_285_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(70)$t([Bool]+[Future(Bool)])$n(1).298.exit": ; preds = %cond_285_case_1.i
  %26 = add nuw nsw i64 %storemerge588745, 1
  %27 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %13, i64 %storemerge588745
  store { i1, i64, i1 } %"16.fca.2.insert.i", ptr %27, align 4
  %exitcond749.not = icmp eq i64 %26, 70
  br i1 %exitcond749.not, label %mask_block_ok.i688, label %15

mask_block_ok.i688:                               ; preds = %"__hugr__.$__copy_scan$$n(70)$t([Bool]+[Future(Bool)])$n(1).298.exit"
  tail call void @heap_free(ptr nonnull %85)
  tail call void @heap_free(ptr nonnull %86)
  %28 = getelementptr i8, ptr %133, i64 8
  %29 = load i64, ptr %28, align 4
  %30 = and i64 %29, 63
  store i64 %30, ptr %28, align 4
  %31 = load i64, ptr %133, align 4
  %32 = icmp eq i64 %31, 0
  %33 = icmp eq i64 %30, 0
  %or.cond754 = select i1 %32, i1 %33, i1 false
  br i1 %or.cond754, label %__barray_check_none_borrowed.exit693, label %mask_block_err.i691

__barray_check_none_borrowed.exit693:             ; preds = %mask_block_ok.i688
  %34 = tail call ptr @heap_alloc(i64 1680)
  %35 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %35, i8 0, i64 16, i1 false)
  br label %36

mask_block_err.i691:                              ; preds = %mask_block_ok.i688
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

36:                                               ; preds = %__barray_check_none_borrowed.exit693, %36
  %storemerge593746 = phi i64 [ 0, %__barray_check_none_borrowed.exit693 ], [ %42, %36 ]
  %37 = getelementptr { i1, { i1, i64, i1 } }, ptr %132, i64 %storemerge593746
  %38 = load { i1, { i1, i64, i1 } }, ptr %37, align 4
  %39 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).248"({ i1, { i1, i64, i1 } } %38)
  %40 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %34, i64 %storemerge593746
  %41 = extractvalue { { i1, i64, i1 } } %39, 0
  store { i1, i64, i1 } %41, ptr %40, align 4
  %42 = add nuw nsw i64 %storemerge593746, 1
  %exitcond750.not = icmp eq i64 %42, 70
  br i1 %exitcond750.not, label %43, label %36

43:                                               ; preds = %36
  tail call void @heap_free(ptr nonnull %132)
  tail call void @heap_free(ptr nonnull %133)
  %44 = getelementptr i8, ptr %35, i64 8
  br label %__barray_check_bounds.exit700

cond_560_case_0:                                  ; preds = %cond_exit_560
  %45 = load i64, ptr %44, align 4
  %46 = or i64 %45, -64
  store i64 %46, ptr %44, align 4
  %47 = load i64, ptr %35, align 4
  %48 = icmp eq i64 %47, -1
  %49 = icmp eq i64 %46, -1
  %or.cond755 = select i1 %48, i1 %49, i1 false
  br i1 %or.cond755, label %loop_out148, label %mask_block_err.i697

mask_block_err.i697:                              ; preds = %cond_560_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit700:                    ; preds = %43, %cond_exit_560
  %"557_0.0758" = phi i64 [ 0, %43 ], [ %50, %cond_exit_560 ]
  %50 = add nuw nsw i64 %"557_0.0758", 1
  %51 = lshr i64 %"557_0.0758", 6
  %52 = getelementptr inbounds nuw i64, ptr %35, i64 %51
  %53 = load i64, ptr %52, align 4
  %54 = and i64 %"557_0.0758", 63
  %55 = lshr i64 %53, %54
  %56 = trunc i64 %55 to i1
  br i1 %56, label %cond_exit_560, label %__barray_mask_borrow.exit

__barray_mask_borrow.exit:                        ; preds = %__barray_check_bounds.exit700
  %57 = shl nuw i64 1, %54
  %58 = xor i64 %53, %57
  store i64 %58, ptr %52, align 4
  %59 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %34, i64 %"557_0.0758"
  %60 = load { i1, i64, i1 }, ptr %59, align 4
  %.fca.0.extract399 = extractvalue { i1, i64, i1 } %60, 0
  br i1 %.fca.0.extract399, label %cond_583_case_1, label %cond_exit_560

cond_exit_560:                                    ; preds = %cond_583_case_1, %__barray_mask_borrow.exit, %__barray_check_bounds.exit700
  %61 = icmp samesign ugt i64 %"557_0.0758", 68
  br i1 %61, label %cond_560_case_0, label %__barray_check_bounds.exit700

loop_out148:                                      ; preds = %cond_560_case_0
  tail call void @heap_free(ptr %34)
  tail call void @heap_free(ptr nonnull %35)
  %62 = getelementptr i8, ptr %14, i64 8
  %63 = load i64, ptr %62, align 4
  %64 = and i64 %63, 63
  store i64 %64, ptr %62, align 4
  %65 = load i64, ptr %14, align 4
  %66 = icmp eq i64 %65, 0
  %67 = icmp eq i64 %64, 0
  %or.cond756 = select i1 %66, i1 %67, i1 false
  br i1 %or.cond756, label %__barray_check_none_borrowed.exit709, label %mask_block_err.i707

__barray_check_none_borrowed.exit709:             ; preds = %loop_out148
  %68 = tail call ptr @heap_alloc(i64 70)
  %69 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %69, i8 0, i64 16, i1 false)
  br label %70

mask_block_err.i707:                              ; preds = %loop_out148
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_583_case_1:                                  ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract400 = extractvalue { i1, i64, i1 } %60, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract400)
  br label %cond_exit_560

70:                                               ; preds = %__barray_check_none_borrowed.exit709, %70
  %storemerge594747 = phi i64 [ 0, %__barray_check_none_borrowed.exit709 ], [ %76, %70 ]
  %71 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %13, i64 %storemerge594747
  %72 = load { i1, i64, i1 }, ptr %71, align 4
  %73 = tail call { i1 } @__hugr__.array.__read_bool.3.294({ i1, i64, i1 } %72)
  %74 = getelementptr inbounds nuw i1, ptr %68, i64 %storemerge594747
  %75 = extractvalue { i1 } %73, 0
  store i1 %75, ptr %74, align 1
  %76 = add nuw nsw i64 %storemerge594747, 1
  %exitcond751.not = icmp eq i64 %76, 70
  br i1 %exitcond751.not, label %mask_block_ok.i710, label %70

mask_block_ok.i710:                               ; preds = %70
  tail call void @heap_free(ptr nonnull %13)
  tail call void @heap_free(ptr nonnull %14)
  %77 = getelementptr i8, ptr %69, i64 8
  %78 = load i64, ptr %77, align 4
  %79 = and i64 %78, 63
  store i64 %79, ptr %77, align 4
  %80 = load i64, ptr %69, align 4
  %81 = icmp eq i64 %80, 0
  %82 = icmp eq i64 %79, 0
  %or.cond757 = select i1 %81, i1 %82, i1 false
  br i1 %or.cond757, label %__barray_check_none_borrowed.exit715, label %mask_block_err.i713

__barray_check_none_borrowed.exit715:             ; preds = %mask_block_ok.i710
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %83 = alloca [70 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(70) %83, i8 0, i64 70, i1 false)
  store i32 70, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %68, ptr %arr_ptr, align 8
  store ptr %83, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  ret void

mask_block_err.i713:                              ; preds = %mask_block_ok.i710
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_84:                                     ; preds = %2
  %84 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"117.fca.2.insert", 0
  %85 = tail call ptr @heap_alloc(i64 1680)
  %86 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %86, i8 -1, i64 16, i1 false)
  br label %__barray_check_bounds.exit.i.i

87:                                               ; preds = %loop_body.i
  %88 = lshr i64 %.fca.2.extract82.i.i, 6
  %89 = getelementptr i64, ptr %.fca.1.extract81.i.i, i64 %88
  %90 = load i64, ptr %89, align 4
  %91 = and i64 %.fca.2.extract82.i.i, 63
  %92 = sub nuw nsw i64 64, %91
  %93 = lshr i64 -1, %92
  %94 = icmp eq i64 %91, 0
  %95 = select i1 %94, i64 0, i64 %93
  %96 = or i64 %90, %95
  store i64 %96, ptr %89, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract82.i.i, 69
  %97 = lshr i64 %last_valid.i.i.i, 6
  %98 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i.i, i64 %97
  %99 = load i64, ptr %98, align 4
  %100 = and i64 %last_valid.i.i.i, 63
  %101 = shl nsw i64 -2, %100
  %102 = icmp eq i64 %100, 63
  %103 = select i1 %102, i64 0, i64 %101
  %104 = or i64 %99, %103
  store i64 %104, ptr %98, align 4
  %reass.sub.i.i.i = sub nsw i64 %97, %88
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit", label %mask_block_ok.i.i.i

105:                                              ; preds = %mask_block_ok.i.i.i
  %106 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %87, %105
  %.02.i.i.i = phi i64 [ %106, %105 ], [ 0, %87 ]
  %gep.i.i.i = getelementptr i64, ptr %89, i64 %.02.i.i.i
  %107 = load i64, ptr %gep.i.i.i, align 4
  %108 = icmp eq i64 %107, -1
  br i1 %108, label %105, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_84
  %.fca.2.extract82.i188.i = phi i64 [ 0, %cond_exit_84 ], [ %.fca.2.extract82.i.i, %loop_body.i ]
  %.fca.1.extract81.i187.i = phi ptr [ %1, %cond_exit_84 ], [ %.fca.1.extract81.i.i, %loop_body.i ]
  %.fca.0.extract80.i186.i = phi ptr [ %0, %cond_exit_84 ], [ %.fca.0.extract80.i.i, %loop_body.i ]
  %"427_0.sroa.15.0185.i" = phi i64 [ 0, %cond_exit_84 ], [ %109, %loop_body.i ]
  %.pn166184.i = phi { { ptr, ptr, i64 }, i64 } [ %84, %cond_exit_84 ], [ %127, %loop_body.i ]
  %109 = add nuw nsw i64 %"427_0.sroa.15.0185.i", 1
  %110 = add i64 %"427_0.sroa.15.0185.i", %.fca.2.extract82.i188.i
  %111 = lshr i64 %110, 6
  %112 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i187.i, i64 %111
  %113 = load i64, ptr %112, align 4
  %114 = and i64 %110, 63
  %115 = lshr i64 %113, %114
  %116 = trunc i64 %115 to i1
  br i1 %116, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %117 = shl nuw i64 1, %114
  %118 = xor i64 %117, %113
  store i64 %118, ptr %112, align 4
  %119 = getelementptr inbounds i64, ptr %.fca.0.extract80.i186.i, i64 %110
  %120 = load i64, ptr %119, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %120)
  tail call void @___qfree(i64 %120)
  %121 = lshr i64 %"427_0.sroa.15.0185.i", 6
  %122 = getelementptr inbounds nuw i64, ptr %86, i64 %121
  %123 = load i64, ptr %122, align 4
  %124 = and i64 %"427_0.sroa.15.0185.i", 63
  %125 = lshr i64 %123, %124
  %126 = trunc i64 %125 to i1
  br i1 %126, label %loop_body.i, label %panic.i.i716

panic.i.i716:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"492_055.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"492_055.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"492_055.fca.1.insert.i", i1 undef, 2
  %127 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn166184.i, i64 %109, 1
  %128 = shl nuw i64 1, %124
  %129 = xor i64 %123, %128
  store i64 %129, ptr %122, align 4
  %130 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %85, i64 %"427_0.sroa.15.0185.i"
  store { i1, i64, i1 } %"492_055.fca.2.insert.i", ptr %130, align 4
  %131 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn166184.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %131, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %131, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %131, 2
  %exitcond.not.i717 = icmp eq i64 %109, 70
  br i1 %exitcond.not.i717, label %87, label %__barray_check_bounds.exit.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(70).401.exit": ; preds = %105, %87
  tail call void @heap_free(ptr %.fca.0.extract80.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract81.i.i)
  %132 = tail call ptr @heap_alloc(i64 2240)
  %133 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %133, i8 0, i64 16, i1 false)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(2240) %132, i8 0, i64 2240, i1 false)
  %134 = getelementptr i8, ptr %86, i64 8
  %135 = load i64, ptr %134, align 4
  %136 = and i64 %135, 63
  store i64 %136, ptr %134, align 4
  %137 = load i64, ptr %86, align 4
  %138 = icmp eq i64 %137, 0
  %139 = icmp eq i64 %136, 0
  %or.cond = select i1 %138, i1 %139, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

finish:                                           ; preds = %loop_out, %2
  %"47_0.0740" = phi i64 [ 0, %loop_out ], [ %140, %2 ]
  %140 = add nuw nsw i64 %"47_0.0740", 1
  %remainder.urem = and i64 %"47_0.0740", 1
  %141 = icmp eq i64 %remainder.urem, 0
  br i1 %141, label %__barray_check_bounds.exit719, label %2

__barray_check_bounds.exit719:                    ; preds = %finish
  %142 = lshr i64 %"47_0.0740", 6
  %143 = getelementptr inbounds nuw i64, ptr %1, i64 %142
  %144 = load i64, ptr %143, align 4
  %145 = and i64 %"47_0.0740", 62
  %146 = lshr i64 %144, %145
  %147 = trunc i64 %146 to i1
  br i1 %147, label %panic.i720, label %__barray_check_bounds.exit723

panic.i720:                                       ; preds = %__barray_check_bounds.exit719
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit723:                    ; preds = %__barray_check_bounds.exit719
  %148 = shl nuw nsw i64 1, %145
  %149 = xor i64 %144, %148
  store i64 %149, ptr %143, align 4
  %150 = getelementptr inbounds nuw i64, ptr %0, i64 %"47_0.0740"
  %151 = load i64, ptr %150, align 4
  tail call void @___rp(i64 %151, double 0x400921FB54442D18, double 0.000000e+00)
  %152 = load i64, ptr %143, align 4
  %153 = lshr i64 %152, %145
  %154 = trunc i64 %153 to i1
  br i1 %154, label %__barray_mask_return.exit725, label %panic.i724

panic.i724:                                       ; preds = %__barray_check_bounds.exit723
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit725:                     ; preds = %__barray_check_bounds.exit723
  %155 = xor i64 %152, %148
  store i64 %155, ptr %143, align 4
  store i64 %151, ptr %150, align 4
  br label %2
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

define internal i1 @__hugr__.array.__read_bool.3.294({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_366_case_1, label %cond_366_case_0

cond_366_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_366

cond_366_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_366

cond_exit_366:                                    ; preds = %cond_366_case_1, %cond_366_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_366_case_1 ], [ %.fca.2.extract, %cond_366_case_0 ]
  ret i1 %"03.0"
}

declare void @heap_free(ptr) local_unnamed_addr

define internal { i1, i64, i1 } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).248"({ i1, { i1, i64, i1 } } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract11 = extractvalue { i1, { i1, i64, i1 } } %0, 0
  br i1 %.fca.0.extract11, label %cond_252_case_1, label %cond_252_case_0

cond_252_case_1:                                  ; preds = %alloca_block
  %1 = extractvalue { i1, { i1, i64, i1 } } %0, 1
  ret { i1, i64, i1 } %1

cond_252_case_0:                                  ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.E6312129.0")
  unreachable
}

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

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
