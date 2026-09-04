; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_cs.46C3C4B5.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:cs"
@res_is.F21393DB.0 = private constant [15 x i8] c"\0EUSER:INTARR:is"
@res_fs.CBD4AF54.0 = private constant [17 x i8] c"\10USER:FLOATARR:fs"
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
  %6 = tail call ptr @heap_alloc(i64 800)
  %7 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %7, i8 -1, i64 16, i1 false)
  %8 = tail call ptr @heap_alloc(i64 80)
  %9 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %9, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit

cond_557_case_0.i:                                ; preds = %cond_exit_12.8, %cond_exit_12.7, %cond_exit_12.6, %cond_exit_12.5, %cond_exit_12.4, %cond_exit_12.3, %cond_exit_12.2, %cond_exit_12.1, %cond_exit_12, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.553.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %10 = load i64, ptr %9, align 4
  %11 = trunc i64 %10 to i1
  br i1 %11, label %cond_exit_12, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_helios_qalloc.553.exit.8, %__hugr__.__tk2_helios_qalloc.553.exit.7, %__hugr__.__tk2_helios_qalloc.553.exit.6, %__hugr__.__tk2_helios_qalloc.553.exit.5, %__hugr__.__tk2_helios_qalloc.553.exit.4, %__hugr__.__tk2_helios_qalloc.553.exit.3, %__hugr__.__tk2_helios_qalloc.553.exit.2, %__hugr__.__tk2_helios_qalloc.553.exit.1, %__hugr__.__tk2_helios_qalloc.553.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_12:                                     ; preds = %__hugr__.__tk2_helios_qalloc.553.exit
  %12 = and i64 %10, -2
  store i64 %12, ptr %9, align 4
  store i64 %qalloc.i, ptr %8, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit.1

__hugr__.__tk2_helios_qalloc.553.exit.1:          ; preds = %cond_exit_12
  tail call void @___reset(i64 %qalloc.i.1)
  %13 = load i64, ptr %9, align 4
  %14 = and i64 %13, 2
  %.not1714 = icmp eq i64 %14, 0
  br i1 %.not1714, label %panic.i, label %cond_exit_12.1

cond_exit_12.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.553.exit.1
  %15 = and i64 %13, -3
  store i64 %15, ptr %9, align 4
  %16 = getelementptr inbounds nuw i8, ptr %8, i64 8
  store i64 %qalloc.i.1, ptr %16, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit.2

__hugr__.__tk2_helios_qalloc.553.exit.2:          ; preds = %cond_exit_12.1
  tail call void @___reset(i64 %qalloc.i.2)
  %17 = load i64, ptr %9, align 4
  %18 = and i64 %17, 4
  %.not1715 = icmp eq i64 %18, 0
  br i1 %.not1715, label %panic.i, label %cond_exit_12.2

cond_exit_12.2:                                   ; preds = %__hugr__.__tk2_helios_qalloc.553.exit.2
  %19 = and i64 %17, -5
  store i64 %19, ptr %9, align 4
  %20 = getelementptr inbounds nuw i8, ptr %8, i64 16
  store i64 %qalloc.i.2, ptr %20, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit.3

__hugr__.__tk2_helios_qalloc.553.exit.3:          ; preds = %cond_exit_12.2
  tail call void @___reset(i64 %qalloc.i.3)
  %21 = load i64, ptr %9, align 4
  %22 = and i64 %21, 8
  %.not1716 = icmp eq i64 %22, 0
  br i1 %.not1716, label %panic.i, label %cond_exit_12.3

cond_exit_12.3:                                   ; preds = %__hugr__.__tk2_helios_qalloc.553.exit.3
  %23 = and i64 %21, -9
  store i64 %23, ptr %9, align 4
  %24 = getelementptr inbounds nuw i8, ptr %8, i64 24
  store i64 %qalloc.i.3, ptr %24, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit.4

__hugr__.__tk2_helios_qalloc.553.exit.4:          ; preds = %cond_exit_12.3
  tail call void @___reset(i64 %qalloc.i.4)
  %25 = load i64, ptr %9, align 4
  %26 = and i64 %25, 16
  %.not1717 = icmp eq i64 %26, 0
  br i1 %.not1717, label %panic.i, label %cond_exit_12.4

