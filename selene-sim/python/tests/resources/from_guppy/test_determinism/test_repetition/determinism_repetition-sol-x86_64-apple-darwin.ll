; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_a.A4A74DAF.0 = private constant [12 x i8] c"\0BUSER:BOOL:a"
@res_b.3BD50C23.0 = private constant [12 x i8] c"\0BUSER:BOOL:b"
@res_c.1C9EF4D1.0 = private constant [12 x i8] c"\0BUSER:BOOL:c"
@res_d.00B84DC7.0 = private constant [12 x i8] c"\0BUSER:BOOL:d"
@res_e.B9A29CAF.0 = private constant [12 x i8] c"\0BUSER:BOOL:e"
@res_shot.6D86EAF7.0 = private constant [14 x i8] c"\0DUSER:INT:shot"
@res_random_int.805B8DD0.0 = private constant [20 x i8] c"\13USER:INT:random_int"
@res_random_flo.4EFA2734.0 = private constant [24 x i8] c"\17USER:FLOAT:random_float"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 40)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_577_case_0.i, label %__hugr__.__tk2_sol_qalloc.550.exit

cond_577_case_0.i:                                ; preds = %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.550.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.4, %__hugr__.__tk2_sol_qalloc.550.exit.3, %__hugr__.__tk2_sol_qalloc.550.exit.2, %__hugr__.__tk2_sol_qalloc.550.exit.1, %__hugr__.__tk2_sol_qalloc.550.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_sol_qalloc.550.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_577_case_0.i, label %__hugr__.__tk2_sol_qalloc.550.exit.1

__hugr__.__tk2_sol_qalloc.550.exit.1:             ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not701 = icmp eq i64 %6, 0
  br i1 %.not701, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.550.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_577_case_0.i, label %__hugr__.__tk2_sol_qalloc.550.exit.2

__hugr__.__tk2_sol_qalloc.550.exit.2:             ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not702 = icmp eq i64 %10, 0
  br i1 %.not702, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_sol_qalloc.550.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_577_case_0.i, label %__hugr__.__tk2_sol_qalloc.550.exit.3

__hugr__.__tk2_sol_qalloc.550.exit.3:             ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not703 = icmp eq i64 %14, 0
  br i1 %.not703, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_sol_qalloc.550.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_577_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not704 = icmp eq i64 %18, 0
  br i1 %.not704, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %21 = load i64, ptr %1, align 4
  %22 = trunc i64 %21 to i1
  br i1 %22, label %panic.i628, label %__barray_check_bounds.exit630

panic.i628:                                       ; preds = %__barray_check_bounds.exit627.4, %__barray_mask_return.exit632.2, %__barray_mask_return.exit632.1, %__barray_mask_return.exit632, %cond_exit_20.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit630:                    ; preds = %cond_exit_20.4
  %23 = or disjoint i64 %21, 1
  store i64 %23, ptr %1, align 4
  %24 = load i64, ptr %0, align 4
  tail call void @___rp(i64 %24, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %24, double 0x400921FB54442D18)
  %25 = load i64, ptr %1, align 4
  %26 = trunc i64 %25 to i1
  br i1 %26, label %__barray_mask_return.exit632, label %panic.i631

panic.i631:                                       ; preds = %__barray_check_bounds.exit630.4, %__barray_check_bounds.exit630.3, %__barray_check_bounds.exit630.2, %__barray_check_bounds.exit630.1, %__barray_check_bounds.exit630
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit632:                     ; preds = %__barray_check_bounds.exit630
  %27 = and i64 %25, -2
  store i64 %27, ptr %1, align 4
  store i64 %24, ptr %0, align 4
  %28 = load i64, ptr %1, align 4
  %29 = and i64 %28, 2
  %.not705 = icmp eq i64 %29, 0
  br i1 %.not705, label %__barray_check_bounds.exit630.1, label %panic.i628

