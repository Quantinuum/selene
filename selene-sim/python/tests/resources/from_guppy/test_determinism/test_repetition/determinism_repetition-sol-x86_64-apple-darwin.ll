; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@res_a.A4A74DAF.0 = private constant [12 x i8] c"\0BUSER:BOOL:a"
@res_b.3BD50C23.0 = private constant [12 x i8] c"\0BUSER:BOOL:b"
@res_c.1C9EF4D1.0 = private constant [12 x i8] c"\0BUSER:BOOL:c"
@res_d.00B84DC7.0 = private constant [12 x i8] c"\0BUSER:BOOL:d"
@res_e.B9A29CAF.0 = private constant [12 x i8] c"\0BUSER:BOOL:e"
@res_shot.6D86EAF7.0 = private constant [14 x i8] c"\0DUSER:INT:shot"
@res_random_int.805B8DD0.0 = private constant [20 x i8] c"\13USER:INT:random_int"
@res_random_flo.4EFA2734.0 = private constant [24 x i8] c"\17USER:FLOAT:random_float"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 40)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_575_case_0.i, label %__hugr__.__tk2_sol_qalloc.571.exit

cond_575_case_0.i:                                ; preds = %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.571.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.4, %__hugr__.__tk2_sol_qalloc.571.exit.3, %__hugr__.__tk2_sol_qalloc.571.exit.2, %__hugr__.__tk2_sol_qalloc.571.exit.1, %__hugr__.__tk2_sol_qalloc.571.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_sol_qalloc.571.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_575_case_0.i, label %__hugr__.__tk2_sol_qalloc.571.exit.1

__hugr__.__tk2_sol_qalloc.571.exit.1:             ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not766 = icmp eq i64 %6, 0
  br i1 %.not766, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.571.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_575_case_0.i, label %__hugr__.__tk2_sol_qalloc.571.exit.2

__hugr__.__tk2_sol_qalloc.571.exit.2:             ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not767 = icmp eq i64 %10, 0
  br i1 %.not767, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_sol_qalloc.571.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_575_case_0.i, label %__hugr__.__tk2_sol_qalloc.571.exit.3

__hugr__.__tk2_sol_qalloc.571.exit.3:             ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not768 = icmp eq i64 %14, 0
  br i1 %.not768, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_sol_qalloc.571.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_575_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not769 = icmp eq i64 %18, 0
  br i1 %.not769, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %21 = load i64, ptr %1, align 4
  %22 = trunc i64 %21 to i1
  br i1 %22, label %panic.i709, label %__barray_check_bounds.exit711

panic.i709:                                       ; preds = %__barray_check_bounds.exit708.4, %__barray_mask_return.exit713.2, %__barray_mask_return.exit713.1, %__barray_mask_return.exit713, %cond_exit_20.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit711:                    ; preds = %cond_exit_20.4
  %23 = or disjoint i64 %21, 1
  store i64 %23, ptr %1, align 4
  %24 = load i64, ptr %0, align 4
  tail call void @___rp(i64 %24, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %24, double 0x400921FB54442D18)
  %25 = load i64, ptr %1, align 4
  %26 = trunc i64 %25 to i1
  br i1 %26, label %__barray_mask_return.exit713, label %panic.i712

panic.i712:                                       ; preds = %__barray_check_bounds.exit711.4, %__barray_check_bounds.exit711.3, %__barray_check_bounds.exit711.2, %__barray_check_bounds.exit711.1, %__barray_check_bounds.exit711
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit713:                     ; preds = %__barray_check_bounds.exit711
  %27 = and i64 %25, -2
  store i64 %27, ptr %1, align 4
  store i64 %24, ptr %0, align 4
  %28 = load i64, ptr %1, align 4
  %29 = and i64 %28, 2
  %.not770 = icmp eq i64 %29, 0
  br i1 %.not770, label %__barray_check_bounds.exit711.1, label %panic.i709

