; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@res_c0.7C14CD6E.0 = private constant [13 x i8] c"\0CUSER:BOOL:c0"
@res_c1.1F7A6571.0 = private constant [13 x i8] c"\0CUSER:BOOL:c1"
@res_c2.60825383.0 = private constant [13 x i8] c"\0CUSER:BOOL:c2"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 24)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_526_case_0.i, label %__hugr__.__tk2_helios_qalloc.453.exit

cond_526_case_0.i:                                ; preds = %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.453.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.2, %__hugr__.__tk2_helios_qalloc.453.exit.1, %__hugr__.__tk2_helios_qalloc.453.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.453.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_526_case_0.i, label %__hugr__.__tk2_helios_qalloc.453.exit.1

__hugr__.__tk2_helios_qalloc.453.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not564 = icmp eq i64 %6, 0
  br i1 %.not564, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.453.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_526_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not565 = icmp eq i64 %10, 0
  br i1 %.not565, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %13 = load i64, ptr %1, align 4
  %14 = trunc i64 %13 to i1
  br i1 %14, label %panic.i482, label %__barray_mask_borrow.exit

panic.i482:                                       ; preds = %cond_exit_20.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.2
  %15 = or disjoint i64 %13, 1
  store i64 %15, ptr %1, align 4
  %16 = load i64, ptr %0, align 4
  tail call void @___rxy(i64 %16, double 0x400921FB54442D18, double 0.000000e+00)
  %17 = load i64, ptr %1, align 4
  %18 = trunc i64 %17 to i1
  br i1 %18, label %__barray_mask_return.exit484, label %panic.i483

panic.i483:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit484:                     ; preds = %__barray_mask_borrow.exit
  %19 = and i64 %17, -2
  store i64 %19, ptr %1, align 4
  store i64 %16, ptr %0, align 4
  %20 = load i64, ptr %1, align 4
  %21 = and i64 %20, 2
  %.not = icmp eq i64 %21, 0
  br i1 %.not, label %__barray_mask_borrow.exit486, label %panic.i485

panic.i485:                                       ; preds = %__barray_mask_return.exit484
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit486:                     ; preds = %__barray_mask_return.exit484
  %22 = or disjoint i64 %20, 2
  store i64 %22, ptr %1, align 4
  %23 = load i64, ptr %8, align 4
  tail call void @___rxy(i64 %23, double 0x400921FB54442D18, double 0.000000e+00)
  %24 = load i64, ptr %1, align 4
  %25 = and i64 %24, 2
  %.not545 = icmp eq i64 %25, 0
  br i1 %.not545, label %panic.i487, label %__barray_mask_return.exit488

panic.i487:                                       ; preds = %__barray_mask_borrow.exit486
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit488:                     ; preds = %__barray_mask_borrow.exit486
  %26 = and i64 %24, -3
  store i64 %26, ptr %1, align 4
  store i64 %23, ptr %8, align 4
  %27 = load i64, ptr %1, align 4
  %28 = trunc i64 %27 to i1
  br i1 %28, label %panic.i489, label %__barray_mask_borrow.exit490

panic.i489:                                       ; preds = %__barray_mask_return.exit488
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit490:                     ; preds = %__barray_mask_return.exit488
  %29 = or disjoint i64 %27, 1
  store i64 %29, ptr %1, align 4
  %30 = load i64, ptr %0, align 4
  %31 = and i64 %27, 2
  %.not546 = icmp eq i64 %31, 0
  br i1 %.not546, label %__barray_mask_borrow.exit492, label %panic.i491

panic.i491:                                       ; preds = %__barray_mask_borrow.exit490
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit492:                     ; preds = %__barray_mask_borrow.exit490
  %32 = or disjoint i64 %27, 3
  store i64 %32, ptr %1, align 4
  %33 = load i64, ptr %8, align 4
  tail call void @___rxy(i64 %33, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %30, i64 %33, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %30, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %33, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %33, double 0xBFF921FB54442D18)
  %34 = load i64, ptr %1, align 4
  %35 = trunc i64 %34 to i1
  br i1 %35, label %__barray_mask_return.exit494, label %panic.i493

