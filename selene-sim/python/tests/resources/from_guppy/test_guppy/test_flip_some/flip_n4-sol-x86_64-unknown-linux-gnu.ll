; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_cs.46C3C4B5.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:cs"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 4)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %2 = tail call ptr @heap_alloc(i64 32)
  %3 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %3, align 1
  %4 = tail call ptr @heap_alloc(i64 32)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_310_case_0.i, label %__hugr__.__tk2_sol_qalloc.305.exit

cond_310_case_0.i:                                ; preds = %cond_exit_12.2, %cond_exit_12.1, %cond_exit_12, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.305.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %6 = load i64, ptr %5, align 4
  %7 = trunc i64 %6 to i1
  br i1 %7, label %cond_exit_12, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.3, %__hugr__.__tk2_sol_qalloc.305.exit.2, %__hugr__.__tk2_sol_qalloc.305.exit.1, %__hugr__.__tk2_sol_qalloc.305.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_12:                                     ; preds = %__hugr__.__tk2_sol_qalloc.305.exit
  %8 = and i64 %6, -2
  store i64 %8, ptr %5, align 4
  store i64 %qalloc.i, ptr %4, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_310_case_0.i, label %__hugr__.__tk2_sol_qalloc.305.exit.1

__hugr__.__tk2_sol_qalloc.305.exit.1:             ; preds = %cond_exit_12
  tail call void @___reset(i64 %qalloc.i.1)
  %9 = load i64, ptr %5, align 4
  %10 = and i64 %9, 2
  %.not902 = icmp eq i64 %10, 0
  br i1 %.not902, label %panic.i, label %cond_exit_12.1

cond_exit_12.1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.305.exit.1
  %11 = and i64 %9, -3
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %qalloc.i.1, ptr %12, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_310_case_0.i, label %__hugr__.__tk2_sol_qalloc.305.exit.2

__hugr__.__tk2_sol_qalloc.305.exit.2:             ; preds = %cond_exit_12.1
  tail call void @___reset(i64 %qalloc.i.2)
  %13 = load i64, ptr %5, align 4
  %14 = and i64 %13, 4
  %.not903 = icmp eq i64 %14, 0
  br i1 %.not903, label %panic.i, label %cond_exit_12.2

cond_exit_12.2:                                   ; preds = %__hugr__.__tk2_sol_qalloc.305.exit.2
  %15 = and i64 %13, -5
  store i64 %15, ptr %5, align 4
  %16 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %qalloc.i.2, ptr %16, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_310_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_12.2
  tail call void @___reset(i64 %qalloc.i.3)
  %17 = load i64, ptr %5, align 4
  %18 = and i64 %17, 8
  %.not904 = icmp eq i64 %18, 0
  br i1 %.not904, label %panic.i, label %cond_exit_12.3

cond_exit_12.3:                                   ; preds = %__barray_check_bounds.exit.3
  %19 = and i64 %17, -9
  store i64 %19, ptr %5, align 4
  %20 = getelementptr inbounds nuw i8, ptr %4, i64 24
  store i64 %qalloc.i.3, ptr %20, align 4
  %21 = load i64, ptr %5, align 4
  %22 = trunc i64 %21 to i1
  br i1 %22, label %panic.i833, label %__barray_mask_borrow.exit

panic.i833:                                       ; preds = %cond_exit_12.3
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_12.3
  %23 = or disjoint i64 %21, 1
  store i64 %23, ptr %5, align 4
  %24 = load i64, ptr %4, align 4
  tail call void @___rp(i64 %24, double 0x400921FB54442D18, double 0.000000e+00)
  %25 = load i64, ptr %5, align 4
  %26 = trunc i64 %25 to i1
  br i1 %26, label %__barray_mask_return.exit835, label %panic.i834

panic.i834:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit835:                     ; preds = %__barray_mask_borrow.exit
  %27 = and i64 %25, -2
  store i64 %27, ptr %5, align 4
  store i64 %24, ptr %4, align 4
  %28 = load i64, ptr %5, align 4
  %29 = and i64 %28, 4
  %.not = icmp eq i64 %29, 0
  br i1 %.not, label %__barray_mask_borrow.exit837, label %panic.i836

