; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@e_Option.unw.32D4E82D.0 = private constant [43 x i8] c"*EXIT:INT:Option.unwrap: value is `Nothing`"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_head_leake.F4F32972.0 = private constant [21 x i8] c"\14USER:INT:head_leaked"
@res_head.AFE8E005.0 = private constant [15 x i8] c"\0EUSER:BOOL:head"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_tail.AD5A440E.0 = private constant [18 x i8] c"\11USER:BOOLARR:tail"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 160)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_512_case_0.i, label %__hugr__.__tk2_helios_qalloc.508.exit

cond_512_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.508.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rxy(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18)
  br label %cond_21_case_1

2:                                                ; preds = %cond_exit_80
  %read_uint.i = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %.not = icmp eq i64 %read_uint.i, 2
  br i1 %.not, label %cond_133_case_0, label %cond_133_case_1

3:                                                ; preds = %cond_exit_80
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  tail call void @print_int(ptr nonnull @res_head_leake.F4F32972.0, i64 20, i64 1)
  br label %5

cond_133_case_1:                                  ; preds = %2
  %4 = icmp eq i64 %read_uint.i, 1
  tail call void @print_bool(ptr nonnull @res_head.AFE8E005.0, i64 14, i1 %4)
  br label %5

5:                                                ; preds = %cond_133_case_1, %3
  %"147_0215.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"147_0215.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"147_0215.fca.0.insert", ptr %1, 1
  %"147_0215.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"147_0215.fca.1.insert", i64 0, 2
  %6 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"147_0215.fca.2.insert", 0
  %7 = tail call ptr @heap_alloc(i64 160)
  %8 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %8, align 1
  br label %__barray_check_bounds.exit.i.i

9:                                                ; preds = %loop_body.i
  %10 = lshr i64 %.fca.2.extract.i.i, 6
  %11 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %10
  %12 = load i64, ptr %11, align 4
  %13 = and i64 %.fca.2.extract.i.i, 63
  %14 = sub nuw nsw i64 64, %13
  %15 = lshr i64 -1, %14
  %16 = icmp eq i64 %13, 0
  %17 = select i1 %16, i64 0, i64 %15
  %18 = or i64 %12, %17
  store i64 %18, ptr %11, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 19
  %19 = lshr i64 %last_valid.i.i.i, 6
  %20 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %19
  %21 = load i64, ptr %20, align 4
  %22 = and i64 %last_valid.i.i.i, 63
  %23 = shl nsw i64 -2, %22
  %24 = icmp eq i64 %22, 63
  %25 = select i1 %24, i64 0, i64 %23
  %26 = or i64 %21, %25
  store i64 %26, ptr %20, align 4
  %reass.sub.i.i.i = sub nsw i64 %19, %10
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$20.338.exit", label %mask_block_ok.i.i.i

27:                                               ; preds = %mask_block_ok.i.i.i
  %28 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$20.338.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %9, %27
  %.02.i.i.i = phi i64 [ %28, %27 ], [ 0, %9 ]
  %gep.i.i.i = getelementptr i64, ptr %11, i64 %.02.i.i.i
  %29 = load i64, ptr %gep.i.i.i, align 4
  %30 = icmp eq i64 %29, -1
  br i1 %30, label %27, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %5
  %.fca.2.extract.i181.i = phi i64 [ 0, %5 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %5 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %5 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"352_0.sroa.15.0178.i" = phi i64 [ 0, %5 ], [ %31, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %6, %5 ], [ %46, %loop_body.i ]
  %31 = add nuw nsw i64 %"352_0.sroa.15.0178.i", 1
  %32 = add i64 %"352_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %33 = lshr i64 %32, 6
  %34 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %33
  %35 = load i64, ptr %34, align 4
  %36 = and i64 %32, 63
  %37 = lshr i64 %35, %36
  %38 = trunc i64 %37 to i1
  br i1 %38, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %39 = shl nuw i64 1, %36
  %40 = xor i64 %39, %35
  store i64 %40, ptr %34, align 4
  %41 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %32
  %42 = load i64, ptr %41, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %42)
  tail call void @___qfree(i64 %42)
  %43 = load i64, ptr %8, align 4
  %44 = lshr i64 %43, %"352_0.sroa.15.0178.i"
  %45 = trunc i64 %44 to i1
  br i1 %45, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %46 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %31, 1
  %47 = shl nuw nsw i64 1, %"352_0.sroa.15.0178.i"
  %48 = xor i64 %43, %47
  store i64 %48, ptr %8, align 4
  %49 = getelementptr inbounds nuw i64, ptr %7, i64 %"352_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %49, align 4
  %50 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %50, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %50, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %50, 2
  %exitcond.not.i = icmp eq i64 %31, 20
  br i1 %exitcond.not.i, label %9, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$20.338.exit": ; preds = %27, %9
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %7, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %8, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %51 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %52 = tail call ptr @heap_alloc(i64 20)
  %53 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %53, align 1
  br label %__barray_check_bounds.exit.i577

