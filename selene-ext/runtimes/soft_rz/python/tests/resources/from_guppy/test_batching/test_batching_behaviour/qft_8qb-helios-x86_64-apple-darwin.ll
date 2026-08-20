; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@e_tket.rotat.20D0216B.0 = private constant [55 x i8] c"6EXIT:INT:tket.rotation.from_halfturns_unchecked failed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_measuremen.F30240EB.0 = private constant [26 x i8] c"\19USER:BOOLARR:measurements"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 8)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %2 = tail call ptr @heap_alloc(i64 64)
  %3 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %3, align 1
  %4 = tail call ptr @heap_alloc(i64 64)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  br label %loop_body

loop_body:                                        ; preds = %cond_exit_278, %alloca_block
  %"274_2.0" = phi i64 [ 0, %alloca_block ], [ %"2106.0", %cond_exit_278 ]
  %"274_0.sroa.0.0" = phi i64 [ 0, %alloca_block ], [ %7, %cond_exit_278 ]
  %6 = icmp samesign ugt i64 %"274_0.sroa.0.0", 7
  %7 = add nuw nsw i64 %"274_0.sroa.0.0", 1
  br i1 %6, label %cond_exit_278, label %cond_278_case_1

cond_278_case_1:                                  ; preds = %loop_body
  %8 = add i64 %"274_2.0", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_619_case_0.i, label %__hugr__.__tk2_helios_qalloc.615.exit

cond_619_case_0.i:                                ; preds = %cond_278_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.615.exit:            ; preds = %cond_278_case_1
  tail call void @___reset(i64 %qalloc.i)
  %9 = icmp ult i64 %"274_2.0", 8
  br i1 %9, label %__barray_check_bounds.exit, label %out_of_bounds.i

out_of_bounds.i:                                  ; preds = %__hugr__.__tk2_helios_qalloc.615.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %__hugr__.__tk2_helios_qalloc.615.exit
  %10 = load i64, ptr %5, align 4
  %11 = lshr i64 %10, %"274_2.0"
  %12 = trunc i64 %11 to i1
  br i1 %12, label %__barray_mask_return.exit, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit
  %13 = shl nuw nsw i64 1, %"274_2.0"
  %14 = xor i64 %10, %13
  store i64 %14, ptr %5, align 4
  %15 = getelementptr inbounds nuw i64, ptr %4, i64 %"274_2.0"
  store i64 %qalloc.i, ptr %15, align 4
  br label %cond_exit_278

cond_exit_278:                                    ; preds = %loop_body, %__barray_mask_return.exit
  %"2106.0" = phi i64 [ %8, %__barray_mask_return.exit ], [ %"274_2.0", %loop_body ]
  %exitcond = icmp eq i64 %7, 9
  br i1 %exitcond, label %__barray_check_bounds.exit1586, label %loop_body

loop_out.loopexit:                                ; preds = %__barray_mask_return.exit1611, %__barray_mask_return.exit1591
  %16 = add nuw nsw i64 %17, 1
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %exitcond1674 = icmp eq i64 %16, 9
  br i1 %exitcond1674, label %cond_exit_374, label %__barray_check_bounds.exit1586

__barray_check_bounds.exit1586:                   ; preds = %cond_exit_278, %loop_out.loopexit
  %indvars.iv = phi i64 [ %indvars.iv.next, %loop_out.loopexit ], [ 8, %cond_exit_278 ]
  %17 = phi i64 [ %16, %loop_out.loopexit ], [ 1, %cond_exit_278 ]
  %"6_0.01668" = phi i64 [ %17, %loop_out.loopexit ], [ 0, %cond_exit_278 ]
  %18 = load i64, ptr %5, align 4
  %19 = lshr i64 %18, %"6_0.01668"
  %20 = trunc i64 %19 to i1
  br i1 %20, label %panic.i1587, label %__barray_check_bounds.exit1589

