; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

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
  br i1 %not_max.not.not.i, label %cond_557_case_0.i, label %__barray_check_bounds.exit

cond_557_case_0.i:                                ; preds = %cond_exit_12.8, %cond_exit_12.7, %cond_exit_12.6, %cond_exit_12.5, %cond_exit_12.4, %cond_exit_12.3, %cond_exit_12.2, %cond_exit_12.1, %cond_exit_12, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %10 = load i64, ptr %9, align 4
  %11 = trunc i64 %10 to i1
  br i1 %11, label %cond_exit_12, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__barray_check_bounds.exit.8, %__barray_check_bounds.exit.7, %__barray_check_bounds.exit.6, %__barray_check_bounds.exit.5, %__barray_check_bounds.exit.4, %__barray_check_bounds.exit.3, %__barray_check_bounds.exit.2, %__barray_check_bounds.exit.1, %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_12:                                     ; preds = %__barray_check_bounds.exit
  %12 = and i64 %10, -2
  store i64 %12, ptr %9, align 4
  store i64 %qalloc.i, ptr %8, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_557_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_12
  tail call void @___reset(i64 %qalloc.i.1)
  %13 = load i64, ptr %9, align 4
  %14 = and i64 %13, 2
  %.not1724 = icmp eq i64 %14, 0
  br i1 %.not1724, label %panic.i, label %cond_exit_12.1

cond_exit_12.1:                                   ; preds = %__barray_check_bounds.exit.1
  %15 = and i64 %13, -3
  store i64 %15, ptr %9, align 4
  %16 = getelementptr inbounds nuw i8, ptr %8, i64 8
  store i64 %qalloc.i.1, ptr %16, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_557_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_12.1
  tail call void @___reset(i64 %qalloc.i.2)
  %17 = load i64, ptr %9, align 4
  %18 = and i64 %17, 4
  %.not1725 = icmp eq i64 %18, 0
  br i1 %.not1725, label %panic.i, label %cond_exit_12.2

cond_exit_12.2:                                   ; preds = %__barray_check_bounds.exit.2
  %19 = and i64 %17, -5
  store i64 %19, ptr %9, align 4
  %20 = getelementptr inbounds nuw i8, ptr %8, i64 16
  store i64 %qalloc.i.2, ptr %20, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_557_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_12.2
  tail call void @___reset(i64 %qalloc.i.3)
  %21 = load i64, ptr %9, align 4
  %22 = and i64 %21, 8
  %.not1726 = icmp eq i64 %22, 0
  br i1 %.not1726, label %panic.i, label %cond_exit_12.3

cond_exit_12.3:                                   ; preds = %__barray_check_bounds.exit.3
  %23 = and i64 %21, -9
  store i64 %23, ptr %9, align 4
  %24 = getelementptr inbounds nuw i8, ptr %8, i64 24
  store i64 %qalloc.i.3, ptr %24, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_557_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_12.3
  tail call void @___reset(i64 %qalloc.i.4)
  %25 = load i64, ptr %9, align 4
  %26 = and i64 %25, 16
  %.not1727 = icmp eq i64 %26, 0
  br i1 %.not1727, label %panic.i, label %cond_exit_12.4

cond_exit_12.4:                                   ; preds = %__barray_check_bounds.exit.4
  %27 = and i64 %25, -17
  store i64 %27, ptr %9, align 4
  %28 = getelementptr inbounds nuw i8, ptr %8, i64 32
  store i64 %qalloc.i.4, ptr %28, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_557_case_0.i, label %__barray_check_bounds.exit.5

__barray_check_bounds.exit.5:                     ; preds = %cond_exit_12.4
  tail call void @___reset(i64 %qalloc.i.5)
  %29 = load i64, ptr %9, align 4
  %30 = and i64 %29, 32
  %.not1728 = icmp eq i64 %30, 0
  br i1 %.not1728, label %panic.i, label %cond_exit_12.5

