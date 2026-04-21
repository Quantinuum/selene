; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@res_cs.46C3C4B5.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:cs"
@res_is.F21393DB.0 = private constant [15 x i8] c"\0EUSER:INTARR:is"
@res_fs.CBD4AF54.0 = private constant [17 x i8] c"\10USER:FLOATARR:fs"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define internal fastcc void @__hugr__.__main__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 800)
  %1 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %1, i8 -1, i64 16, i1 false)
  %2 = tail call ptr @heap_alloc(i64 800)
  %3 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %3, i8 -1, i64 16, i1 false)
  %4 = tail call ptr @heap_alloc(i64 80)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit

cond_293_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.296.exit:                   ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %6 = load i64, ptr %5, align 4
  %7 = trunc i64 %6 to i1
  br i1 %7, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_qalloc.296.exit.8, %__hugr__.__tk2_qalloc.296.exit.7, %__hugr__.__tk2_qalloc.296.exit.6, %__hugr__.__tk2_qalloc.296.exit.5, %__hugr__.__tk2_qalloc.296.exit.4, %__hugr__.__tk2_qalloc.296.exit.3, %__hugr__.__tk2_qalloc.296.exit.2, %__hugr__.__tk2_qalloc.296.exit.1, %__hugr__.__tk2_qalloc.296.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_qalloc.296.exit
  %8 = and i64 %6, -2
  store i64 %8, ptr %5, align 4
  store i64 %qalloc.i, ptr %4, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit.1

__hugr__.__tk2_qalloc.296.exit.1:                 ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %9 = load i64, ptr %5, align 4
  %10 = and i64 %9, 2
  %.not937 = icmp eq i64 %10, 0
  br i1 %.not937, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_qalloc.296.exit.1
  %11 = and i64 %9, -3
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %qalloc.i.1, ptr %12, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit.2

__hugr__.__tk2_qalloc.296.exit.2:                 ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %13 = load i64, ptr %5, align 4
  %14 = and i64 %13, 4
  %.not938 = icmp eq i64 %14, 0
  br i1 %.not938, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_qalloc.296.exit.2
  %15 = and i64 %13, -5
  store i64 %15, ptr %5, align 4
  %16 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %qalloc.i.2, ptr %16, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit.3

__hugr__.__tk2_qalloc.296.exit.3:                 ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %17 = load i64, ptr %5, align 4
  %18 = and i64 %17, 8
  %.not939 = icmp eq i64 %18, 0
  br i1 %.not939, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_qalloc.296.exit.3
  %19 = and i64 %17, -9
  store i64 %19, ptr %5, align 4
  %20 = getelementptr inbounds nuw i8, ptr %4, i64 24
  store i64 %qalloc.i.3, ptr %20, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit.4

__hugr__.__tk2_qalloc.296.exit.4:                 ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %21 = load i64, ptr %5, align 4
  %22 = and i64 %21, 16
  %.not940 = icmp eq i64 %22, 0
  br i1 %.not940, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_qalloc.296.exit.4
  %23 = and i64 %21, -17
  store i64 %23, ptr %5, align 4
  %24 = getelementptr inbounds nuw i8, ptr %4, i64 32
  store i64 %qalloc.i.4, ptr %24, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit.5

__hugr__.__tk2_qalloc.296.exit.5:                 ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %25 = load i64, ptr %5, align 4
  %26 = and i64 %25, 32
  %.not941 = icmp eq i64 %26, 0
  br i1 %.not941, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_qalloc.296.exit.5
  %27 = and i64 %25, -33
  store i64 %27, ptr %5, align 4
  %28 = getelementptr inbounds nuw i8, ptr %4, i64 40
  store i64 %qalloc.i.5, ptr %28, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit.6

__hugr__.__tk2_qalloc.296.exit.6:                 ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %29 = load i64, ptr %5, align 4
  %30 = and i64 %29, 64
  %.not942 = icmp eq i64 %30, 0
  br i1 %.not942, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_qalloc.296.exit.6
  %31 = and i64 %29, -65
  store i64 %31, ptr %5, align 4
  %32 = getelementptr inbounds nuw i8, ptr %4, i64 48
  store i64 %qalloc.i.6, ptr %32, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit.7

__hugr__.__tk2_qalloc.296.exit.7:                 ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %33 = load i64, ptr %5, align 4
  %34 = and i64 %33, 128
  %.not943 = icmp eq i64 %34, 0
  br i1 %.not943, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__hugr__.__tk2_qalloc.296.exit.7
  %35 = and i64 %33, -129
  store i64 %35, ptr %5, align 4
  %36 = getelementptr inbounds nuw i8, ptr %4, i64 56
  store i64 %qalloc.i.7, ptr %36, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_293_case_0.i, label %__hugr__.__tk2_qalloc.296.exit.8

