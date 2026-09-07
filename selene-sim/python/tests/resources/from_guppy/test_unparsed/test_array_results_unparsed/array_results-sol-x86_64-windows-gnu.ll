; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@res_floats.8646C2EF.0 = private constant [21 x i8] c"\14USER:FLOATARR:floats"
@res_ints.B3BC9D53.0 = private constant [17 x i8] c"\10USER:INTARR:ints"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 10)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %2 = tail call ptr @heap_alloc(i64 80)
  %3 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %3, align 1
  %4 = tail call ptr @heap_alloc(i64 800)
  %5 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %5, i8 -1, i64 16, i1 false)
  %6 = tail call ptr @heap_alloc(i64 80)
  %7 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %7, align 1
  %8 = tail call ptr @heap_alloc(i64 80)
  %9 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %9, align 1
  br label %loop_body

loop_body:                                        ; preds = %cond_exit_104, %alloca_block
  %"100_2.0" = phi i64 [ 0, %alloca_block ], [ %"2109.0", %cond_exit_104 ]
  %"100_0.sroa.0.0" = phi i64 [ 0, %alloca_block ], [ %11, %cond_exit_104 ]
  %10 = icmp samesign ugt i64 %"100_0.sroa.0.0", 9
  %11 = add nuw nsw i64 %"100_0.sroa.0.0", 1
  br i1 %10, label %cond_exit_104, label %cond_104_case_1

cond_104_case_1:                                  ; preds = %loop_body
  %12 = add i64 %"100_2.0", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_683_case_0.i, label %__hugr__.__tk2_sol_qalloc.679.exit

cond_683_case_0.i:                                ; preds = %cond_104_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.679.exit:               ; preds = %cond_104_case_1
  tail call void @___reset(i64 %qalloc.i)
  %13 = icmp ult i64 %"100_2.0", 10
  br i1 %13, label %__barray_check_bounds.exit, label %out_of_bounds.i

out_of_bounds.i:                                  ; preds = %__hugr__.__tk2_sol_qalloc.679.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %__hugr__.__tk2_sol_qalloc.679.exit
  %14 = load i64, ptr %9, align 4
  %15 = lshr i64 %14, %"100_2.0"
  %16 = trunc i64 %15 to i1
  br i1 %16, label %__barray_mask_return.exit, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit
  %17 = shl nuw nsw i64 1, %"100_2.0"
  %18 = xor i64 %14, %17
  store i64 %18, ptr %9, align 4
  %19 = getelementptr inbounds nuw i64, ptr %8, i64 %"100_2.0"
  store i64 %qalloc.i, ptr %19, align 4
  br label %cond_exit_104

cond_exit_104:                                    ; preds = %loop_body, %__barray_mask_return.exit
  %"2109.0" = phi i64 [ %12, %__barray_mask_return.exit ], [ %"100_2.0", %loop_body ]
  %exitcond = icmp eq i64 %11, 11
  br i1 %exitcond, label %__barray_check_bounds.exit1794, label %loop_body

__barray_check_bounds.exit1794:                   ; preds = %cond_exit_104, %__barray_mask_return.exit1799
  %20 = phi i64 [ %32, %__barray_mask_return.exit1799 ], [ 1, %cond_exit_104 ]
  %"6_0.01885" = phi i64 [ %20, %__barray_mask_return.exit1799 ], [ 0, %cond_exit_104 ]
  %21 = load i64, ptr %9, align 4
  %22 = lshr i64 %21, %"6_0.01885"
  %23 = trunc i64 %22 to i1
  br i1 %23, label %panic.i1795, label %__barray_check_bounds.exit1797

