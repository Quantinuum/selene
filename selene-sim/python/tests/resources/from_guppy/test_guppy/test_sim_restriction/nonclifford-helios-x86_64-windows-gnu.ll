; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_cs.46C3C4B5.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:cs"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 24)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_447_case_0.i, label %__hugr__.__tk2_helios_qalloc.420.exit

cond_447_case_0.i:                                ; preds = %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.420.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.2, %__hugr__.__tk2_helios_qalloc.420.exit.1, %__hugr__.__tk2_helios_qalloc.420.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.420.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_447_case_0.i, label %__hugr__.__tk2_helios_qalloc.420.exit.1

__hugr__.__tk2_helios_qalloc.420.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not228 = icmp eq i64 %6, 0
  br i1 %.not228, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.420.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_447_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not229 = icmp eq i64 %10, 0
  br i1 %.not229, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %13 = load i64, ptr %1, align 4
  %14 = trunc i64 %13 to i1
  br i1 %14, label %panic.i179, label %__barray_mask_borrow.exit

panic.i179:                                       ; preds = %cond_exit_20.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.2
  %15 = or disjoint i64 %13, 1
  store i64 %15, ptr %1, align 4
  %16 = load i64, ptr %0, align 4
  tail call void @___rxy(i64 %16, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %16, double 0x400921FB54442D18)
  %17 = load i64, ptr %1, align 4
  %18 = trunc i64 %17 to i1
  br i1 %18, label %__barray_mask_return.exit181, label %panic.i180

panic.i180:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit181:                     ; preds = %__barray_mask_borrow.exit
  %19 = and i64 %17, -2
  store i64 %19, ptr %1, align 4
  store i64 %16, ptr %0, align 4
  %20 = load i64, ptr %1, align 4
  %21 = trunc i64 %20 to i1
  br i1 %21, label %panic.i182, label %__barray_mask_borrow.exit183

panic.i182:                                       ; preds = %__barray_mask_return.exit181
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit183:                     ; preds = %__barray_mask_return.exit181
  %22 = or disjoint i64 %20, 1
  store i64 %22, ptr %1, align 4
  %23 = load i64, ptr %0, align 4
  %24 = and i64 %20, 2
  %.not = icmp eq i64 %24, 0
  br i1 %.not, label %__barray_mask_borrow.exit185, label %panic.i184

panic.i184:                                       ; preds = %__barray_mask_borrow.exit183
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit185:                     ; preds = %__barray_mask_borrow.exit183
  %25 = or disjoint i64 %20, 3
  store i64 %25, ptr %1, align 4
  %26 = load i64, ptr %8, align 4
  %27 = and i64 %20, 4
  %.not213 = icmp eq i64 %27, 0
  br i1 %.not213, label %__barray_mask_borrow.exit187, label %panic.i186