panic.i1587:                                      ; preds = %__barray_check_bounds.exit1586
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1589:                   ; preds = %__barray_check_bounds.exit1586
  %21 = shl nuw nsw i64 1, %"6_0.01668"
  %22 = xor i64 %18, %21
  store i64 %22, ptr %5, align 4
  %23 = getelementptr inbounds nuw i64, ptr %4, i64 %"6_0.01668"
  %24 = load i64, ptr %23, align 4
  tail call void @___rxy(i64 %24, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %24, double 0x400921FB54442D18)
  %25 = load i64, ptr %5, align 4
  %26 = lshr i64 %25, %"6_0.01668"
  %27 = trunc i64 %26 to i1
  br i1 %27, label %__barray_mask_return.exit1591, label %panic.i1590

panic.i1590:                                      ; preds = %__barray_check_bounds.exit1589
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1591:                    ; preds = %__barray_check_bounds.exit1589
  %28 = xor i64 %25, %21
  store i64 %28, ptr %5, align 4
  store i64 %24, ptr %23, align 4
  %.not1666.not = icmp eq i64 %"6_0.01668", 7
  br i1 %.not1666.not, label %loop_out.loopexit, label %__barray_check_bounds.exit1597

cond_exit_374:                                    ; preds = %loop_out.loopexit
  %29 = load i64, ptr %5, align 4
  %30 = and i64 %29, 128
  %.not1663 = icmp eq i64 %30, 0
  br i1 %.not1663, label %__barray_mask_borrow.exit1593, label %panic.i1592

panic.i1592:                                      ; preds = %cond_exit_374
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1593:                    ; preds = %cond_exit_374
  %31 = or disjoint i64 %29, 128
  store i64 %31, ptr %5, align 4
  %32 = getelementptr inbounds nuw i8, ptr %4, i64 56
  %33 = load i64, ptr %32, align 4
  tail call void @___rxy(i64 %33, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %33, double 0x400921FB54442D18)
  %34 = load i64, ptr %5, align 4
  %35 = and i64 %34, 128
  %.not1664 = icmp eq i64 %35, 0
  br i1 %.not1664, label %panic.i1594, label %__barray_mask_return.exit1595

panic.i1594:                                      ; preds = %__barray_mask_borrow.exit1593
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1595:                    ; preds = %__barray_mask_borrow.exit1593
  %36 = and i64 %34, -129
  store i64 %36, ptr %5, align 4
  store i64 %33, ptr %32, align 4
  br label %__barray_check_bounds.exit1617

__barray_check_bounds.exit1597:                   ; preds = %__barray_mask_return.exit1591, %__barray_mask_return.exit1611
  %37 = phi i64 [ %65, %__barray_mask_return.exit1611 ], [ 1, %__barray_mask_return.exit1591 ]
  %"107_3.01667" = phi i64 [ %37, %__barray_mask_return.exit1611 ], [ 0, %__barray_mask_return.exit1591 ]
  %38 = load i64, ptr %5, align 4
  %39 = lshr i64 %38, %"6_0.01668"
  %40 = trunc i64 %39 to i1
  br i1 %40, label %panic.i1598, label %__barray_check_bounds.exit1601

panic.i1598:                                      ; preds = %__barray_check_bounds.exit1597
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1601:                   ; preds = %__barray_check_bounds.exit1597
  %41 = xor i64 %38, %21
  store i64 %41, ptr %5, align 4
  %42 = load i64, ptr %23, align 4
  %43 = sub nuw nsw i64 7, %"107_3.01667"
  %44 = lshr i64 %41, %43
  %45 = trunc i64 %44 to i1
  br i1 %45, label %panic.i1602, label %__barray_mask_borrow.exit1603

panic.i1602:                                      ; preds = %__barray_check_bounds.exit1601
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1603:                    ; preds = %__barray_check_bounds.exit1601
  %46 = shl nuw nsw i64 1, %43
  %47 = xor i64 %41, %46
  store i64 %47, ptr %5, align 4
  %48 = getelementptr inbounds nuw i64, ptr %4, i64 %43
  %49 = load i64, ptr %48, align 4
  br label %pow

