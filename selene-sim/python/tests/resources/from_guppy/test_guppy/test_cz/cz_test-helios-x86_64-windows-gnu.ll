; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_c.19197FA6.0 = private constant [15 x i8] c"\0EUSER:BOOLARR:c"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define internal fastcc void @__hugr__.__main__.main.1() unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_55_case_0.i, label %__hugr__.__tk2_qalloc.51.exit

cond_55_case_0.i:                                 ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.51.exit:                    ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %qalloc.i177 = tail call i64 @___qalloc()
  %not_max.not.not.i178 = icmp eq i64 %qalloc.i177, -1
  br i1 %not_max.not.not.i178, label %cond_69_case_0.i, label %__hugr__.__tk2_qalloc.65.exit

cond_69_case_0.i:                                 ; preds = %__hugr__.__tk2_qalloc.51.exit
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.65.exit:                    ; preds = %__hugr__.__tk2_qalloc.51.exit
  tail call void @___reset(i64 %qalloc.i177)
  tail call void @___rxy(i64 %qalloc.i, double 0x40316444CB580C0B, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %qalloc.i, i64 %qalloc.i177, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i177, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %qalloc.i, double 0x40316444CB580C0B, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %qalloc.i, i64 %qalloc.i177, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i177, double 0xBFF921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  %lazy_measure14 = tail call i64 @___lazy_measure(i64 %qalloc.i177)
  tail call void @___qfree(i64 %qalloc.i177)
  %"16_017.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure, 1
  %"16_017.fca.2.insert" = insertvalue { i1, i64, i1 } %"16_017.fca.1.insert", i1 undef, 2
  %"17_018.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure14, 1
  %"17_018.fca.2.insert" = insertvalue { i1, i64, i1 } %"17_018.fca.1.insert", i1 undef, 2
  %0 = tail call ptr @heap_alloc(i64 48)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %1, align 1
  store { i1, i64, i1 } %"16_017.fca.2.insert", ptr %0, align 4
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store { i1, i64, i1 } %"17_018.fca.2.insert", ptr %2, align 4
  %3 = tail call ptr @heap_alloc(i64 64)
  %4 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %4, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(64) %3, i8 0, i64 64, i1 false)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 3
  store i64 %6, ptr %1, align 4
  %7 = icmp eq i64 %6, 0
  br i1 %7, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %__hugr__.__tk2_qalloc.65.exit
  %8 = tail call ptr @heap_alloc(i64 48)
  %9 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %9, align 1
  %10 = load { i1, i64, i1 }, ptr %0, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %10, 0
  br i1 %.fca.0.extract118.i, label %cond_137_case_1.i, label %cond_137_case_0.i

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_qalloc.65.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_137_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %10, 2
  br label %cond_exit_137.i

cond_137_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %10, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_137.i

cond_exit_137.i:                                  ; preds = %cond_137_case_1.i, %cond_137_case_0.i
  %"04.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_137_case_1.i ], [ undef, %cond_137_case_0.i ]
  %"04.sroa.6.0.i" = phi i1 [ undef, %cond_137_case_1.i ], [ %.fca.2.extract120.i, %cond_137_case_0.i ]
  %11 = load i64, ptr %4, align 4
  %12 = trunc i64 %11 to i1
  br i1 %12, label %panic.i.i, label %cond_140_case_1.i

panic.i.i:                                        ; preds = %cond_exit_137.i.1, %cond_exit_137.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_140_case_1.i:                                ; preds = %cond_exit_137.i
  %"17.fca.1.insert.i" = insertvalue { i1, i64, i1 } %10, i64 %"04.sroa.3.0.i", 1
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"17.fca.1.insert.i", i1 %"04.sroa.6.0.i", 2
  %13 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %.fca.2.0.extract.i = load i1, ptr %3, align 1
  store { i1, { i1, i64, i1 } } %13, ptr %3, align 4
  br i1 %.fca.2.0.extract.i, label %cond_141_case_1.i, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).133.exit"

cond_141_case_1.i:                                ; preds = %cond_140_case_1.i.1, %cond_140_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).133.exit": ; preds = %cond_140_case_1.i
  store { i1, i64, i1 } %"17.fca.2.insert.i", ptr %8, align 4
  %14 = load { i1, i64, i1 }, ptr %2, align 4
  %.fca.0.extract118.i.1 = extractvalue { i1, i64, i1 } %14, 0
  br i1 %.fca.0.extract118.i.1, label %cond_137_case_1.i.1, label %cond_137_case_0.i.1