__hugr__.__tk2_qalloc.296.exit.8:                 ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %37 = load i64, ptr %5, align 4
  %38 = and i64 %37, 256
  %.not944 = icmp eq i64 %38, 0
  br i1 %.not944, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__hugr__.__tk2_qalloc.296.exit.8
  %39 = and i64 %37, -257
  store i64 %39, ptr %5, align 4
  %40 = getelementptr inbounds nuw i8, ptr %4, i64 64
  store i64 %qalloc.i.8, ptr %40, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_293_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %41 = load i64, ptr %5, align 4
  %42 = and i64 %41, 512
  %.not945 = icmp eq i64 %42, 0
  br i1 %.not945, label %panic.i, label %cond_exit_20.9

cond_exit_20.9:                                   ; preds = %__barray_check_bounds.exit.9
  %43 = and i64 %41, -513
  store i64 %43, ptr %5, align 4
  %44 = getelementptr inbounds nuw i8, ptr %4, i64 72
  store i64 %qalloc.i.9, ptr %44, align 4
  %"120.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %4, 0
  %"120.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"120.fca.0.insert", ptr %5, 1
  %"120.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"120.fca.1.insert", i64 0, 2
  %45 = load i64, ptr %5, align 4
  %46 = trunc i64 %45 to i1
  br i1 %46, label %panic.i816, label %__barray_mask_borrow.exit

panic.i816:                                       ; preds = %cond_exit_20.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.9
  %47 = or disjoint i64 %45, 1
  store i64 %47, ptr %5, align 4
  %48 = load i64, ptr %4, align 4
  tail call void @___rp(i64 %48, double 0x400921FB54442D18, double 0.000000e+00)
  %49 = load i64, ptr %5, align 4
  %50 = trunc i64 %49 to i1
  br i1 %50, label %__barray_mask_return.exit818, label %panic.i817

panic.i817:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit818:                     ; preds = %__barray_mask_borrow.exit
  %51 = and i64 %49, -2
  store i64 %51, ptr %5, align 4
  store i64 %48, ptr %4, align 4
  %52 = load i64, ptr %5, align 4
  %53 = and i64 %52, 4
  %.not = icmp eq i64 %53, 0
  br i1 %.not, label %__barray_mask_borrow.exit820, label %panic.i819

panic.i819:                                       ; preds = %__barray_mask_return.exit818
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit820:                     ; preds = %__barray_mask_return.exit818
  %54 = or disjoint i64 %52, 4
  store i64 %54, ptr %5, align 4
  %55 = load i64, ptr %16, align 4
  tail call void @___rp(i64 %55, double 0x400921FB54442D18, double 0.000000e+00)
  %56 = load i64, ptr %5, align 4
  %57 = and i64 %56, 4
  %.not915 = icmp eq i64 %57, 0
  br i1 %.not915, label %panic.i821, label %__barray_mask_return.exit822

panic.i821:                                       ; preds = %__barray_mask_borrow.exit820
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit822:                     ; preds = %__barray_mask_borrow.exit820
  %58 = and i64 %56, -5
  store i64 %58, ptr %5, align 4
  store i64 %55, ptr %16, align 4
  %59 = load i64, ptr %5, align 4
  %60 = and i64 %59, 8
  %.not916 = icmp eq i64 %60, 0
  br i1 %.not916, label %__barray_mask_borrow.exit824, label %panic.i823

panic.i823:                                       ; preds = %__barray_mask_return.exit822
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit824:                     ; preds = %__barray_mask_return.exit822
  %61 = or disjoint i64 %59, 8
  store i64 %61, ptr %5, align 4
  %62 = load i64, ptr %20, align 4
  tail call void @___rp(i64 %62, double 0x400921FB54442D18, double 0.000000e+00)
  %63 = load i64, ptr %5, align 4
  %64 = and i64 %63, 8
  %.not917 = icmp eq i64 %64, 0
  br i1 %.not917, label %panic.i825, label %__barray_mask_return.exit826

panic.i825:                                       ; preds = %__barray_mask_borrow.exit824
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit826:                     ; preds = %__barray_mask_borrow.exit824
  %65 = and i64 %63, -9
  store i64 %65, ptr %5, align 4
  store i64 %62, ptr %20, align 4
  %66 = load i64, ptr %5, align 4
  %67 = and i64 %66, 512
  %.not918 = icmp eq i64 %67, 0
  br i1 %.not918, label %__barray_mask_borrow.exit828, label %panic.i827