cond_exit_12.5:                                   ; preds = %__barray_check_bounds.exit.5
  %31 = and i64 %29, -33
  store i64 %31, ptr %9, align 4
  %32 = getelementptr inbounds nuw i8, ptr %8, i64 40
  store i64 %qalloc.i.5, ptr %32, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_557_case_0.i, label %__barray_check_bounds.exit.6

__barray_check_bounds.exit.6:                     ; preds = %cond_exit_12.5
  tail call void @___reset(i64 %qalloc.i.6)
  %33 = load i64, ptr %9, align 4
  %34 = and i64 %33, 64
  %.not1729 = icmp eq i64 %34, 0
  br i1 %.not1729, label %panic.i, label %cond_exit_12.6

cond_exit_12.6:                                   ; preds = %__barray_check_bounds.exit.6
  %35 = and i64 %33, -65
  store i64 %35, ptr %9, align 4
  %36 = getelementptr inbounds nuw i8, ptr %8, i64 48
  store i64 %qalloc.i.6, ptr %36, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_557_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_12.6
  tail call void @___reset(i64 %qalloc.i.7)
  %37 = load i64, ptr %9, align 4
  %38 = and i64 %37, 128
  %.not1730 = icmp eq i64 %38, 0
  br i1 %.not1730, label %panic.i, label %cond_exit_12.7

cond_exit_12.7:                                   ; preds = %__barray_check_bounds.exit.7
  %39 = and i64 %37, -129
  store i64 %39, ptr %9, align 4
  %40 = getelementptr inbounds nuw i8, ptr %8, i64 56
  store i64 %qalloc.i.7, ptr %40, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_557_case_0.i, label %__barray_check_bounds.exit.8

__barray_check_bounds.exit.8:                     ; preds = %cond_exit_12.7
  tail call void @___reset(i64 %qalloc.i.8)
  %41 = load i64, ptr %9, align 4
  %42 = and i64 %41, 256
  %.not1731 = icmp eq i64 %42, 0
  br i1 %.not1731, label %panic.i, label %cond_exit_12.8

cond_exit_12.8:                                   ; preds = %__barray_check_bounds.exit.8
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
  %.not1732 = icmp eq i64 %46, 0
  br i1 %.not1732, label %panic.i, label %cond_exit_12.9

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
  tail call void @___rp(i64 %52, double 0x400921FB54442D18, double 0.000000e+00)
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
  %59 = getelementptr inbounds nuw i8, ptr %8, i64 16
  %60 = load i64, ptr %59, align 4
  tail call void @___rp(i64 %60, double 0x400921FB54442D18, double 0.000000e+00)
  %61 = load i64, ptr %9, align 4
  %62 = and i64 %61, 4
  %.not1701 = icmp eq i64 %62, 0
  br i1 %.not1701, label %panic.i1605, label %__barray_mask_return.exit1606

panic.i1605:                                      ; preds = %__barray_mask_borrow.exit1604
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1606:                    ; preds = %__barray_mask_borrow.exit1604
  %63 = and i64 %61, -5
  store i64 %63, ptr %9, align 4
  store i64 %60, ptr %59, align 4
  %64 = load i64, ptr %9, align 4
  %65 = and i64 %64, 8
  %.not1702 = icmp eq i64 %65, 0
  br i1 %.not1702, label %__barray_mask_borrow.exit1608, label %panic.i1607

panic.i1607:                                      ; preds = %__barray_mask_return.exit1606
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1608:                    ; preds = %__barray_mask_return.exit1606
  %66 = or disjoint i64 %64, 8
  store i64 %66, ptr %9, align 4
  %67 = getelementptr inbounds nuw i8, ptr %8, i64 24
  %68 = load i64, ptr %67, align 4
  tail call void @___rp(i64 %68, double 0x400921FB54442D18, double 0.000000e+00)
  %69 = load i64, ptr %9, align 4
  %70 = and i64 %69, 8
  %.not1703 = icmp eq i64 %70, 0
  br i1 %.not1703, label %panic.i1609, label %__barray_mask_return.exit1610

