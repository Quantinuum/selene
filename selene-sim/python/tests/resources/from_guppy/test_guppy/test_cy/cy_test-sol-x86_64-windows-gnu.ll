; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_00.00F9F73D.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:00"
@res_01.2F21FB33.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:01"
@res_10.90CD55C3.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:10"
@res_11.7D0DF573.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:11"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define internal fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_94_case_0.i, label %__hugr__.__tk2_qalloc.90.exit

cond_94_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.90.exit:                    ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %qalloc.i755 = tail call i64 @___qalloc()
  %not_max.not.not.i756 = icmp eq i64 %qalloc.i755, -1
  br i1 %not_max.not.not.i756, label %cond_108_case_0.i, label %__hugr__.__tk2_qalloc.104.exit

cond_108_case_0.i:                                ; preds = %__hugr__.__tk2_qalloc.90.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.104.exit:                   ; preds = %__hugr__.__tk2_qalloc.90.exit
  tail call void @___reset(i64 %qalloc.i755)
  tail call void @___rz(i64 %qalloc.i755, double 0xBFF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %qalloc.i, i64 %qalloc.i755, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %qalloc.i755, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rz(i64 %qalloc.i755, double 0x3FF921FB54442D18)
  tail call void @___rp(i64 %qalloc.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___rp(i64 %qalloc.i755, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure10 = tail call i64 @___lazy_measure(i64 %qalloc.i755)
  tail call void @___qfree(i64 %qalloc.i755)
  %"10_013.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure, 1
  %"10_013.fca.2.insert" = insertvalue { i1, i64, i1 } %"10_013.fca.1.insert", i1 undef, 2
  %"11_014.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure10, 1
  %"11_014.fca.2.insert" = insertvalue { i1, i64, i1 } %"11_014.fca.1.insert", i1 undef, 2
  %0 = tail call ptr @heap_alloc(i64 48)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %1, align 1
  store { i1, i64, i1 } %"10_013.fca.2.insert", ptr %0, align 4
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store { i1, i64, i1 } %"11_014.fca.2.insert", ptr %2, align 4
  %3 = tail call ptr @heap_alloc(i64 64)
  %4 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %4, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(64) %3, i8 0, i64 64, i1 false)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 3
  store i64 %6, ptr %1, align 4
  %7 = icmp eq i64 %6, 0
  br i1 %7, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %__hugr__.__tk2_qalloc.104.exit
  %8 = tail call ptr @heap_alloc(i64 48)
  %9 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %9, align 1
  %10 = load { i1, i64, i1 }, ptr %0, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %10, 0
  br i1 %.fca.0.extract118.i, label %cond_468_case_1.i, label %cond_468_case_0.i

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_qalloc.104.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_468_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %10, 2
  br label %cond_exit_468.i

cond_468_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %10, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_468.i

cond_exit_468.i:                                  ; preds = %cond_468_case_1.i, %cond_468_case_0.i
  %"03.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_468_case_1.i ], [ undef, %cond_468_case_0.i ]
  %"03.sroa.6.0.i" = phi i1 [ undef, %cond_468_case_1.i ], [ %.fca.2.extract120.i, %cond_468_case_0.i ]
  %11 = load i64, ptr %4, align 4
  %12 = trunc i64 %11 to i1
  br i1 %12, label %panic.i.i, label %cond_465_case_1.i

panic.i.i:                                        ; preds = %cond_exit_468.i.1, %cond_exit_468.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_465_case_1.i:                                ; preds = %cond_exit_468.i
  %"16.fca.1.insert.i" = insertvalue { i1, i64, i1 } %10, i64 %"03.sroa.3.0.i", 1
  %"16.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i", i1 %"03.sroa.6.0.i", 2
  %13 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i", 1
  %.fca.2.0.extract.i = load i1, ptr %3, align 1
  store { i1, { i1, i64, i1 } } %13, ptr %3, align 4
  br i1 %.fca.2.0.extract.i, label %cond_469_case_1.i, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit"

cond_469_case_1.i:                                ; preds = %cond_465_case_1.i.1, %cond_465_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit": ; preds = %cond_465_case_1.i
  store { i1, i64, i1 } %"16.fca.2.insert.i", ptr %8, align 4
  %14 = load { i1, i64, i1 }, ptr %2, align 4
  %.fca.0.extract118.i.1 = extractvalue { i1, i64, i1 } %14, 0
  br i1 %.fca.0.extract118.i.1, label %cond_468_case_1.i.1, label %cond_468_case_0.i.1

cond_468_case_0.i.1:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit"
  %.fca.2.extract120.i.1 = extractvalue { i1, i64, i1 } %14, 2
  br label %cond_exit_468.i.1

cond_468_case_1.i.1:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit"
  %.fca.1.extract119.i.1 = extractvalue { i1, i64, i1 } %14, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i.1)
  br label %cond_exit_468.i.1

cond_exit_468.i.1:                                ; preds = %cond_468_case_0.i.1, %cond_468_case_1.i.1
  %"03.sroa.3.0.i.1" = phi i64 [ %.fca.1.extract119.i.1, %cond_468_case_1.i.1 ], [ undef, %cond_468_case_0.i.1 ]
  %"03.sroa.6.0.i.1" = phi i1 [ undef, %cond_468_case_1.i.1 ], [ %.fca.2.extract120.i.1, %cond_468_case_0.i.1 ]
  %15 = load i64, ptr %4, align 4
  %16 = and i64 %15, 2
  %.not = icmp eq i64 %16, 0
  br i1 %.not, label %cond_465_case_1.i.1, label %panic.i.i

cond_465_case_1.i.1:                              ; preds = %cond_exit_468.i.1
  %"16.fca.1.insert.i.1" = insertvalue { i1, i64, i1 } %14, i64 %"03.sroa.3.0.i.1", 1
  %"16.fca.2.insert.i.1" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i.1", i1 %"03.sroa.6.0.i.1", 2
  %17 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i.1", 1
  %18 = getelementptr i8, ptr %3, i64 32
  %.fca.2.0.extract.i.1 = load i1, ptr %18, align 1
  store { i1, { i1, i64, i1 } } %17, ptr %18, align 4
  br i1 %.fca.2.0.extract.i.1, label %cond_469_case_1.i, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit.1"

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit.1": ; preds = %cond_465_case_1.i.1
  %19 = getelementptr inbounds nuw i8, ptr %8, i64 24
  store { i1, i64, i1 } %"16.fca.2.insert.i.1", ptr %19, align 4
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %20 = load i64, ptr %4, align 4
  %21 = and i64 %20, 3
  store i64 %21, ptr %4, align 4
  %22 = icmp eq i64 %21, 0
  br i1 %22, label %__barray_check_none_borrowed.exit763, label %mask_block_err.i761

__barray_check_none_borrowed.exit763:             ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit.1"
  %23 = tail call ptr @heap_alloc(i64 48)
  %24 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %24, align 1
  %25 = load { i1, { i1, i64, i1 } }, ptr %3, align 4
  %26 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %25)
  %27 = extractvalue { { i1, i64, i1 } } %26, 0
  store { i1, i64, i1 } %27, ptr %23, align 4
  %28 = load { i1, { i1, i64, i1 } }, ptr %18, align 4
  %29 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %28)
  %30 = getelementptr inbounds nuw i8, ptr %23, i64 24
  %31 = extractvalue { { i1, i64, i1 } } %29, 0
  store { i1, i64, i1 } %31, ptr %30, align 4
  tail call void @heap_free(ptr nonnull %3)
  tail call void @heap_free(ptr nonnull %4)
  %32 = load i64, ptr %24, align 4
  %33 = trunc i64 %32 to i1
  br i1 %33, label %cond_exit_506, label %__barray_mask_borrow.exit