panic.i827:                                       ; preds = %__barray_mask_return.exit826
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit828:                     ; preds = %__barray_mask_return.exit826
  %68 = or disjoint i64 %66, 512
  store i64 %68, ptr %5, align 4
  %69 = load i64, ptr %44, align 4
  tail call void @___rp(i64 %69, double 0x400921FB54442D18, double 0.000000e+00)
  %70 = load i64, ptr %5, align 4
  %71 = and i64 %70, 512
  %.not919 = icmp eq i64 %71, 0
  br i1 %.not919, label %panic.i829, label %__barray_mask_return.exit830

panic.i829:                                       ; preds = %__barray_mask_borrow.exit828
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit830:                     ; preds = %__barray_mask_borrow.exit828
  %72 = and i64 %70, -513
  store i64 %72, ptr %5, align 4
  store i64 %69, ptr %44, align 4
  %73 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"120.fca.2.insert", 0
  %74 = tail call ptr @heap_alloc(i64 240)
  %75 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %75, align 1
  br label %__barray_check_bounds.exit.i.i

76:                                               ; preds = %loop_body.i
  %77 = lshr i64 %.fca.2.extract82.i.i, 6
  %78 = getelementptr i64, ptr %.fca.1.extract81.i.i, i64 %77
  %79 = load i64, ptr %78, align 4
  %80 = and i64 %.fca.2.extract82.i.i, 63
  %81 = sub nuw nsw i64 64, %80
  %82 = lshr i64 -1, %81
  %83 = icmp eq i64 %80, 0
  %84 = select i1 %83, i64 0, i64 %82
  %85 = or i64 %79, %84
  store i64 %85, ptr %78, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract82.i.i, 9
  %86 = lshr i64 %last_valid.i.i.i, 6
  %87 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i.i, i64 %86
  %88 = load i64, ptr %87, align 4
  %89 = and i64 %last_valid.i.i.i, 63
  %90 = shl nsw i64 -2, %89
  %91 = icmp eq i64 %89, 63
  %92 = select i1 %91, i64 0, i64 %90
  %93 = or i64 %88, %92
  store i64 %93, ptr %87, align 4
  %reass.sub.i.i.i = sub nsw i64 %86, %77
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit", label %mask_block_ok.i.i.i

94:                                               ; preds = %mask_block_ok.i.i.i
  %95 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %76, %94
  %.02.i.i.i = phi i64 [ %95, %94 ], [ 0, %76 ]
  %gep.i.i.i = getelementptr i64, ptr %78, i64 %.02.i.i.i
  %96 = load i64, ptr %gep.i.i.i, align 4
  %97 = icmp eq i64 %96, -1
  br i1 %97, label %94, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit830
  %.fca.2.extract82.i187.i = phi i64 [ 0, %__barray_mask_return.exit830 ], [ %.fca.2.extract82.i.i, %loop_body.i ]
  %.fca.1.extract81.i186.i = phi ptr [ %5, %__barray_mask_return.exit830 ], [ %.fca.1.extract81.i.i, %loop_body.i ]
  %.fca.0.extract80.i185.i = phi ptr [ %4, %__barray_mask_return.exit830 ], [ %.fca.0.extract80.i.i, %loop_body.i ]
  %"396_0.sroa.15.0184.i" = phi i64 [ 0, %__barray_mask_return.exit830 ], [ %98, %loop_body.i ]
  %.pn165183.i = phi { { ptr, ptr, i64 }, i64 } [ %73, %__barray_mask_return.exit830 ], [ %113, %loop_body.i ]
  %98 = add nuw nsw i64 %"396_0.sroa.15.0184.i", 1
  %99 = add i64 %"396_0.sroa.15.0184.i", %.fca.2.extract82.i187.i
  %100 = lshr i64 %99, 6
  %101 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i186.i, i64 %100
  %102 = load i64, ptr %101, align 4
  %103 = and i64 %99, 63
  %104 = lshr i64 %102, %103
  %105 = trunc i64 %104 to i1
  br i1 %105, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %106 = shl nuw i64 1, %103
  %107 = xor i64 %106, %102
  store i64 %107, ptr %101, align 4
  %108 = getelementptr inbounds i64, ptr %.fca.0.extract80.i185.i, i64 %99
  %109 = load i64, ptr %108, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %109)
  tail call void @___qfree(i64 %109)
  %110 = load i64, ptr %75, align 4
  %111 = lshr i64 %110, %"396_0.sroa.15.0184.i"
  %112 = trunc i64 %111 to i1
  br i1 %112, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"461_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"461_054.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"461_054.fca.1.insert.i", i1 undef, 2
  %113 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, i64 %98, 1
  %114 = shl nuw nsw i64 1, %"396_0.sroa.15.0184.i"
  %115 = xor i64 %110, %114
  store i64 %115, ptr %75, align 4
  %116 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %74, i64 %"396_0.sroa.15.0184.i"
  store { i1, i64, i1 } %"461_054.fca.2.insert.i", ptr %116, align 4
  %117 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %117, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %117, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %117, 2
  %exitcond.not.i = icmp eq i64 %98, 10
  br i1 %exitcond.not.i, label %76, label %__barray_check_bounds.exit.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit": ; preds = %94, %76
  tail call void @heap_free(ptr %.fca.0.extract80.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract81.i.i)
  %118 = tail call ptr @heap_alloc(i64 320)
  %119 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %119, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(320) %118, i8 0, i64 320, i1 false)
  %120 = load i64, ptr %75, align 4
  %121 = and i64 %120, 1023
  store i64 %121, ptr %75, align 4
  %122 = icmp eq i64 %121, 0
  br i1 %122, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit"
  %123 = tail call ptr @heap_alloc(i64 240)
  %124 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %124, align 1
  br label %125

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

