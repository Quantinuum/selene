; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_measuremen.F30240EB.0 = private constant [26 x i8] c"\19USER:BOOLARR:measurements"
@e_tket.rotat.20D0216B.0 = private constant [55 x i8] c"6EXIT:INT:tket.rotation.from_halfturns_unchecked failed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 64)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_664_case_0.i, label %__hugr__.__tk2_sol_qalloc.637.exit

cond_exit_173.loopexit:                           ; preds = %__barray_mask_return.exit771
  %indvars.iv.next = add nsw i64 %indvars.iv, -1
  %exitcond806.not = icmp eq i64 %39, 8
  br i1 %exitcond806.not, label %cond_exit_89, label %__barray_check_bounds.exit728

cond_188_case_1:                                  ; preds = %__barray_check_bounds.exit757
  %2 = xor i64 %245, %43
  store i64 %2, ptr %1, align 4
  %3 = load i64, ptr %45, align 4
  br label %pow.i

pow.i:                                            ; preds = %cond_188_case_1, %pow_body.i
  %storemerge53.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %cond_188_case_1 ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"45_0.0802", %cond_188_case_1 ]
  switch i64 %storemerge.i, label %pow_body.i [
    i64 1, label %__hugr__.guppylang.std.num.int.__pow__.413.exit.loopexit
    i64 0, label %__hugr__.guppylang.std.num.int.__pow__.413.exit
  ]

pow_body.i:                                       ; preds = %pow.i
  %new_acc.i = shl i64 %storemerge53.i, 1
  %new_exp.i = add i64 %storemerge.i, -1
  br label %pow.i

__hugr__.guppylang.std.num.int.__pow__.413.exit.loopexit: ; preds = %pow.i
  %4 = sitofp i64 %storemerge53.i to double
  br label %__hugr__.guppylang.std.num.int.__pow__.413.exit

__hugr__.guppylang.std.num.int.__pow__.413.exit:  ; preds = %pow.i, %__hugr__.guppylang.std.num.int.__pow__.413.exit.loopexit
  %storemerge55.i = phi double [ %4, %__hugr__.guppylang.std.num.int.__pow__.413.exit.loopexit ], [ 1.000000e+00, %pow.i ]
  %5 = fdiv double 1.000000e+00, %storemerge55.i
  %6 = tail call double @llvm.fabs.f64(double %5)
  %7 = fcmp ueq double %6, 0x7FF0000000000000
  br i1 %7, label %248, label %__barray_check_bounds.exit761

cond_664_case_0.i:                                ; preds = %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.637.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %8 = load i64, ptr %1, align 4
  %9 = trunc i64 %8 to i1
  br i1 %9, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.7, %__hugr__.__tk2_sol_qalloc.637.exit.6, %__hugr__.__tk2_sol_qalloc.637.exit.5, %__hugr__.__tk2_sol_qalloc.637.exit.4, %__hugr__.__tk2_sol_qalloc.637.exit.3, %__hugr__.__tk2_sol_qalloc.637.exit.2, %__hugr__.__tk2_sol_qalloc.637.exit.1, %__hugr__.__tk2_sol_qalloc.637.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_sol_qalloc.637.exit
  %10 = and i64 %8, -2
  store i64 %10, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_664_case_0.i, label %__hugr__.__tk2_sol_qalloc.637.exit.1

__hugr__.__tk2_sol_qalloc.637.exit.1:             ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %11 = load i64, ptr %1, align 4
  %12 = and i64 %11, 2
  %.not807 = icmp eq i64 %12, 0
  br i1 %.not807, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.637.exit.1
  %13 = and i64 %11, -3
  store i64 %13, ptr %1, align 4
  %14 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %14, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_664_case_0.i, label %__hugr__.__tk2_sol_qalloc.637.exit.2

__hugr__.__tk2_sol_qalloc.637.exit.2:             ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %15 = load i64, ptr %1, align 4
  %16 = and i64 %15, 4
  %.not808 = icmp eq i64 %16, 0
  br i1 %.not808, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_sol_qalloc.637.exit.2
  %17 = and i64 %15, -5
  store i64 %17, ptr %1, align 4
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %18, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_664_case_0.i, label %__hugr__.__tk2_sol_qalloc.637.exit.3