__barray_check_bounds.exit630.1:                  ; preds = %__barray_mask_return.exit632
  %30 = or disjoint i64 %28, 2
  store i64 %30, ptr %1, align 4
  %31 = load i64, ptr %8, align 4
  tail call void @___rp(i64 %31, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %31, double 0x400921FB54442D18)
  %32 = load i64, ptr %1, align 4
  %33 = and i64 %32, 2
  %.not706 = icmp eq i64 %33, 0
  br i1 %.not706, label %panic.i631, label %__barray_mask_return.exit632.1

__barray_mask_return.exit632.1:                   ; preds = %__barray_check_bounds.exit630.1
  %34 = and i64 %32, -3
  store i64 %34, ptr %1, align 4
  store i64 %31, ptr %8, align 4
  %35 = load i64, ptr %1, align 4
  %36 = and i64 %35, 4
  %.not707 = icmp eq i64 %36, 0
  br i1 %.not707, label %__barray_check_bounds.exit630.2, label %panic.i628

__barray_check_bounds.exit630.2:                  ; preds = %__barray_mask_return.exit632.1
  %37 = or disjoint i64 %35, 4
  store i64 %37, ptr %1, align 4
  %38 = load i64, ptr %12, align 4
  tail call void @___rp(i64 %38, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %38, double 0x400921FB54442D18)
  %39 = load i64, ptr %1, align 4
  %40 = and i64 %39, 4
  %.not708 = icmp eq i64 %40, 0
  br i1 %.not708, label %panic.i631, label %__barray_mask_return.exit632.2

__barray_mask_return.exit632.2:                   ; preds = %__barray_check_bounds.exit630.2
  %41 = and i64 %39, -5
  store i64 %41, ptr %1, align 4
  store i64 %38, ptr %12, align 4
  %42 = load i64, ptr %1, align 4
  %43 = and i64 %42, 8
  %.not709 = icmp eq i64 %43, 0
  br i1 %.not709, label %__barray_check_bounds.exit630.3, label %panic.i628

__barray_check_bounds.exit630.3:                  ; preds = %__barray_mask_return.exit632.2
  %44 = or disjoint i64 %42, 8
  store i64 %44, ptr %1, align 4
  %45 = load i64, ptr %16, align 4
  tail call void @___rp(i64 %45, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %45, double 0x400921FB54442D18)
  %46 = load i64, ptr %1, align 4
  %47 = and i64 %46, 8
  %.not710 = icmp eq i64 %47, 0
  br i1 %.not710, label %panic.i631, label %__barray_check_bounds.exit627.4

__barray_check_bounds.exit627.4:                  ; preds = %__barray_check_bounds.exit630.3
  %48 = and i64 %46, -9
  store i64 %48, ptr %1, align 4
  store i64 %45, ptr %16, align 4
  %49 = load i64, ptr %1, align 4
  %50 = and i64 %49, 16
  %.not711 = icmp eq i64 %50, 0
  br i1 %.not711, label %__barray_check_bounds.exit630.4, label %panic.i628

__barray_check_bounds.exit630.4:                  ; preds = %__barray_check_bounds.exit627.4
  %51 = or disjoint i64 %49, 16
  store i64 %51, ptr %1, align 4
  %52 = load i64, ptr %20, align 4
  tail call void @___rp(i64 %52, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %52, double 0x400921FB54442D18)
  %53 = load i64, ptr %1, align 4
  %54 = and i64 %53, 16
  %.not712 = icmp eq i64 %54, 0
  br i1 %.not712, label %panic.i631, label %__barray_mask_return.exit632.4

__barray_mask_return.exit632.4:                   ; preds = %__barray_check_bounds.exit630.4
  %55 = and i64 %53, -17
  store i64 %55, ptr %1, align 4
  store i64 %52, ptr %20, align 4
  %shot = tail call i64 @get_current_shot()
  %shot109 = tail call i64 @get_current_shot()
  %56 = tail call ptr @heap_alloc(i64 40)
  %57 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %57, align 1
  %58 = load i64, ptr %1, align 4
  %59 = trunc i64 %58 to i1
  br i1 %59, label %panic.i.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.i"