panic.i836:                                       ; preds = %__barray_mask_return.exit835
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit837:                     ; preds = %__barray_mask_return.exit835
  %30 = or disjoint i64 %28, 4
  store i64 %30, ptr %5, align 4
  %31 = load i64, ptr %16, align 4
  tail call void @___rp(i64 %31, double 0x400921FB54442D18, double 0.000000e+00)
  %32 = load i64, ptr %5, align 4
  %33 = and i64 %32, 4
  %.not896 = icmp eq i64 %33, 0
  br i1 %.not896, label %panic.i838, label %__barray_mask_return.exit839

panic.i838:                                       ; preds = %__barray_mask_borrow.exit837
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit839:                     ; preds = %__barray_mask_borrow.exit837
  %34 = and i64 %32, -5
  store i64 %34, ptr %5, align 4
  store i64 %31, ptr %16, align 4
  %35 = load i64, ptr %5, align 4
  %36 = and i64 %35, 8
  %.not897 = icmp eq i64 %36, 0
  br i1 %.not897, label %__barray_mask_borrow.exit841, label %panic.i840

panic.i840:                                       ; preds = %__barray_mask_return.exit839
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit841:                     ; preds = %__barray_mask_return.exit839
  %37 = or disjoint i64 %35, 8
  store i64 %37, ptr %5, align 4
  %38 = load i64, ptr %20, align 4
  tail call void @___rp(i64 %38, double 0x400921FB54442D18, double 0.000000e+00)
  %39 = load i64, ptr %5, align 4
  %40 = and i64 %39, 8
  %.not898 = icmp eq i64 %40, 0
  br i1 %.not898, label %panic.i842, label %__barray_mask_return.exit843

panic.i842:                                       ; preds = %__barray_mask_borrow.exit841
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit843:                     ; preds = %__barray_mask_borrow.exit841
  %41 = and i64 %39, -9
  store i64 %41, ptr %5, align 4
  store i64 %38, ptr %20, align 4
  %42 = load i64, ptr %5, align 4
  %43 = trunc i64 %42 to i1
  br i1 %43, label %panic.i850, label %.thread

panic.i846:                                       ; preds = %.thread.3, %.thread.2, %.thread.1, %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_err.i:                                 ; preds = %cond_exit_142.3
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i850:                                       ; preds = %cond_exit_142.2, %cond_exit_142.1, %cond_exit_142, %__barray_mask_return.exit843
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_mask_return.exit843
  %44 = or disjoint i64 %42, 1
  store i64 %44, ptr %5, align 4
  %45 = load i64, ptr %4, align 4
  %___future_measure = tail call i64 @___future_measure(i64 %45, i64 0)
  tail call void @___qfree(i64 %45)
  %46 = load i64, ptr %3, align 4
  %47 = trunc i64 %46 to i1
  br i1 %47, label %cond_exit_142, label %panic.i846

cond_exit_142:                                    ; preds = %.thread
  %48 = and i64 %46, -2
  store i64 %48, ptr %3, align 4
  store i64 %___future_measure, ptr %2, align 4
  %49 = load i64, ptr %5, align 4
  %50 = and i64 %49, 2
  %.not920 = icmp eq i64 %50, 0
  br i1 %.not920, label %.thread.1, label %panic.i850

.thread.1:                                        ; preds = %cond_exit_142
  %51 = or disjoint i64 %49, 2
  store i64 %51, ptr %5, align 4
  %52 = getelementptr inbounds nuw i8, ptr %4, i64 8
  %53 = load i64, ptr %52, align 4
  %___future_measure.1 = tail call i64 @___future_measure(i64 %53, i64 0)
  tail call void @___qfree(i64 %53)
  %54 = load i64, ptr %3, align 4
  %55 = and i64 %54, 2
  %.not921 = icmp eq i64 %55, 0
  br i1 %.not921, label %panic.i846, label %cond_exit_142.1

cond_exit_142.1:                                  ; preds = %.thread.1
  %56 = and i64 %54, -3
  store i64 %56, ptr %3, align 4
  %57 = getelementptr inbounds nuw i8, ptr %2, i64 8
  store i64 %___future_measure.1, ptr %57, align 4
  %58 = load i64, ptr %5, align 4
  %59 = and i64 %58, 4
  %.not922 = icmp eq i64 %59, 0
  br i1 %.not922, label %.thread.2, label %panic.i850