cond_exit_12.4:                                   ; preds = %__hugr__.__tk2_helios_qalloc.553.exit.4
  %27 = and i64 %25, -17
  store i64 %27, ptr %9, align 4
  %28 = getelementptr inbounds nuw i8, ptr %8, i64 32
  store i64 %qalloc.i.4, ptr %28, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit.5

__hugr__.__tk2_helios_qalloc.553.exit.5:          ; preds = %cond_exit_12.4
  tail call void @___reset(i64 %qalloc.i.5)
  %29 = load i64, ptr %9, align 4
  %30 = and i64 %29, 32
  %.not1718 = icmp eq i64 %30, 0
  br i1 %.not1718, label %panic.i, label %cond_exit_12.5

cond_exit_12.5:                                   ; preds = %__hugr__.__tk2_helios_qalloc.553.exit.5
  %31 = and i64 %29, -33
  store i64 %31, ptr %9, align 4
  %32 = getelementptr inbounds nuw i8, ptr %8, i64 40
  store i64 %qalloc.i.5, ptr %32, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit.6

__hugr__.__tk2_helios_qalloc.553.exit.6:          ; preds = %cond_exit_12.5
  tail call void @___reset(i64 %qalloc.i.6)
  %33 = load i64, ptr %9, align 4
  %34 = and i64 %33, 64
  %.not1719 = icmp eq i64 %34, 0
  br i1 %.not1719, label %panic.i, label %cond_exit_12.6

cond_exit_12.6:                                   ; preds = %__hugr__.__tk2_helios_qalloc.553.exit.6
  %35 = and i64 %33, -65
  store i64 %35, ptr %9, align 4
  %36 = getelementptr inbounds nuw i8, ptr %8, i64 48
  store i64 %qalloc.i.6, ptr %36, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit.7

__hugr__.__tk2_helios_qalloc.553.exit.7:          ; preds = %cond_exit_12.6
  tail call void @___reset(i64 %qalloc.i.7)
  %37 = load i64, ptr %9, align 4
  %38 = and i64 %37, 128
  %.not1720 = icmp eq i64 %38, 0
  br i1 %.not1720, label %panic.i, label %cond_exit_12.7

cond_exit_12.7:                                   ; preds = %__hugr__.__tk2_helios_qalloc.553.exit.7
  %39 = and i64 %37, -129
  store i64 %39, ptr %9, align 4
  %40 = getelementptr inbounds nuw i8, ptr %8, i64 56
  store i64 %qalloc.i.7, ptr %40, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_557_case_0.i, label %__hugr__.__tk2_helios_qalloc.553.exit.8

__hugr__.__tk2_helios_qalloc.553.exit.8:          ; preds = %cond_exit_12.7
  tail call void @___reset(i64 %qalloc.i.8)
  %41 = load i64, ptr %9, align 4
  %42 = and i64 %41, 256
  %.not1721 = icmp eq i64 %42, 0
  br i1 %.not1721, label %panic.i, label %cond_exit_12.8

cond_exit_12.8:                                   ; preds = %__hugr__.__tk2_helios_qalloc.553.exit.8
  %43 = and i64 %41, -257
  store i64 %43, ptr %9, align 4
  %44 = getelementptr inbounds nuw i8, ptr %8, i64 64
  store i64 %qalloc.i.8, ptr %44, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_557_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_12.8
  tail call void @___reset(i64 %qalloc.i.9)
  %45 = load i64, ptr %9, align 4
  %46 = and i64 %45, 512
  %.not1722 = icmp eq i64 %46, 0
  br i1 %.not1722, label %panic.i, label %cond_exit_12.9

cond_exit_12.9:                                   ; preds = %__barray_check_bounds.exit.9
  %47 = and i64 %45, -513
  store i64 %47, ptr %9, align 4
  %48 = getelementptr inbounds nuw i8, ptr %8, i64 72
  store i64 %qalloc.i.9, ptr %48, align 4
  %49 = load i64, ptr %9, align 4
  %50 = trunc i64 %49 to i1
  br i1 %50, label %panic.i1600, label %__barray_mask_borrow.exit