panic.i1795:                                      ; preds = %__barray_check_bounds.exit1794
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1797:                   ; preds = %__barray_check_bounds.exit1794
  %24 = shl nuw nsw i64 1, %"6_0.01885"
  %25 = xor i64 %21, %24
  store i64 %25, ptr %9, align 4
  %26 = getelementptr inbounds nuw i64, ptr %8, i64 %"6_0.01885"
  %27 = load i64, ptr %26, align 4
  tail call void @___rp(i64 %27, double 0x400921FB54442D18, double 0.000000e+00)
  %28 = load i64, ptr %9, align 4
  %29 = lshr i64 %28, %"6_0.01885"
  %30 = trunc i64 %29 to i1
  br i1 %30, label %__barray_mask_return.exit1799, label %panic.i1798

panic.i1798:                                      ; preds = %__barray_check_bounds.exit1797
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1799:                    ; preds = %__barray_check_bounds.exit1797
  %31 = xor i64 %28, %24
  store i64 %31, ptr %9, align 4
  store i64 %27, ptr %26, align 4
  %32 = add nuw nsw i64 %20, 1
  %exitcond1895 = icmp eq i64 %32, 11
  br i1 %exitcond1895, label %loop_body321.preheader, label %__barray_check_bounds.exit1794

out_of_bounds.i1800:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1801:                   ; preds = %.thread
  %33 = load i64, ptr %3, align 4
  %34 = lshr i64 %33, %"476_2.01904"
  %35 = trunc i64 %34 to i1
  br i1 %35, label %cond_exit_480, label %panic.i1802

panic.i1802:                                      ; preds = %__barray_check_bounds.exit1801
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_480
  %36 = load i64, ptr %9, align 4
  %37 = or i64 %36, -1024
  store i64 %37, ptr %9, align 4
  %38 = icmp eq i64 %37, -1
  br i1 %38, label %loop_body430.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

loop_body321.preheader:                           ; preds = %__barray_mask_return.exit1799, %cond_exit_480
  %"476_0.sroa.15.01905" = phi i64 [ %39, %cond_exit_480 ], [ 0, %__barray_mask_return.exit1799 ]
  %"476_2.01904" = phi i64 [ %47, %cond_exit_480 ], [ 0, %__barray_mask_return.exit1799 ]
  %39 = add nuw nsw i64 %"476_0.sroa.15.01905", 1
  %40 = load i64, ptr %9, align 4
  %41 = lshr i64 %40, %"476_0.sroa.15.01905"
  %42 = trunc i64 %41 to i1
  br i1 %42, label %panic.i1806, label %.thread

panic.i1806:                                      ; preds = %loop_body321.preheader
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %loop_body321.preheader
  %43 = shl nuw nsw i64 1, %"476_0.sroa.15.01905"
  %44 = xor i64 %40, %43
  store i64 %44, ptr %9, align 4
  %45 = getelementptr inbounds nuw i64, ptr %8, i64 %"476_0.sroa.15.01905"
  %46 = load i64, ptr %45, align 4
  %47 = add i64 %"476_2.01904", 1
  %___future_measure = tail call i64 @___future_measure(i64 %46, i64 0)
  tail call void @___qfree(i64 %46)
  %48 = icmp ult i64 %"476_2.01904", 10
  br i1 %48, label %__barray_check_bounds.exit1801, label %out_of_bounds.i1800

cond_exit_480:                                    ; preds = %__barray_check_bounds.exit1801
  %49 = shl nuw nsw i64 1, %"476_2.01904"
  %50 = xor i64 %33, %49
  store i64 %50, ptr %3, align 4
  %51 = getelementptr inbounds nuw i64, ptr %2, i64 %"476_2.01904"
  store i64 %___future_measure, ptr %51, align 4
  %52 = icmp samesign ugt i64 %"476_0.sroa.15.01905", 8
  br i1 %52, label %mask_block_ok.i, label %loop_body321.preheader

loop_body430.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %8)
  tail call void @heap_free(ptr nonnull %9)
  br label %__barray_check_bounds.exit1809

