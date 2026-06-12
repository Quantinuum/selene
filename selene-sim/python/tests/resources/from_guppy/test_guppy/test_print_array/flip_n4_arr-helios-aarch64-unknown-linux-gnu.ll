; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

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
  br i1 %not_max.not.not.i, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit

cond_525_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.498.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %6 = load i64, ptr %5, align 4
  %7 = trunc i64 %6 to i1
  br i1 %7, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_helios_qalloc.498.exit.8, %__hugr__.__tk2_helios_qalloc.498.exit.7, %__hugr__.__tk2_helios_qalloc.498.exit.6, %__hugr__.__tk2_helios_qalloc.498.exit.5, %__hugr__.__tk2_helios_qalloc.498.exit.4, %__hugr__.__tk2_helios_qalloc.498.exit.3, %__hugr__.__tk2_helios_qalloc.498.exit.2, %__hugr__.__tk2_helios_qalloc.498.exit.1, %__hugr__.__tk2_helios_qalloc.498.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.498.exit
  %8 = and i64 %6, -2
  store i64 %8, ptr %5, align 4
  store i64 %qalloc.i, ptr %4, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit.1

__hugr__.__tk2_helios_qalloc.498.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %9 = load i64, ptr %5, align 4
  %10 = and i64 %9, 2
  %.not781 = icmp eq i64 %10, 0
  br i1 %.not781, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.498.exit.1
  %11 = and i64 %9, -3
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %qalloc.i.1, ptr %12, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit.2

__hugr__.__tk2_helios_qalloc.498.exit.2:          ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %13 = load i64, ptr %5, align 4
  %14 = and i64 %13, 4
  %.not782 = icmp eq i64 %14, 0
  br i1 %.not782, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_helios_qalloc.498.exit.2
  %15 = and i64 %13, -5
  store i64 %15, ptr %5, align 4
  %16 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %qalloc.i.2, ptr %16, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit.3

__hugr__.__tk2_helios_qalloc.498.exit.3:          ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %17 = load i64, ptr %5, align 4
  %18 = and i64 %17, 8
  %.not783 = icmp eq i64 %18, 0
  br i1 %.not783, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_helios_qalloc.498.exit.3
  %19 = and i64 %17, -9
  store i64 %19, ptr %5, align 4
  %20 = getelementptr inbounds nuw i8, ptr %4, i64 24
  store i64 %qalloc.i.3, ptr %20, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit.4

__hugr__.__tk2_helios_qalloc.498.exit.4:          ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %21 = load i64, ptr %5, align 4
  %22 = and i64 %21, 16
  %.not784 = icmp eq i64 %22, 0
  br i1 %.not784, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_helios_qalloc.498.exit.4
  %23 = and i64 %21, -17
  store i64 %23, ptr %5, align 4
  %24 = getelementptr inbounds nuw i8, ptr %4, i64 32
  store i64 %qalloc.i.4, ptr %24, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit.5

__hugr__.__tk2_helios_qalloc.498.exit.5:          ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %25 = load i64, ptr %5, align 4
  %26 = and i64 %25, 32
  %.not785 = icmp eq i64 %26, 0
  br i1 %.not785, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_helios_qalloc.498.exit.5
  %27 = and i64 %25, -33
  store i64 %27, ptr %5, align 4
  %28 = getelementptr inbounds nuw i8, ptr %4, i64 40
  store i64 %qalloc.i.5, ptr %28, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit.6

__hugr__.__tk2_helios_qalloc.498.exit.6:          ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %29 = load i64, ptr %5, align 4
  %30 = and i64 %29, 64
  %.not786 = icmp eq i64 %30, 0
  br i1 %.not786, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_helios_qalloc.498.exit.6
  %31 = and i64 %29, -65
  store i64 %31, ptr %5, align 4
  %32 = getelementptr inbounds nuw i8, ptr %4, i64 48
  store i64 %qalloc.i.6, ptr %32, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit.7