panic.i1600:                                      ; preds = %cond_exit_12.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_12.9
  %51 = or disjoint i64 %49, 1
  store i64 %51, ptr %9, align 4
  %52 = load i64, ptr %8, align 4
  tail call void @___rxy(i64 %52, double 0x400921FB54442D18, double 0.000000e+00)
  %53 = load i64, ptr %9, align 4
  %54 = trunc i64 %53 to i1
  br i1 %54, label %__barray_mask_return.exit1602, label %panic.i1601

panic.i1601:                                      ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1602:                    ; preds = %__barray_mask_borrow.exit
  %55 = and i64 %53, -2
  store i64 %55, ptr %9, align 4
  store i64 %52, ptr %8, align 4
  %56 = load i64, ptr %9, align 4
  %57 = and i64 %56, 4
  %.not = icmp eq i64 %57, 0
  br i1 %.not, label %__barray_mask_borrow.exit1604, label %panic.i1603

panic.i1603:                                      ; preds = %__barray_mask_return.exit1602
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1604:                    ; preds = %__barray_mask_return.exit1602
  %58 = or disjoint i64 %56, 4
  store i64 %58, ptr %9, align 4
  %59 = load i64, ptr %20, align 4
  tail call void @___rxy(i64 %59, double 0x400921FB54442D18, double 0.000000e+00)
  %60 = load i64, ptr %9, align 4
  %61 = and i64 %60, 4
  %.not1701 = icmp eq i64 %61, 0
  br i1 %.not1701, label %panic.i1605, label %__barray_mask_return.exit1606

panic.i1605:                                      ; preds = %__barray_mask_borrow.exit1604
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1606:                    ; preds = %__barray_mask_borrow.exit1604
  %62 = and i64 %60, -5
  store i64 %62, ptr %9, align 4
  store i64 %59, ptr %20, align 4
  %63 = load i64, ptr %9, align 4
  %64 = and i64 %63, 8
  %.not1702 = icmp eq i64 %64, 0
  br i1 %.not1702, label %__barray_mask_borrow.exit1608, label %panic.i1607

panic.i1607:                                      ; preds = %__barray_mask_return.exit1606
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1608:                    ; preds = %__barray_mask_return.exit1606
  %65 = or disjoint i64 %63, 8
  store i64 %65, ptr %9, align 4
  %66 = load i64, ptr %24, align 4
  tail call void @___rxy(i64 %66, double 0x400921FB54442D18, double 0.000000e+00)
  %67 = load i64, ptr %9, align 4
  %68 = and i64 %67, 8
  %.not1703 = icmp eq i64 %68, 0
  br i1 %.not1703, label %panic.i1609, label %__barray_mask_return.exit1610

panic.i1609:                                      ; preds = %__barray_mask_borrow.exit1608
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1610:                    ; preds = %__barray_mask_borrow.exit1608
  %69 = and i64 %67, -9
  store i64 %69, ptr %9, align 4
  store i64 %66, ptr %24, align 4
  %70 = load i64, ptr %9, align 4
  %71 = and i64 %70, 512
  %.not1704 = icmp eq i64 %71, 0
  br i1 %.not1704, label %__barray_mask_borrow.exit1612, label %panic.i1611

panic.i1611:                                      ; preds = %__barray_mask_return.exit1610
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1612:                    ; preds = %__barray_mask_return.exit1610
  %72 = or disjoint i64 %70, 512
  store i64 %72, ptr %9, align 4
  %73 = load i64, ptr %48, align 4
  tail call void @___rxy(i64 %73, double 0x400921FB54442D18, double 0.000000e+00)
  %74 = load i64, ptr %9, align 4
  %75 = and i64 %74, 512
  %.not1705 = icmp eq i64 %75, 0
  br i1 %.not1705, label %panic.i1613, label %__barray_mask_return.exit1614

panic.i1613:                                      ; preds = %__barray_mask_borrow.exit1612
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1614:                    ; preds = %__barray_mask_borrow.exit1612
  %76 = and i64 %74, -513
  store i64 %76, ptr %9, align 4
  store i64 %73, ptr %48, align 4
  br label %__barray_check_bounds.exit1620

out_of_bounds.i1615:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1616:                   ; preds = %.thread
  %77 = load i64, ptr %3, align 4
  %78 = lshr i64 %77, %"363_2.01729"
  %79 = trunc i64 %78 to i1
  br i1 %79, label %cond_exit_367, label %panic.i1617

