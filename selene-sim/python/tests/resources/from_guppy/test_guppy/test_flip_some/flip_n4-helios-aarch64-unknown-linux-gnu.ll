; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_cs.46C3C4B5.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:cs"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 32)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_410_case_0.i, label %__hugr__.__tk2_helios_qalloc.383.exit

cond_410_case_0.i:                                ; preds = %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.383.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.3, %__hugr__.__tk2_helios_qalloc.383.exit.2, %__hugr__.__tk2_helios_qalloc.383.exit.1, %__hugr__.__tk2_helios_qalloc.383.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.383.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_410_case_0.i, label %__hugr__.__tk2_helios_qalloc.383.exit.1

__hugr__.__tk2_helios_qalloc.383.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not219 = icmp eq i64 %6, 0
  br i1 %.not219, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.383.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_410_case_0.i, label %__hugr__.__tk2_helios_qalloc.383.exit.2

__hugr__.__tk2_helios_qalloc.383.exit.2:          ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not220 = icmp eq i64 %10, 0
  br i1 %.not220, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_helios_qalloc.383.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_410_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not221 = icmp eq i64 %14, 0
  br i1 %.not221, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %17 = load i64, ptr %1, align 4
  %18 = trunc i64 %17 to i1
  br i1 %18, label %panic.i168, label %__barray_mask_borrow.exit

panic.i168:                                       ; preds = %cond_exit_20.3
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.3
  %19 = or disjoint i64 %17, 1
  store i64 %19, ptr %1, align 4
  %20 = load i64, ptr %0, align 4
  tail call void @___rxy(i64 %20, double 0x400921FB54442D18, double 0.000000e+00)
  %21 = load i64, ptr %1, align 4
  %22 = trunc i64 %21 to i1
  br i1 %22, label %__barray_mask_return.exit170, label %panic.i169

panic.i169:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit170:                     ; preds = %__barray_mask_borrow.exit
  %23 = and i64 %21, -2
  store i64 %23, ptr %1, align 4
  store i64 %20, ptr %0, align 4
  %24 = load i64, ptr %1, align 4
  %25 = and i64 %24, 4
  %.not = icmp eq i64 %25, 0
  br i1 %.not, label %__barray_mask_borrow.exit172, label %panic.i171

panic.i171:                                       ; preds = %__barray_mask_return.exit170
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit172:                     ; preds = %__barray_mask_return.exit170
  %26 = or disjoint i64 %24, 4
  store i64 %26, ptr %1, align 4
  %27 = load i64, ptr %12, align 4
  tail call void @___rxy(i64 %27, double 0x400921FB54442D18, double 0.000000e+00)
  %28 = load i64, ptr %1, align 4
  %29 = and i64 %28, 4
  %.not199 = icmp eq i64 %29, 0
  br i1 %.not199, label %panic.i173, label %__barray_mask_return.exit174

panic.i173:                                       ; preds = %__barray_mask_borrow.exit172
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit174:                     ; preds = %__barray_mask_borrow.exit172
  %30 = and i64 %28, -5
  store i64 %30, ptr %1, align 4
  store i64 %27, ptr %12, align 4
  %31 = load i64, ptr %1, align 4
  %32 = and i64 %31, 8
  %.not200 = icmp eq i64 %32, 0
  br i1 %.not200, label %__barray_mask_borrow.exit176, label %panic.i175

panic.i175:                                       ; preds = %__barray_mask_return.exit174
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit176:                     ; preds = %__barray_mask_return.exit174
  %33 = or disjoint i64 %31, 8
  store i64 %33, ptr %1, align 4
  %34 = load i64, ptr %16, align 4
  tail call void @___rxy(i64 %34, double 0x400921FB54442D18, double 0.000000e+00)
  %35 = load i64, ptr %1, align 4
  %36 = and i64 %35, 8
  %.not201 = icmp eq i64 %36, 0
  br i1 %.not201, label %panic.i177, label %__barray_mask_return.exit178