mask_block_err.i761:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit.1"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

mask_block_err.i767:                              ; preds = %cond_exit_506.1
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %__barray_check_none_borrowed.exit763
  %34 = or disjoint i64 %32, 1
  store i64 %34, ptr %24, align 4
  %35 = load { i1, i64, i1 }, ptr %23, align 4
  %.fca.0.extract605 = extractvalue { i1, i64, i1 } %35, 0
  br i1 %.fca.0.extract605, label %cond_374_case_1, label %cond_exit_506

cond_exit_506:                                    ; preds = %cond_374_case_1, %__barray_mask_borrow.exit, %__barray_check_none_borrowed.exit763
  %36 = load i64, ptr %24, align 4
  %37 = and i64 %36, 2
  %.not1010 = icmp eq i64 %37, 0
  br i1 %.not1010, label %__barray_mask_borrow.exit.1, label %cond_exit_506.1

__barray_mask_borrow.exit.1:                      ; preds = %cond_exit_506
  %38 = or disjoint i64 %36, 2
  store i64 %38, ptr %24, align 4
  %39 = getelementptr inbounds nuw i8, ptr %23, i64 24
  %40 = load { i1, i64, i1 }, ptr %39, align 4
  %.fca.0.extract605.1 = extractvalue { i1, i64, i1 } %40, 0
  br i1 %.fca.0.extract605.1, label %cond_374_case_1.1, label %cond_exit_506.1

cond_374_case_1.1:                                ; preds = %__barray_mask_borrow.exit.1
  %.fca.1.extract606.1 = extractvalue { i1, i64, i1 } %40, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract606.1)
  br label %cond_exit_506.1

cond_exit_506.1:                                  ; preds = %cond_374_case_1.1, %__barray_mask_borrow.exit.1, %cond_exit_506
  %41 = load i64, ptr %24, align 4
  %42 = or i64 %41, -4
  store i64 %42, ptr %24, align 4
  %43 = icmp eq i64 %42, -1
  br i1 %43, label %loop_out, label %mask_block_err.i767

loop_out:                                         ; preds = %cond_exit_506.1
  tail call void @heap_free(ptr nonnull %23)
  tail call void @heap_free(ptr nonnull %24)
  %44 = load i64, ptr %9, align 4
  %45 = and i64 %44, 3
  store i64 %45, ptr %9, align 4
  %46 = icmp eq i64 %45, 0
  br i1 %46, label %__barray_check_none_borrowed.exit774, label %mask_block_err.i772

__barray_check_none_borrowed.exit774:             ; preds = %loop_out
  %47 = tail call ptr @heap_alloc(i64 2)
  %48 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %48, align 1
  %49 = load { i1, i64, i1 }, ptr %8, align 4
  %50 = tail call { i1 } @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %49)
  %51 = extractvalue { i1 } %50, 0
  store i1 %51, ptr %47, align 1
  %52 = load { i1, i64, i1 }, ptr %19, align 4
  %53 = tail call { i1 } @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %52)
  %54 = getelementptr inbounds nuw i8, ptr %47, i64 1
  %55 = extractvalue { i1 } %53, 0
  store i1 %55, ptr %54, align 1
  tail call void @heap_free(ptr nonnull %8)
  tail call void @heap_free(ptr nonnull %9)
  %56 = load i64, ptr %48, align 4
  %57 = and i64 %56, 3
  store i64 %57, ptr %48, align 4
  %58 = icmp eq i64 %57, 0
  br i1 %58, label %__barray_check_none_borrowed.exit780, label %mask_block_err.i778

mask_block_err.i772:                              ; preds = %loop_out
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_374_case_1:                                  ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract606 = extractvalue { i1, i64, i1 } %35, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract606)
  br label %cond_exit_506

__barray_check_none_borrowed.exit780:             ; preds = %__barray_check_none_borrowed.exit774
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %59 = alloca [2 x i1], align 1
  store i1 false, ptr %59, align 1
  %.repack670 = getelementptr inbounds nuw i8, ptr %59, i64 1
  store i1 false, ptr %.repack670, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %47, ptr %arr_ptr, align 8
  store ptr %59, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_00.00F9F73D.0, i64 15, ptr nonnull %out_arr_alloca)
  %qalloc.i781 = call i64 @___qalloc()
  %not_max.not.not.i782 = icmp eq i64 %qalloc.i781, -1
  br i1 %not_max.not.not.i782, label %cond_149_case_0.i, label %__hugr__.__tk2_qalloc.145.exit

mask_block_err.i778:                              ; preds = %__barray_check_none_borrowed.exit774
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_149_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit780
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.145.exit:                   ; preds = %__barray_check_none_borrowed.exit780
  call void @___reset(i64 %qalloc.i781)
  %qalloc.i783 = call i64 @___qalloc()
  %not_max.not.not.i784 = icmp eq i64 %qalloc.i783, -1
  br i1 %not_max.not.not.i784, label %cond_163_case_0.i, label %__hugr__.__tk2_qalloc.159.exit

cond_163_case_0.i:                                ; preds = %__hugr__.__tk2_qalloc.145.exit
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.159.exit:                   ; preds = %__hugr__.__tk2_qalloc.145.exit
  call void @___reset(i64 %qalloc.i783)
  call void @___rp(i64 %qalloc.i783, double 0x400921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i783, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i781, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i781, i64 %qalloc.i783, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i783, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i783, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i781, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i781, double 0xBFF921FB54442D18)
  %lazy_measure103 = call i64 @___lazy_measure(i64 %qalloc.i781)
  call void @___qfree(i64 %qalloc.i781)
  call void @___rp(i64 %qalloc.i783, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure109 = call i64 @___lazy_measure(i64 %qalloc.i783)
  call void @___qfree(i64 %qalloc.i783)
  %"29_0112.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure103, 1
  %"29_0112.fca.2.insert" = insertvalue { i1, i64, i1 } %"29_0112.fca.1.insert", i1 undef, 2
  %"30_0113.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure109, 1
  %"30_0113.fca.2.insert" = insertvalue { i1, i64, i1 } %"30_0113.fca.1.insert", i1 undef, 2
  %60 = call ptr @heap_alloc(i64 48)
  %61 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %61, align 1
  store { i1, i64, i1 } %"29_0112.fca.2.insert", ptr %60, align 4
  %62 = getelementptr inbounds nuw i8, ptr %60, i64 24
  store { i1, i64, i1 } %"30_0113.fca.2.insert", ptr %62, align 4
  %63 = call ptr @heap_alloc(i64 64)
  %64 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %64, align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(64) %63, i8 0, i64 64, i1 false)
  %65 = load i64, ptr %61, align 4
  %66 = and i64 %65, 3
  store i64 %66, ptr %61, align 4
  %67 = icmp eq i64 %66, 0
  br i1 %67, label %__barray_check_none_borrowed.exit792, label %mask_block_err.i790