125:                                              ; preds = %__barray_check_none_borrowed.exit, %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit"
  %storemerge593926 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %133, %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit" ]
  %126 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %74, i64 %storemerge593926
  %127 = load { i1, i64, i1 }, ptr %126, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %127, 0
  br i1 %.fca.0.extract118.i, label %cond_252_case_1.i, label %cond_252_case_0.i

cond_252_case_0.i:                                ; preds = %125
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %127, 2
  br label %cond_exit_252.i

cond_252_case_1.i:                                ; preds = %125
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %127, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_252.i

cond_exit_252.i:                                  ; preds = %cond_252_case_0.i, %cond_252_case_1.i
  %"03.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_252_case_1.i ], [ undef, %cond_252_case_0.i ]
  %"03.sroa.6.0.i" = phi i1 [ undef, %cond_252_case_1.i ], [ %.fca.2.extract120.i, %cond_252_case_0.i ]
  %128 = load i64, ptr %119, align 4
  %129 = lshr i64 %128, %storemerge593926
  %130 = trunc i64 %129 to i1
  br i1 %130, label %panic.i.i832, label %cond_250_case_1.i

panic.i.i832:                                     ; preds = %cond_exit_252.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_250_case_1.i:                                ; preds = %cond_exit_252.i
  %"16.fca.1.insert.i" = insertvalue { i1, i64, i1 } %127, i64 %"03.sroa.3.0.i", 1
  %"16.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i", i1 %"03.sroa.6.0.i", 2
  %131 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i", 1
  %132 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %118, i64 %storemerge593926
  %.fca.2.0.extract.i = load i1, ptr %132, align 1
  store { i1, { i1, i64, i1 } } %131, ptr %132, align 4
  br i1 %.fca.2.0.extract.i, label %cond_249_case_1.i, label %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit"

cond_249_case_1.i:                                ; preds = %cond_250_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit": ; preds = %cond_250_case_1.i
  %133 = add nuw nsw i64 %storemerge593926, 1
  %134 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %123, i64 %storemerge593926
  store { i1, i64, i1 } %"16.fca.2.insert.i", ptr %134, align 4
  %exitcond.not = icmp eq i64 %133, 10
  br i1 %exitcond.not, label %mask_block_ok.i833, label %125

mask_block_ok.i833:                               ; preds = %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit"
  tail call void @heap_free(ptr nonnull %74)
  tail call void @heap_free(ptr nonnull %75)
  %135 = load i64, ptr %119, align 4
  %136 = and i64 %135, 1023
  store i64 %136, ptr %119, align 4
  %137 = icmp eq i64 %136, 0
  br i1 %137, label %__barray_check_none_borrowed.exit838, label %mask_block_err.i836

