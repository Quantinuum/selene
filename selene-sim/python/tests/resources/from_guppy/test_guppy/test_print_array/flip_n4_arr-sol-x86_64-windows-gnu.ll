; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

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
  br i1 %not_max.not.not.i, label %cond_515_case_0.i, label %__barray_check_bounds.exit

cond_515_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %8 = load i64, ptr %7, align 4
  %9 = trunc i64 %8 to i1
  br i1 %9, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__barray_check_bounds.exit.8, %__barray_check_bounds.exit.7, %__barray_check_bounds.exit.6, %__barray_check_bounds.exit.5, %__barray_check_bounds.exit.4, %__barray_check_bounds.exit.3, %__barray_check_bounds.exit.2, %__barray_check_bounds.exit.1, %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__barray_check_bounds.exit
  %10 = and i64 %8, -2
  store i64 %10, ptr %7, align 4
  store i64 %qalloc.i, ptr %6, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_515_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %11 = load i64, ptr %7, align 4
  %12 = and i64 %11, 2
  %.not944 = icmp eq i64 %12, 0
  br i1 %.not944, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit.1
  %13 = and i64 %11, -3
  store i64 %13, ptr %7, align 4
  %14 = getelementptr inbounds nuw i8, ptr %6, i64 8
  store i64 %qalloc.i.1, ptr %14, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_515_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %15 = load i64, ptr %7, align 4
  %16 = and i64 %15, 4
  %.not945 = icmp eq i64 %16, 0
  br i1 %.not945, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %17 = and i64 %15, -5
  store i64 %17, ptr %7, align 4
  %18 = getelementptr inbounds nuw i8, ptr %6, i64 16
  store i64 %qalloc.i.2, ptr %18, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_515_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %19 = load i64, ptr %7, align 4
  %20 = and i64 %19, 8
  %.not946 = icmp eq i64 %20, 0
  br i1 %.not946, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %21 = and i64 %19, -9
  store i64 %21, ptr %7, align 4
  %22 = getelementptr inbounds nuw i8, ptr %6, i64 24
  store i64 %qalloc.i.3, ptr %22, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_515_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %23 = load i64, ptr %7, align 4
  %24 = and i64 %23, 16
  %.not947 = icmp eq i64 %24, 0
  br i1 %.not947, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %25 = and i64 %23, -17
  store i64 %25, ptr %7, align 4
  %26 = getelementptr inbounds nuw i8, ptr %6, i64 32
  store i64 %qalloc.i.4, ptr %26, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_515_case_0.i, label %__barray_check_bounds.exit.5

__barray_check_bounds.exit.5:                     ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %27 = load i64, ptr %7, align 4
  %28 = and i64 %27, 32
  %.not948 = icmp eq i64 %28, 0
  br i1 %.not948, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__barray_check_bounds.exit.5
  %29 = and i64 %27, -33
  store i64 %29, ptr %7, align 4
  %30 = getelementptr inbounds nuw i8, ptr %6, i64 40
  store i64 %qalloc.i.5, ptr %30, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_515_case_0.i, label %__barray_check_bounds.exit.6

__barray_check_bounds.exit.6:                     ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %31 = load i64, ptr %7, align 4
  %32 = and i64 %31, 64
  %.not949 = icmp eq i64 %32, 0
  br i1 %.not949, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__barray_check_bounds.exit.6
  %33 = and i64 %31, -65
  store i64 %33, ptr %7, align 4
  %34 = getelementptr inbounds nuw i8, ptr %6, i64 48
  store i64 %qalloc.i.6, ptr %34, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_515_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %35 = load i64, ptr %7, align 4
  %36 = and i64 %35, 128
  %.not950 = icmp eq i64 %36, 0
  br i1 %.not950, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %37 = and i64 %35, -129
  store i64 %37, ptr %7, align 4
  %38 = getelementptr inbounds nuw i8, ptr %6, i64 56
  store i64 %qalloc.i.7, ptr %38, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_515_case_0.i, label %__barray_check_bounds.exit.8

