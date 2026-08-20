; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_cs.46C3C4B5.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:cs"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 3)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %2 = tail call ptr @heap_alloc(i64 24)
  %3 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %3, align 1
  %4 = tail call ptr @heap_alloc(i64 24)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_359_case_0.i, label %__hugr__.__tk2_helios_qalloc.355.exit

cond_359_case_0.i:                                ; preds = %cond_exit_12.1, %cond_exit_12, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.355.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %6 = load i64, ptr %5, align 4
  %7 = trunc i64 %6 to i1
  br i1 %7, label %cond_exit_12, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.2, %__hugr__.__tk2_helios_qalloc.355.exit.1, %__hugr__.__tk2_helios_qalloc.355.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_12:                                     ; preds = %__hugr__.__tk2_helios_qalloc.355.exit
  %8 = and i64 %6, -2
  store i64 %8, ptr %5, align 4
  store i64 %qalloc.i, ptr %4, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_359_case_0.i, label %__hugr__.__tk2_helios_qalloc.355.exit.1

__hugr__.__tk2_helios_qalloc.355.exit.1:          ; preds = %cond_exit_12
  tail call void @___reset(i64 %qalloc.i.1)
  %9 = load i64, ptr %5, align 4
  %10 = and i64 %9, 2
  %.not902 = icmp eq i64 %10, 0
  br i1 %.not902, label %panic.i, label %cond_exit_12.1

cond_exit_12.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.355.exit.1
  %11 = and i64 %9, -3
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %qalloc.i.1, ptr %12, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_359_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_12.1
  tail call void @___reset(i64 %qalloc.i.2)
  %13 = load i64, ptr %5, align 4
  %14 = and i64 %13, 4
  %.not903 = icmp eq i64 %14, 0
  br i1 %.not903, label %panic.i, label %cond_exit_12.2

cond_exit_12.2:                                   ; preds = %__barray_check_bounds.exit.2
  %15 = and i64 %13, -5
  store i64 %15, ptr %5, align 4
  %16 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %qalloc.i.2, ptr %16, align 4
  %17 = load i64, ptr %5, align 4
  %18 = trunc i64 %17 to i1
  br i1 %18, label %panic.i833, label %__barray_mask_borrow.exit

panic.i833:                                       ; preds = %cond_exit_12.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_12.2
  %19 = or disjoint i64 %17, 1
  store i64 %19, ptr %5, align 4
  %20 = load i64, ptr %4, align 4
  tail call void @___rxy(i64 %20, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %20, double 0x400921FB54442D18)
  %21 = load i64, ptr %5, align 4
  %22 = and i64 %21, 2
  %.not = icmp eq i64 %22, 0
  br i1 %.not, label %__barray_mask_borrow.exit835, label %panic.i834

panic.i834:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit835:                     ; preds = %__barray_mask_borrow.exit
  %23 = or disjoint i64 %21, 2
  store i64 %23, ptr %5, align 4
  %24 = load i64, ptr %12, align 4
  %25 = and i64 %21, 4
  %.not896 = icmp eq i64 %25, 0
  br i1 %.not896, label %__barray_mask_borrow.exit837, label %panic.i836