__hugr__.__tk2_helios_qalloc.498.exit.7:          ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %33 = load i64, ptr %5, align 4
  %34 = and i64 %33, 128
  %.not787 = icmp eq i64 %34, 0
  br i1 %.not787, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__hugr__.__tk2_helios_qalloc.498.exit.7
  %35 = and i64 %33, -129
  store i64 %35, ptr %5, align 4
  %36 = getelementptr inbounds nuw i8, ptr %4, i64 56
  store i64 %qalloc.i.7, ptr %36, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_525_case_0.i, label %__hugr__.__tk2_helios_qalloc.498.exit.8

__hugr__.__tk2_helios_qalloc.498.exit.8:          ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %37 = load i64, ptr %5, align 4
  %38 = and i64 %37, 256
  %.not788 = icmp eq i64 %38, 0
  br i1 %.not788, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__hugr__.__tk2_helios_qalloc.498.exit.8
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
  %.not789 = icmp eq i64 %42, 0
  br i1 %.not789, label %panic.i, label %cond_exit_20.9

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
  %55 = load i64, ptr %16, align 4
  tail call void @___rxy(i64 %55, double 0x400921FB54442D18, double 0.000000e+00)
  %56 = load i64, ptr %5, align 4
  %57 = and i64 %56, 4
  %.not769 = icmp eq i64 %57, 0
  br i1 %.not769, label %panic.i688, label %__barray_mask_return.exit689

panic.i688:                                       ; preds = %__barray_mask_borrow.exit687
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit689:                     ; preds = %__barray_mask_borrow.exit687
  %58 = and i64 %56, -5
  store i64 %58, ptr %5, align 4
  store i64 %55, ptr %16, align 4
  %59 = load i64, ptr %5, align 4
  %60 = and i64 %59, 8
  %.not770 = icmp eq i64 %60, 0
  br i1 %.not770, label %__barray_mask_borrow.exit691, label %panic.i690

panic.i690:                                       ; preds = %__barray_mask_return.exit689
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit691:                     ; preds = %__barray_mask_return.exit689
  %61 = or disjoint i64 %59, 8
  store i64 %61, ptr %5, align 4
  %62 = load i64, ptr %20, align 4
  tail call void @___rxy(i64 %62, double 0x400921FB54442D18, double 0.000000e+00)
  %63 = load i64, ptr %5, align 4
  %64 = and i64 %63, 8
  %.not771 = icmp eq i64 %64, 0
  br i1 %.not771, label %panic.i692, label %__barray_mask_return.exit693

panic.i692:                                       ; preds = %__barray_mask_borrow.exit691
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit693:                     ; preds = %__barray_mask_borrow.exit691
  %65 = and i64 %63, -9
  store i64 %65, ptr %5, align 4
  store i64 %62, ptr %20, align 4
  %66 = load i64, ptr %5, align 4
  %67 = and i64 %66, 512
  %.not772 = icmp eq i64 %67, 0
  br i1 %.not772, label %__barray_mask_borrow.exit695, label %panic.i694

panic.i694:                                       ; preds = %__barray_mask_return.exit693
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit695:                     ; preds = %__barray_mask_return.exit693
  %68 = or disjoint i64 %66, 512
  store i64 %68, ptr %5, align 4
  %69 = load i64, ptr %44, align 4
  tail call void @___rxy(i64 %69, double 0x400921FB54442D18, double 0.000000e+00)
  %70 = load i64, ptr %5, align 4
  %71 = and i64 %70, 512
  %.not773 = icmp eq i64 %71, 0
  br i1 %.not773, label %panic.i696, label %__barray_mask_return.exit697

panic.i696:                                       ; preds = %__barray_mask_borrow.exit695
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit697:                     ; preds = %__barray_mask_borrow.exit695
  %72 = and i64 %70, -513
  store i64 %72, ptr %5, align 4
  store i64 %69, ptr %44, align 4
  %73 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"120.fca.2.insert", 0
  %74 = tail call ptr @heap_alloc(i64 80)
  %75 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %75, align 1
  br label %__barray_check_bounds.exit.i.i

