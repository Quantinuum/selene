; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

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
  %4 = tail call ptr @heap_alloc(i64 80)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_525_case_0.i, label %__barray_check_bounds.exit

cond_525_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
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
  br i1 %not_max.not.not.i.1, label %cond_525_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %9 = load i64, ptr %5, align 4
  %10 = and i64 %9, 2
  %.not786 = icmp eq i64 %10, 0
  br i1 %.not786, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit.1
  %11 = and i64 %9, -3
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %qalloc.i.1, ptr %12, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_525_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %13 = load i64, ptr %5, align 4
  %14 = and i64 %13, 4
  %.not787 = icmp eq i64 %14, 0
  br i1 %.not787, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %15 = and i64 %13, -5
  store i64 %15, ptr %5, align 4
  %16 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %qalloc.i.2, ptr %16, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_525_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %17 = load i64, ptr %5, align 4
  %18 = and i64 %17, 8
  %.not788 = icmp eq i64 %18, 0
  br i1 %.not788, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %19 = and i64 %17, -9
  store i64 %19, ptr %5, align 4
  %20 = getelementptr inbounds nuw i8, ptr %4, i64 24
  store i64 %qalloc.i.3, ptr %20, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_525_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %21 = load i64, ptr %5, align 4
  %22 = and i64 %21, 16
  %.not789 = icmp eq i64 %22, 0
  br i1 %.not789, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %23 = and i64 %21, -17
  store i64 %23, ptr %5, align 4
  %24 = getelementptr inbounds nuw i8, ptr %4, i64 32
  store i64 %qalloc.i.4, ptr %24, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_525_case_0.i, label %__barray_check_bounds.exit.5

__barray_check_bounds.exit.5:                     ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %25 = load i64, ptr %5, align 4
  %26 = and i64 %25, 32
  %.not790 = icmp eq i64 %26, 0
  br i1 %.not790, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__barray_check_bounds.exit.5
  %27 = and i64 %25, -33
  store i64 %27, ptr %5, align 4
  %28 = getelementptr inbounds nuw i8, ptr %4, i64 40
  store i64 %qalloc.i.5, ptr %28, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_525_case_0.i, label %__barray_check_bounds.exit.6

__barray_check_bounds.exit.6:                     ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %29 = load i64, ptr %5, align 4
  %30 = and i64 %29, 64
  %.not791 = icmp eq i64 %30, 0
  br i1 %.not791, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__barray_check_bounds.exit.6
  %31 = and i64 %29, -65
  store i64 %31, ptr %5, align 4
  %32 = getelementptr inbounds nuw i8, ptr %4, i64 48
  store i64 %qalloc.i.6, ptr %32, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_525_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %33 = load i64, ptr %5, align 4
  %34 = and i64 %33, 128
  %.not792 = icmp eq i64 %34, 0
  br i1 %.not792, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %35 = and i64 %33, -129
  store i64 %35, ptr %5, align 4
  %36 = getelementptr inbounds nuw i8, ptr %4, i64 56
  store i64 %qalloc.i.7, ptr %36, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_525_case_0.i, label %__barray_check_bounds.exit.8

__barray_check_bounds.exit.8:                     ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %37 = load i64, ptr %5, align 4
  %38 = and i64 %37, 256
  %.not793 = icmp eq i64 %38, 0
  br i1 %.not793, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__barray_check_bounds.exit.8
  %39 = and i64 %37, -257
  store i64 %39, ptr %5, align 4
  %40 = getelementptr inbounds nuw i8, ptr %4, i64 64
  store i64 %qalloc.i.8, ptr %40, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_525_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %41 = load i64, ptr %5, align 4
  %42 = and i64 %41, 512
  %.not794 = icmp eq i64 %42, 0
  br i1 %.not794, label %panic.i, label %cond_exit_20.9

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
  br i1 %46, label %panic.i683, label %__barray_mask_borrow.exit

panic.i683:                                       ; preds = %cond_exit_20.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.9
  %47 = or disjoint i64 %45, 1
  store i64 %47, ptr %5, align 4
  %48 = load i64, ptr %4, align 4
  tail call void @___rxy(i64 %48, double 0x400921FB54442D18, double 0.000000e+00)
  %49 = load i64, ptr %5, align 4
  %50 = trunc i64 %49 to i1
  br i1 %50, label %__barray_mask_return.exit685, label %panic.i684