__barray_check_none_borrowed.exit792:             ; preds = %__hugr__.__tk2_qalloc.159.exit
  %68 = call ptr @heap_alloc(i64 48)
  %69 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %69, align 1
  %70 = load { i1, i64, i1 }, ptr %60, align 4
  %.fca.0.extract118.i793 = extractvalue { i1, i64, i1 } %70, 0
  br i1 %.fca.0.extract118.i793, label %cond_468_case_1.i809, label %cond_468_case_0.i794

mask_block_err.i790:                              ; preds = %__hugr__.__tk2_qalloc.159.exit
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_468_case_0.i794:                             ; preds = %__barray_check_none_borrowed.exit792
  %.fca.2.extract120.i795 = extractvalue { i1, i64, i1 } %70, 2
  br label %cond_exit_468.i796

cond_468_case_1.i809:                             ; preds = %__barray_check_none_borrowed.exit792
  %.fca.1.extract119.i810 = extractvalue { i1, i64, i1 } %70, 1
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i810)
  br label %cond_exit_468.i796

cond_exit_468.i796:                               ; preds = %cond_468_case_1.i809, %cond_468_case_0.i794
  %"03.sroa.3.0.i797" = phi i64 [ %.fca.1.extract119.i810, %cond_468_case_1.i809 ], [ undef, %cond_468_case_0.i794 ]
  %"03.sroa.6.0.i798" = phi i1 [ undef, %cond_468_case_1.i809 ], [ %.fca.2.extract120.i795, %cond_468_case_0.i794 ]
  %71 = load i64, ptr %64, align 4
  %72 = trunc i64 %71 to i1
  br i1 %72, label %panic.i.i808, label %cond_465_case_1.i800

panic.i.i808:                                     ; preds = %cond_exit_468.i796.1, %cond_exit_468.i796
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_465_case_1.i800:                             ; preds = %cond_exit_468.i796
  %"16.fca.1.insert.i801" = insertvalue { i1, i64, i1 } %70, i64 %"03.sroa.3.0.i797", 1
  %"16.fca.2.insert.i802" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i801", i1 %"03.sroa.6.0.i798", 2
  %73 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i802", 1
  %.fca.2.0.extract.i803 = load i1, ptr %63, align 1
  store { i1, { i1, i64, i1 } } %73, ptr %63, align 4
  br i1 %.fca.2.0.extract.i803, label %cond_469_case_1.i807, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit811"

cond_469_case_1.i807:                             ; preds = %cond_465_case_1.i800.1, %cond_465_case_1.i800
  call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit811": ; preds = %cond_465_case_1.i800
  store { i1, i64, i1 } %"16.fca.2.insert.i802", ptr %68, align 4
  %74 = load { i1, i64, i1 }, ptr %62, align 4
  %.fca.0.extract118.i793.1 = extractvalue { i1, i64, i1 } %74, 0
  br i1 %.fca.0.extract118.i793.1, label %cond_468_case_1.i809.1, label %cond_468_case_0.i794.1

cond_468_case_0.i794.1:                           ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit811"
  %.fca.2.extract120.i795.1 = extractvalue { i1, i64, i1 } %74, 2
  br label %cond_exit_468.i796.1

cond_468_case_1.i809.1:                           ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit811"
  %.fca.1.extract119.i810.1 = extractvalue { i1, i64, i1 } %74, 1
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i810.1)
  br label %cond_exit_468.i796.1

cond_exit_468.i796.1:                             ; preds = %cond_468_case_0.i794.1, %cond_468_case_1.i809.1
  %"03.sroa.3.0.i797.1" = phi i64 [ %.fca.1.extract119.i810.1, %cond_468_case_1.i809.1 ], [ undef, %cond_468_case_0.i794.1 ]
  %"03.sroa.6.0.i798.1" = phi i1 [ undef, %cond_468_case_1.i809.1 ], [ %.fca.2.extract120.i795.1, %cond_468_case_0.i794.1 ]
  %75 = load i64, ptr %64, align 4
  %76 = and i64 %75, 2
  %.not995 = icmp eq i64 %76, 0
  br i1 %.not995, label %cond_465_case_1.i800.1, label %panic.i.i808

cond_465_case_1.i800.1:                           ; preds = %cond_exit_468.i796.1
  %"16.fca.1.insert.i801.1" = insertvalue { i1, i64, i1 } %74, i64 %"03.sroa.3.0.i797.1", 1
  %"16.fca.2.insert.i802.1" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i801.1", i1 %"03.sroa.6.0.i798.1", 2
  %77 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i802.1", 1
  %78 = getelementptr i8, ptr %63, i64 32
  %.fca.2.0.extract.i803.1 = load i1, ptr %78, align 1
  store { i1, { i1, i64, i1 } } %77, ptr %78, align 4
  br i1 %.fca.2.0.extract.i803.1, label %cond_469_case_1.i807, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit811.1"

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit811.1": ; preds = %cond_465_case_1.i800.1
  %79 = getelementptr inbounds nuw i8, ptr %68, i64 24
  store { i1, i64, i1 } %"16.fca.2.insert.i802.1", ptr %79, align 4
  call void @heap_free(ptr nonnull %60)
  call void @heap_free(ptr nonnull %61)
  %80 = load i64, ptr %64, align 4
  %81 = and i64 %80, 3
  store i64 %81, ptr %64, align 4
  %82 = icmp eq i64 %81, 0
  br i1 %82, label %__barray_check_none_borrowed.exit820, label %mask_block_err.i818

__barray_check_none_borrowed.exit820:             ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit811.1"
  %83 = call ptr @heap_alloc(i64 48)
  %84 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %84, align 1
  %85 = load { i1, { i1, i64, i1 } }, ptr %63, align 4
  %86 = call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %85)
  %87 = extractvalue { { i1, i64, i1 } } %86, 0
  store { i1, i64, i1 } %87, ptr %83, align 4
  %88 = load { i1, { i1, i64, i1 } }, ptr %78, align 4
  %89 = call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %88)
  %90 = getelementptr inbounds nuw i8, ptr %83, i64 24
  %91 = extractvalue { { i1, i64, i1 } } %89, 0
  store { i1, i64, i1 } %91, ptr %90, align 4
  call void @heap_free(ptr nonnull %63)
  call void @heap_free(ptr nonnull %64)
  %92 = load i64, ptr %84, align 4
  %93 = trunc i64 %92 to i1
  br i1 %93, label %cond_exit_550, label %__barray_mask_borrow.exit828