panic.i1609:                                      ; preds = %__barray_mask_borrow.exit1608
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1610:                    ; preds = %__barray_mask_borrow.exit1608
  %71 = and i64 %69, -9
  store i64 %71, ptr %9, align 4
  store i64 %68, ptr %67, align 4
  %72 = load i64, ptr %9, align 4
  %73 = and i64 %72, 512
  %.not1704 = icmp eq i64 %73, 0
  br i1 %.not1704, label %__barray_mask_borrow.exit1612, label %panic.i1611

panic.i1611:                                      ; preds = %__barray_mask_return.exit1610
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1612:                    ; preds = %__barray_mask_return.exit1610
  %74 = or disjoint i64 %72, 512
  store i64 %74, ptr %9, align 4
  %75 = getelementptr inbounds nuw i8, ptr %8, i64 72
  %76 = load i64, ptr %75, align 4
  tail call void @___rp(i64 %76, double 0x400921FB54442D18, double 0.000000e+00)
  %77 = load i64, ptr %9, align 4
  %78 = and i64 %77, 512
  %.not1705 = icmp eq i64 %78, 0
  br i1 %.not1705, label %panic.i1613, label %__barray_mask_return.exit1614

panic.i1613:                                      ; preds = %__barray_mask_borrow.exit1612
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1614:                    ; preds = %__barray_mask_borrow.exit1612
  %79 = and i64 %77, -513
  store i64 %79, ptr %9, align 4
  store i64 %76, ptr %75, align 4
  br label %__barray_check_bounds.exit1620

out_of_bounds.i1615:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1616:                   ; preds = %.thread
  %80 = load i64, ptr %3, align 4
  %81 = lshr i64 %80, %"363_2.01721"
  %82 = trunc i64 %81 to i1
  br i1 %82, label %cond_exit_367, label %panic.i1617

panic.i1617:                                      ; preds = %__barray_check_bounds.exit1616
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_367
  %83 = load i64, ptr %9, align 4
  %84 = or i64 %83, -1024
  store i64 %84, ptr %9, align 4
  %85 = icmp eq i64 %84, -1
  br i1 %85, label %loop_body311.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1620:                   ; preds = %__barray_mask_return.exit1614, %cond_exit_367
  %"363_0.sroa.15.01722" = phi i64 [ 0, %__barray_mask_return.exit1614 ], [ %86, %cond_exit_367 ]
  %"363_2.01721" = phi i64 [ 0, %__barray_mask_return.exit1614 ], [ %94, %cond_exit_367 ]
  %86 = add nuw nsw i64 %"363_0.sroa.15.01722", 1
  %87 = load i64, ptr %9, align 4
  %88 = lshr i64 %87, %"363_0.sroa.15.01722"
  %89 = trunc i64 %88 to i1
  br i1 %89, label %panic.i1621, label %.thread

panic.i1621:                                      ; preds = %__barray_check_bounds.exit1620
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_check_bounds.exit1620
  %90 = shl nuw nsw i64 1, %"363_0.sroa.15.01722"
  %91 = xor i64 %87, %90
  store i64 %91, ptr %9, align 4
  %92 = getelementptr inbounds nuw i64, ptr %8, i64 %"363_0.sroa.15.01722"
  %93 = load i64, ptr %92, align 4
  %94 = add i64 %"363_2.01721", 1
  %lazy_measure = tail call i64 @___lazy_measure(i64 %93)
  tail call void @___qfree(i64 %93)
  %95 = icmp ult i64 %"363_2.01721", 10
  br i1 %95, label %__barray_check_bounds.exit1616, label %out_of_bounds.i1615