panic.i684:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit685:                     ; preds = %__barray_mask_borrow.exit
  %51 = and i64 %49, -2
  store i64 %51, ptr %5, align 4
  store i64 %48, ptr %4, align 4
  %52 = load i64, ptr %5, align 4
  %53 = and i64 %52, 4
  %.not = icmp eq i64 %53, 0
  br i1 %.not, label %__barray_mask_borrow.exit687, label %panic.i686

panic.i686:                                       ; preds = %__barray_mask_return.exit685
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit687:                     ; preds = %__barray_mask_return.exit685
  %54 = or disjoint i64 %52, 4
  store i64 %54, ptr %5, align 4
  %55 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %56 = load i64, ptr %55, align 4
  tail call void @___rxy(i64 %56, double 0x400921FB54442D18, double 0.000000e+00)
  %57 = load i64, ptr %5, align 4
  %58 = and i64 %57, 4
  %.not770 = icmp eq i64 %58, 0
  br i1 %.not770, label %panic.i688, label %__barray_mask_return.exit689

panic.i688:                                       ; preds = %__barray_mask_borrow.exit687
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit689:                     ; preds = %__barray_mask_borrow.exit687
  %59 = and i64 %57, -5
  store i64 %59, ptr %5, align 4
  store i64 %56, ptr %55, align 4
  %60 = load i64, ptr %5, align 4
  %61 = and i64 %60, 8
  %.not771 = icmp eq i64 %61, 0
  br i1 %.not771, label %__barray_mask_borrow.exit691, label %panic.i690

panic.i690:                                       ; preds = %__barray_mask_return.exit689
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit691:                     ; preds = %__barray_mask_return.exit689
  %62 = or disjoint i64 %60, 8
  store i64 %62, ptr %5, align 4
  %63 = getelementptr inbounds nuw i8, ptr %4, i64 24
  %64 = load i64, ptr %63, align 4
  tail call void @___rxy(i64 %64, double 0x400921FB54442D18, double 0.000000e+00)
  %65 = load i64, ptr %5, align 4
  %66 = and i64 %65, 8
  %.not772 = icmp eq i64 %66, 0
  br i1 %.not772, label %panic.i692, label %__barray_mask_return.exit693

panic.i692:                                       ; preds = %__barray_mask_borrow.exit691
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit693:                     ; preds = %__barray_mask_borrow.exit691
  %67 = and i64 %65, -9
  store i64 %67, ptr %5, align 4
  store i64 %64, ptr %63, align 4
  %68 = load i64, ptr %5, align 4
  %69 = and i64 %68, 512
  %.not773 = icmp eq i64 %69, 0
  br i1 %.not773, label %__barray_mask_borrow.exit695, label %panic.i694

panic.i694:                                       ; preds = %__barray_mask_return.exit693
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit695:                     ; preds = %__barray_mask_return.exit693
  %70 = or disjoint i64 %68, 512
  store i64 %70, ptr %5, align 4
  %71 = getelementptr inbounds nuw i8, ptr %4, i64 72
  %72 = load i64, ptr %71, align 4
  tail call void @___rxy(i64 %72, double 0x400921FB54442D18, double 0.000000e+00)
  %73 = load i64, ptr %5, align 4
  %74 = and i64 %73, 512
  %.not774 = icmp eq i64 %74, 0
  br i1 %.not774, label %panic.i696, label %__barray_mask_return.exit697

panic.i696:                                       ; preds = %__barray_mask_borrow.exit695
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit697:                     ; preds = %__barray_mask_borrow.exit695
  %75 = and i64 %73, -513
  store i64 %75, ptr %5, align 4
  store i64 %72, ptr %71, align 4
  %76 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"120.fca.2.insert", 0
  %77 = tail call ptr @heap_alloc(i64 80)
  %78 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %78, align 1
  br label %__barray_check_bounds.exit.i.i

