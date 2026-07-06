; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@res_a.A4A74DAF.0 = private constant [12 x i8] c"\0BUSER:BOOL:a"
@res_b.3BD50C23.0 = private constant [12 x i8] c"\0BUSER:BOOL:b"
@res_c.1C9EF4D1.0 = private constant [12 x i8] c"\0BUSER:BOOL:c"
@res_d.00B84DC7.0 = private constant [12 x i8] c"\0BUSER:BOOL:d"
@res_shot.6D86EAF7.0 = private constant [14 x i8] c"\0DUSER:INT:shot"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 32)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_504_case_0.i, label %__hugr__.__tk2_helios_qalloc.500.exit

cond_504_case_0.i:                                ; preds = %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.500.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.3, %__hugr__.__tk2_helios_qalloc.500.exit.2, %__hugr__.__tk2_helios_qalloc.500.exit.1, %__hugr__.__tk2_helios_qalloc.500.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.500.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_504_case_0.i, label %__hugr__.__tk2_helios_qalloc.500.exit.1

__hugr__.__tk2_helios_qalloc.500.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not685 = icmp eq i64 %6, 0
  br i1 %.not685, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.500.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_504_case_0.i, label %__hugr__.__tk2_helios_qalloc.500.exit.2

__hugr__.__tk2_helios_qalloc.500.exit.2:          ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not686 = icmp eq i64 %10, 0
  br i1 %.not686, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_helios_qalloc.500.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_504_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not687 = icmp eq i64 %14, 0
  br i1 %.not687, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %17 = load i64, ptr %1, align 4
  %18 = trunc i64 %17 to i1
  br i1 %18, label %panic.i635, label %__barray_check_bounds.exit637

panic.i635:                                       ; preds = %__barray_check_bounds.exit634.3, %__barray_mask_return.exit639.1, %__barray_mask_return.exit639, %cond_exit_20.3
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit637:                    ; preds = %cond_exit_20.3
  %19 = or disjoint i64 %17, 1
  store i64 %19, ptr %1, align 4
  %20 = load i64, ptr %0, align 4
  tail call void @___rxy(i64 %20, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %20, double 0x400921FB54442D18)
  %21 = load i64, ptr %1, align 4
  %22 = trunc i64 %21 to i1
  br i1 %22, label %__barray_mask_return.exit639, label %panic.i638

panic.i638:                                       ; preds = %__barray_check_bounds.exit637.3, %__barray_check_bounds.exit637.2, %__barray_check_bounds.exit637.1, %__barray_check_bounds.exit637
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit639:                     ; preds = %__barray_check_bounds.exit637
  %23 = and i64 %21, -2
  store i64 %23, ptr %1, align 4
  store i64 %20, ptr %0, align 4
  %24 = load i64, ptr %1, align 4
  %25 = and i64 %24, 2
  %.not688 = icmp eq i64 %25, 0
  br i1 %.not688, label %__barray_check_bounds.exit637.1, label %panic.i635

__barray_check_bounds.exit637.1:                  ; preds = %__barray_mask_return.exit639
  %26 = or disjoint i64 %24, 2
  store i64 %26, ptr %1, align 4
  %27 = load i64, ptr %8, align 4
  tail call void @___rxy(i64 %27, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %27, double 0x400921FB54442D18)
  %28 = load i64, ptr %1, align 4
  %29 = and i64 %28, 2
  %.not689 = icmp eq i64 %29, 0
  br i1 %.not689, label %panic.i638, label %__barray_mask_return.exit639.1

__barray_mask_return.exit639.1:                   ; preds = %__barray_check_bounds.exit637.1
  %30 = and i64 %28, -3
  store i64 %30, ptr %1, align 4
  store i64 %27, ptr %8, align 4
  %31 = load i64, ptr %1, align 4
  %32 = and i64 %31, 4
  %.not690 = icmp eq i64 %32, 0
  br i1 %.not690, label %__barray_check_bounds.exit637.2, label %panic.i635

__barray_check_bounds.exit637.2:                  ; preds = %__barray_mask_return.exit639.1
  %33 = or disjoint i64 %31, 4
  store i64 %33, ptr %1, align 4
  %34 = load i64, ptr %12, align 4
  tail call void @___rxy(i64 %34, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %34, double 0x400921FB54442D18)
  %35 = load i64, ptr %1, align 4
  %36 = and i64 %35, 4
  %.not691 = icmp eq i64 %36, 0
  br i1 %.not691, label %panic.i638, label %__barray_check_bounds.exit634.3

__barray_check_bounds.exit634.3:                  ; preds = %__barray_check_bounds.exit637.2
  %37 = and i64 %35, -5
  store i64 %37, ptr %1, align 4
  store i64 %34, ptr %12, align 4
  %38 = load i64, ptr %1, align 4
  %39 = and i64 %38, 8
  %.not692 = icmp eq i64 %39, 0
  br i1 %.not692, label %__barray_check_bounds.exit637.3, label %panic.i635

