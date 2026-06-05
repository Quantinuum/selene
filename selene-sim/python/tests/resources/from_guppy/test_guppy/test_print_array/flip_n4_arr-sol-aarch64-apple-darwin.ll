; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_cs.46C3C4B5.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:cs"
@res_is.F21393DB.0 = private constant [15 x i8] c"\0EUSER:INTARR:is"
@res_fs.CBD4AF54.0 = private constant [17 x i8] c"\10USER:FLOATARR:fs"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 800)
  %1 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %1, i8 -1, i64 16, i1 false)
  %2 = tail call ptr @heap_alloc(i64 800)
  %3 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %3, i8 -1, i64 16, i1 false)
  %4 = tail call ptr @heap_alloc(i64 10)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  %6 = tail call ptr @heap_alloc(i64 80)
  %7 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %7, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit

cond_515_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.488.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %8 = load i64, ptr %7, align 4
  %9 = trunc i64 %8 to i1
  br i1 %9, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_sol_qalloc.488.exit.8, %__hugr__.__tk2_sol_qalloc.488.exit.7, %__hugr__.__tk2_sol_qalloc.488.exit.6, %__hugr__.__tk2_sol_qalloc.488.exit.5, %__hugr__.__tk2_sol_qalloc.488.exit.4, %__hugr__.__tk2_sol_qalloc.488.exit.3, %__hugr__.__tk2_sol_qalloc.488.exit.2, %__hugr__.__tk2_sol_qalloc.488.exit.1, %__hugr__.__tk2_sol_qalloc.488.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_sol_qalloc.488.exit
  %10 = and i64 %8, -2
  store i64 %10, ptr %7, align 4
  store i64 %qalloc.i, ptr %6, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit.1

__hugr__.__tk2_sol_qalloc.488.exit.1:             ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %11 = load i64, ptr %7, align 4
  %12 = and i64 %11, 2
  %.not940 = icmp eq i64 %12, 0
  br i1 %.not940, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.488.exit.1
  %13 = and i64 %11, -3
  store i64 %13, ptr %7, align 4
  %14 = getelementptr inbounds nuw i8, ptr %6, i64 8
  store i64 %qalloc.i.1, ptr %14, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit.2

__hugr__.__tk2_sol_qalloc.488.exit.2:             ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %15 = load i64, ptr %7, align 4
  %16 = and i64 %15, 4
  %.not941 = icmp eq i64 %16, 0
  br i1 %.not941, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_sol_qalloc.488.exit.2
  %17 = and i64 %15, -5
  store i64 %17, ptr %7, align 4
  %18 = getelementptr inbounds nuw i8, ptr %6, i64 16
  store i64 %qalloc.i.2, ptr %18, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit.3

__hugr__.__tk2_sol_qalloc.488.exit.3:             ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %19 = load i64, ptr %7, align 4
  %20 = and i64 %19, 8
  %.not942 = icmp eq i64 %20, 0
  br i1 %.not942, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_sol_qalloc.488.exit.3
  %21 = and i64 %19, -9
  store i64 %21, ptr %7, align 4
  %22 = getelementptr inbounds nuw i8, ptr %6, i64 24
  store i64 %qalloc.i.3, ptr %22, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit.4

__hugr__.__tk2_sol_qalloc.488.exit.4:             ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %23 = load i64, ptr %7, align 4
  %24 = and i64 %23, 16
  %.not943 = icmp eq i64 %24, 0
  br i1 %.not943, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_sol_qalloc.488.exit.4
  %25 = and i64 %23, -17
  store i64 %25, ptr %7, align 4
  %26 = getelementptr inbounds nuw i8, ptr %6, i64 32
  store i64 %qalloc.i.4, ptr %26, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit.5

__hugr__.__tk2_sol_qalloc.488.exit.5:             ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %27 = load i64, ptr %7, align 4
  %28 = and i64 %27, 32
  %.not944 = icmp eq i64 %28, 0
  br i1 %.not944, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_sol_qalloc.488.exit.5
  %29 = and i64 %27, -33
  store i64 %29, ptr %7, align 4
  %30 = getelementptr inbounds nuw i8, ptr %6, i64 40
  store i64 %qalloc.i.5, ptr %30, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit.6

__hugr__.__tk2_sol_qalloc.488.exit.6:             ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %31 = load i64, ptr %7, align 4
  %32 = and i64 %31, 64
  %.not945 = icmp eq i64 %32, 0
  br i1 %.not945, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_sol_qalloc.488.exit.6
  %33 = and i64 %31, -65
  store i64 %33, ptr %7, align 4
  %34 = getelementptr inbounds nuw i8, ptr %6, i64 48
  store i64 %qalloc.i.6, ptr %34, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit.7