__barray_check_bounds.exit1809:                   ; preds = %cond_exit_546, %loop_body430.preheader.preheader
  %"542_0.sroa.15.01887" = phi i64 [ %53, %cond_exit_546 ], [ 0, %loop_body430.preheader.preheader ]
  %53 = add nuw nsw i64 %"542_0.sroa.15.01887", 1
  %54 = load i64, ptr %3, align 4
  %55 = lshr i64 %54, %"542_0.sroa.15.01887"
  %56 = trunc i64 %55 to i1
  br i1 %56, label %panic.i1810, label %__barray_check_bounds.exit1813

panic.i1810:                                      ; preds = %__barray_check_bounds.exit1809
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1813:                   ; preds = %__barray_check_bounds.exit1809
  %57 = shl nuw nsw i64 1, %"542_0.sroa.15.01887"
  %58 = xor i64 %54, %57
  store i64 %58, ptr %3, align 4
  %59 = getelementptr inbounds nuw i64, ptr %2, i64 %"542_0.sroa.15.01887"
  %60 = load i64, ptr %59, align 4
  tail call void @___inc_future_refcount(i64 %60)
  %61 = load i64, ptr %3, align 4
  %62 = lshr i64 %61, %"542_0.sroa.15.01887"
  %63 = trunc i64 %62 to i1
  br i1 %63, label %__barray_check_bounds.exit1817, label %panic.i1814

panic.i1814:                                      ; preds = %__barray_check_bounds.exit1813
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1817:                   ; preds = %__barray_check_bounds.exit1813
  %64 = xor i64 %61, %57
  store i64 %64, ptr %3, align 4
  store i64 %60, ptr %59, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %60)
  tail call void @___dec_future_refcount(i64 %60)
  %65 = load i64, ptr %1, align 4
  %66 = lshr i64 %65, %"542_0.sroa.15.01887"
  %67 = trunc i64 %66 to i1
  br i1 %67, label %cond_exit_546, label %panic.i1818

panic.i1818:                                      ; preds = %__barray_check_bounds.exit1817
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_err.i1823:                             ; preds = %cond_exit_729.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit1831:                    ; preds = %__barray_check_bounds.exit1827.preheader
  %68 = or disjoint i64 %121, 1
  store i64 %68, ptr %3, align 4
  %69 = load i64, ptr %2, align 4
  tail call void @___dec_future_refcount(i64 %69)
  br label %cond_exit_729

cond_exit_729:                                    ; preds = %__barray_mask_borrow.exit1831, %__barray_check_bounds.exit1827.preheader
  %70 = load i64, ptr %3, align 4
  %71 = and i64 %70, 2
  %.not = icmp eq i64 %71, 0
  br i1 %.not, label %__barray_mask_borrow.exit1831.1, label %cond_exit_729.1

__barray_mask_borrow.exit1831.1:                  ; preds = %cond_exit_729
  %72 = or disjoint i64 %70, 2
  store i64 %72, ptr %3, align 4
  %73 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %74 = load i64, ptr %73, align 4
  tail call void @___dec_future_refcount(i64 %74)
  br label %cond_exit_729.1

cond_exit_729.1:                                  ; preds = %__barray_mask_borrow.exit1831.1, %cond_exit_729
  %75 = load i64, ptr %3, align 4
  %76 = and i64 %75, 4
  %.not1908 = icmp eq i64 %76, 0
  br i1 %.not1908, label %__barray_mask_borrow.exit1831.2, label %cond_exit_729.2

__barray_mask_borrow.exit1831.2:                  ; preds = %cond_exit_729.1
  %77 = or disjoint i64 %75, 4
  store i64 %77, ptr %3, align 4
  %78 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %79 = load i64, ptr %78, align 4
  tail call void @___dec_future_refcount(i64 %79)
  br label %cond_exit_729.2

cond_exit_729.2:                                  ; preds = %__barray_mask_borrow.exit1831.2, %cond_exit_729.1
  %80 = load i64, ptr %3, align 4
  %81 = and i64 %80, 8
  %.not1909 = icmp eq i64 %81, 0
  br i1 %.not1909, label %__barray_mask_borrow.exit1831.3, label %cond_exit_729.3