mask_block_err.i818:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit811.1"
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

mask_block_err.i824:                              ; preds = %cond_exit_550.1
  call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit828:                     ; preds = %__barray_check_none_borrowed.exit820
  %94 = or disjoint i64 %92, 1
  store i64 %94, ptr %84, align 4
  %95 = load { i1, i64, i1 }, ptr %83, align 4
  %.fca.0.extract555 = extractvalue { i1, i64, i1 } %95, 0
  br i1 %.fca.0.extract555, label %cond_573_case_1, label %cond_exit_550

cond_exit_550:                                    ; preds = %cond_573_case_1, %__barray_mask_borrow.exit828, %__barray_check_none_borrowed.exit820
  %96 = load i64, ptr %84, align 4
  %97 = and i64 %96, 2
  %.not1011 = icmp eq i64 %97, 0
  br i1 %.not1011, label %__barray_mask_borrow.exit828.1, label %cond_exit_550.1

__barray_mask_borrow.exit828.1:                   ; preds = %cond_exit_550
  %98 = or disjoint i64 %96, 2
  store i64 %98, ptr %84, align 4
  %99 = getelementptr inbounds nuw i8, ptr %83, i64 24
  %100 = load { i1, i64, i1 }, ptr %99, align 4
  %.fca.0.extract555.1 = extractvalue { i1, i64, i1 } %100, 0
  br i1 %.fca.0.extract555.1, label %cond_573_case_1.1, label %cond_exit_550.1

cond_573_case_1.1:                                ; preds = %__barray_mask_borrow.exit828.1
  %.fca.1.extract556.1 = extractvalue { i1, i64, i1 } %100, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract556.1)
  br label %cond_exit_550.1

cond_exit_550.1:                                  ; preds = %cond_573_case_1.1, %__barray_mask_borrow.exit828.1, %cond_exit_550
  %101 = load i64, ptr %84, align 4
  %102 = or i64 %101, -4
  store i64 %102, ptr %84, align 4
  %103 = icmp eq i64 %102, -1
  br i1 %103, label %loop_out137, label %mask_block_err.i824

loop_out137:                                      ; preds = %cond_exit_550.1
  call void @heap_free(ptr nonnull %83)
  call void @heap_free(ptr nonnull %84)
  %104 = load i64, ptr %69, align 4
  %105 = and i64 %104, 3
  store i64 %105, ptr %69, align 4
  %106 = icmp eq i64 %105, 0
  br i1 %106, label %__barray_check_none_borrowed.exit834, label %mask_block_err.i832

__barray_check_none_borrowed.exit834:             ; preds = %loop_out137
  %107 = call ptr @heap_alloc(i64 2)
  %108 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %108, align 1
  %109 = load { i1, i64, i1 }, ptr %68, align 4
  %110 = call { i1 } @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %109)
  %111 = extractvalue { i1 } %110, 0
  store i1 %111, ptr %107, align 1
  %112 = load { i1, i64, i1 }, ptr %79, align 4
  %113 = call { i1 } @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %112)
  %114 = getelementptr inbounds nuw i8, ptr %107, i64 1
  %115 = extractvalue { i1 } %113, 0
  store i1 %115, ptr %114, align 1
  call void @heap_free(ptr nonnull %68)
  call void @heap_free(ptr nonnull %69)
  %116 = load i64, ptr %108, align 4
  %117 = and i64 %116, 3
  store i64 %117, ptr %108, align 4
  %118 = icmp eq i64 %117, 0
  br i1 %118, label %__barray_check_none_borrowed.exit840, label %mask_block_err.i838

mask_block_err.i832:                              ; preds = %loop_out137
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_573_case_1:                                  ; preds = %__barray_mask_borrow.exit828
  %.fca.1.extract556 = extractvalue { i1, i64, i1 } %95, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract556)
  br label %cond_exit_550

__barray_check_none_borrowed.exit840:             ; preds = %__barray_check_none_borrowed.exit834
  %out_arr_alloca205 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr207 = getelementptr inbounds nuw i8, ptr %out_arr_alloca205, i64 4
  %arr_ptr208 = getelementptr inbounds nuw i8, ptr %out_arr_alloca205, i64 8
  %mask_ptr209 = getelementptr inbounds nuw i8, ptr %out_arr_alloca205, i64 16
  %119 = alloca [2 x i1], align 1
  store i1 false, ptr %119, align 1
  %.repack684 = getelementptr inbounds nuw i8, ptr %119, i64 1
  store i1 false, ptr %.repack684, align 1
  store i32 2, ptr %out_arr_alloca205, align 8
  store i32 1, ptr %y_ptr207, align 4
  store ptr %107, ptr %arr_ptr208, align 8
  store ptr %119, ptr %mask_ptr209, align 8
  call void @print_bool_arr(ptr nonnull @res_01.2F21FB33.0, i64 15, ptr nonnull %out_arr_alloca205)
  %qalloc.i841 = call i64 @___qalloc()
  %not_max.not.not.i842 = icmp eq i64 %qalloc.i841, -1
  br i1 %not_max.not.not.i842, label %cond_212_case_0.i, label %__hugr__.__tk2_qalloc.208.exit