__hugr__.__tk2_sol_qalloc.637.exit.3:             ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %19 = load i64, ptr %1, align 4
  %20 = and i64 %19, 8
  %.not809 = icmp eq i64 %20, 0
  br i1 %.not809, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_sol_qalloc.637.exit.3
  %21 = and i64 %19, -9
  store i64 %21, ptr %1, align 4
  %22 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %22, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_664_case_0.i, label %__hugr__.__tk2_sol_qalloc.637.exit.4

__hugr__.__tk2_sol_qalloc.637.exit.4:             ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %23 = load i64, ptr %1, align 4
  %24 = and i64 %23, 16
  %.not810 = icmp eq i64 %24, 0
  br i1 %.not810, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_sol_qalloc.637.exit.4
  %25 = and i64 %23, -17
  store i64 %25, ptr %1, align 4
  %26 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %26, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_664_case_0.i, label %__hugr__.__tk2_sol_qalloc.637.exit.5

__hugr__.__tk2_sol_qalloc.637.exit.5:             ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %27 = load i64, ptr %1, align 4
  %28 = and i64 %27, 32
  %.not811 = icmp eq i64 %28, 0
  br i1 %.not811, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_sol_qalloc.637.exit.5
  %29 = and i64 %27, -33
  store i64 %29, ptr %1, align 4
  %30 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %30, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_664_case_0.i, label %__hugr__.__tk2_sol_qalloc.637.exit.6

__hugr__.__tk2_sol_qalloc.637.exit.6:             ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %31 = load i64, ptr %1, align 4
  %32 = and i64 %31, 64
  %.not812 = icmp eq i64 %32, 0
  br i1 %.not812, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_sol_qalloc.637.exit.6
  %33 = and i64 %31, -65
  store i64 %33, ptr %1, align 4
  %34 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %34, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_664_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %35 = load i64, ptr %1, align 4
  %36 = and i64 %35, 128
  %.not813 = icmp eq i64 %36, 0
  br i1 %.not813, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %37 = and i64 %35, -129
  store i64 %37, ptr %1, align 4
  %38 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %38, align 4
  br label %__barray_check_bounds.exit728

__barray_check_bounds.exit728:                    ; preds = %cond_exit_173.loopexit, %cond_exit_20.7
  %indvars.iv = phi i64 [ 7, %cond_exit_20.7 ], [ %indvars.iv.next, %cond_exit_173.loopexit ]
  %"45_0.0802" = phi i64 [ 0, %cond_exit_20.7 ], [ %39, %cond_exit_173.loopexit ]
  %smax = tail call i64 @llvm.smax.i64(i64 %indvars.iv, i64 1)
  %39 = add nuw nsw i64 %"45_0.0802", 1
  %40 = load i64, ptr %1, align 4
  %41 = lshr i64 %40, %"45_0.0802"
  %42 = trunc i64 %41 to i1
  br i1 %42, label %panic.i729, label %__barray_check_bounds.exit731

panic.i729:                                       ; preds = %__barray_check_bounds.exit728
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit731:                    ; preds = %__barray_check_bounds.exit728
  %43 = shl nuw nsw i64 1, %"45_0.0802"
  %44 = xor i64 %40, %43
  store i64 %44, ptr %1, align 4
  %45 = getelementptr inbounds nuw i64, ptr %0, i64 %"45_0.0802"
  %46 = load i64, ptr %45, align 4
  tail call void @___rp(i64 %46, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %46, double 0x400921FB54442D18)
  %47 = load i64, ptr %1, align 4
  %48 = lshr i64 %47, %"45_0.0802"
  %49 = trunc i64 %48 to i1
  br i1 %49, label %__barray_mask_return.exit733, label %panic.i732

panic.i732:                                       ; preds = %__barray_check_bounds.exit731
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit733:                     ; preds = %__barray_check_bounds.exit731
  %50 = xor i64 %47, %43
  store i64 %50, ptr %1, align 4
  store i64 %46, ptr %45, align 4
  %.not803 = icmp eq i64 %"45_0.0802", 7
  br i1 %.not803, label %cond_exit_89, label %__barray_check_bounds.exit757