__hugr__.__tk2_sol_qalloc.488.exit.7:             ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %35 = load i64, ptr %7, align 4
  %36 = and i64 %35, 128
  %.not946 = icmp eq i64 %36, 0
  br i1 %.not946, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__hugr__.__tk2_sol_qalloc.488.exit.7
  %37 = and i64 %35, -129
  store i64 %37, ptr %7, align 4
  %38 = getelementptr inbounds nuw i8, ptr %6, i64 56
  store i64 %qalloc.i.7, ptr %38, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_515_case_0.i, label %__hugr__.__tk2_sol_qalloc.488.exit.8

__hugr__.__tk2_sol_qalloc.488.exit.8:             ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %39 = load i64, ptr %7, align 4
  %40 = and i64 %39, 256
  %.not947 = icmp eq i64 %40, 0
  br i1 %.not947, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__hugr__.__tk2_sol_qalloc.488.exit.8
  %41 = and i64 %39, -257
  store i64 %41, ptr %7, align 4
  %42 = getelementptr inbounds nuw i8, ptr %6, i64 64
  store i64 %qalloc.i.8, ptr %42, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_515_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %43 = load i64, ptr %7, align 4
  %44 = and i64 %43, 512
  %.not948 = icmp eq i64 %44, 0
  br i1 %.not948, label %panic.i, label %cond_exit_20.9

cond_exit_20.9:                                   ; preds = %__barray_check_bounds.exit.9
  %45 = and i64 %43, -513
  store i64 %45, ptr %7, align 4
  %46 = getelementptr inbounds nuw i8, ptr %6, i64 72
  store i64 %qalloc.i.9, ptr %46, align 4
  %"121.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %6, 0
  %"121.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"121.fca.0.insert", ptr %7, 1
  %"121.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"121.fca.1.insert", i64 0, 2
  %47 = load i64, ptr %7, align 4
  %48 = trunc i64 %47 to i1
  br i1 %48, label %panic.i819, label %__barray_mask_borrow.exit

panic.i819:                                       ; preds = %cond_exit_20.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.9
  %49 = or disjoint i64 %47, 1
  store i64 %49, ptr %7, align 4
  %50 = load i64, ptr %6, align 4
  tail call void @___rp(i64 %50, double 0x400921FB54442D18, double 0.000000e+00)
  %51 = load i64, ptr %7, align 4
  %52 = trunc i64 %51 to i1
  br i1 %52, label %__barray_mask_return.exit821, label %panic.i820

panic.i820:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit821:                     ; preds = %__barray_mask_borrow.exit
  %53 = and i64 %51, -2
  store i64 %53, ptr %7, align 4
  store i64 %50, ptr %6, align 4
  %54 = load i64, ptr %7, align 4
  %55 = and i64 %54, 4
  %.not = icmp eq i64 %55, 0
  br i1 %.not, label %__barray_mask_borrow.exit823, label %panic.i822

panic.i822:                                       ; preds = %__barray_mask_return.exit821
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit823:                     ; preds = %__barray_mask_return.exit821
  %56 = or disjoint i64 %54, 4
  store i64 %56, ptr %7, align 4
  %57 = load i64, ptr %18, align 4
  tail call void @___rp(i64 %57, double 0x400921FB54442D18, double 0.000000e+00)
  %58 = load i64, ptr %7, align 4
  %59 = and i64 %58, 4
  %.not917 = icmp eq i64 %59, 0
  br i1 %.not917, label %panic.i824, label %__barray_mask_return.exit825

panic.i824:                                       ; preds = %__barray_mask_borrow.exit823
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit825:                     ; preds = %__barray_mask_borrow.exit823
  %60 = and i64 %58, -5
  store i64 %60, ptr %7, align 4
  store i64 %57, ptr %18, align 4
  %61 = load i64, ptr %7, align 4
  %62 = and i64 %61, 8
  %.not918 = icmp eq i64 %62, 0
  br i1 %.not918, label %__barray_mask_borrow.exit827, label %panic.i826

panic.i826:                                       ; preds = %__barray_mask_return.exit825
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit827:                     ; preds = %__barray_mask_return.exit825
  %63 = or disjoint i64 %61, 8
  store i64 %63, ptr %7, align 4
  %64 = load i64, ptr %22, align 4
  tail call void @___rp(i64 %64, double 0x400921FB54442D18, double 0.000000e+00)
  %65 = load i64, ptr %7, align 4
  %66 = and i64 %65, 8
  %.not919 = icmp eq i64 %66, 0
  br i1 %.not919, label %panic.i828, label %__barray_mask_return.exit829