__barray_check_bounds.exit711.1:                  ; preds = %__barray_mask_return.exit713
  %30 = or disjoint i64 %28, 2
  store i64 %30, ptr %1, align 4
  %31 = load i64, ptr %8, align 4
  tail call void @___rp(i64 %31, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %31, double 0x400921FB54442D18)
  %32 = load i64, ptr %1, align 4
  %33 = and i64 %32, 2
  %.not771 = icmp eq i64 %33, 0
  br i1 %.not771, label %panic.i712, label %__barray_mask_return.exit713.1

__barray_mask_return.exit713.1:                   ; preds = %__barray_check_bounds.exit711.1
  %34 = and i64 %32, -3
  store i64 %34, ptr %1, align 4
  store i64 %31, ptr %8, align 4
  %35 = load i64, ptr %1, align 4
  %36 = and i64 %35, 4
  %.not772 = icmp eq i64 %36, 0
  br i1 %.not772, label %__barray_check_bounds.exit711.2, label %panic.i709

__barray_check_bounds.exit711.2:                  ; preds = %__barray_mask_return.exit713.1
  %37 = or disjoint i64 %35, 4
  store i64 %37, ptr %1, align 4
  %38 = load i64, ptr %12, align 4
  tail call void @___rp(i64 %38, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %38, double 0x400921FB54442D18)
  %39 = load i64, ptr %1, align 4
  %40 = and i64 %39, 4
  %.not773 = icmp eq i64 %40, 0
  br i1 %.not773, label %panic.i712, label %__barray_mask_return.exit713.2

__barray_mask_return.exit713.2:                   ; preds = %__barray_check_bounds.exit711.2
  %41 = and i64 %39, -5
  store i64 %41, ptr %1, align 4
  store i64 %38, ptr %12, align 4
  %42 = load i64, ptr %1, align 4
  %43 = and i64 %42, 8
  %.not774 = icmp eq i64 %43, 0
  br i1 %.not774, label %__barray_check_bounds.exit711.3, label %panic.i709

__barray_check_bounds.exit711.3:                  ; preds = %__barray_mask_return.exit713.2
  %44 = or disjoint i64 %42, 8
  store i64 %44, ptr %1, align 4
  %45 = load i64, ptr %16, align 4
  tail call void @___rp(i64 %45, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %45, double 0x400921FB54442D18)
  %46 = load i64, ptr %1, align 4
  %47 = and i64 %46, 8
  %.not775 = icmp eq i64 %47, 0
  br i1 %.not775, label %panic.i712, label %__barray_check_bounds.exit708.4

__barray_check_bounds.exit708.4:                  ; preds = %__barray_check_bounds.exit711.3
  %48 = and i64 %46, -9
  store i64 %48, ptr %1, align 4
  store i64 %45, ptr %16, align 4
  %49 = load i64, ptr %1, align 4
  %50 = and i64 %49, 16
  %.not776 = icmp eq i64 %50, 0
  br i1 %.not776, label %__barray_check_bounds.exit711.4, label %panic.i709

__barray_check_bounds.exit711.4:                  ; preds = %__barray_check_bounds.exit708.4
  %51 = or disjoint i64 %49, 16
  store i64 %51, ptr %1, align 4
  %52 = load i64, ptr %20, align 4
  tail call void @___rp(i64 %52, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %52, double 0x400921FB54442D18)
  %53 = load i64, ptr %1, align 4
  %54 = and i64 %53, 16
  %.not777 = icmp eq i64 %54, 0
  br i1 %.not777, label %panic.i712, label %__barray_mask_return.exit713.4

__barray_mask_return.exit713.4:                   ; preds = %__barray_check_bounds.exit711.4
  %55 = and i64 %53, -17
  store i64 %55, ptr %1, align 4
  store i64 %52, ptr %20, align 4
  %shot = tail call i64 @get_current_shot()
  %shot109 = tail call i64 @get_current_shot()
  %56 = tail call ptr @heap_alloc(i64 40)
  %57 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %57, align 1
  %58 = load i64, ptr %1, align 4
  %59 = trunc i64 %58 to i1
  br i1 %59, label %panic.i.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.i"

mask_block_err.i:                                 ; preds = %cond_exit_598.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit719:                     ; preds = %__barray_mask_return.exit739
  %60 = or disjoint i64 %161, 1
  store i64 %60, ptr %57, align 4
  %61 = load i64, ptr %56, align 4
  tail call void @___dec_future_refcount(i64 %61)
  br label %cond_exit_598