panic.i1617:                                      ; preds = %__barray_check_bounds.exit1616
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_367
  %80 = load i64, ptr %9, align 4
  %81 = or i64 %80, -1024
  store i64 %81, ptr %9, align 4
  %82 = icmp eq i64 %81, -1
  br i1 %82, label %loop_body311.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1620:                   ; preds = %__barray_mask_return.exit1614, %cond_exit_367
  %"363_0.sroa.15.01730" = phi i64 [ 0, %__barray_mask_return.exit1614 ], [ %83, %cond_exit_367 ]
  %"363_2.01729" = phi i64 [ 0, %__barray_mask_return.exit1614 ], [ %91, %cond_exit_367 ]
  %83 = add nuw nsw i64 %"363_0.sroa.15.01730", 1
  %84 = load i64, ptr %9, align 4
  %85 = lshr i64 %84, %"363_0.sroa.15.01730"
  %86 = trunc i64 %85 to i1
  br i1 %86, label %panic.i1621, label %.thread

panic.i1621:                                      ; preds = %__barray_check_bounds.exit1620
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_check_bounds.exit1620
  %87 = shl nuw nsw i64 1, %"363_0.sroa.15.01730"
  %88 = xor i64 %84, %87
  store i64 %88, ptr %9, align 4
  %89 = getelementptr inbounds nuw i64, ptr %8, i64 %"363_0.sroa.15.01730"
  %90 = load i64, ptr %89, align 4
  %91 = add i64 %"363_2.01729", 1
  %lazy_measure = tail call i64 @___lazy_measure(i64 %90)
  tail call void @___qfree(i64 %90)
  %92 = icmp ult i64 %"363_2.01729", 10
  br i1 %92, label %__barray_check_bounds.exit1616, label %out_of_bounds.i1615

cond_exit_367:                                    ; preds = %__barray_check_bounds.exit1616
  %93 = shl nuw nsw i64 1, %"363_2.01729"
  %94 = xor i64 %77, %93
  store i64 %94, ptr %3, align 4
  %95 = getelementptr inbounds nuw i64, ptr %2, i64 %"363_2.01729"
  store i64 %lazy_measure, ptr %95, align 4
  %96 = icmp samesign ugt i64 %"363_0.sroa.15.01730", 8
  br i1 %96, label %mask_block_ok.i, label %__barray_check_bounds.exit1620

loop_body311.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %8)
  tail call void @heap_free(ptr nonnull %9)
  br label %__barray_check_bounds.exit1624

__barray_check_bounds.exit1624:                   ; preds = %cond_exit_433, %loop_body311.preheader.preheader
  %"429_0.sroa.15.01708" = phi i64 [ %97, %cond_exit_433 ], [ 0, %loop_body311.preheader.preheader ]
  %97 = add nuw nsw i64 %"429_0.sroa.15.01708", 1
  %98 = load i64, ptr %3, align 4
  %99 = lshr i64 %98, %"429_0.sroa.15.01708"
  %100 = trunc i64 %99 to i1
  br i1 %100, label %panic.i1625, label %__barray_check_bounds.exit1628

panic.i1625:                                      ; preds = %__barray_check_bounds.exit1624
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1628:                   ; preds = %__barray_check_bounds.exit1624
  %101 = shl nuw nsw i64 1, %"429_0.sroa.15.01708"
  %102 = xor i64 %98, %101
  store i64 %102, ptr %3, align 4
  %103 = getelementptr inbounds nuw i64, ptr %2, i64 %"429_0.sroa.15.01708"
  %104 = load i64, ptr %103, align 4
  tail call void @___inc_future_refcount(i64 %104)
  %105 = load i64, ptr %3, align 4
  %106 = lshr i64 %105, %"429_0.sroa.15.01708"
  %107 = trunc i64 %106 to i1
  br i1 %107, label %__barray_check_bounds.exit1632, label %panic.i1629