cond_exit_89:                                     ; preds = %__barray_mask_return.exit733, %cond_exit_173.loopexit
  %"45_368.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"45_368.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"45_368.fca.0.insert", ptr %1, 1
  %"45_368.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"45_368.fca.1.insert", i64 0, 2
  %51 = load i64, ptr %1, align 4
  %52 = and i64 %51, 128
  %.not = icmp eq i64 %52, 0
  br i1 %.not, label %__barray_mask_borrow.exit735, label %panic.i734

panic.i734:                                       ; preds = %cond_exit_89
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit735:                     ; preds = %cond_exit_89
  %53 = or disjoint i64 %51, 128
  store i64 %53, ptr %1, align 4
  %54 = load i64, ptr %38, align 4
  tail call void @___rp(i64 %54, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %54, double 0x400921FB54442D18)
  %55 = load i64, ptr %1, align 4
  %56 = and i64 %55, 128
  %.not794 = icmp eq i64 %56, 0
  br i1 %.not794, label %panic.i736, label %__barray_mask_return.exit737

panic.i736:                                       ; preds = %__barray_mask_borrow.exit735
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit737:                     ; preds = %__barray_mask_borrow.exit735
  %57 = and i64 %55, -129
  store i64 %57, ptr %1, align 4
  store i64 %54, ptr %38, align 4
  %58 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"45_368.fca.2.insert", 0
  %59 = tail call ptr @heap_alloc(i64 64)
  %60 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %60, align 1
  br label %__barray_check_bounds.exit.i.i

61:                                               ; preds = %loop_body.i
  %62 = lshr i64 %.fca.2.extract.i.i, 6
  %63 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %62
  %64 = load i64, ptr %63, align 4
  %65 = and i64 %.fca.2.extract.i.i, 63
  %66 = sub nuw nsw i64 64, %65
  %67 = lshr i64 -1, %66
  %68 = icmp eq i64 %65, 0
  %69 = select i1 %68, i64 0, i64 %67
  %70 = or i64 %64, %69
  store i64 %70, ptr %63, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 7
  %71 = lshr i64 %last_valid.i.i.i, 6
  %72 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %71
  %73 = load i64, ptr %72, align 4
  %74 = and i64 %last_valid.i.i.i, 63
  %75 = shl nsw i64 -2, %74
  %76 = icmp eq i64 %74, 63
  %77 = select i1 %76, i64 0, i64 %75
  %78 = or i64 %73, %77
  store i64 %78, ptr %72, align 4
  %reass.sub.i.i.i = sub nsw i64 %71, %62
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$8.335.exit", label %mask_block_ok.i.i.i

79:                                               ; preds = %mask_block_ok.i.i.i
  %80 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$8.335.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %61, %79
  %.02.i.i.i = phi i64 [ %80, %79 ], [ 0, %61 ]
  %gep.i.i.i = getelementptr i64, ptr %63, i64 %.02.i.i.i
  %81 = load i64, ptr %gep.i.i.i, align 4
  %82 = icmp eq i64 %81, -1
  br i1 %82, label %79, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %__barray_mask_return.exit737
  %.fca.2.extract.i181.i = phi i64 [ 0, %__barray_mask_return.exit737 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %__barray_mask_return.exit737 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %__barray_mask_return.exit737 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"349_0.sroa.15.0178.i" = phi i64 [ 0, %__barray_mask_return.exit737 ], [ %83, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %58, %__barray_mask_return.exit737 ], [ %98, %loop_body.i ]
  %83 = add nuw nsw i64 %"349_0.sroa.15.0178.i", 1
  %84 = add i64 %"349_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %85 = lshr i64 %84, 6
  %86 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %85
  %87 = load i64, ptr %86, align 4
  %88 = and i64 %84, 63
  %89 = lshr i64 %87, %88
  %90 = trunc i64 %89 to i1
  br i1 %90, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %91 = shl nuw i64 1, %88
  %92 = xor i64 %91, %87
  store i64 %92, ptr %86, align 4
  %93 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %84
  %94 = load i64, ptr %93, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %94)
  tail call void @___qfree(i64 %94)
  %95 = load i64, ptr %60, align 4
  %96 = lshr i64 %95, %"349_0.sroa.15.0178.i"
  %97 = trunc i64 %96 to i1
  br i1 %97, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %98 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %83, 1
  %99 = shl nuw nsw i64 1, %"349_0.sroa.15.0178.i"
  %100 = xor i64 %95, %99
  store i64 %100, ptr %60, align 4
  %101 = getelementptr inbounds nuw i64, ptr %59, i64 %"349_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %101, align 4
  %102 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %102, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %102, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %102, 2
  %exitcond.not.i = icmp eq i64 %83, 8
  br i1 %exitcond.not.i, label %61, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$8.335.exit": ; preds = %79, %61
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %59, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %60, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %103 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %104 = tail call ptr @heap_alloc(i64 8)
  %105 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %105, align 1
  br label %__barray_check_bounds.exit.i.i738