cond_exit_598:                                    ; preds = %__barray_mask_borrow.exit719, %__barray_mask_return.exit739
  %62 = load i64, ptr %57, align 4
  %63 = and i64 %62, 2
  %.not780 = icmp eq i64 %63, 0
  br i1 %.not780, label %__barray_mask_borrow.exit719.1, label %cond_exit_598.1

__barray_mask_borrow.exit719.1:                   ; preds = %cond_exit_598
  %64 = or disjoint i64 %62, 2
  store i64 %64, ptr %57, align 4
  %65 = getelementptr inbounds nuw i8, ptr %56, i64 8
  %66 = load i64, ptr %65, align 4
  tail call void @___dec_future_refcount(i64 %66)
  br label %cond_exit_598.1

cond_exit_598.1:                                  ; preds = %__barray_mask_borrow.exit719.1, %cond_exit_598
  %67 = load i64, ptr %57, align 4
  %68 = and i64 %67, 4
  %.not781 = icmp eq i64 %68, 0
  br i1 %.not781, label %__barray_mask_borrow.exit719.2, label %cond_exit_598.2

__barray_mask_borrow.exit719.2:                   ; preds = %cond_exit_598.1
  %69 = or disjoint i64 %67, 4
  store i64 %69, ptr %57, align 4
  %70 = getelementptr inbounds nuw i8, ptr %56, i64 16
  %71 = load i64, ptr %70, align 4
  tail call void @___dec_future_refcount(i64 %71)
  br label %cond_exit_598.2

cond_exit_598.2:                                  ; preds = %__barray_mask_borrow.exit719.2, %cond_exit_598.1
  %72 = load i64, ptr %57, align 4
  %73 = and i64 %72, 8
  %.not782 = icmp eq i64 %73, 0
  br i1 %.not782, label %__barray_mask_borrow.exit719.3, label %cond_exit_598.3

__barray_mask_borrow.exit719.3:                   ; preds = %cond_exit_598.2
  %74 = or disjoint i64 %72, 8
  store i64 %74, ptr %57, align 4
  %75 = getelementptr inbounds nuw i8, ptr %56, i64 24
  %76 = load i64, ptr %75, align 4
  tail call void @___dec_future_refcount(i64 %76)
  br label %cond_exit_598.3

cond_exit_598.3:                                  ; preds = %__barray_mask_borrow.exit719.3, %cond_exit_598.2
  %77 = load i64, ptr %57, align 4
  %78 = and i64 %77, 16
  %.not783 = icmp eq i64 %78, 0
  br i1 %.not783, label %__barray_mask_borrow.exit719.4, label %cond_exit_598.4

__barray_mask_borrow.exit719.4:                   ; preds = %cond_exit_598.3
  %79 = or disjoint i64 %77, 16
  store i64 %79, ptr %57, align 4
  %80 = getelementptr inbounds nuw i8, ptr %56, i64 32
  %81 = load i64, ptr %80, align 4
  tail call void @___dec_future_refcount(i64 %81)
  br label %cond_exit_598.4

cond_exit_598.4:                                  ; preds = %__barray_mask_borrow.exit719.4, %cond_exit_598.3
  %82 = load i64, ptr %57, align 4
  %83 = or i64 %82, -32
  store i64 %83, ptr %57, align 4
  %84 = icmp eq i64 %83, -1
  br i1 %84, label %loop_out309, label %mask_block_err.i