__barray_check_bounds.exit.8:                     ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %39 = load i64, ptr %7, align 4
  %40 = and i64 %39, 256
  %.not951 = icmp eq i64 %40, 0
  br i1 %.not951, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__barray_check_bounds.exit.8
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
  %.not952 = icmp eq i64 %44, 0
  br i1 %.not952, label %panic.i, label %cond_exit_20.9

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
  %57 = getelementptr inbounds nuw i8, ptr %6, i64 16
  %58 = load i64, ptr %57, align 4
  tail call void @___rp(i64 %58, double 0x400921FB54442D18, double 0.000000e+00)
  %59 = load i64, ptr %7, align 4
  %60 = and i64 %59, 4
  %.not917 = icmp eq i64 %60, 0
  br i1 %.not917, label %panic.i824, label %__barray_mask_return.exit825

panic.i824:                                       ; preds = %__barray_mask_borrow.exit823
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit825:                     ; preds = %__barray_mask_borrow.exit823
  %61 = and i64 %59, -5
  store i64 %61, ptr %7, align 4
  store i64 %58, ptr %57, align 4
  %62 = load i64, ptr %7, align 4
  %63 = and i64 %62, 8
  %.not918 = icmp eq i64 %63, 0
  br i1 %.not918, label %__barray_mask_borrow.exit827, label %panic.i826

panic.i826:                                       ; preds = %__barray_mask_return.exit825
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit827:                     ; preds = %__barray_mask_return.exit825
  %64 = or disjoint i64 %62, 8
  store i64 %64, ptr %7, align 4
  %65 = getelementptr inbounds nuw i8, ptr %6, i64 24
  %66 = load i64, ptr %65, align 4
  tail call void @___rp(i64 %66, double 0x400921FB54442D18, double 0.000000e+00)
  %67 = load i64, ptr %7, align 4
  %68 = and i64 %67, 8
  %.not919 = icmp eq i64 %68, 0
  br i1 %.not919, label %panic.i828, label %__barray_mask_return.exit829

panic.i828:                                       ; preds = %__barray_mask_borrow.exit827
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit829:                     ; preds = %__barray_mask_borrow.exit827
  %69 = and i64 %67, -9
  store i64 %69, ptr %7, align 4
  store i64 %66, ptr %65, align 4
  %70 = load i64, ptr %7, align 4
  %71 = and i64 %70, 512
  %.not920 = icmp eq i64 %71, 0
  br i1 %.not920, label %__barray_mask_borrow.exit831, label %panic.i830

panic.i830:                                       ; preds = %__barray_mask_return.exit829
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit831:                     ; preds = %__barray_mask_return.exit829
  %72 = or disjoint i64 %70, 512
  store i64 %72, ptr %7, align 4
  %73 = getelementptr inbounds nuw i8, ptr %6, i64 72
  %74 = load i64, ptr %73, align 4
  tail call void @___rp(i64 %74, double 0x400921FB54442D18, double 0.000000e+00)
  %75 = load i64, ptr %7, align 4
  %76 = and i64 %75, 512
  %.not921 = icmp eq i64 %76, 0
  br i1 %.not921, label %panic.i832, label %__barray_mask_return.exit833

panic.i832:                                       ; preds = %__barray_mask_borrow.exit831
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit833:                     ; preds = %__barray_mask_borrow.exit831
  %77 = and i64 %75, -513
  store i64 %77, ptr %7, align 4
  store i64 %74, ptr %73, align 4
  %78 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"121.fca.2.insert", 0
  %79 = tail call ptr @heap_alloc(i64 80)
  %80 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %80, align 1
  br label %__barray_check_bounds.exit.i.i

81:                                               ; preds = %loop_body.i
  %82 = lshr i64 %.fca.2.extract.i.i, 6
  %83 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %82
  %84 = load i64, ptr %83, align 4
  %85 = and i64 %.fca.2.extract.i.i, 63
  %86 = sub nuw nsw i64 64, %85
  %87 = lshr i64 -1, %86
  %88 = icmp eq i64 %85, 0
  %89 = select i1 %88, i64 0, i64 %87
  %90 = or i64 %84, %89
  store i64 %90, ptr %83, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %91 = lshr i64 %last_valid.i.i.i, 6
  %92 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %91
  %93 = load i64, ptr %92, align 4
  %94 = and i64 %last_valid.i.i.i, 63
  %95 = shl nsw i64 -2, %94
  %96 = icmp eq i64 %94, 63
  %97 = select i1 %96, i64 0, i64 %95
  %98 = or i64 %93, %97
  store i64 %98, ptr %92, align 4
  %reass.sub.i.i.i = sub nsw i64 %91, %82
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit", label %mask_block_ok.i.i.i