loop_body.preheader.i:                            ; preds = %loop_body120
  %"597_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %155, 2
  %"597_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %155, 1
  %"597_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %155, 0
  %60 = lshr i64 %"597_1.sroa.10.0.i", 6
  %61 = getelementptr i64, ptr %"597_1.sroa.5.0.i", i64 %60
  %62 = load i64, ptr %61, align 4
  %63 = and i64 %"597_1.sroa.10.0.i", 63
  %64 = lshr i64 %62, %63
  %65 = trunc i64 %64 to i1
  br i1 %65, label %cond_exit_600.thread.i, label %__barray_mask_borrow.exit228.i

__barray_check_bounds.exit.i:                     ; preds = %loop_body120, %"__hugr__.guppylang.std.quantum.measure_array$5.353.exit"
  %66 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$5.353.exit" ], [ %155, %loop_body120 ]
  %"79_0.sroa.15.0700" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$5.353.exit" ], [ %67, %loop_body120 ]
  %.pn684699 = phi { { ptr, ptr, i64 }, i64 } [ %170, %"__hugr__.guppylang.std.quantum.measure_array$5.353.exit" ], [ %151, %loop_body120 ]
  %67 = add nuw nsw i64 %"79_0.sroa.15.0700", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %66, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %66, 1
  %68 = add i64 %.fca.2.extract208.i, %"79_0.sroa.15.0700"
  %69 = lshr i64 %68, 6
  %70 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %69
  %71 = load i64, ptr %70, align 4
  %72 = and i64 %68, 63
  %73 = lshr i64 %71, %72
  %74 = trunc i64 %73 to i1
  br i1 %74, label %panic.i.i, label %__barray_check_bounds.exit221.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %66, 0
  %75 = shl nuw i64 1, %72
  %76 = xor i64 %71, %75
  store i64 %76, ptr %70, align 4
  %77 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %68
  %78 = load i64, ptr %77, align 4
  tail call void @___inc_future_refcount(i64 %78)
  %79 = load i64, ptr %70, align 4
  %80 = lshr i64 %79, %72
  %81 = trunc i64 %80 to i1
  br i1 %81, label %__barray_check_bounds.exit634, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

82:                                               ; preds = %mask_block_ok.i.i
  %83 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&5.394.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_exit_600.thread.4.i, %82
  %.02.i.i = phi i64 [ %83, %82 ], [ 0, %cond_exit_600.thread.4.i ]
  %gep.i.i = getelementptr i64, ptr %61, i64 %.02.i.i
  %84 = load i64, ptr %gep.i.i, align 4
  %85 = icmp eq i64 %84, -1
  br i1 %85, label %82, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i:                   ; preds = %loop_body.preheader.i
  %86 = shl nuw i64 1, %63
  %87 = xor i64 %62, %86
  store i64 %87, ptr %61, align 4
  %88 = getelementptr inbounds i64, ptr %"597_1.sroa.0.0.i", i64 %"597_1.sroa.10.0.i"
  %89 = load i64, ptr %88, align 4
  tail call void @___dec_future_refcount(i64 %89)
  br label %cond_exit_600.thread.i

cond_exit_600.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %loop_body.preheader.i
  %90 = add i64 %"597_1.sroa.10.0.i", 1
  %91 = lshr i64 %90, 6
  %92 = getelementptr inbounds nuw i64, ptr %"597_1.sroa.5.0.i", i64 %91
  %93 = load i64, ptr %92, align 4
  %94 = and i64 %90, 63
  %95 = lshr i64 %93, %94
  %96 = trunc i64 %95 to i1
  br i1 %96, label %cond_exit_600.thread.1.i, label %__barray_mask_borrow.exit228.1.i