76:                                               ; preds = %loop_body.i
  %77 = lshr i64 %.fca.2.extract.i.i, 6
  %78 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %77
  %79 = load i64, ptr %78, align 4
  %80 = and i64 %.fca.2.extract.i.i, 63
  %81 = sub nuw nsw i64 64, %80
  %82 = lshr i64 -1, %81
  %83 = icmp eq i64 %80, 0
  %84 = select i1 %83, i64 0, i64 %82
  %85 = or i64 %79, %84
  store i64 %85, ptr %78, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %86 = lshr i64 %last_valid.i.i.i, 6
  %87 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %86
  %88 = load i64, ptr %87, align 4
  %89 = and i64 %last_valid.i.i.i, 63
  %90 = shl nsw i64 -2, %89
  %91 = icmp eq i64 %89, 63
  %92 = select i1 %91, i64 0, i64 %90
  %93 = or i64 %88, %92
  store i64 %93, ptr %87, align 4
  %reass.sub.i.i.i = sub nsw i64 %86, %77
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit", label %mask_block_ok.i.i.i

94:                                               ; preds = %mask_block_ok.i.i.i
  %95 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %76, %94
  %.02.i.i.i = phi i64 [ %95, %94 ], [ 0, %76 ]
  %gep.i.i.i = getelementptr i64, ptr %78, i64 %.02.i.i.i
  %96 = load i64, ptr %gep.i.i.i, align 4
  %97 = icmp eq i64 %96, -1
  br i1 %97, label %94, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit697
  %.fca.2.extract.i181.i = phi i64 [ 0, %__barray_mask_return.exit697 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %5, %__barray_mask_return.exit697 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %4, %__barray_mask_return.exit697 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"239_0.sroa.15.0178.i" = phi i64 [ 0, %__barray_mask_return.exit697 ], [ %98, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %73, %__barray_mask_return.exit697 ], [ %113, %loop_body.i ]
  %98 = add nuw nsw i64 %"239_0.sroa.15.0178.i", 1
  %99 = add i64 %"239_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %100 = lshr i64 %99, 6
  %101 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %100
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
  %108 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %99
  %109 = load i64, ptr %108, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %109)
  tail call void @___qfree(i64 %109)
  %110 = load i64, ptr %75, align 4
  %111 = lshr i64 %110, %"239_0.sroa.15.0178.i"
  %112 = trunc i64 %111 to i1
  br i1 %112, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %113 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %98, 1
  %114 = shl nuw nsw i64 1, %"239_0.sroa.15.0178.i"
  %115 = xor i64 %110, %114
  store i64 %115, ptr %75, align 4
  %116 = getelementptr inbounds nuw i64, ptr %74, i64 %"239_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %116, align 4
  %117 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %117, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %117, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %117, 2
  %exitcond.not.i = icmp eq i64 %98, 10
  br i1 %exitcond.not.i, label %76, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.225.exit": ; preds = %94, %76
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %74, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %75, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %118 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %119 = tail call ptr @heap_alloc(i64 10)
  %120 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %120, align 1
  br label %__barray_check_bounds.exit.i.i698

loop_body.preheader.i.i:                          ; preds = %loop_body.i701
  %"545_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %269, 2
  %"545_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %269, 1
  %"545_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %269, 0
  %121 = lshr i64 %"545_1.sroa.10.0.i.i", 6
  %122 = getelementptr i64, ptr %"545_1.sroa.5.0.i.i", i64 %121
  %123 = load i64, ptr %122, align 4
  %124 = and i64 %"545_1.sroa.10.0.i.i", 63
  %125 = lshr i64 %123, %124
  %126 = trunc i64 %125 to i1
  br i1 %126, label %cond_exit_548.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_check_bounds.exit.i.i698:                ; preds = %loop_body.i701, %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit"
  %127 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit" ], [ %269, %loop_body.i701 ]
  %"280_0.sroa.15.0168.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit" ], [ %128, %loop_body.i701 ]
  %.pn159167.i = phi { { ptr, ptr, i64 }, i64 } [ %118, %"__hugr__.guppylang.std.quantum.measure_array$10.225.exit" ], [ %265, %loop_body.i701 ]
  %128 = add nuw nsw i64 %"280_0.sroa.15.0168.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %127, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %127, 1
  %129 = add i64 %.fca.2.extract208.i.i, %"280_0.sroa.15.0168.i"
  %130 = lshr i64 %129, 6
  %131 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %130
  %132 = load i64, ptr %131, align 4
  %133 = and i64 %129, 63
  %134 = lshr i64 %132, %133
  %135 = trunc i64 %134 to i1
  br i1 %135, label %panic.i.i.i713, label %__barray_check_bounds.exit221.i.i