__barray_check_bounds.exit637.3:                  ; preds = %__barray_check_bounds.exit634.3
  %40 = or disjoint i64 %38, 8
  store i64 %40, ptr %1, align 4
  %41 = load i64, ptr %16, align 4
  tail call void @___rxy(i64 %41, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %41, double 0x400921FB54442D18)
  %42 = load i64, ptr %1, align 4
  %43 = and i64 %42, 8
  %.not693 = icmp eq i64 %43, 0
  br i1 %.not693, label %panic.i638, label %__barray_mask_return.exit639.3

__barray_mask_return.exit639.3:                   ; preds = %__barray_check_bounds.exit637.3
  %44 = and i64 %42, -9
  store i64 %44, ptr %1, align 4
  store i64 %41, ptr %16, align 4
  %shot = tail call i64 @get_current_shot()
  %45 = tail call ptr @heap_alloc(i64 32)
  %46 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %46, align 1
  %47 = load i64, ptr %1, align 4
  %48 = trunc i64 %47 to i1
  br i1 %48, label %panic.i.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.i"

mask_block_err.i:                                 ; preds = %cond_exit_527.3
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit645:                     ; preds = %__barray_mask_return.exit661
  %49 = or disjoint i64 %129, 1
  store i64 %49, ptr %46, align 4
  %50 = load i64, ptr %45, align 4
  tail call void @___dec_future_refcount(i64 %50)
  br label %cond_exit_527

cond_exit_527:                                    ; preds = %__barray_mask_borrow.exit645, %__barray_mask_return.exit661
  %51 = load i64, ptr %46, align 4
  %52 = and i64 %51, 2
  %.not696 = icmp eq i64 %52, 0
  br i1 %.not696, label %__barray_mask_borrow.exit645.1, label %cond_exit_527.1

__barray_mask_borrow.exit645.1:                   ; preds = %cond_exit_527
  %53 = or disjoint i64 %51, 2
  store i64 %53, ptr %46, align 4
  %54 = getelementptr inbounds nuw i8, ptr %45, i64 8
  %55 = load i64, ptr %54, align 4
  tail call void @___dec_future_refcount(i64 %55)
  br label %cond_exit_527.1

cond_exit_527.1:                                  ; preds = %__barray_mask_borrow.exit645.1, %cond_exit_527
  %56 = load i64, ptr %46, align 4
  %57 = and i64 %56, 4
  %.not697 = icmp eq i64 %57, 0
  br i1 %.not697, label %__barray_mask_borrow.exit645.2, label %cond_exit_527.2

__barray_mask_borrow.exit645.2:                   ; preds = %cond_exit_527.1
  %58 = or disjoint i64 %56, 4
  store i64 %58, ptr %46, align 4
  %59 = getelementptr inbounds nuw i8, ptr %45, i64 16
  %60 = load i64, ptr %59, align 4
  tail call void @___dec_future_refcount(i64 %60)
  br label %cond_exit_527.2

cond_exit_527.2:                                  ; preds = %__barray_mask_borrow.exit645.2, %cond_exit_527.1
  %61 = load i64, ptr %46, align 4
  %62 = and i64 %61, 8
  %.not698 = icmp eq i64 %62, 0
  br i1 %.not698, label %__barray_mask_borrow.exit645.3, label %cond_exit_527.3

__barray_mask_borrow.exit645.3:                   ; preds = %cond_exit_527.2
  %63 = or disjoint i64 %61, 8
  store i64 %63, ptr %46, align 4
  %64 = getelementptr inbounds nuw i8, ptr %45, i64 24
  %65 = load i64, ptr %64, align 4
  tail call void @___dec_future_refcount(i64 %65)
  br label %cond_exit_527.3

cond_exit_527.3:                                  ; preds = %__barray_mask_borrow.exit645.3, %cond_exit_527.2
  %66 = load i64, ptr %46, align 4
  %67 = or i64 %66, -16
  store i64 %67, ptr %46, align 4
  %68 = icmp eq i64 %67, -1
  br i1 %68, label %loop_out269, label %mask_block_err.i

