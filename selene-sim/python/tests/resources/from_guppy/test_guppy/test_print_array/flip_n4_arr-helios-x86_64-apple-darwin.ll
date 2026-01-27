; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

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
  br i1 %not_max.not.not.i, label %cond_293_case_0.i, label %__barray_check_bounds.exit

cond_293_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %6 = load i64, ptr %5, align 4
  %7 = trunc i64 %6 to i1
  br i1 %7, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__barray_check_bounds.exit.8, %__barray_check_bounds.exit.7, %__barray_check_bounds.exit.6, %__barray_check_bounds.exit.5, %__barray_check_bounds.exit.4, %__barray_check_bounds.exit.3, %__barray_check_bounds.exit.2, %__barray_check_bounds.exit.1, %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__barray_check_bounds.exit
  %8 = and i64 %6, -2
  store i64 %8, ptr %5, align 4
  store i64 %qalloc.i, ptr %4, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_293_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %9 = load i64, ptr %5, align 4
  %10 = and i64 %9, 2
  %.not943 = icmp eq i64 %10, 0
  br i1 %.not943, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit.1
  %11 = and i64 %9, -3
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %qalloc.i.1, ptr %12, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_293_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %13 = load i64, ptr %5, align 4
  %14 = and i64 %13, 4
  %.not944 = icmp eq i64 %14, 0
  br i1 %.not944, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %15 = and i64 %13, -5
  store i64 %15, ptr %5, align 4
  %16 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %qalloc.i.2, ptr %16, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_293_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %17 = load i64, ptr %5, align 4
  %18 = and i64 %17, 8
  %.not945 = icmp eq i64 %18, 0
  br i1 %.not945, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %19 = and i64 %17, -9
  store i64 %19, ptr %5, align 4
  %20 = getelementptr inbounds nuw i8, ptr %4, i64 24
  store i64 %qalloc.i.3, ptr %20, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_293_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %21 = load i64, ptr %5, align 4
  %22 = and i64 %21, 16
  %.not946 = icmp eq i64 %22, 0
  br i1 %.not946, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %23 = and i64 %21, -17
  store i64 %23, ptr %5, align 4
  %24 = getelementptr inbounds nuw i8, ptr %4, i64 32
  store i64 %qalloc.i.4, ptr %24, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_293_case_0.i, label %__barray_check_bounds.exit.5

__barray_check_bounds.exit.5:                     ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %25 = load i64, ptr %5, align 4
  %26 = and i64 %25, 32
  %.not947 = icmp eq i64 %26, 0
  br i1 %.not947, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__barray_check_bounds.exit.5
  %27 = and i64 %25, -33
  store i64 %27, ptr %5, align 4
  %28 = getelementptr inbounds nuw i8, ptr %4, i64 40
  store i64 %qalloc.i.5, ptr %28, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_293_case_0.i, label %__barray_check_bounds.exit.6

__barray_check_bounds.exit.6:                     ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %29 = load i64, ptr %5, align 4
  %30 = and i64 %29, 64
  %.not948 = icmp eq i64 %30, 0
  br i1 %.not948, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__barray_check_bounds.exit.6
  %31 = and i64 %29, -65
  store i64 %31, ptr %5, align 4
  %32 = getelementptr inbounds nuw i8, ptr %4, i64 48
  store i64 %qalloc.i.6, ptr %32, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_293_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %33 = load i64, ptr %5, align 4
  %34 = and i64 %33, 128
  %.not949 = icmp eq i64 %34, 0
  br i1 %.not949, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %35 = and i64 %33, -129
  store i64 %35, ptr %5, align 4
  %36 = getelementptr inbounds nuw i8, ptr %4, i64 56
  store i64 %qalloc.i.7, ptr %36, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_293_case_0.i, label %__barray_check_bounds.exit.8

__barray_check_bounds.exit.8:                     ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %37 = load i64, ptr %5, align 4
  %38 = and i64 %37, 256
  %.not950 = icmp eq i64 %38, 0
  br i1 %.not950, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__barray_check_bounds.exit.8
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
  %.not951 = icmp eq i64 %42, 0
  br i1 %.not951, label %panic.i, label %cond_exit_20.9

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
  tail call void @___rxy(i64 %48, double 0x400921FB54442D18, double 0.000000e+00)
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
  %55 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %56 = load i64, ptr %55, align 4
  tail call void @___rxy(i64 %56, double 0x400921FB54442D18, double 0.000000e+00)
  %57 = load i64, ptr %5, align 4
  %58 = and i64 %57, 4
  %.not915 = icmp eq i64 %58, 0
  br i1 %.not915, label %panic.i821, label %__barray_mask_return.exit822

panic.i821:                                       ; preds = %__barray_mask_borrow.exit820
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit822:                     ; preds = %__barray_mask_borrow.exit820
  %59 = and i64 %57, -5
  store i64 %59, ptr %5, align 4
  store i64 %56, ptr %55, align 4
  %60 = load i64, ptr %5, align 4
  %61 = and i64 %60, 8
  %.not916 = icmp eq i64 %61, 0
  br i1 %.not916, label %__barray_mask_borrow.exit824, label %panic.i823

