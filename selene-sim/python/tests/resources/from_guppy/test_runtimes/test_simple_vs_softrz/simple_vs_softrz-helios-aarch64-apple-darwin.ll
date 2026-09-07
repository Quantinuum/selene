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
  %2 = tail call ptr @heap_alloc(i64 24)
  %3 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %3, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_403_case_0.i, label %__hugr__.__tk2_helios_qalloc.329.exit

cond_403_case_0.i:                                ; preds = %cond_exit_12.1, %cond_exit_12, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.329.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %4 = load i64, ptr %3, align 4
  %5 = trunc i64 %4 to i1
  br i1 %5, label %cond_exit_12, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.2, %__hugr__.__tk2_helios_qalloc.329.exit.1, %__hugr__.__tk2_helios_qalloc.329.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_12:                                     ; preds = %__hugr__.__tk2_helios_qalloc.329.exit
  %6 = and i64 %4, -2
  store i64 %6, ptr %3, align 4
  store i64 %qalloc.i, ptr %2, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_403_case_0.i, label %__hugr__.__tk2_helios_qalloc.329.exit.1

__hugr__.__tk2_helios_qalloc.329.exit.1:          ; preds = %cond_exit_12
  tail call void @___reset(i64 %qalloc.i.1)
  %7 = load i64, ptr %3, align 4
  %8 = and i64 %7, 2
  %.not789 = icmp eq i64 %8, 0
  br i1 %.not789, label %panic.i, label %cond_exit_12.1

cond_exit_12.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.329.exit.1
  %9 = and i64 %7, -3
  store i64 %9, ptr %3, align 4
  %10 = getelementptr inbounds nuw i8, ptr %2, i64 8
  store i64 %qalloc.i.1, ptr %10, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_403_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_12.1
  tail call void @___reset(i64 %qalloc.i.2)
  %11 = load i64, ptr %3, align 4
  %12 = and i64 %11, 4
  %.not790 = icmp eq i64 %12, 0
  br i1 %.not790, label %panic.i, label %cond_exit_12.2

cond_exit_12.2:                                   ; preds = %__barray_check_bounds.exit.2
  %13 = and i64 %11, -5
  store i64 %13, ptr %3, align 4
  %14 = getelementptr inbounds nuw i8, ptr %2, i64 16
  store i64 %qalloc.i.2, ptr %14, align 4
  %15 = load i64, ptr %3, align 4
  %16 = trunc i64 %15 to i1
  br i1 %16, label %panic.i724, label %__barray_mask_borrow.exit

panic.i724:                                       ; preds = %cond_exit_12.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_12.2
  %17 = or disjoint i64 %15, 1
  store i64 %17, ptr %3, align 4
  %18 = load i64, ptr %2, align 4
  tail call void @___rxy(i64 %18, double 0x400921FB54442D18, double 0.000000e+00)
  %19 = load i64, ptr %3, align 4
  %20 = and i64 %19, 2
  %.not = icmp eq i64 %20, 0
  br i1 %.not, label %__barray_mask_borrow.exit726, label %panic.i725

panic.i725:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit726:                     ; preds = %__barray_mask_borrow.exit
  %21 = or disjoint i64 %19, 2
  store i64 %21, ptr %3, align 4
  %22 = load i64, ptr %10, align 4
  tail call void @___rxy(i64 %22, double 0x400921FB54442D18, double 0.000000e+00)
  tail call void @___rxy(i64 %22, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %18, i64 %22, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %18, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %22, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %22, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %22, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %22, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %18, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %18, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %22, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %18, i64 %22, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %18, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %22, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %22, double 0xBFF921FB54442D18)
  %23 = load i64, ptr %3, align 4
  %24 = trunc i64 %23 to i1
  br i1 %24, label %__barray_mask_return.exit730, label %panic.i729

panic.i729:                                       ; preds = %__barray_mask_borrow.exit726
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit730:                     ; preds = %__barray_mask_borrow.exit726
  %25 = and i64 %23, -2
  store i64 %25, ptr %3, align 4
  store i64 %18, ptr %2, align 4
  %26 = load i64, ptr %3, align 4
  %27 = and i64 %26, 4
  %.not779 = icmp eq i64 %27, 0
  br i1 %.not779, label %__barray_mask_borrow.exit732, label %panic.i731

panic.i731:                                       ; preds = %__barray_mask_return.exit730
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit732:                     ; preds = %__barray_mask_return.exit730
  %28 = or disjoint i64 %26, 4
  store i64 %28, ptr %3, align 4
  %29 = load i64, ptr %14, align 4
  tail call void @___rxy(i64 %29, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %22, i64 %29, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %22, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %29, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %29, double 0xBFF921FB54442D18)
  %30 = load i64, ptr %3, align 4
  %31 = and i64 %30, 2
  %.not780 = icmp eq i64 %31, 0
  br i1 %.not780, label %panic.i735, label %__barray_mask_return.exit736