__barray_mask_borrow.exit1831.3:                  ; preds = %cond_exit_729.2
  %82 = or disjoint i64 %80, 8
  store i64 %82, ptr %3, align 4
  %83 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %84 = load i64, ptr %83, align 4
  tail call void @___dec_future_refcount(i64 %84)
  br label %cond_exit_729.3

cond_exit_729.3:                                  ; preds = %__barray_mask_borrow.exit1831.3, %cond_exit_729.2
  %85 = load i64, ptr %3, align 4
  %86 = and i64 %85, 16
  %.not1910 = icmp eq i64 %86, 0
  br i1 %.not1910, label %__barray_mask_borrow.exit1831.4, label %cond_exit_729.4

__barray_mask_borrow.exit1831.4:                  ; preds = %cond_exit_729.3
  %87 = or disjoint i64 %85, 16
  store i64 %87, ptr %3, align 4
  %88 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %89 = load i64, ptr %88, align 4
  tail call void @___dec_future_refcount(i64 %89)
  br label %cond_exit_729.4

cond_exit_729.4:                                  ; preds = %__barray_mask_borrow.exit1831.4, %cond_exit_729.3
  %90 = load i64, ptr %3, align 4
  %91 = and i64 %90, 32
  %.not1911 = icmp eq i64 %91, 0
  br i1 %.not1911, label %__barray_mask_borrow.exit1831.5, label %cond_exit_729.5

__barray_mask_borrow.exit1831.5:                  ; preds = %cond_exit_729.4
  %92 = or disjoint i64 %90, 32
  store i64 %92, ptr %3, align 4
  %93 = getelementptr inbounds nuw i8, ptr %2, i64 40
  %94 = load i64, ptr %93, align 4
  tail call void @___dec_future_refcount(i64 %94)
  br label %cond_exit_729.5

cond_exit_729.5:                                  ; preds = %__barray_mask_borrow.exit1831.5, %cond_exit_729.4
  %95 = load i64, ptr %3, align 4
  %96 = and i64 %95, 64
  %.not1912 = icmp eq i64 %96, 0
  br i1 %.not1912, label %__barray_mask_borrow.exit1831.6, label %cond_exit_729.6

__barray_mask_borrow.exit1831.6:                  ; preds = %cond_exit_729.5
  %97 = or disjoint i64 %95, 64
  store i64 %97, ptr %3, align 4
  %98 = getelementptr inbounds nuw i8, ptr %2, i64 48
  %99 = load i64, ptr %98, align 4
  tail call void @___dec_future_refcount(i64 %99)
  br label %cond_exit_729.6

cond_exit_729.6:                                  ; preds = %__barray_mask_borrow.exit1831.6, %cond_exit_729.5
  %100 = load i64, ptr %3, align 4
  %101 = and i64 %100, 128
  %.not1913 = icmp eq i64 %101, 0
  br i1 %.not1913, label %__barray_mask_borrow.exit1831.7, label %cond_exit_729.7

__barray_mask_borrow.exit1831.7:                  ; preds = %cond_exit_729.6
  %102 = or disjoint i64 %100, 128
  store i64 %102, ptr %3, align 4
  %103 = getelementptr inbounds nuw i8, ptr %2, i64 56
  %104 = load i64, ptr %103, align 4
  tail call void @___dec_future_refcount(i64 %104)
  br label %cond_exit_729.7

cond_exit_729.7:                                  ; preds = %__barray_mask_borrow.exit1831.7, %cond_exit_729.6
  %105 = load i64, ptr %3, align 4
  %106 = and i64 %105, 256
  %.not1914 = icmp eq i64 %106, 0
  br i1 %.not1914, label %__barray_mask_borrow.exit1831.8, label %cond_exit_729.8

__barray_mask_borrow.exit1831.8:                  ; preds = %cond_exit_729.7
  %107 = or disjoint i64 %105, 256
  store i64 %107, ptr %3, align 4
  %108 = getelementptr inbounds nuw i8, ptr %2, i64 64
  %109 = load i64, ptr %108, align 4
  tail call void @___dec_future_refcount(i64 %109)
  br label %cond_exit_729.8