cond_137_case_0.i.1:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).133.exit"
  %.fca.2.extract120.i.1 = extractvalue { i1, i64, i1 } %14, 2
  br label %cond_exit_137.i.1

cond_137_case_1.i.1:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).133.exit"
  %.fca.1.extract119.i.1 = extractvalue { i1, i64, i1 } %14, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i.1)
  br label %cond_exit_137.i.1

cond_exit_137.i.1:                                ; preds = %cond_137_case_0.i.1, %cond_137_case_1.i.1
  %"04.sroa.3.0.i.1" = phi i64 [ %.fca.1.extract119.i.1, %cond_137_case_1.i.1 ], [ undef, %cond_137_case_0.i.1 ]
  %"04.sroa.6.0.i.1" = phi i1 [ undef, %cond_137_case_1.i.1 ], [ %.fca.2.extract120.i.1, %cond_137_case_0.i.1 ]
  %15 = load i64, ptr %4, align 4
  %16 = and i64 %15, 2
  %.not = icmp eq i64 %16, 0
  br i1 %.not, label %cond_140_case_1.i.1, label %panic.i.i

cond_140_case_1.i.1:                              ; preds = %cond_exit_137.i.1
  %"17.fca.1.insert.i.1" = insertvalue { i1, i64, i1 } %14, i64 %"04.sroa.3.0.i.1", 1
  %"17.fca.2.insert.i.1" = insertvalue { i1, i64, i1 } %"17.fca.1.insert.i.1", i1 %"04.sroa.6.0.i.1", 2
  %17 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i.1", 1
  %18 = getelementptr i8, ptr %3, i64 32
  %.fca.2.0.extract.i.1 = load i1, ptr %18, align 1
  store { i1, { i1, i64, i1 } } %17, ptr %18, align 4
  br i1 %.fca.2.0.extract.i.1, label %cond_141_case_1.i, label %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).133.exit.1"

"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).133.exit.1": ; preds = %cond_140_case_1.i.1
  %19 = getelementptr inbounds nuw i8, ptr %8, i64 24
  store { i1, i64, i1 } %"17.fca.2.insert.i.1", ptr %19, align 4
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %20 = load i64, ptr %4, align 4
  %21 = and i64 %20, 3
  store i64 %21, ptr %4, align 4
  %22 = icmp eq i64 %21, 0
  br i1 %22, label %__barray_check_none_borrowed.exit186, label %mask_block_err.i184

__barray_check_none_borrowed.exit186:             ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).133.exit.1"
  %23 = tail call ptr @heap_alloc(i64 48)
  %24 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %24, align 1
  %25 = load { i1, { i1, i64, i1 } }, ptr %3, align 4
  %26 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).179"({ i1, { i1, i64, i1 } } %25)
  %27 = extractvalue { { i1, i64, i1 } } %26, 0
  store { i1, i64, i1 } %27, ptr %23, align 4
  %28 = load { i1, { i1, i64, i1 } }, ptr %18, align 4
  %29 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).179"({ i1, { i1, i64, i1 } } %28)
  %30 = getelementptr inbounds nuw i8, ptr %23, i64 24
  %31 = extractvalue { { i1, i64, i1 } } %29, 0
  store { i1, i64, i1 } %31, ptr %30, align 4
  tail call void @heap_free(ptr nonnull %3)
  tail call void @heap_free(ptr nonnull %4)
  %32 = load i64, ptr %24, align 4
  %33 = trunc i64 %32 to i1
  br i1 %33, label %cond_exit_205, label %__barray_mask_borrow.exit

mask_block_err.i184:                              ; preds = %"__hugr__.$__copy_scan$$n(2)$t([Bool]+[Future(Bool)])$n(1).133.exit.1"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

mask_block_err.i190:                              ; preds = %cond_exit_205.1
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %__barray_check_none_borrowed.exit186
  %34 = or disjoint i64 %32, 1
  store i64 %34, ptr %24, align 4
  %35 = load { i1, i64, i1 }, ptr %23, align 4
  %.fca.0.extract112 = extractvalue { i1, i64, i1 } %35, 0
  br i1 %.fca.0.extract112, label %cond_228_case_1, label %cond_exit_205

cond_exit_205:                                    ; preds = %cond_228_case_1, %__barray_mask_borrow.exit, %__barray_check_none_borrowed.exit186
  %36 = load i64, ptr %24, align 4
  %37 = and i64 %36, 2
  %.not214 = icmp eq i64 %37, 0
  br i1 %.not214, label %__barray_mask_borrow.exit.1, label %cond_exit_205.1

