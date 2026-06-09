; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@res_outcomes.9CB6D2E7.0 = private constant [22 x i8] c"\15USER:BOOLARR:outcomes"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 80)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit

cond_374_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.370.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_helios_qalloc.370.exit.8, %__hugr__.__tk2_helios_qalloc.370.exit.7, %__hugr__.__tk2_helios_qalloc.370.exit.6, %__hugr__.__tk2_helios_qalloc.370.exit.5, %__hugr__.__tk2_helios_qalloc.370.exit.4, %__hugr__.__tk2_helios_qalloc.370.exit.3, %__hugr__.__tk2_helios_qalloc.370.exit.2, %__hugr__.__tk2_helios_qalloc.370.exit.1, %__hugr__.__tk2_helios_qalloc.370.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.370.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit.1

__hugr__.__tk2_helios_qalloc.370.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not = icmp eq i64 %6, 0
  br i1 %.not, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.370.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit.2

__hugr__.__tk2_helios_qalloc.370.exit.2:          ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not586 = icmp eq i64 %10, 0
  br i1 %.not586, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_helios_qalloc.370.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit.3

__hugr__.__tk2_helios_qalloc.370.exit.3:          ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not587 = icmp eq i64 %14, 0
  br i1 %.not587, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_helios_qalloc.370.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit.4

__hugr__.__tk2_helios_qalloc.370.exit.4:          ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not588 = icmp eq i64 %18, 0
  br i1 %.not588, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_helios_qalloc.370.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit.5

__hugr__.__tk2_helios_qalloc.370.exit.5:          ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not589 = icmp eq i64 %22, 0
  br i1 %.not589, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_helios_qalloc.370.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit.6

__hugr__.__tk2_helios_qalloc.370.exit.6:          ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not590 = icmp eq i64 %26, 0
  br i1 %.not590, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_helios_qalloc.370.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit.7

__hugr__.__tk2_helios_qalloc.370.exit.7:          ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not591 = icmp eq i64 %30, 0
  br i1 %.not591, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__hugr__.__tk2_helios_qalloc.370.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_374_case_0.i, label %__hugr__.__tk2_helios_qalloc.370.exit.8

__hugr__.__tk2_helios_qalloc.370.exit.8:          ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not592 = icmp eq i64 %34, 0
  br i1 %.not592, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__hugr__.__tk2_helios_qalloc.370.exit.8
  %35 = and i64 %33, -257
  store i64 %35, ptr %1, align 4
  %36 = getelementptr inbounds nuw i8, ptr %0, i64 64
  store i64 %qalloc.i.8, ptr %36, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_374_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %37 = load i64, ptr %1, align 4
  %38 = and i64 %37, 512
  %.not593 = icmp eq i64 %38, 0
  br i1 %.not593, label %panic.i, label %cond_exit_20.9

cond_exit_20.9:                                   ; preds = %__barray_check_bounds.exit.9
  %39 = and i64 %37, -513
  store i64 %39, ptr %1, align 4
  %40 = getelementptr inbounds nuw i8, ptr %0, i64 72
  store i64 %qalloc.i.9, ptr %40, align 4
  %41 = load i64, ptr %1, align 4
  %42 = trunc i64 %41 to i1
  br i1 %42, label %panic.i510, label %__barray_mask_borrow.exit

panic.i510:                                       ; preds = %cond_exit_20.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.9
  %43 = or disjoint i64 %41, 1
  store i64 %43, ptr %1, align 4
  %44 = load i64, ptr %0, align 4
  tail call void @___rxy(i64 %44, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %44, double 0x400921FB54442D18)
  %45 = load i64, ptr %1, align 4
  %46 = trunc i64 %45 to i1
  br i1 %46, label %__barray_mask_return.exit512, label %panic.i511

panic.i511:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit512:                     ; preds = %__barray_mask_borrow.exit
  %47 = and i64 %45, -2
  store i64 %47, ptr %1, align 4
  store i64 %44, ptr %0, align 4
  br label %__barray_check_bounds.exit514

__barray_check_bounds.exit514:                    ; preds = %__barray_mask_return.exit528, %__barray_mask_return.exit512
  %"54_0.0575" = phi i64 [ 0, %__barray_mask_return.exit512 ], [ %48, %__barray_mask_return.exit528 ]
  %48 = add nuw nsw i64 %"54_0.0575", 1
  %49 = load i64, ptr %1, align 4
  %50 = lshr i64 %49, %"54_0.0575"
  %51 = trunc i64 %50 to i1
  br i1 %51, label %panic.i515, label %__barray_mask_borrow.exit516