cond_exit_729.8:                                  ; preds = %__barray_mask_borrow.exit1831.8, %cond_exit_729.7
  %110 = load i64, ptr %3, align 4
  %111 = and i64 %110, 512
  %.not1915 = icmp eq i64 %111, 0
  br i1 %.not1915, label %__barray_mask_borrow.exit1831.9, label %cond_exit_729.9

__barray_mask_borrow.exit1831.9:                  ; preds = %cond_exit_729.8
  %112 = or disjoint i64 %110, 512
  store i64 %112, ptr %3, align 4
  %113 = getelementptr inbounds nuw i8, ptr %2, i64 72
  %114 = load i64, ptr %113, align 4
  tail call void @___dec_future_refcount(i64 %114)
  br label %cond_exit_729.9

cond_exit_729.9:                                  ; preds = %__barray_mask_borrow.exit1831.9, %cond_exit_729.8
  %115 = load i64, ptr %3, align 4
  %116 = or i64 %115, -1024
  store i64 %116, ptr %3, align 4
  %117 = icmp eq i64 %116, -1
  br i1 %117, label %loop_out429, label %mask_block_err.i1823

cond_exit_546:                                    ; preds = %__barray_check_bounds.exit1817
  %118 = xor i64 %65, %57
  store i64 %118, ptr %1, align 4
  %119 = getelementptr inbounds nuw i1, ptr %0, i64 %"542_0.sroa.15.01887"
  store i1 %read_bool, ptr %119, align 1
  %120 = icmp eq i64 %"542_0.sroa.15.01887", 9
  br i1 %120, label %__barray_check_bounds.exit1827.preheader, label %__barray_check_bounds.exit1809

__barray_check_bounds.exit1827.preheader:         ; preds = %cond_exit_546
  %121 = load i64, ptr %3, align 4
  %122 = trunc i64 %121 to i1
  br i1 %122, label %cond_exit_729, label %__barray_mask_borrow.exit1831

loop_out429:                                      ; preds = %cond_exit_729.9
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %123 = load i64, ptr %1, align 4
  %124 = and i64 %123, 1023
  store i64 %124, ptr %1, align 4
  %125 = icmp eq i64 %124, 0
  br i1 %125, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1834

__barray_check_none_borrowed.exit:                ; preds = %loop_out429
  %126 = tail call ptr @heap_alloc(i64 10)
  %127 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %127, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %126, ptr noundef nonnull align 1 dereferenceable(10) %0, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %126)
  %128 = load i64, ptr %1, align 4
  %129 = and i64 %128, 1023
  store i64 %129, ptr %1, align 4
  %130 = icmp eq i64 %129, 0
  br i1 %130, label %__barray_check_none_borrowed.exit1840, label %mask_block_err.i1838

mask_block_err.i1834:                             ; preds = %loop_out429
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1840:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %131 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %131, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %131, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  br label %cond_221_case_1

mask_block_err.i1838:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_221_case_1:                                  ; preds = %__barray_check_none_borrowed.exit1840, %cond_exit_221
  %"217_2.01889" = phi i64 [ 0, %__barray_check_none_borrowed.exit1840 ], [ %132, %cond_exit_221 ]
  %132 = add nuw nsw i64 %"217_2.01889", 1
  br label %pow

cond_exit_221:                                    ; preds = %__barray_check_bounds.exit1852
  %133 = fdiv double 1.000000e+00, %storemerge1893
  %134 = shl nuw nsw i64 1, %"217_2.01889"
  %135 = xor i64 %147, %134
  store i64 %135, ptr %7, align 4
  %136 = getelementptr inbounds nuw double, ptr %6, i64 %"217_2.01889"
  store double %133, ptr %136, align 8
  %exitcond1896 = icmp eq i64 %132, 10
  br i1 %exitcond1896, label %loop_out649, label %cond_221_case_1