panic.i735:                                       ; preds = %__barray_mask_borrow.exit732
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit736:                     ; preds = %__barray_mask_borrow.exit732
  %32 = and i64 %30, -3
  store i64 %32, ptr %3, align 4
  store i64 %22, ptr %10, align 4
  %33 = load i64, ptr %3, align 4
  %34 = and i64 %33, 4
  %.not781 = icmp eq i64 %34, 0
  br i1 %.not781, label %panic.i737, label %__barray_mask_return.exit738

panic.i737:                                       ; preds = %__barray_mask_return.exit736
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit738:                     ; preds = %__barray_mask_return.exit736
  %35 = and i64 %33, -5
  store i64 %35, ptr %3, align 4
  store i64 %29, ptr %14, align 4
  %36 = load i64, ptr %3, align 4
  %37 = trunc i64 %36 to i1
  br i1 %37, label %panic.i745, label %.thread

panic.i741:                                       ; preds = %__barray_check_bounds.exit740.2, %.thread.1, %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_out191:                                      ; preds = %cond_exit_180.2
  tail call void @heap_free(ptr nonnull %2)
  tail call void @heap_free(ptr nonnull %3)
  %38 = load i64, ptr %1, align 4
  %39 = trunc i64 %38 to i1
  br i1 %39, label %panic.i747, label %__barray_mask_borrow.exit748

mask_block_err.i:                                 ; preds = %cond_exit_180.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i745:                                       ; preds = %__barray_check_bounds.exit744.2, %cond_exit_180, %__barray_mask_return.exit738
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_mask_return.exit738
  %40 = or disjoint i64 %36, 1
  store i64 %40, ptr %3, align 4
  %41 = load i64, ptr %2, align 4
  %___lazy_measure = tail call i64 @___lazy_measure(i64 %41)
  tail call void @___qfree(i64 %41)
  %42 = load i64, ptr %1, align 4
  %43 = trunc i64 %42 to i1
  br i1 %43, label %cond_exit_180, label %panic.i741

cond_exit_180:                                    ; preds = %.thread
  %44 = and i64 %42, -2
  store i64 %44, ptr %1, align 4
  store i64 %___lazy_measure, ptr %0, align 4
  %45 = load i64, ptr %3, align 4
  %46 = and i64 %45, 2
  %.not791 = icmp eq i64 %46, 0
  br i1 %.not791, label %.thread.1, label %panic.i745

.thread.1:                                        ; preds = %cond_exit_180
  %47 = or disjoint i64 %45, 2
  store i64 %47, ptr %3, align 4
  %48 = load i64, ptr %10, align 4
  %___lazy_measure.1 = tail call i64 @___lazy_measure(i64 %48)
  tail call void @___qfree(i64 %48)
  %49 = load i64, ptr %1, align 4
  %50 = and i64 %49, 2
  %.not792 = icmp eq i64 %50, 0
  br i1 %.not792, label %panic.i741, label %__barray_check_bounds.exit744.2

__barray_check_bounds.exit744.2:                  ; preds = %.thread.1
  %51 = and i64 %49, -3
  store i64 %51, ptr %1, align 4
  %52 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %___lazy_measure.1, ptr %52, align 4
  %53 = load i64, ptr %3, align 4
  %54 = and i64 %53, 4
  %.not793 = icmp eq i64 %54, 0
  br i1 %.not793, label %__barray_check_bounds.exit740.2, label %panic.i745

__barray_check_bounds.exit740.2:                  ; preds = %__barray_check_bounds.exit744.2
  %55 = or disjoint i64 %53, 4
  store i64 %55, ptr %3, align 4
  %56 = load i64, ptr %14, align 4
  %___lazy_measure.2 = tail call i64 @___lazy_measure(i64 %56)
  tail call void @___qfree(i64 %56)
  %57 = load i64, ptr %1, align 4
  %58 = and i64 %57, 4
  %.not794 = icmp eq i64 %58, 0
  br i1 %.not794, label %panic.i741, label %cond_exit_180.2

cond_exit_180.2:                                  ; preds = %__barray_check_bounds.exit740.2
  %59 = and i64 %57, -5
  store i64 %59, ptr %1, align 4
  %60 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %___lazy_measure.2, ptr %60, align 4
  %61 = load i64, ptr %3, align 4
  %62 = or i64 %61, -8
  store i64 %62, ptr %3, align 4
  %63 = icmp eq i64 %62, -1
  br i1 %63, label %loop_out191, label %mask_block_err.i

panic.i747:                                       ; preds = %loop_out191
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit748:                     ; preds = %loop_out191
  %64 = or disjoint i64 %38, 1
  store i64 %64, ptr %1, align 4
  %65 = load i64, ptr %0, align 4
  tail call void @___inc_future_refcount(i64 %65)
  %66 = load i64, ptr %1, align 4
  %67 = trunc i64 %66 to i1
  br i1 %67, label %__barray_mask_return.exit750, label %panic.i749

panic.i749:                                       ; preds = %__barray_mask_borrow.exit748
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit750:                     ; preds = %__barray_mask_borrow.exit748
  %68 = and i64 %66, -2
  store i64 %68, ptr %1, align 4
  store i64 %65, ptr %0, align 4
  %69 = load i64, ptr %1, align 4
  %70 = and i64 %69, 2
  %.not782 = icmp eq i64 %70, 0
  br i1 %.not782, label %__barray_mask_borrow.exit752, label %panic.i751