panic.i186:                                       ; preds = %__barray_mask_borrow.exit185
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit187:                     ; preds = %__barray_mask_borrow.exit185
  %28 = or disjoint i64 %20, 7
  store i64 %28, ptr %1, align 4
  %29 = load i64, ptr %12, align 4
  tail call void @___rxy(i64 %29, double 0x400921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rzz(i64 %26, i64 %29, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %29, double 0x3FE921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %23, i64 %29, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %29, double 0x3FE921FB54442D18, double 0.000000e+00)
  tail call void @___rzz(i64 %26, i64 %29, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %29, double 0x3FE921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rzz(i64 %23, i64 %29, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %29, double 0xC002D97C7F3321D2, double 0x400921FB54442D18)
  tail call void @___rz(i64 %29, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %23, double 0x400921FB54442D18, double 0x3FE921FB54442D18)
  tail call void @___rzz(i64 %23, i64 %26, double 0x3FE921FB54442D18)
  tail call void @___rz(i64 %26, double 0xC002D97C7F3321D2)
  tail call void @___rxy(i64 %23, double 0x400921FB54442D18, double 0xBFE921FB54442D18)
  tail call void @___rz(i64 %23, double 0x3FE921FB54442D18)
  %30 = load i64, ptr %1, align 4
  %31 = trunc i64 %30 to i1
  br i1 %31, label %__barray_mask_return.exit189, label %panic.i188

panic.i188:                                       ; preds = %__barray_mask_borrow.exit187
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit189:                     ; preds = %__barray_mask_borrow.exit187
  %32 = and i64 %30, -2
  store i64 %32, ptr %1, align 4
  store i64 %23, ptr %0, align 4
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 2
  %.not214 = icmp eq i64 %34, 0
  br i1 %.not214, label %panic.i190, label %__barray_mask_return.exit191

panic.i190:                                       ; preds = %__barray_mask_return.exit189
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit191:                     ; preds = %__barray_mask_return.exit189
  %35 = and i64 %33, -3
  store i64 %35, ptr %1, align 4
  store i64 %26, ptr %8, align 4
  %36 = load i64, ptr %1, align 4
  %37 = and i64 %36, 4
  %.not215 = icmp eq i64 %37, 0
  br i1 %.not215, label %panic.i192, label %__barray_mask_return.exit193

panic.i192:                                       ; preds = %__barray_mask_return.exit191
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit193:                     ; preds = %__barray_mask_return.exit191
  %38 = and i64 %36, -5
  store i64 %38, ptr %1, align 4
  store i64 %29, ptr %12, align 4
  %39 = tail call ptr @heap_alloc(i64 24)
  %40 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %40, align 1
  %41 = load i64, ptr %1, align 4
  %42 = trunc i64 %41 to i1
  br i1 %42, label %panic.i.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.302.exit.thread.i"

"__hugr__.guppylang.std.quantum.measure_array$3.145.exit": ; preds = %loop_body.2.i
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %43 = tail call ptr @heap_alloc(i64 3)
  %44 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %44, align 1
  %45 = load i64, ptr %40, align 4
  %46 = trunc i64 %45 to i1
  br i1 %46, label %panic.i.i.i208, label %__barray_check_bounds.exit221.i.i

mask_block_err.i.i.i:                             ; preds = %loop_body.2.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.2.i, %loop_body.i, %__barray_mask_return.exit193
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.302.exit.thread.i": ; preds = %__barray_mask_return.exit193
  %47 = or disjoint i64 %41, 1
  store i64 %47, ptr %1, align 4
  %48 = load i64, ptr %0, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %48)
  tail call void @___qfree(i64 %48)
  %49 = load i64, ptr %40, align 4
  %50 = trunc i64 %49 to i1
  br i1 %50, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.2.i, %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.302.exit.thread.1.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.302.exit.thread.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.302.exit.thread.i"
  %51 = and i64 %49, -2
  store i64 %51, ptr %40, align 4
  store i64 %lazy_measure.i, ptr %39, align 4
  %52 = load i64, ptr %1, align 4
  %53 = and i64 %52, 2
  %.not216 = icmp eq i64 %53, 0
  br i1 %.not216, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.302.exit.thread.1.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.302.exit.thread.1.i": ; preds = %loop_body.i
  %54 = or disjoint i64 %52, 2
  store i64 %54, ptr %1, align 4
  %55 = load i64, ptr %8, align 4
  %lazy_measure.1.i = tail call i64 @___lazy_measure(i64 %55)
  tail call void @___qfree(i64 %55)
  %56 = load i64, ptr %40, align 4
  %57 = and i64 %56, 2
  %.not.i = icmp eq i64 %57, 0
  br i1 %.not.i, label %panic.i.i, label %__barray_check_bounds.exit.i.2.i

__barray_check_bounds.exit.i.2.i:                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&3.302.exit.thread.1.i"
  %58 = and i64 %56, -3
  store i64 %58, ptr %40, align 4
  %59 = getelementptr inbounds nuw i8, ptr %39, i64 8
  store i64 %lazy_measure.1.i, ptr %59, align 4
  %60 = load i64, ptr %1, align 4
  %61 = and i64 %60, 4
  %.not217 = icmp eq i64 %61, 0
  br i1 %.not217, label %__barray_check_bounds.exit.2.i, label %panic.i.i.i

__barray_check_bounds.exit.2.i:                   ; preds = %__barray_check_bounds.exit.i.2.i
  %62 = or disjoint i64 %60, 4
  store i64 %62, ptr %1, align 4
  %63 = load i64, ptr %12, align 4
  %lazy_measure.2.i = tail call i64 @___lazy_measure(i64 %63)
  tail call void @___qfree(i64 %63)
  %64 = load i64, ptr %40, align 4
  %65 = and i64 %64, 4
  %.not182.i = icmp eq i64 %65, 0
  br i1 %.not182.i, label %panic.i.i, label %loop_body.2.i

loop_body.2.i:                                    ; preds = %__barray_check_bounds.exit.2.i
  %66 = and i64 %64, -5
  store i64 %66, ptr %40, align 4
  %67 = getelementptr inbounds nuw i8, ptr %39, i64 16
  store i64 %lazy_measure.2.i, ptr %67, align 4
  %68 = load i64, ptr %1, align 4
  %69 = or i64 %68, -8
  store i64 %69, ptr %1, align 4
  %70 = icmp eq i64 %69, -1
  br i1 %70, label %"__hugr__.guppylang.std.quantum.measure_array$3.145.exit", label %mask_block_err.i.i.i

panic.i.i.i208:                                   ; preds = %__barray_check_bounds.exit.i.2.i197, %loop_body.i195, %"__hugr__.guppylang.std.quantum.measure_array$3.145.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %"__hugr__.guppylang.std.quantum.measure_array$3.145.exit"
  %71 = or disjoint i64 %45, 1
  store i64 %71, ptr %40, align 4
  %72 = load i64, ptr %39, align 4
  tail call void @___inc_future_refcount(i64 %72)
  %73 = load i64, ptr %40, align 4
  %74 = trunc i64 %73 to i1
  br i1 %74, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&3.239.exit.thread.i", label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.2.i, %__barray_check_bounds.exit221.i.1.i, %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&3.239.exit.thread.i": ; preds = %__barray_check_bounds.exit221.i.i
  %75 = and i64 %73, -2
  store i64 %75, ptr %40, align 4
  store i64 %72, ptr %39, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %72)
  tail call void @___dec_future_refcount(i64 %72)
  %76 = load i64, ptr %44, align 4
  %77 = trunc i64 %76 to i1
  br i1 %77, label %loop_body.i195, label %panic.i.i194