99:                                               ; preds = %mask_block_ok.i.i.i
  %100 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %81, %99
  %.02.i.i.i = phi i64 [ %100, %99 ], [ 0, %81 ]
  %gep.i.i.i = getelementptr i64, ptr %83, i64 %.02.i.i.i
  %101 = load i64, ptr %gep.i.i.i, align 4
  %102 = icmp eq i64 %101, -1
  br i1 %102, label %99, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit833
  %.fca.2.extract.i181.i = phi i64 [ 0, %__barray_mask_return.exit833 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %7, %__barray_mask_return.exit833 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %6, %__barray_mask_return.exit833 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"282_0.sroa.15.0178.i" = phi i64 [ 0, %__barray_mask_return.exit833 ], [ %103, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %78, %__barray_mask_return.exit833 ], [ %118, %loop_body.i ]
  %103 = add nuw nsw i64 %"282_0.sroa.15.0178.i", 1
  %104 = add i64 %"282_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %105 = lshr i64 %104, 6
  %106 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %105
  %107 = load i64, ptr %106, align 4
  %108 = and i64 %104, 63
  %109 = lshr i64 %107, %108
  %110 = trunc i64 %109 to i1
  br i1 %110, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %111 = shl nuw i64 1, %108
  %112 = xor i64 %111, %107
  store i64 %112, ptr %106, align 4
  %113 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %104
  %114 = load i64, ptr %113, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %114)
  tail call void @___qfree(i64 %114)
  %115 = load i64, ptr %80, align 4
  %116 = lshr i64 %115, %"282_0.sroa.15.0178.i"
  %117 = trunc i64 %116 to i1
  br i1 %117, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %118 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %103, 1
  %119 = shl nuw nsw i64 1, %"282_0.sroa.15.0178.i"
  %120 = xor i64 %115, %119
  store i64 %120, ptr %80, align 4
  %121 = getelementptr inbounds nuw i64, ptr %79, i64 %"282_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %121, align 4
  %122 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %122, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %122, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %122, 2
  %exitcond.not.i = icmp eq i64 %103, 10
  br i1 %exitcond.not.i, label %81, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.268.exit": ; preds = %99, %81
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %79, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %80, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %123 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  br label %__barray_check_bounds.exit.i834

loop_body.preheader.i:                            ; preds = %loop_body117
  %"535_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %184, 2
  %"535_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %184, 1
  %"535_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %184, 0
  br label %__barray_check_bounds.exit224.i

__barray_check_bounds.exit.i834:                  ; preds = %loop_body117, %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit"
  %124 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit" ], [ %184, %loop_body117 ]
  %"84_0.sroa.15.0933" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit" ], [ %125, %loop_body117 ]
  %.pn922932 = phi { { ptr, ptr, i64 }, i64 } [ %123, %"__hugr__.guppylang.std.quantum.measure_array$10.268.exit" ], [ %180, %loop_body117 ]
  %125 = add nuw nsw i64 %"84_0.sroa.15.0933", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %124, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %124, 1
  %126 = add i64 %.fca.2.extract208.i, %"84_0.sroa.15.0933"
  %127 = lshr i64 %126, 6
  %128 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %127
  %129 = load i64, ptr %128, align 4
  %130 = and i64 %126, 63
  %131 = lshr i64 %129, %130
  %132 = trunc i64 %131 to i1
  br i1 %132, label %panic.i.i835, label %__barray_check_bounds.exit221.i