pow:                                              ; preds = %pow_body, %__barray_mask_borrow.exit1603
  %storemerge1584 = phi i64 [ 2, %__barray_mask_borrow.exit1603 ], [ %new_acc, %pow_body ]
  %storemerge = phi i64 [ %"6_0.01668", %__barray_mask_borrow.exit1603 ], [ %new_exp, %pow_body ]
  switch i64 %storemerge, label %pow_body [
    i64 1, label %done.loopexit
    i64 0, label %done
  ]

pow_body:                                         ; preds = %pow
  %new_acc = shl i64 %storemerge1584, 1
  %new_exp = add i64 %storemerge, -1
  br label %pow

done.loopexit:                                    ; preds = %pow
  %50 = sitofp i64 %storemerge1584 to double
  br label %done

done:                                             ; preds = %pow, %done.loopexit
  %storemerge1671 = phi double [ %50, %done.loopexit ], [ 1.000000e+00, %pow ]
  %reciprocal = fdiv double 1.000000e+00, %storemerge1671
  %51 = tail call double @llvm.fabs.f64(double %reciprocal)
  %52 = fcmp ueq double %51, 0x7FF0000000000000
  br i1 %52, label %53, label %__barray_check_bounds.exit1605

53:                                               ; preds = %done
  tail call void @panic(i32 1001, ptr nonnull @e_tket.rotat.20D0216B.0)
  unreachable

__barray_check_bounds.exit1605:                   ; preds = %done
  %54 = fmul double %reciprocal, 0x400921FB54442D18
  %55 = fmul double %54, 5.000000e-01
  %56 = fneg double %55
  tail call void @___rzz(i64 %42, i64 %49, double %56)
  tail call void @___rz(i64 %49, double %55)
  %57 = load i64, ptr %5, align 4
  %58 = lshr i64 %57, %"6_0.01668"
  %59 = trunc i64 %58 to i1
  br i1 %59, label %__barray_check_bounds.exit1609, label %panic.i1606

panic.i1606:                                      ; preds = %__barray_check_bounds.exit1605
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1609:                   ; preds = %__barray_check_bounds.exit1605
  %60 = xor i64 %57, %21
  store i64 %60, ptr %5, align 4
  store i64 %42, ptr %23, align 4
  %61 = load i64, ptr %5, align 4
  %62 = lshr i64 %61, %43
  %63 = trunc i64 %62 to i1
  br i1 %63, label %__barray_mask_return.exit1611, label %panic.i1610

panic.i1610:                                      ; preds = %__barray_check_bounds.exit1609
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1611:                    ; preds = %__barray_check_bounds.exit1609
  %64 = xor i64 %61, %46
  store i64 %64, ptr %5, align 4
  store i64 %49, ptr %48, align 4
  %65 = add nuw nsw i64 %37, 1
  %exitcond1673.not = icmp eq i64 %65, %indvars.iv
  br i1 %exitcond1673.not, label %loop_out.loopexit, label %__barray_check_bounds.exit1597

out_of_bounds.i1612:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1613:                   ; preds = %.thread
  %66 = load i64, ptr %3, align 4
  %67 = lshr i64 %66, %"406_2.01682"
  %68 = trunc i64 %67 to i1
  br i1 %68, label %cond_exit_410, label %panic.i1614

panic.i1614:                                      ; preds = %__barray_check_bounds.exit1613
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_410
  %69 = load i64, ptr %5, align 4
  %70 = or i64 %69, -256
  store i64 %70, ptr %5, align 4
  %71 = icmp eq i64 %70, -1
  br i1 %71, label %loop_body739.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1617:                   ; preds = %__barray_mask_return.exit1595, %cond_exit_410
  %"406_0.sroa.15.01683" = phi i64 [ 0, %__barray_mask_return.exit1595 ], [ %72, %cond_exit_410 ]
  %"406_2.01682" = phi i64 [ 0, %__barray_mask_return.exit1595 ], [ %80, %cond_exit_410 ]
  %72 = add nuw nsw i64 %"406_0.sroa.15.01683", 1
  %73 = load i64, ptr %5, align 4
  %74 = lshr i64 %73, %"406_0.sroa.15.01683"
  %75 = trunc i64 %74 to i1
  br i1 %75, label %panic.i1618, label %.thread