__barray_mask_borrow.exit228.1.i:                 ; preds = %cond_exit_600.thread.i
  %97 = shl nuw i64 1, %94
  %98 = xor i64 %93, %97
  store i64 %98, ptr %92, align 4
  %99 = getelementptr inbounds i64, ptr %"597_1.sroa.0.0.i", i64 %90
  %100 = load i64, ptr %99, align 4
  tail call void @___dec_future_refcount(i64 %100)
  br label %cond_exit_600.thread.1.i

cond_exit_600.thread.1.i:                         ; preds = %__barray_mask_borrow.exit228.1.i, %cond_exit_600.thread.i
  %101 = add i64 %"597_1.sroa.10.0.i", 2
  %102 = lshr i64 %101, 6
  %103 = getelementptr inbounds nuw i64, ptr %"597_1.sroa.5.0.i", i64 %102
  %104 = load i64, ptr %103, align 4
  %105 = and i64 %101, 63
  %106 = lshr i64 %104, %105
  %107 = trunc i64 %106 to i1
  br i1 %107, label %cond_exit_600.thread.2.i, label %__barray_mask_borrow.exit228.2.i

__barray_mask_borrow.exit228.2.i:                 ; preds = %cond_exit_600.thread.1.i
  %108 = shl nuw i64 1, %105
  %109 = xor i64 %104, %108
  store i64 %109, ptr %103, align 4
  %110 = getelementptr inbounds i64, ptr %"597_1.sroa.0.0.i", i64 %101
  %111 = load i64, ptr %110, align 4
  tail call void @___dec_future_refcount(i64 %111)
  br label %cond_exit_600.thread.2.i

cond_exit_600.thread.2.i:                         ; preds = %__barray_mask_borrow.exit228.2.i, %cond_exit_600.thread.1.i
  %112 = add i64 %"597_1.sroa.10.0.i", 3
  %113 = lshr i64 %112, 6
  %114 = getelementptr inbounds nuw i64, ptr %"597_1.sroa.5.0.i", i64 %113
  %115 = load i64, ptr %114, align 4
  %116 = and i64 %112, 63
  %117 = lshr i64 %115, %116
  %118 = trunc i64 %117 to i1
  br i1 %118, label %cond_exit_600.thread.3.i, label %__barray_mask_borrow.exit228.3.i

__barray_mask_borrow.exit228.3.i:                 ; preds = %cond_exit_600.thread.2.i
  %119 = shl nuw i64 1, %116
  %120 = xor i64 %115, %119
  store i64 %120, ptr %114, align 4
  %121 = getelementptr inbounds i64, ptr %"597_1.sroa.0.0.i", i64 %112
  %122 = load i64, ptr %121, align 4
  tail call void @___dec_future_refcount(i64 %122)
  br label %cond_exit_600.thread.3.i

cond_exit_600.thread.3.i:                         ; preds = %__barray_mask_borrow.exit228.3.i, %cond_exit_600.thread.2.i
  %123 = add i64 %"597_1.sroa.10.0.i", 4
  %124 = lshr i64 %123, 6
  %125 = getelementptr inbounds nuw i64, ptr %"597_1.sroa.5.0.i", i64 %124
  %126 = load i64, ptr %125, align 4
  %127 = and i64 %123, 63
  %128 = lshr i64 %126, %127
  %129 = trunc i64 %128 to i1
  br i1 %129, label %cond_exit_600.thread.4.i, label %__barray_mask_borrow.exit228.4.i

__barray_mask_borrow.exit228.4.i:                 ; preds = %cond_exit_600.thread.3.i
  %130 = shl nuw i64 1, %127
  %131 = xor i64 %126, %130
  store i64 %131, ptr %125, align 4
  %132 = getelementptr inbounds i64, ptr %"597_1.sroa.0.0.i", i64 %123
  %133 = load i64, ptr %132, align 4
  tail call void @___dec_future_refcount(i64 %133)
  br label %cond_exit_600.thread.4.i