panic.i493:                                       ; preds = %__barray_mask_borrow.exit492
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit494:                     ; preds = %__barray_mask_borrow.exit492
  %36 = and i64 %34, -2
  store i64 %36, ptr %1, align 4
  store i64 %30, ptr %0, align 4
  %37 = load i64, ptr %1, align 4
  %38 = and i64 %37, 2
  %.not547 = icmp eq i64 %38, 0
  br i1 %.not547, label %panic.i495, label %__barray_mask_return.exit496

panic.i495:                                       ; preds = %__barray_mask_return.exit494
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit496:                     ; preds = %__barray_mask_return.exit494
  %39 = and i64 %37, -3
  store i64 %39, ptr %1, align 4
  store i64 %33, ptr %8, align 4
  %40 = load i64, ptr %1, align 4
  %41 = trunc i64 %40 to i1
  br i1 %41, label %panic.i497, label %__barray_mask_borrow.exit498

panic.i497:                                       ; preds = %__barray_mask_return.exit496
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit498:                     ; preds = %__barray_mask_return.exit496
  %42 = or disjoint i64 %40, 1
  store i64 %42, ptr %1, align 4
  %43 = load i64, ptr %0, align 4
  tail call void @___rxy(i64 %43, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %43, double 0x400921FB54442D18)
  %44 = load i64, ptr %1, align 4
  %45 = trunc i64 %44 to i1
  br i1 %45, label %__barray_mask_return.exit500, label %panic.i499

panic.i499:                                       ; preds = %__barray_mask_borrow.exit498
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit500:                     ; preds = %__barray_mask_borrow.exit498
  %46 = and i64 %44, -2
  store i64 %46, ptr %1, align 4
  store i64 %43, ptr %0, align 4
  %47 = load i64, ptr %1, align 4
  %48 = and i64 %47, 2
  %.not548 = icmp eq i64 %48, 0
  br i1 %.not548, label %__barray_mask_borrow.exit502, label %panic.i501

panic.i501:                                       ; preds = %__barray_mask_return.exit500
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit502:                     ; preds = %__barray_mask_return.exit500
  %49 = or disjoint i64 %47, 2
  store i64 %49, ptr %1, align 4
  %50 = load i64, ptr %8, align 4
  tail call void @___rxy(i64 %50, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %50, double 0x400921FB54442D18)
  %51 = load i64, ptr %1, align 4
  %52 = and i64 %51, 2
  %.not549 = icmp eq i64 %52, 0
  br i1 %.not549, label %panic.i503, label %__barray_mask_return.exit504

panic.i503:                                       ; preds = %__barray_mask_borrow.exit502
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit504:                     ; preds = %__barray_mask_borrow.exit502
  %53 = and i64 %51, -3
  store i64 %53, ptr %1, align 4
  store i64 %50, ptr %8, align 4
  %54 = load i64, ptr %1, align 4
  %55 = trunc i64 %54 to i1
  br i1 %55, label %panic.i505, label %__barray_mask_borrow.exit506

panic.i505:                                       ; preds = %__barray_mask_return.exit504
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit506:                     ; preds = %__barray_mask_return.exit504
  %56 = or disjoint i64 %54, 1
  store i64 %56, ptr %1, align 4
  %57 = load i64, ptr %0, align 4
  %58 = and i64 %54, 2
  %.not550 = icmp eq i64 %58, 0
  br i1 %.not550, label %__barray_mask_borrow.exit508, label %panic.i507

panic.i507:                                       ; preds = %__barray_mask_borrow.exit506
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit508:                     ; preds = %__barray_mask_borrow.exit506
  %59 = or disjoint i64 %54, 3
  store i64 %59, ptr %1, align 4
  %60 = load i64, ptr %8, align 4
  tail call void @___rxy(i64 %60, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %57, i64 %60, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %57, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %60, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %60, double 0xBFF921FB54442D18)
  %61 = load i64, ptr %1, align 4
  %62 = trunc i64 %61 to i1
  br i1 %62, label %__barray_mask_return.exit512, label %panic.i511

panic.i511:                                       ; preds = %__barray_mask_borrow.exit508
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit512:                     ; preds = %__barray_mask_borrow.exit508
  %63 = and i64 %61, -2
  store i64 %63, ptr %1, align 4
  store i64 %57, ptr %0, align 4
  %64 = load i64, ptr %1, align 4
  %65 = and i64 %64, 2
  %.not551 = icmp eq i64 %65, 0
  br i1 %.not551, label %panic.i513, label %__barray_mask_return.exit514