cond_exit_367:                                    ; preds = %__barray_check_bounds.exit1616
  %96 = shl nuw nsw i64 1, %"363_2.01721"
  %97 = xor i64 %80, %96
  store i64 %97, ptr %3, align 4
  %98 = getelementptr inbounds nuw i64, ptr %2, i64 %"363_2.01721"
  store i64 %lazy_measure, ptr %98, align 4
  %99 = icmp samesign ugt i64 %"363_0.sroa.15.01722", 8
  br i1 %99, label %mask_block_ok.i, label %__barray_check_bounds.exit1620

loop_body311.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %8)
  tail call void @heap_free(ptr nonnull %9)
  br label %__barray_check_bounds.exit1624

__barray_check_bounds.exit1624:                   ; preds = %cond_exit_433, %loop_body311.preheader.preheader
  %"429_0.sroa.15.01708" = phi i64 [ %100, %cond_exit_433 ], [ 0, %loop_body311.preheader.preheader ]
  %100 = add nuw nsw i64 %"429_0.sroa.15.01708", 1
  %101 = load i64, ptr %3, align 4
  %102 = lshr i64 %101, %"429_0.sroa.15.01708"
  %103 = trunc i64 %102 to i1
  br i1 %103, label %panic.i1625, label %__barray_check_bounds.exit1628

panic.i1625:                                      ; preds = %__barray_check_bounds.exit1624
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1628:                   ; preds = %__barray_check_bounds.exit1624
  %104 = shl nuw nsw i64 1, %"429_0.sroa.15.01708"
  %105 = xor i64 %101, %104
  store i64 %105, ptr %3, align 4
  %106 = getelementptr inbounds nuw i64, ptr %2, i64 %"429_0.sroa.15.01708"
  %107 = load i64, ptr %106, align 4
  tail call void @___inc_future_refcount(i64 %107)
  %108 = load i64, ptr %3, align 4
  %109 = lshr i64 %108, %"429_0.sroa.15.01708"
  %110 = trunc i64 %109 to i1
  br i1 %110, label %__barray_check_bounds.exit1632, label %panic.i1629

panic.i1629:                                      ; preds = %__barray_check_bounds.exit1628
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1632:                   ; preds = %__barray_check_bounds.exit1628
  %111 = xor i64 %108, %104
  store i64 %111, ptr %3, align 4
  store i64 %107, ptr %106, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %107)
  tail call void @___dec_future_refcount(i64 %107)
  %112 = load i64, ptr %1, align 4
  %113 = lshr i64 %112, %"429_0.sroa.15.01708"
  %114 = trunc i64 %113 to i1
  br i1 %114, label %cond_exit_433, label %panic.i1633

panic.i1633:                                      ; preds = %__barray_check_bounds.exit1632
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_err.i1638:                             ; preds = %cond_exit_603.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit1646:                    ; preds = %__barray_check_bounds.exit1642.preheader
  %115 = or disjoint i64 %168, 1
  store i64 %115, ptr %3, align 4
  %116 = load i64, ptr %2, align 4
  tail call void @___dec_future_refcount(i64 %116)
  br label %cond_exit_603

cond_exit_603:                                    ; preds = %__barray_mask_borrow.exit1646, %__barray_check_bounds.exit1642.preheader
  %117 = load i64, ptr %3, align 4
  %118 = and i64 %117, 2
  %.not1733 = icmp eq i64 %118, 0
  br i1 %.not1733, label %__barray_mask_borrow.exit1646.1, label %cond_exit_603.1

__barray_mask_borrow.exit1646.1:                  ; preds = %cond_exit_603
  %119 = or disjoint i64 %117, 2
  store i64 %119, ptr %3, align 4
  %120 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %121 = load i64, ptr %120, align 4
  tail call void @___dec_future_refcount(i64 %121)
  br label %cond_exit_603.1

cond_exit_603.1:                                  ; preds = %__barray_mask_borrow.exit1646.1, %cond_exit_603
  %122 = load i64, ptr %3, align 4
  %123 = and i64 %122, 4
  %.not1734 = icmp eq i64 %123, 0
  br i1 %.not1734, label %__barray_mask_borrow.exit1646.2, label %cond_exit_603.2