panic.i836:                                       ; preds = %__barray_mask_borrow.exit835
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit837:                     ; preds = %__barray_mask_borrow.exit835
  %26 = or disjoint i64 %21, 6
  store i64 %26, ptr %5, align 4
  %27 = load i64, ptr %16, align 4
  tail call void @___rxy(i64 %27, double 0x400921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rzz(i64 %24, i64 %27, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %27, double 0x3FE921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %20, i64 %27, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %27, double 0x3FE921FB54442D18, double 0.000000e+00)
  tail call void @___rzz(i64 %24, i64 %27, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %27, double 0x3FE921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rzz(i64 %20, i64 %27, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %27, double 0xC002D97C7F3321D2, double 0x400921FB54442D18)
  tail call void @___rz(i64 %27, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %20, double 0x400921FB54442D18, double 0x3FE921FB54442D18)
  tail call void @___rzz(i64 %20, i64 %24, double 0x3FE921FB54442D18)
  tail call void @___rz(i64 %24, double 0xC002D97C7F3321D2)
  tail call void @___rxy(i64 %20, double 0x400921FB54442D18, double 0xBFE921FB54442D18)
  tail call void @___rz(i64 %20, double 0x3FE921FB54442D18)
  %28 = load i64, ptr %5, align 4
  %29 = trunc i64 %28 to i1
  br i1 %29, label %__barray_mask_return.exit839, label %panic.i838

panic.i838:                                       ; preds = %__barray_mask_borrow.exit837
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit839:                     ; preds = %__barray_mask_borrow.exit837
  %30 = and i64 %28, -2
  store i64 %30, ptr %5, align 4
  store i64 %20, ptr %4, align 4
  %31 = load i64, ptr %5, align 4
  %32 = and i64 %31, 2
  %.not897 = icmp eq i64 %32, 0
  br i1 %.not897, label %panic.i840, label %__barray_mask_return.exit841

panic.i840:                                       ; preds = %__barray_mask_return.exit839
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit841:                     ; preds = %__barray_mask_return.exit839
  %33 = and i64 %31, -3
  store i64 %33, ptr %5, align 4
  store i64 %24, ptr %12, align 4
  %34 = load i64, ptr %5, align 4
  %35 = and i64 %34, 4
  %.not898 = icmp eq i64 %35, 0
  br i1 %.not898, label %panic.i842, label %__barray_mask_return.exit843

panic.i842:                                       ; preds = %__barray_mask_return.exit841
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit843:                     ; preds = %__barray_mask_return.exit841
  %36 = and i64 %34, -5
  store i64 %36, ptr %5, align 4
  store i64 %27, ptr %16, align 4
  %37 = load i64, ptr %5, align 4
  %38 = trunc i64 %37 to i1
  br i1 %38, label %panic.i850, label %.thread

panic.i846:                                       ; preds = %.thread.2, %.thread.1, %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_err.i:                                 ; preds = %cond_exit_137.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i850:                                       ; preds = %cond_exit_137.1, %cond_exit_137, %__barray_mask_return.exit843
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_mask_return.exit843
  %39 = or disjoint i64 %37, 1
  store i64 %39, ptr %5, align 4
  %40 = load i64, ptr %4, align 4
  %lazy_measure = tail call i64 @___lazy_measure(i64 %40)
  tail call void @___qfree(i64 %40)
  %41 = load i64, ptr %3, align 4
  %42 = trunc i64 %41 to i1
  br i1 %42, label %cond_exit_137, label %panic.i846

cond_exit_137:                                    ; preds = %.thread
  %43 = and i64 %41, -2
  store i64 %43, ptr %3, align 4
  store i64 %lazy_measure, ptr %2, align 4
  %44 = load i64, ptr %5, align 4
  %45 = and i64 %44, 2
  %.not916 = icmp eq i64 %45, 0
  br i1 %.not916, label %.thread.1, label %panic.i850

.thread.1:                                        ; preds = %cond_exit_137
  %46 = or disjoint i64 %44, 2
  store i64 %46, ptr %5, align 4
  %47 = getelementptr inbounds nuw i8, ptr %4, i64 8
  %48 = load i64, ptr %47, align 4
  %lazy_measure.1 = tail call i64 @___lazy_measure(i64 %48)
  tail call void @___qfree(i64 %48)
  %49 = load i64, ptr %3, align 4
  %50 = and i64 %49, 2
  %.not917 = icmp eq i64 %50, 0
  br i1 %.not917, label %panic.i846, label %cond_exit_137.1

cond_exit_137.1:                                  ; preds = %.thread.1
  %51 = and i64 %49, -3
  store i64 %51, ptr %3, align 4
  %52 = getelementptr inbounds nuw i8, ptr %2, i64 8
  store i64 %lazy_measure.1, ptr %52, align 4
  %53 = load i64, ptr %5, align 4
  %54 = and i64 %53, 4
  %.not918 = icmp eq i64 %54, 0
  br i1 %.not918, label %.thread.2, label %panic.i850

.thread.2:                                        ; preds = %cond_exit_137.1
  %55 = or disjoint i64 %53, 4
  store i64 %55, ptr %5, align 4
  %56 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %57 = load i64, ptr %56, align 4
  %lazy_measure.2 = tail call i64 @___lazy_measure(i64 %57)
  tail call void @___qfree(i64 %57)
  %58 = load i64, ptr %3, align 4
  %59 = and i64 %58, 4
  %.not919 = icmp eq i64 %59, 0
  br i1 %.not919, label %panic.i846, label %cond_exit_137.2

cond_exit_137.2:                                  ; preds = %.thread.2
  %60 = and i64 %58, -5
  store i64 %60, ptr %3, align 4
  %61 = getelementptr inbounds nuw i8, ptr %2, i64 16
  store i64 %lazy_measure.2, ptr %61, align 4
  %62 = load i64, ptr %5, align 4
  %63 = or i64 %62, -8
  store i64 %63, ptr %5, align 4
  %64 = icmp eq i64 %63, -1
  br i1 %64, label %loop_body296.preheader.preheader, label %mask_block_err.i

loop_body296.preheader.preheader:                 ; preds = %cond_exit_137.2
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  %65 = load i64, ptr %3, align 4
  %66 = trunc i64 %65 to i1
  br i1 %66, label %panic.i854, label %__barray_check_bounds.exit857

panic.i854:                                       ; preds = %__barray_check_bounds.exit853.2, %cond_exit_203, %loop_body296.preheader.preheader
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit857:                    ; preds = %loop_body296.preheader.preheader
  %67 = or disjoint i64 %65, 1
  store i64 %67, ptr %3, align 4
  %68 = load i64, ptr %2, align 4
  tail call void @___inc_future_refcount(i64 %68)
  %69 = load i64, ptr %3, align 4
  %70 = trunc i64 %69 to i1
  br i1 %70, label %cond_244_case_1.thread, label %panic.i858

panic.i858:                                       ; preds = %__barray_check_bounds.exit857.2, %__barray_check_bounds.exit857.1, %__barray_check_bounds.exit857
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

panic.i862:                                       ; preds = %__barray_check_bounds.exit861.2, %cond_244_case_1.thread.1, %cond_244_case_1.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_244_case_1.thread:                           ; preds = %__barray_check_bounds.exit857
  %71 = and i64 %69, -2
  store i64 %71, ptr %3, align 4
  store i64 %68, ptr %2, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %68)
  tail call void @___dec_future_refcount(i64 %68)
  %72 = load i64, ptr %1, align 4
  %73 = trunc i64 %72 to i1
  br i1 %73, label %cond_exit_203, label %panic.i862

mask_block_err.i867:                              ; preds = %cond_exit_405.2
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit875:                     ; preds = %cond_exit_203.2
  %74 = or disjoint i64 %114, 1
  store i64 %74, ptr %3, align 4
  %75 = load i64, ptr %2, align 4
  tail call void @___dec_future_refcount(i64 %75)
  br label %cond_exit_405

cond_exit_405:                                    ; preds = %__barray_mask_borrow.exit875, %cond_exit_203.2
  %76 = load i64, ptr %3, align 4
  %77 = and i64 %76, 2
  %.not920 = icmp eq i64 %77, 0
  br i1 %.not920, label %__barray_mask_borrow.exit875.1, label %cond_exit_405.1

__barray_mask_borrow.exit875.1:                   ; preds = %cond_exit_405
  %78 = or disjoint i64 %76, 2
  store i64 %78, ptr %3, align 4
  %79 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %80 = load i64, ptr %79, align 4
  tail call void @___dec_future_refcount(i64 %80)
  br label %cond_exit_405.1

cond_exit_405.1:                                  ; preds = %__barray_mask_borrow.exit875.1, %cond_exit_405
  %81 = load i64, ptr %3, align 4
  %82 = and i64 %81, 4
  %.not921 = icmp eq i64 %82, 0
  br i1 %.not921, label %__barray_mask_borrow.exit875.2, label %cond_exit_405.2

__barray_mask_borrow.exit875.2:                   ; preds = %cond_exit_405.1
  %83 = or disjoint i64 %81, 4
  store i64 %83, ptr %3, align 4
  %84 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %85 = load i64, ptr %84, align 4
  tail call void @___dec_future_refcount(i64 %85)
  br label %cond_exit_405.2

cond_exit_405.2:                                  ; preds = %__barray_mask_borrow.exit875.2, %cond_exit_405.1
  %86 = load i64, ptr %3, align 4
  %87 = or i64 %86, -8
  store i64 %87, ptr %3, align 4
  %88 = icmp eq i64 %87, -1
  br i1 %88, label %loop_out295, label %mask_block_err.i867

cond_exit_203:                                    ; preds = %cond_244_case_1.thread
  %89 = and i64 %72, -2
  store i64 %89, ptr %1, align 4
  store i1 %read_bool, ptr %0, align 1
  %90 = load i64, ptr %3, align 4
  %91 = and i64 %90, 2
  %.not904 = icmp eq i64 %91, 0
  br i1 %.not904, label %__barray_check_bounds.exit857.1, label %panic.i854

__barray_check_bounds.exit857.1:                  ; preds = %cond_exit_203
  %92 = or disjoint i64 %90, 2
  store i64 %92, ptr %3, align 4
  %93 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %94 = load i64, ptr %93, align 4
  tail call void @___inc_future_refcount(i64 %94)
  %95 = load i64, ptr %3, align 4
  %96 = and i64 %95, 2
  %.not905 = icmp eq i64 %96, 0
  br i1 %.not905, label %panic.i858, label %cond_244_case_1.thread.1

cond_244_case_1.thread.1:                         ; preds = %__barray_check_bounds.exit857.1
  %97 = and i64 %95, -3
  store i64 %97, ptr %3, align 4
  store i64 %94, ptr %93, align 4
  %read_bool.1 = tail call i1 @___read_future_bool(i64 %94)
  tail call void @___dec_future_refcount(i64 %94)
  %98 = load i64, ptr %1, align 4
  %99 = and i64 %98, 2
  %.not906 = icmp eq i64 %99, 0
  br i1 %.not906, label %panic.i862, label %__barray_check_bounds.exit853.2

__barray_check_bounds.exit853.2:                  ; preds = %cond_244_case_1.thread.1
  %100 = and i64 %98, -3
  store i64 %100, ptr %1, align 4
  %101 = getelementptr inbounds nuw i8, ptr %0, i64 1
  store i1 %read_bool.1, ptr %101, align 1
  %102 = load i64, ptr %3, align 4
  %103 = and i64 %102, 4
  %.not907 = icmp eq i64 %103, 0
  br i1 %.not907, label %__barray_check_bounds.exit857.2, label %panic.i854

__barray_check_bounds.exit857.2:                  ; preds = %__barray_check_bounds.exit853.2
  %104 = or disjoint i64 %102, 4
  store i64 %104, ptr %3, align 4
  %105 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %106 = load i64, ptr %105, align 4
  tail call void @___inc_future_refcount(i64 %106)
  %107 = load i64, ptr %3, align 4
  %108 = and i64 %107, 4
  %.not908 = icmp eq i64 %108, 0
  br i1 %.not908, label %panic.i858, label %__barray_check_bounds.exit861.2

__barray_check_bounds.exit861.2:                  ; preds = %__barray_check_bounds.exit857.2
  %109 = and i64 %107, -5
  store i64 %109, ptr %3, align 4
  store i64 %106, ptr %105, align 4
  %read_bool.2 = tail call i1 @___read_future_bool(i64 %106)
  tail call void @___dec_future_refcount(i64 %106)
  %110 = load i64, ptr %1, align 4
  %111 = and i64 %110, 4
  %.not909 = icmp eq i64 %111, 0
  br i1 %.not909, label %panic.i862, label %cond_exit_203.2

cond_exit_203.2:                                  ; preds = %__barray_check_bounds.exit861.2
  %112 = and i64 %110, -5
  store i64 %112, ptr %1, align 4
  %113 = getelementptr inbounds nuw i8, ptr %0, i64 2
  store i1 %read_bool.2, ptr %113, align 1
  %114 = load i64, ptr %3, align 4
  %115 = trunc i64 %114 to i1
  br i1 %115, label %cond_exit_405, label %__barray_mask_borrow.exit875

loop_out295:                                      ; preds = %cond_exit_405.2
  tail call void @heap_free(ptr nonnull %2)
  tail call void @heap_free(ptr nonnull %3)
  %116 = load i64, ptr %1, align 4
  %117 = and i64 %116, 7
  store i64 %117, ptr %1, align 4
  %118 = icmp eq i64 %117, 0
  br i1 %118, label %__barray_check_none_borrowed.exit, label %mask_block_err.i876

mask_block_err.i876:                              ; preds = %loop_out295
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out295
  %119 = tail call ptr @heap_alloc(i64 3)
  %120 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %120, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(3) %119, ptr noundef nonnull align 1 dereferenceable(3) %0, i64 3, i1 false)
  tail call void @heap_free(ptr nonnull %119)
  %121 = load i64, ptr %1, align 4
  %122 = and i64 %121, 7
  store i64 %122, ptr %1, align 4
  %123 = icmp eq i64 %122, 0
  br i1 %123, label %__barray_check_none_borrowed.exit880, label %mask_block_err.i878

mask_block_err.i878:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit880:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %124 = alloca [3 x i1], align 1
  store i1 false, ptr %124, align 1
  %.repack831 = getelementptr inbounds nuw i8, ptr %124, i64 1
  store i1 false, ptr %.repack831, align 1
  %.repack832 = getelementptr inbounds nuw i8, ptr %124, i64 2
  store i1 false, ptr %.repack832, align 1
  store i32 3, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %124, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
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

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

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