panic.i.i835:                                     ; preds = %__barray_check_bounds.exit.i834
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i834
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %124, 0
  %133 = shl nuw i64 1, %130
  %134 = xor i64 %129, %133
  store i64 %134, ptr %128, align 4
  %135 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %126
  %136 = load i64, ptr %135, align 4
  tail call void @___inc_future_refcount(i64 %136)
  %137 = load i64, ptr %128, align 4
  %138 = lshr i64 %137, %130
  %139 = trunc i64 %138 to i1
  br i1 %139, label %__barray_check_bounds.exit837, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_538_case_0.i:                                ; preds = %cond_exit_538.thread.i
  %140 = lshr i64 %"535_1.sroa.10.0.i", 6
  %141 = getelementptr i64, ptr %"535_1.sroa.5.0.i", i64 %140
  %142 = load i64, ptr %141, align 4
  %143 = and i64 %"535_1.sroa.10.0.i", 63
  %144 = sub nuw nsw i64 64, %143
  %145 = lshr i64 -1, %144
  %146 = icmp eq i64 %143, 0
  %147 = select i1 %146, i64 0, i64 %145
  %148 = or i64 %142, %147
  store i64 %148, ptr %141, align 4
  %last_valid.i.i = add i64 %"535_1.sroa.10.0.i", 9
  %149 = lshr i64 %last_valid.i.i, 6
  %150 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %149
  %151 = load i64, ptr %150, align 4
  %152 = and i64 %last_valid.i.i, 63
  %153 = shl nsw i64 -2, %152
  %154 = icmp eq i64 %152, 63
  %155 = select i1 %154, i64 0, i64 %153
  %156 = or i64 %151, %155
  store i64 %156, ptr %150, align 4
  %reass.sub.i.i = sub nsw i64 %149, %140
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit", label %mask_block_ok.i.i

157:                                              ; preds = %mask_block_ok.i.i
  %158 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_538_case_0.i, %157
  %.02.i.i = phi i64 [ %158, %157 ], [ 0, %cond_538_case_0.i ]
  %gep.i.i = getelementptr i64, ptr %141, i64 %.02.i.i
  %159 = load i64, ptr %gep.i.i, align 4
  %160 = icmp eq i64 %159, -1
  br i1 %160, label %157, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i:                  ; preds = %cond_exit_538.thread.i, %loop_body.preheader.i
  %"535_0.0239.i" = phi i64 [ 0, %loop_body.preheader.i ], [ %161, %cond_exit_538.thread.i ]
  %161 = add nuw nsw i64 %"535_0.0239.i", 1
  %162 = add i64 %"535_0.0239.i", %"535_1.sroa.10.0.i"
  %163 = lshr i64 %162, 6
  %164 = getelementptr inbounds nuw i64, ptr %"535_1.sroa.5.0.i", i64 %163
  %165 = load i64, ptr %164, align 4
  %166 = and i64 %162, 63
  %167 = lshr i64 %165, %166
  %168 = trunc i64 %167 to i1
  br i1 %168, label %cond_exit_538.thread.i, label %__barray_mask_borrow.exit228.i

__barray_mask_borrow.exit228.i:                   ; preds = %__barray_check_bounds.exit224.i
  %169 = shl nuw i64 1, %166
  %170 = xor i64 %169, %165
  store i64 %170, ptr %164, align 4
  %171 = getelementptr inbounds i64, ptr %"535_1.sroa.0.0.i", i64 %162
  %172 = load i64, ptr %171, align 4
  tail call void @___dec_future_refcount(i64 %172)
  br label %cond_exit_538.thread.i

cond_exit_538.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %__barray_check_bounds.exit224.i
  %exitcond.i = icmp eq i64 %161, 10
  br i1 %exitcond.i, label %cond_538_case_0.i, label %__barray_check_bounds.exit224.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit": ; preds = %157, %cond_538_case_0.i
  tail call void @heap_free(ptr %"535_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"535_1.sroa.5.0.i")
  %173 = load i64, ptr %5, align 4
  %174 = and i64 %173, 1023
  store i64 %174, ptr %5, align 4
  %175 = icmp eq i64 %174, 0
  br i1 %175, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit837:                    ; preds = %__barray_check_bounds.exit221.i
  %176 = xor i64 %137, %133
  store i64 %176, ptr %128, align 4
  store i64 %136, ptr %135, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %136)
  tail call void @___dec_future_refcount(i64 %136)
  %177 = load i64, ptr %5, align 4
  %178 = lshr i64 %177, %"84_0.sroa.15.0933"
  %179 = trunc i64 %178 to i1
  br i1 %179, label %loop_body117, label %panic.i838