panic.i1629:                                      ; preds = %__barray_check_bounds.exit1628
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1632:                   ; preds = %__barray_check_bounds.exit1628
  %108 = xor i64 %105, %101
  store i64 %108, ptr %3, align 4
  store i64 %104, ptr %103, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %104)
  tail call void @___dec_future_refcount(i64 %104)
  %109 = load i64, ptr %1, align 4
  %110 = lshr i64 %109, %"429_0.sroa.15.01708"
  %111 = trunc i64 %110 to i1
  br i1 %111, label %cond_exit_433, label %panic.i1633

panic.i1633:                                      ; preds = %__barray_check_bounds.exit1632
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_err.i1638:                             ; preds = %cond_exit_603.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit1646:                    ; preds = %__barray_check_bounds.exit1642.preheader
  %112 = or disjoint i64 %165, 1
  store i64 %112, ptr %3, align 4
  %113 = load i64, ptr %2, align 4
  tail call void @___dec_future_refcount(i64 %113)
  br label %cond_exit_603

cond_exit_603:                                    ; preds = %__barray_mask_borrow.exit1646, %__barray_check_bounds.exit1642.preheader
  %114 = load i64, ptr %3, align 4
  %115 = and i64 %114, 2
  %.not1732 = icmp eq i64 %115, 0
  br i1 %.not1732, label %__barray_mask_borrow.exit1646.1, label %cond_exit_603.1

__barray_mask_borrow.exit1646.1:                  ; preds = %cond_exit_603
  %116 = or disjoint i64 %114, 2
  store i64 %116, ptr %3, align 4
  %117 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %118 = load i64, ptr %117, align 4
  tail call void @___dec_future_refcount(i64 %118)
  br label %cond_exit_603.1

cond_exit_603.1:                                  ; preds = %__barray_mask_borrow.exit1646.1, %cond_exit_603
  %119 = load i64, ptr %3, align 4
  %120 = and i64 %119, 4
  %.not1733 = icmp eq i64 %120, 0
  br i1 %.not1733, label %__barray_mask_borrow.exit1646.2, label %cond_exit_603.2

__barray_mask_borrow.exit1646.2:                  ; preds = %cond_exit_603.1
  %121 = or disjoint i64 %119, 4
  store i64 %121, ptr %3, align 4
  %122 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %123 = load i64, ptr %122, align 4
  tail call void @___dec_future_refcount(i64 %123)
  br label %cond_exit_603.2

cond_exit_603.2:                                  ; preds = %__barray_mask_borrow.exit1646.2, %cond_exit_603.1
  %124 = load i64, ptr %3, align 4
  %125 = and i64 %124, 8
  %.not1734 = icmp eq i64 %125, 0
  br i1 %.not1734, label %__barray_mask_borrow.exit1646.3, label %cond_exit_603.3

__barray_mask_borrow.exit1646.3:                  ; preds = %cond_exit_603.2
  %126 = or disjoint i64 %124, 8
  store i64 %126, ptr %3, align 4
  %127 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %128 = load i64, ptr %127, align 4
  tail call void @___dec_future_refcount(i64 %128)
  br label %cond_exit_603.3

cond_exit_603.3:                                  ; preds = %__barray_mask_borrow.exit1646.3, %cond_exit_603.2
  %129 = load i64, ptr %3, align 4
  %130 = and i64 %129, 16
  %.not1735 = icmp eq i64 %130, 0
  br i1 %.not1735, label %__barray_mask_borrow.exit1646.4, label %cond_exit_603.4

__barray_mask_borrow.exit1646.4:                  ; preds = %cond_exit_603.3
  %131 = or disjoint i64 %129, 16
  store i64 %131, ptr %3, align 4
  %132 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %133 = load i64, ptr %132, align 4
  tail call void @___dec_future_refcount(i64 %133)
  br label %cond_exit_603.4

cond_exit_603.4:                                  ; preds = %__barray_mask_borrow.exit1646.4, %cond_exit_603.3
  %134 = load i64, ptr %3, align 4
  %135 = and i64 %134, 32
  %.not1736 = icmp eq i64 %135, 0
  br i1 %.not1736, label %__barray_mask_borrow.exit1646.5, label %cond_exit_603.5

__barray_mask_borrow.exit1646.5:                  ; preds = %cond_exit_603.4
  %136 = or disjoint i64 %134, 32
  store i64 %136, ptr %3, align 4
  %137 = getelementptr inbounds nuw i8, ptr %2, i64 40
  %138 = load i64, ptr %137, align 4
  tail call void @___dec_future_refcount(i64 %138)
  br label %cond_exit_603.5