panic.i828:                                       ; preds = %__barray_mask_borrow.exit827
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit829:                     ; preds = %__barray_mask_borrow.exit827
  %67 = and i64 %65, -9
  store i64 %67, ptr %7, align 4
  store i64 %64, ptr %22, align 4
  %68 = load i64, ptr %7, align 4
  %69 = and i64 %68, 512
  %.not920 = icmp eq i64 %69, 0
  br i1 %.not920, label %__barray_mask_borrow.exit831, label %panic.i830

panic.i830:                                       ; preds = %__barray_mask_return.exit829
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit831:                     ; preds = %__barray_mask_return.exit829
  %70 = or disjoint i64 %68, 512
  store i64 %70, ptr %7, align 4
  %71 = load i64, ptr %46, align 4
  tail call void @___rp(i64 %71, double 0x400921FB54442D18, double 0.000000e+00)
  %72 = load i64, ptr %7, align 4
  %73 = and i64 %72, 512
  %.not921 = icmp eq i64 %73, 0
  br i1 %.not921, label %panic.i832, label %__barray_mask_return.exit833

panic.i832:                                       ; preds = %__barray_mask_borrow.exit831
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit833:                     ; preds = %__barray_mask_borrow.exit831
  %74 = and i64 %72, -513
  store i64 %74, ptr %7, align 4
  store i64 %71, ptr %46, align 4
  %75 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"121.fca.2.insert", 0
  %76 = tail call ptr @heap_alloc(i64 80)
  %77 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %77, align 1
  br label %__barray_check_bounds.exit.i.i

78:                                               ; preds = %loop_body.i
  %79 = lshr i64 %.fca.2.extract.i.i, 6
  %80 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %79
  %81 = load i64, ptr %80, align 4
  %82 = and i64 %.fca.2.extract.i.i, 63
  %83 = sub nuw nsw i64 64, %82
  %84 = lshr i64 -1, %83
  %85 = icmp eq i64 %82, 0
  %86 = select i1 %85, i64 0, i64 %84
  %87 = or i64 %81, %86
  store i64 %87, ptr %80, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %88 = lshr i64 %last_valid.i.i.i, 6
  %89 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %88
  %90 = load i64, ptr %89, align 4
  %91 = and i64 %last_valid.i.i.i, 63
  %92 = shl nsw i64 -2, %91
  %93 = icmp eq i64 %91, 63
  %94 = select i1 %93, i64 0, i64 %92
  %95 = or i64 %90, %94
  store i64 %95, ptr %89, align 4
  %reass.sub.i.i.i = sub nsw i64 %88, %79
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit", label %mask_block_ok.i.i.i

96:                                               ; preds = %mask_block_ok.i.i.i
  %97 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %78, %96
  %.02.i.i.i = phi i64 [ %97, %96 ], [ 0, %78 ]
  %gep.i.i.i = getelementptr i64, ptr %80, i64 %.02.i.i.i
  %98 = load i64, ptr %gep.i.i.i, align 4
  %99 = icmp eq i64 %98, -1
  br i1 %99, label %96, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit833
  %.fca.2.extract.i181.i = phi i64 [ 0, %__barray_mask_return.exit833 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %7, %__barray_mask_return.exit833 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %6, %__barray_mask_return.exit833 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"282_0.sroa.15.0178.i" = phi i64 [ 0, %__barray_mask_return.exit833 ], [ %100, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %75, %__barray_mask_return.exit833 ], [ %115, %loop_body.i ]
  %100 = add nuw nsw i64 %"282_0.sroa.15.0178.i", 1
  %101 = add i64 %"282_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %102 = lshr i64 %101, 6
  %103 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %102
  %104 = load i64, ptr %103, align 4
  %105 = and i64 %101, 63
  %106 = lshr i64 %104, %105
  %107 = trunc i64 %106 to i1
  br i1 %107, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %108 = shl nuw i64 1, %105
  %109 = xor i64 %108, %104
  store i64 %109, ptr %103, align 4
  %110 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %101
  %111 = load i64, ptr %110, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %111)
  tail call void @___qfree(i64 %111)
  %112 = load i64, ptr %77, align 4
  %113 = lshr i64 %112, %"282_0.sroa.15.0178.i"
  %114 = trunc i64 %113 to i1
  br i1 %114, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %115 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %100, 1
  %116 = shl nuw nsw i64 1, %"282_0.sroa.15.0178.i"
  %117 = xor i64 %112, %116
  store i64 %117, ptr %77, align 4
  %118 = getelementptr inbounds nuw i64, ptr %76, i64 %"282_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %118, align 4
  %119 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %119, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %119, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %119, 2
  %exitcond.not.i = icmp eq i64 %100, 10
  br i1 %exitcond.not.i, label %78, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.268.exit": ; preds = %96, %78
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %76, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %77, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %120 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  br label %__barray_check_bounds.exit.i834