loop_body.preheader.i.i:                          ; preds = %loop_body.i741
  %"684_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %232, 2
  %"684_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %232, 1
  %"684_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %232, 0
  %106 = lshr i64 %"684_1.sroa.10.0.i.i", 6
  %107 = getelementptr i64, ptr %"684_1.sroa.5.0.i.i", i64 %106
  %108 = load i64, ptr %107, align 4
  %109 = and i64 %"684_1.sroa.10.0.i.i", 63
  %110 = lshr i64 %108, %109
  %111 = trunc i64 %110 to i1
  br i1 %111, label %cond_exit_687.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_check_bounds.exit.i.i738:                ; preds = %loop_body.i741, %"__hugr__.guppylang.std.quantum.measure_array$8.335.exit"
  %112 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$8.335.exit" ], [ %232, %loop_body.i741 ]
  %"308_0.sroa.15.0168.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$8.335.exit" ], [ %113, %loop_body.i741 ]
  %.pn159167.i = phi { { ptr, ptr, i64 }, i64 } [ %103, %"__hugr__.guppylang.std.quantum.measure_array$8.335.exit" ], [ %228, %loop_body.i741 ]
  %113 = add nuw nsw i64 %"308_0.sroa.15.0168.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %112, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %112, 1
  %114 = add i64 %.fca.2.extract208.i.i, %"308_0.sroa.15.0168.i"
  %115 = lshr i64 %114, 6
  %116 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %115
  %117 = load i64, ptr %116, align 4
  %118 = and i64 %114, 63
  %119 = lshr i64 %117, %118
  %120 = trunc i64 %119 to i1
  br i1 %120, label %panic.i.i.i753, label %__barray_check_bounds.exit221.i.i

panic.i.i.i753:                                   ; preds = %__barray_check_bounds.exit.i.i738
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i738
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %112, 0
  %121 = shl nuw i64 1, %118
  %122 = xor i64 %121, %117
  store i64 %122, ptr %116, align 4
  %123 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %114
  %124 = load i64, ptr %123, align 4
  tail call void @___inc_future_refcount(i64 %124)
  %125 = load i64, ptr %116, align 4
  %126 = lshr i64 %125, %118
  %127 = trunc i64 %126 to i1
  br i1 %127, label %__barray_check_bounds.exit.i739, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

128:                                              ; preds = %mask_block_ok.i.i.i745
  %129 = add nuw i64 %.02.i.i.i746, 1
  %exitcond.not.i.i.i749 = icmp eq i64 %.02.i.i.i746, %reass.sub.i.i.i743
  br i1 %exitcond.not.i.i.i749, label %"__hugr__.guppylang.std.quantum.collect_measurements$8.294.exit", label %mask_block_ok.i.i.i745