.thread.2:                                        ; preds = %cond_exit_142.1
  %60 = or disjoint i64 %58, 4
  store i64 %60, ptr %5, align 4
  %61 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %62 = load i64, ptr %61, align 4
  %___future_measure.2 = tail call i64 @___future_measure(i64 %62, i64 0)
  tail call void @___qfree(i64 %62)
  %63 = load i64, ptr %3, align 4
  %64 = and i64 %63, 4
  %.not923 = icmp eq i64 %64, 0
  br i1 %.not923, label %panic.i846, label %cond_exit_142.2

cond_exit_142.2:                                  ; preds = %.thread.2
  %65 = and i64 %63, -5
  store i64 %65, ptr %3, align 4
  %66 = getelementptr inbounds nuw i8, ptr %2, i64 16
  store i64 %___future_measure.2, ptr %66, align 4
  %67 = load i64, ptr %5, align 4
  %68 = and i64 %67, 8
  %.not924 = icmp eq i64 %68, 0
  br i1 %.not924, label %.thread.3, label %panic.i850

.thread.3:                                        ; preds = %cond_exit_142.2
  %69 = or disjoint i64 %67, 8
  store i64 %69, ptr %5, align 4
  %70 = getelementptr inbounds nuw i8, ptr %4, i64 24
  %71 = load i64, ptr %70, align 4
  %___future_measure.3 = tail call i64 @___future_measure(i64 %71, i64 0)
  tail call void @___qfree(i64 %71)
  %72 = load i64, ptr %3, align 4
  %73 = and i64 %72, 8
  %.not925 = icmp eq i64 %73, 0
  br i1 %.not925, label %panic.i846, label %cond_exit_142.3

cond_exit_142.3:                                  ; preds = %.thread.3
  %74 = and i64 %72, -9
  store i64 %74, ptr %3, align 4
  %75 = getelementptr inbounds nuw i8, ptr %2, i64 24
  store i64 %___future_measure.3, ptr %75, align 4
  %76 = load i64, ptr %5, align 4
  %77 = or i64 %76, -16
  store i64 %77, ptr %5, align 4
  %78 = icmp eq i64 %77, -1
  br i1 %78, label %loop_body295.preheader.preheader, label %mask_block_err.i

loop_body295.preheader.preheader:                 ; preds = %cond_exit_142.3
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  %79 = load i64, ptr %3, align 4
  %80 = trunc i64 %79 to i1
  br i1 %80, label %panic.i854, label %__barray_check_bounds.exit857

panic.i854:                                       ; preds = %__barray_check_bounds.exit853.3, %cond_exit_208.1, %cond_exit_208, %loop_body295.preheader.preheader
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit857:                    ; preds = %loop_body295.preheader.preheader
  %81 = or disjoint i64 %79, 1
  store i64 %81, ptr %3, align 4
  %82 = load i64, ptr %2, align 4
  tail call void @___inc_future_refcount(i64 %82)
  %83 = load i64, ptr %3, align 4
  %84 = trunc i64 %83 to i1
  br i1 %84, label %cond_249_case_1.thread, label %panic.i858

panic.i858:                                       ; preds = %__barray_check_bounds.exit857.3, %__barray_check_bounds.exit857.2, %__barray_check_bounds.exit857.1, %__barray_check_bounds.exit857
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

panic.i862:                                       ; preds = %__barray_check_bounds.exit861.3, %cond_249_case_1.thread.2, %cond_249_case_1.thread.1, %cond_249_case_1.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_249_case_1.thread:                           ; preds = %__barray_check_bounds.exit857
  %85 = and i64 %83, -2
  store i64 %85, ptr %3, align 4
  store i64 %82, ptr %2, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %82)
  tail call void @___dec_future_refcount(i64 %82)
  %86 = load i64, ptr %1, align 4
  %87 = trunc i64 %86 to i1
  br i1 %87, label %cond_exit_208, label %panic.i862

mask_block_err.i867:                              ; preds = %cond_exit_356.3
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit875:                     ; preds = %cond_exit_208.3
  %88 = or disjoint i64 %145, 1
  store i64 %88, ptr %3, align 4
  %89 = load i64, ptr %2, align 4
  tail call void @___dec_future_refcount(i64 %89)
  br label %cond_exit_356

cond_exit_356:                                    ; preds = %__barray_mask_borrow.exit875, %cond_exit_208.3
  %90 = load i64, ptr %3, align 4
  %91 = and i64 %90, 2
  %.not926 = icmp eq i64 %91, 0
  br i1 %.not926, label %__barray_mask_borrow.exit875.1, label %cond_exit_356.1