__barray_check_none_borrowed.exit838:             ; preds = %mask_block_ok.i833
  %138 = tail call ptr @heap_alloc(i64 240)
  %139 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %139, align 1
  %140 = load { i1, { i1, i64, i1 } }, ptr %118, align 4
  %141 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %140)
  %142 = extractvalue { { i1, i64, i1 } } %141, 0
  store { i1, i64, i1 } %142, ptr %138, align 4
  %143 = getelementptr i8, ptr %118, i64 32
  %144 = load { i1, { i1, i64, i1 } }, ptr %143, align 4
  %145 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %144)
  %146 = getelementptr inbounds nuw i8, ptr %138, i64 24
  %147 = extractvalue { { i1, i64, i1 } } %145, 0
  store { i1, i64, i1 } %147, ptr %146, align 4
  %148 = getelementptr i8, ptr %118, i64 64
  %149 = load { i1, { i1, i64, i1 } }, ptr %148, align 4
  %150 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %149)
  %151 = getelementptr inbounds nuw i8, ptr %138, i64 48
  %152 = extractvalue { { i1, i64, i1 } } %150, 0
  store { i1, i64, i1 } %152, ptr %151, align 4
  %153 = getelementptr i8, ptr %118, i64 96
  %154 = load { i1, { i1, i64, i1 } }, ptr %153, align 4
  %155 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %154)
  %156 = getelementptr inbounds nuw i8, ptr %138, i64 72
  %157 = extractvalue { { i1, i64, i1 } } %155, 0
  store { i1, i64, i1 } %157, ptr %156, align 4
  %158 = getelementptr i8, ptr %118, i64 128
  %159 = load { i1, { i1, i64, i1 } }, ptr %158, align 4
  %160 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %159)
  %161 = getelementptr inbounds nuw i8, ptr %138, i64 96
  %162 = extractvalue { { i1, i64, i1 } } %160, 0
  store { i1, i64, i1 } %162, ptr %161, align 4
  %163 = getelementptr i8, ptr %118, i64 160
  %164 = load { i1, { i1, i64, i1 } }, ptr %163, align 4
  %165 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %164)
  %166 = getelementptr inbounds nuw i8, ptr %138, i64 120
  %167 = extractvalue { { i1, i64, i1 } } %165, 0
  store { i1, i64, i1 } %167, ptr %166, align 4
  %168 = getelementptr i8, ptr %118, i64 192
  %169 = load { i1, { i1, i64, i1 } }, ptr %168, align 4
  %170 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %169)
  %171 = getelementptr inbounds nuw i8, ptr %138, i64 144
  %172 = extractvalue { { i1, i64, i1 } } %170, 0
  store { i1, i64, i1 } %172, ptr %171, align 4
  %173 = getelementptr i8, ptr %118, i64 224
  %174 = load { i1, { i1, i64, i1 } }, ptr %173, align 4
  %175 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %174)
  %176 = getelementptr inbounds nuw i8, ptr %138, i64 168
  %177 = extractvalue { { i1, i64, i1 } } %175, 0
  store { i1, i64, i1 } %177, ptr %176, align 4
  %178 = getelementptr i8, ptr %118, i64 256
  %179 = load { i1, { i1, i64, i1 } }, ptr %178, align 4
  %180 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %179)
  %181 = getelementptr inbounds nuw i8, ptr %138, i64 192
  %182 = extractvalue { { i1, i64, i1 } } %180, 0
  store { i1, i64, i1 } %182, ptr %181, align 4
  %183 = getelementptr i8, ptr %118, i64 288
  %184 = load { i1, { i1, i64, i1 } }, ptr %183, align 4
  %185 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %184)
  %186 = getelementptr inbounds nuw i8, ptr %138, i64 216
  %187 = extractvalue { { i1, i64, i1 } } %185, 0
  store { i1, i64, i1 } %187, ptr %186, align 4
  tail call void @heap_free(ptr nonnull %118)
  tail call void @heap_free(ptr nonnull %119)
  br label %__barray_check_bounds.exit845

mask_block_err.i836:                              ; preds = %mask_block_ok.i833
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_559_case_0:                                  ; preds = %cond_exit_559
  %188 = load i64, ptr %139, align 4
  %189 = or i64 %188, -1024
  store i64 %189, ptr %139, align 4
  %190 = icmp eq i64 %189, -1
  br i1 %190, label %loop_out130, label %mask_block_err.i842

mask_block_err.i842:                              ; preds = %cond_559_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit845:                    ; preds = %__barray_check_none_borrowed.exit838, %cond_exit_559
  %"556_0.0950" = phi i64 [ 0, %__barray_check_none_borrowed.exit838 ], [ %191, %cond_exit_559 ]
  %191 = add nuw nsw i64 %"556_0.0950", 1
  %192 = load i64, ptr %139, align 4
  %193 = lshr i64 %192, %"556_0.0950"
  %194 = trunc i64 %193 to i1
  br i1 %194, label %cond_exit_559, label %__barray_mask_borrow.exit849