panic.i838:                                       ; preds = %__barray_check_bounds.exit837
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body117:                                     ; preds = %__barray_check_bounds.exit837
  %180 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn922932, i64 %125, 1
  %181 = shl nuw nsw i64 1, %"84_0.sroa.15.0933"
  %182 = xor i64 %177, %181
  store i64 %182, ptr %5, align 4
  %183 = getelementptr inbounds nuw i1, ptr %4, i64 %"84_0.sroa.15.0933"
  store i1 %read_bool, ptr %183, align 1
  %184 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn922932, 0
  %exitcond938.not = icmp eq i64 %125, 10
  br i1 %exitcond938.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i834

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit"
  %185 = tail call ptr @heap_alloc(i64 10)
  %186 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %186, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %185, ptr noundef nonnull align 1 dereferenceable(10) %4, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %185)
  %187 = load i64, ptr %5, align 4
  %188 = and i64 %187, 1023
  store i64 %188, ptr %5, align 4
  %189 = icmp eq i64 %188, 0
  br i1 %189, label %__barray_check_none_borrowed.exit845, label %mask_block_err.i843

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.309.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit845:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %190 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %190, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %4, ptr %arr_ptr, align 8
  store ptr %190, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  br label %__barray_check_bounds.exit853

mask_block_err.i843:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit853:                    ; preds = %cond_exit_125.1, %__barray_check_none_borrowed.exit845
  %"120_0.sroa.0.0935" = phi i64 [ 0, %__barray_check_none_borrowed.exit845 ], [ %207, %cond_exit_125.1 ]
  %191 = lshr i64 %"120_0.sroa.0.0935", 6
  %192 = getelementptr inbounds nuw i64, ptr %3, i64 %191
  %193 = load i64, ptr %192, align 4
  %194 = and i64 %"120_0.sroa.0.0935", 62
  %195 = lshr i64 %193, %194
  %196 = trunc i64 %195 to i1
  br i1 %196, label %cond_exit_125, label %panic.i854

panic.i854:                                       ; preds = %cond_exit_125, %__barray_check_bounds.exit853
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_125:                                    ; preds = %__barray_check_bounds.exit853
  %197 = or disjoint i64 %"120_0.sroa.0.0935", 1
  %198 = shl nuw nsw i64 1, %194
  %199 = xor i64 %193, %198
  store i64 %199, ptr %192, align 4
  %200 = getelementptr inbounds nuw i64, ptr %2, i64 %"120_0.sroa.0.0935"
  store i64 %"120_0.sroa.0.0935", ptr %200, align 4
  %201 = lshr i64 %"120_0.sroa.0.0935", 6
  %202 = getelementptr inbounds nuw i64, ptr %3, i64 %201
  %203 = load i64, ptr %202, align 4
  %204 = and i64 %197, 63
  %205 = lshr i64 %203, %204
  %206 = trunc i64 %205 to i1
  br i1 %206, label %cond_exit_125.1, label %panic.i854

cond_exit_125.1:                                  ; preds = %cond_exit_125
  %207 = add nuw nsw i64 %"120_0.sroa.0.0935", 2
  %208 = shl nuw i64 1, %204
  %209 = xor i64 %203, %208
  store i64 %209, ptr %202, align 4
  %210 = getelementptr inbounds nuw i64, ptr %2, i64 %197
  store i64 %197, ptr %210, align 4
  %exitcond939.not.1 = icmp eq i64 %207, 100
  br i1 %exitcond939.not.1, label %loop_out192, label %__barray_check_bounds.exit853

loop_out192:                                      ; preds = %cond_exit_125.1
  %211 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %212 = load i64, ptr %211, align 4
  %213 = and i64 %212, 68719476735
  store i64 %213, ptr %211, align 4
  %214 = load i64, ptr %3, align 4
  %215 = icmp eq i64 %214, 0
  %216 = icmp eq i64 %213, 0
  %or.cond = select i1 %215, i1 %216, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit860, label %mask_block_err.i858

__barray_check_none_borrowed.exit860:             ; preds = %loop_out192
  %217 = call ptr @heap_alloc(i64 800)
  %218 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %218, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %217, ptr noundef nonnull align 1 dereferenceable(800) %2, i64 800, i1 false)
  call void @heap_free(ptr nonnull %217)
  %219 = load i64, ptr %211, align 4
  %220 = and i64 %219, 68719476735
  store i64 %220, ptr %211, align 4
  %221 = load i64, ptr %3, align 4
  %222 = icmp eq i64 %221, 0
  %223 = icmp eq i64 %220, 0
  %or.cond941 = select i1 %222, i1 %223, i1 false
  br i1 %or.cond941, label %__barray_check_none_borrowed.exit865, label %mask_block_err.i863