cond_exit_600.thread.4.i:                         ; preds = %__barray_mask_borrow.exit228.4.i, %cond_exit_600.thread.3.i
  %134 = load i64, ptr %61, align 4
  %135 = sub nuw nsw i64 64, %63
  %136 = lshr i64 -1, %135
  %137 = icmp eq i64 %63, 0
  %138 = select i1 %137, i64 0, i64 %136
  %139 = or i64 %134, %138
  store i64 %139, ptr %61, align 4
  %140 = load i64, ptr %125, align 4
  %141 = shl nsw i64 -2, %127
  %142 = icmp eq i64 %127, 63
  %143 = select i1 %142, i64 0, i64 %141
  %144 = or i64 %140, %143
  store i64 %144, ptr %125, align 4
  %reass.sub.i.i = sub nsw i64 %124, %60
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&5.394.exit", label %mask_block_ok.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&5.394.exit": ; preds = %82, %cond_exit_600.thread.4.i
  tail call void @heap_free(ptr %"597_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"597_1.sroa.5.0.i")
  %145 = load i64, ptr %172, align 4
  %146 = trunc i64 %145 to i1
  br i1 %146, label %panic.i637, label %__barray_mask_check_not_borrowed.exit

__barray_check_bounds.exit634:                    ; preds = %__barray_check_bounds.exit221.i
  %147 = xor i64 %79, %75
  store i64 %147, ptr %70, align 4
  store i64 %78, ptr %77, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %78)
  tail call void @___dec_future_refcount(i64 %78)
  %148 = load i64, ptr %172, align 4
  %149 = lshr i64 %148, %"79_0.sroa.15.0700"
  %150 = trunc i64 %149 to i1
  br i1 %150, label %loop_body120, label %panic.i635

panic.i635:                                       ; preds = %__barray_check_bounds.exit634
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body120:                                     ; preds = %__barray_check_bounds.exit634
  %151 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn684699, i64 %67, 1
  %152 = shl nuw nsw i64 1, %"79_0.sroa.15.0700"
  %153 = xor i64 %148, %152
  store i64 %153, ptr %172, align 4
  %154 = getelementptr inbounds nuw i1, ptr %171, i64 %"79_0.sroa.15.0700"
  store i1 %read_bool, ptr %154, align 1
  %155 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn684699, 0
  %exitcond.not = icmp eq i64 %67, 5
  br i1 %exitcond.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i

panic.i637:                                       ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&5.394.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit:            ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&5.394.exit"
  %156 = load i1, ptr %171, align 1
  %157 = and i64 %145, 2
  %.not686 = icmp eq i64 %157, 0
  br i1 %.not686, label %__barray_mask_check_not_borrowed.exit639, label %panic.i638

panic.i638:                                       ; preds = %__barray_mask_check_not_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit639:         ; preds = %__barray_mask_check_not_borrowed.exit
  %158 = getelementptr inbounds nuw i8, ptr %171, i64 1
  %159 = load i1, ptr %158, align 1
  %160 = and i64 %145, 4
  %.not687 = icmp eq i64 %160, 0
  br i1 %.not687, label %__barray_mask_check_not_borrowed.exit641, label %panic.i640

panic.i640:                                       ; preds = %__barray_mask_check_not_borrowed.exit639
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit641:         ; preds = %__barray_mask_check_not_borrowed.exit639
  %161 = getelementptr inbounds nuw i8, ptr %171, i64 2
  %162 = load i1, ptr %161, align 1
  %163 = and i64 %145, 8
  %.not688 = icmp eq i64 %163, 0
  br i1 %.not688, label %__barray_mask_check_not_borrowed.exit643, label %panic.i642