mask_block_ok.i.i.i745:                           ; preds = %cond_exit_687.thread.7.i.i, %128
  %.02.i.i.i746 = phi i64 [ %129, %128 ], [ 0, %cond_exit_687.thread.7.i.i ]
  %gep.i.i.i747 = getelementptr i64, ptr %107, i64 %.02.i.i.i746
  %130 = load i64, ptr %gep.i.i.i747, align 4
  %131 = icmp eq i64 %130, -1
  br i1 %131, label %128, label %mask_block_err.i.i.i748

mask_block_err.i.i.i748:                          ; preds = %mask_block_ok.i.i.i745
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i.i:                 ; preds = %loop_body.preheader.i.i
  %132 = shl nuw i64 1, %109
  %133 = xor i64 %108, %132
  store i64 %133, ptr %107, align 4
  %134 = getelementptr inbounds i64, ptr %"684_1.sroa.0.0.i.i", i64 %"684_1.sroa.10.0.i.i"
  %135 = load i64, ptr %134, align 4
  tail call void @___dec_future_refcount(i64 %135)
  br label %cond_exit_687.thread.i.i

cond_exit_687.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %loop_body.preheader.i.i
  %136 = add i64 %"684_1.sroa.10.0.i.i", 1
  %137 = lshr i64 %136, 6
  %138 = getelementptr inbounds nuw i64, ptr %"684_1.sroa.5.0.i.i", i64 %137
  %139 = load i64, ptr %138, align 4
  %140 = and i64 %136, 63
  %141 = lshr i64 %139, %140
  %142 = trunc i64 %141 to i1
  br i1 %142, label %cond_exit_687.thread.1.i.i, label %__barray_mask_borrow.exit228.1.i.i

__barray_mask_borrow.exit228.1.i.i:               ; preds = %cond_exit_687.thread.i.i
  %143 = shl nuw i64 1, %140
  %144 = xor i64 %139, %143
  store i64 %144, ptr %138, align 4
  %145 = getelementptr inbounds i64, ptr %"684_1.sroa.0.0.i.i", i64 %136
  %146 = load i64, ptr %145, align 4
  tail call void @___dec_future_refcount(i64 %146)
  br label %cond_exit_687.thread.1.i.i

cond_exit_687.thread.1.i.i:                       ; preds = %__barray_mask_borrow.exit228.1.i.i, %cond_exit_687.thread.i.i
  %147 = add i64 %"684_1.sroa.10.0.i.i", 2
  %148 = lshr i64 %147, 6
  %149 = getelementptr inbounds nuw i64, ptr %"684_1.sroa.5.0.i.i", i64 %148
  %150 = load i64, ptr %149, align 4
  %151 = and i64 %147, 63
  %152 = lshr i64 %150, %151
  %153 = trunc i64 %152 to i1
  br i1 %153, label %cond_exit_687.thread.2.i.i, label %__barray_mask_borrow.exit228.2.i.i

__barray_mask_borrow.exit228.2.i.i:               ; preds = %cond_exit_687.thread.1.i.i
  %154 = shl nuw i64 1, %151
  %155 = xor i64 %150, %154
  store i64 %155, ptr %149, align 4
  %156 = getelementptr inbounds i64, ptr %"684_1.sroa.0.0.i.i", i64 %147
  %157 = load i64, ptr %156, align 4
  tail call void @___dec_future_refcount(i64 %157)
  br label %cond_exit_687.thread.2.i.i

cond_exit_687.thread.2.i.i:                       ; preds = %__barray_mask_borrow.exit228.2.i.i, %cond_exit_687.thread.1.i.i
  %158 = add i64 %"684_1.sroa.10.0.i.i", 3
  %159 = lshr i64 %158, 6
  %160 = getelementptr inbounds nuw i64, ptr %"684_1.sroa.5.0.i.i", i64 %159
  %161 = load i64, ptr %160, align 4
  %162 = and i64 %158, 63
  %163 = lshr i64 %161, %162
  %164 = trunc i64 %163 to i1
  br i1 %164, label %cond_exit_687.thread.3.i.i, label %__barray_mask_borrow.exit228.3.i.i