79:                                               ; preds = %loop_body.i
  %80 = lshr i64 %.fca.2.extract.i.i, 6
  %81 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %80
  %82 = load i64, ptr %81, align 4
  %83 = and i64 %.fca.2.extract.i.i, 63
  %84 = sub nuw nsw i64 64, %83
  %85 = lshr i64 -1, %84
  %86 = icmp eq i64 %83, 0
  %87 = select i1 %86, i64 0, i64 %85
  %88 = or i64 %82, %87
  store i64 %88, ptr %81, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %89 = lshr i64 %last_valid.i.i.i, 6
  %90 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %89
  %91 = load i64, ptr %90, align 4
  %92 = and i64 %last_valid.i.i.i, 63
  %93 = shl nsw i64 -2, %92
  %94 = icmp eq i64 %92, 63
  %95 = select i1 %94, i64 0, i64 %93
  %96 = or i64 %91, %95
  store i64 %96, ptr %90, align 4
  %reass.sub.i.i.i = sub nsw i64 %89, %80
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit", label %mask_block_ok.i.i.i

97:                                               ; preds = %mask_block_ok.i.i.i
  %98 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %79, %97
  %.02.i.i.i = phi i64 [ %98, %97 ], [ 0, %79 ]
  %gep.i.i.i = getelementptr i64, ptr %81, i64 %.02.i.i.i
  %99 = load i64, ptr %gep.i.i.i, align 4
  %100 = icmp eq i64 %99, -1
  br i1 %100, label %97, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit697
  %.fca.2.extract.i181.i = phi i64 [ 0, %__barray_mask_return.exit697 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %5, %__barray_mask_return.exit697 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %4, %__barray_mask_return.exit697 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"239_0.sroa.15.0178.i" = phi i64 [ 0, %__barray_mask_return.exit697 ], [ %101, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %76, %__barray_mask_return.exit697 ], [ %116, %loop_body.i ]
  %101 = add nuw nsw i64 %"239_0.sroa.15.0178.i", 1
  %102 = add i64 %"239_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %103 = lshr i64 %102, 6
  %104 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %103
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
  %111 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %102
  %112 = load i64, ptr %111, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %112)
  tail call void @___qfree(i64 %112)
  %113 = load i64, ptr %78, align 4
  %114 = lshr i64 %113, %"239_0.sroa.15.0178.i"
  %115 = trunc i64 %114 to i1
  br i1 %115, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %116 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %101, 1
  %117 = shl nuw nsw i64 1, %"239_0.sroa.15.0178.i"
  %118 = xor i64 %113, %117
  store i64 %118, ptr %78, align 4
  %119 = getelementptr inbounds nuw i64, ptr %77, i64 %"239_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %119, align 4
  %120 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %120, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %120, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %120, 2
  %exitcond.not.i = icmp eq i64 %101, 10
  br i1 %exitcond.not.i, label %79, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.225.exit": ; preds = %97, %79
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %77, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %78, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %121 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %122 = tail call ptr @heap_alloc(i64 10)
  %123 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %123, align 1
  br label %__barray_check_bounds.exit.i.i698