panic.i642:                                       ; preds = %__barray_mask_check_not_borrowed.exit641
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit643:         ; preds = %__barray_mask_check_not_borrowed.exit641
  %164 = and i64 %145, 16
  %.not689 = icmp eq i64 %164, 0
  br i1 %.not689, label %__barray_mask_check_not_borrowed.exit645, label %panic.i644

panic.i644:                                       ; preds = %__barray_mask_check_not_borrowed.exit643
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_check_not_borrowed.exit645:         ; preds = %__barray_mask_check_not_borrowed.exit643
  %165 = getelementptr inbounds nuw i8, ptr %171, i64 3
  %166 = load i1, ptr %165, align 1
  %167 = getelementptr inbounds nuw i8, ptr %171, i64 4
  %168 = load i1, ptr %167, align 1
  tail call void @heap_free(ptr nonnull %171)
  tail call void @print_bool(ptr nonnull @res_a.A4A74DAF.0, i64 11, i1 %156)
  tail call void @print_bool(ptr nonnull @res_b.3BD50C23.0, i64 11, i1 %159)
  tail call void @print_bool(ptr nonnull @res_c.1C9EF4D1.0, i64 11, i1 %162)
  tail call void @print_bool(ptr nonnull @res_d.00B84DC7.0, i64 11, i1 %166)
  tail call void @print_bool(ptr nonnull @res_e.B9A29CAF.0, i64 11, i1 %168)
  tail call void @print_int(ptr nonnull @res_shot.6D86EAF7.0, i64 13, i64 %shot109)
  tail call void @random_seed(i64 %shot)
  %rint = tail call i32 @random_int()
  %rfloat = tail call double @random_float()
  %169 = sext i32 %rint to i64
  tail call void @print_int(ptr nonnull @res_random_int.805B8DD0.0, i64 19, i64 %169)
  tail call void @print_float(ptr nonnull @res_random_flo.4EFA2734.0, i64 23, double %rfloat)
  ret void

"__hugr__.guppylang.std.quantum.measure_array$5.353.exit": ; preds = %loop_body.4.i
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %56, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %57, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %170 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %171 = tail call ptr @heap_alloc(i64 5)
  %172 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %172, align 1
  br label %__barray_check_bounds.exit.i

mask_block_err.i.i.i:                             ; preds = %loop_body.4.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.4.i, %loop_body.2.i, %loop_body.1.i, %loop_body.i, %__barray_mask_return.exit632.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.i": ; preds = %__barray_mask_return.exit632.4
  %173 = or disjoint i64 %58, 1
  store i64 %173, ptr %1, align 4
  %174 = load i64, ptr %0, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %174)
  tail call void @___qfree(i64 %174)
  %175 = load i64, ptr %57, align 4
  %176 = trunc i64 %175 to i1
  br i1 %176, label %loop_body.i, label %panic.i.i646

panic.i.i646:                                     ; preds = %__barray_check_bounds.exit.4.i, %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.3.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.2.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.1.i", %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.i"
  %177 = and i64 %175, -2
  store i64 %177, ptr %57, align 4
  store i64 %lazy_measure.i, ptr %56, align 4
  %178 = load i64, ptr %1, align 4
  %179 = and i64 %178, 2
  %.not = icmp eq i64 %179, 0
  br i1 %.not, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.1.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.1.i": ; preds = %loop_body.i
  %180 = or disjoint i64 %178, 2
  store i64 %180, ptr %1, align 4
  %181 = load i64, ptr %8, align 4
  %lazy_measure.1.i = tail call i64 @___lazy_measure(i64 %181)
  tail call void @___qfree(i64 %181)
  %182 = load i64, ptr %57, align 4
  %183 = and i64 %182, 2
  %.not.i = icmp eq i64 %183, 0
  br i1 %.not.i, label %panic.i.i646, label %loop_body.1.i