__barray_mask_borrow.exit1646.2:                  ; preds = %cond_exit_603.1
  %124 = or disjoint i64 %122, 4
  store i64 %124, ptr %3, align 4
  %125 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %126 = load i64, ptr %125, align 4
  tail call void @___dec_future_refcount(i64 %126)
  br label %cond_exit_603.2

cond_exit_603.2:                                  ; preds = %__barray_mask_borrow.exit1646.2, %cond_exit_603.1
  %127 = load i64, ptr %3, align 4
  %128 = and i64 %127, 8
  %.not1735 = icmp eq i64 %128, 0
  br i1 %.not1735, label %__barray_mask_borrow.exit1646.3, label %cond_exit_603.3

__barray_mask_borrow.exit1646.3:                  ; preds = %cond_exit_603.2
  %129 = or disjoint i64 %127, 8
  store i64 %129, ptr %3, align 4
  %130 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %131 = load i64, ptr %130, align 4
  tail call void @___dec_future_refcount(i64 %131)
  br label %cond_exit_603.3

cond_exit_603.3:                                  ; preds = %__barray_mask_borrow.exit1646.3, %cond_exit_603.2
  %132 = load i64, ptr %3, align 4
  %133 = and i64 %132, 16
  %.not1736 = icmp eq i64 %133, 0
  br i1 %.not1736, label %__barray_mask_borrow.exit1646.4, label %cond_exit_603.4

__barray_mask_borrow.exit1646.4:                  ; preds = %cond_exit_603.3
  %134 = or disjoint i64 %132, 16
  store i64 %134, ptr %3, align 4
  %135 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %136 = load i64, ptr %135, align 4
  tail call void @___dec_future_refcount(i64 %136)
  br label %cond_exit_603.4

cond_exit_603.4:                                  ; preds = %__barray_mask_borrow.exit1646.4, %cond_exit_603.3
  %137 = load i64, ptr %3, align 4
  %138 = and i64 %137, 32
  %.not1737 = icmp eq i64 %138, 0
  br i1 %.not1737, label %__barray_mask_borrow.exit1646.5, label %cond_exit_603.5

__barray_mask_borrow.exit1646.5:                  ; preds = %cond_exit_603.4
  %139 = or disjoint i64 %137, 32
  store i64 %139, ptr %3, align 4
  %140 = getelementptr inbounds nuw i8, ptr %2, i64 40
  %141 = load i64, ptr %140, align 4
  tail call void @___dec_future_refcount(i64 %141)
  br label %cond_exit_603.5

cond_exit_603.5:                                  ; preds = %__barray_mask_borrow.exit1646.5, %cond_exit_603.4
  %142 = load i64, ptr %3, align 4
  %143 = and i64 %142, 64
  %.not1738 = icmp eq i64 %143, 0
  br i1 %.not1738, label %__barray_mask_borrow.exit1646.6, label %cond_exit_603.6

__barray_mask_borrow.exit1646.6:                  ; preds = %cond_exit_603.5
  %144 = or disjoint i64 %142, 64
  store i64 %144, ptr %3, align 4
  %145 = getelementptr inbounds nuw i8, ptr %2, i64 48
  %146 = load i64, ptr %145, align 4
  tail call void @___dec_future_refcount(i64 %146)
  br label %cond_exit_603.6

cond_exit_603.6:                                  ; preds = %__barray_mask_borrow.exit1646.6, %cond_exit_603.5
  %147 = load i64, ptr %3, align 4
  %148 = and i64 %147, 128
  %.not1739 = icmp eq i64 %148, 0
  br i1 %.not1739, label %__barray_mask_borrow.exit1646.7, label %cond_exit_603.7

__barray_mask_borrow.exit1646.7:                  ; preds = %cond_exit_603.6
  %149 = or disjoint i64 %147, 128
  store i64 %149, ptr %3, align 4
  %150 = getelementptr inbounds nuw i8, ptr %2, i64 56
  %151 = load i64, ptr %150, align 4
  tail call void @___dec_future_refcount(i64 %151)
  br label %cond_exit_603.7