panic.i.i.i713:                                   ; preds = %__barray_check_bounds.exit.i.i698
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i698
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %127, 0
  %136 = shl nuw i64 1, %133
  %137 = xor i64 %136, %132
  store i64 %137, ptr %131, align 4
  %138 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %129
  %139 = load i64, ptr %138, align 4
  tail call void @___inc_future_refcount(i64 %139)
  %140 = load i64, ptr %131, align 4
  %141 = lshr i64 %140, %133
  %142 = trunc i64 %141 to i1
  br i1 %142, label %__barray_check_bounds.exit.i699, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

143:                                              ; preds = %mask_block_ok.i.i.i705
  %144 = add nuw i64 %.02.i.i.i706, 1
  %exitcond.not.i.i.i709 = icmp eq i64 %.02.i.i.i706, %reass.sub.i.i.i703
  br i1 %exitcond.not.i.i.i709, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit", label %mask_block_ok.i.i.i705

mask_block_ok.i.i.i705:                           ; preds = %cond_exit_548.thread.9.i.i, %143
  %.02.i.i.i706 = phi i64 [ %144, %143 ], [ 0, %cond_exit_548.thread.9.i.i ]
  %gep.i.i.i707 = getelementptr i64, ptr %122, i64 %.02.i.i.i706
  %145 = load i64, ptr %gep.i.i.i707, align 4
  %146 = icmp eq i64 %145, -1
  br i1 %146, label %143, label %mask_block_err.i.i.i708

mask_block_err.i.i.i708:                          ; preds = %mask_block_ok.i.i.i705
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i.i:                 ; preds = %loop_body.preheader.i.i
  %147 = shl nuw i64 1, %124
  %148 = xor i64 %123, %147
  store i64 %148, ptr %122, align 4
  %149 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %"545_1.sroa.10.0.i.i"
  %150 = load i64, ptr %149, align 4
  tail call void @___dec_future_refcount(i64 %150)
  br label %cond_exit_548.thread.i.i

cond_exit_548.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %loop_body.preheader.i.i
  %151 = add i64 %"545_1.sroa.10.0.i.i", 1
  %152 = lshr i64 %151, 6
  %153 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %152
  %154 = load i64, ptr %153, align 4
  %155 = and i64 %151, 63
  %156 = lshr i64 %154, %155
  %157 = trunc i64 %156 to i1
  br i1 %157, label %cond_exit_548.thread.1.i.i, label %__barray_mask_borrow.exit228.1.i.i

__barray_mask_borrow.exit228.1.i.i:               ; preds = %cond_exit_548.thread.i.i
  %158 = shl nuw i64 1, %155
  %159 = xor i64 %154, %158
  store i64 %159, ptr %153, align 4
  %160 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %151
  %161 = load i64, ptr %160, align 4
  tail call void @___dec_future_refcount(i64 %161)
  br label %cond_exit_548.thread.1.i.i

cond_exit_548.thread.1.i.i:                       ; preds = %__barray_mask_borrow.exit228.1.i.i, %cond_exit_548.thread.i.i
  %162 = add i64 %"545_1.sroa.10.0.i.i", 2
  %163 = lshr i64 %162, 6
  %164 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %163
  %165 = load i64, ptr %164, align 4
  %166 = and i64 %162, 63
  %167 = lshr i64 %165, %166
  %168 = trunc i64 %167 to i1
  br i1 %168, label %cond_exit_548.thread.2.i.i, label %__barray_mask_borrow.exit228.2.i.i

__barray_mask_borrow.exit228.2.i.i:               ; preds = %cond_exit_548.thread.1.i.i
  %169 = shl nuw i64 1, %166
  %170 = xor i64 %165, %169
  store i64 %170, ptr %164, align 4
  %171 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %162
  %172 = load i64, ptr %171, align 4
  tail call void @___dec_future_refcount(i64 %172)
  br label %cond_exit_548.thread.2.i.i