loop_body.preheader.i:                            ; preds = %loop_body117
  %"535_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %272, 2
  %"535_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %272, 1
  %"535_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %272, 0
  %121 = lshr i64 %"535_1.sroa.10.0.i", 6
  %122 = getelementptr i64, ptr %"535_1.sroa.5.0.i", i64 %121
  %123 = load i64, ptr %122, align 4
  %124 = and i64 %"535_1.sroa.10.0.i", 63
  %125 = lshr i64 %123, %124
  %126 = trunc i64 %125 to i1
  br i1 %126, label %cond_exit_538.thread.i, label %__barray_mask_borrow.exit228.i

__barray_check_bounds.exit.i834:                  ; preds = %loop_body117, %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit"
  %127 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit" ], [ %272, %loop_body117 ]
  %"84_0.sroa.15.0933" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit" ], [ %128, %loop_body117 ]
  %.pn922932 = phi { { ptr, ptr, i64 }, i64 } [ %120, %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit" ], [ %268, %loop_body117 ]
  %128 = add nuw nsw i64 %"84_0.sroa.15.0933", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %127, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %127, 1
  %129 = add i64 %.fca.2.extract208.i, %"84_0.sroa.15.0933"
  %130 = lshr i64 %129, 6
  %131 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %130
  %132 = load i64, ptr %131, align 4
  %133 = and i64 %129, 63
  %134 = lshr i64 %132, %133
  %135 = trunc i64 %134 to i1
  br i1 %135, label %panic.i.i835, label %__barray_check_bounds.exit221.i

panic.i.i835:                                     ; preds = %__barray_check_bounds.exit.i834
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i834
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %127, 0
  %136 = shl nuw i64 1, %133
  %137 = xor i64 %132, %136
  store i64 %137, ptr %131, align 4
  %138 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %129
  %139 = load i64, ptr %138, align 4
  tail call void @___inc_future_refcount(i64 %139)
  %140 = load i64, ptr %131, align 4
  %141 = lshr i64 %140, %133
  %142 = trunc i64 %141 to i1
  br i1 %142, label %__barray_check_bounds.exit837, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

143:                                              ; preds = %mask_block_ok.i.i
  %144 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_exit_538.thread.9.i, %143
  %.02.i.i = phi i64 [ %144, %143 ], [ 0, %cond_exit_538.thread.9.i ]
  %gep.i.i = getelementptr i64, ptr %122, i64 %.02.i.i
  %145 = load i64, ptr %gep.i.i, align 4
  %146 = icmp eq i64 %145, -1
  br i1 %146, label %143, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i:                   ; preds = %loop_body.preheader.i
  %147 = shl nuw i64 1, %124
  %148 = xor i64 %123, %147
  store i64 %148, ptr %122, align 4
  %149 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %"535_1.sroa.10.0.i"
  %150 = load i64, ptr %149, align 4
  tail call void @___dec_future_refcount(i64 %150)
  br label %cond_exit_538.thread.i

cond_exit_538.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %loop_body.preheader.i
  %151 = add i64 %"535_1.sroa.10.0.i", 1
  %152 = lshr i64 %151, 6
  %153 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %152
  %154 = load i64, ptr %153, align 4
  %155 = and i64 %151, 63
  %156 = lshr i64 %154, %155
  %157 = trunc i64 %156 to i1
  br i1 %157, label %cond_exit_538.thread.1.i, label %__barray_mask_borrow.exit228.1.i

__barray_mask_borrow.exit228.1.i:                 ; preds = %cond_exit_538.thread.i
  %158 = shl nuw i64 1, %155
  %159 = xor i64 %154, %158
  store i64 %159, ptr %153, align 4
  %160 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %151
  %161 = load i64, ptr %160, align 4
  tail call void @___dec_future_refcount(i64 %161)
  br label %cond_exit_538.thread.1.i

cond_exit_538.thread.1.i:                         ; preds = %__barray_mask_borrow.exit228.1.i, %cond_exit_538.thread.i
  %162 = add i64 %"535_1.sroa.10.0.i", 2
  %163 = lshr i64 %162, 6
  %164 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %163
  %165 = load i64, ptr %164, align 4
  %166 = and i64 %162, 63
  %167 = lshr i64 %165, %166
  %168 = trunc i64 %167 to i1
  br i1 %168, label %cond_exit_538.thread.2.i, label %__barray_mask_borrow.exit228.2.i

__barray_mask_borrow.exit228.2.i:                 ; preds = %cond_exit_538.thread.1.i
  %169 = shl nuw i64 1, %166
  %170 = xor i64 %165, %169
  store i64 %170, ptr %164, align 4
  %171 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %162
  %172 = load i64, ptr %171, align 4
  tail call void @___dec_future_refcount(i64 %172)
  br label %cond_exit_538.thread.2.i

cond_exit_538.thread.2.i:                         ; preds = %__barray_mask_borrow.exit228.2.i, %cond_exit_538.thread.1.i
  %173 = add i64 %"535_1.sroa.10.0.i", 3
  %174 = lshr i64 %173, 6
  %175 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %174
  %176 = load i64, ptr %175, align 4
  %177 = and i64 %173, 63
  %178 = lshr i64 %176, %177
  %179 = trunc i64 %178 to i1
  br i1 %179, label %cond_exit_538.thread.3.i, label %__barray_mask_borrow.exit228.3.i

__barray_mask_borrow.exit228.3.i:                 ; preds = %cond_exit_538.thread.2.i
  %180 = shl nuw i64 1, %177
  %181 = xor i64 %176, %180
  store i64 %181, ptr %175, align 4
  %182 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %173
  %183 = load i64, ptr %182, align 4
  tail call void @___dec_future_refcount(i64 %183)
  br label %cond_exit_538.thread.3.i

cond_exit_538.thread.3.i:                         ; preds = %__barray_mask_borrow.exit228.3.i, %cond_exit_538.thread.2.i
  %184 = add i64 %"535_1.sroa.10.0.i", 4
  %185 = lshr i64 %184, 6
  %186 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %185
  %187 = load i64, ptr %186, align 4
  %188 = and i64 %184, 63
  %189 = lshr i64 %187, %188
  %190 = trunc i64 %189 to i1
  br i1 %190, label %cond_exit_538.thread.4.i, label %__barray_mask_borrow.exit228.4.i

__barray_mask_borrow.exit228.4.i:                 ; preds = %cond_exit_538.thread.3.i
  %191 = shl nuw i64 1, %188
  %192 = xor i64 %187, %191
  store i64 %192, ptr %186, align 4
  %193 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %184
  %194 = load i64, ptr %193, align 4
  tail call void @___dec_future_refcount(i64 %194)
  br label %cond_exit_538.thread.4.i

cond_exit_538.thread.4.i:                         ; preds = %__barray_mask_borrow.exit228.4.i, %cond_exit_538.thread.3.i
  %195 = add i64 %"535_1.sroa.10.0.i", 5
  %196 = lshr i64 %195, 6
  %197 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %196
  %198 = load i64, ptr %197, align 4
  %199 = and i64 %195, 63
  %200 = lshr i64 %198, %199
  %201 = trunc i64 %200 to i1
  br i1 %201, label %cond_exit_538.thread.5.i, label %__barray_mask_borrow.exit228.5.i

__barray_mask_borrow.exit228.5.i:                 ; preds = %cond_exit_538.thread.4.i
  %202 = shl nuw i64 1, %199
  %203 = xor i64 %198, %202
  store i64 %203, ptr %197, align 4
  %204 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %195
  %205 = load i64, ptr %204, align 4
  tail call void @___dec_future_refcount(i64 %205)
  br label %cond_exit_538.thread.5.i

cond_exit_538.thread.5.i:                         ; preds = %__barray_mask_borrow.exit228.5.i, %cond_exit_538.thread.4.i
  %206 = add i64 %"535_1.sroa.10.0.i", 6
  %207 = lshr i64 %206, 6
  %208 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %207
  %209 = load i64, ptr %208, align 4
  %210 = and i64 %206, 63
  %211 = lshr i64 %209, %210
  %212 = trunc i64 %211 to i1
  br i1 %212, label %cond_exit_538.thread.6.i, label %__barray_mask_borrow.exit228.6.i

__barray_mask_borrow.exit228.6.i:                 ; preds = %cond_exit_538.thread.5.i
  %213 = shl nuw i64 1, %210
  %214 = xor i64 %209, %213
  store i64 %214, ptr %208, align 4
  %215 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %206
  %216 = load i64, ptr %215, align 4
  tail call void @___dec_future_refcount(i64 %216)
  br label %cond_exit_538.thread.6.i

cond_exit_538.thread.6.i:                         ; preds = %__barray_mask_borrow.exit228.6.i, %cond_exit_538.thread.5.i
  %217 = add i64 %"535_1.sroa.10.0.i", 7
  %218 = lshr i64 %217, 6
  %219 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %218
  %220 = load i64, ptr %219, align 4
  %221 = and i64 %217, 63
  %222 = lshr i64 %220, %221
  %223 = trunc i64 %222 to i1
  br i1 %223, label %cond_exit_538.thread.7.i, label %__barray_mask_borrow.exit228.7.i

__barray_mask_borrow.exit228.7.i:                 ; preds = %cond_exit_538.thread.6.i
  %224 = shl nuw i64 1, %221
  %225 = xor i64 %220, %224
  store i64 %225, ptr %219, align 4
  %226 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %217
  %227 = load i64, ptr %226, align 4
  tail call void @___dec_future_refcount(i64 %227)
  br label %cond_exit_538.thread.7.i

cond_exit_538.thread.7.i:                         ; preds = %__barray_mask_borrow.exit228.7.i, %cond_exit_538.thread.6.i
  %228 = add i64 %"535_1.sroa.10.0.i", 8
  %229 = lshr i64 %228, 6
  %230 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %229
  %231 = load i64, ptr %230, align 4
  %232 = and i64 %228, 63
  %233 = lshr i64 %231, %232
  %234 = trunc i64 %233 to i1
  br i1 %234, label %cond_exit_538.thread.8.i, label %__barray_mask_borrow.exit228.8.i

__barray_mask_borrow.exit228.8.i:                 ; preds = %cond_exit_538.thread.7.i
  %235 = shl nuw i64 1, %232
  %236 = xor i64 %231, %235
  store i64 %236, ptr %230, align 4
  %237 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %228
  %238 = load i64, ptr %237, align 4
  tail call void @___dec_future_refcount(i64 %238)
  br label %cond_exit_538.thread.8.i

cond_exit_538.thread.8.i:                         ; preds = %__barray_mask_borrow.exit228.8.i, %cond_exit_538.thread.7.i
  %239 = add i64 %"535_1.sroa.10.0.i", 9
  %240 = lshr i64 %239, 6
  %241 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %240
  %242 = load i64, ptr %241, align 4
  %243 = and i64 %239, 63
  %244 = lshr i64 %242, %243
  %245 = trunc i64 %244 to i1
  br i1 %245, label %cond_exit_538.thread.9.i, label %__barray_mask_borrow.exit228.9.i

__barray_mask_borrow.exit228.9.i:                 ; preds = %cond_exit_538.thread.8.i
  %246 = shl nuw i64 1, %243
  %247 = xor i64 %242, %246
  store i64 %247, ptr %241, align 4
  %248 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %239
  %249 = load i64, ptr %248, align 4
  tail call void @___dec_future_refcount(i64 %249)
  br label %cond_exit_538.thread.9.i

cond_exit_538.thread.9.i:                         ; preds = %__barray_mask_borrow.exit228.9.i, %cond_exit_538.thread.8.i
  %250 = load i64, ptr %122, align 4
  %251 = sub nuw nsw i64 64, %124
  %252 = lshr i64 -1, %251
  %253 = icmp eq i64 %124, 0
  %254 = select i1 %253, i64 0, i64 %252
  %255 = or i64 %250, %254
  store i64 %255, ptr %122, align 4
  %256 = load i64, ptr %241, align 4
  %257 = shl nsw i64 -2, %243
  %258 = icmp eq i64 %243, 63
  %259 = select i1 %258, i64 0, i64 %257
  %260 = or i64 %256, %259
  store i64 %260, ptr %241, align 4
  %reass.sub.i.i = sub nsw i64 %240, %121
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit", label %mask_block_ok.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit": ; preds = %143, %cond_exit_538.thread.9.i
  tail call void @heap_free(ptr %"535_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"535_1.sroa.5.0.i")
  %261 = load i64, ptr %5, align 4
  %262 = and i64 %261, 1023
  store i64 %262, ptr %5, align 4
  %263 = icmp eq i64 %262, 0
  br i1 %263, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit837:                    ; preds = %__barray_check_bounds.exit221.i
  %264 = xor i64 %140, %136
  store i64 %264, ptr %131, align 4
  store i64 %139, ptr %138, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %139)
  tail call void @___dec_future_refcount(i64 %139)
  %265 = load i64, ptr %5, align 4
  %266 = lshr i64 %265, %"84_0.sroa.15.0933"
  %267 = trunc i64 %266 to i1
  br i1 %267, label %loop_body117, label %panic.i838

panic.i838:                                       ; preds = %__barray_check_bounds.exit837
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body117:                                     ; preds = %__barray_check_bounds.exit837
  %268 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn922932, i64 %128, 1
  %269 = shl nuw nsw i64 1, %"84_0.sroa.15.0933"
  %270 = xor i64 %265, %269
  store i64 %270, ptr %5, align 4
  %271 = getelementptr inbounds nuw i1, ptr %4, i64 %"84_0.sroa.15.0933"
  store i1 %read_bool, ptr %271, align 1
  %272 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn922932, 0
  %exitcond.not = icmp eq i64 %128, 10
  br i1 %exitcond.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i834

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit"
  %273 = tail call ptr @heap_alloc(i64 10)
  %274 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %274, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %273, ptr noundef nonnull align 1 dereferenceable(10) %4, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %273)
  %275 = load i64, ptr %5, align 4
  %276 = and i64 %275, 1023
  store i64 %276, ptr %5, align 4
  %277 = icmp eq i64 %276, 0
  br i1 %277, label %__barray_check_none_borrowed.exit845, label %mask_block_err.i843

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit845:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %278 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %278, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %4, ptr %arr_ptr, align 8
  store ptr %278, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  br label %__barray_check_bounds.exit853