panic.i823:                                       ; preds = %__barray_mask_return.exit822
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit824:                     ; preds = %__barray_mask_return.exit822
  %62 = or disjoint i64 %60, 8
  store i64 %62, ptr %5, align 4
  %63 = getelementptr inbounds nuw i8, ptr %4, i64 24
  %64 = load i64, ptr %63, align 4
  tail call void @___rxy(i64 %64, double 0x400921FB54442D18, double 0.000000e+00)
  %65 = load i64, ptr %5, align 4
  %66 = and i64 %65, 8
  %.not917 = icmp eq i64 %66, 0
  br i1 %.not917, label %panic.i825, label %__barray_mask_return.exit826

panic.i825:                                       ; preds = %__barray_mask_borrow.exit824
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit826:                     ; preds = %__barray_mask_borrow.exit824
  %67 = and i64 %65, -9
  store i64 %67, ptr %5, align 4
  store i64 %64, ptr %63, align 4
  %68 = load i64, ptr %5, align 4
  %69 = and i64 %68, 512
  %.not918 = icmp eq i64 %69, 0
  br i1 %.not918, label %__barray_mask_borrow.exit828, label %panic.i827

panic.i827:                                       ; preds = %__barray_mask_return.exit826
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit828:                     ; preds = %__barray_mask_return.exit826
  %70 = or disjoint i64 %68, 512
  store i64 %70, ptr %5, align 4
  %71 = getelementptr inbounds nuw i8, ptr %4, i64 72
  %72 = load i64, ptr %71, align 4
  tail call void @___rxy(i64 %72, double 0x400921FB54442D18, double 0.000000e+00)
  %73 = load i64, ptr %5, align 4
  %74 = and i64 %73, 512
  %.not919 = icmp eq i64 %74, 0
  br i1 %.not919, label %panic.i829, label %__barray_mask_return.exit830

panic.i829:                                       ; preds = %__barray_mask_borrow.exit828
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit830:                     ; preds = %__barray_mask_borrow.exit828
  %75 = and i64 %73, -513
  store i64 %75, ptr %5, align 4
  store i64 %72, ptr %71, align 4
  %76 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"120.fca.2.insert", 0
  %77 = tail call ptr @heap_alloc(i64 240)
  %78 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %78, align 1
  br label %__barray_check_bounds.exit.i.i

79:                                               ; preds = %loop_body.i
  %80 = lshr i64 %.fca.2.extract82.i.i, 6
  %81 = getelementptr i64, ptr %.fca.1.extract81.i.i, i64 %80
  %82 = load i64, ptr %81, align 4
  %83 = and i64 %.fca.2.extract82.i.i, 63
  %84 = sub nuw nsw i64 64, %83
  %85 = lshr i64 -1, %84
  %86 = icmp eq i64 %83, 0
  %87 = select i1 %86, i64 0, i64 %85
  %88 = or i64 %82, %87
  store i64 %88, ptr %81, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract82.i.i, 9
  %89 = lshr i64 %last_valid.i.i.i, 6
  %90 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i.i, i64 %89
  %91 = load i64, ptr %90, align 4
  %92 = and i64 %last_valid.i.i.i, 63
  %93 = shl nsw i64 -2, %92
  %94 = icmp eq i64 %92, 63
  %95 = select i1 %94, i64 0, i64 %93
  %96 = or i64 %91, %95
  store i64 %96, ptr %90, align 4
  %reass.sub.i.i.i = sub nsw i64 %89, %80
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit", label %mask_block_ok.i.i.i

97:                                               ; preds = %mask_block_ok.i.i.i
  %98 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %79, %97
  %.02.i.i.i = phi i64 [ %98, %97 ], [ 0, %79 ]
  %gep.i.i.i = getelementptr i64, ptr %81, i64 %.02.i.i.i
  %99 = load i64, ptr %gep.i.i.i, align 4
  %100 = icmp eq i64 %99, -1
  br i1 %100, label %97, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit830
  %.fca.2.extract82.i187.i = phi i64 [ 0, %__barray_mask_return.exit830 ], [ %.fca.2.extract82.i.i, %loop_body.i ]
  %.fca.1.extract81.i186.i = phi ptr [ %5, %__barray_mask_return.exit830 ], [ %.fca.1.extract81.i.i, %loop_body.i ]
  %.fca.0.extract80.i185.i = phi ptr [ %4, %__barray_mask_return.exit830 ], [ %.fca.0.extract80.i.i, %loop_body.i ]
  %"396_0.sroa.15.0184.i" = phi i64 [ 0, %__barray_mask_return.exit830 ], [ %101, %loop_body.i ]
  %.pn165183.i = phi { { ptr, ptr, i64 }, i64 } [ %76, %__barray_mask_return.exit830 ], [ %116, %loop_body.i ]
  %101 = add nuw nsw i64 %"396_0.sroa.15.0184.i", 1
  %102 = add i64 %"396_0.sroa.15.0184.i", %.fca.2.extract82.i187.i
  %103 = lshr i64 %102, 6
  %104 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i186.i, i64 %103
  %105 = load i64, ptr %104, align 4
  %106 = and i64 %102, 63
  %107 = lshr i64 %105, %106
  %108 = trunc i64 %107 to i1
  br i1 %108, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %109 = shl nuw i64 1, %106
  %110 = xor i64 %109, %105
  store i64 %110, ptr %104, align 4
  %111 = getelementptr inbounds i64, ptr %.fca.0.extract80.i185.i, i64 %102
  %112 = load i64, ptr %111, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %112)
  tail call void @___qfree(i64 %112)
  %113 = load i64, ptr %78, align 4
  %114 = lshr i64 %113, %"396_0.sroa.15.0184.i"
  %115 = trunc i64 %114 to i1
  br i1 %115, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"461_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"461_054.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"461_054.fca.1.insert.i", i1 undef, 2
  %116 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, i64 %101, 1
  %117 = shl nuw nsw i64 1, %"396_0.sroa.15.0184.i"
  %118 = xor i64 %113, %117
  store i64 %118, ptr %78, align 4
  %119 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %77, i64 %"396_0.sroa.15.0184.i"
  store { i1, i64, i1 } %"461_054.fca.2.insert.i", ptr %119, align 4
  %120 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %120, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %120, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %120, 2
  %exitcond.not.i = icmp eq i64 %101, 10
  br i1 %exitcond.not.i, label %79, label %__barray_check_bounds.exit.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit": ; preds = %97, %79
  tail call void @heap_free(ptr %.fca.0.extract80.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract81.i.i)
  %121 = tail call ptr @heap_alloc(i64 320)
  %122 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %122, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(320) %121, i8 0, i64 320, i1 false)
  %123 = load i64, ptr %78, align 4
  %124 = and i64 %123, 1023
  store i64 %124, ptr %78, align 4
  %125 = icmp eq i64 %124, 0
  br i1 %125, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit"
  %126 = tail call ptr @heap_alloc(i64 240)
  %127 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %127, align 1
  br label %128

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).370.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