mask_block_err.i838:                              ; preds = %__barray_check_none_borrowed.exit834
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_212_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit840
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.208.exit:                   ; preds = %__barray_check_none_borrowed.exit840
  call void @___reset(i64 %qalloc.i841)
  call void @___rp(i64 %qalloc.i841, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i843 = call i64 @___qalloc()
  %not_max.not.not.i844 = icmp eq i64 %qalloc.i843, -1
  br i1 %not_max.not.not.i844, label %cond_226_case_0.i, label %__hugr__.__tk2_qalloc.222.exit

cond_226_case_0.i:                                ; preds = %__hugr__.__tk2_qalloc.208.exit
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.222.exit:                   ; preds = %__hugr__.__tk2_qalloc.208.exit
  call void @___reset(i64 %qalloc.i843)
  call void @___rz(i64 %qalloc.i843, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i841, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i841, i64 %qalloc.i843, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i843, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i843, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i841, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i841, double 0xBFF921FB54442D18)
  %lazy_measure215 = call i64 @___lazy_measure(i64 %qalloc.i841)
  call void @___qfree(i64 %qalloc.i841)
  call void @___rp(i64 %qalloc.i843, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure221 = call i64 @___lazy_measure(i64 %qalloc.i843)
  call void @___qfree(i64 %qalloc.i843)
  %"48_0224.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure215, 1
  %"48_0224.fca.2.insert" = insertvalue { i1, i64, i1 } %"48_0224.fca.1.insert", i1 undef, 2
  %"49_0225.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure221, 1
  %"49_0225.fca.2.insert" = insertvalue { i1, i64, i1 } %"49_0225.fca.1.insert", i1 undef, 2
  %120 = call ptr @heap_alloc(i64 48)
  %121 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %121, align 1
  store { i1, i64, i1 } %"48_0224.fca.2.insert", ptr %120, align 4
  %122 = getelementptr inbounds nuw i8, ptr %120, i64 24
  store { i1, i64, i1 } %"49_0225.fca.2.insert", ptr %122, align 4
  %123 = call ptr @heap_alloc(i64 64)
  %124 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %124, align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(64) %123, i8 0, i64 64, i1 false)
  %125 = load i64, ptr %121, align 4
  %126 = and i64 %125, 3
  store i64 %126, ptr %121, align 4
  %127 = icmp eq i64 %126, 0
  br i1 %127, label %__barray_check_none_borrowed.exit852, label %mask_block_err.i850

__barray_check_none_borrowed.exit852:             ; preds = %__hugr__.__tk2_qalloc.222.exit
  %128 = call ptr @heap_alloc(i64 48)
  %129 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %129, align 1
  %130 = load { i1, i64, i1 }, ptr %120, align 4
  %.fca.0.extract118.i853 = extractvalue { i1, i64, i1 } %130, 0
  br i1 %.fca.0.extract118.i853, label %cond_468_case_1.i869, label %cond_468_case_0.i854

mask_block_err.i850:                              ; preds = %__hugr__.__tk2_qalloc.222.exit
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_468_case_0.i854:                             ; preds = %__barray_check_none_borrowed.exit852
  %.fca.2.extract120.i855 = extractvalue { i1, i64, i1 } %130, 2
  br label %cond_exit_468.i856

cond_468_case_1.i869:                             ; preds = %__barray_check_none_borrowed.exit852
  %.fca.1.extract119.i870 = extractvalue { i1, i64, i1 } %130, 1
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i870)
  br label %cond_exit_468.i856

cond_exit_468.i856:                               ; preds = %cond_468_case_1.i869, %cond_468_case_0.i854
  %"03.sroa.3.0.i857" = phi i64 [ %.fca.1.extract119.i870, %cond_468_case_1.i869 ], [ undef, %cond_468_case_0.i854 ]
  %"03.sroa.6.0.i858" = phi i1 [ undef, %cond_468_case_1.i869 ], [ %.fca.2.extract120.i855, %cond_468_case_0.i854 ]
  %131 = load i64, ptr %124, align 4
  %132 = trunc i64 %131 to i1
  br i1 %132, label %panic.i.i868, label %cond_465_case_1.i860

panic.i.i868:                                     ; preds = %cond_exit_468.i856.1, %cond_exit_468.i856
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_465_case_1.i860:                             ; preds = %cond_exit_468.i856
  %"16.fca.1.insert.i861" = insertvalue { i1, i64, i1 } %130, i64 %"03.sroa.3.0.i857", 1
  %"16.fca.2.insert.i862" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i861", i1 %"03.sroa.6.0.i858", 2
  %133 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i862", 1
  %.fca.2.0.extract.i863 = load i1, ptr %123, align 1
  store { i1, { i1, i64, i1 } } %133, ptr %123, align 4
  br i1 %.fca.2.0.extract.i863, label %cond_469_case_1.i867, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit871"

cond_469_case_1.i867:                             ; preds = %cond_465_case_1.i860.1, %cond_465_case_1.i860
  call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit871": ; preds = %cond_465_case_1.i860
  store { i1, i64, i1 } %"16.fca.2.insert.i862", ptr %128, align 4
  %134 = load { i1, i64, i1 }, ptr %122, align 4
  %.fca.0.extract118.i853.1 = extractvalue { i1, i64, i1 } %134, 0
  br i1 %.fca.0.extract118.i853.1, label %cond_468_case_1.i869.1, label %cond_468_case_0.i854.1

cond_468_case_0.i854.1:                           ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit871"
  %.fca.2.extract120.i855.1 = extractvalue { i1, i64, i1 } %134, 2
  br label %cond_exit_468.i856.1

cond_468_case_1.i869.1:                           ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit871"
  %.fca.1.extract119.i870.1 = extractvalue { i1, i64, i1 } %134, 1
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i870.1)
  br label %cond_exit_468.i856.1

cond_exit_468.i856.1:                             ; preds = %cond_468_case_0.i854.1, %cond_468_case_1.i869.1
  %"03.sroa.3.0.i857.1" = phi i64 [ %.fca.1.extract119.i870.1, %cond_468_case_1.i869.1 ], [ undef, %cond_468_case_0.i854.1 ]
  %"03.sroa.6.0.i858.1" = phi i1 [ undef, %cond_468_case_1.i869.1 ], [ %.fca.2.extract120.i855.1, %cond_468_case_0.i854.1 ]
  %135 = load i64, ptr %124, align 4
  %136 = and i64 %135, 2
  %.not996 = icmp eq i64 %136, 0
  br i1 %.not996, label %cond_465_case_1.i860.1, label %panic.i.i868

cond_465_case_1.i860.1:                           ; preds = %cond_exit_468.i856.1
  %"16.fca.1.insert.i861.1" = insertvalue { i1, i64, i1 } %134, i64 %"03.sroa.3.0.i857.1", 1
  %"16.fca.2.insert.i862.1" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i861.1", i1 %"03.sroa.6.0.i858.1", 2
  %137 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i862.1", 1
  %138 = getelementptr i8, ptr %123, i64 32
  %.fca.2.0.extract.i863.1 = load i1, ptr %138, align 1
  store { i1, { i1, i64, i1 } } %137, ptr %138, align 4
  br i1 %.fca.2.0.extract.i863.1, label %cond_469_case_1.i867, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit871.1"

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit871.1": ; preds = %cond_465_case_1.i860.1
  %139 = getelementptr inbounds nuw i8, ptr %128, i64 24
  store { i1, i64, i1 } %"16.fca.2.insert.i862.1", ptr %139, align 4
  call void @heap_free(ptr nonnull %120)
  call void @heap_free(ptr nonnull %121)
  %140 = load i64, ptr %124, align 4
  %141 = and i64 %140, 3
  store i64 %141, ptr %124, align 4
  %142 = icmp eq i64 %141, 0
  br i1 %142, label %__barray_check_none_borrowed.exit880, label %mask_block_err.i878

__barray_check_none_borrowed.exit880:             ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit871.1"
  %143 = call ptr @heap_alloc(i64 48)
  %144 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %144, align 1
  %145 = load { i1, { i1, i64, i1 } }, ptr %123, align 4
  %146 = call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %145)
  %147 = extractvalue { { i1, i64, i1 } } %146, 0
  store { i1, i64, i1 } %147, ptr %143, align 4
  %148 = load { i1, { i1, i64, i1 } }, ptr %138, align 4
  %149 = call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %148)
  %150 = getelementptr inbounds nuw i8, ptr %143, i64 24
  %151 = extractvalue { { i1, i64, i1 } } %149, 0
  store { i1, i64, i1 } %151, ptr %150, align 4
  call void @heap_free(ptr nonnull %123)
  call void @heap_free(ptr nonnull %124)
  %152 = load i64, ptr %144, align 4
  %153 = trunc i64 %152 to i1
  br i1 %153, label %cond_exit_596, label %__barray_mask_borrow.exit888