loop_out309:                                      ; preds = %cond_exit_598.4
  tail call void @heap_free(ptr nonnull %56)
  tail call void @heap_free(ptr nonnull %57)
  %read_bool = tail call i1 @___read_future_bool(i64 %129)
  tail call void @___dec_future_refcount(i64 %129)
  tail call void @print_bool(ptr nonnull @res_a.A4A74DAF.0, i64 11, i1 %read_bool)
  %read_bool378 = tail call i1 @___read_future_bool(i64 %136)
  tail call void @___dec_future_refcount(i64 %136)
  tail call void @print_bool(ptr nonnull @res_b.3BD50C23.0, i64 11, i1 %read_bool378)
  %read_bool393 = tail call i1 @___read_future_bool(i64 %143)
  tail call void @___dec_future_refcount(i64 %143)
  tail call void @print_bool(ptr nonnull @res_c.1C9EF4D1.0, i64 11, i1 %read_bool393)
  %read_bool408 = tail call i1 @___read_future_bool(i64 %150)
  tail call void @___dec_future_refcount(i64 %150)
  tail call void @print_bool(ptr nonnull @res_d.00B84DC7.0, i64 11, i1 %read_bool408)
  %read_bool423 = tail call i1 @___read_future_bool(i64 %157)
  tail call void @___dec_future_refcount(i64 %157)
  tail call void @print_bool(ptr nonnull @res_e.B9A29CAF.0, i64 11, i1 %read_bool423)
  tail call void @print_int(ptr nonnull @res_shot.6D86EAF7.0, i64 13, i64 %shot109)
  tail call void @random_seed(i64 %shot)
  %rint = tail call i32 @random_int()
  %rfloat = tail call double @random_float()
  %85 = sext i32 %rint to i64
  tail call void @print_int(ptr nonnull @res_random_int.805B8DD0.0, i64 19, i64 %85)
  tail call void @print_float(ptr nonnull @res_random_flo.4EFA2734.0, i64 23, double %rfloat)
  ret void

"__hugr__.guppylang.std.quantum.measure_array$5.314.exit": ; preds = %loop_body.4.i
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %86 = load i64, ptr %57, align 4
  %87 = trunc i64 %86 to i1
  br i1 %87, label %panic.i720, label %__barray_mask_borrow.exit721

mask_block_err.i.i.i:                             ; preds = %loop_body.4.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.4.i, %loop_body.2.i, %loop_body.1.i, %loop_body.i, %__barray_mask_return.exit713.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.i": ; preds = %__barray_mask_return.exit713.4
  %88 = or disjoint i64 %58, 1
  store i64 %88, ptr %1, align 4
  %89 = load i64, ptr %0, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %89)
  tail call void @___qfree(i64 %89)
  %90 = load i64, ptr %57, align 4
  %91 = trunc i64 %90 to i1
  br i1 %91, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.4.i, %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.3.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.2.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.1.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.i"
  %92 = and i64 %90, -2
  store i64 %92, ptr %57, align 4
  store i64 %lazy_measure.i, ptr %56, align 4
  %93 = load i64, ptr %1, align 4
  %94 = and i64 %93, 2
  %.not = icmp eq i64 %94, 0
  br i1 %.not, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.1.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.1.i": ; preds = %loop_body.i
  %95 = or disjoint i64 %93, 2
  store i64 %95, ptr %1, align 4
  %96 = load i64, ptr %8, align 4
  %lazy_measure.1.i = tail call i64 @___lazy_measure(i64 %96)
  tail call void @___qfree(i64 %96)
  %97 = load i64, ptr %57, align 4
  %98 = and i64 %97, 2
  %.not.i = icmp eq i64 %98, 0
  br i1 %.not.i, label %panic.i.i, label %loop_body.1.i

loop_body.1.i:                                    ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.1.i"
  %99 = and i64 %97, -3
  store i64 %99, ptr %57, align 4
  %100 = getelementptr inbounds nuw i8, ptr %56, i64 8
  store i64 %lazy_measure.1.i, ptr %100, align 4
  %101 = load i64, ptr %1, align 4
  %102 = and i64 %101, 4
  %.not752 = icmp eq i64 %102, 0
  br i1 %.not752, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.2.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.2.i": ; preds = %loop_body.1.i
  %103 = or disjoint i64 %101, 4
  store i64 %103, ptr %1, align 4
  %104 = load i64, ptr %12, align 4
  %lazy_measure.2.i = tail call i64 @___lazy_measure(i64 %104)
  tail call void @___qfree(i64 %104)
  %105 = load i64, ptr %57, align 4
  %106 = and i64 %105, 4
  %.not182.i = icmp eq i64 %106, 0
  br i1 %.not182.i, label %panic.i.i, label %loop_body.2.i