"__hugr__.guppylang.std.quantum.collect_measurements$3.186.exit": ; preds = %cond_exit_470.thread.2.i.i
  tail call void @heap_free(ptr nonnull %39)
  tail call void @heap_free(ptr nonnull %40)
  %78 = load i64, ptr %44, align 4
  %79 = and i64 %78, 7
  store i64 %79, ptr %44, align 4
  %80 = icmp eq i64 %79, 0
  br i1 %80, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i.i.i203:                          ; preds = %cond_exit_470.thread.2.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i.i:                 ; preds = %loop_body.2.i199
  %81 = or disjoint i64 %117, 1
  store i64 %81, ptr %40, align 4
  %82 = load i64, ptr %39, align 4
  tail call void @___dec_future_refcount(i64 %82)
  %.pre = load i64, ptr %40, align 4
  br label %cond_exit_470.thread.i.i

cond_exit_470.thread.i.i:                         ; preds = %loop_body.2.i199, %__barray_mask_borrow.exit228.i.i
  %83 = phi i64 [ %117, %loop_body.2.i199 ], [ %.pre, %__barray_mask_borrow.exit228.i.i ]
  %84 = and i64 %83, 2
  %.not222 = icmp eq i64 %84, 0
  br i1 %.not222, label %__barray_mask_borrow.exit228.1.i.i, label %cond_exit_470.thread.1.i.i

__barray_mask_borrow.exit228.1.i.i:               ; preds = %cond_exit_470.thread.i.i
  %85 = or disjoint i64 %83, 2
  store i64 %85, ptr %40, align 4
  %86 = load i64, ptr %59, align 4
  tail call void @___dec_future_refcount(i64 %86)
  %.pre226 = load i64, ptr %40, align 4
  br label %cond_exit_470.thread.1.i.i

cond_exit_470.thread.1.i.i:                       ; preds = %__barray_mask_borrow.exit228.1.i.i, %cond_exit_470.thread.i.i
  %87 = phi i64 [ %.pre226, %__barray_mask_borrow.exit228.1.i.i ], [ %83, %cond_exit_470.thread.i.i ]
  %88 = and i64 %87, 4
  %.not223 = icmp eq i64 %88, 0
  br i1 %.not223, label %__barray_mask_borrow.exit228.2.i.i, label %cond_exit_470.thread.2.i.i

__barray_mask_borrow.exit228.2.i.i:               ; preds = %cond_exit_470.thread.1.i.i
  %89 = or disjoint i64 %87, 4
  store i64 %89, ptr %40, align 4
  %90 = load i64, ptr %67, align 4
  tail call void @___dec_future_refcount(i64 %90)
  %.pre227 = load i64, ptr %40, align 4
  br label %cond_exit_470.thread.2.i.i

cond_exit_470.thread.2.i.i:                       ; preds = %__barray_mask_borrow.exit228.2.i.i, %cond_exit_470.thread.1.i.i
  %91 = phi i64 [ %.pre227, %__barray_mask_borrow.exit228.2.i.i ], [ %87, %cond_exit_470.thread.1.i.i ]
  %92 = or i64 %91, -8
  store i64 %92, ptr %40, align 4
  %93 = icmp eq i64 %92, -1
  br i1 %93, label %"__hugr__.guppylang.std.quantum.collect_measurements$3.186.exit", label %mask_block_err.i.i.i203

panic.i.i194:                                     ; preds = %__barray_check_bounds.exit.2.i198, %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&3.239.exit.thread.1.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&3.239.exit.thread.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i195:                                   ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&3.239.exit.thread.i"
  %94 = and i64 %76, -2
  store i64 %94, ptr %44, align 4
  store i1 %read_bool.i, ptr %43, align 1
  %95 = load i64, ptr %40, align 4
  %96 = and i64 %95, 2
  %.not218 = icmp eq i64 %96, 0
  br i1 %.not218, label %__barray_check_bounds.exit221.i.1.i, label %panic.i.i.i208