panic.i515:                                       ; preds = %__barray_check_bounds.exit514
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit516:                     ; preds = %__barray_check_bounds.exit514
  %52 = shl nuw nsw i64 1, %"54_0.0575"
  %53 = xor i64 %49, %52
  store i64 %53, ptr %1, align 4
  %54 = getelementptr inbounds nuw i64, ptr %0, i64 %"54_0.0575"
  %55 = load i64, ptr %54, align 4
  %56 = lshr i64 %53, %48
  %57 = trunc i64 %56 to i1
  br i1 %57, label %panic.i519, label %__barray_check_bounds.exit522

panic.i519:                                       ; preds = %__barray_mask_borrow.exit516
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit522:                    ; preds = %__barray_mask_borrow.exit516
  %58 = shl nuw nsw i64 2, %"54_0.0575"
  %59 = xor i64 %53, %58
  store i64 %59, ptr %1, align 4
  %60 = getelementptr inbounds nuw i64, ptr %0, i64 %48
  %61 = load i64, ptr %60, align 4
  tail call void @___rxy(i64 %61, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %55, i64 %61, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %55, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %61, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %61, double 0xBFF921FB54442D18)
  %62 = load i64, ptr %1, align 4
  %63 = lshr i64 %62, %"54_0.0575"
  %64 = trunc i64 %63 to i1
  br i1 %64, label %__barray_check_bounds.exit526, label %panic.i523

panic.i523:                                       ; preds = %__barray_check_bounds.exit522
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit526:                    ; preds = %__barray_check_bounds.exit522
  %65 = xor i64 %62, %52
  store i64 %65, ptr %1, align 4
  store i64 %55, ptr %54, align 4
  %66 = load i64, ptr %1, align 4
  %67 = lshr i64 %66, %48
  %68 = trunc i64 %67 to i1
  br i1 %68, label %__barray_mask_return.exit528, label %panic.i527

panic.i527:                                       ; preds = %__barray_check_bounds.exit526
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit528:                     ; preds = %__barray_check_bounds.exit526
  %69 = xor i64 %66, %58
  store i64 %69, ptr %1, align 4
  store i64 %61, ptr %60, align 4
  %exitcond.not = icmp eq i64 %48, 9
  br i1 %exitcond.not, label %cond_exit_91, label %__barray_check_bounds.exit514

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.measure_array$10.222.exit"
  %70 = tail call ptr @heap_alloc(i64 240)
  %71 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %71, align 1
  br label %72

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.measure_array$10.222.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

72:                                               ; preds = %__barray_check_none_borrowed.exit, %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).419.exit"
  %storemerge479580 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %80, %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).419.exit" ]
  %73 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %205, i64 %storemerge479580
  %74 = load { i1, i64, i1 }, ptr %73, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %74, 0
  br i1 %.fca.0.extract118.i, label %cond_423_case_1.i, label %cond_423_case_0.i

cond_423_case_0.i:                                ; preds = %72
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %74, 2
  br label %cond_exit_423.i

cond_423_case_1.i:                                ; preds = %72
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %74, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_423.i

cond_exit_423.i:                                  ; preds = %cond_423_case_0.i, %cond_423_case_1.i
  %"04.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_423_case_1.i ], [ undef, %cond_423_case_0.i ]
  %"04.sroa.6.0.i" = phi i1 [ undef, %cond_423_case_1.i ], [ %.fca.2.extract120.i, %cond_423_case_0.i ]
  %75 = load i64, ptr %250, align 4
  %76 = lshr i64 %75, %storemerge479580
  %77 = trunc i64 %76 to i1
  br i1 %77, label %panic.i.i, label %cond_426_case_1.i

panic.i.i:                                        ; preds = %cond_exit_423.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_426_case_1.i:                                ; preds = %cond_exit_423.i
  %"17.fca.1.insert.i" = insertvalue { i1, i64, i1 } %74, i64 %"04.sroa.3.0.i", 1
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"17.fca.1.insert.i", i1 %"04.sroa.6.0.i", 2
  %78 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %79 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %249, i64 %storemerge479580
  %.fca.2.0.extract.i = load i1, ptr %79, align 1
  store { i1, { i1, i64, i1 } } %78, ptr %79, align 4
  br i1 %.fca.2.0.extract.i, label %cond_427_case_1.i, label %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).419.exit"