loop_body.1.i:                                    ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.1.i"
  %184 = and i64 %182, -3
  store i64 %184, ptr %57, align 4
  %185 = getelementptr inbounds nuw i8, ptr %56, i64 8
  store i64 %lazy_measure.1.i, ptr %185, align 4
  %186 = load i64, ptr %1, align 4
  %187 = and i64 %186, 4
  %.not681 = icmp eq i64 %187, 0
  br i1 %.not681, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.2.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.2.i": ; preds = %loop_body.1.i
  %188 = or disjoint i64 %186, 4
  store i64 %188, ptr %1, align 4
  %189 = load i64, ptr %12, align 4
  %lazy_measure.2.i = tail call i64 @___lazy_measure(i64 %189)
  tail call void @___qfree(i64 %189)
  %190 = load i64, ptr %57, align 4
  %191 = and i64 %190, 4
  %.not182.i = icmp eq i64 %191, 0
  br i1 %.not182.i, label %panic.i.i646, label %loop_body.2.i

loop_body.2.i:                                    ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.2.i"
  %192 = and i64 %190, -5
  store i64 %192, ptr %57, align 4
  %193 = getelementptr inbounds nuw i8, ptr %56, i64 16
  store i64 %lazy_measure.2.i, ptr %193, align 4
  %194 = load i64, ptr %1, align 4
  %195 = and i64 %194, 8
  %.not682 = icmp eq i64 %195, 0
  br i1 %.not682, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.3.i", label %panic.i.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.3.i": ; preds = %loop_body.2.i
  %196 = or disjoint i64 %194, 8
  store i64 %196, ptr %1, align 4
  %197 = load i64, ptr %16, align 4
  %lazy_measure.3.i = tail call i64 @___lazy_measure(i64 %197)
  tail call void @___qfree(i64 %197)
  %198 = load i64, ptr %57, align 4
  %199 = and i64 %198, 8
  %.not183.i = icmp eq i64 %199, 0
  br i1 %.not183.i, label %panic.i.i646, label %__barray_check_bounds.exit.i.4.i

__barray_check_bounds.exit.i.4.i:                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$qubit&5.477.exit.thread.3.i"
  %200 = and i64 %198, -9
  store i64 %200, ptr %57, align 4
  %201 = getelementptr inbounds nuw i8, ptr %56, i64 24
  store i64 %lazy_measure.3.i, ptr %201, align 4
  %202 = load i64, ptr %1, align 4
  %203 = and i64 %202, 16
  %.not683 = icmp eq i64 %203, 0
  br i1 %.not683, label %__barray_check_bounds.exit.4.i, label %panic.i.i.i

__barray_check_bounds.exit.4.i:                   ; preds = %__barray_check_bounds.exit.i.4.i
  %204 = or disjoint i64 %202, 16
  store i64 %204, ptr %1, align 4
  %205 = load i64, ptr %20, align 4
  %lazy_measure.4.i = tail call i64 @___lazy_measure(i64 %205)
  tail call void @___qfree(i64 %205)
  %206 = load i64, ptr %57, align 4
  %207 = and i64 %206, 16
  %.not184.i = icmp eq i64 %207, 0
  br i1 %.not184.i, label %panic.i.i646, label %loop_body.4.i

loop_body.4.i:                                    ; preds = %__barray_check_bounds.exit.4.i
  %208 = and i64 %206, -17
  store i64 %208, ptr %57, align 4
  %209 = getelementptr inbounds nuw i8, ptr %56, i64 32
  store i64 %lazy_measure.4.i, ptr %209, align 4
  %210 = load i64, ptr %1, align 4
  %211 = or i64 %210, -32
  store i64 %211, ptr %1, align 4
  %212 = icmp eq i64 %211, -1
  br i1 %212, label %"__hugr__.guppylang.std.quantum.measure_array$5.353.exit", label %mask_block_err.i.i.i
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare i64 @get_current_shot() local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare i32 @random_int() local_unnamed_addr

declare double @random_float() local_unnamed_addr

declare void @print_float(ptr, i64, double) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @random_seed(i64) local_unnamed_addr

declare void @___rp(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

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

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