__barray_check_bounds.exit221.i.1.i:              ; preds = %loop_body.i195
  %97 = or disjoint i64 %95, 2
  store i64 %97, ptr %40, align 4
  %98 = load i64, ptr %59, align 4
  tail call void @___inc_future_refcount(i64 %98)
  %99 = load i64, ptr %40, align 4
  %100 = and i64 %99, 2
  %.not219 = icmp eq i64 %100, 0
  br i1 %.not219, label %panic.i222.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&3.239.exit.thread.1.i"

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&3.239.exit.thread.1.i": ; preds = %__barray_check_bounds.exit221.i.1.i
  %101 = and i64 %99, -3
  store i64 %101, ptr %40, align 4
  store i64 %98, ptr %59, align 4
  %read_bool.1.i = tail call i1 @___read_future_bool(i64 %98)
  tail call void @___dec_future_refcount(i64 %98)
  %102 = load i64, ptr %44, align 4
  %103 = and i64 %102, 2
  %.not.i196 = icmp eq i64 %103, 0
  br i1 %.not.i196, label %panic.i.i194, label %__barray_check_bounds.exit.i.2.i197

__barray_check_bounds.exit.i.2.i197:              ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&3.239.exit.thread.1.i"
  %104 = and i64 %102, -3
  store i64 %104, ptr %44, align 4
  %105 = getelementptr inbounds nuw i8, ptr %43, i64 1
  store i1 %read_bool.1.i, ptr %105, align 1
  %106 = load i64, ptr %40, align 4
  %107 = and i64 %106, 4
  %.not220 = icmp eq i64 %107, 0
  br i1 %.not220, label %__barray_check_bounds.exit221.i.2.i, label %panic.i.i.i208

__barray_check_bounds.exit221.i.2.i:              ; preds = %__barray_check_bounds.exit.i.2.i197
  %108 = or disjoint i64 %106, 4
  store i64 %108, ptr %40, align 4
  %109 = load i64, ptr %67, align 4
  tail call void @___inc_future_refcount(i64 %109)
  %110 = load i64, ptr %40, align 4
  %111 = and i64 %110, 4
  %.not221 = icmp eq i64 %111, 0
  br i1 %.not221, label %panic.i222.i.i, label %__barray_check_bounds.exit.2.i198

__barray_check_bounds.exit.2.i198:                ; preds = %__barray_check_bounds.exit221.i.2.i
  %112 = and i64 %110, -5
  store i64 %112, ptr %40, align 4
  store i64 %109, ptr %67, align 4
  %read_bool.2.i = tail call i1 @___read_future_bool(i64 %109)
  tail call void @___dec_future_refcount(i64 %109)
  %113 = load i64, ptr %44, align 4
  %114 = and i64 %113, 4
  %.not169.i = icmp eq i64 %114, 0
  br i1 %.not169.i, label %panic.i.i194, label %loop_body.2.i199

loop_body.2.i199:                                 ; preds = %__barray_check_bounds.exit.2.i198
  %115 = and i64 %113, -5
  store i64 %115, ptr %44, align 4
  %116 = getelementptr inbounds nuw i8, ptr %43, i64 2
  store i1 %read_bool.2.i, ptr %116, align 1
  %117 = load i64, ptr %40, align 4
  %118 = trunc i64 %117 to i1
  br i1 %118, label %cond_exit_470.thread.i.i, label %__barray_mask_borrow.exit228.i.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$3.186.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$3.186.exit"
  %119 = tail call ptr @heap_alloc(i64 3)
  %120 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %120, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(3) %119, ptr noundef nonnull align 1 dereferenceable(3) %43, i64 3, i1 false)
  tail call void @heap_free(ptr nonnull %119)
  %121 = load i64, ptr %44, align 4
  %122 = and i64 %121, 7
  store i64 %122, ptr %44, align 4
  %123 = icmp eq i64 %122, 0
  br i1 %123, label %__barray_check_none_borrowed.exit210, label %mask_block_err.i209

mask_block_err.i209:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit210:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %124 = alloca [3 x i1], align 1
  store i1 false, ptr %124, align 1
  %.repack177 = getelementptr inbounds nuw i8, ptr %124, i64 1
  store i1 false, ptr %.repack177, align 1
  %.repack178 = getelementptr inbounds nuw i8, ptr %124, i64 2
  store i1 false, ptr %.repack178, align 1
  store i32 3, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %43, ptr %arr_ptr, align 8
  store ptr %124, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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
attributes #1 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!name = !{!0}

!0 = !{!"mainlib"}