mask_block_err.i843:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit853:                    ; preds = %cond_exit_125, %__barray_check_none_borrowed.exit845
  %"120_0.sroa.0.0935" = phi i64 [ 0, %__barray_check_none_borrowed.exit845 ], [ %285, %cond_exit_125 ]
  %279 = lshr i64 %"120_0.sroa.0.0935", 6
  %280 = getelementptr inbounds nuw i64, ptr %3, i64 %279
  %281 = load i64, ptr %280, align 4
  %282 = and i64 %"120_0.sroa.0.0935", 63
  %283 = lshr i64 %281, %282
  %284 = trunc i64 %283 to i1
  br i1 %284, label %cond_exit_125, label %panic.i854

panic.i854:                                       ; preds = %__barray_check_bounds.exit853
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_125:                                    ; preds = %__barray_check_bounds.exit853
  %285 = add nuw nsw i64 %"120_0.sroa.0.0935", 1
  %286 = shl nuw i64 1, %282
  %287 = xor i64 %281, %286
  store i64 %287, ptr %280, align 4
  %288 = getelementptr inbounds nuw i64, ptr %2, i64 %"120_0.sroa.0.0935"
  store i64 %"120_0.sroa.0.0935", ptr %288, align 4
  %exitcond938.not = icmp eq i64 %285, 100
  br i1 %exitcond938.not, label %loop_out192, label %__barray_check_bounds.exit853