mask_block_err.i858:                              ; preds = %loop_out192
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit865:             ; preds = %__barray_check_none_borrowed.exit860
  %out_arr_alloca268 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr270 = getelementptr inbounds nuw i8, ptr %out_arr_alloca268, i64 4
  %arr_ptr271 = getelementptr inbounds nuw i8, ptr %out_arr_alloca268, i64 8
  %mask_ptr272 = getelementptr inbounds nuw i8, ptr %out_arr_alloca268, i64 16
  %224 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %224, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca268, align 8
  store i32 1, ptr %y_ptr270, align 4
  store ptr %2, ptr %arr_ptr271, align 8
  store ptr %224, ptr %mask_ptr272, align 8
  call void @print_int_arr(ptr nonnull @res_is.F21393DB.0, i64 14, ptr nonnull %out_arr_alloca268)
  br label %__barray_check_bounds.exit873

mask_block_err.i863:                              ; preds = %__barray_check_none_borrowed.exit860
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit873:                    ; preds = %cond_exit_160, %__barray_check_none_borrowed.exit865
  %"155_0.sroa.0.0937" = phi i64 [ 0, %__barray_check_none_borrowed.exit865 ], [ %233, %cond_exit_160 ]
  %225 = lshr i64 %"155_0.sroa.0.0937", 6
  %226 = getelementptr inbounds nuw i64, ptr %1, i64 %225
  %227 = load i64, ptr %226, align 4
  %228 = and i64 %"155_0.sroa.0.0937", 63
  %229 = lshr i64 %227, %228
  %230 = trunc i64 %229 to i1
  br i1 %230, label %cond_exit_160, label %panic.i874

panic.i874:                                       ; preds = %__barray_check_bounds.exit873
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_160:                                    ; preds = %__barray_check_bounds.exit873
  %231 = uitofp nneg i64 %"155_0.sroa.0.0937" to double
  %232 = fmul double %231, 6.250000e-02
  %233 = add nuw nsw i64 %"155_0.sroa.0.0937", 1
  %234 = shl nuw i64 1, %228
  %235 = xor i64 %227, %234
  store i64 %235, ptr %226, align 4
  %236 = getelementptr inbounds nuw double, ptr %0, i64 %"155_0.sroa.0.0937"
  store double %232, ptr %236, align 8
  %exitcond940.not = icmp eq i64 %233, 100
  br i1 %exitcond940.not, label %loop_out276, label %__barray_check_bounds.exit873

loop_out276:                                      ; preds = %cond_exit_160
  %237 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %238 = load i64, ptr %237, align 4
  %239 = and i64 %238, 68719476735
  store i64 %239, ptr %237, align 4
  %240 = load i64, ptr %1, align 4
  %241 = icmp eq i64 %240, 0
  %242 = icmp eq i64 %239, 0
  %or.cond942 = select i1 %241, i1 %242, i1 false
  br i1 %or.cond942, label %__barray_check_none_borrowed.exit880, label %mask_block_err.i878

__barray_check_none_borrowed.exit880:             ; preds = %loop_out276
  %243 = call ptr @heap_alloc(i64 800)
  %244 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %244, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %243, ptr noundef nonnull align 1 dereferenceable(800) %0, i64 800, i1 false)
  call void @heap_free(ptr nonnull %243)
  %245 = load i64, ptr %237, align 4
  %246 = and i64 %245, 68719476735
  store i64 %246, ptr %237, align 4
  %247 = load i64, ptr %1, align 4
  %248 = icmp eq i64 %247, 0
  %249 = icmp eq i64 %246, 0
  %or.cond943 = select i1 %248, i1 %249, i1 false
  br i1 %or.cond943, label %__barray_check_none_borrowed.exit885, label %mask_block_err.i883

mask_block_err.i878:                              ; preds = %loop_out276
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit885:             ; preds = %__barray_check_none_borrowed.exit880
  %out_arr_alloca355 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr357 = getelementptr inbounds nuw i8, ptr %out_arr_alloca355, i64 4
  %arr_ptr358 = getelementptr inbounds nuw i8, ptr %out_arr_alloca355, i64 8
  %mask_ptr359 = getelementptr inbounds nuw i8, ptr %out_arr_alloca355, i64 16
  %250 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %250, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca355, align 8
  store i32 1, ptr %y_ptr357, align 4
  store ptr %0, ptr %arr_ptr358, align 8
  store ptr %250, ptr %mask_ptr359, align 8
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