panic.i1618:                                      ; preds = %__barray_check_bounds.exit1617
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_check_bounds.exit1617
  %76 = shl nuw nsw i64 1, %"406_0.sroa.15.01683"
  %77 = xor i64 %73, %76
  store i64 %77, ptr %5, align 4
  %78 = getelementptr inbounds nuw i64, ptr %4, i64 %"406_0.sroa.15.01683"
  %79 = load i64, ptr %78, align 4
  %80 = add i64 %"406_2.01682", 1
  %lazy_measure = tail call i64 @___lazy_measure(i64 %79)
  tail call void @___qfree(i64 %79)
  %81 = icmp ult i64 %"406_2.01682", 8
  br i1 %81, label %__barray_check_bounds.exit1613, label %out_of_bounds.i1612

cond_exit_410:                                    ; preds = %__barray_check_bounds.exit1613
  %82 = shl nuw nsw i64 1, %"406_2.01682"
  %83 = xor i64 %66, %82
  store i64 %83, ptr %3, align 4
  %84 = getelementptr inbounds nuw i64, ptr %2, i64 %"406_2.01682"
  store i64 %lazy_measure, ptr %84, align 4
  %85 = icmp samesign ugt i64 %"406_0.sroa.15.01683", 6
  br i1 %85, label %mask_block_ok.i, label %__barray_check_bounds.exit1617

loop_body739.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  br label %__barray_check_bounds.exit1621

__barray_check_bounds.exit1621:                   ; preds = %cond_exit_476, %loop_body739.preheader.preheader
  %"472_0.sroa.15.01670" = phi i64 [ %86, %cond_exit_476 ], [ 0, %loop_body739.preheader.preheader ]
  %86 = add nuw nsw i64 %"472_0.sroa.15.01670", 1
  %87 = load i64, ptr %3, align 4
  %88 = lshr i64 %87, %"472_0.sroa.15.01670"
  %89 = trunc i64 %88 to i1
  br i1 %89, label %panic.i1622, label %__barray_check_bounds.exit1625

panic.i1622:                                      ; preds = %__barray_check_bounds.exit1621
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1625:                   ; preds = %__barray_check_bounds.exit1621
  %90 = shl nuw nsw i64 1, %"472_0.sroa.15.01670"
  %91 = xor i64 %87, %90
  store i64 %91, ptr %3, align 4
  %92 = getelementptr inbounds nuw i64, ptr %2, i64 %"472_0.sroa.15.01670"
  %93 = load i64, ptr %92, align 4
  tail call void @___inc_future_refcount(i64 %93)
  %94 = load i64, ptr %3, align 4
  %95 = lshr i64 %94, %"472_0.sroa.15.01670"
  %96 = trunc i64 %95 to i1
  br i1 %96, label %__barray_check_bounds.exit1629, label %panic.i1626

panic.i1626:                                      ; preds = %__barray_check_bounds.exit1625
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1629:                   ; preds = %__barray_check_bounds.exit1625
  %97 = xor i64 %94, %90
  store i64 %97, ptr %3, align 4
  store i64 %93, ptr %92, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %93)
  tail call void @___dec_future_refcount(i64 %93)
  %98 = load i64, ptr %1, align 4
  %99 = lshr i64 %98, %"472_0.sroa.15.01670"
  %100 = trunc i64 %99 to i1
  br i1 %100, label %cond_exit_476, label %panic.i1630