loop_out192:                                      ; preds = %cond_exit_125
  %289 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %290 = load i64, ptr %289, align 4
  %291 = and i64 %290, 68719476735
  store i64 %291, ptr %289, align 4
  %292 = load i64, ptr %3, align 4
  %293 = icmp eq i64 %292, 0
  %294 = icmp eq i64 %291, 0
  %or.cond = select i1 %293, i1 %294, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit860, label %mask_block_err.i858

__barray_check_none_borrowed.exit860:             ; preds = %loop_out192
  %295 = call ptr @heap_alloc(i64 800)
  %296 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %296, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %295, ptr noundef nonnull align 1 dereferenceable(800) %2, i64 800, i1 false)
  call void @heap_free(ptr nonnull %295)
  %297 = load i64, ptr %289, align 4
  %298 = and i64 %297, 68719476735
  store i64 %298, ptr %289, align 4
  %299 = load i64, ptr %3, align 4
  %300 = icmp eq i64 %299, 0
  %301 = icmp eq i64 %298, 0
  %or.cond949 = select i1 %300, i1 %301, i1 false
  br i1 %or.cond949, label %__barray_check_none_borrowed.exit865, label %mask_block_err.i863

mask_block_err.i858:                              ; preds = %loop_out192
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit865:             ; preds = %__barray_check_none_borrowed.exit860
  %out_arr_alloca268 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr270 = getelementptr inbounds nuw i8, ptr %out_arr_alloca268, i64 4
  %arr_ptr271 = getelementptr inbounds nuw i8, ptr %out_arr_alloca268, i64 8
  %mask_ptr272 = getelementptr inbounds nuw i8, ptr %out_arr_alloca268, i64 16
  %302 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %302, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca268, align 8
  store i32 1, ptr %y_ptr270, align 4
  store ptr %2, ptr %arr_ptr271, align 8
  store ptr %302, ptr %mask_ptr272, align 8
  call void @print_int_arr(ptr nonnull @res_is.F21393DB.0, i64 14, ptr nonnull %out_arr_alloca268)
  br label %__barray_check_bounds.exit873