cond_21_case_1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.508.exit, %cond_exit_21
  %"16_0.sroa.0.0627" = phi i64 [ 0, %__hugr__.__tk2_helios_qalloc.508.exit ], [ %54, %cond_exit_21 ]
  %54 = add nuw nsw i64 %"16_0.sroa.0.0627", 1
  %qalloc.i566 = tail call i64 @___qalloc()
  %not_max.not.not.i567 = icmp eq i64 %qalloc.i566, -1
  br i1 %not_max.not.not.i567, label %cond_578_case_0.i, label %__barray_check_bounds.exit

cond_578_case_0.i:                                ; preds = %cond_21_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_21_case_1
  tail call void @___reset(i64 %qalloc.i566)
  %55 = load i64, ptr %1, align 4
  %56 = lshr i64 %55, %"16_0.sroa.0.0627"
  %57 = trunc i64 %56 to i1
  br i1 %57, label %cond_exit_21, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_21:                                     ; preds = %__barray_check_bounds.exit
  %58 = shl nuw nsw i64 1, %"16_0.sroa.0.0627"
  %59 = xor i64 %55, %58
  store i64 %59, ptr %1, align 4
  %60 = getelementptr inbounds nuw i64, ptr %0, i64 %"16_0.sroa.0.0627"
  store i64 %qalloc.i566, ptr %60, align 4
  %exitcond.not = icmp eq i64 %54, 20
  br i1 %exitcond.not, label %__barray_check_bounds.exit569, label %cond_21_case_1

__barray_check_bounds.exit569:                    ; preds = %cond_exit_21, %__barray_mask_return.exit574
  %"48_0.0628" = phi i64 [ %61, %__barray_mask_return.exit574 ], [ 0, %cond_exit_21 ]
  %61 = add nuw nsw i64 %"48_0.0628", 1
  %62 = load i64, ptr %1, align 4
  %63 = lshr i64 %62, %"48_0.0628"
  %64 = trunc i64 %63 to i1
  br i1 %64, label %panic.i570, label %__barray_check_bounds.exit572

panic.i570:                                       ; preds = %__barray_check_bounds.exit569
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit572:                    ; preds = %__barray_check_bounds.exit569
  %65 = shl nuw nsw i64 1, %"48_0.0628"
  %66 = xor i64 %62, %65
  store i64 %66, ptr %1, align 4
  %67 = getelementptr inbounds nuw i64, ptr %0, i64 %"48_0.0628"
  %68 = load i64, ptr %67, align 4
  tail call void @___rxy(i64 %68, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %qalloc.i, i64 %68, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %68, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %68, double 0xBFF921FB54442D18)
  %69 = load i64, ptr %1, align 4
  %70 = lshr i64 %69, %"48_0.0628"
  %71 = trunc i64 %70 to i1
  br i1 %71, label %__barray_mask_return.exit574, label %panic.i573

panic.i573:                                       ; preds = %__barray_check_bounds.exit572
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit574:                     ; preds = %__barray_check_bounds.exit572
  %72 = xor i64 %69, %65
  store i64 %72, ptr %1, align 4
  store i64 %68, ptr %67, align 4
  %exitcond632.not = icmp eq i64 %61, 20
  br i1 %exitcond632.not, label %cond_exit_80, label %__barray_check_bounds.exit569