128:                                              ; preds = %__barray_check_none_borrowed.exit, %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit"
  %storemerge593926 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %136, %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit" ]
  %129 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %77, i64 %storemerge593926
  %130 = load { i1, i64, i1 }, ptr %129, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %130, 0
  br i1 %.fca.0.extract118.i, label %cond_252_case_1.i, label %cond_252_case_0.i

cond_252_case_0.i:                                ; preds = %128
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %130, 2
  br label %cond_exit_252.i

cond_252_case_1.i:                                ; preds = %128
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %130, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_252.i

cond_exit_252.i:                                  ; preds = %cond_252_case_0.i, %cond_252_case_1.i
  %"03.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_252_case_1.i ], [ undef, %cond_252_case_0.i ]
  %"03.sroa.6.0.i" = phi i1 [ undef, %cond_252_case_1.i ], [ %.fca.2.extract120.i, %cond_252_case_0.i ]
  %131 = load i64, ptr %122, align 4
  %132 = lshr i64 %131, %storemerge593926
  %133 = trunc i64 %132 to i1
  br i1 %133, label %panic.i.i832, label %cond_250_case_1.i

panic.i.i832:                                     ; preds = %cond_exit_252.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_250_case_1.i:                                ; preds = %cond_exit_252.i
  %"16.fca.1.insert.i" = insertvalue { i1, i64, i1 } %130, i64 %"03.sroa.3.0.i", 1
  %"16.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i", i1 %"03.sroa.6.0.i", 2
  %134 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i", 1
  %135 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %121, i64 %storemerge593926
  %.fca.2.0.extract.i = load i1, ptr %135, align 1
  store { i1, { i1, i64, i1 } } %134, ptr %135, align 4
  br i1 %.fca.2.0.extract.i, label %cond_249_case_1.i, label %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit"

cond_249_case_1.i:                                ; preds = %cond_250_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit": ; preds = %cond_250_case_1.i
  %136 = add nuw nsw i64 %storemerge593926, 1
  %137 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %126, i64 %storemerge593926
  store { i1, i64, i1 } %"16.fca.2.insert.i", ptr %137, align 4
  %exitcond933.not = icmp eq i64 %136, 10
  br i1 %exitcond933.not, label %mask_block_ok.i833, label %128

mask_block_ok.i833:                               ; preds = %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).256.exit"
  tail call void @heap_free(ptr nonnull %77)
  tail call void @heap_free(ptr nonnull %78)
  %138 = load i64, ptr %122, align 4
  %139 = and i64 %138, 1023
  store i64 %139, ptr %122, align 4
  %140 = icmp eq i64 %139, 0
  br i1 %140, label %__barray_check_none_borrowed.exit838, label %mask_block_err.i836