cond_427_case_1.i:                                ; preds = %cond_426_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).419.exit": ; preds = %cond_426_case_1.i
  %80 = add nuw nsw i64 %storemerge479580, 1
  %81 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %70, i64 %storemerge479580
  store { i1, i64, i1 } %"17.fca.2.insert.i", ptr %81, align 4
  %exitcond583.not = icmp eq i64 %80, 10
  br i1 %exitcond583.not, label %mask_block_ok.i530, label %72

mask_block_ok.i530:                               ; preds = %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).419.exit"
  tail call void @heap_free(ptr nonnull %205)
  tail call void @heap_free(ptr nonnull %206)
  %82 = load i64, ptr %250, align 4
  %83 = and i64 %82, 1023
  store i64 %83, ptr %250, align 4
  %84 = icmp eq i64 %83, 0
  br i1 %84, label %__barray_check_none_borrowed.exit535, label %mask_block_err.i533

__barray_check_none_borrowed.exit535:             ; preds = %mask_block_ok.i530
  %85 = tail call ptr @heap_alloc(i64 240)
  %86 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %86, align 1
  %87 = load { i1, { i1, i64, i1 } }, ptr %249, align 4
  %88 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %87)
  %89 = extractvalue { { i1, i64, i1 } } %88, 0
  store { i1, i64, i1 } %89, ptr %85, align 4
  %90 = getelementptr i8, ptr %249, i64 32
  %91 = load { i1, { i1, i64, i1 } }, ptr %90, align 4
  %92 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %91)
  %93 = getelementptr inbounds nuw i8, ptr %85, i64 24
  %94 = extractvalue { { i1, i64, i1 } } %92, 0
  store { i1, i64, i1 } %94, ptr %93, align 4
  %95 = getelementptr i8, ptr %249, i64 64
  %96 = load { i1, { i1, i64, i1 } }, ptr %95, align 4
  %97 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %96)
  %98 = getelementptr inbounds nuw i8, ptr %85, i64 48
  %99 = extractvalue { { i1, i64, i1 } } %97, 0
  store { i1, i64, i1 } %99, ptr %98, align 4
  %100 = getelementptr i8, ptr %249, i64 96
  %101 = load { i1, { i1, i64, i1 } }, ptr %100, align 4
  %102 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %101)
  %103 = getelementptr inbounds nuw i8, ptr %85, i64 72
  %104 = extractvalue { { i1, i64, i1 } } %102, 0
  store { i1, i64, i1 } %104, ptr %103, align 4
  %105 = getelementptr i8, ptr %249, i64 128
  %106 = load { i1, { i1, i64, i1 } }, ptr %105, align 4
  %107 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %106)
  %108 = getelementptr inbounds nuw i8, ptr %85, i64 96
  %109 = extractvalue { { i1, i64, i1 } } %107, 0
  store { i1, i64, i1 } %109, ptr %108, align 4
  %110 = getelementptr i8, ptr %249, i64 160
  %111 = load { i1, { i1, i64, i1 } }, ptr %110, align 4
  %112 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %111)
  %113 = getelementptr inbounds nuw i8, ptr %85, i64 120
  %114 = extractvalue { { i1, i64, i1 } } %112, 0
  store { i1, i64, i1 } %114, ptr %113, align 4
  %115 = getelementptr i8, ptr %249, i64 192
  %116 = load { i1, { i1, i64, i1 } }, ptr %115, align 4
  %117 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %116)
  %118 = getelementptr inbounds nuw i8, ptr %85, i64 144
  %119 = extractvalue { { i1, i64, i1 } } %117, 0
  store { i1, i64, i1 } %119, ptr %118, align 4
  %120 = getelementptr i8, ptr %249, i64 224
  %121 = load { i1, { i1, i64, i1 } }, ptr %120, align 4
  %122 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %121)
  %123 = getelementptr inbounds nuw i8, ptr %85, i64 168
  %124 = extractvalue { { i1, i64, i1 } } %122, 0
  store { i1, i64, i1 } %124, ptr %123, align 4
  %125 = getelementptr i8, ptr %249, i64 256
  %126 = load { i1, { i1, i64, i1 } }, ptr %125, align 4
  %127 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %126)
  %128 = getelementptr inbounds nuw i8, ptr %85, i64 192
  %129 = extractvalue { { i1, i64, i1 } } %127, 0
  store { i1, i64, i1 } %129, ptr %128, align 4
  %130 = getelementptr i8, ptr %249, i64 288
  %131 = load { i1, { i1, i64, i1 } }, ptr %130, align 4
  %132 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %131)
  %133 = getelementptr inbounds nuw i8, ptr %85, i64 216
  %134 = extractvalue { { i1, i64, i1 } } %132, 0
  store { i1, i64, i1 } %134, ptr %133, align 4
  tail call void @heap_free(ptr nonnull %249)
  tail call void @heap_free(ptr nonnull %250)
  br label %__barray_check_bounds.exit542