cond_exit_80:                                     ; preds = %__barray_mask_return.exit574
  %lazy_measure_leaked.i = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___inc_future_refcount(i64 %lazy_measure_leaked.i)
  %read_uint.i575 = tail call i64 @___read_future_uint(i64 %lazy_measure_leaked.i)
  tail call void @___dec_future_refcount(i64 %lazy_measure_leaked.i)
  %73 = icmp eq i64 %read_uint.i575, 2
  br i1 %73, label %3, label %2

cond_133_case_0:                                  ; preds = %2
  tail call void @panic(i32 1001, ptr nonnull @e_Option.unw.32D4E82D.0)
  unreachable

loop_body.preheader.i:                            ; preds = %loop_body226
  %"598_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %134, 2
  %"598_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %134, 1
  %"598_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %134, 0
  br label %__barray_check_bounds.exit224.i

__barray_check_bounds.exit.i577:                  ; preds = %loop_body226, %"__hugr__.guppylang.std.quantum.measure_array$20.338.exit"
  %74 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$20.338.exit" ], [ %134, %loop_body226 ]
  %"157_0.sroa.15.0631" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$20.338.exit" ], [ %75, %loop_body226 ]
  %.pn619630 = phi { { ptr, ptr, i64 }, i64 } [ %51, %"__hugr__.guppylang.std.quantum.measure_array$20.338.exit" ], [ %130, %loop_body226 ]
  %75 = add nuw nsw i64 %"157_0.sroa.15.0631", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %74, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %74, 1
  %76 = add i64 %.fca.2.extract208.i, %"157_0.sroa.15.0631"
  %77 = lshr i64 %76, 6
  %78 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %77
  %79 = load i64, ptr %78, align 4
  %80 = and i64 %76, 63
  %81 = lshr i64 %79, %80
  %82 = trunc i64 %81 to i1
  br i1 %82, label %panic.i.i578, label %__barray_check_bounds.exit221.i

panic.i.i578:                                     ; preds = %__barray_check_bounds.exit.i577
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i577
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %74, 0
  %83 = shl nuw i64 1, %80
  %84 = xor i64 %79, %83
  store i64 %84, ptr %78, align 4
  %85 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %76
  %86 = load i64, ptr %85, align 4
  tail call void @___inc_future_refcount(i64 %86)
  %87 = load i64, ptr %78, align 4
  %88 = lshr i64 %87, %80
  %89 = trunc i64 %88 to i1
  br i1 %89, label %__barray_check_bounds.exit580, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_601_case_0.i:                                ; preds = %cond_exit_601.thread.i
  %90 = lshr i64 %"598_1.sroa.10.0.i", 6
  %91 = getelementptr i64, ptr %"598_1.sroa.5.0.i", i64 %90
  %92 = load i64, ptr %91, align 4
  %93 = and i64 %"598_1.sroa.10.0.i", 63
  %94 = sub nuw nsw i64 64, %93
  %95 = lshr i64 -1, %94
  %96 = icmp eq i64 %93, 0
  %97 = select i1 %96, i64 0, i64 %95
  %98 = or i64 %92, %97
  store i64 %98, ptr %91, align 4
  %last_valid.i.i = add i64 %"598_1.sroa.10.0.i", 19
  %99 = lshr i64 %last_valid.i.i, 6
  %100 = getelementptr inbounds nuw i64, ptr %"598_1.sroa.5.0.i", i64 %99
  %101 = load i64, ptr %100, align 4
  %102 = and i64 %last_valid.i.i, 63
  %103 = shl nsw i64 -2, %102
  %104 = icmp eq i64 %102, 63
  %105 = select i1 %104, i64 0, i64 %103
  %106 = or i64 %101, %105
  store i64 %106, ptr %100, align 4
  %reass.sub.i.i = sub nsw i64 %99, %90
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.379.exit", label %mask_block_ok.i.i