__barray_check_none_borrowed.exit838:             ; preds = %mask_block_ok.i833
  %141 = tail call ptr @heap_alloc(i64 240)
  %142 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %142, align 1
  %143 = load { i1, { i1, i64, i1 } }, ptr %121, align 4
  %144 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %143)
  %145 = extractvalue { { i1, i64, i1 } } %144, 0
  store { i1, i64, i1 } %145, ptr %141, align 4
  %146 = getelementptr i8, ptr %121, i64 32
  %147 = load { i1, { i1, i64, i1 } }, ptr %146, align 4
  %148 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %147)
  %149 = getelementptr inbounds nuw i8, ptr %141, i64 24
  %150 = extractvalue { { i1, i64, i1 } } %148, 0
  store { i1, i64, i1 } %150, ptr %149, align 4
  %151 = getelementptr i8, ptr %121, i64 64
  %152 = load { i1, { i1, i64, i1 } }, ptr %151, align 4
  %153 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %152)
  %154 = getelementptr inbounds nuw i8, ptr %141, i64 48
  %155 = extractvalue { { i1, i64, i1 } } %153, 0
  store { i1, i64, i1 } %155, ptr %154, align 4
  %156 = getelementptr i8, ptr %121, i64 96
  %157 = load { i1, { i1, i64, i1 } }, ptr %156, align 4
  %158 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %157)
  %159 = getelementptr inbounds nuw i8, ptr %141, i64 72
  %160 = extractvalue { { i1, i64, i1 } } %158, 0
  store { i1, i64, i1 } %160, ptr %159, align 4
  %161 = getelementptr i8, ptr %121, i64 128
  %162 = load { i1, { i1, i64, i1 } }, ptr %161, align 4
  %163 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %162)
  %164 = getelementptr inbounds nuw i8, ptr %141, i64 96
  %165 = extractvalue { { i1, i64, i1 } } %163, 0
  store { i1, i64, i1 } %165, ptr %164, align 4
  %166 = getelementptr i8, ptr %121, i64 160
  %167 = load { i1, { i1, i64, i1 } }, ptr %166, align 4
  %168 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %167)
  %169 = getelementptr inbounds nuw i8, ptr %141, i64 120
  %170 = extractvalue { { i1, i64, i1 } } %168, 0
  store { i1, i64, i1 } %170, ptr %169, align 4
  %171 = getelementptr i8, ptr %121, i64 192
  %172 = load { i1, { i1, i64, i1 } }, ptr %171, align 4
  %173 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %172)
  %174 = getelementptr inbounds nuw i8, ptr %141, i64 144
  %175 = extractvalue { { i1, i64, i1 } } %173, 0
  store { i1, i64, i1 } %175, ptr %174, align 4
  %176 = getelementptr i8, ptr %121, i64 224
  %177 = load { i1, { i1, i64, i1 } }, ptr %176, align 4
  %178 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %177)
  %179 = getelementptr inbounds nuw i8, ptr %141, i64 168
  %180 = extractvalue { { i1, i64, i1 } } %178, 0
  store { i1, i64, i1 } %180, ptr %179, align 4
  %181 = getelementptr i8, ptr %121, i64 256
  %182 = load { i1, { i1, i64, i1 } }, ptr %181, align 4
  %183 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %182)
  %184 = getelementptr inbounds nuw i8, ptr %141, i64 192
  %185 = extractvalue { { i1, i64, i1 } } %183, 0
  store { i1, i64, i1 } %185, ptr %184, align 4
  %186 = getelementptr i8, ptr %121, i64 288
  %187 = load { i1, { i1, i64, i1 } }, ptr %186, align 4
  %188 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).351"({ i1, { i1, i64, i1 } } %187)
  %189 = getelementptr inbounds nuw i8, ptr %141, i64 216
  %190 = extractvalue { { i1, i64, i1 } } %188, 0
  store { i1, i64, i1 } %190, ptr %189, align 4
  tail call void @heap_free(ptr nonnull %121)
  tail call void @heap_free(ptr nonnull %122)
  %191 = load i64, ptr %142, align 4
  %192 = trunc i64 %191 to i1
  br i1 %192, label %cond_exit_559, label %__barray_mask_borrow.exit849

mask_block_err.i836:                              ; preds = %mask_block_ok.i833
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

mask_block_err.i842:                              ; preds = %cond_exit_559.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit849:                     ; preds = %__barray_check_none_borrowed.exit838
  %193 = or disjoint i64 %191, 1
  store i64 %193, ptr %142, align 4
  %194 = load { i1, i64, i1 }, ptr %141, align 4
  %.fca.0.extract491 = extractvalue { i1, i64, i1 } %194, 0
  br i1 %.fca.0.extract491, label %cond_582_case_1, label %cond_exit_559

cond_exit_559:                                    ; preds = %cond_582_case_1, %__barray_mask_borrow.exit849, %__barray_check_none_borrowed.exit838
  %195 = load i64, ptr %142, align 4
  %196 = and i64 %195, 2
  %.not952 = icmp eq i64 %196, 0
  br i1 %.not952, label %__barray_mask_borrow.exit849.1, label %cond_exit_559.1

__barray_mask_borrow.exit849.1:                   ; preds = %cond_exit_559
  %197 = or disjoint i64 %195, 2
  store i64 %197, ptr %142, align 4
  %198 = getelementptr inbounds nuw i8, ptr %141, i64 24
  %199 = load { i1, i64, i1 }, ptr %198, align 4
  %.fca.0.extract491.1 = extractvalue { i1, i64, i1 } %199, 0
  br i1 %.fca.0.extract491.1, label %cond_582_case_1.1, label %cond_exit_559.1

cond_582_case_1.1:                                ; preds = %__barray_mask_borrow.exit849.1
  %.fca.1.extract492.1 = extractvalue { i1, i64, i1 } %199, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.1)
  br label %cond_exit_559.1

cond_exit_559.1:                                  ; preds = %cond_582_case_1.1, %__barray_mask_borrow.exit849.1, %cond_exit_559
  %200 = load i64, ptr %142, align 4
  %201 = and i64 %200, 4
  %.not953 = icmp eq i64 %201, 0
  br i1 %.not953, label %__barray_mask_borrow.exit849.2, label %cond_exit_559.2

__barray_mask_borrow.exit849.2:                   ; preds = %cond_exit_559.1
  %202 = or disjoint i64 %200, 4
  store i64 %202, ptr %142, align 4
  %203 = getelementptr inbounds nuw i8, ptr %141, i64 48
  %204 = load { i1, i64, i1 }, ptr %203, align 4
  %.fca.0.extract491.2 = extractvalue { i1, i64, i1 } %204, 0
  br i1 %.fca.0.extract491.2, label %cond_582_case_1.2, label %cond_exit_559.2