cond_exit_548.thread.2.i.i:                       ; preds = %__barray_mask_borrow.exit228.2.i.i, %cond_exit_548.thread.1.i.i
  %173 = add i64 %"545_1.sroa.10.0.i.i", 3
  %174 = lshr i64 %173, 6
  %175 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %174
  %176 = load i64, ptr %175, align 4
  %177 = and i64 %173, 63
  %178 = lshr i64 %176, %177
  %179 = trunc i64 %178 to i1
  br i1 %179, label %cond_exit_548.thread.3.i.i, label %__barray_mask_borrow.exit228.3.i.i

__barray_mask_borrow.exit228.3.i.i:               ; preds = %cond_exit_548.thread.2.i.i
  %180 = shl nuw i64 1, %177
  %181 = xor i64 %176, %180
  store i64 %181, ptr %175, align 4
  %182 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %173
  %183 = load i64, ptr %182, align 4
  tail call void @___dec_future_refcount(i64 %183)
  br label %cond_exit_548.thread.3.i.i

cond_exit_548.thread.3.i.i:                       ; preds = %__barray_mask_borrow.exit228.3.i.i, %cond_exit_548.thread.2.i.i
  %184 = add i64 %"545_1.sroa.10.0.i.i", 4
  %185 = lshr i64 %184, 6
  %186 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %185
  %187 = load i64, ptr %186, align 4
  %188 = and i64 %184, 63
  %189 = lshr i64 %187, %188
  %190 = trunc i64 %189 to i1
  br i1 %190, label %cond_exit_548.thread.4.i.i, label %__barray_mask_borrow.exit228.4.i.i

__barray_mask_borrow.exit228.4.i.i:               ; preds = %cond_exit_548.thread.3.i.i
  %191 = shl nuw i64 1, %188
  %192 = xor i64 %187, %191
  store i64 %192, ptr %186, align 4
  %193 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %184
  %194 = load i64, ptr %193, align 4
  tail call void @___dec_future_refcount(i64 %194)
  br label %cond_exit_548.thread.4.i.i

cond_exit_548.thread.4.i.i:                       ; preds = %__barray_mask_borrow.exit228.4.i.i, %cond_exit_548.thread.3.i.i
  %195 = add i64 %"545_1.sroa.10.0.i.i", 5
  %196 = lshr i64 %195, 6
  %197 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %196
  %198 = load i64, ptr %197, align 4
  %199 = and i64 %195, 63
  %200 = lshr i64 %198, %199
  %201 = trunc i64 %200 to i1
  br i1 %201, label %cond_exit_548.thread.5.i.i, label %__barray_mask_borrow.exit228.5.i.i

__barray_mask_borrow.exit228.5.i.i:               ; preds = %cond_exit_548.thread.4.i.i
  %202 = shl nuw i64 1, %199
  %203 = xor i64 %198, %202
  store i64 %203, ptr %197, align 4
  %204 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %195
  %205 = load i64, ptr %204, align 4
  tail call void @___dec_future_refcount(i64 %205)
  br label %cond_exit_548.thread.5.i.i

cond_exit_548.thread.5.i.i:                       ; preds = %__barray_mask_borrow.exit228.5.i.i, %cond_exit_548.thread.4.i.i
  %206 = add i64 %"545_1.sroa.10.0.i.i", 6
  %207 = lshr i64 %206, 6
  %208 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %207
  %209 = load i64, ptr %208, align 4
  %210 = and i64 %206, 63
  %211 = lshr i64 %209, %210
  %212 = trunc i64 %211 to i1
  br i1 %212, label %cond_exit_548.thread.6.i.i, label %__barray_mask_borrow.exit228.6.i.i

__barray_mask_borrow.exit228.6.i.i:               ; preds = %cond_exit_548.thread.5.i.i
  %213 = shl nuw i64 1, %210
  %214 = xor i64 %209, %213
  store i64 %214, ptr %208, align 4
  %215 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %206
  %216 = load i64, ptr %215, align 4
  tail call void @___dec_future_refcount(i64 %216)
  br label %cond_exit_548.thread.6.i.i