mask_block_err.i878:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit871.1"
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

mask_block_err.i884:                              ; preds = %cond_exit_596.1
  call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit888:                     ; preds = %__barray_check_none_borrowed.exit880
  %154 = or disjoint i64 %152, 1
  store i64 %154, ptr %144, align 4
  %155 = load { i1, i64, i1 }, ptr %143, align 4
  %.fca.0.extract505 = extractvalue { i1, i64, i1 } %155, 0
  br i1 %.fca.0.extract505, label %cond_619_case_1, label %cond_exit_596

cond_exit_596:                                    ; preds = %cond_619_case_1, %__barray_mask_borrow.exit888, %__barray_check_none_borrowed.exit880
  %156 = load i64, ptr %144, align 4
  %157 = and i64 %156, 2
  %.not1012 = icmp eq i64 %157, 0
  br i1 %.not1012, label %__barray_mask_borrow.exit888.1, label %cond_exit_596.1

__barray_mask_borrow.exit888.1:                   ; preds = %cond_exit_596
  %158 = or disjoint i64 %156, 2
  store i64 %158, ptr %144, align 4
  %159 = getelementptr inbounds nuw i8, ptr %143, i64 24
  %160 = load { i1, i64, i1 }, ptr %159, align 4
  %.fca.0.extract505.1 = extractvalue { i1, i64, i1 } %160, 0
  br i1 %.fca.0.extract505.1, label %cond_619_case_1.1, label %cond_exit_596.1

cond_619_case_1.1:                                ; preds = %__barray_mask_borrow.exit888.1
  %.fca.1.extract506.1 = extractvalue { i1, i64, i1 } %160, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract506.1)
  br label %cond_exit_596.1

cond_exit_596.1:                                  ; preds = %cond_619_case_1.1, %__barray_mask_borrow.exit888.1, %cond_exit_596
  %161 = load i64, ptr %144, align 4
  %162 = or i64 %161, -4
  store i64 %162, ptr %144, align 4
  %163 = icmp eq i64 %162, -1
  br i1 %163, label %loop_out249, label %mask_block_err.i884

loop_out249:                                      ; preds = %cond_exit_596.1
  call void @heap_free(ptr nonnull %143)
  call void @heap_free(ptr nonnull %144)
  %164 = load i64, ptr %129, align 4
  %165 = and i64 %164, 3
  store i64 %165, ptr %129, align 4
  %166 = icmp eq i64 %165, 0
  br i1 %166, label %__barray_check_none_borrowed.exit894, label %mask_block_err.i892

__barray_check_none_borrowed.exit894:             ; preds = %loop_out249
  %167 = call ptr @heap_alloc(i64 2)
  %168 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %168, align 1
  %169 = load { i1, i64, i1 }, ptr %128, align 4
  %170 = call { i1 } @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %169)
  %171 = extractvalue { i1 } %170, 0
  store i1 %171, ptr %167, align 1
  %172 = load { i1, i64, i1 }, ptr %139, align 4
  %173 = call { i1 } @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %172)
  %174 = getelementptr inbounds nuw i8, ptr %167, i64 1
  %175 = extractvalue { i1 } %173, 0
  store i1 %175, ptr %174, align 1
  call void @heap_free(ptr nonnull %128)
  call void @heap_free(ptr nonnull %129)
  %176 = load i64, ptr %168, align 4
  %177 = and i64 %176, 3
  store i64 %177, ptr %168, align 4
  %178 = icmp eq i64 %177, 0
  br i1 %178, label %__barray_check_none_borrowed.exit900, label %mask_block_err.i898

mask_block_err.i892:                              ; preds = %loop_out249
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_619_case_1:                                  ; preds = %__barray_mask_borrow.exit888
  %.fca.1.extract506 = extractvalue { i1, i64, i1 } %155, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract506)
  br label %cond_exit_596

__barray_check_none_borrowed.exit900:             ; preds = %__barray_check_none_borrowed.exit894
  %out_arr_alloca317 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr319 = getelementptr inbounds nuw i8, ptr %out_arr_alloca317, i64 4
  %arr_ptr320 = getelementptr inbounds nuw i8, ptr %out_arr_alloca317, i64 8
  %mask_ptr321 = getelementptr inbounds nuw i8, ptr %out_arr_alloca317, i64 16
  %179 = alloca [2 x i1], align 1
  store i1 false, ptr %179, align 1
  %.repack698 = getelementptr inbounds nuw i8, ptr %179, i64 1
  store i1 false, ptr %.repack698, align 1
  store i32 2, ptr %out_arr_alloca317, align 8
  store i32 1, ptr %y_ptr319, align 4
  store ptr %167, ptr %arr_ptr320, align 8
  store ptr %179, ptr %mask_ptr321, align 8
  call void @print_bool_arr(ptr nonnull @res_10.90CD55C3.0, i64 15, ptr nonnull %out_arr_alloca317)
  %qalloc.i901 = call i64 @___qalloc()
  %not_max.not.not.i902 = icmp eq i64 %qalloc.i901, -1
  br i1 %not_max.not.not.i902, label %cond_275_case_0.i, label %__hugr__.__tk2_qalloc.271.exit