cond_582_case_1.2:                                ; preds = %__barray_mask_borrow.exit849.2
  %.fca.1.extract492.2 = extractvalue { i1, i64, i1 } %204, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.2)
  br label %cond_exit_559.2

cond_exit_559.2:                                  ; preds = %cond_582_case_1.2, %__barray_mask_borrow.exit849.2, %cond_exit_559.1
  %205 = load i64, ptr %142, align 4
  %206 = and i64 %205, 8
  %.not954 = icmp eq i64 %206, 0
  br i1 %.not954, label %__barray_mask_borrow.exit849.3, label %cond_exit_559.3

__barray_mask_borrow.exit849.3:                   ; preds = %cond_exit_559.2
  %207 = or disjoint i64 %205, 8
  store i64 %207, ptr %142, align 4
  %208 = getelementptr inbounds nuw i8, ptr %141, i64 72
  %209 = load { i1, i64, i1 }, ptr %208, align 4
  %.fca.0.extract491.3 = extractvalue { i1, i64, i1 } %209, 0
  br i1 %.fca.0.extract491.3, label %cond_582_case_1.3, label %cond_exit_559.3

cond_582_case_1.3:                                ; preds = %__barray_mask_borrow.exit849.3
  %.fca.1.extract492.3 = extractvalue { i1, i64, i1 } %209, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.3)
  br label %cond_exit_559.3

cond_exit_559.3:                                  ; preds = %cond_582_case_1.3, %__barray_mask_borrow.exit849.3, %cond_exit_559.2
  %210 = load i64, ptr %142, align 4
  %211 = and i64 %210, 16
  %.not955 = icmp eq i64 %211, 0
  br i1 %.not955, label %__barray_mask_borrow.exit849.4, label %cond_exit_559.4

__barray_mask_borrow.exit849.4:                   ; preds = %cond_exit_559.3
  %212 = or disjoint i64 %210, 16
  store i64 %212, ptr %142, align 4
  %213 = getelementptr inbounds nuw i8, ptr %141, i64 96
  %214 = load { i1, i64, i1 }, ptr %213, align 4
  %.fca.0.extract491.4 = extractvalue { i1, i64, i1 } %214, 0
  br i1 %.fca.0.extract491.4, label %cond_582_case_1.4, label %cond_exit_559.4

cond_582_case_1.4:                                ; preds = %__barray_mask_borrow.exit849.4
  %.fca.1.extract492.4 = extractvalue { i1, i64, i1 } %214, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.4)
  br label %cond_exit_559.4

cond_exit_559.4:                                  ; preds = %cond_582_case_1.4, %__barray_mask_borrow.exit849.4, %cond_exit_559.3
  %215 = load i64, ptr %142, align 4
  %216 = and i64 %215, 32
  %.not956 = icmp eq i64 %216, 0
  br i1 %.not956, label %__barray_mask_borrow.exit849.5, label %cond_exit_559.5

__barray_mask_borrow.exit849.5:                   ; preds = %cond_exit_559.4
  %217 = or disjoint i64 %215, 32
  store i64 %217, ptr %142, align 4
  %218 = getelementptr inbounds nuw i8, ptr %141, i64 120
  %219 = load { i1, i64, i1 }, ptr %218, align 4
  %.fca.0.extract491.5 = extractvalue { i1, i64, i1 } %219, 0
  br i1 %.fca.0.extract491.5, label %cond_582_case_1.5, label %cond_exit_559.5

cond_582_case_1.5:                                ; preds = %__barray_mask_borrow.exit849.5
  %.fca.1.extract492.5 = extractvalue { i1, i64, i1 } %219, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.5)
  br label %cond_exit_559.5

cond_exit_559.5:                                  ; preds = %cond_582_case_1.5, %__barray_mask_borrow.exit849.5, %cond_exit_559.4
  %220 = load i64, ptr %142, align 4
  %221 = and i64 %220, 64
  %.not957 = icmp eq i64 %221, 0
  br i1 %.not957, label %__barray_mask_borrow.exit849.6, label %cond_exit_559.6

__barray_mask_borrow.exit849.6:                   ; preds = %cond_exit_559.5
  %222 = or disjoint i64 %220, 64
  store i64 %222, ptr %142, align 4
  %223 = getelementptr inbounds nuw i8, ptr %141, i64 144
  %224 = load { i1, i64, i1 }, ptr %223, align 4
  %.fca.0.extract491.6 = extractvalue { i1, i64, i1 } %224, 0
  br i1 %.fca.0.extract491.6, label %cond_582_case_1.6, label %cond_exit_559.6

cond_582_case_1.6:                                ; preds = %__barray_mask_borrow.exit849.6
  %.fca.1.extract492.6 = extractvalue { i1, i64, i1 } %224, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.6)
  br label %cond_exit_559.6

cond_exit_559.6:                                  ; preds = %cond_582_case_1.6, %__barray_mask_borrow.exit849.6, %cond_exit_559.5
  %225 = load i64, ptr %142, align 4
  %226 = and i64 %225, 128
  %.not958 = icmp eq i64 %226, 0
  br i1 %.not958, label %__barray_mask_borrow.exit849.7, label %cond_exit_559.7