loop_body.preheader.i.i:                          ; preds = %loop_body.i701
  %"545_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %181, 2
  %"545_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %181, 1
  %"545_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %181, 0
  br label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i.i698:                ; preds = %loop_body.i701, %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit"
  %124 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit" ], [ %181, %loop_body.i701 ]
  %"280_0.sroa.15.0168.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit" ], [ %125, %loop_body.i701 ]
  %.pn159167.i = phi { { ptr, ptr, i64 }, i64 } [ %121, %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit" ], [ %177, %loop_body.i701 ]
  %125 = add nuw nsw i64 %"280_0.sroa.15.0168.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %124, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %124, 1
  %126 = add i64 %.fca.2.extract208.i.i, %"280_0.sroa.15.0168.i"
  %127 = lshr i64 %126, 6
  %128 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %127
  %129 = load i64, ptr %128, align 4
  %130 = and i64 %126, 63
  %131 = lshr i64 %129, %130
  %132 = trunc i64 %131 to i1
  br i1 %132, label %panic.i.i.i714, label %__barray_check_bounds.exit221.i.i

panic.i.i.i714:                                   ; preds = %__barray_check_bounds.exit.i.i698
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i698
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %124, 0
  %133 = shl nuw i64 1, %130
  %134 = xor i64 %133, %129
  store i64 %134, ptr %128, align 4
  %135 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %126
  %136 = load i64, ptr %135, align 4
  tail call void @___inc_future_refcount(i64 %136)
  %137 = load i64, ptr %128, align 4
  %138 = lshr i64 %137, %130
  %139 = trunc i64 %138 to i1
  br i1 %139, label %__barray_check_bounds.exit.i699, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_548_case_0.i.i:                              ; preds = %cond_exit_548.thread.i.i
  %140 = lshr i64 %"545_1.sroa.10.0.i.i", 6
  %141 = getelementptr i64, ptr %"545_1.sroa.5.0.i.i", i64 %140
  %142 = load i64, ptr %141, align 4
  %143 = and i64 %"545_1.sroa.10.0.i.i", 63
  %144 = sub nuw nsw i64 64, %143
  %145 = lshr i64 -1, %144
  %146 = icmp eq i64 %143, 0
  %147 = select i1 %146, i64 0, i64 %145
  %148 = or i64 %142, %147
  store i64 %148, ptr %141, align 4
  %last_valid.i.i.i703 = add i64 %"545_1.sroa.10.0.i.i", 9
  %149 = lshr i64 %last_valid.i.i.i703, 6
  %150 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %149
  %151 = load i64, ptr %150, align 4
  %152 = and i64 %last_valid.i.i.i703, 63
  %153 = shl nsw i64 -2, %152
  %154 = icmp eq i64 %152, 63
  %155 = select i1 %154, i64 0, i64 %153
  %156 = or i64 %151, %155
  store i64 %156, ptr %150, align 4
  %reass.sub.i.i.i704 = sub nsw i64 %149, %140
  %.not.i.i.i705 = icmp eq i64 %reass.sub.i.i.i704, -1
  br i1 %.not.i.i.i705, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit", label %mask_block_ok.i.i.i706

157:                                              ; preds = %mask_block_ok.i.i.i706
  %158 = add nuw i64 %.02.i.i.i707, 1
  %exitcond.not.i.i.i710 = icmp eq i64 %.02.i.i.i707, %reass.sub.i.i.i704
  br i1 %exitcond.not.i.i.i710, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit", label %mask_block_ok.i.i.i706

mask_block_ok.i.i.i706:                           ; preds = %cond_548_case_0.i.i, %157
  %.02.i.i.i707 = phi i64 [ %158, %157 ], [ 0, %cond_548_case_0.i.i ]
  %gep.i.i.i708 = getelementptr i64, ptr %141, i64 %.02.i.i.i707
  %159 = load i64, ptr %gep.i.i.i708, align 4
  %160 = icmp eq i64 %159, -1
  br i1 %160, label %157, label %mask_block_err.i.i.i709

mask_block_err.i.i.i709:                          ; preds = %mask_block_ok.i.i.i706
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i.i:                ; preds = %cond_exit_548.thread.i.i, %loop_body.preheader.i.i
  %"545_0.0239.i.i" = phi i64 [ 0, %loop_body.preheader.i.i ], [ %161, %cond_exit_548.thread.i.i ]
  %161 = add nuw nsw i64 %"545_0.0239.i.i", 1
  %162 = add i64 %"545_0.0239.i.i", %"545_1.sroa.10.0.i.i"
  %163 = lshr i64 %162, 6
  %164 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %163
  %165 = load i64, ptr %164, align 4
  %166 = and i64 %162, 63
  %167 = lshr i64 %165, %166
  %168 = trunc i64 %167 to i1
  br i1 %168, label %cond_exit_548.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_mask_borrow.exit228.i.i:                 ; preds = %__barray_check_bounds.exit224.i.i
  %169 = shl nuw i64 1, %166
  %170 = xor i64 %169, %165
  store i64 %170, ptr %164, align 4
  %171 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %162
  %172 = load i64, ptr %171, align 4
  tail call void @___dec_future_refcount(i64 %172)
  br label %cond_exit_548.thread.i.i

cond_exit_548.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %__barray_check_bounds.exit224.i.i
  %exitcond.i.i = icmp eq i64 %161, 10
  br i1 %exitcond.i.i, label %cond_548_case_0.i.i, label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i699:                  ; preds = %__barray_check_bounds.exit221.i.i
  %173 = xor i64 %137, %133
  store i64 %173, ptr %128, align 4
  store i64 %136, ptr %135, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %136)
  tail call void @___dec_future_refcount(i64 %136)
  %174 = load i64, ptr %123, align 4
  %175 = lshr i64 %174, %"280_0.sroa.15.0168.i"
  %176 = trunc i64 %175 to i1
  br i1 %176, label %loop_body.i701, label %panic.i.i700