__barray_mask_borrow.exit849:                     ; preds = %__barray_check_bounds.exit845
  %195 = shl nuw nsw i64 1, %"556_0.0950"
  %196 = xor i64 %192, %195
  store i64 %196, ptr %139, align 4
  %197 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %138, i64 %"556_0.0950"
  %198 = load { i1, i64, i1 }, ptr %197, align 4
  %.fca.0.extract491 = extractvalue { i1, i64, i1 } %198, 0
  br i1 %.fca.0.extract491, label %cond_582_case_1, label %cond_exit_559

cond_exit_559:                                    ; preds = %cond_582_case_1, %__barray_mask_borrow.exit849, %__barray_check_bounds.exit845
  %199 = icmp samesign ugt i64 %"556_0.0950", 8
  br i1 %199, label %cond_559_case_0, label %__barray_check_bounds.exit845

loop_out130:                                      ; preds = %cond_559_case_0
  tail call void @heap_free(ptr nonnull %138)
  tail call void @heap_free(ptr nonnull %139)
  %200 = load i64, ptr %124, align 4
  %201 = and i64 %200, 1023
  store i64 %201, ptr %124, align 4
  %202 = icmp eq i64 %201, 0
  br i1 %202, label %__barray_check_none_borrowed.exit855, label %mask_block_err.i853

__barray_check_none_borrowed.exit855:             ; preds = %loop_out130
  %203 = tail call ptr @heap_alloc(i64 10)
  %204 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %204, align 1
  %205 = load { i1, i64, i1 }, ptr %123, align 4
  %206 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %205)
  %207 = extractvalue { i1 } %206, 0
  store i1 %207, ptr %203, align 1
  %208 = getelementptr inbounds nuw i8, ptr %123, i64 24
  %209 = load { i1, i64, i1 }, ptr %208, align 4
  %210 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %209)
  %211 = getelementptr inbounds nuw i8, ptr %203, i64 1
  %212 = extractvalue { i1 } %210, 0
  store i1 %212, ptr %211, align 1
  %213 = getelementptr inbounds nuw i8, ptr %123, i64 48
  %214 = load { i1, i64, i1 }, ptr %213, align 4
  %215 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %214)
  %216 = getelementptr inbounds nuw i8, ptr %203, i64 2
  %217 = extractvalue { i1 } %215, 0
  store i1 %217, ptr %216, align 1
  %218 = getelementptr inbounds nuw i8, ptr %123, i64 72
  %219 = load { i1, i64, i1 }, ptr %218, align 4
  %220 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %219)
  %221 = getelementptr inbounds nuw i8, ptr %203, i64 3
  %222 = extractvalue { i1 } %220, 0
  store i1 %222, ptr %221, align 1
  %223 = getelementptr inbounds nuw i8, ptr %123, i64 96
  %224 = load { i1, i64, i1 }, ptr %223, align 4
  %225 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %224)
  %226 = getelementptr inbounds nuw i8, ptr %203, i64 4
  %227 = extractvalue { i1 } %225, 0
  store i1 %227, ptr %226, align 1
  %228 = getelementptr inbounds nuw i8, ptr %123, i64 120
  %229 = load { i1, i64, i1 }, ptr %228, align 4
  %230 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %229)
  %231 = getelementptr inbounds nuw i8, ptr %203, i64 5
  %232 = extractvalue { i1 } %230, 0
  store i1 %232, ptr %231, align 1
  %233 = getelementptr inbounds nuw i8, ptr %123, i64 144
  %234 = load { i1, i64, i1 }, ptr %233, align 4
  %235 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %234)
  %236 = getelementptr inbounds nuw i8, ptr %203, i64 6
  %237 = extractvalue { i1 } %235, 0
  store i1 %237, ptr %236, align 1
  %238 = getelementptr inbounds nuw i8, ptr %123, i64 168
  %239 = load { i1, i64, i1 }, ptr %238, align 4
  %240 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %239)
  %241 = getelementptr inbounds nuw i8, ptr %203, i64 7
  %242 = extractvalue { i1 } %240, 0
  store i1 %242, ptr %241, align 1
  %243 = getelementptr inbounds nuw i8, ptr %123, i64 192
  %244 = load { i1, i64, i1 }, ptr %243, align 4
  %245 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %244)
  %246 = getelementptr inbounds nuw i8, ptr %203, i64 8
  %247 = extractvalue { i1 } %245, 0
  store i1 %247, ptr %246, align 1
  %248 = getelementptr inbounds nuw i8, ptr %123, i64 216
  %249 = load { i1, i64, i1 }, ptr %248, align 4
  %250 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %249)
  %251 = getelementptr inbounds nuw i8, ptr %203, i64 9
  %252 = extractvalue { i1 } %250, 0
  store i1 %252, ptr %251, align 1
  tail call void @heap_free(ptr nonnull %123)
  tail call void @heap_free(ptr nonnull %124)
  %253 = load i64, ptr %204, align 4
  %254 = and i64 %253, 1023
  store i64 %254, ptr %204, align 4
  %255 = icmp eq i64 %254, 0
  br i1 %255, label %__barray_check_none_borrowed.exit861, label %mask_block_err.i859