__barray_mask_borrow.exit849.7:                   ; preds = %cond_exit_559.6
  %227 = or disjoint i64 %225, 128
  store i64 %227, ptr %142, align 4
  %228 = getelementptr inbounds nuw i8, ptr %141, i64 168
  %229 = load { i1, i64, i1 }, ptr %228, align 4
  %.fca.0.extract491.7 = extractvalue { i1, i64, i1 } %229, 0
  br i1 %.fca.0.extract491.7, label %cond_582_case_1.7, label %cond_exit_559.7

cond_582_case_1.7:                                ; preds = %__barray_mask_borrow.exit849.7
  %.fca.1.extract492.7 = extractvalue { i1, i64, i1 } %229, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.7)
  br label %cond_exit_559.7

cond_exit_559.7:                                  ; preds = %cond_582_case_1.7, %__barray_mask_borrow.exit849.7, %cond_exit_559.6
  %230 = load i64, ptr %142, align 4
  %231 = and i64 %230, 256
  %.not959 = icmp eq i64 %231, 0
  br i1 %.not959, label %__barray_mask_borrow.exit849.8, label %cond_exit_559.8

__barray_mask_borrow.exit849.8:                   ; preds = %cond_exit_559.7
  %232 = or disjoint i64 %230, 256
  store i64 %232, ptr %142, align 4
  %233 = getelementptr inbounds nuw i8, ptr %141, i64 192
  %234 = load { i1, i64, i1 }, ptr %233, align 4
  %.fca.0.extract491.8 = extractvalue { i1, i64, i1 } %234, 0
  br i1 %.fca.0.extract491.8, label %cond_582_case_1.8, label %cond_exit_559.8

cond_582_case_1.8:                                ; preds = %__barray_mask_borrow.exit849.8
  %.fca.1.extract492.8 = extractvalue { i1, i64, i1 } %234, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.8)
  br label %cond_exit_559.8

cond_exit_559.8:                                  ; preds = %cond_582_case_1.8, %__barray_mask_borrow.exit849.8, %cond_exit_559.7
  %235 = load i64, ptr %142, align 4
  %236 = and i64 %235, 512
  %.not960 = icmp eq i64 %236, 0
  br i1 %.not960, label %__barray_mask_borrow.exit849.9, label %cond_exit_559.9

__barray_mask_borrow.exit849.9:                   ; preds = %cond_exit_559.8
  %237 = or disjoint i64 %235, 512
  store i64 %237, ptr %142, align 4
  %238 = getelementptr inbounds nuw i8, ptr %141, i64 216
  %239 = load { i1, i64, i1 }, ptr %238, align 4
  %.fca.0.extract491.9 = extractvalue { i1, i64, i1 } %239, 0
  br i1 %.fca.0.extract491.9, label %cond_582_case_1.9, label %cond_exit_559.9

cond_582_case_1.9:                                ; preds = %__barray_mask_borrow.exit849.9
  %.fca.1.extract492.9 = extractvalue { i1, i64, i1 } %239, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492.9)
  br label %cond_exit_559.9

cond_exit_559.9:                                  ; preds = %cond_582_case_1.9, %__barray_mask_borrow.exit849.9, %cond_exit_559.8
  %240 = load i64, ptr %142, align 4
  %241 = or i64 %240, -1024
  store i64 %241, ptr %142, align 4
  %242 = icmp eq i64 %241, -1
  br i1 %242, label %loop_out130, label %mask_block_err.i842

loop_out130:                                      ; preds = %cond_exit_559.9
  tail call void @heap_free(ptr nonnull %141)
  tail call void @heap_free(ptr nonnull %142)
  %243 = load i64, ptr %127, align 4
  %244 = and i64 %243, 1023
  store i64 %244, ptr %127, align 4
  %245 = icmp eq i64 %244, 0
  br i1 %245, label %__barray_check_none_borrowed.exit855, label %mask_block_err.i853