panic.i177:                                       ; preds = %__barray_mask_borrow.exit176
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit178:                     ; preds = %__barray_mask_borrow.exit176
  %37 = and i64 %35, -9
  store i64 %37, ptr %1, align 4
  store i64 %34, ptr %16, align 4
  %38 = tail call ptr @heap_alloc(i64 32)
  %39 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %39, align 1
  %40 = load i64, ptr %1, align 4
  %41 = trunc i64 %40 to i1
  br i1 %41, label %panic.i.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.i"

"__hugr__.guppylang.std.quantum.measure_array$4.140.exit": ; preds = %loop_body.3.i
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %42 = tail call ptr @heap_alloc(i64 4)
  %43 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %43, align 1
  %44 = load i64, ptr %39, align 4
  %45 = trunc i64 %44 to i1
  br i1 %45, label %panic.i.i.i194, label %__barray_check_bounds.exit221.i.i

mask_block_err.i.i.i:                             ; preds = %loop_body.3.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.3.i, %loop_body.1.i, %loop_body.i, %__barray_mask_return.exit178
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.i": ; preds = %__barray_mask_return.exit178
  %46 = or disjoint i64 %40, 1
  store i64 %46, ptr %1, align 4
  %47 = load i64, ptr %0, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %47)
  tail call void @___qfree(i64 %47)
  %48 = load i64, ptr %39, align 4
  %49 = trunc i64 %48 to i1
  br i1 %49, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.3.i, %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.2.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.1.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.i"
  %50 = and i64 %48, -2
  store i64 %50, ptr %39, align 4
  store i64 %lazy_measure.i, ptr %38, align 4
  %51 = load i64, ptr %1, align 4
  %52 = and i64 %51, 2
  %.not202 = icmp eq i64 %52, 0
  br i1 %.not202, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.1.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.1.i": ; preds = %loop_body.i
  %53 = or disjoint i64 %51, 2
  store i64 %53, ptr %1, align 4
  %54 = load i64, ptr %8, align 4
  %lazy_measure.1.i = tail call i64 @___lazy_measure(i64 %54)
  tail call void @___qfree(i64 %54)
  %55 = load i64, ptr %39, align 4
  %56 = and i64 %55, 2
  %.not.i = icmp eq i64 %56, 0
  br i1 %.not.i, label %panic.i.i, label %loop_body.1.i

loop_body.1.i:                                    ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.1.i"
  %57 = and i64 %55, -3
  store i64 %57, ptr %39, align 4
  %58 = getelementptr inbounds nuw i8, ptr %38, i64 8
  store i64 %lazy_measure.1.i, ptr %58, align 4
  %59 = load i64, ptr %1, align 4
  %60 = and i64 %59, 4
  %.not203 = icmp eq i64 %60, 0
  br i1 %.not203, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.2.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.2.i": ; preds = %loop_body.1.i
  %61 = or disjoint i64 %59, 4
  store i64 %61, ptr %1, align 4
  %62 = load i64, ptr %12, align 4
  %lazy_measure.2.i = tail call i64 @___lazy_measure(i64 %62)
  tail call void @___qfree(i64 %62)
  %63 = load i64, ptr %39, align 4
  %64 = and i64 %63, 4
  %.not182.i = icmp eq i64 %64, 0
  br i1 %.not182.i, label %panic.i.i, label %__barray_check_bounds.exit.i.3.i

__barray_check_bounds.exit.i.3.i:                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&4.297.exit.thread.2.i"
  %65 = and i64 %63, -5
  store i64 %65, ptr %39, align 4
  %66 = getelementptr inbounds nuw i8, ptr %38, i64 16
  store i64 %lazy_measure.2.i, ptr %66, align 4
  %67 = load i64, ptr %1, align 4
  %68 = and i64 %67, 8
  %.not204 = icmp eq i64 %68, 0
  br i1 %.not204, label %__barray_check_bounds.exit.3.i, label %panic.i.i.i

__barray_check_bounds.exit.3.i:                   ; preds = %__barray_check_bounds.exit.i.3.i
  %69 = or disjoint i64 %67, 8
  store i64 %69, ptr %1, align 4
  %70 = load i64, ptr %16, align 4
  %lazy_measure.3.i = tail call i64 @___lazy_measure(i64 %70)
  tail call void @___qfree(i64 %70)
  %71 = load i64, ptr %39, align 4
  %72 = and i64 %71, 8
  %.not183.i = icmp eq i64 %72, 0
  br i1 %.not183.i, label %panic.i.i, label %loop_body.3.i