panic.i.i700:                                     ; preds = %__barray_check_bounds.exit.i699
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i701:                                   ; preds = %__barray_check_bounds.exit.i699
  %177 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, i64 %125, 1
  %178 = shl nuw nsw i64 1, %"280_0.sroa.15.0168.i"
  %179 = xor i64 %174, %178
  store i64 %179, ptr %123, align 4
  %180 = getelementptr inbounds nuw i1, ptr %122, i64 %"280_0.sroa.15.0168.i"
  store i1 %read_bool.i, ptr %180, align 1
  %181 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, 0
  %exitcond.not.i702 = icmp eq i64 %125, 10
  br i1 %exitcond.not.i702, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i698

"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit": ; preds = %157, %cond_548_case_0.i.i
  tail call void @heap_free(ptr %"545_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"545_1.sroa.5.0.i.i")
  %182 = load i64, ptr %123, align 4
  %183 = and i64 %182, 1023
  store i64 %183, ptr %123, align 4
  %184 = icmp eq i64 %183, 0
  br i1 %184, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit"
  %185 = tail call ptr @heap_alloc(i64 10)
  %186 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %186, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %185, ptr noundef nonnull align 1 dereferenceable(10) %122, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %185)
  %187 = load i64, ptr %123, align 4
  %188 = and i64 %187, 1023
  store i64 %188, ptr %123, align 4
  %189 = icmp eq i64 %188, 0
  br i1 %189, label %__barray_check_none_borrowed.exit720, label %mask_block_err.i718

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit720:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %190 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %190, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %122, ptr %arr_ptr, align 8
  store ptr %190, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  br label %__barray_check_bounds.exit728

mask_block_err.i718:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit728:                    ; preds = %cond_exit_94.1, %__barray_check_none_borrowed.exit720
  %"89_0.sroa.0.0778" = phi i64 [ 0, %__barray_check_none_borrowed.exit720 ], [ %207, %cond_exit_94.1 ]
  %191 = lshr i64 %"89_0.sroa.0.0778", 6
  %192 = getelementptr inbounds nuw i64, ptr %3, i64 %191
  %193 = load i64, ptr %192, align 4
  %194 = and i64 %"89_0.sroa.0.0778", 62
  %195 = lshr i64 %193, %194
  %196 = trunc i64 %195 to i1
  br i1 %196, label %cond_exit_94, label %panic.i729

panic.i729:                                       ; preds = %cond_exit_94, %__barray_check_bounds.exit728
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_94:                                     ; preds = %__barray_check_bounds.exit728
  %197 = or disjoint i64 %"89_0.sroa.0.0778", 1
  %198 = shl nuw nsw i64 1, %194
  %199 = xor i64 %193, %198
  store i64 %199, ptr %192, align 4
  %200 = getelementptr inbounds nuw i64, ptr %2, i64 %"89_0.sroa.0.0778"
  store i64 %"89_0.sroa.0.0778", ptr %200, align 4
  %201 = lshr i64 %"89_0.sroa.0.0778", 6
  %202 = getelementptr inbounds nuw i64, ptr %3, i64 %201
  %203 = load i64, ptr %202, align 4
  %204 = and i64 %197, 63
  %205 = lshr i64 %203, %204
  %206 = trunc i64 %205 to i1
  br i1 %206, label %cond_exit_94.1, label %panic.i729

cond_exit_94.1:                                   ; preds = %cond_exit_94
  %207 = add nuw nsw i64 %"89_0.sroa.0.0778", 2
  %208 = shl nuw i64 1, %204
  %209 = xor i64 %203, %208
  store i64 %209, ptr %202, align 4
  %210 = getelementptr inbounds nuw i64, ptr %2, i64 %197
  store i64 %197, ptr %210, align 4
  %exitcond781.not.1 = icmp eq i64 %207, 100
  br i1 %exitcond781.not.1, label %loop_out127, label %__barray_check_bounds.exit728

loop_out127:                                      ; preds = %cond_exit_94.1
  %211 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %212 = load i64, ptr %211, align 4
  %213 = and i64 %212, 68719476735
  store i64 %213, ptr %211, align 4
  %214 = load i64, ptr %3, align 4
  %215 = icmp eq i64 %214, 0
  %216 = icmp eq i64 %213, 0
  %or.cond = select i1 %215, i1 %216, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit735, label %mask_block_err.i733

__barray_check_none_borrowed.exit735:             ; preds = %loop_out127
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
  %or.cond783 = select i1 %222, i1 %223, i1 false
  br i1 %or.cond783, label %__barray_check_none_borrowed.exit740, label %mask_block_err.i738