cond_exit_548.thread.6.i.i:                       ; preds = %__barray_mask_borrow.exit228.6.i.i, %cond_exit_548.thread.5.i.i
  %217 = add i64 %"545_1.sroa.10.0.i.i", 7
  %218 = lshr i64 %217, 6
  %219 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %218
  %220 = load i64, ptr %219, align 4
  %221 = and i64 %217, 63
  %222 = lshr i64 %220, %221
  %223 = trunc i64 %222 to i1
  br i1 %223, label %cond_exit_548.thread.7.i.i, label %__barray_mask_borrow.exit228.7.i.i

__barray_mask_borrow.exit228.7.i.i:               ; preds = %cond_exit_548.thread.6.i.i
  %224 = shl nuw i64 1, %221
  %225 = xor i64 %220, %224
  store i64 %225, ptr %219, align 4
  %226 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %217
  %227 = load i64, ptr %226, align 4
  tail call void @___dec_future_refcount(i64 %227)
  br label %cond_exit_548.thread.7.i.i

cond_exit_548.thread.7.i.i:                       ; preds = %__barray_mask_borrow.exit228.7.i.i, %cond_exit_548.thread.6.i.i
  %228 = add i64 %"545_1.sroa.10.0.i.i", 8
  %229 = lshr i64 %228, 6
  %230 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %229
  %231 = load i64, ptr %230, align 4
  %232 = and i64 %228, 63
  %233 = lshr i64 %231, %232
  %234 = trunc i64 %233 to i1
  br i1 %234, label %cond_exit_548.thread.8.i.i, label %__barray_mask_borrow.exit228.8.i.i

__barray_mask_borrow.exit228.8.i.i:               ; preds = %cond_exit_548.thread.7.i.i
  %235 = shl nuw i64 1, %232
  %236 = xor i64 %231, %235
  store i64 %236, ptr %230, align 4
  %237 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %228
  %238 = load i64, ptr %237, align 4
  tail call void @___dec_future_refcount(i64 %238)
  br label %cond_exit_548.thread.8.i.i

cond_exit_548.thread.8.i.i:                       ; preds = %__barray_mask_borrow.exit228.8.i.i, %cond_exit_548.thread.7.i.i
  %239 = add i64 %"545_1.sroa.10.0.i.i", 9
  %240 = lshr i64 %239, 6
  %241 = getelementptr inbounds nuw i64, ptr %"545_1.sroa.5.0.i.i", i64 %240
  %242 = load i64, ptr %241, align 4
  %243 = and i64 %239, 63
  %244 = lshr i64 %242, %243
  %245 = trunc i64 %244 to i1
  br i1 %245, label %cond_exit_548.thread.9.i.i, label %__barray_mask_borrow.exit228.9.i.i

__barray_mask_borrow.exit228.9.i.i:               ; preds = %cond_exit_548.thread.8.i.i
  %246 = shl nuw i64 1, %243
  %247 = xor i64 %242, %246
  store i64 %247, ptr %241, align 4
  %248 = getelementptr inbounds i64, ptr %"545_1.sroa.0.0.i.i", i64 %239
  %249 = load i64, ptr %248, align 4
  tail call void @___dec_future_refcount(i64 %249)
  br label %cond_exit_548.thread.9.i.i

cond_exit_548.thread.9.i.i:                       ; preds = %__barray_mask_borrow.exit228.9.i.i, %cond_exit_548.thread.8.i.i
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
  %reass.sub.i.i.i703 = sub nsw i64 %240, %121
  %.not.i.i.i704 = icmp eq i64 %reass.sub.i.i.i703, -1
  br i1 %.not.i.i.i704, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit", label %mask_block_ok.i.i.i705

__barray_check_bounds.exit.i699:                  ; preds = %__barray_check_bounds.exit221.i.i
  %261 = xor i64 %140, %136
  store i64 %261, ptr %131, align 4
  store i64 %139, ptr %138, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %139)
  tail call void @___dec_future_refcount(i64 %139)
  %262 = load i64, ptr %120, align 4
  %263 = lshr i64 %262, %"280_0.sroa.15.0168.i"
  %264 = trunc i64 %263 to i1
  br i1 %264, label %loop_body.i701, label %panic.i.i700