__barray_mask_borrow.exit.1:                      ; preds = %cond_exit_205
  %38 = or disjoint i64 %36, 2
  store i64 %38, ptr %24, align 4
  %39 = getelementptr inbounds nuw i8, ptr %23, i64 24
  %40 = load { i1, i64, i1 }, ptr %39, align 4
  %.fca.0.extract112.1 = extractvalue { i1, i64, i1 } %40, 0
  br i1 %.fca.0.extract112.1, label %cond_228_case_1.1, label %cond_exit_205.1

cond_228_case_1.1:                                ; preds = %__barray_mask_borrow.exit.1
  %.fca.1.extract113.1 = extractvalue { i1, i64, i1 } %40, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract113.1)
  br label %cond_exit_205.1

cond_exit_205.1:                                  ; preds = %cond_228_case_1.1, %__barray_mask_borrow.exit.1, %cond_exit_205
  %41 = load i64, ptr %24, align 4
  %42 = or i64 %41, -4
  store i64 %42, ptr %24, align 4
  %43 = icmp eq i64 %42, -1
  br i1 %43, label %loop_out, label %mask_block_err.i190

loop_out:                                         ; preds = %cond_exit_205.1
  tail call void @heap_free(ptr nonnull %23)
  tail call void @heap_free(ptr nonnull %24)
  %44 = load i64, ptr %9, align 4
  %45 = and i64 %44, 3
  store i64 %45, ptr %9, align 4
  %46 = icmp eq i64 %45, 0
  br i1 %46, label %__barray_check_none_borrowed.exit197, label %mask_block_err.i195

__barray_check_none_borrowed.exit197:             ; preds = %loop_out
  %47 = tail call ptr @heap_alloc(i64 2)
  %48 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %48, align 1
  %49 = load { i1, i64, i1 }, ptr %8, align 4
  %50 = tail call { i1 } @__hugr__.array.__read_bool.3.46({ i1, i64, i1 } %49)
  %51 = extractvalue { i1 } %50, 0
  store i1 %51, ptr %47, align 1
  %52 = load { i1, i64, i1 }, ptr %19, align 4
  %53 = tail call { i1 } @__hugr__.array.__read_bool.3.46({ i1, i64, i1 } %52)
  %54 = getelementptr inbounds nuw i8, ptr %47, i64 1
  %55 = extractvalue { i1 } %53, 0
  store i1 %55, ptr %54, align 1
  tail call void @heap_free(ptr nonnull %8)
  tail call void @heap_free(ptr nonnull %9)
  %56 = load i64, ptr %48, align 4
  %57 = and i64 %56, 3
  store i64 %57, ptr %48, align 4
  %58 = icmp eq i64 %57, 0
  br i1 %58, label %__barray_check_none_borrowed.exit203, label %mask_block_err.i201

mask_block_err.i195:                              ; preds = %loop_out
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_228_case_1:                                  ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract113 = extractvalue { i1, i64, i1 } %35, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract113)
  br label %cond_exit_205

__barray_check_none_borrowed.exit203:             ; preds = %__barray_check_none_borrowed.exit197
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %59 = alloca [2 x i1], align 1
  store i1 false, ptr %59, align 1
  %.repack167 = getelementptr inbounds nuw i8, ptr %59, i64 1
  store i1 false, ptr %.repack167, align 1
  store i32 2, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %47, ptr %arr_ptr, align 8
  store ptr %59, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_c.19197FA6.0, i64 14, ptr nonnull %out_arr_alloca)
  ret void

mask_block_err.i201:                              ; preds = %__barray_check_none_borrowed.exit197
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
}

define internal i1 @__hugr__.array.__read_bool.3.46({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_103_case_1, label %cond_103_case_0

cond_103_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_103

cond_103_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_103

cond_exit_103:                                    ; preds = %cond_103_case_1, %cond_103_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_103_case_1 ], [ %.fca.2.extract, %cond_103_case_0 ]
  ret i1 %"03.0"
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

define internal { i1, i64, i1 } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).179"({ i1, { i1, i64, i1 } } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract11 = extractvalue { i1, { i1, i64, i1 } } %0, 0
  br i1 %.fca.0.extract11, label %cond_182_case_1, label %cond_182_case_0

cond_182_case_1:                                  ; preds = %alloca_block
  %1 = extractvalue { i1, { i1, i64, i1 } } %0, 1
  ret { i1, i64, i1 } %1

cond_182_case_0:                                  ; preds = %alloca_block
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

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

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

!name = !{!0}

!0 = !{!"mainlib"}