loop_body.2.i:                                    ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.2.i"
  %107 = and i64 %105, -5
  store i64 %107, ptr %57, align 4
  %108 = getelementptr inbounds nuw i8, ptr %56, i64 16
  store i64 %lazy_measure.2.i, ptr %108, align 4
  %109 = load i64, ptr %1, align 4
  %110 = and i64 %109, 8
  %.not753 = icmp eq i64 %110, 0
  br i1 %.not753, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.3.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.3.i": ; preds = %loop_body.2.i
  %111 = or disjoint i64 %109, 8
  store i64 %111, ptr %1, align 4
  %112 = load i64, ptr %16, align 4
  %lazy_measure.3.i = tail call i64 @___lazy_measure(i64 %112)
  tail call void @___qfree(i64 %112)
  %113 = load i64, ptr %57, align 4
  %114 = and i64 %113, 8
  %.not183.i = icmp eq i64 %114, 0
  br i1 %.not183.i, label %panic.i.i, label %__barray_check_bounds.exit.i.4.i

__barray_check_bounds.exit.i.4.i:                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.387.exit.thread.3.i"
  %115 = and i64 %113, -9
  store i64 %115, ptr %57, align 4
  %116 = getelementptr inbounds nuw i8, ptr %56, i64 24
  store i64 %lazy_measure.3.i, ptr %116, align 4
  %117 = load i64, ptr %1, align 4
  %118 = and i64 %117, 16
  %.not754 = icmp eq i64 %118, 0
  br i1 %.not754, label %__barray_check_bounds.exit.4.i, label %panic.i.i.i

__barray_check_bounds.exit.4.i:                   ; preds = %__barray_check_bounds.exit.i.4.i
  %119 = or disjoint i64 %117, 16
  store i64 %119, ptr %1, align 4
  %120 = load i64, ptr %20, align 4
  %lazy_measure.4.i = tail call i64 @___lazy_measure(i64 %120)
  tail call void @___qfree(i64 %120)
  %121 = load i64, ptr %57, align 4
  %122 = and i64 %121, 16
  %.not184.i = icmp eq i64 %122, 0
  br i1 %.not184.i, label %panic.i.i, label %loop_body.4.i

loop_body.4.i:                                    ; preds = %__barray_check_bounds.exit.4.i
  %123 = and i64 %121, -17
  store i64 %123, ptr %57, align 4
  %124 = getelementptr inbounds nuw i8, ptr %56, i64 32
  store i64 %lazy_measure.4.i, ptr %124, align 4
  %125 = load i64, ptr %1, align 4
  %126 = or i64 %125, -32
  store i64 %126, ptr %1, align 4
  %127 = icmp eq i64 %126, -1
  br i1 %127, label %"__hugr__.guppylang.std.quantum.measure_array$5.314.exit", label %mask_block_err.i.i.i

panic.i720:                                       ; preds = %"__hugr__.guppylang.std.quantum.measure_array$5.314.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit721:                     ; preds = %"__hugr__.guppylang.std.quantum.measure_array$5.314.exit"
  %128 = or disjoint i64 %86, 1
  store i64 %128, ptr %57, align 4
  %129 = load i64, ptr %56, align 4
  tail call void @___inc_future_refcount(i64 %129)
  %130 = load i64, ptr %57, align 4
  %131 = trunc i64 %130 to i1
  br i1 %131, label %__barray_mask_return.exit723, label %panic.i722

panic.i722:                                       ; preds = %__barray_mask_borrow.exit721
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit723:                     ; preds = %__barray_mask_borrow.exit721
  %132 = and i64 %130, -2
  store i64 %132, ptr %57, align 4
  store i64 %129, ptr %56, align 4
  %133 = load i64, ptr %57, align 4
  %134 = and i64 %133, 2
  %.not755 = icmp eq i64 %134, 0
  br i1 %.not755, label %__barray_mask_borrow.exit725, label %panic.i724