__barray_mask_borrow.exit228.3.i.i:               ; preds = %cond_exit_687.thread.2.i.i
  %165 = shl nuw i64 1, %162
  %166 = xor i64 %161, %165
  store i64 %166, ptr %160, align 4
  %167 = getelementptr inbounds i64, ptr %"684_1.sroa.0.0.i.i", i64 %158
  %168 = load i64, ptr %167, align 4
  tail call void @___dec_future_refcount(i64 %168)
  br label %cond_exit_687.thread.3.i.i

cond_exit_687.thread.3.i.i:                       ; preds = %__barray_mask_borrow.exit228.3.i.i, %cond_exit_687.thread.2.i.i
  %169 = add i64 %"684_1.sroa.10.0.i.i", 4
  %170 = lshr i64 %169, 6
  %171 = getelementptr inbounds nuw i64, ptr %"684_1.sroa.5.0.i.i", i64 %170
  %172 = load i64, ptr %171, align 4
  %173 = and i64 %169, 63
  %174 = lshr i64 %172, %173
  %175 = trunc i64 %174 to i1
  br i1 %175, label %cond_exit_687.thread.4.i.i, label %__barray_mask_borrow.exit228.4.i.i

__barray_mask_borrow.exit228.4.i.i:               ; preds = %cond_exit_687.thread.3.i.i
  %176 = shl nuw i64 1, %173
  %177 = xor i64 %172, %176
  store i64 %177, ptr %171, align 4
  %178 = getelementptr inbounds i64, ptr %"684_1.sroa.0.0.i.i", i64 %169
  %179 = load i64, ptr %178, align 4
  tail call void @___dec_future_refcount(i64 %179)
  br label %cond_exit_687.thread.4.i.i

cond_exit_687.thread.4.i.i:                       ; preds = %__barray_mask_borrow.exit228.4.i.i, %cond_exit_687.thread.3.i.i
  %180 = add i64 %"684_1.sroa.10.0.i.i", 5
  %181 = lshr i64 %180, 6
  %182 = getelementptr inbounds nuw i64, ptr %"684_1.sroa.5.0.i.i", i64 %181
  %183 = load i64, ptr %182, align 4
  %184 = and i64 %180, 63
  %185 = lshr i64 %183, %184
  %186 = trunc i64 %185 to i1
  br i1 %186, label %cond_exit_687.thread.5.i.i, label %__barray_mask_borrow.exit228.5.i.i

__barray_mask_borrow.exit228.5.i.i:               ; preds = %cond_exit_687.thread.4.i.i
  %187 = shl nuw i64 1, %184
  %188 = xor i64 %183, %187
  store i64 %188, ptr %182, align 4
  %189 = getelementptr inbounds i64, ptr %"684_1.sroa.0.0.i.i", i64 %180
  %190 = load i64, ptr %189, align 4
  tail call void @___dec_future_refcount(i64 %190)
  br label %cond_exit_687.thread.5.i.i

cond_exit_687.thread.5.i.i:                       ; preds = %__barray_mask_borrow.exit228.5.i.i, %cond_exit_687.thread.4.i.i
  %191 = add i64 %"684_1.sroa.10.0.i.i", 6
  %192 = lshr i64 %191, 6
  %193 = getelementptr inbounds nuw i64, ptr %"684_1.sroa.5.0.i.i", i64 %192
  %194 = load i64, ptr %193, align 4
  %195 = and i64 %191, 63
  %196 = lshr i64 %194, %195
  %197 = trunc i64 %196 to i1
  br i1 %197, label %cond_exit_687.thread.6.i.i, label %__barray_mask_borrow.exit228.6.i.i

__barray_mask_borrow.exit228.6.i.i:               ; preds = %cond_exit_687.thread.5.i.i
  %198 = shl nuw i64 1, %195
  %199 = xor i64 %194, %198
  store i64 %199, ptr %193, align 4
  %200 = getelementptr inbounds i64, ptr %"684_1.sroa.0.0.i.i", i64 %191
  %201 = load i64, ptr %200, align 4
  tail call void @___dec_future_refcount(i64 %201)
  br label %cond_exit_687.thread.6.i.i