mask_block_err.i733:                              ; preds = %loop_out127
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit740:             ; preds = %__barray_check_none_borrowed.exit735
  %out_arr_alloca203 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr205 = getelementptr inbounds nuw i8, ptr %out_arr_alloca203, i64 4
  %arr_ptr206 = getelementptr inbounds nuw i8, ptr %out_arr_alloca203, i64 8
  %mask_ptr207 = getelementptr inbounds nuw i8, ptr %out_arr_alloca203, i64 16
  %224 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %224, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca203, align 8
  store i32 1, ptr %y_ptr205, align 4
  store ptr %2, ptr %arr_ptr206, align 8
  store ptr %224, ptr %mask_ptr207, align 8
  call void @print_int_arr(ptr nonnull @res_is.F21393DB.0, i64 14, ptr nonnull %out_arr_alloca203)
  br label %__barray_check_bounds.exit748

mask_block_err.i738:                              ; preds = %__barray_check_none_borrowed.exit735
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit748:                    ; preds = %cond_exit_129, %__barray_check_none_borrowed.exit740
  %"124_0.sroa.0.0780" = phi i64 [ 0, %__barray_check_none_borrowed.exit740 ], [ %233, %cond_exit_129 ]
  %225 = lshr i64 %"124_0.sroa.0.0780", 6
  %226 = getelementptr inbounds nuw i64, ptr %1, i64 %225
  %227 = load i64, ptr %226, align 4
  %228 = and i64 %"124_0.sroa.0.0780", 63
  %229 = lshr i64 %227, %228
  %230 = trunc i64 %229 to i1
  br i1 %230, label %cond_exit_129, label %panic.i749

panic.i749:                                       ; preds = %__barray_check_bounds.exit748
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_129:                                    ; preds = %__barray_check_bounds.exit748
  %231 = uitofp nneg i64 %"124_0.sroa.0.0780" to double
  %232 = fmul double %231, 6.250000e-02
  %233 = add nuw nsw i64 %"124_0.sroa.0.0780", 1
  %234 = shl nuw i64 1, %228
  %235 = xor i64 %227, %234
  store i64 %235, ptr %226, align 4
  %236 = getelementptr inbounds nuw double, ptr %0, i64 %"124_0.sroa.0.0780"
  store double %232, ptr %236, align 8
  %exitcond782.not = icmp eq i64 %233, 100
  br i1 %exitcond782.not, label %loop_out211, label %__barray_check_bounds.exit748

loop_out211:                                      ; preds = %cond_exit_129
  %237 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %238 = load i64, ptr %237, align 4
  %239 = and i64 %238, 68719476735
  store i64 %239, ptr %237, align 4
  %240 = load i64, ptr %1, align 4
  %241 = icmp eq i64 %240, 0
  %242 = icmp eq i64 %239, 0
  %or.cond784 = select i1 %241, i1 %242, i1 false
  br i1 %or.cond784, label %__barray_check_none_borrowed.exit755, label %mask_block_err.i753

__barray_check_none_borrowed.exit755:             ; preds = %loop_out211
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
  %or.cond785 = select i1 %248, i1 %249, i1 false
  br i1 %or.cond785, label %__barray_check_none_borrowed.exit760, label %mask_block_err.i758

mask_block_err.i753:                              ; preds = %loop_out211
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit760:             ; preds = %__barray_check_none_borrowed.exit755
  %out_arr_alloca290 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr292 = getelementptr inbounds nuw i8, ptr %out_arr_alloca290, i64 4
  %arr_ptr293 = getelementptr inbounds nuw i8, ptr %out_arr_alloca290, i64 8
  %mask_ptr294 = getelementptr inbounds nuw i8, ptr %out_arr_alloca290, i64 16
  %250 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %250, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca290, align 8
  store i32 1, ptr %y_ptr292, align 4
  store ptr %0, ptr %arr_ptr293, align 8
  store ptr %250, ptr %mask_ptr294, align 8
  call void @print_float_arr(ptr nonnull @res_fs.CBD4AF54.0, i64 16, ptr nonnull %out_arr_alloca290)
  ret void

mask_block_err.i758:                              ; preds = %__barray_check_none_borrowed.exit755
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr

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

attributes #0 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #1 = { noreturn }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!name = !{!0}

!0 = !{!"mainlib"}