__barray_mask_borrow.exit875.1:                   ; preds = %cond_exit_356
  %92 = or disjoint i64 %90, 2
  store i64 %92, ptr %3, align 4
  %93 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %94 = load i64, ptr %93, align 4
  tail call void @___dec_future_refcount(i64 %94)
  br label %cond_exit_356.1

cond_exit_356.1:                                  ; preds = %__barray_mask_borrow.exit875.1, %cond_exit_356
  %95 = load i64, ptr %3, align 4
  %96 = and i64 %95, 4
  %.not927 = icmp eq i64 %96, 0
  br i1 %.not927, label %__barray_mask_borrow.exit875.2, label %cond_exit_356.2

__barray_mask_borrow.exit875.2:                   ; preds = %cond_exit_356.1
  %97 = or disjoint i64 %95, 4
  store i64 %97, ptr %3, align 4
  %98 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %99 = load i64, ptr %98, align 4
  tail call void @___dec_future_refcount(i64 %99)
  br label %cond_exit_356.2

cond_exit_356.2:                                  ; preds = %__barray_mask_borrow.exit875.2, %cond_exit_356.1
  %100 = load i64, ptr %3, align 4
  %101 = and i64 %100, 8
  %.not928 = icmp eq i64 %101, 0
  br i1 %.not928, label %__barray_mask_borrow.exit875.3, label %cond_exit_356.3

__barray_mask_borrow.exit875.3:                   ; preds = %cond_exit_356.2
  %102 = or disjoint i64 %100, 8
  store i64 %102, ptr %3, align 4
  %103 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %104 = load i64, ptr %103, align 4
  tail call void @___dec_future_refcount(i64 %104)
  br label %cond_exit_356.3

cond_exit_356.3:                                  ; preds = %__barray_mask_borrow.exit875.3, %cond_exit_356.2
  %105 = load i64, ptr %3, align 4
  %106 = or i64 %105, -16
  store i64 %106, ptr %3, align 4
  %107 = icmp eq i64 %106, -1
  br i1 %107, label %loop_out294, label %mask_block_err.i867

cond_exit_208:                                    ; preds = %cond_249_case_1.thread
  %108 = and i64 %86, -2
  store i64 %108, ptr %1, align 4
  store i1 %read_bool, ptr %0, align 1
  %109 = load i64, ptr %3, align 4
  %110 = and i64 %109, 2
  %.not905 = icmp eq i64 %110, 0
  br i1 %.not905, label %__barray_check_bounds.exit857.1, label %panic.i854

__barray_check_bounds.exit857.1:                  ; preds = %cond_exit_208
  %111 = or disjoint i64 %109, 2
  store i64 %111, ptr %3, align 4
  %112 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %113 = load i64, ptr %112, align 4
  tail call void @___inc_future_refcount(i64 %113)
  %114 = load i64, ptr %3, align 4
  %115 = and i64 %114, 2
  %.not906 = icmp eq i64 %115, 0
  br i1 %.not906, label %panic.i858, label %cond_249_case_1.thread.1

cond_249_case_1.thread.1:                         ; preds = %__barray_check_bounds.exit857.1
  %116 = and i64 %114, -3
  store i64 %116, ptr %3, align 4
  store i64 %113, ptr %112, align 4
  %read_bool.1 = tail call i1 @___read_future_bool(i64 %113)
  tail call void @___dec_future_refcount(i64 %113)
  %117 = load i64, ptr %1, align 4
  %118 = and i64 %117, 2
  %.not907 = icmp eq i64 %118, 0
  br i1 %.not907, label %panic.i862, label %cond_exit_208.1

cond_exit_208.1:                                  ; preds = %cond_249_case_1.thread.1
  %119 = and i64 %117, -3
  store i64 %119, ptr %1, align 4
  %120 = getelementptr inbounds nuw i8, ptr %0, i64 1
  store i1 %read_bool.1, ptr %120, align 1
  %121 = load i64, ptr %3, align 4
  %122 = and i64 %121, 4
  %.not908 = icmp eq i64 %122, 0
  br i1 %.not908, label %__barray_check_bounds.exit857.2, label %panic.i854