mask_block_err.i533:                              ; preds = %mask_block_ok.i530
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_537_case_0:                                  ; preds = %cond_exit_537
  %135 = load i64, ptr %86, align 4
  %136 = or i64 %135, -1024
  store i64 %136, ptr %86, align 4
  %137 = icmp eq i64 %136, -1
  br i1 %137, label %loop_out153, label %mask_block_err.i539

mask_block_err.i539:                              ; preds = %cond_537_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit542:                    ; preds = %__barray_check_none_borrowed.exit535, %cond_exit_537
  %"534_0.0595" = phi i64 [ 0, %__barray_check_none_borrowed.exit535 ], [ %138, %cond_exit_537 ]
  %138 = add nuw nsw i64 %"534_0.0595", 1
  %139 = load i64, ptr %86, align 4
  %140 = lshr i64 %139, %"534_0.0595"
  %141 = trunc i64 %140 to i1
  br i1 %141, label %cond_exit_537, label %__barray_mask_borrow.exit546

__barray_mask_borrow.exit546:                     ; preds = %__barray_check_bounds.exit542
  %142 = shl nuw nsw i64 1, %"534_0.0595"
  %143 = xor i64 %139, %142
  store i64 %143, ptr %86, align 4
  %144 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %85, i64 %"534_0.0595"
  %145 = load { i1, i64, i1 }, ptr %144, align 4
  %.fca.0.extract325 = extractvalue { i1, i64, i1 } %145, 0
  br i1 %.fca.0.extract325, label %cond_560_case_1, label %cond_exit_537

cond_exit_537:                                    ; preds = %cond_560_case_1, %__barray_mask_borrow.exit546, %__barray_check_bounds.exit542
  %146 = icmp samesign ugt i64 %"534_0.0595", 8
  br i1 %146, label %cond_537_case_0, label %__barray_check_bounds.exit542

loop_out153:                                      ; preds = %cond_537_case_0
  tail call void @heap_free(ptr nonnull %85)
  tail call void @heap_free(ptr nonnull %86)
  %147 = load i64, ptr %71, align 4
  %148 = and i64 %147, 1023
  store i64 %148, ptr %71, align 4
  %149 = icmp eq i64 %148, 0
  br i1 %149, label %__barray_check_none_borrowed.exit552, label %mask_block_err.i550