loop_out269:                                      ; preds = %cond_exit_527.3
  tail call void @heap_free(ptr nonnull %45)
  tail call void @heap_free(ptr nonnull %46)
  %read_bool = tail call i1 @___read_future_bool(i64 %104)
  tail call void @___dec_future_refcount(i64 %104)
  tail call void @print_bool(ptr nonnull @res_a.A4A74DAF.0, i64 11, i1 %read_bool)
  %read_bool338 = tail call i1 @___read_future_bool(i64 %111)
  tail call void @___dec_future_refcount(i64 %111)
  tail call void @print_bool(ptr nonnull @res_b.3BD50C23.0, i64 11, i1 %read_bool338)
  %read_bool353 = tail call i1 @___read_future_bool(i64 %118)
  tail call void @___dec_future_refcount(i64 %118)
  tail call void @print_bool(ptr nonnull @res_c.1C9EF4D1.0, i64 11, i1 %read_bool353)
  %read_bool368 = tail call i1 @___read_future_bool(i64 %125)
  tail call void @___dec_future_refcount(i64 %125)
  tail call void @print_bool(ptr nonnull @res_d.00B84DC7.0, i64 11, i1 %read_bool368)
  tail call void @print_int(ptr nonnull @res_shot.6D86EAF7.0, i64 13, i64 %shot)
  ret void

"__hugr__.guppylang.std.quantum.measure_array$4.286.exit": ; preds = %loop_body.3.i
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %69 = load i64, ptr %46, align 4
  %70 = trunc i64 %69 to i1
  br i1 %70, label %panic.i646, label %__barray_mask_borrow.exit647

mask_block_err.i.i.i:                             ; preds = %loop_body.3.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.3.i, %loop_body.1.i, %loop_body.i, %__barray_mask_return.exit639.3
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.i": ; preds = %__barray_mask_return.exit639.3
  %71 = or disjoint i64 %47, 1
  store i64 %71, ptr %1, align 4
  %72 = load i64, ptr %0, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %72)
  tail call void @___qfree(i64 %72)
  %73 = load i64, ptr %46, align 4
  %74 = trunc i64 %73 to i1
  br i1 %74, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.3.i, %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.2.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.1.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.i"
  %75 = and i64 %73, -2
  store i64 %75, ptr %46, align 4
  store i64 %lazy_measure.i, ptr %45, align 4
  %76 = load i64, ptr %1, align 4
  %77 = and i64 %76, 2
  %.not = icmp eq i64 %77, 0
  br i1 %.not, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.1.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.1.i": ; preds = %loop_body.i
  %78 = or disjoint i64 %76, 2
  store i64 %78, ptr %1, align 4
  %79 = load i64, ptr %8, align 4
  %lazy_measure.1.i = tail call i64 @___lazy_measure(i64 %79)
  tail call void @___qfree(i64 %79)
  %80 = load i64, ptr %46, align 4
  %81 = and i64 %80, 2
  %.not.i = icmp eq i64 %81, 0
  br i1 %.not.i, label %panic.i.i, label %loop_body.1.i

loop_body.1.i:                                    ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.1.i"
  %82 = and i64 %80, -3
  store i64 %82, ptr %46, align 4
  %83 = getelementptr inbounds nuw i8, ptr %45, i64 8
  store i64 %lazy_measure.1.i, ptr %83, align 4
  %84 = load i64, ptr %1, align 4
  %85 = and i64 %84, 4
  %.not674 = icmp eq i64 %85, 0
  br i1 %.not674, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.2.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.2.i": ; preds = %loop_body.1.i
  %86 = or disjoint i64 %84, 4
  store i64 %86, ptr %1, align 4
  %87 = load i64, ptr %12, align 4
  %lazy_measure.2.i = tail call i64 @___lazy_measure(i64 %87)
  tail call void @___qfree(i64 %87)
  %88 = load i64, ptr %46, align 4
  %89 = and i64 %88, 4
  %.not182.i = icmp eq i64 %89, 0
  br i1 %.not182.i, label %panic.i.i, label %__barray_check_bounds.exit.i.3.i

__barray_check_bounds.exit.i.3.i:                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.339.exit.thread.2.i"
  %90 = and i64 %88, -5
  store i64 %90, ptr %46, align 4
  %91 = getelementptr inbounds nuw i8, ptr %45, i64 16
  store i64 %lazy_measure.2.i, ptr %91, align 4
  %92 = load i64, ptr %1, align 4
  %93 = and i64 %92, 8
  %.not675 = icmp eq i64 %93, 0
  br i1 %.not675, label %__barray_check_bounds.exit.3.i, label %panic.i.i.i

__barray_check_bounds.exit.3.i:                   ; preds = %__barray_check_bounds.exit.i.3.i
  %94 = or disjoint i64 %92, 8
  store i64 %94, ptr %1, align 4
  %95 = load i64, ptr %16, align 4
  %lazy_measure.3.i = tail call i64 @___lazy_measure(i64 %95)
  tail call void @___qfree(i64 %95)
  %96 = load i64, ptr %46, align 4
  %97 = and i64 %96, 8
  %.not183.i = icmp eq i64 %97, 0
  br i1 %.not183.i, label %panic.i.i, label %loop_body.3.i