mask_block_err.i863:                              ; preds = %__barray_check_none_borrowed.exit860
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit873:                    ; preds = %cond_exit_160, %__barray_check_none_borrowed.exit865
  %"155_0.sroa.0.0937" = phi i64 [ 0, %__barray_check_none_borrowed.exit865 ], [ %311, %cond_exit_160 ]
  %303 = lshr i64 %"155_0.sroa.0.0937", 6
  %304 = getelementptr inbounds nuw i64, ptr %1, i64 %303
  %305 = load i64, ptr %304, align 4
  %306 = and i64 %"155_0.sroa.0.0937", 63
  %307 = lshr i64 %305, %306
  %308 = trunc i64 %307 to i1
  br i1 %308, label %cond_exit_160, label %panic.i874

panic.i874:                                       ; preds = %__barray_check_bounds.exit873
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_160:                                    ; preds = %__barray_check_bounds.exit873
  %309 = uitofp nneg i64 %"155_0.sroa.0.0937" to double
  %310 = fmul double %309, 6.250000e-02
  %311 = add nuw nsw i64 %"155_0.sroa.0.0937", 1
  %312 = shl nuw i64 1, %306
  %313 = xor i64 %305, %312
  store i64 %313, ptr %304, align 4
  %314 = getelementptr inbounds nuw double, ptr %0, i64 %"155_0.sroa.0.0937"
  store double %310, ptr %314, align 8
  %exitcond939.not = icmp eq i64 %311, 100
  br i1 %exitcond939.not, label %loop_out276, label %__barray_check_bounds.exit873

