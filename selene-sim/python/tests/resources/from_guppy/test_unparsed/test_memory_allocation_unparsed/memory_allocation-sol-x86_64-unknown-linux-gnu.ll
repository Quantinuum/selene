; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 70)
  %1 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %1, i8 -1, i64 16, i1 false)
  %2 = tail call ptr @heap_alloc(i64 560)
  %3 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %3, i8 -1, i64 16, i1 false)
  %4 = tail call ptr @heap_alloc(i64 560)
  %5 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %5, i8 -1, i64 16, i1 false)
  br label %loop_body

loop_body:                                        ; preds = %cond_exit_132, %alloca_block
  %"128_2.0" = phi i64 [ 0, %alloca_block ], [ %"2109.0", %cond_exit_132 ]
  %"128_0.sroa.0.0" = phi i64 [ 0, %alloca_block ], [ %7, %cond_exit_132 ]
  %6 = icmp samesign ugt i64 %"128_0.sroa.0.0", 69
  %7 = add nuw nsw i64 %"128_0.sroa.0.0", 1
  br i1 %6, label %cond_exit_132, label %cond_132_case_1

cond_132_case_1:                                  ; preds = %loop_body
  %8 = add i64 %"128_2.0", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_436_case_0.i, label %__hugr__.__tk2_sol_qalloc.432.exit

cond_436_case_0.i:                                ; preds = %cond_132_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.432.exit:               ; preds = %cond_132_case_1
  tail call void @___reset(i64 %qalloc.i)
  %9 = icmp ult i64 %"128_2.0", 70
  br i1 %9, label %__barray_check_bounds.exit, label %out_of_bounds.i

out_of_bounds.i:                                  ; preds = %__hugr__.__tk2_sol_qalloc.432.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %__hugr__.__tk2_sol_qalloc.432.exit
  %10 = lshr i64 %"128_2.0", 6
  %11 = getelementptr inbounds nuw i64, ptr %5, i64 %10
  %12 = load i64, ptr %11, align 4
  %13 = and i64 %"128_2.0", 63
  %14 = lshr i64 %12, %13
  %15 = trunc i64 %14 to i1
  br i1 %15, label %__barray_mask_return.exit, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit
  %16 = shl nuw i64 1, %13
  %17 = xor i64 %12, %16
  store i64 %17, ptr %11, align 4
  %18 = getelementptr inbounds nuw i64, ptr %4, i64 %"128_2.0"
  store i64 %qalloc.i, ptr %18, align 4
  br label %cond_exit_132

cond_exit_132:                                    ; preds = %loop_body, %__barray_mask_return.exit
  %"2109.0" = phi i64 [ %8, %__barray_mask_return.exit ], [ %"128_2.0", %loop_body ]
  %exitcond = icmp eq i64 %7, 71
  br i1 %exitcond, label %finish, label %loop_body

loop_body394.preheader:                           ; preds = %loop_out
  %19 = getelementptr i8, ptr %5, i64 8
  br label %__barray_check_bounds.exit1285

loop_out:                                         ; preds = %finish, %__barray_mask_return.exit1279
  %20 = add nuw nsw i64 %21, 1
  %exitcond1335 = icmp eq i64 %20, 71
  br i1 %exitcond1335, label %loop_body394.preheader, label %finish

finish:                                           ; preds = %cond_exit_132, %loop_out
  %21 = phi i64 [ %20, %loop_out ], [ 1, %cond_exit_132 ]
  %"6_0.01332" = phi i64 [ %21, %loop_out ], [ 0, %cond_exit_132 ]
  %remainder.urem = and i64 %"6_0.01332", 1
  %22 = icmp eq i64 %remainder.urem, 0
  br i1 %22, label %__barray_check_bounds.exit1274, label %loop_out

__barray_check_bounds.exit1274:                   ; preds = %finish
  %23 = lshr i64 %"6_0.01332", 6
  %24 = getelementptr inbounds nuw i64, ptr %5, i64 %23
  %25 = load i64, ptr %24, align 4
  %26 = and i64 %"6_0.01332", 62
  %27 = lshr i64 %25, %26
  %28 = trunc i64 %27 to i1
  br i1 %28, label %panic.i1275, label %__barray_check_bounds.exit1277

panic.i1275:                                      ; preds = %__barray_check_bounds.exit1274
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1277:                   ; preds = %__barray_check_bounds.exit1274
  %29 = shl nuw nsw i64 1, %26
  %30 = xor i64 %25, %29
  store i64 %30, ptr %24, align 4
  %31 = getelementptr inbounds nuw i64, ptr %4, i64 %"6_0.01332"
  %32 = load i64, ptr %31, align 4
  tail call void @___rp(i64 %32, double 0x400921FB54442D18, double 0.000000e+00)
  %33 = load i64, ptr %24, align 4
  %34 = lshr i64 %33, %26
  %35 = trunc i64 %34 to i1
  br i1 %35, label %__barray_mask_return.exit1279, label %panic.i1278