mask_block_err.i898:                              ; preds = %__barray_check_none_borrowed.exit894
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_275_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit900
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.271.exit:                   ; preds = %__barray_check_none_borrowed.exit900
  call void @___reset(i64 %qalloc.i901)
  call void @___rp(i64 %qalloc.i901, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i903 = call i64 @___qalloc()
  %not_max.not.not.i904 = icmp eq i64 %qalloc.i903, -1
  br i1 %not_max.not.not.i904, label %cond_289_case_0.i, label %__hugr__.__tk2_qalloc.285.exit

cond_289_case_0.i:                                ; preds = %__hugr__.__tk2_qalloc.271.exit
  call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.285.exit:                   ; preds = %__hugr__.__tk2_qalloc.271.exit
  call void @___reset(i64 %qalloc.i903)
  call void @___rp(i64 %qalloc.i903, double 0x400921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i903, double 0xBFF921FB54442D18)
  call void @___rp(i64 %qalloc.i901, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rpp(i64 %qalloc.i901, i64 %qalloc.i903, double 0x3FF921FB54442D18, double 0.000000e+00)
  call void @___rp(i64 %qalloc.i903, double 0xBFF921FB54442D18, double 0.000000e+00)
  call void @___rz(i64 %qalloc.i903, double 0x3FF921FB54442D18)
  call void @___rp(i64 %qalloc.i901, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %qalloc.i901, double 0xBFF921FB54442D18)
  %lazy_measure328 = call i64 @___lazy_measure(i64 %qalloc.i901)
  call void @___qfree(i64 %qalloc.i901)
  call void @___rp(i64 %qalloc.i903, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure334 = call i64 @___lazy_measure(i64 %qalloc.i903)
  call void @___qfree(i64 %qalloc.i903)
  %"69_0337.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure328, 1
  %"69_0337.fca.2.insert" = insertvalue { i1, i64, i1 } %"69_0337.fca.1.insert", i1 undef, 2
  %"70_0338.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure334, 1
  %"70_0338.fca.2.insert" = insertvalue { i1, i64, i1 } %"70_0338.fca.1.insert", i1 undef, 2
  %180 = call ptr @heap_alloc(i64 48)
  %181 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %181, align 1
  store { i1, i64, i1 } %"69_0337.fca.2.insert", ptr %180, align 4
  %182 = getelementptr inbounds nuw i8, ptr %180, i64 24
  store { i1, i64, i1 } %"70_0338.fca.2.insert", ptr %182, align 4
  %183 = call ptr @heap_alloc(i64 64)
  %184 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %184, align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(64) %183, i8 0, i64 64, i1 false)
  %185 = load i64, ptr %181, align 4
  %186 = and i64 %185, 3
  store i64 %186, ptr %181, align 4
  %187 = icmp eq i64 %186, 0
  br i1 %187, label %__barray_check_none_borrowed.exit912, label %mask_block_err.i910

__barray_check_none_borrowed.exit912:             ; preds = %__hugr__.__tk2_qalloc.285.exit
  %188 = call ptr @heap_alloc(i64 48)
  %189 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %189, align 1
  %190 = load { i1, i64, i1 }, ptr %180, align 4
  %.fca.0.extract118.i913 = extractvalue { i1, i64, i1 } %190, 0
  br i1 %.fca.0.extract118.i913, label %cond_468_case_1.i929, label %cond_468_case_0.i914

mask_block_err.i910:                              ; preds = %__hugr__.__tk2_qalloc.285.exit
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_468_case_0.i914:                             ; preds = %__barray_check_none_borrowed.exit912
  %.fca.2.extract120.i915 = extractvalue { i1, i64, i1 } %190, 2
  br label %cond_exit_468.i916

cond_468_case_1.i929:                             ; preds = %__barray_check_none_borrowed.exit912
  %.fca.1.extract119.i930 = extractvalue { i1, i64, i1 } %190, 1
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i930)
  br label %cond_exit_468.i916

cond_exit_468.i916:                               ; preds = %cond_468_case_1.i929, %cond_468_case_0.i914
  %"03.sroa.3.0.i917" = phi i64 [ %.fca.1.extract119.i930, %cond_468_case_1.i929 ], [ undef, %cond_468_case_0.i914 ]
  %"03.sroa.6.0.i918" = phi i1 [ undef, %cond_468_case_1.i929 ], [ %.fca.2.extract120.i915, %cond_468_case_0.i914 ]
  %191 = load i64, ptr %184, align 4
  %192 = trunc i64 %191 to i1
  br i1 %192, label %panic.i.i928, label %cond_465_case_1.i920

panic.i.i928:                                     ; preds = %cond_exit_468.i916.1, %cond_exit_468.i916
  call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_465_case_1.i920:                             ; preds = %cond_exit_468.i916
  %"16.fca.1.insert.i921" = insertvalue { i1, i64, i1 } %190, i64 %"03.sroa.3.0.i917", 1
  %"16.fca.2.insert.i922" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i921", i1 %"03.sroa.6.0.i918", 2
  %193 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i922", 1
  %.fca.2.0.extract.i923 = load i1, ptr %183, align 1
  store { i1, { i1, i64, i1 } } %193, ptr %183, align 4
  br i1 %.fca.2.0.extract.i923, label %cond_469_case_1.i927, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit931"

cond_469_case_1.i927:                             ; preds = %cond_465_case_1.i920.1, %cond_465_case_1.i920
  call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit931": ; preds = %cond_465_case_1.i920
  store { i1, i64, i1 } %"16.fca.2.insert.i922", ptr %188, align 4
  %194 = load { i1, i64, i1 }, ptr %182, align 4
  %.fca.0.extract118.i913.1 = extractvalue { i1, i64, i1 } %194, 0
  br i1 %.fca.0.extract118.i913.1, label %cond_468_case_1.i929.1, label %cond_468_case_0.i914.1

cond_468_case_0.i914.1:                           ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit931"
  %.fca.2.extract120.i915.1 = extractvalue { i1, i64, i1 } %194, 2
  br label %cond_exit_468.i916.1

cond_468_case_1.i929.1:                           ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit931"
  %.fca.1.extract119.i930.1 = extractvalue { i1, i64, i1 } %194, 1
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i930.1)
  br label %cond_exit_468.i916.1

cond_exit_468.i916.1:                             ; preds = %cond_468_case_0.i914.1, %cond_468_case_1.i929.1
  %"03.sroa.3.0.i917.1" = phi i64 [ %.fca.1.extract119.i930.1, %cond_468_case_1.i929.1 ], [ undef, %cond_468_case_0.i914.1 ]
  %"03.sroa.6.0.i918.1" = phi i1 [ undef, %cond_468_case_1.i929.1 ], [ %.fca.2.extract120.i915.1, %cond_468_case_0.i914.1 ]
  %195 = load i64, ptr %184, align 4
  %196 = and i64 %195, 2
  %.not997 = icmp eq i64 %196, 0
  br i1 %.not997, label %cond_465_case_1.i920.1, label %panic.i.i928

cond_465_case_1.i920.1:                           ; preds = %cond_exit_468.i916.1
  %"16.fca.1.insert.i921.1" = insertvalue { i1, i64, i1 } %194, i64 %"03.sroa.3.0.i917.1", 1
  %"16.fca.2.insert.i922.1" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i921.1", i1 %"03.sroa.6.0.i918.1", 2
  %197 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i922.1", 1
  %198 = getelementptr i8, ptr %183, i64 32
  %.fca.2.0.extract.i923.1 = load i1, ptr %198, align 1
  store { i1, { i1, i64, i1 } } %197, ptr %198, align 4
  br i1 %.fca.2.0.extract.i923.1, label %cond_469_case_1.i927, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit931.1"

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit931.1": ; preds = %cond_465_case_1.i920.1
  %199 = getelementptr inbounds nuw i8, ptr %188, i64 24
  store { i1, i64, i1 } %"16.fca.2.insert.i922.1", ptr %199, align 4
  call void @heap_free(ptr nonnull %180)
  call void @heap_free(ptr nonnull %181)
  %200 = load i64, ptr %184, align 4
  %201 = and i64 %200, 3
  store i64 %201, ptr %184, align 4
  %202 = icmp eq i64 %201, 0
  br i1 %202, label %__barray_check_none_borrowed.exit940, label %mask_block_err.i938