cond_exit_687.thread.6.i.i:                       ; preds = %__barray_mask_borrow.exit228.6.i.i, %cond_exit_687.thread.5.i.i
  %202 = add i64 %"684_1.sroa.10.0.i.i", 7
  %203 = lshr i64 %202, 6
  %204 = getelementptr inbounds nuw i64, ptr %"684_1.sroa.5.0.i.i", i64 %203
  %205 = load i64, ptr %204, align 4
  %206 = and i64 %202, 63
  %207 = lshr i64 %205, %206
  %208 = trunc i64 %207 to i1
  br i1 %208, label %cond_exit_687.thread.7.i.i, label %__barray_mask_borrow.exit228.7.i.i

__barray_mask_borrow.exit228.7.i.i:               ; preds = %cond_exit_687.thread.6.i.i
  %209 = shl nuw i64 1, %206
  %210 = xor i64 %205, %209
  store i64 %210, ptr %204, align 4
  %211 = getelementptr inbounds i64, ptr %"684_1.sroa.0.0.i.i", i64 %202
  %212 = load i64, ptr %211, align 4
  tail call void @___dec_future_refcount(i64 %212)
  br label %cond_exit_687.thread.7.i.i

cond_exit_687.thread.7.i.i:                       ; preds = %__barray_mask_borrow.exit228.7.i.i, %cond_exit_687.thread.6.i.i
  %213 = load i64, ptr %107, align 4
  %214 = sub nuw nsw i64 64, %109
  %215 = lshr i64 -1, %214
  %216 = icmp eq i64 %109, 0
  %217 = select i1 %216, i64 0, i64 %215
  %218 = or i64 %213, %217
  store i64 %218, ptr %107, align 4
  %219 = load i64, ptr %204, align 4
  %220 = shl nsw i64 -2, %206
  %221 = icmp eq i64 %206, 63
  %222 = select i1 %221, i64 0, i64 %220
  %223 = or i64 %219, %222
  store i64 %223, ptr %204, align 4
  %reass.sub.i.i.i743 = sub nsw i64 %203, %106
  %.not.i.i.i744 = icmp eq i64 %reass.sub.i.i.i743, -1
  br i1 %.not.i.i.i744, label %"__hugr__.guppylang.std.quantum.collect_measurements$8.294.exit", label %mask_block_ok.i.i.i745

__barray_check_bounds.exit.i739:                  ; preds = %__barray_check_bounds.exit221.i.i
  %224 = xor i64 %125, %121
  store i64 %224, ptr %116, align 4
  store i64 %124, ptr %123, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %124)
  tail call void @___dec_future_refcount(i64 %124)
  %225 = load i64, ptr %105, align 4
  %226 = lshr i64 %225, %"308_0.sroa.15.0168.i"
  %227 = trunc i64 %226 to i1
  br i1 %227, label %loop_body.i741, label %panic.i.i740

panic.i.i740:                                     ; preds = %__barray_check_bounds.exit.i739
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i741:                                   ; preds = %__barray_check_bounds.exit.i739
  %228 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, i64 %113, 1
  %229 = shl nuw nsw i64 1, %"308_0.sroa.15.0168.i"
  %230 = xor i64 %225, %229
  store i64 %230, ptr %105, align 4
  %231 = getelementptr inbounds nuw i1, ptr %104, i64 %"308_0.sroa.15.0168.i"
  store i1 %read_bool.i, ptr %231, align 1
  %232 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, 0
  %exitcond.not.i742 = icmp eq i64 %113, 8
  br i1 %exitcond.not.i742, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i738