cond_exit_603.7:                                  ; preds = %__barray_mask_borrow.exit1646.7, %cond_exit_603.6
  %152 = load i64, ptr %3, align 4
  %153 = and i64 %152, 256
  %.not1740 = icmp eq i64 %153, 0
  br i1 %.not1740, label %__barray_mask_borrow.exit1646.8, label %cond_exit_603.8

__barray_mask_borrow.exit1646.8:                  ; preds = %cond_exit_603.7
  %154 = or disjoint i64 %152, 256
  store i64 %154, ptr %3, align 4
  %155 = getelementptr inbounds nuw i8, ptr %2, i64 64
  %156 = load i64, ptr %155, align 4
  tail call void @___dec_future_refcount(i64 %156)
  br label %cond_exit_603.8

cond_exit_603.8:                                  ; preds = %__barray_mask_borrow.exit1646.8, %cond_exit_603.7
  %157 = load i64, ptr %3, align 4
  %158 = and i64 %157, 512
  %.not1741 = icmp eq i64 %158, 0
  br i1 %.not1741, label %__barray_mask_borrow.exit1646.9, label %cond_exit_603.9

__barray_mask_borrow.exit1646.9:                  ; preds = %cond_exit_603.8
  %159 = or disjoint i64 %157, 512
  store i64 %159, ptr %3, align 4
  %160 = getelementptr inbounds nuw i8, ptr %2, i64 72
  %161 = load i64, ptr %160, align 4
  tail call void @___dec_future_refcount(i64 %161)
  br label %cond_exit_603.9

cond_exit_603.9:                                  ; preds = %__barray_mask_borrow.exit1646.9, %cond_exit_603.8
  %162 = load i64, ptr %3, align 4
  %163 = or i64 %162, -1024
  store i64 %163, ptr %3, align 4
  %164 = icmp eq i64 %163, -1
  br i1 %164, label %loop_out310, label %mask_block_err.i1638

cond_exit_433:                                    ; preds = %__barray_check_bounds.exit1632
  %165 = xor i64 %112, %104
  store i64 %165, ptr %1, align 4
  %166 = getelementptr inbounds nuw i1, ptr %0, i64 %"429_0.sroa.15.01708"
  store i1 %read_bool, ptr %166, align 1
  %167 = icmp eq i64 %"429_0.sroa.15.01708", 9
  br i1 %167, label %__barray_check_bounds.exit1642.preheader, label %__barray_check_bounds.exit1624

__barray_check_bounds.exit1642.preheader:         ; preds = %cond_exit_433
  %168 = load i64, ptr %3, align 4
  %169 = trunc i64 %168 to i1
  br i1 %169, label %cond_exit_603, label %__barray_mask_borrow.exit1646

loop_out310:                                      ; preds = %cond_exit_603.9
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %170 = load i64, ptr %1, align 4
  %171 = and i64 %170, 1023
  store i64 %171, ptr %1, align 4
  %172 = icmp eq i64 %171, 0
  br i1 %172, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1649

__barray_check_none_borrowed.exit:                ; preds = %loop_out310
  %173 = tail call ptr @heap_alloc(i64 10)
  %174 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %174, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %173, ptr noundef nonnull align 1 dereferenceable(10) %0, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %173)
  %175 = load i64, ptr %1, align 4
  %176 = and i64 %175, 1023
  store i64 %176, ptr %1, align 4
  %177 = icmp eq i64 %176, 0
  br i1 %177, label %__barray_check_none_borrowed.exit1655, label %mask_block_err.i1653

mask_block_err.i1649:                             ; preds = %loop_out310
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1655:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %178 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %178, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %178, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_cs.46C3C4B5.0, i64 15, ptr nonnull %out_arr_alloca)
  br label %__barray_check_bounds.exit1657