panic.i1278:                                      ; preds = %__barray_check_bounds.exit1277
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1279:                    ; preds = %__barray_check_bounds.exit1277
  %36 = xor i64 %33, %29
  store i64 %36, ptr %24, align 4
  store i64 %32, ptr %31, align 4
  br label %loop_out

out_of_bounds.i1280:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1281:                   ; preds = %.thread
  %37 = lshr i64 %"251_2.01341", 6
  %38 = getelementptr inbounds nuw i64, ptr %3, i64 %37
  %39 = load i64, ptr %38, align 4
  %40 = and i64 %"251_2.01341", 63
  %41 = lshr i64 %39, %40
  %42 = trunc i64 %41 to i1
  br i1 %42, label %cond_exit_255, label %panic.i1282

panic.i1282:                                      ; preds = %__barray_check_bounds.exit1281
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_255
  %43 = load i64, ptr %19, align 4
  %44 = or i64 %43, -64
  store i64 %44, ptr %19, align 4
  %45 = load i64, ptr %5, align 4
  %46 = icmp eq i64 %45, -1
  %47 = icmp eq i64 %44, -1
  %or.cond = select i1 %46, i1 %47, i1 false
  br i1 %or.cond, label %loop_body503.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1285:                   ; preds = %loop_body394.preheader, %cond_exit_255
  %"251_0.sroa.15.01342" = phi i64 [ 0, %loop_body394.preheader ], [ %48, %cond_exit_255 ]
  %"251_2.01341" = phi i64 [ 0, %loop_body394.preheader ], [ %59, %cond_exit_255 ]
  %48 = add nuw nsw i64 %"251_0.sroa.15.01342", 1
  %49 = lshr i64 %"251_0.sroa.15.01342", 6
  %50 = getelementptr inbounds nuw i64, ptr %5, i64 %49
  %51 = load i64, ptr %50, align 4
  %52 = and i64 %"251_0.sroa.15.01342", 63
  %53 = lshr i64 %51, %52
  %54 = trunc i64 %53 to i1
  br i1 %54, label %panic.i1286, label %.thread

panic.i1286:                                      ; preds = %__barray_check_bounds.exit1285
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_check_bounds.exit1285
  %55 = shl nuw i64 1, %52
  %56 = xor i64 %51, %55
  store i64 %56, ptr %50, align 4
  %57 = getelementptr inbounds nuw i64, ptr %4, i64 %"251_0.sroa.15.01342"
  %58 = load i64, ptr %57, align 4
  %59 = add i64 %"251_2.01341", 1
  %___future_measure = tail call i64 @___future_measure(i64 %58, i64 0)
  tail call void @___qfree(i64 %58)
  %60 = icmp ult i64 %"251_2.01341", 70
  br i1 %60, label %__barray_check_bounds.exit1281, label %out_of_bounds.i1280

cond_exit_255:                                    ; preds = %__barray_check_bounds.exit1281
  %61 = shl nuw i64 1, %40
  %62 = xor i64 %39, %61
  store i64 %62, ptr %38, align 4
  %63 = getelementptr inbounds nuw i64, ptr %2, i64 %"251_2.01341"
  store i64 %___future_measure, ptr %63, align 4
  %64 = icmp samesign ugt i64 %"251_0.sroa.15.01342", 68
  br i1 %64, label %mask_block_ok.i, label %__barray_check_bounds.exit1285

loop_body503.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr %4)
  tail call void @heap_free(ptr nonnull %5)
  br label %__barray_check_bounds.exit1289

loop_body607.preheader:                           ; preds = %cond_exit_321
  %65 = getelementptr i8, ptr %3, i64 8
  br label %__barray_check_bounds.exit1307

__barray_check_bounds.exit1289:                   ; preds = %cond_exit_321, %loop_body503.preheader.preheader
  %"317_0.sroa.15.01334" = phi i64 [ %66, %cond_exit_321 ], [ 0, %loop_body503.preheader.preheader ]
  %66 = add nuw nsw i64 %"317_0.sroa.15.01334", 1
  %67 = lshr i64 %"317_0.sroa.15.01334", 6
  %68 = getelementptr inbounds nuw i64, ptr %3, i64 %67
  %69 = load i64, ptr %68, align 4
  %70 = and i64 %"317_0.sroa.15.01334", 63
  %71 = lshr i64 %69, %70
  %72 = trunc i64 %71 to i1
  br i1 %72, label %panic.i1290, label %__barray_check_bounds.exit1293

panic.i1290:                                      ; preds = %__barray_check_bounds.exit1289
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1293:                   ; preds = %__barray_check_bounds.exit1289
  %73 = shl nuw i64 1, %70
  %74 = xor i64 %69, %73
  store i64 %74, ptr %68, align 4
  %75 = getelementptr inbounds nuw i64, ptr %2, i64 %"317_0.sroa.15.01334"
  %76 = load i64, ptr %75, align 4
  tail call void @___inc_future_refcount(i64 %76)
  %77 = load i64, ptr %68, align 4
  %78 = lshr i64 %77, %70
  %79 = trunc i64 %78 to i1
  br i1 %79, label %__barray_check_bounds.exit1297, label %panic.i1294