cond_exit_603.5:                                  ; preds = %__barray_mask_borrow.exit1646.5, %cond_exit_603.4
  %139 = load i64, ptr %3, align 4
  %140 = and i64 %139, 64
  %.not1737 = icmp eq i64 %140, 0
  br i1 %.not1737, label %__barray_mask_borrow.exit1646.6, label %cond_exit_603.6

__barray_mask_borrow.exit1646.6:                  ; preds = %cond_exit_603.5
  %141 = or disjoint i64 %139, 64
  store i64 %141, ptr %3, align 4
  %142 = getelementptr inbounds nuw i8, ptr %2, i64 48
  %143 = load i64, ptr %142, align 4
  tail call void @___dec_future_refcount(i64 %143)
  br label %cond_exit_603.6

cond_exit_603.6:                                  ; preds = %__barray_mask_borrow.exit1646.6, %cond_exit_603.5
  %144 = load i64, ptr %3, align 4
  %145 = and i64 %144, 128
  %.not1738 = icmp eq i64 %145, 0
  br i1 %.not1738, label %__barray_mask_borrow.exit1646.7, label %cond_exit_603.7

__barray_mask_borrow.exit1646.7:                  ; preds = %cond_exit_603.6
  %146 = or disjoint i64 %144, 128
  store i64 %146, ptr %3, align 4
  %147 = getelementptr inbounds nuw i8, ptr %2, i64 56
  %148 = load i64, ptr %147, align 4
  tail call void @___dec_future_refcount(i64 %148)
  br label %cond_exit_603.7

cond_exit_603.7:                                  ; preds = %__barray_mask_borrow.exit1646.7, %cond_exit_603.6
  %149 = load i64, ptr %3, align 4
  %150 = and i64 %149, 256
  %.not1739 = icmp eq i64 %150, 0
  br i1 %.not1739, label %__barray_mask_borrow.exit1646.8, label %cond_exit_603.8

__barray_mask_borrow.exit1646.8:                  ; preds = %cond_exit_603.7
  %151 = or disjoint i64 %149, 256
  store i64 %151, ptr %3, align 4
  %152 = getelementptr inbounds nuw i8, ptr %2, i64 64
  %153 = load i64, ptr %152, align 4
  tail call void @___dec_future_refcount(i64 %153)
  br label %cond_exit_603.8

cond_exit_603.8:                                  ; preds = %__barray_mask_borrow.exit1646.8, %cond_exit_603.7
  %154 = load i64, ptr %3, align 4
  %155 = and i64 %154, 512
  %.not1740 = icmp eq i64 %155, 0
  br i1 %.not1740, label %__barray_mask_borrow.exit1646.9, label %cond_exit_603.9

__barray_mask_borrow.exit1646.9:                  ; preds = %cond_exit_603.8
  %156 = or disjoint i64 %154, 512
  store i64 %156, ptr %3, align 4
  %157 = getelementptr inbounds nuw i8, ptr %2, i64 72
  %158 = load i64, ptr %157, align 4
  tail call void @___dec_future_refcount(i64 %158)
  br label %cond_exit_603.9

cond_exit_603.9:                                  ; preds = %__barray_mask_borrow.exit1646.9, %cond_exit_603.8
  %159 = load i64, ptr %3, align 4
  %160 = or i64 %159, -1024
  store i64 %160, ptr %3, align 4
  %161 = icmp eq i64 %160, -1
  br i1 %161, label %loop_out310, label %mask_block_err.i1638

cond_exit_433:                                    ; preds = %__barray_check_bounds.exit1632
  %162 = xor i64 %109, %101
  store i64 %162, ptr %1, align 4
  %163 = getelementptr inbounds nuw i1, ptr %0, i64 %"429_0.sroa.15.01708"
  store i1 %read_bool, ptr %163, align 1
  %164 = icmp eq i64 %"429_0.sroa.15.01708", 9
  br i1 %164, label %__barray_check_bounds.exit1642.preheader, label %__barray_check_bounds.exit1624