mask_block_err.i1653:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit1657:                   ; preds = %cond_exit_147.1, %__barray_check_none_borrowed.exit1655
  %"143_2.01709" = phi i64 [ 0, %__barray_check_none_borrowed.exit1655 ], [ %195, %cond_exit_147.1 ]
  %179 = lshr i64 %"143_2.01709", 6
  %180 = getelementptr inbounds nuw i64, ptr %7, i64 %179
  %181 = load i64, ptr %180, align 4
  %182 = and i64 %"143_2.01709", 62
  %183 = lshr i64 %181, %182
  %184 = trunc i64 %183 to i1
  br i1 %184, label %cond_exit_147, label %panic.i1658

panic.i1658:                                      ; preds = %cond_exit_147, %__barray_check_bounds.exit1657
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_147:                                    ; preds = %__barray_check_bounds.exit1657
  %185 = or disjoint i64 %"143_2.01709", 1
  %186 = shl nuw nsw i64 1, %182
  %187 = xor i64 %181, %186
  store i64 %187, ptr %180, align 4
  %188 = getelementptr inbounds nuw i64, ptr %6, i64 %"143_2.01709"
  store i64 %"143_2.01709", ptr %188, align 4
  %189 = lshr i64 %"143_2.01709", 6
  %190 = getelementptr inbounds nuw i64, ptr %7, i64 %189
  %191 = load i64, ptr %190, align 4
  %192 = and i64 %185, 63
  %193 = lshr i64 %191, %192
  %194 = trunc i64 %193 to i1
  br i1 %194, label %cond_exit_147.1, label %panic.i1658

cond_exit_147.1:                                  ; preds = %cond_exit_147
  %195 = add nuw nsw i64 %"143_2.01709", 2
  %196 = shl nuw i64 1, %192
  %197 = xor i64 %191, %196
  store i64 %197, ptr %190, align 4
  %198 = getelementptr inbounds nuw i64, ptr %6, i64 %185
  store i64 %185, ptr %198, align 4
  %exitcond1713.1 = icmp eq i64 %195, 100
  br i1 %exitcond1713.1, label %loop_out529, label %__barray_check_bounds.exit1657

loop_out529:                                      ; preds = %cond_exit_147.1
  %199 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %200 = load i64, ptr %199, align 4
  %201 = and i64 %200, 68719476735
  store i64 %201, ptr %199, align 4
  %202 = load i64, ptr %7, align 4
  %203 = icmp eq i64 %202, 0
  %204 = icmp eq i64 %201, 0
  %or.cond = select i1 %203, i1 %204, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit1664, label %mask_block_err.i1662

__barray_check_none_borrowed.exit1664:            ; preds = %loop_out529
  %205 = call ptr @heap_alloc(i64 800)
  %206 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %206, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %205, ptr noundef nonnull align 1 dereferenceable(800) %6, i64 800, i1 false)
  call void @heap_free(ptr nonnull %205)
  %207 = load i64, ptr %199, align 4
  %208 = and i64 %207, 68719476735
  store i64 %208, ptr %199, align 4
  %209 = load i64, ptr %7, align 4
  %210 = icmp eq i64 %209, 0
  %211 = icmp eq i64 %208, 0
  %or.cond1718 = select i1 %210, i1 %211, i1 false
  br i1 %or.cond1718, label %__barray_check_none_borrowed.exit1669, label %mask_block_err.i1667

mask_block_err.i1662:                             ; preds = %loop_out529
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1669:            ; preds = %__barray_check_none_borrowed.exit1664
  %out_arr_alloca692 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr694 = getelementptr inbounds nuw i8, ptr %out_arr_alloca692, i64 4
  %arr_ptr695 = getelementptr inbounds nuw i8, ptr %out_arr_alloca692, i64 8
  %mask_ptr696 = getelementptr inbounds nuw i8, ptr %out_arr_alloca692, i64 16
  %212 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %212, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca692, align 8
  store i32 1, ptr %y_ptr694, align 4
  store ptr %6, ptr %arr_ptr695, align 8
  store ptr %212, ptr %mask_ptr696, align 8
  call void @print_int_arr(ptr nonnull @res_is.F21393DB.0, i64 14, ptr nonnull %out_arr_alloca692)
  br label %__barray_check_bounds.exit1671