107:                                              ; preds = %mask_block_ok.i.i
  %108 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.379.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_601_case_0.i, %107
  %.02.i.i = phi i64 [ %108, %107 ], [ 0, %cond_601_case_0.i ]
  %gep.i.i = getelementptr i64, ptr %91, i64 %.02.i.i
  %109 = load i64, ptr %gep.i.i, align 4
  %110 = icmp eq i64 %109, -1
  br i1 %110, label %107, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i:                  ; preds = %cond_exit_601.thread.i, %loop_body.preheader.i
  %"598_0.0239.i" = phi i64 [ 0, %loop_body.preheader.i ], [ %111, %cond_exit_601.thread.i ]
  %111 = add nuw nsw i64 %"598_0.0239.i", 1
  %112 = add i64 %"598_0.0239.i", %"598_1.sroa.10.0.i"
  %113 = lshr i64 %112, 6
  %114 = getelementptr inbounds nuw i64, ptr %"598_1.sroa.5.0.i", i64 %113
  %115 = load i64, ptr %114, align 4
  %116 = and i64 %112, 63
  %117 = lshr i64 %115, %116
  %118 = trunc i64 %117 to i1
  br i1 %118, label %cond_exit_601.thread.i, label %__barray_mask_borrow.exit228.i

__barray_mask_borrow.exit228.i:                   ; preds = %__barray_check_bounds.exit224.i
  %119 = shl nuw i64 1, %116
  %120 = xor i64 %119, %115
  store i64 %120, ptr %114, align 4
  %121 = getelementptr inbounds i64, ptr %"598_1.sroa.0.0.i", i64 %112
  %122 = load i64, ptr %121, align 4
  tail call void @___dec_future_refcount(i64 %122)
  br label %cond_exit_601.thread.i

cond_exit_601.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %__barray_check_bounds.exit224.i
  %exitcond.i = icmp eq i64 %111, 20
  br i1 %exitcond.i, label %cond_601_case_0.i, label %__barray_check_bounds.exit224.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.379.exit": ; preds = %107, %cond_601_case_0.i
  tail call void @heap_free(ptr %"598_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"598_1.sroa.5.0.i")
  %123 = load i64, ptr %53, align 4
  %124 = and i64 %123, 1048575
  store i64 %124, ptr %53, align 4
  %125 = icmp eq i64 %124, 0
  br i1 %125, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit580:                    ; preds = %__barray_check_bounds.exit221.i
  %126 = xor i64 %87, %83
  store i64 %126, ptr %78, align 4
  store i64 %86, ptr %85, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %86)
  tail call void @___dec_future_refcount(i64 %86)
  %127 = load i64, ptr %53, align 4
  %128 = lshr i64 %127, %"157_0.sroa.15.0631"
  %129 = trunc i64 %128 to i1
  br i1 %129, label %loop_body226, label %panic.i581

panic.i581:                                       ; preds = %__barray_check_bounds.exit580
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body226:                                     ; preds = %__barray_check_bounds.exit580
  %130 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn619630, i64 %75, 1
  %131 = shl nuw nsw i64 1, %"157_0.sroa.15.0631"
  %132 = xor i64 %127, %131
  store i64 %132, ptr %53, align 4
  %133 = getelementptr inbounds nuw i1, ptr %52, i64 %"157_0.sroa.15.0631"
  store i1 %read_bool, ptr %133, align 1
  %134 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn619630, 0
  %exitcond633.not = icmp eq i64 %75, 20
  br i1 %exitcond633.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i577

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.379.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&20.379.exit"
  %135 = tail call ptr @heap_alloc(i64 20)
  %136 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %136, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %135, ptr noundef nonnull align 1 dereferenceable(20) %52, i64 20, i1 false)
  tail call void @heap_free(ptr nonnull %135)
  %137 = load i64, ptr %53, align 4
  %138 = and i64 %137, 1048575
  store i64 %138, ptr %53, align 4
  %139 = icmp eq i64 %138, 0
  br i1 %139, label %__barray_check_none_borrowed.exit584, label %mask_block_err.i583

mask_block_err.i583:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit584:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %140 = alloca [20 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %140, i8 0, i64 20, i1 false)
  store i32 20, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %52, ptr %arr_ptr, align 8
  store ptr %140, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_tail.AD5A440E.0, i64 17, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure_leaked(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare i64 @___read_future_uint(i64) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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