panic.i.i700:                                     ; preds = %__barray_check_bounds.exit.i699
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i701:                                   ; preds = %__barray_check_bounds.exit.i699
  %265 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, i64 %128, 1
  %266 = shl nuw nsw i64 1, %"280_0.sroa.15.0168.i"
  %267 = xor i64 %262, %266
  store i64 %267, ptr %120, align 4
  %268 = getelementptr inbounds nuw i1, ptr %119, i64 %"280_0.sroa.15.0168.i"
  store i1 %read_bool.i, ptr %268, align 1
  %269 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, 0
  %exitcond.not.i702 = icmp eq i64 %128, 10
  br i1 %exitcond.not.i702, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i698

"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit": ; preds = %143, %cond_exit_548.thread.9.i.i
  tail call void @heap_free(ptr %"545_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"545_1.sroa.5.0.i.i")
  %270 = load i64, ptr %120, align 4
  %271 = and i64 %270, 1023
  store i64 %271, ptr %120, align 4
  %272 = icmp eq i64 %271, 0
  br i1 %272, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit"
  %273 = tail call ptr @heap_alloc(i64 10)
  %274 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %274, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %273, ptr noundef nonnull align 1 dereferenceable(10) %119, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %273)
  %275 = load i64, ptr %120, align 4
  %276 = and i64 %275, 1023
  store i64 %276, ptr %120, align 4
  %277 = icmp eq i64 %276, 0
  br i1 %277, label %__barray_check_none_borrowed.exit719, label %mask_block_err.i717

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.266.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit719:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %278 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %278, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %119, ptr %arr_ptr, align 8
  store ptr %278, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  br label %__barray_check_bounds.exit727

mask_block_err.i717:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit727:                    ; preds = %cond_exit_94, %__barray_check_none_borrowed.exit719
  %"89_0.sroa.0.0777" = phi i64 [ 0, %__barray_check_none_borrowed.exit719 ], [ %285, %cond_exit_94 ]
  %279 = lshr i64 %"89_0.sroa.0.0777", 6
  %280 = getelementptr inbounds nuw i64, ptr %3, i64 %279
  %281 = load i64, ptr %280, align 4
  %282 = and i64 %"89_0.sroa.0.0777", 63
  %283 = lshr i64 %281, %282
  %284 = trunc i64 %283 to i1
  br i1 %284, label %cond_exit_94, label %panic.i728

panic.i728:                                       ; preds = %__barray_check_bounds.exit727
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_94:                                     ; preds = %__barray_check_bounds.exit727
  %285 = add nuw nsw i64 %"89_0.sroa.0.0777", 1
  %286 = shl nuw i64 1, %282
  %287 = xor i64 %281, %286
  store i64 %287, ptr %280, align 4
  %288 = getelementptr inbounds nuw i64, ptr %2, i64 %"89_0.sroa.0.0777"
  store i64 %"89_0.sroa.0.0777", ptr %288, align 4
  %exitcond.not = icmp eq i64 %285, 100
  br i1 %exitcond.not, label %loop_out127, label %__barray_check_bounds.exit727

loop_out127:                                      ; preds = %cond_exit_94
  %289 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %290 = load i64, ptr %289, align 4
  %291 = and i64 %290, 68719476735
  store i64 %291, ptr %289, align 4
  %292 = load i64, ptr %3, align 4
  %293 = icmp eq i64 %292, 0
  %294 = icmp eq i64 %291, 0
  %or.cond = select i1 %293, i1 %294, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit734, label %mask_block_err.i732

__barray_check_none_borrowed.exit734:             ; preds = %loop_out127
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
  %or.cond790 = select i1 %300, i1 %301, i1 false
  br i1 %or.cond790, label %__barray_check_none_borrowed.exit739, label %mask_block_err.i737