"__hugr__.guppylang.std.quantum.collect_measurements$8.294.exit": ; preds = %128, %cond_exit_687.thread.7.i.i
  tail call void @heap_free(ptr %"684_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"684_1.sroa.5.0.i.i")
  %233 = load i64, ptr %105, align 4
  %234 = and i64 %233, 255
  store i64 %234, ptr %105, align 4
  %235 = icmp eq i64 %234, 0
  br i1 %235, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$8.294.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$8.294.exit"
  %236 = tail call ptr @heap_alloc(i64 8)
  %237 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %237, align 1
  %238 = load i64, ptr %104, align 1
  store i64 %238, ptr %236, align 1
  tail call void @heap_free(ptr nonnull %236)
  %239 = load i64, ptr %105, align 4
  %240 = and i64 %239, 255
  store i64 %240, ptr %105, align 4
  %241 = icmp eq i64 %240, 0
  br i1 %241, label %__barray_check_none_borrowed.exit755, label %mask_block_err.i754

mask_block_err.i754:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit755:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %242 = alloca [8 x i1], align 8
  store i64 0, ptr %242, align 8
  store i32 8, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %104, ptr %arr_ptr, align 8
  store ptr %242, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_measuremen.F30240EB.0, i64 25, ptr nonnull %out_arr_alloca)
  ret void

__barray_check_bounds.exit757:                    ; preds = %__barray_mask_return.exit733, %__barray_mask_return.exit771
  %"136_3.0801" = phi i64 [ %243, %__barray_mask_return.exit771 ], [ 0, %__barray_mask_return.exit733 ]
  %243 = add nuw nsw i64 %"136_3.0801", 1
  %244 = sub nuw nsw i64 7, %"136_3.0801"
  %245 = load i64, ptr %1, align 4
  %246 = lshr i64 %245, %"45_0.0802"
  %247 = trunc i64 %246 to i1
  br i1 %247, label %panic.i758, label %cond_188_case_1

panic.i758:                                       ; preds = %__barray_check_bounds.exit757
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

248:                                              ; preds = %__hugr__.guppylang.std.num.int.__pow__.413.exit
  tail call void @panic(i32 1001, ptr nonnull @e_tket.rotat.20D0216B.0)
  unreachable

__barray_check_bounds.exit761:                    ; preds = %__hugr__.guppylang.std.num.int.__pow__.413.exit
  %249 = lshr i64 %2, %244
  %250 = trunc i64 %249 to i1
  br i1 %250, label %panic.i762, label %__barray_check_bounds.exit765

panic.i762:                                       ; preds = %__barray_check_bounds.exit761
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit765:                    ; preds = %__barray_check_bounds.exit761
  %251 = shl nuw nsw i64 1, %244
  %252 = xor i64 %2, %251
  store i64 %252, ptr %1, align 4
  %253 = getelementptr inbounds nuw i64, ptr %0, i64 %244
  %254 = load i64, ptr %253, align 4
  tail call void @___rp(i64 %254, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %3, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  %255 = fmul double %5, 0x400921FB54442D18
  %256 = fmul double %255, 5.000000e-01
  %257 = fneg double %256
  tail call void @___rpp(i64 %3, i64 %254, double %257, double 0xC00921FB54442D18)
  tail call void @___rp(i64 %254, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %254, double %256)
  tail call void @___rp(i64 %3, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  %258 = load i64, ptr %1, align 4
  %259 = lshr i64 %258, %"45_0.0802"
  %260 = trunc i64 %259 to i1
  br i1 %260, label %__barray_check_bounds.exit769, label %panic.i766

panic.i766:                                       ; preds = %__barray_check_bounds.exit765
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit769:                    ; preds = %__barray_check_bounds.exit765
  %261 = xor i64 %258, %43
  store i64 %261, ptr %1, align 4
  store i64 %3, ptr %45, align 4
  %262 = load i64, ptr %1, align 4
  %263 = lshr i64 %262, %244
  %264 = trunc i64 %263 to i1
  br i1 %264, label %__barray_mask_return.exit771, label %panic.i770

panic.i770:                                       ; preds = %__barray_check_bounds.exit769
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit771:                     ; preds = %__barray_check_bounds.exit769
  %265 = xor i64 %262, %251
  store i64 %265, ptr %1, align 4
  store i64 %254, ptr %253, align 4
  %exitcond.not = icmp eq i64 %243, %smax
  br i1 %exitcond.not, label %cond_exit_173.loopexit, label %__barray_check_bounds.exit757
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

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

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smax.i64(i64, i64) #1

attributes #0 = { noreturn }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!name = !{!0}

!0 = !{!"mainlib"}