__barray_check_bounds.exit857.2:                  ; preds = %cond_exit_208.1
  %123 = or disjoint i64 %121, 4
  store i64 %123, ptr %3, align 4
  %124 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %125 = load i64, ptr %124, align 4
  tail call void @___inc_future_refcount(i64 %125)
  %126 = load i64, ptr %3, align 4
  %127 = and i64 %126, 4
  %.not909 = icmp eq i64 %127, 0
  br i1 %.not909, label %panic.i858, label %cond_249_case_1.thread.2

cond_249_case_1.thread.2:                         ; preds = %__barray_check_bounds.exit857.2
  %128 = and i64 %126, -5
  store i64 %128, ptr %3, align 4
  store i64 %125, ptr %124, align 4
  %read_bool.2 = tail call i1 @___read_future_bool(i64 %125)
  tail call void @___dec_future_refcount(i64 %125)
  %129 = load i64, ptr %1, align 4
  %130 = and i64 %129, 4
  %.not910 = icmp eq i64 %130, 0
  br i1 %.not910, label %panic.i862, label %__barray_check_bounds.exit853.3

__barray_check_bounds.exit853.3:                  ; preds = %cond_249_case_1.thread.2
  %131 = and i64 %129, -5
  store i64 %131, ptr %1, align 4
  %132 = getelementptr inbounds nuw i8, ptr %0, i64 2
  store i1 %read_bool.2, ptr %132, align 1
  %133 = load i64, ptr %3, align 4
  %134 = and i64 %133, 8
  %.not911 = icmp eq i64 %134, 0
  br i1 %.not911, label %__barray_check_bounds.exit857.3, label %panic.i854

__barray_check_bounds.exit857.3:                  ; preds = %__barray_check_bounds.exit853.3
  %135 = or disjoint i64 %133, 8
  store i64 %135, ptr %3, align 4
  %136 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %137 = load i64, ptr %136, align 4
  tail call void @___inc_future_refcount(i64 %137)
  %138 = load i64, ptr %3, align 4
  %139 = and i64 %138, 8
  %.not912 = icmp eq i64 %139, 0
  br i1 %.not912, label %panic.i858, label %__barray_check_bounds.exit861.3

__barray_check_bounds.exit861.3:                  ; preds = %__barray_check_bounds.exit857.3
  %140 = and i64 %138, -9
  store i64 %140, ptr %3, align 4
  store i64 %137, ptr %136, align 4
  %read_bool.3 = tail call i1 @___read_future_bool(i64 %137)
  tail call void @___dec_future_refcount(i64 %137)
  %141 = load i64, ptr %1, align 4
  %142 = and i64 %141, 8
  %.not913 = icmp eq i64 %142, 0
  br i1 %.not913, label %panic.i862, label %cond_exit_208.3

cond_exit_208.3:                                  ; preds = %__barray_check_bounds.exit861.3
  %143 = and i64 %141, -9
  store i64 %143, ptr %1, align 4
  %144 = getelementptr inbounds nuw i8, ptr %0, i64 3
  store i1 %read_bool.3, ptr %144, align 1
  %145 = load i64, ptr %3, align 4
  %146 = trunc i64 %145 to i1
  br i1 %146, label %cond_exit_356, label %__barray_mask_borrow.exit875

loop_out294:                                      ; preds = %cond_exit_356.3
  tail call void @heap_free(ptr nonnull %2)
  tail call void @heap_free(ptr nonnull %3)
  %147 = load i64, ptr %1, align 4
  %148 = and i64 %147, 15
  store i64 %148, ptr %1, align 4
  %149 = icmp eq i64 %148, 0
  br i1 %149, label %__barray_check_none_borrowed.exit, label %mask_block_err.i876

mask_block_err.i876:                              ; preds = %loop_out294
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out294
  %150 = tail call ptr @heap_alloc(i64 4)
  %151 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %151, align 1
  %152 = load i32, ptr %0, align 1
  store i32 %152, ptr %150, align 1
  tail call void @heap_free(ptr nonnull %150)
  %153 = load i64, ptr %1, align 4
  %154 = and i64 %153, 15
  store i64 %154, ptr %1, align 4
  %155 = icmp eq i64 %154, 0
  br i1 %155, label %__barray_check_none_borrowed.exit880, label %mask_block_err.i878

mask_block_err.i878:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit880:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %156 = alloca [4 x i1], align 4
  store i32 0, ptr %156, align 4
  store i32 4, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %156, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @heap_free(ptr) local_unnamed_addr

declare i64 @___future_measure(i64, i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

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