__barray_check_none_borrowed.exit552:             ; preds = %loop_out153
  %150 = tail call ptr @heap_alloc(i64 10)
  %151 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %151, align 1
  %152 = load { i1, i64, i1 }, ptr %70, align 4
  %153 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %152)
  %154 = extractvalue { i1 } %153, 0
  store i1 %154, ptr %150, align 1
  %155 = getelementptr inbounds nuw i8, ptr %70, i64 24
  %156 = load { i1, i64, i1 }, ptr %155, align 4
  %157 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %156)
  %158 = getelementptr inbounds nuw i8, ptr %150, i64 1
  %159 = extractvalue { i1 } %157, 0
  store i1 %159, ptr %158, align 1
  %160 = getelementptr inbounds nuw i8, ptr %70, i64 48
  %161 = load { i1, i64, i1 }, ptr %160, align 4
  %162 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %161)
  %163 = getelementptr inbounds nuw i8, ptr %150, i64 2
  %164 = extractvalue { i1 } %162, 0
  store i1 %164, ptr %163, align 1
  %165 = getelementptr inbounds nuw i8, ptr %70, i64 72
  %166 = load { i1, i64, i1 }, ptr %165, align 4
  %167 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %166)
  %168 = getelementptr inbounds nuw i8, ptr %150, i64 3
  %169 = extractvalue { i1 } %167, 0
  store i1 %169, ptr %168, align 1
  %170 = getelementptr inbounds nuw i8, ptr %70, i64 96
  %171 = load { i1, i64, i1 }, ptr %170, align 4
  %172 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %171)
  %173 = getelementptr inbounds nuw i8, ptr %150, i64 4
  %174 = extractvalue { i1 } %172, 0
  store i1 %174, ptr %173, align 1
  %175 = getelementptr inbounds nuw i8, ptr %70, i64 120
  %176 = load { i1, i64, i1 }, ptr %175, align 4
  %177 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %176)
  %178 = getelementptr inbounds nuw i8, ptr %150, i64 5
  %179 = extractvalue { i1 } %177, 0
  store i1 %179, ptr %178, align 1
  %180 = getelementptr inbounds nuw i8, ptr %70, i64 144
  %181 = load { i1, i64, i1 }, ptr %180, align 4
  %182 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %181)
  %183 = getelementptr inbounds nuw i8, ptr %150, i64 6
  %184 = extractvalue { i1 } %182, 0
  store i1 %184, ptr %183, align 1
  %185 = getelementptr inbounds nuw i8, ptr %70, i64 168
  %186 = load { i1, i64, i1 }, ptr %185, align 4
  %187 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %186)
  %188 = getelementptr inbounds nuw i8, ptr %150, i64 7
  %189 = extractvalue { i1 } %187, 0
  store i1 %189, ptr %188, align 1
  %190 = getelementptr inbounds nuw i8, ptr %70, i64 192
  %191 = load { i1, i64, i1 }, ptr %190, align 4
  %192 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %191)
  %193 = getelementptr inbounds nuw i8, ptr %150, i64 8
  %194 = extractvalue { i1 } %192, 0
  store i1 %194, ptr %193, align 1
  %195 = getelementptr inbounds nuw i8, ptr %70, i64 216
  %196 = load { i1, i64, i1 }, ptr %195, align 4
  %197 = tail call { i1 } @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %196)
  %198 = getelementptr inbounds nuw i8, ptr %150, i64 9
  %199 = extractvalue { i1 } %197, 0
  store i1 %199, ptr %198, align 1
  tail call void @heap_free(ptr nonnull %70)
  tail call void @heap_free(ptr nonnull %71)
  %200 = load i64, ptr %151, align 4
  %201 = and i64 %200, 1023
  store i64 %201, ptr %151, align 4
  %202 = icmp eq i64 %201, 0
  br i1 %202, label %__barray_check_none_borrowed.exit558, label %mask_block_err.i556

mask_block_err.i550:                              ; preds = %loop_out153
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_560_case_1:                                  ; preds = %__barray_mask_borrow.exit546
  %.fca.1.extract326 = extractvalue { i1, i64, i1 } %145, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract326)
  br label %cond_exit_537

__barray_check_none_borrowed.exit558:             ; preds = %__barray_check_none_borrowed.exit552
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %203 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %203, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %150, ptr %arr_ptr, align 8
  store ptr %203, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_outcomes.9CB6D2E7.0, i64 21, ptr nonnull %out_arr_alloca)
  ret void

mask_block_err.i556:                              ; preds = %__barray_check_none_borrowed.exit552
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_91:                                     ; preds = %__barray_mask_return.exit528
  %"54_380.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"54_380.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"54_380.fca.0.insert", ptr %1, 1
  %"54_380.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"54_380.fca.1.insert", i64 0, 2
  %204 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"54_380.fca.2.insert", 0
  %205 = tail call ptr @heap_alloc(i64 240)
  %206 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %206, align 1
  br label %__barray_check_bounds.exit.i.i

207:                                              ; preds = %loop_body.i
  %208 = lshr i64 %.fca.2.extract82.i.i, 6
  %209 = getelementptr i64, ptr %.fca.1.extract81.i.i, i64 %208
  %210 = load i64, ptr %209, align 4
  %211 = and i64 %.fca.2.extract82.i.i, 63
  %212 = sub nuw nsw i64 64, %211
  %213 = lshr i64 -1, %212
  %214 = icmp eq i64 %211, 0
  %215 = select i1 %214, i64 0, i64 %213
  %216 = or i64 %210, %215
  store i64 %216, ptr %209, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract82.i.i, 9
  %217 = lshr i64 %last_valid.i.i.i, 6
  %218 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i.i, i64 %217
  %219 = load i64, ptr %218, align 4
  %220 = and i64 %last_valid.i.i.i, 63
  %221 = shl nsw i64 -2, %220
  %222 = icmp eq i64 %220, 63
  %223 = select i1 %222, i64 0, i64 %221
  %224 = or i64 %219, %223
  store i64 %224, ptr %218, align 4
  %reass.sub.i.i.i = sub nsw i64 %217, %208
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.222.exit", label %mask_block_ok.i.i.i