panic.i513:                                       ; preds = %__barray_mask_return.exit512
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit514:                     ; preds = %__barray_mask_return.exit512
  %66 = and i64 %64, -3
  store i64 %66, ptr %1, align 4
  store i64 %60, ptr %8, align 4
  %67 = load i64, ptr %1, align 4
  %68 = and i64 %67, 2
  %.not552 = icmp eq i64 %68, 0
  br i1 %.not552, label %__barray_mask_borrow.exit516, label %panic.i515

panic.i515:                                       ; preds = %__barray_mask_return.exit514
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit516:                     ; preds = %__barray_mask_return.exit514
  %69 = or disjoint i64 %67, 2
  store i64 %69, ptr %1, align 4
  %70 = load i64, ptr %8, align 4
  %71 = and i64 %67, 4
  %.not553 = icmp eq i64 %71, 0
  br i1 %.not553, label %__barray_mask_borrow.exit518, label %panic.i517

panic.i517:                                       ; preds = %__barray_mask_borrow.exit516
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit518:                     ; preds = %__barray_mask_borrow.exit516
  %72 = or disjoint i64 %67, 6
  store i64 %72, ptr %1, align 4
  %73 = load i64, ptr %12, align 4
  tail call void @___rxy(i64 %73, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %70, i64 %73, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %70, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %73, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %73, double 0xBFF921FB54442D18)
  %74 = load i64, ptr %1, align 4
  %75 = and i64 %74, 2
  %.not554 = icmp eq i64 %75, 0
  br i1 %.not554, label %panic.i521, label %__barray_mask_return.exit522

panic.i521:                                       ; preds = %__barray_mask_borrow.exit518
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit522:                     ; preds = %__barray_mask_borrow.exit518
  %76 = and i64 %74, -3
  store i64 %76, ptr %1, align 4
  store i64 %70, ptr %8, align 4
  %77 = load i64, ptr %1, align 4
  %78 = and i64 %77, 4
  %.not555 = icmp eq i64 %78, 0
  br i1 %.not555, label %panic.i523, label %__barray_mask_return.exit524

panic.i523:                                       ; preds = %__barray_mask_return.exit522
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit524:                     ; preds = %__barray_mask_return.exit522
  %79 = and i64 %77, -5
  store i64 %79, ptr %1, align 4
  store i64 %73, ptr %12, align 4
  %80 = tail call ptr @heap_alloc(i64 24)
  %81 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %81, align 1
  %82 = load i64, ptr %1, align 4
  %83 = trunc i64 %82 to i1
  br i1 %83, label %panic.i.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.296.exit.thread.i"

"__hugr__.guppylang.std.quantum.measure_array$3.243.exit": ; preds = %loop_body.2.i
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %84 = load i64, ptr %81, align 4
  %85 = trunc i64 %84 to i1
  br i1 %85, label %panic.i525, label %__barray_mask_borrow.exit526

mask_block_err.i.i.i:                             ; preds = %loop_body.2.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.2.i, %loop_body.i, %__barray_mask_return.exit524
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.296.exit.thread.i": ; preds = %__barray_mask_return.exit524
  %86 = or disjoint i64 %82, 1
  store i64 %86, ptr %1, align 4
  %87 = load i64, ptr %0, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %87)
  tail call void @___qfree(i64 %87)
  %88 = load i64, ptr %81, align 4
  %89 = trunc i64 %88 to i1
  br i1 %89, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.2.i, %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.296.exit.thread.1.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.296.exit.thread.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.296.exit.thread.i"
  %90 = and i64 %88, -2
  store i64 %90, ptr %81, align 4
  store i64 %lazy_measure.i, ptr %80, align 4
  %91 = load i64, ptr %1, align 4
  %92 = and i64 %91, 2
  %.not556 = icmp eq i64 %92, 0
  br i1 %.not556, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.296.exit.thread.1.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.296.exit.thread.1.i": ; preds = %loop_body.i
  %93 = or disjoint i64 %91, 2
  store i64 %93, ptr %1, align 4
  %94 = load i64, ptr %8, align 4
  %lazy_measure.1.i = tail call i64 @___lazy_measure(i64 %94)
  tail call void @___qfree(i64 %94)
  %95 = load i64, ptr %81, align 4
  %96 = and i64 %95, 2
  %.not.i = icmp eq i64 %96, 0
  br i1 %.not.i, label %panic.i.i, label %__barray_check_bounds.exit.i.2.i