__barray_check_none_borrowed.exit855:             ; preds = %loop_out130
  %246 = tail call ptr @heap_alloc(i64 10)
  %247 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %247, align 1
  %248 = load { i1, i64, i1 }, ptr %126, align 4
  %249 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %248)
  %250 = extractvalue { i1 } %249, 0
  store i1 %250, ptr %246, align 1
  %251 = getelementptr inbounds nuw i8, ptr %126, i64 24
  %252 = load { i1, i64, i1 }, ptr %251, align 4
  %253 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %252)
  %254 = getelementptr inbounds nuw i8, ptr %246, i64 1
  %255 = extractvalue { i1 } %253, 0
  store i1 %255, ptr %254, align 1
  %256 = getelementptr inbounds nuw i8, ptr %126, i64 48
  %257 = load { i1, i64, i1 }, ptr %256, align 4
  %258 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %257)
  %259 = getelementptr inbounds nuw i8, ptr %246, i64 2
  %260 = extractvalue { i1 } %258, 0
  store i1 %260, ptr %259, align 1
  %261 = getelementptr inbounds nuw i8, ptr %126, i64 72
  %262 = load { i1, i64, i1 }, ptr %261, align 4
  %263 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %262)
  %264 = getelementptr inbounds nuw i8, ptr %246, i64 3
  %265 = extractvalue { i1 } %263, 0
  store i1 %265, ptr %264, align 1
  %266 = getelementptr inbounds nuw i8, ptr %126, i64 96
  %267 = load { i1, i64, i1 }, ptr %266, align 4
  %268 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %267)
  %269 = getelementptr inbounds nuw i8, ptr %246, i64 4
  %270 = extractvalue { i1 } %268, 0
  store i1 %270, ptr %269, align 1
  %271 = getelementptr inbounds nuw i8, ptr %126, i64 120
  %272 = load { i1, i64, i1 }, ptr %271, align 4
  %273 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %272)
  %274 = getelementptr inbounds nuw i8, ptr %246, i64 5
  %275 = extractvalue { i1 } %273, 0
  store i1 %275, ptr %274, align 1
  %276 = getelementptr inbounds nuw i8, ptr %126, i64 144
  %277 = load { i1, i64, i1 }, ptr %276, align 4
  %278 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %277)
  %279 = getelementptr inbounds nuw i8, ptr %246, i64 6
  %280 = extractvalue { i1 } %278, 0
  store i1 %280, ptr %279, align 1
  %281 = getelementptr inbounds nuw i8, ptr %126, i64 168
  %282 = load { i1, i64, i1 }, ptr %281, align 4
  %283 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %282)
  %284 = getelementptr inbounds nuw i8, ptr %246, i64 7
  %285 = extractvalue { i1 } %283, 0
  store i1 %285, ptr %284, align 1
  %286 = getelementptr inbounds nuw i8, ptr %126, i64 192
  %287 = load { i1, i64, i1 }, ptr %286, align 4
  %288 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %287)
  %289 = getelementptr inbounds nuw i8, ptr %246, i64 8
  %290 = extractvalue { i1 } %288, 0
  store i1 %290, ptr %289, align 1
  %291 = getelementptr inbounds nuw i8, ptr %126, i64 216
  %292 = load { i1, i64, i1 }, ptr %291, align 4
  %293 = tail call { i1 } @__hugr__.array.__read_bool.3.272({ i1, i64, i1 } %292)
  %294 = getelementptr inbounds nuw i8, ptr %246, i64 9
  %295 = extractvalue { i1 } %293, 0
  store i1 %295, ptr %294, align 1
  tail call void @heap_free(ptr nonnull %126)
  tail call void @heap_free(ptr nonnull %127)
  %296 = load i64, ptr %247, align 4
  %297 = and i64 %296, 1023
  store i64 %297, ptr %247, align 4
  %298 = icmp eq i64 %297, 0
  br i1 %298, label %__barray_check_none_borrowed.exit861, label %mask_block_err.i859

mask_block_err.i853:                              ; preds = %loop_out130
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_582_case_1:                                  ; preds = %__barray_mask_borrow.exit849
  %.fca.1.extract492 = extractvalue { i1, i64, i1 } %194, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract492)
  br label %cond_exit_559

__barray_check_none_borrowed.exit861:             ; preds = %__barray_check_none_borrowed.exit855
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %299 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %299, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %246, ptr %arr_ptr, align 8
  store ptr %299, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  br label %__barray_check_bounds.exit869

mask_block_err.i859:                              ; preds = %__barray_check_none_borrowed.exit855
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit869:                    ; preds = %cond_exit_95.1, %__barray_check_none_borrowed.exit861
  %"90_0.sroa.0.0930" = phi i64 [ 0, %__barray_check_none_borrowed.exit861 ], [ %316, %cond_exit_95.1 ]
  %300 = lshr i64 %"90_0.sroa.0.0930", 6
  %301 = getelementptr inbounds nuw i64, ptr %3, i64 %300
  %302 = load i64, ptr %301, align 4
  %303 = and i64 %"90_0.sroa.0.0930", 62
  %304 = lshr i64 %302, %303
  %305 = trunc i64 %304 to i1
  br i1 %305, label %cond_exit_95, label %panic.i870

panic.i870:                                       ; preds = %cond_exit_95, %__barray_check_bounds.exit869
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_95:                                     ; preds = %__barray_check_bounds.exit869
  %306 = or disjoint i64 %"90_0.sroa.0.0930", 1
  %307 = shl nuw nsw i64 1, %303
  %308 = xor i64 %302, %307
  store i64 %308, ptr %301, align 4
  %309 = getelementptr inbounds nuw i64, ptr %2, i64 %"90_0.sroa.0.0930"
  store i64 %"90_0.sroa.0.0930", ptr %309, align 4
  %310 = lshr i64 %"90_0.sroa.0.0930", 6
  %311 = getelementptr inbounds nuw i64, ptr %3, i64 %310
  %312 = load i64, ptr %311, align 4
  %313 = and i64 %306, 63
  %314 = lshr i64 %312, %313
  %315 = trunc i64 %314 to i1
  br i1 %315, label %cond_exit_95.1, label %panic.i870

cond_exit_95.1:                                   ; preds = %cond_exit_95
  %316 = add nuw nsw i64 %"90_0.sroa.0.0930", 2
  %317 = shl nuw i64 1, %313
  %318 = xor i64 %312, %317
  store i64 %318, ptr %311, align 4
  %319 = getelementptr inbounds nuw i64, ptr %2, i64 %306
  store i64 %306, ptr %319, align 4
  %exitcond936.not.1 = icmp eq i64 %316, 100
  br i1 %exitcond936.not.1, label %loop_out200, label %__barray_check_bounds.exit869

loop_out200:                                      ; preds = %cond_exit_95.1
  %320 = getelementptr i8, ptr %3, i64 8
  %321 = load i64, ptr %320, align 4
  %322 = and i64 %321, 68719476735
  store i64 %322, ptr %320, align 4
  %323 = load i64, ptr %3, align 4
  %324 = icmp eq i64 %323, 0
  %325 = icmp eq i64 %322, 0
  %or.cond = select i1 %324, i1 %325, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit877, label %mask_block_err.i875