mask_block_err.i853:                              ; preds = %loop_out130
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_582_case_1:                                  ; preds = %__barray_mask_borrow.exit849
  %.fca.1.extract492 = extractvalue { i1, i64, i1 } %198, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492)
  br label %cond_exit_559

__barray_check_none_borrowed.exit861:             ; preds = %__barray_check_none_borrowed.exit855
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %256 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %256, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %203, ptr %arr_ptr, align 8
  store ptr %256, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  br label %__barray_check_bounds.exit869

mask_block_err.i859:                              ; preds = %__barray_check_none_borrowed.exit855
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit869:                    ; preds = %cond_exit_95, %__barray_check_none_borrowed.exit861
  %"90_0.sroa.0.0930" = phi i64 [ 0, %__barray_check_none_borrowed.exit861 ], [ %263, %cond_exit_95 ]
  %257 = lshr i64 %"90_0.sroa.0.0930", 6
  %258 = getelementptr inbounds nuw i64, ptr %3, i64 %257
  %259 = load i64, ptr %258, align 4
  %260 = and i64 %"90_0.sroa.0.0930", 63
  %261 = lshr i64 %259, %260
  %262 = trunc i64 %261 to i1
  br i1 %262, label %cond_exit_95, label %panic.i870

panic.i870:                                       ; preds = %__barray_check_bounds.exit869
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_95:                                     ; preds = %__barray_check_bounds.exit869
  %263 = add nuw nsw i64 %"90_0.sroa.0.0930", 1
  %264 = shl nuw i64 1, %260
  %265 = xor i64 %259, %264
  store i64 %265, ptr %258, align 4
  %266 = getelementptr inbounds nuw i64, ptr %2, i64 %"90_0.sroa.0.0930"
  store i64 %"90_0.sroa.0.0930", ptr %266, align 4
  %exitcond935.not = icmp eq i64 %263, 100
  br i1 %exitcond935.not, label %loop_out200, label %__barray_check_bounds.exit869

loop_out200:                                      ; preds = %cond_exit_95
  %267 = getelementptr i8, ptr %3, i64 8
  %268 = load i64, ptr %267, align 4
  %269 = and i64 %268, 68719476735
  store i64 %269, ptr %267, align 4
  %270 = load i64, ptr %3, align 4
  %271 = icmp eq i64 %270, 0
  %272 = icmp eq i64 %269, 0
  %or.cond = select i1 %271, i1 %272, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit877, label %mask_block_err.i875

__barray_check_none_borrowed.exit877:             ; preds = %loop_out200
  %273 = call ptr @heap_alloc(i64 800)
  %274 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %274, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %273, ptr noundef nonnull align 1 dereferenceable(800) %2, i64 800, i1 false)
  call void @heap_free(ptr nonnull %273)
  %275 = load i64, ptr %267, align 4
  %276 = and i64 %275, 68719476735
  store i64 %276, ptr %267, align 4
  %277 = load i64, ptr %3, align 4
  %278 = icmp eq i64 %277, 0
  %279 = icmp eq i64 %276, 0
  %or.cond947 = select i1 %278, i1 %279, i1 false
  br i1 %or.cond947, label %__barray_check_none_borrowed.exit883, label %mask_block_err.i881

mask_block_err.i875:                              ; preds = %loop_out200
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit883:             ; preds = %__barray_check_none_borrowed.exit877
  %out_arr_alloca276 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr278 = getelementptr inbounds nuw i8, ptr %out_arr_alloca276, i64 4
  %arr_ptr279 = getelementptr inbounds nuw i8, ptr %out_arr_alloca276, i64 8
  %mask_ptr280 = getelementptr inbounds nuw i8, ptr %out_arr_alloca276, i64 16
  %280 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %280, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca276, align 8
  store i32 1, ptr %y_ptr278, align 4
  store ptr %2, ptr %arr_ptr279, align 8
  store ptr %280, ptr %mask_ptr280, align 8
  call void @print_int_arr(ptr nonnull @res_is.F21393DB.0, i64 14, ptr nonnull %out_arr_alloca276)
  br label %__barray_check_bounds.exit891