mask_block_err.i1667:                             ; preds = %__barray_check_none_borrowed.exit1664
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit1671:                   ; preds = %cond_exit_253, %__barray_check_none_borrowed.exit1669
  %"249_2.01711" = phi i64 [ 0, %__barray_check_none_borrowed.exit1669 ], [ %221, %cond_exit_253 ]
  %213 = lshr i64 %"249_2.01711", 6
  %214 = getelementptr inbounds nuw i64, ptr %5, i64 %213
  %215 = load i64, ptr %214, align 4
  %216 = and i64 %"249_2.01711", 63
  %217 = lshr i64 %215, %216
  %218 = trunc i64 %217 to i1
  br i1 %218, label %cond_exit_253, label %panic.i1672

panic.i1672:                                      ; preds = %__barray_check_bounds.exit1671
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_253:                                    ; preds = %__barray_check_bounds.exit1671
  %219 = uitofp nneg i64 %"249_2.01711" to double
  %220 = fmul double %219, 6.250000e-02
  %221 = add nuw nsw i64 %"249_2.01711", 1
  %222 = shl nuw i64 1, %216
  %223 = xor i64 %215, %222
  store i64 %223, ptr %214, align 4
  %224 = getelementptr inbounds nuw double, ptr %4, i64 %"249_2.01711"
  store double %220, ptr %224, align 8
  %exitcond1714 = icmp eq i64 %221, 100
  br i1 %exitcond1714, label %loop_out700, label %__barray_check_bounds.exit1671

loop_out700:                                      ; preds = %cond_exit_253
  %225 = getelementptr inbounds nuw i8, ptr %5, i64 8
  %226 = load i64, ptr %225, align 4
  %227 = and i64 %226, 68719476735
  store i64 %227, ptr %225, align 4
  %228 = load i64, ptr %5, align 4
  %229 = icmp eq i64 %228, 0
  %230 = icmp eq i64 %227, 0
  %or.cond1719 = select i1 %229, i1 %230, i1 false
  br i1 %or.cond1719, label %__barray_check_none_borrowed.exit1678, label %mask_block_err.i1676

__barray_check_none_borrowed.exit1678:            ; preds = %loop_out700
  %231 = call ptr @heap_alloc(i64 800)
  %232 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %232, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %231, ptr noundef nonnull align 1 dereferenceable(800) %4, i64 800, i1 false)
  call void @heap_free(ptr nonnull %231)
  %233 = load i64, ptr %225, align 4
  %234 = and i64 %233, 68719476735
  store i64 %234, ptr %225, align 4
  %235 = load i64, ptr %5, align 4
  %236 = icmp eq i64 %235, 0
  %237 = icmp eq i64 %234, 0
  %or.cond1720 = select i1 %236, i1 %237, i1 false
  br i1 %or.cond1720, label %__barray_check_none_borrowed.exit1683, label %mask_block_err.i1681

mask_block_err.i1676:                             ; preds = %loop_out700
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1683:            ; preds = %__barray_check_none_borrowed.exit1678
  %out_arr_alloca866 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr868 = getelementptr inbounds nuw i8, ptr %out_arr_alloca866, i64 4
  %arr_ptr869 = getelementptr inbounds nuw i8, ptr %out_arr_alloca866, i64 8
  %mask_ptr870 = getelementptr inbounds nuw i8, ptr %out_arr_alloca866, i64 16
  %238 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %238, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca866, align 8
  store i32 1, ptr %y_ptr868, align 4
  store ptr %4, ptr %arr_ptr869, align 8
  store ptr %238, ptr %mask_ptr870, align 8
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