__barray_check_none_borrowed.exit940:             ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit931.1"
  %203 = call ptr @heap_alloc(i64 48)
  %204 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %204, align 1
  %205 = load { i1, { i1, i64, i1 } }, ptr %183, align 4
  %206 = call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %205)
  %207 = extractvalue { { i1, i64, i1 } } %206, 0
  store { i1, i64, i1 } %207, ptr %203, align 4
  %208 = load { i1, { i1, i64, i1 } }, ptr %198, align 4
  %209 = call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %208)
  %210 = getelementptr inbounds nuw i8, ptr %203, i64 24
  %211 = extractvalue { { i1, i64, i1 } } %209, 0
  store { i1, i64, i1 } %211, ptr %210, align 4
  call void @heap_free(ptr nonnull %183)
  call void @heap_free(ptr nonnull %184)
  %212 = load i64, ptr %204, align 4
  %213 = trunc i64 %212 to i1
  br i1 %213, label %cond_exit_642, label %__barray_mask_borrow.exit948

mask_block_err.i938:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).473.exit931.1"
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

mask_block_err.i944:                              ; preds = %cond_exit_642.1
  call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit948:                     ; preds = %__barray_check_none_borrowed.exit940
  %214 = or disjoint i64 %212, 1
  store i64 %214, ptr %204, align 4
  %215 = load { i1, i64, i1 }, ptr %203, align 4
  %.fca.0.extract455 = extractvalue { i1, i64, i1 } %215, 0
  br i1 %.fca.0.extract455, label %cond_665_case_1, label %cond_exit_642

cond_exit_642:                                    ; preds = %cond_665_case_1, %__barray_mask_borrow.exit948, %__barray_check_none_borrowed.exit940
  %216 = load i64, ptr %204, align 4
  %217 = and i64 %216, 2
  %.not1013 = icmp eq i64 %217, 0
  br i1 %.not1013, label %__barray_mask_borrow.exit948.1, label %cond_exit_642.1

__barray_mask_borrow.exit948.1:                   ; preds = %cond_exit_642
  %218 = or disjoint i64 %216, 2
  store i64 %218, ptr %204, align 4
  %219 = getelementptr inbounds nuw i8, ptr %203, i64 24
  %220 = load { i1, i64, i1 }, ptr %219, align 4
  %.fca.0.extract455.1 = extractvalue { i1, i64, i1 } %220, 0
  br i1 %.fca.0.extract455.1, label %cond_665_case_1.1, label %cond_exit_642.1

cond_665_case_1.1:                                ; preds = %__barray_mask_borrow.exit948.1
  %.fca.1.extract456.1 = extractvalue { i1, i64, i1 } %220, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract456.1)
  br label %cond_exit_642.1

cond_exit_642.1:                                  ; preds = %cond_665_case_1.1, %__barray_mask_borrow.exit948.1, %cond_exit_642
  %221 = load i64, ptr %204, align 4
  %222 = or i64 %221, -4
  store i64 %222, ptr %204, align 4
  %223 = icmp eq i64 %222, -1
  br i1 %223, label %loop_out362, label %mask_block_err.i944

loop_out362:                                      ; preds = %cond_exit_642.1
  call void @heap_free(ptr nonnull %203)
  call void @heap_free(ptr nonnull %204)
  %224 = load i64, ptr %189, align 4
  %225 = and i64 %224, 3
  store i64 %225, ptr %189, align 4
  %226 = icmp eq i64 %225, 0
  br i1 %226, label %__barray_check_none_borrowed.exit954, label %mask_block_err.i952

__barray_check_none_borrowed.exit954:             ; preds = %loop_out362
  %227 = call ptr @heap_alloc(i64 2)
  %228 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %228, align 1
  %229 = load { i1, i64, i1 }, ptr %188, align 4
  %230 = call { i1 } @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %229)
  %231 = extractvalue { i1 } %230, 0
  store i1 %231, ptr %227, align 1
  %232 = load { i1, i64, i1 }, ptr %199, align 4
  %233 = call { i1 } @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %232)
  %234 = getelementptr inbounds nuw i8, ptr %227, i64 1
  %235 = extractvalue { i1 } %233, 0
  store i1 %235, ptr %234, align 1
  call void @heap_free(ptr nonnull %188)
  call void @heap_free(ptr nonnull %189)
  %236 = load i64, ptr %228, align 4
  %237 = and i64 %236, 3
  store i64 %237, ptr %228, align 4
  %238 = icmp eq i64 %237, 0
  br i1 %238, label %__barray_check_none_borrowed.exit960, label %mask_block_err.i958

mask_block_err.i952:                              ; preds = %loop_out362
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_665_case_1:                                  ; preds = %__barray_mask_borrow.exit948
  %.fca.1.extract456 = extractvalue { i1, i64, i1 } %215, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract456)
  br label %cond_exit_642

__barray_check_none_borrowed.exit960:             ; preds = %__barray_check_none_borrowed.exit954
  %out_arr_alloca430 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr432 = getelementptr inbounds nuw i8, ptr %out_arr_alloca430, i64 4
  %arr_ptr433 = getelementptr inbounds nuw i8, ptr %out_arr_alloca430, i64 8
  %mask_ptr434 = getelementptr inbounds nuw i8, ptr %out_arr_alloca430, i64 16
  %239 = alloca [2 x i1], align 1
  store i1 false, ptr %239, align 1
  %.repack712 = getelementptr inbounds nuw i8, ptr %239, i64 1
  store i1 false, ptr %.repack712, align 1
  store i32 2, ptr %out_arr_alloca430, align 8
  store i32 1, ptr %y_ptr432, align 4
  store ptr %227, ptr %arr_ptr433, align 8
  store ptr %239, ptr %mask_ptr434, align 8
  call void @print_bool_arr(ptr nonnull @res_11.7D0DF573.0, i64 15, ptr nonnull %out_arr_alloca430)
  ret void

mask_block_err.i958:                              ; preds = %__barray_check_none_borrowed.exit954
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
}

define internal i1 @__hugr__.array.__read_bool.3.85({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_394_case_1, label %cond_394_case_0

cond_394_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_394

cond_394_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_394

cond_exit_394:                                    ; preds = %cond_394_case_1, %cond_394_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_394_case_1 ], [ %.fca.2.extract, %cond_394_case_0 ]
  ret i1 %"03.0"
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

define internal { i1, i64, i1 } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).531"({ i1, { i1, i64, i1 } } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract11 = extractvalue { i1, { i1, i64, i1 } } %0, 0
  br i1 %.fca.0.extract11, label %cond_534_case_1, label %cond_534_case_0

cond_534_case_1:                                  ; preds = %alloca_block
  %1 = extractvalue { i1, { i1, i64, i1 } } %0, 1
  ret { i1, i64, i1 } %1

cond_534_case_0:                                  ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.E6312129.0")
  unreachable
}

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare void @heap_free(ptr) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rpp(i64, i64, double, double) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @__hugr__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #1 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