panic.i751:                                       ; preds = %__barray_mask_return.exit750
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit752:                     ; preds = %__barray_mask_return.exit750
  %71 = or disjoint i64 %69, 2
  store i64 %71, ptr %1, align 4
  %72 = load i64, ptr %52, align 4
  tail call void @___inc_future_refcount(i64 %72)
  %73 = load i64, ptr %1, align 4
  %74 = and i64 %73, 2
  %.not783 = icmp eq i64 %74, 0
  br i1 %.not783, label %panic.i753, label %__barray_mask_return.exit754

panic.i753:                                       ; preds = %__barray_mask_borrow.exit752
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit754:                     ; preds = %__barray_mask_borrow.exit752
  %75 = and i64 %73, -3
  store i64 %75, ptr %1, align 4
  store i64 %72, ptr %52, align 4
  %76 = load i64, ptr %1, align 4
  %77 = and i64 %76, 4
  %.not784 = icmp eq i64 %77, 0
  br i1 %.not784, label %__barray_mask_borrow.exit756, label %panic.i755

panic.i755:                                       ; preds = %__barray_mask_return.exit754
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit756:                     ; preds = %__barray_mask_return.exit754
  %78 = or disjoint i64 %76, 4
  store i64 %78, ptr %1, align 4
  %79 = load i64, ptr %60, align 4
  tail call void @___inc_future_refcount(i64 %79)
  %80 = load i64, ptr %1, align 4
  %81 = and i64 %80, 4
  %.not785 = icmp eq i64 %81, 0
  br i1 %.not785, label %panic.i757, label %__barray_mask_return.exit758

panic.i757:                                       ; preds = %__barray_mask_borrow.exit756
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit758:                     ; preds = %__barray_mask_borrow.exit756
  %82 = and i64 %80, -5
  store i64 %82, ptr %1, align 4
  store i64 %79, ptr %60, align 4
  %83 = load i64, ptr %1, align 4
  %84 = trunc i64 %83 to i1
  br i1 %84, label %cond_exit_426, label %__barray_mask_borrow.exit770

mask_block_err.i762:                              ; preds = %cond_exit_426.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit770:                     ; preds = %__barray_mask_return.exit758
  %85 = or disjoint i64 %83, 1
  store i64 %85, ptr %1, align 4
  %86 = load i64, ptr %0, align 4
  tail call void @___dec_future_refcount(i64 %86)
  br label %cond_exit_426

cond_exit_426:                                    ; preds = %__barray_mask_borrow.exit770, %__barray_mask_return.exit758
  %87 = load i64, ptr %1, align 4
  %88 = and i64 %87, 2
  %.not797 = icmp eq i64 %88, 0
  br i1 %.not797, label %__barray_mask_borrow.exit770.1, label %cond_exit_426.1

__barray_mask_borrow.exit770.1:                   ; preds = %cond_exit_426
  %89 = or disjoint i64 %87, 2
  store i64 %89, ptr %1, align 4
  %90 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %91 = load i64, ptr %90, align 4
  tail call void @___dec_future_refcount(i64 %91)
  br label %cond_exit_426.1

cond_exit_426.1:                                  ; preds = %__barray_mask_borrow.exit770.1, %cond_exit_426
  %92 = load i64, ptr %1, align 4
  %93 = and i64 %92, 4
  %.not798 = icmp eq i64 %93, 0
  br i1 %.not798, label %__barray_mask_borrow.exit770.2, label %cond_exit_426.2

__barray_mask_borrow.exit770.2:                   ; preds = %cond_exit_426.1
  %94 = or disjoint i64 %92, 4
  store i64 %94, ptr %1, align 4
  %95 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %96 = load i64, ptr %95, align 4
  tail call void @___dec_future_refcount(i64 %96)
  br label %cond_exit_426.2

cond_exit_426.2:                                  ; preds = %__barray_mask_borrow.exit770.2, %cond_exit_426.1
  %97 = load i64, ptr %1, align 4
  %98 = or i64 %97, -8
  store i64 %98, ptr %1, align 4
  %99 = icmp eq i64 %98, -1
  br i1 %99, label %loop_out415, label %mask_block_err.i762

loop_out415:                                      ; preds = %cond_exit_426.2
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %read_bool = tail call i1 @___read_future_bool(i64 %65)
  tail call void @___dec_future_refcount(i64 %65)
  tail call void @print_bool(ptr nonnull @res_c0.7C14CD6E.0, i64 12, i1 %read_bool)
  %read_bool484 = tail call i1 @___read_future_bool(i64 %72)
  tail call void @___dec_future_refcount(i64 %72)
  tail call void @print_bool(ptr nonnull @res_c1.1F7A6571.0, i64 12, i1 %read_bool484)
  %read_bool499 = tail call i1 @___read_future_bool(i64 %79)
  tail call void @___dec_future_refcount(i64 %79)
  tail call void @print_bool(ptr nonnull @res_c2.60825383.0, i64 12, i1 %read_bool499)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @heap_free(ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

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