__barray_check_none_borrowed.exit877:             ; preds = %loop_out200
  %326 = call ptr @heap_alloc(i64 800)
  %327 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %327, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %326, ptr noundef nonnull align 1 dereferenceable(800) %2, i64 800, i1 false)
  call void @heap_free(ptr nonnull %326)
  %328 = load i64, ptr %320, align 4
  %329 = and i64 %328, 68719476735
  store i64 %329, ptr %320, align 4
  %330 = load i64, ptr %3, align 4
  %331 = icmp eq i64 %330, 0
  %332 = icmp eq i64 %329, 0
  %or.cond939 = select i1 %331, i1 %332, i1 false
  br i1 %or.cond939, label %__barray_check_none_borrowed.exit883, label %mask_block_err.i881

mask_block_err.i875:                              ; preds = %loop_out200
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit883:             ; preds = %__barray_check_none_borrowed.exit877
  %out_arr_alloca276 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr278 = getelementptr inbounds nuw i8, ptr %out_arr_alloca276, i64 4
  %arr_ptr279 = getelementptr inbounds nuw i8, ptr %out_arr_alloca276, i64 8
  %mask_ptr280 = getelementptr inbounds nuw i8, ptr %out_arr_alloca276, i64 16
  %333 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %333, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca276, align 8
  store i32 1, ptr %y_ptr278, align 4
  store ptr %2, ptr %arr_ptr279, align 8
  store ptr %333, ptr %mask_ptr280, align 8
  call void @print_int_arr(ptr nonnull @res_is.F21393DB.0, i64 14, ptr nonnull %out_arr_alloca276)
  br label %__barray_check_bounds.exit891

mask_block_err.i881:                              ; preds = %__barray_check_none_borrowed.exit877
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit891:                    ; preds = %cond_exit_130, %__barray_check_none_borrowed.exit883
  %"125_0.sroa.0.0932" = phi i64 [ 0, %__barray_check_none_borrowed.exit883 ], [ %342, %cond_exit_130 ]
  %334 = lshr i64 %"125_0.sroa.0.0932", 6
  %335 = getelementptr inbounds nuw i64, ptr %1, i64 %334
  %336 = load i64, ptr %335, align 4
  %337 = and i64 %"125_0.sroa.0.0932", 63
  %338 = lshr i64 %336, %337
  %339 = trunc i64 %338 to i1
  br i1 %339, label %cond_exit_130, label %panic.i892

panic.i892:                                       ; preds = %__barray_check_bounds.exit891
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_130:                                    ; preds = %__barray_check_bounds.exit891
  %340 = uitofp nneg i64 %"125_0.sroa.0.0932" to double
  %341 = fmul double %340, 6.250000e-02
  %342 = add nuw nsw i64 %"125_0.sroa.0.0932", 1
  %343 = shl nuw i64 1, %337
  %344 = xor i64 %336, %343
  store i64 %344, ptr %335, align 4
  %345 = getelementptr inbounds nuw double, ptr %0, i64 %"125_0.sroa.0.0932"
  store double %341, ptr %345, align 8
  %exitcond937.not = icmp eq i64 %342, 100
  br i1 %exitcond937.not, label %loop_out284, label %__barray_check_bounds.exit891

loop_out284:                                      ; preds = %cond_exit_130
  %346 = getelementptr i8, ptr %1, i64 8
  %347 = load i64, ptr %346, align 4
  %348 = and i64 %347, 68719476735
  store i64 %348, ptr %346, align 4
  %349 = load i64, ptr %1, align 4
  %350 = icmp eq i64 %349, 0
  %351 = icmp eq i64 %348, 0
  %or.cond940 = select i1 %350, i1 %351, i1 false
  br i1 %or.cond940, label %__barray_check_none_borrowed.exit899, label %mask_block_err.i897

__barray_check_none_borrowed.exit899:             ; preds = %loop_out284
  %352 = call ptr @heap_alloc(i64 800)
  %353 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %353, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %352, ptr noundef nonnull align 1 dereferenceable(800) %0, i64 800, i1 false)
  call void @heap_free(ptr nonnull %352)
  %354 = load i64, ptr %346, align 4
  %355 = and i64 %354, 68719476735
  store i64 %355, ptr %346, align 4
  %356 = load i64, ptr %1, align 4
  %357 = icmp eq i64 %356, 0
  %358 = icmp eq i64 %355, 0
  %or.cond941 = select i1 %357, i1 %358, i1 false
  br i1 %or.cond941, label %__barray_check_none_borrowed.exit905, label %mask_block_err.i903

mask_block_err.i897:                              ; preds = %loop_out284
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit905:             ; preds = %__barray_check_none_borrowed.exit899
  %out_arr_alloca363 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr365 = getelementptr inbounds nuw i8, ptr %out_arr_alloca363, i64 4
  %arr_ptr366 = getelementptr inbounds nuw i8, ptr %out_arr_alloca363, i64 8
  %mask_ptr367 = getelementptr inbounds nuw i8, ptr %out_arr_alloca363, i64 16
  %359 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %359, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca363, align 8
  store i32 1, ptr %y_ptr365, align 4
  store ptr %0, ptr %arr_ptr366, align 8
  store ptr %359, ptr %mask_ptr367, align 8
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

declare void @___rxy(i64, double, double) local_unnamed_addr

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