__barray_check_bounds.exit.i.2.i:                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.296.exit.thread.1.i"
  %97 = and i64 %95, -3
  store i64 %97, ptr %81, align 4
  %98 = getelementptr inbounds nuw i8, ptr %80, i64 8
  store i64 %lazy_measure.1.i, ptr %98, align 4
  %99 = load i64, ptr %1, align 4
  %100 = and i64 %99, 4
  %.not557 = icmp eq i64 %100, 0
  br i1 %.not557, label %__barray_check_bounds.exit.2.i, label %panic.i.i.i

__barray_check_bounds.exit.2.i:                   ; preds = %__barray_check_bounds.exit.i.2.i
  %101 = or disjoint i64 %99, 4
  store i64 %101, ptr %1, align 4
  %102 = load i64, ptr %12, align 4
  %lazy_measure.2.i = tail call i64 @___lazy_measure(i64 %102)
  tail call void @___qfree(i64 %102)
  %103 = load i64, ptr %81, align 4
  %104 = and i64 %103, 4
  %.not182.i = icmp eq i64 %104, 0
  br i1 %.not182.i, label %panic.i.i, label %loop_body.2.i

loop_body.2.i:                                    ; preds = %__barray_check_bounds.exit.2.i
  %105 = and i64 %103, -5
  store i64 %105, ptr %81, align 4
  %106 = getelementptr inbounds nuw i8, ptr %80, i64 16
  store i64 %lazy_measure.2.i, ptr %106, align 4
  %107 = load i64, ptr %1, align 4
  %108 = or i64 %107, -8
  store i64 %108, ptr %1, align 4
  %109 = icmp eq i64 %108, -1
  br i1 %109, label %"__hugr__.guppylang.std.quantum.measure_array$3.243.exit", label %mask_block_err.i.i.i

panic.i525:                                       ; preds = %"__hugr__.guppylang.std.quantum.measure_array$3.243.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit526:                     ; preds = %"__hugr__.guppylang.std.quantum.measure_array$3.243.exit"
  %110 = or disjoint i64 %84, 1
  store i64 %110, ptr %81, align 4
  %111 = load i64, ptr %80, align 4
  tail call void @___inc_future_refcount(i64 %111)
  %112 = load i64, ptr %81, align 4
  %113 = trunc i64 %112 to i1
  br i1 %113, label %__barray_mask_return.exit528, label %panic.i527

panic.i527:                                       ; preds = %__barray_mask_borrow.exit526
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit528:                     ; preds = %__barray_mask_borrow.exit526
  %114 = and i64 %112, -2
  store i64 %114, ptr %81, align 4
  store i64 %111, ptr %80, align 4
  %115 = load i64, ptr %81, align 4
  %116 = and i64 %115, 2
  %.not558 = icmp eq i64 %116, 0
  br i1 %.not558, label %__barray_mask_borrow.exit530, label %panic.i529

panic.i529:                                       ; preds = %__barray_mask_return.exit528
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit530:                     ; preds = %__barray_mask_return.exit528
  %117 = or disjoint i64 %115, 2
  store i64 %117, ptr %81, align 4
  %118 = load i64, ptr %98, align 4
  tail call void @___inc_future_refcount(i64 %118)
  %119 = load i64, ptr %81, align 4
  %120 = and i64 %119, 2
  %.not559 = icmp eq i64 %120, 0
  br i1 %.not559, label %panic.i531, label %__barray_mask_return.exit532

panic.i531:                                       ; preds = %__barray_mask_borrow.exit530
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit532:                     ; preds = %__barray_mask_borrow.exit530
  %121 = and i64 %119, -3
  store i64 %121, ptr %81, align 4
  store i64 %118, ptr %98, align 4
  %122 = load i64, ptr %81, align 4
  %123 = and i64 %122, 4
  %.not560 = icmp eq i64 %123, 0
  br i1 %.not560, label %__barray_mask_borrow.exit534, label %panic.i533