panic.i724:                                       ; preds = %__barray_mask_return.exit723
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit725:                     ; preds = %__barray_mask_return.exit723
  %135 = or disjoint i64 %133, 2
  store i64 %135, ptr %57, align 4
  %136 = load i64, ptr %100, align 4
  tail call void @___inc_future_refcount(i64 %136)
  %137 = load i64, ptr %57, align 4
  %138 = and i64 %137, 2
  %.not756 = icmp eq i64 %138, 0
  br i1 %.not756, label %panic.i726, label %__barray_mask_return.exit727

panic.i726:                                       ; preds = %__barray_mask_borrow.exit725
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit727:                     ; preds = %__barray_mask_borrow.exit725
  %139 = and i64 %137, -3
  store i64 %139, ptr %57, align 4
  store i64 %136, ptr %100, align 4
  %140 = load i64, ptr %57, align 4
  %141 = and i64 %140, 4
  %.not757 = icmp eq i64 %141, 0
  br i1 %.not757, label %__barray_mask_borrow.exit729, label %panic.i728

panic.i728:                                       ; preds = %__barray_mask_return.exit727
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit729:                     ; preds = %__barray_mask_return.exit727
  %142 = or disjoint i64 %140, 4
  store i64 %142, ptr %57, align 4
  %143 = load i64, ptr %108, align 4
  tail call void @___inc_future_refcount(i64 %143)
  %144 = load i64, ptr %57, align 4
  %145 = and i64 %144, 4
  %.not758 = icmp eq i64 %145, 0
  br i1 %.not758, label %panic.i730, label %__barray_mask_return.exit731

panic.i730:                                       ; preds = %__barray_mask_borrow.exit729
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit731:                     ; preds = %__barray_mask_borrow.exit729
  %146 = and i64 %144, -5
  store i64 %146, ptr %57, align 4
  store i64 %143, ptr %108, align 4
  %147 = load i64, ptr %57, align 4
  %148 = and i64 %147, 8
  %.not759 = icmp eq i64 %148, 0
  br i1 %.not759, label %__barray_mask_borrow.exit733, label %panic.i732

panic.i732:                                       ; preds = %__barray_mask_return.exit731
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit733:                     ; preds = %__barray_mask_return.exit731
  %149 = or disjoint i64 %147, 8
  store i64 %149, ptr %57, align 4
  %150 = load i64, ptr %116, align 4
  tail call void @___inc_future_refcount(i64 %150)
  %151 = load i64, ptr %57, align 4
  %152 = and i64 %151, 8
  %.not760 = icmp eq i64 %152, 0
  br i1 %.not760, label %panic.i734, label %__barray_mask_return.exit735

panic.i734:                                       ; preds = %__barray_mask_borrow.exit733
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit735:                     ; preds = %__barray_mask_borrow.exit733
  %153 = and i64 %151, -9
  store i64 %153, ptr %57, align 4
  store i64 %150, ptr %116, align 4
  %154 = load i64, ptr %57, align 4
  %155 = and i64 %154, 16
  %.not761 = icmp eq i64 %155, 0
  br i1 %.not761, label %__barray_mask_borrow.exit737, label %panic.i736

panic.i736:                                       ; preds = %__barray_mask_return.exit735
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit737:                     ; preds = %__barray_mask_return.exit735
  %156 = or disjoint i64 %154, 16
  store i64 %156, ptr %57, align 4
  %157 = load i64, ptr %124, align 4
  tail call void @___inc_future_refcount(i64 %157)
  %158 = load i64, ptr %57, align 4
  %159 = and i64 %158, 16
  %.not762 = icmp eq i64 %159, 0
  br i1 %.not762, label %panic.i738, label %__barray_mask_return.exit739

panic.i738:                                       ; preds = %__barray_mask_borrow.exit737
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit739:                     ; preds = %__barray_mask_borrow.exit737
  %160 = and i64 %158, -17
  store i64 %160, ptr %57, align 4
  store i64 %157, ptr %124, align 4
  %161 = load i64, ptr %57, align 4
  %162 = trunc i64 %161 to i1
  br i1 %162, label %cond_exit_598, label %__barray_mask_borrow.exit719
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare i64 @get_current_shot() local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare i32 @random_int() local_unnamed_addr

declare double @random_float() local_unnamed_addr

declare void @print_float(ptr, i64, double) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @random_seed(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

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

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