loop_out649:                                      ; preds = %cond_exit_221
  %137 = load i64, ptr %7, align 4
  %138 = and i64 %137, 1023
  store i64 %138, ptr %7, align 4
  %139 = icmp eq i64 %138, 0
  br i1 %139, label %__barray_check_none_borrowed.exit1845, label %mask_block_err.i1843

__barray_check_none_borrowed.exit1845:            ; preds = %loop_out649
  %140 = call ptr @heap_alloc(i64 80)
  %141 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %141, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(80) %140, ptr noundef nonnull align 1 dereferenceable(80) %6, i64 80, i1 false)
  call void @heap_free(ptr nonnull %140)
  %142 = load i64, ptr %7, align 4
  %143 = and i64 %142, 1023
  store i64 %143, ptr %7, align 4
  %144 = icmp eq i64 %143, 0
  br i1 %144, label %__barray_check_none_borrowed.exit1850, label %mask_block_err.i1848

mask_block_err.i1843:                             ; preds = %loop_out649
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1850:            ; preds = %__barray_check_none_borrowed.exit1845
  %out_arr_alloca852 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr854 = getelementptr inbounds nuw i8, ptr %out_arr_alloca852, i64 4
  %arr_ptr855 = getelementptr inbounds nuw i8, ptr %out_arr_alloca852, i64 8
  %mask_ptr856 = getelementptr inbounds nuw i8, ptr %out_arr_alloca852, i64 16
  %145 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %145, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca852, align 8
  store i32 1, ptr %y_ptr854, align 4
  store ptr %6, ptr %arr_ptr855, align 8
  store ptr %145, ptr %mask_ptr856, align 8
  call void @print_float_arr(ptr nonnull @res_floats.8646C2EF.0, i64 20, ptr nonnull %out_arr_alloca852)
  br label %__barray_check_bounds.exit1856

mask_block_err.i1848:                             ; preds = %__barray_check_none_borrowed.exit1845
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

pow:                                              ; preds = %pow_body, %cond_221_case_1
  %storemerge1684 = phi i64 [ 2, %cond_221_case_1 ], [ %new_acc, %pow_body ]
  %storemerge = phi i64 [ %"217_2.01889", %cond_221_case_1 ], [ %new_exp, %pow_body ]
  switch i64 %storemerge, label %pow_body [
    i64 1, label %done.loopexit
    i64 0, label %__barray_check_bounds.exit1852
  ]

pow_body:                                         ; preds = %pow
  %new_acc = shl i64 %storemerge1684, 1
  %new_exp = add i64 %storemerge, -1
  br label %pow

done.loopexit:                                    ; preds = %pow
  %146 = sitofp i64 %storemerge1684 to double
  br label %__barray_check_bounds.exit1852

__barray_check_bounds.exit1852:                   ; preds = %pow, %done.loopexit
  %storemerge1893 = phi double [ %146, %done.loopexit ], [ 1.000000e+00, %pow ]
  %147 = load i64, ptr %7, align 4
  %148 = lshr i64 %147, %"217_2.01889"
  %149 = trunc i64 %148 to i1
  br i1 %149, label %cond_exit_221, label %panic.i1853

panic.i1853:                                      ; preds = %__barray_check_bounds.exit1852
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1856:                   ; preds = %cond_exit_366.1, %__barray_check_none_borrowed.exit1850
  %"362_2.01892" = phi i64 [ 0, %__barray_check_none_borrowed.exit1850 ], [ %166, %cond_exit_366.1 ]
  %150 = lshr i64 %"362_2.01892", 6
  %151 = getelementptr inbounds nuw i64, ptr %5, i64 %150
  %152 = load i64, ptr %151, align 4
  %153 = and i64 %"362_2.01892", 62
  %154 = lshr i64 %152, %153
  %155 = trunc i64 %154 to i1
  br i1 %155, label %cond_exit_366, label %panic.i1857