panic.i533:                                       ; preds = %__barray_mask_return.exit532
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit534:                     ; preds = %__barray_mask_return.exit532
  %124 = or disjoint i64 %122, 4
  store i64 %124, ptr %81, align 4
  %125 = load i64, ptr %106, align 4
  tail call void @___inc_future_refcount(i64 %125)
  %126 = load i64, ptr %81, align 4
  %127 = and i64 %126, 4
  %.not561 = icmp eq i64 %127, 0
  br i1 %.not561, label %panic.i535, label %__barray_mask_return.exit536

panic.i535:                                       ; preds = %__barray_mask_borrow.exit534
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit536:                     ; preds = %__barray_mask_borrow.exit534
  %128 = and i64 %126, -5
  store i64 %128, ptr %81, align 4
  store i64 %125, ptr %106, align 4
  %129 = load i64, ptr %81, align 4
  %130 = trunc i64 %129 to i1
  br i1 %130, label %cond_exit_549, label %__barray_mask_borrow.exit542

mask_block_err.i:                                 ; preds = %cond_exit_549.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit542:                     ; preds = %__barray_mask_return.exit536
  %131 = or disjoint i64 %129, 1
  store i64 %131, ptr %81, align 4
  %132 = load i64, ptr %80, align 4
  tail call void @___dec_future_refcount(i64 %132)
  br label %cond_exit_549

cond_exit_549:                                    ; preds = %__barray_mask_borrow.exit542, %__barray_mask_return.exit536
  %133 = load i64, ptr %81, align 4
  %134 = and i64 %133, 2
  %.not568 = icmp eq i64 %134, 0
  br i1 %.not568, label %__barray_mask_borrow.exit542.1, label %cond_exit_549.1

__barray_mask_borrow.exit542.1:                   ; preds = %cond_exit_549
  %135 = or disjoint i64 %133, 2
  store i64 %135, ptr %81, align 4
  %136 = getelementptr inbounds nuw i8, ptr %80, i64 8
  %137 = load i64, ptr %136, align 4
  tail call void @___dec_future_refcount(i64 %137)
  br label %cond_exit_549.1

cond_exit_549.1:                                  ; preds = %__barray_mask_borrow.exit542.1, %cond_exit_549
  %138 = load i64, ptr %81, align 4
  %139 = and i64 %138, 4
  %.not569 = icmp eq i64 %139, 0
  br i1 %.not569, label %__barray_mask_borrow.exit542.2, label %cond_exit_549.2

__barray_mask_borrow.exit542.2:                   ; preds = %cond_exit_549.1
  %140 = or disjoint i64 %138, 4
  store i64 %140, ptr %81, align 4
  %141 = getelementptr inbounds nuw i8, ptr %80, i64 16
  %142 = load i64, ptr %141, align 4
  tail call void @___dec_future_refcount(i64 %142)
  br label %cond_exit_549.2

cond_exit_549.2:                                  ; preds = %__barray_mask_borrow.exit542.2, %cond_exit_549.1
  %143 = load i64, ptr %81, align 4
  %144 = or i64 %143, -8
  store i64 %144, ptr %81, align 4
  %145 = icmp eq i64 %144, -1
  br i1 %145, label %loop_out296, label %mask_block_err.i

loop_out296:                                      ; preds = %cond_exit_549.2
  tail call void @heap_free(ptr nonnull %80)
  tail call void @heap_free(ptr nonnull %81)
  %read_bool = tail call i1 @___read_future_bool(i64 %111)
  tail call void @___dec_future_refcount(i64 %111)
  tail call void @print_bool(ptr nonnull @res_c0.7C14CD6E.0, i64 12, i1 %read_bool)
  %read_bool365 = tail call i1 @___read_future_bool(i64 %118)
  tail call void @___dec_future_refcount(i64 %118)
  tail call void @print_bool(ptr nonnull @res_c1.1F7A6571.0, i64 12, i1 %read_bool365)
  %read_bool380 = tail call i1 @___read_future_bool(i64 %125)
  tail call void @___dec_future_refcount(i64 %125)
  tail call void @print_bool(ptr nonnull @res_c2.60825383.0, i64 12, i1 %read_bool380)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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