loop_body.3.i:                                    ; preds = %__barray_check_bounds.exit.3.i
  %73 = and i64 %71, -9
  store i64 %73, ptr %39, align 4
  %74 = getelementptr inbounds nuw i8, ptr %38, i64 24
  store i64 %lazy_measure.3.i, ptr %74, align 4
  %75 = load i64, ptr %1, align 4
  %76 = or i64 %75, -16
  store i64 %76, ptr %1, align 4
  %77 = icmp eq i64 %76, -1
  br i1 %77, label %"__hugr__.guppylang.std.quantum.measure_array$4.140.exit", label %mask_block_err.i.i.i

panic.i.i.i194:                                   ; preds = %__barray_check_bounds.exit.i.3.i183, %loop_body.1.i182, %loop_body.i180, %"__hugr__.guppylang.std.quantum.measure_array$4.140.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %"__hugr__.guppylang.std.quantum.measure_array$4.140.exit"
  %78 = or disjoint i64 %44, 1
  store i64 %78, ptr %39, align 4
  %79 = load i64, ptr %38, align 4
  tail call void @___inc_future_refcount(i64 %79)
  %80 = load i64, ptr %39, align 4
  %81 = trunc i64 %80 to i1
  br i1 %81, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.i", label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.3.i, %__barray_check_bounds.exit221.i.2.i, %__barray_check_bounds.exit221.i.1.i, %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.i": ; preds = %__barray_check_bounds.exit221.i.i
  %82 = and i64 %80, -2
  store i64 %82, ptr %39, align 4
  store i64 %79, ptr %38, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %79)
  tail call void @___dec_future_refcount(i64 %79)
  %83 = load i64, ptr %43, align 4
  %84 = trunc i64 %83 to i1
  br i1 %84, label %loop_body.i180, label %panic.i.i179

"__hugr__.guppylang.std.quantum.collect_measurements$4.181.exit": ; preds = %cond_exit_433.thread.3.i.i
  tail call void @heap_free(ptr nonnull %38)
  tail call void @heap_free(ptr nonnull %39)
  %85 = load i64, ptr %43, align 4
  %86 = and i64 %85, 15
  store i64 %86, ptr %43, align 4
  %87 = icmp eq i64 %86, 0
  br i1 %87, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i189:                          ; preds = %cond_exit_433.thread.3.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i.i:                 ; preds = %loop_body.3.i185
  %88 = or disjoint i64 %139, 1
  store i64 %88, ptr %39, align 4
  %89 = load i64, ptr %38, align 4
  tail call void @___dec_future_refcount(i64 %89)
  %.pre = load i64, ptr %39, align 4
  br label %cond_exit_433.thread.i.i

cond_exit_433.thread.i.i:                         ; preds = %loop_body.3.i185, %__barray_mask_borrow.exit228.i.i
  %90 = phi i64 [ %139, %loop_body.3.i185 ], [ %.pre, %__barray_mask_borrow.exit228.i.i ]
  %91 = and i64 %90, 2
  %.not211 = icmp eq i64 %91, 0
  br i1 %.not211, label %__barray_mask_borrow.exit228.1.i.i, label %cond_exit_433.thread.1.i.i

__barray_mask_borrow.exit228.1.i.i:               ; preds = %cond_exit_433.thread.i.i
  %92 = or disjoint i64 %90, 2
  store i64 %92, ptr %39, align 4
  %93 = load i64, ptr %58, align 4
  tail call void @___dec_future_refcount(i64 %93)
  %.pre216 = load i64, ptr %39, align 4
  br label %cond_exit_433.thread.1.i.i

cond_exit_433.thread.1.i.i:                       ; preds = %__barray_mask_borrow.exit228.1.i.i, %cond_exit_433.thread.i.i
  %94 = phi i64 [ %.pre216, %__barray_mask_borrow.exit228.1.i.i ], [ %90, %cond_exit_433.thread.i.i ]
  %95 = and i64 %94, 4
  %.not212 = icmp eq i64 %95, 0
  br i1 %.not212, label %__barray_mask_borrow.exit228.2.i.i, label %cond_exit_433.thread.2.i.i