mask_block_err.i732:                              ; preds = %loop_out127
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit739:             ; preds = %__barray_check_none_borrowed.exit734
  %out_arr_alloca203 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr205 = getelementptr inbounds nuw i8, ptr %out_arr_alloca203, i64 4
  %arr_ptr206 = getelementptr inbounds nuw i8, ptr %out_arr_alloca203, i64 8
  %mask_ptr207 = getelementptr inbounds nuw i8, ptr %out_arr_alloca203, i64 16
  %302 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %302, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca203, align 8
  store i32 1, ptr %y_ptr205, align 4
  store ptr %2, ptr %arr_ptr206, align 8
  store ptr %302, ptr %mask_ptr207, align 8
  call void @print_int_arr(ptr nonnull @res_is.F21393DB.0, i64 14, ptr nonnull %out_arr_alloca203)
  br label %__barray_check_bounds.exit747

mask_block_err.i737:                              ; preds = %__barray_check_none_borrowed.exit734
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit747:                    ; preds = %cond_exit_129, %__barray_check_none_borrowed.exit739
  %"124_0.sroa.0.0779" = phi i64 [ 0, %__barray_check_none_borrowed.exit739 ], [ %311, %cond_exit_129 ]
  %303 = lshr i64 %"124_0.sroa.0.0779", 6
  %304 = getelementptr inbounds nuw i64, ptr %1, i64 %303
  %305 = load i64, ptr %304, align 4
  %306 = and i64 %"124_0.sroa.0.0779", 63
  %307 = lshr i64 %305, %306
  %308 = trunc i64 %307 to i1
  br i1 %308, label %cond_exit_129, label %panic.i748

panic.i748:                                       ; preds = %__barray_check_bounds.exit747
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_129:                                    ; preds = %__barray_check_bounds.exit747
  %309 = uitofp nneg i64 %"124_0.sroa.0.0779" to double
  %310 = fmul double %309, 6.250000e-02
  %311 = add nuw nsw i64 %"124_0.sroa.0.0779", 1
  %312 = shl nuw i64 1, %306
  %313 = xor i64 %305, %312
  store i64 %313, ptr %304, align 4
  %314 = getelementptr inbounds nuw double, ptr %0, i64 %"124_0.sroa.0.0779"
  store double %310, ptr %314, align 8
  %exitcond780.not = icmp eq i64 %311, 100
  br i1 %exitcond780.not, label %loop_out211, label %__barray_check_bounds.exit747

loop_out211:                                      ; preds = %cond_exit_129
  %315 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %316 = load i64, ptr %315, align 4
  %317 = and i64 %316, 68719476735
  store i64 %317, ptr %315, align 4
  %318 = load i64, ptr %1, align 4
  %319 = icmp eq i64 %318, 0
  %320 = icmp eq i64 %317, 0
  %or.cond791 = select i1 %319, i1 %320, i1 false
  br i1 %or.cond791, label %__barray_check_none_borrowed.exit754, label %mask_block_err.i752

__barray_check_none_borrowed.exit754:             ; preds = %loop_out211
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
  %or.cond792 = select i1 %326, i1 %327, i1 false
  br i1 %or.cond792, label %__barray_check_none_borrowed.exit759, label %mask_block_err.i757

mask_block_err.i752:                              ; preds = %loop_out211
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit759:             ; preds = %__barray_check_none_borrowed.exit754
  %out_arr_alloca290 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr292 = getelementptr inbounds nuw i8, ptr %out_arr_alloca290, i64 4
  %arr_ptr293 = getelementptr inbounds nuw i8, ptr %out_arr_alloca290, i64 8
  %mask_ptr294 = getelementptr inbounds nuw i8, ptr %out_arr_alloca290, i64 16
  %328 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %328, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca290, align 8
  store i32 1, ptr %y_ptr292, align 4
  store ptr %0, ptr %arr_ptr293, align 8
  store ptr %328, ptr %mask_ptr294, align 8
  call void @print_float_arr(ptr nonnull @res_fs.CBD4AF54.0, i64 16, ptr nonnull %out_arr_alloca290)
  ret void

mask_block_err.i757:                              ; preds = %__barray_check_none_borrowed.exit754
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