225:                                              ; preds = %mask_block_ok.i.i.i
  %226 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.222.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %207, %225
  %.02.i.i.i = phi i64 [ %226, %225 ], [ 0, %207 ]
  %gep.i.i.i = getelementptr i64, ptr %209, i64 %.02.i.i.i
  %227 = load i64, ptr %gep.i.i.i, align 4
  %228 = icmp eq i64 %227, -1
  br i1 %228, label %225, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_91
  %.fca.2.extract82.i187.i = phi i64 [ 0, %cond_exit_91 ], [ %.fca.2.extract82.i.i, %loop_body.i ]
  %.fca.1.extract81.i186.i = phi ptr [ %1, %cond_exit_91 ], [ %.fca.1.extract81.i.i, %loop_body.i ]
  %.fca.0.extract80.i185.i = phi ptr [ %0, %cond_exit_91 ], [ %.fca.0.extract80.i.i, %loop_body.i ]
  %"236_0.sroa.15.0184.i" = phi i64 [ 0, %cond_exit_91 ], [ %229, %loop_body.i ]
  %.pn165183.i = phi { { ptr, ptr, i64 }, i64 } [ %204, %cond_exit_91 ], [ %244, %loop_body.i ]
  %229 = add nuw nsw i64 %"236_0.sroa.15.0184.i", 1
  %230 = add i64 %"236_0.sroa.15.0184.i", %.fca.2.extract82.i187.i
  %231 = lshr i64 %230, 6
  %232 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i186.i, i64 %231
  %233 = load i64, ptr %232, align 4
  %234 = and i64 %230, 63
  %235 = lshr i64 %233, %234
  %236 = trunc i64 %235 to i1
  br i1 %236, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %237 = shl nuw i64 1, %234
  %238 = xor i64 %237, %233
  store i64 %238, ptr %232, align 4
  %239 = getelementptr inbounds i64, ptr %.fca.0.extract80.i185.i, i64 %230
  %240 = load i64, ptr %239, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %240)
  tail call void @___qfree(i64 %240)
  %241 = load i64, ptr %206, align 4
  %242 = lshr i64 %241, %"236_0.sroa.15.0184.i"
  %243 = trunc i64 %242 to i1
  br i1 %243, label %loop_body.i, label %panic.i.i559

panic.i.i559:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"255_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"255_054.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"255_054.fca.1.insert.i", i1 undef, 2
  %244 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, i64 %229, 1
  %245 = shl nuw nsw i64 1, %"236_0.sroa.15.0184.i"
  %246 = xor i64 %241, %245
  store i64 %246, ptr %206, align 4
  %247 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %205, i64 %"236_0.sroa.15.0184.i"
  store { i1, i64, i1 } %"255_054.fca.2.insert.i", ptr %247, align 4
  %248 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %248, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %248, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %248, 2
  %exitcond.not.i560 = icmp eq i64 %229, 10
  br i1 %exitcond.not.i560, label %207, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.222.exit": ; preds = %225, %207
  tail call void @heap_free(ptr %.fca.0.extract80.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract81.i.i)
  %249 = tail call ptr @heap_alloc(i64 320)
  %250 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %250, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(320) %249, i8 0, i64 320, i1 false)
  %251 = load i64, ptr %206, align 4
  %252 = and i64 %251, 1023
  store i64 %252, ptr %206, align 4
  %253 = icmp eq i64 %252, 0
  br i1 %253, label %__barray_check_none_borrowed.exit, label %mask_block_err.i
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

define internal i1 @__hugr__.array.__read_bool.1.263({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_387_case_1, label %cond_387_case_0

cond_387_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_387

cond_387_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_387

cond_exit_387:                                    ; preds = %cond_387_case_1, %cond_387_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_387_case_1 ], [ %.fca.2.extract, %cond_387_case_0 ]
  ret i1 %"03.0"
}

define internal { i1, i64, i1 } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).465"({ i1, { i1, i64, i1 } } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract11 = extractvalue { i1, { i1, i64, i1 } } %0, 0
  br i1 %.fca.0.extract11, label %cond_468_case_1, label %cond_468_case_0

cond_468_case_1:                                  ; preds = %alloca_block
  %1 = extractvalue { i1, { i1, i64, i1 } } %0, 1
  ret { i1, i64, i1 } %1

cond_468_case_0:                                  ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.E6312129.0")
  unreachable
}

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

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

!name = !{!0}

!0 = !{!"mainlib"}