__barray_mask_borrow.exit228.2.i.i:               ; preds = %cond_exit_433.thread.1.i.i
  %96 = or disjoint i64 %94, 4
  store i64 %96, ptr %39, align 4
  %97 = load i64, ptr %66, align 4
  tail call void @___dec_future_refcount(i64 %97)
  %.pre217 = load i64, ptr %39, align 4
  br label %cond_exit_433.thread.2.i.i

cond_exit_433.thread.2.i.i:                       ; preds = %__barray_mask_borrow.exit228.2.i.i, %cond_exit_433.thread.1.i.i
  %98 = phi i64 [ %.pre217, %__barray_mask_borrow.exit228.2.i.i ], [ %94, %cond_exit_433.thread.1.i.i ]
  %99 = and i64 %98, 8
  %.not213 = icmp eq i64 %99, 0
  br i1 %.not213, label %__barray_mask_borrow.exit228.3.i.i, label %cond_exit_433.thread.3.i.i

__barray_mask_borrow.exit228.3.i.i:               ; preds = %cond_exit_433.thread.2.i.i
  %100 = or disjoint i64 %98, 8
  store i64 %100, ptr %39, align 4
  %101 = load i64, ptr %74, align 4
  tail call void @___dec_future_refcount(i64 %101)
  %.pre218 = load i64, ptr %39, align 4
  br label %cond_exit_433.thread.3.i.i

cond_exit_433.thread.3.i.i:                       ; preds = %__barray_mask_borrow.exit228.3.i.i, %cond_exit_433.thread.2.i.i
  %102 = phi i64 [ %.pre218, %__barray_mask_borrow.exit228.3.i.i ], [ %98, %cond_exit_433.thread.2.i.i ]
  %103 = or i64 %102, -16
  store i64 %103, ptr %39, align 4
  %104 = icmp eq i64 %103, -1
  br i1 %104, label %"__hugr__.guppylang.std.quantum.collect_measurements$4.181.exit", label %mask_block_err.i.i.i189

panic.i.i179:                                     ; preds = %__barray_check_bounds.exit.3.i184, %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.2.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.1.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i180:                                   ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.i"
  %105 = and i64 %83, -2
  store i64 %105, ptr %43, align 4
  store i1 %read_bool.i, ptr %42, align 1
  %106 = load i64, ptr %39, align 4
  %107 = and i64 %106, 2
  %.not205 = icmp eq i64 %107, 0
  br i1 %.not205, label %__barray_check_bounds.exit221.i.1.i, label %panic.i.i.i194

__barray_check_bounds.exit221.i.1.i:              ; preds = %loop_body.i180
  %108 = or disjoint i64 %106, 2
  store i64 %108, ptr %39, align 4
  %109 = load i64, ptr %58, align 4
  tail call void @___inc_future_refcount(i64 %109)
  %110 = load i64, ptr %39, align 4
  %111 = and i64 %110, 2
  %.not206 = icmp eq i64 %111, 0
  br i1 %.not206, label %panic.i222.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.1.i"

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.1.i": ; preds = %__barray_check_bounds.exit221.i.1.i
  %112 = and i64 %110, -3
  store i64 %112, ptr %39, align 4
  store i64 %109, ptr %58, align 4
  %read_bool.1.i = tail call i1 @___read_future_bool(i64 %109)
  tail call void @___dec_future_refcount(i64 %109)
  %113 = load i64, ptr %43, align 4
  %114 = and i64 %113, 2
  %.not.i181 = icmp eq i64 %114, 0
  br i1 %.not.i181, label %panic.i.i179, label %loop_body.1.i182

loop_body.1.i182:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.1.i"
  %115 = and i64 %113, -3
  store i64 %115, ptr %43, align 4
  %116 = getelementptr inbounds nuw i8, ptr %42, i64 1
  store i1 %read_bool.1.i, ptr %116, align 1
  %117 = load i64, ptr %39, align 4
  %118 = and i64 %117, 4
  %.not207 = icmp eq i64 %118, 0
  br i1 %.not207, label %__barray_check_bounds.exit221.i.2.i, label %panic.i.i.i194