__barray_check_bounds.exit1642.preheader:         ; preds = %cond_exit_433
  %165 = load i64, ptr %3, align 4
  %166 = trunc i64 %165 to i1
  br i1 %166, label %cond_exit_603, label %__barray_mask_borrow.exit1646

loop_out310:                                      ; preds = %cond_exit_603.9
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %167 = load i64, ptr %1, align 4
  %168 = and i64 %167, 1023
  store i64 %168, ptr %1, align 4
  %169 = icmp eq i64 %168, 0
  br i1 %169, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1649

__barray_check_none_borrowed.exit:                ; preds = %loop_out310
  %170 = tail call ptr @heap_alloc(i64 10)
  %171 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %171, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %170, ptr noundef nonnull align 1 dereferenceable(10) %0, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %170)
  %172 = load i64, ptr %1, align 4
  %173 = and i64 %172, 1023
  store i64 %173, ptr %1, align 4
  %174 = icmp eq i64 %173, 0
  br i1 %174, label %__barray_check_none_borrowed.exit1655, label %mask_block_err.i1653

mask_block_err.i1649:                             ; preds = %loop_out310
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1655:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %175 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %175, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %175, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  br label %__barray_check_bounds.exit1657

mask_block_err.i1653:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit1657:                   ; preds = %cond_exit_147, %__barray_check_none_borrowed.exit1655
  %"143_2.01709" = phi i64 [ 0, %__barray_check_none_borrowed.exit1655 ], [ %182, %cond_exit_147 ]
  %176 = lshr i64 %"143_2.01709", 6
  %177 = getelementptr inbounds nuw i64, ptr %7, i64 %176
  %178 = load i64, ptr %177, align 4
  %179 = and i64 %"143_2.01709", 63
  %180 = lshr i64 %178, %179
  %181 = trunc i64 %180 to i1
  br i1 %181, label %cond_exit_147, label %panic.i1658

panic.i1658:                                      ; preds = %__barray_check_bounds.exit1657
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_147:                                    ; preds = %__barray_check_bounds.exit1657
  %182 = add nuw nsw i64 %"143_2.01709", 1
  %183 = shl nuw i64 1, %179
  %184 = xor i64 %178, %183
  store i64 %184, ptr %177, align 4
  %185 = getelementptr inbounds nuw i64, ptr %6, i64 %"143_2.01709"
  store i64 %"143_2.01709", ptr %185, align 4
  %exitcond = icmp eq i64 %182, 100
  br i1 %exitcond, label %loop_out529, label %__barray_check_bounds.exit1657

loop_out529:                                      ; preds = %cond_exit_147
  %186 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %187 = load i64, ptr %186, align 4
  %188 = and i64 %187, 68719476735
  store i64 %188, ptr %186, align 4
  %189 = load i64, ptr %7, align 4
  %190 = icmp eq i64 %189, 0
  %191 = icmp eq i64 %188, 0
  %or.cond = select i1 %190, i1 %191, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit1664, label %mask_block_err.i1662

__barray_check_none_borrowed.exit1664:            ; preds = %loop_out529
  %192 = call ptr @heap_alloc(i64 800)
  %193 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %193, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %192, ptr noundef nonnull align 1 dereferenceable(800) %6, i64 800, i1 false)
  call void @heap_free(ptr nonnull %192)
  %194 = load i64, ptr %186, align 4
  %195 = and i64 %194, 68719476735
  store i64 %195, ptr %186, align 4
  %196 = load i64, ptr %7, align 4
  %197 = icmp eq i64 %196, 0
  %198 = icmp eq i64 %195, 0
  %or.cond1726 = select i1 %197, i1 %198, i1 false
  br i1 %or.cond1726, label %__barray_check_none_borrowed.exit1669, label %mask_block_err.i1667

mask_block_err.i1662:                             ; preds = %loop_out529
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1669:            ; preds = %__barray_check_none_borrowed.exit1664
  %out_arr_alloca692 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr694 = getelementptr inbounds nuw i8, ptr %out_arr_alloca692, i64 4
  %arr_ptr695 = getelementptr inbounds nuw i8, ptr %out_arr_alloca692, i64 8
  %mask_ptr696 = getelementptr inbounds nuw i8, ptr %out_arr_alloca692, i64 16
  %199 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %199, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca692, align 8
  store i32 1, ptr %y_ptr694, align 4
  store ptr %6, ptr %arr_ptr695, align 8
  store ptr %199, ptr %mask_ptr696, align 8
  call void @print_int_arr(ptr nonnull @res_is.F21393DB.0, i64 14, ptr nonnull %out_arr_alloca692)
  br label %__barray_check_bounds.exit1671