panic.i1857:                                      ; preds = %cond_exit_366, %__barray_check_bounds.exit1856
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_366:                                    ; preds = %__barray_check_bounds.exit1856
  %156 = or disjoint i64 %"362_2.01892", 1
  %157 = shl nuw nsw i64 1, %153
  %158 = xor i64 %152, %157
  store i64 %158, ptr %151, align 4
  %159 = getelementptr inbounds nuw i64, ptr %4, i64 %"362_2.01892"
  store i64 %"362_2.01892", ptr %159, align 4
  %160 = lshr i64 %"362_2.01892", 6
  %161 = getelementptr inbounds nuw i64, ptr %5, i64 %160
  %162 = load i64, ptr %161, align 4
  %163 = and i64 %156, 63
  %164 = lshr i64 %162, %163
  %165 = trunc i64 %164 to i1
  br i1 %165, label %cond_exit_366.1, label %panic.i1857

cond_exit_366.1:                                  ; preds = %cond_exit_366
  %166 = add nuw nsw i64 %"362_2.01892", 2
  %167 = shl nuw i64 1, %163
  %168 = xor i64 %162, %167
  store i64 %168, ptr %161, align 4
  %169 = getelementptr inbounds nuw i64, ptr %4, i64 %156
  store i64 %156, ptr %169, align 4
  %exitcond1897.1 = icmp eq i64 %166, 100
  br i1 %exitcond1897.1, label %loop_out860, label %__barray_check_bounds.exit1856

loop_out860:                                      ; preds = %cond_exit_366.1
  %170 = getelementptr inbounds nuw i8, ptr %5, i64 8
  %171 = load i64, ptr %170, align 4
  %172 = and i64 %171, 68719476735
  store i64 %172, ptr %170, align 4
  %173 = load i64, ptr %5, align 4
  %174 = icmp eq i64 %173, 0
  %175 = icmp eq i64 %172, 0
  %or.cond = select i1 %174, i1 %175, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit1863, label %mask_block_err.i1861

__barray_check_none_borrowed.exit1863:            ; preds = %loop_out860
  %176 = call ptr @heap_alloc(i64 800)
  %177 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %177, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %176, ptr noundef nonnull align 1 dereferenceable(800) %4, i64 800, i1 false)
  call void @heap_free(ptr nonnull %176)
  %178 = load i64, ptr %170, align 4
  %179 = and i64 %178, 68719476735
  store i64 %179, ptr %170, align 4
  %180 = load i64, ptr %5, align 4
  %181 = icmp eq i64 %180, 0
  %182 = icmp eq i64 %179, 0
  %or.cond1902 = select i1 %181, i1 %182, i1 false
  br i1 %or.cond1902, label %__barray_check_none_borrowed.exit1868, label %mask_block_err.i1866

mask_block_err.i1861:                             ; preds = %loop_out860
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1868:            ; preds = %__barray_check_none_borrowed.exit1863
  %out_arr_alloca1023 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr1025 = getelementptr inbounds nuw i8, ptr %out_arr_alloca1023, i64 4
  %arr_ptr1026 = getelementptr inbounds nuw i8, ptr %out_arr_alloca1023, i64 8
  %mask_ptr1027 = getelementptr inbounds nuw i8, ptr %out_arr_alloca1023, i64 16
  %183 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %183, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca1023, align 8
  store i32 1, ptr %y_ptr1025, align 4
  store ptr %4, ptr %arr_ptr1026, align 8
  store ptr %183, ptr %mask_ptr1027, align 8
  call void @print_int_arr(ptr nonnull @res_ints.B3BC9D53.0, i64 16, ptr nonnull %out_arr_alloca1023)
  ret void

mask_block_err.i1866:                             ; preds = %__barray_check_none_borrowed.exit1863
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare void @heap_free(ptr) local_unnamed_addr

declare i64 @___future_measure(i64, i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr

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

attributes #0 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #1 = { noreturn }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!name = !{!0}

!0 = !{!"mainlib"}