__barray_check_bounds.exit221.i.2.i:              ; preds = %loop_body.1.i182
  %119 = or disjoint i64 %117, 4
  store i64 %119, ptr %39, align 4
  %120 = load i64, ptr %66, align 4
  tail call void @___inc_future_refcount(i64 %120)
  %121 = load i64, ptr %39, align 4
  %122 = and i64 %121, 4
  %.not208 = icmp eq i64 %122, 0
  br i1 %.not208, label %panic.i222.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.2.i"

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.2.i": ; preds = %__barray_check_bounds.exit221.i.2.i
  %123 = and i64 %121, -5
  store i64 %123, ptr %39, align 4
  store i64 %120, ptr %66, align 4
  %read_bool.2.i = tail call i1 @___read_future_bool(i64 %120)
  tail call void @___dec_future_refcount(i64 %120)
  %124 = load i64, ptr %43, align 4
  %125 = and i64 %124, 4
  %.not169.i = icmp eq i64 %125, 0
  br i1 %.not169.i, label %panic.i.i179, label %__barray_check_bounds.exit.i.3.i183

__barray_check_bounds.exit.i.3.i183:              ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&4.234.exit.thread.2.i"
  %126 = and i64 %124, -5
  store i64 %126, ptr %43, align 4
  %127 = getelementptr inbounds nuw i8, ptr %42, i64 2
  store i1 %read_bool.2.i, ptr %127, align 1
  %128 = load i64, ptr %39, align 4
  %129 = and i64 %128, 8
  %.not209 = icmp eq i64 %129, 0
  br i1 %.not209, label %__barray_check_bounds.exit221.i.3.i, label %panic.i.i.i194

__barray_check_bounds.exit221.i.3.i:              ; preds = %__barray_check_bounds.exit.i.3.i183
  %130 = or disjoint i64 %128, 8
  store i64 %130, ptr %39, align 4
  %131 = load i64, ptr %74, align 4
  tail call void @___inc_future_refcount(i64 %131)
  %132 = load i64, ptr %39, align 4
  %133 = and i64 %132, 8
  %.not210 = icmp eq i64 %133, 0
  br i1 %.not210, label %panic.i222.i.i, label %__barray_check_bounds.exit.3.i184

__barray_check_bounds.exit.3.i184:                ; preds = %__barray_check_bounds.exit221.i.3.i
  %134 = and i64 %132, -9
  store i64 %134, ptr %39, align 4
  store i64 %131, ptr %74, align 4
  %read_bool.3.i = tail call i1 @___read_future_bool(i64 %131)
  tail call void @___dec_future_refcount(i64 %131)
  %135 = load i64, ptr %43, align 4
  %136 = and i64 %135, 8
  %.not170.i = icmp eq i64 %136, 0
  br i1 %.not170.i, label %panic.i.i179, label %loop_body.3.i185

loop_body.3.i185:                                 ; preds = %__barray_check_bounds.exit.3.i184
  %137 = and i64 %135, -9
  store i64 %137, ptr %43, align 4
  %138 = getelementptr inbounds nuw i8, ptr %42, i64 3
  store i1 %read_bool.3.i, ptr %138, align 1
  %139 = load i64, ptr %39, align 4
  %140 = trunc i64 %139 to i1
  br i1 %140, label %cond_exit_433.thread.i.i, label %__barray_mask_borrow.exit228.i.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$4.181.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$4.181.exit"
  %141 = tail call ptr @heap_alloc(i64 4)
  %142 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %142, align 1
  %143 = load i32, ptr %42, align 1
  store i32 %143, ptr %141, align 1
  tail call void @heap_free(ptr nonnull %141)
  %144 = load i64, ptr %43, align 4
  %145 = and i64 %144, 15
  store i64 %145, ptr %43, align 4
  %146 = icmp eq i64 %145, 0
  br i1 %146, label %__barray_check_none_borrowed.exit196, label %mask_block_err.i195

mask_block_err.i195:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit196:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %147 = alloca [4 x i1], align 4
  store i32 0, ptr %147, align 4
  store i32 4, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %42, ptr %arr_ptr, align 8
  store ptr %147, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

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