mask_block_err.i1667:                             ; preds = %__barray_check_none_borrowed.exit1664
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit1671:                   ; preds = %cond_exit_253, %__barray_check_none_borrowed.exit1669
  %"249_2.01711" = phi i64 [ 0, %__barray_check_none_borrowed.exit1669 ], [ %208, %cond_exit_253 ]
  %200 = lshr i64 %"249_2.01711", 6
  %201 = getelementptr inbounds nuw i64, ptr %5, i64 %200
  %202 = load i64, ptr %201, align 4
  %203 = and i64 %"249_2.01711", 63
  %204 = lshr i64 %202, %203
  %205 = trunc i64 %204 to i1
  br i1 %205, label %cond_exit_253, label %panic.i1672

panic.i1672:                                      ; preds = %__barray_check_bounds.exit1671
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_253:                                    ; preds = %__barray_check_bounds.exit1671
  %206 = uitofp nneg i64 %"249_2.01711" to double
  %207 = fmul double %206, 6.250000e-02
  %208 = add nuw nsw i64 %"249_2.01711", 1
  %209 = shl nuw i64 1, %203
  %210 = xor i64 %202, %209
  store i64 %210, ptr %201, align 4
  %211 = getelementptr inbounds nuw double, ptr %4, i64 %"249_2.01711"
  store double %207, ptr %211, align 8
  %exitcond1713 = icmp eq i64 %208, 100
  br i1 %exitcond1713, label %loop_out700, label %__barray_check_bounds.exit1671

loop_out700:                                      ; preds = %cond_exit_253
  %212 = getelementptr inbounds nuw i8, ptr %5, i64 8
  %213 = load i64, ptr %212, align 4
  %214 = and i64 %213, 68719476735
  store i64 %214, ptr %212, align 4
  %215 = load i64, ptr %5, align 4
  %216 = icmp eq i64 %215, 0
  %217 = icmp eq i64 %214, 0
  %or.cond1727 = select i1 %216, i1 %217, i1 false
  br i1 %or.cond1727, label %__barray_check_none_borrowed.exit1678, label %mask_block_err.i1676

__barray_check_none_borrowed.exit1678:            ; preds = %loop_out700
  %218 = call ptr @heap_alloc(i64 800)
  %219 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %219, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %218, ptr noundef nonnull align 1 dereferenceable(800) %4, i64 800, i1 false)
  call void @heap_free(ptr nonnull %218)
  %220 = load i64, ptr %212, align 4
  %221 = and i64 %220, 68719476735
  store i64 %221, ptr %212, align 4
  %222 = load i64, ptr %5, align 4
  %223 = icmp eq i64 %222, 0
  %224 = icmp eq i64 %221, 0
  %or.cond1728 = select i1 %223, i1 %224, i1 false
  br i1 %or.cond1728, label %__barray_check_none_borrowed.exit1683, label %mask_block_err.i1681

mask_block_err.i1676:                             ; preds = %loop_out700
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1683:            ; preds = %__barray_check_none_borrowed.exit1678
  %out_arr_alloca866 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr868 = getelementptr inbounds nuw i8, ptr %out_arr_alloca866, i64 4
  %arr_ptr869 = getelementptr inbounds nuw i8, ptr %out_arr_alloca866, i64 8
  %mask_ptr870 = getelementptr inbounds nuw i8, ptr %out_arr_alloca866, i64 16
  %225 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %225, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca866, align 8
  store i32 1, ptr %y_ptr868, align 4
  store ptr %4, ptr %arr_ptr869, align 8
  store ptr %225, ptr %mask_ptr870, align 8
  call void @print_float_arr(ptr nonnull @res_fs.CBD4AF54.0, i64 16, ptr nonnull %out_arr_alloca866)
  ret void

mask_block_err.i1681:                             ; preds = %__barray_check_none_borrowed.exit1678
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare void @heap_free(ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr

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