loop_body.3.i:                                    ; preds = %__barray_check_bounds.exit.3.i
  %98 = and i64 %96, -9
  store i64 %98, ptr %46, align 4
  %99 = getelementptr inbounds nuw i8, ptr %45, i64 24
  store i64 %lazy_measure.3.i, ptr %99, align 4
  %100 = load i64, ptr %1, align 4
  %101 = or i64 %100, -16
  store i64 %101, ptr %1, align 4
  %102 = icmp eq i64 %101, -1
  br i1 %102, label %"__hugr__.guppylang.std.quantum.measure_array$4.286.exit", label %mask_block_err.i.i.i

panic.i646:                                       ; preds = %"__hugr__.guppylang.std.quantum.measure_array$4.286.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit647:                     ; preds = %"__hugr__.guppylang.std.quantum.measure_array$4.286.exit"
  %103 = or disjoint i64 %69, 1
  store i64 %103, ptr %46, align 4
  %104 = load i64, ptr %45, align 4
  tail call void @___inc_future_refcount(i64 %104)
  %105 = load i64, ptr %46, align 4
  %106 = trunc i64 %105 to i1
  br i1 %106, label %__barray_mask_return.exit649, label %panic.i648

panic.i648:                                       ; preds = %__barray_mask_borrow.exit647
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit649:                     ; preds = %__barray_mask_borrow.exit647
  %107 = and i64 %105, -2
  store i64 %107, ptr %46, align 4
  store i64 %104, ptr %45, align 4
  %108 = load i64, ptr %46, align 4
  %109 = and i64 %108, 2
  %.not676 = icmp eq i64 %109, 0
  br i1 %.not676, label %__barray_mask_borrow.exit651, label %panic.i650

panic.i650:                                       ; preds = %__barray_mask_return.exit649
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit651:                     ; preds = %__barray_mask_return.exit649
  %110 = or disjoint i64 %108, 2
  store i64 %110, ptr %46, align 4
  %111 = load i64, ptr %83, align 4
  tail call void @___inc_future_refcount(i64 %111)
  %112 = load i64, ptr %46, align 4
  %113 = and i64 %112, 2
  %.not677 = icmp eq i64 %113, 0
  br i1 %.not677, label %panic.i652, label %__barray_mask_return.exit653

panic.i652:                                       ; preds = %__barray_mask_borrow.exit651
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit653:                     ; preds = %__barray_mask_borrow.exit651
  %114 = and i64 %112, -3
  store i64 %114, ptr %46, align 4
  store i64 %111, ptr %83, align 4
  %115 = load i64, ptr %46, align 4
  %116 = and i64 %115, 4
  %.not678 = icmp eq i64 %116, 0
  br i1 %.not678, label %__barray_mask_borrow.exit655, label %panic.i654

panic.i654:                                       ; preds = %__barray_mask_return.exit653
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit655:                     ; preds = %__barray_mask_return.exit653
  %117 = or disjoint i64 %115, 4
  store i64 %117, ptr %46, align 4
  %118 = load i64, ptr %91, align 4
  tail call void @___inc_future_refcount(i64 %118)
  %119 = load i64, ptr %46, align 4
  %120 = and i64 %119, 4
  %.not679 = icmp eq i64 %120, 0
  br i1 %.not679, label %panic.i656, label %__barray_mask_return.exit657

panic.i656:                                       ; preds = %__barray_mask_borrow.exit655
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit657:                     ; preds = %__barray_mask_borrow.exit655
  %121 = and i64 %119, -5
  store i64 %121, ptr %46, align 4
  store i64 %118, ptr %91, align 4
  %122 = load i64, ptr %46, align 4
  %123 = and i64 %122, 8
  %.not680 = icmp eq i64 %123, 0
  br i1 %.not680, label %__barray_mask_borrow.exit659, label %panic.i658

panic.i658:                                       ; preds = %__barray_mask_return.exit657
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit659:                     ; preds = %__barray_mask_return.exit657
  %124 = or disjoint i64 %122, 8
  store i64 %124, ptr %46, align 4
  %125 = load i64, ptr %99, align 4
  tail call void @___inc_future_refcount(i64 %125)
  %126 = load i64, ptr %46, align 4
  %127 = and i64 %126, 8
  %.not681 = icmp eq i64 %127, 0
  br i1 %.not681, label %panic.i660, label %__barray_mask_return.exit661

panic.i660:                                       ; preds = %__barray_mask_borrow.exit659
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit661:                     ; preds = %__barray_mask_borrow.exit659
  %128 = and i64 %126, -9
  store i64 %128, ptr %46, align 4
  store i64 %125, ptr %99, align 4
  %129 = load i64, ptr %46, align 4
  %130 = trunc i64 %129 to i1
  br i1 %130, label %cond_exit_527, label %__barray_mask_borrow.exit645
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

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

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