loop_out276:                                      ; preds = %cond_exit_160
  %315 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %316 = load i64, ptr %315, align 4
  %317 = and i64 %316, 68719476735
  store i64 %317, ptr %315, align 4
  %318 = load i64, ptr %1, align 4
  %319 = icmp eq i64 %318, 0
  %320 = icmp eq i64 %317, 0
  %or.cond950 = select i1 %319, i1 %320, i1 false
  br i1 %or.cond950, label %__barray_check_none_borrowed.exit880, label %mask_block_err.i878

__barray_check_none_borrowed.exit880:             ; preds = %loop_out276
  %321 = call ptr @heap_alloc(i64 800)
  %322 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %322, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %321, ptr noundef nonnull align 1 dereferenceable(800) %0, i64 800, i1 false)
  call void @heap_free(ptr nonnull %321)
  %323 = load i64, ptr %315, align 4
  %324 = and i64 %323, 68719476735
  store i64 %324, ptr %315, align 4
  %325 = load i64, ptr %1, align 4
  %326 = icmp eq i64 %325, 0
  %327 = icmp eq i64 %324, 0
  %or.cond951 = select i1 %326, i1 %327, i1 false
  br i1 %or.cond951, label %__barray_check_none_borrowed.exit885, label %mask_block_err.i883

mask_block_err.i878:                              ; preds = %loop_out276
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit885:             ; preds = %__barray_check_none_borrowed.exit880
  %out_arr_alloca355 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr357 = getelementptr inbounds nuw i8, ptr %out_arr_alloca355, i64 4
  %arr_ptr358 = getelementptr inbounds nuw i8, ptr %out_arr_alloca355, i64 8
  %mask_ptr359 = getelementptr inbounds nuw i8, ptr %out_arr_alloca355, i64 16
  %328 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %328, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca355, align 8
  store i32 1, ptr %y_ptr357, align 4
  store ptr %0, ptr %arr_ptr358, align 8
  store ptr %328, ptr %mask_ptr359, align 8
  call void @print_float_arr(ptr nonnull @res_fs.CBD4AF54.0, i64 16, ptr nonnull %out_arr_alloca355)
  ret void

mask_block_err.i883:                              ; preds = %__barray_check_none_borrowed.exit880
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

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