panic.i1630:                                      ; preds = %__barray_check_bounds.exit1629
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_err.i1635:                             ; preds = %cond_exit_665.7
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit1643:                    ; preds = %__barray_check_bounds.exit1639.preheader
  %101 = or disjoint i64 %144, 1
  store i64 %101, ptr %3, align 4
  %102 = load i64, ptr %2, align 4
  tail call void @___dec_future_refcount(i64 %102)
  br label %cond_exit_665

cond_exit_665:                                    ; preds = %__barray_mask_borrow.exit1643, %__barray_check_bounds.exit1639.preheader
  %103 = load i64, ptr %3, align 4
  %104 = and i64 %103, 2
  %.not = icmp eq i64 %104, 0
  br i1 %.not, label %__barray_mask_borrow.exit1643.1, label %cond_exit_665.1

__barray_mask_borrow.exit1643.1:                  ; preds = %cond_exit_665
  %105 = or disjoint i64 %103, 2
  store i64 %105, ptr %3, align 4
  %106 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %107 = load i64, ptr %106, align 4
  tail call void @___dec_future_refcount(i64 %107)
  br label %cond_exit_665.1

cond_exit_665.1:                                  ; preds = %__barray_mask_borrow.exit1643.1, %cond_exit_665
  %108 = load i64, ptr %3, align 4
  %109 = and i64 %108, 4
  %.not1687 = icmp eq i64 %109, 0
  br i1 %.not1687, label %__barray_mask_borrow.exit1643.2, label %cond_exit_665.2

__barray_mask_borrow.exit1643.2:                  ; preds = %cond_exit_665.1
  %110 = or disjoint i64 %108, 4
  store i64 %110, ptr %3, align 4
  %111 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %112 = load i64, ptr %111, align 4
  tail call void @___dec_future_refcount(i64 %112)
  br label %cond_exit_665.2

cond_exit_665.2:                                  ; preds = %__barray_mask_borrow.exit1643.2, %cond_exit_665.1
  %113 = load i64, ptr %3, align 4
  %114 = and i64 %113, 8
  %.not1688 = icmp eq i64 %114, 0
  br i1 %.not1688, label %__barray_mask_borrow.exit1643.3, label %cond_exit_665.3

__barray_mask_borrow.exit1643.3:                  ; preds = %cond_exit_665.2
  %115 = or disjoint i64 %113, 8
  store i64 %115, ptr %3, align 4
  %116 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %117 = load i64, ptr %116, align 4
  tail call void @___dec_future_refcount(i64 %117)
  br label %cond_exit_665.3

cond_exit_665.3:                                  ; preds = %__barray_mask_borrow.exit1643.3, %cond_exit_665.2
  %118 = load i64, ptr %3, align 4
  %119 = and i64 %118, 16
  %.not1689 = icmp eq i64 %119, 0
  br i1 %.not1689, label %__barray_mask_borrow.exit1643.4, label %cond_exit_665.4

__barray_mask_borrow.exit1643.4:                  ; preds = %cond_exit_665.3
  %120 = or disjoint i64 %118, 16
  store i64 %120, ptr %3, align 4
  %121 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %122 = load i64, ptr %121, align 4
  tail call void @___dec_future_refcount(i64 %122)
  br label %cond_exit_665.4

cond_exit_665.4:                                  ; preds = %__barray_mask_borrow.exit1643.4, %cond_exit_665.3
  %123 = load i64, ptr %3, align 4
  %124 = and i64 %123, 32
  %.not1690 = icmp eq i64 %124, 0
  br i1 %.not1690, label %__barray_mask_borrow.exit1643.5, label %cond_exit_665.5

__barray_mask_borrow.exit1643.5:                  ; preds = %cond_exit_665.4
  %125 = or disjoint i64 %123, 32
  store i64 %125, ptr %3, align 4
  %126 = getelementptr inbounds nuw i8, ptr %2, i64 40
  %127 = load i64, ptr %126, align 4
  tail call void @___dec_future_refcount(i64 %127)
  br label %cond_exit_665.5