mask_block_err.i881:                              ; preds = %__barray_check_none_borrowed.exit877
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit891:                    ; preds = %cond_exit_130, %__barray_check_none_borrowed.exit883
  %"125_0.sroa.0.0932" = phi i64 [ 0, %__barray_check_none_borrowed.exit883 ], [ %289, %cond_exit_130 ]
  %281 = lshr i64 %"125_0.sroa.0.0932", 6
  %282 = getelementptr inbounds nuw i64, ptr %1, i64 %281
  %283 = load i64, ptr %282, align 4
  %284 = and i64 %"125_0.sroa.0.0932", 63
  %285 = lshr i64 %283, %284
  %286 = trunc i64 %285 to i1
  br i1 %286, label %cond_exit_130, label %panic.i892

panic.i892:                                       ; preds = %__barray_check_bounds.exit891
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_130:                                    ; preds = %__barray_check_bounds.exit891
  %287 = uitofp nneg i64 %"125_0.sroa.0.0932" to double
  %288 = fmul double %287, 6.250000e-02
  %289 = add nuw nsw i64 %"125_0.sroa.0.0932", 1
  %290 = shl nuw i64 1, %284
  %291 = xor i64 %283, %290
  store i64 %291, ptr %282, align 4
  %292 = getelementptr inbounds nuw double, ptr %0, i64 %"125_0.sroa.0.0932"
  store double %288, ptr %292, align 8
  %exitcond936.not = icmp eq i64 %289, 100
  br i1 %exitcond936.not, label %loop_out284, label %__barray_check_bounds.exit891

loop_out284:                                      ; preds = %cond_exit_130
  %293 = getelementptr i8, ptr %1, i64 8
  %294 = load i64, ptr %293, align 4
  %295 = and i64 %294, 68719476735
  store i64 %295, ptr %293, align 4
  %296 = load i64, ptr %1, align 4
  %297 = icmp eq i64 %296, 0
  %298 = icmp eq i64 %295, 0
  %or.cond948 = select i1 %297, i1 %298, i1 false
  br i1 %or.cond948, label %__barray_check_none_borrowed.exit899, label %mask_block_err.i897

__barray_check_none_borrowed.exit899:             ; preds = %loop_out284
  %299 = call ptr @heap_alloc(i64 800)
  %300 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %300, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %299, ptr noundef nonnull align 1 dereferenceable(800) %0, i64 800, i1 false)
  call void @heap_free(ptr nonnull %299)
  %301 = load i64, ptr %293, align 4
  %302 = and i64 %301, 68719476735
  store i64 %302, ptr %293, align 4
  %303 = load i64, ptr %1, align 4
  %304 = icmp eq i64 %303, 0
  %305 = icmp eq i64 %302, 0
  %or.cond949 = select i1 %304, i1 %305, i1 false
  br i1 %or.cond949, label %__barray_check_none_borrowed.exit905, label %mask_block_err.i903

mask_block_err.i897:                              ; preds = %loop_out284
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit905:             ; preds = %__barray_check_none_borrowed.exit899
  %out_arr_alloca363 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr365 = getelementptr inbounds nuw i8, ptr %out_arr_alloca363, i64 4
  %arr_ptr366 = getelementptr inbounds nuw i8, ptr %out_arr_alloca363, i64 8
  %mask_ptr367 = getelementptr inbounds nuw i8, ptr %out_arr_alloca363, i64 16
  %306 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %306, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca363, align 8
  store i32 1, ptr %y_ptr365, align 4
  store ptr %0, ptr %arr_ptr366, align 8
  store ptr %306, ptr %mask_ptr367, align 8
  call void @print_float_arr(ptr nonnull @res_fs.CBD4AF54.0, i64 16, ptr nonnull %out_arr_alloca363)
  ret void

mask_block_err.i903:                              ; preds = %__barray_check_none_borrowed.exit899
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

define internal i1 @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_283_case_1, label %cond_283_case_0

cond_283_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_283

cond_283_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_283

cond_exit_283:                                    ; preds = %cond_283_case_1, %cond_283_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_283_case_1 ], [ %.fca.2.extract, %cond_283_case_0 ]
  ret i1 %"03.0"
}

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare void @heap_free(ptr) local_unnamed_addr

define internal { i1, i64, i1 } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract11 = extractvalue { i1, { i1, i64, i1 } } %0, 0
  br i1 %.fca.0.extract11, label %cond_490_case_1, label %cond_490_case_0

cond_490_case_1:                                  ; preds = %alloca_block
  %1 = extractvalue { i1, { i1, i64, i1 } } %0, 1
  ret { i1, i64, i1 } %1

cond_490_case_0:                                  ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.E6312129.0")
  unreachable
}

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @__hugr__.__main__.main.1()
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