panic.i1294:                                      ; preds = %__barray_check_bounds.exit1293
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1297:                   ; preds = %__barray_check_bounds.exit1293
  %80 = xor i64 %77, %73
  store i64 %80, ptr %68, align 4
  store i64 %76, ptr %75, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %76)
  tail call void @___dec_future_refcount(i64 %76)
  %81 = getelementptr inbounds nuw i64, ptr %1, i64 %67
  %82 = load i64, ptr %81, align 4
  %83 = lshr i64 %82, %70
  %84 = trunc i64 %83 to i1
  br i1 %84, label %cond_exit_321, label %panic.i1298

panic.i1298:                                      ; preds = %__barray_check_bounds.exit1297
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_482_case_0:                                  ; preds = %cond_exit_482
  %85 = load i64, ptr %65, align 4
  %86 = or i64 %85, -64
  store i64 %86, ptr %65, align 4
  %87 = load i64, ptr %3, align 4
  %88 = icmp eq i64 %87, -1
  %89 = icmp eq i64 %86, -1
  %or.cond1340 = select i1 %88, i1 %89, i1 false
  br i1 %or.cond1340, label %loop_out502, label %mask_block_err.i1303

mask_block_err.i1303:                             ; preds = %cond_482_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1307:                   ; preds = %loop_body607.preheader, %cond_exit_482
  %"479_0.01343" = phi i64 [ 0, %loop_body607.preheader ], [ %90, %cond_exit_482 ]
  %90 = add nuw nsw i64 %"479_0.01343", 1
  %91 = lshr i64 %"479_0.01343", 6
  %92 = getelementptr inbounds nuw i64, ptr %3, i64 %91
  %93 = load i64, ptr %92, align 4
  %94 = and i64 %"479_0.01343", 63
  %95 = lshr i64 %93, %94
  %96 = trunc i64 %95 to i1
  br i1 %96, label %cond_exit_482, label %__barray_mask_borrow.exit1311

__barray_mask_borrow.exit1311:                    ; preds = %__barray_check_bounds.exit1307
  %97 = shl nuw i64 1, %94
  %98 = xor i64 %93, %97
  store i64 %98, ptr %92, align 4
  %99 = getelementptr inbounds nuw i64, ptr %2, i64 %"479_0.01343"
  %100 = load i64, ptr %99, align 4
  tail call void @___dec_future_refcount(i64 %100)
  br label %cond_exit_482

cond_exit_482:                                    ; preds = %__barray_mask_borrow.exit1311, %__barray_check_bounds.exit1307
  %101 = icmp samesign ugt i64 %"479_0.01343", 68
  br i1 %101, label %cond_482_case_0, label %__barray_check_bounds.exit1307

cond_exit_321:                                    ; preds = %__barray_check_bounds.exit1297
  %102 = xor i64 %82, %73
  store i64 %102, ptr %81, align 4
  %103 = getelementptr inbounds nuw i1, ptr %0, i64 %"317_0.sroa.15.01334"
  store i1 %read_bool, ptr %103, align 1
  %104 = icmp eq i64 %"317_0.sroa.15.01334", 69
  br i1 %104, label %loop_body607.preheader, label %__barray_check_bounds.exit1289

loop_out502:                                      ; preds = %cond_482_case_0
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %105 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %106 = load i64, ptr %105, align 4
  %107 = and i64 %106, 63
  store i64 %107, ptr %105, align 4
  %108 = load i64, ptr %1, align 4
  %109 = icmp eq i64 %108, 0
  %110 = icmp eq i64 %107, 0
  %or.cond.i = select i1 %109, i1 %110, i1 false
  br i1 %or.cond.i, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1313

mask_block_err.i1313:                             ; preds = %loop_out502
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out502
  %111 = tail call ptr @heap_alloc(i64 70)
  %112 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %112, i8 0, i64 16, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(70) %111, ptr noundef nonnull align 1 dereferenceable(70) %0, i64 70, i1 false)
  tail call void @heap_free(ptr nonnull %111)
  %113 = load i64, ptr %105, align 4
  %114 = and i64 %113, 63
  store i64 %114, ptr %105, align 4
  %115 = load i64, ptr %1, align 4
  %116 = icmp eq i64 %115, 0
  %117 = icmp eq i64 %114, 0
  %or.cond.i1315 = select i1 %116, i1 %117, i1 false
  br i1 %or.cond.i1315, label %__barray_check_none_borrowed.exit1317, label %mask_block_err.i1316

mask_block_err.i1316:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1317:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %118 = alloca [70 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(70) %118, i8 0, i64 70, i1 false)
  store i32 70, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %118, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare void @heap_free(ptr) local_unnamed_addr

declare i64 @___future_measure(i64, i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

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