cond_exit_665.5:                                  ; preds = %__barray_mask_borrow.exit1643.5, %cond_exit_665.4
  %128 = load i64, ptr %3, align 4
  %129 = and i64 %128, 64
  %.not1691 = icmp eq i64 %129, 0
  br i1 %.not1691, label %__barray_mask_borrow.exit1643.6, label %cond_exit_665.6

__barray_mask_borrow.exit1643.6:                  ; preds = %cond_exit_665.5
  %130 = or disjoint i64 %128, 64
  store i64 %130, ptr %3, align 4
  %131 = getelementptr inbounds nuw i8, ptr %2, i64 48
  %132 = load i64, ptr %131, align 4
  tail call void @___dec_future_refcount(i64 %132)
  br label %cond_exit_665.6

cond_exit_665.6:                                  ; preds = %__barray_mask_borrow.exit1643.6, %cond_exit_665.5
  %133 = load i64, ptr %3, align 4
  %134 = and i64 %133, 128
  %.not1692 = icmp eq i64 %134, 0
  br i1 %.not1692, label %__barray_mask_borrow.exit1643.7, label %cond_exit_665.7

__barray_mask_borrow.exit1643.7:                  ; preds = %cond_exit_665.6
  %135 = or disjoint i64 %133, 128
  store i64 %135, ptr %3, align 4
  %136 = getelementptr inbounds nuw i8, ptr %2, i64 56
  %137 = load i64, ptr %136, align 4
  tail call void @___dec_future_refcount(i64 %137)
  br label %cond_exit_665.7

cond_exit_665.7:                                  ; preds = %__barray_mask_borrow.exit1643.7, %cond_exit_665.6
  %138 = load i64, ptr %3, align 4
  %139 = or i64 %138, -256
  store i64 %139, ptr %3, align 4
  %140 = icmp eq i64 %139, -1
  br i1 %140, label %loop_out738, label %mask_block_err.i1635

cond_exit_476:                                    ; preds = %__barray_check_bounds.exit1629
  %141 = xor i64 %98, %90
  store i64 %141, ptr %1, align 4
  %142 = getelementptr inbounds nuw i1, ptr %0, i64 %"472_0.sroa.15.01670"
  store i1 %read_bool, ptr %142, align 1
  %143 = icmp eq i64 %"472_0.sroa.15.01670", 7
  br i1 %143, label %__barray_check_bounds.exit1639.preheader, label %__barray_check_bounds.exit1621

__barray_check_bounds.exit1639.preheader:         ; preds = %cond_exit_476
  %144 = load i64, ptr %3, align 4
  %145 = trunc i64 %144 to i1
  br i1 %145, label %cond_exit_665, label %__barray_mask_borrow.exit1643

loop_out738:                                      ; preds = %cond_exit_665.7
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %146 = load i64, ptr %1, align 4
  %147 = and i64 %146, 255
  store i64 %147, ptr %1, align 4
  %148 = icmp eq i64 %147, 0
  br i1 %148, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1644

mask_block_err.i1644:                             ; preds = %loop_out738
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out738
  %149 = tail call ptr @heap_alloc(i64 8)
  %150 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %150, align 1
  %151 = load i64, ptr %0, align 1
  store i64 %151, ptr %149, align 1
  tail call void @heap_free(ptr nonnull %149)
  %152 = load i64, ptr %1, align 4
  %153 = and i64 %152, 255
  store i64 %153, ptr %1, align 4
  %154 = icmp eq i64 %153, 0
  br i1 %154, label %__barray_check_none_borrowed.exit1648, label %mask_block_err.i1646

mask_block_err.i1646:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1648:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %155 = alloca [8 x i1], align 8
  store i64 0, ptr %155, align 8
  store i32 8, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %155, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_measuremen.F30240EB.0, i64 25, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @heap_free(ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fabs.f64(double) #1

attributes #0 = { noreturn }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!name = !{!0}

!0 = !{!"mainlib"}
