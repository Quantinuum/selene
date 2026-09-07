; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@e_Option.unw.32D4E82D.0 = private constant [43 x i8] c"*EXIT:INT:Option.unwrap: value is `Nothing`"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_head_leake.F4F32972.0 = private constant [21 x i8] c"\14USER:INT:head_leaked"
@res_head.AFE8E005.0 = private constant [15 x i8] c"\0EUSER:BOOL:head"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_tail.AD5A440E.0 = private constant [18 x i8] c"\11USER:BOOLARR:tail"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 20)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %2 = tail call ptr @heap_alloc(i64 160)
  %3 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %3, align 1
  %4 = tail call ptr @heap_alloc(i64 160)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_474_case_0.i, label %__hugr__.__tk2_helios_qalloc.470.exit

cond_474_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.470.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rxy(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18)
  br label %loop_body

loop_body:                                        ; preds = %cond_exit_13, %__hugr__.__tk2_helios_qalloc.470.exit
  %"9_2.0" = phi i64 [ 0, %__hugr__.__tk2_helios_qalloc.470.exit ], [ %"2107.0", %cond_exit_13 ]
  %"9_0.sroa.0.0" = phi i64 [ 0, %__hugr__.__tk2_helios_qalloc.470.exit ], [ %7, %cond_exit_13 ]
  %6 = icmp samesign ugt i64 %"9_0.sroa.0.0", 19
  %7 = add nuw nsw i64 %"9_0.sroa.0.0", 1
  br i1 %6, label %cond_exit_13, label %cond_13_case_1

cond_13_case_1:                                   ; preds = %loop_body
  %8 = add i64 %"9_2.0", 1
  %qalloc.i1214 = tail call i64 @___qalloc()
  %not_max.not.not.i1215 = icmp eq i64 %qalloc.i1214, -1
  br i1 %not_max.not.not.i1215, label %cond_474_case_0.i1216, label %__hugr__.__tk2_helios_qalloc.470.exit1217

cond_474_case_0.i1216:                            ; preds = %cond_13_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.470.exit1217:        ; preds = %cond_13_case_1
  tail call void @___reset(i64 %qalloc.i1214)
  %9 = icmp ult i64 %"9_2.0", 20
  br i1 %9, label %__barray_check_bounds.exit, label %out_of_bounds.i

out_of_bounds.i:                                  ; preds = %__hugr__.__tk2_helios_qalloc.470.exit1217
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %__hugr__.__tk2_helios_qalloc.470.exit1217
  %10 = load i64, ptr %5, align 4
  %11 = lshr i64 %10, %"9_2.0"
  %12 = trunc i64 %11 to i1
  br i1 %12, label %__barray_mask_return.exit, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit
  %13 = shl nuw nsw i64 1, %"9_2.0"
  %14 = xor i64 %10, %13
  store i64 %14, ptr %5, align 4
  %15 = getelementptr inbounds nuw i64, ptr %4, i64 %"9_2.0"
  store i64 %qalloc.i1214, ptr %15, align 4
  br label %cond_exit_13

cond_exit_13:                                     ; preds = %loop_body, %__barray_mask_return.exit
  %"2107.0" = phi i64 [ %8, %__barray_mask_return.exit ], [ %"9_2.0", %loop_body ]
  %exitcond = icmp eq i64 %7, 21
  br i1 %exitcond, label %__barray_check_bounds.exit1219, label %loop_body

__barray_check_bounds.exit1219:                   ; preds = %cond_exit_13, %__barray_mask_return.exit1224
  %16 = phi i64 [ %28, %__barray_mask_return.exit1224 ], [ 1, %cond_exit_13 ]
  %"114_0.01276" = phi i64 [ %16, %__barray_mask_return.exit1224 ], [ 0, %cond_exit_13 ]
  %17 = load i64, ptr %5, align 4
  %18 = lshr i64 %17, %"114_0.01276"
  %19 = trunc i64 %18 to i1
  br i1 %19, label %panic.i1220, label %__barray_check_bounds.exit1222

panic.i1220:                                      ; preds = %__barray_check_bounds.exit1219
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1222:                   ; preds = %__barray_check_bounds.exit1219
  %20 = shl nuw nsw i64 1, %"114_0.01276"
  %21 = xor i64 %17, %20
  store i64 %21, ptr %5, align 4
  %22 = getelementptr inbounds nuw i64, ptr %4, i64 %"114_0.01276"
  %23 = load i64, ptr %22, align 4
  tail call void @___rxy(i64 %23, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %qalloc.i, i64 %23, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %23, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %23, double 0xBFF921FB54442D18)
  %24 = load i64, ptr %5, align 4
  %25 = lshr i64 %24, %"114_0.01276"
  %26 = trunc i64 %25 to i1
  br i1 %26, label %__barray_mask_return.exit1224, label %panic.i1223

panic.i1223:                                      ; preds = %__barray_check_bounds.exit1222
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1224:                    ; preds = %__barray_check_bounds.exit1222
  %27 = xor i64 %24, %20
  store i64 %27, ptr %5, align 4
  store i64 %23, ptr %22, align 4
  %28 = add nuw nsw i64 %16, 1
  %exitcond1279 = icmp eq i64 %28, 21
  br i1 %exitcond1279, label %cond_exit_185, label %__barray_check_bounds.exit1219

cond_exit_185:                                    ; preds = %__barray_mask_return.exit1224
  %___lazy_measure_leaked = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___inc_future_refcount(i64 %___lazy_measure_leaked)
  %read_uint = tail call i64 @___read_future_uint(i64 %___lazy_measure_leaked)
  tail call void @___dec_future_refcount(i64 %___lazy_measure_leaked)
  %29 = icmp eq i64 %read_uint, 2
  br i1 %29, label %30, label %cond_exit_256

cond_exit_256:                                    ; preds = %cond_exit_185
  %read_uint350 = tail call i64 @___read_future_uint(i64 %___lazy_measure_leaked)
  tail call void @___dec_future_refcount(i64 %___lazy_measure_leaked)
  %.not = icmp eq i64 %read_uint350, 2
  br i1 %.not, label %cond_236_case_0, label %cond_236_case_1

30:                                               ; preds = %cond_exit_185
  tail call void @___dec_future_refcount(i64 %___lazy_measure_leaked)
  tail call void @print_int(ptr nonnull @res_head_leake.F4F32972.0, i64 20, i64 1)
  br label %__barray_check_bounds.exit1230.preheader

__barray_check_bounds.exit1230.preheader:         ; preds = %cond_236_case_1, %30
  br label %__barray_check_bounds.exit1230

cond_236_case_1:                                  ; preds = %cond_exit_256
  %31 = icmp eq i64 %read_uint350, 1
  tail call void @print_bool(ptr nonnull @res_head.AFE8E005.0, i64 14, i1 %31)
  br label %__barray_check_bounds.exit1230.preheader

cond_236_case_0:                                  ; preds = %cond_exit_256
  tail call void @panic(i32 1001, ptr nonnull @e_Option.unw.32D4E82D.0)
  unreachable

out_of_bounds.i1225:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1226:                   ; preds = %.thread
  %32 = load i64, ptr %3, align 4
  %33 = lshr i64 %32, %"298_2.01283"
  %34 = trunc i64 %33 to i1
  br i1 %34, label %cond_exit_302, label %panic.i1227

panic.i1227:                                      ; preds = %__barray_check_bounds.exit1226
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_302
  %35 = load i64, ptr %5, align 4
  %36 = or i64 %35, -1048576
  store i64 %36, ptr %5, align 4
  %37 = icmp eq i64 %36, -1
  br i1 %37, label %loop_body510.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1230:                   ; preds = %__barray_check_bounds.exit1230.preheader, %cond_exit_302
  %"298_0.sroa.15.01284" = phi i64 [ %38, %cond_exit_302 ], [ 0, %__barray_check_bounds.exit1230.preheader ]
  %"298_2.01283" = phi i64 [ %46, %cond_exit_302 ], [ 0, %__barray_check_bounds.exit1230.preheader ]
  %38 = add nuw nsw i64 %"298_0.sroa.15.01284", 1
  %39 = load i64, ptr %5, align 4
  %40 = lshr i64 %39, %"298_0.sroa.15.01284"
  %41 = trunc i64 %40 to i1
  br i1 %41, label %panic.i1231, label %.thread

panic.i1231:                                      ; preds = %__barray_check_bounds.exit1230
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_check_bounds.exit1230
  %42 = shl nuw nsw i64 1, %"298_0.sroa.15.01284"
  %43 = xor i64 %39, %42
  store i64 %43, ptr %5, align 4
  %44 = getelementptr inbounds nuw i64, ptr %4, i64 %"298_0.sroa.15.01284"
  %45 = load i64, ptr %44, align 4
  %46 = add i64 %"298_2.01283", 1
  %___lazy_measure = tail call i64 @___lazy_measure(i64 %45)
  tail call void @___qfree(i64 %45)
  %47 = icmp ult i64 %"298_2.01283", 20
  br i1 %47, label %__barray_check_bounds.exit1226, label %out_of_bounds.i1225

cond_exit_302:                                    ; preds = %__barray_check_bounds.exit1226
  %48 = shl nuw nsw i64 1, %"298_2.01283"
  %49 = xor i64 %32, %48
  store i64 %49, ptr %3, align 4
  %50 = getelementptr inbounds nuw i64, ptr %2, i64 %"298_2.01283"
  store i64 %___lazy_measure, ptr %50, align 4
  %51 = icmp samesign ugt i64 %"298_0.sroa.15.01284", 18
  br i1 %51, label %mask_block_ok.i, label %__barray_check_bounds.exit1230

loop_body510.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  br label %__barray_check_bounds.exit1234

__barray_check_bounds.exit1234:                   ; preds = %cond_exit_368, %loop_body510.preheader.preheader
  %"364_0.sroa.15.01278" = phi i64 [ %52, %cond_exit_368 ], [ 0, %loop_body510.preheader.preheader ]
  %52 = add nuw nsw i64 %"364_0.sroa.15.01278", 1
  %53 = load i64, ptr %3, align 4
  %54 = lshr i64 %53, %"364_0.sroa.15.01278"
  %55 = trunc i64 %54 to i1
  br i1 %55, label %panic.i1235, label %__barray_check_bounds.exit1238

panic.i1235:                                      ; preds = %__barray_check_bounds.exit1234
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1238:                   ; preds = %__barray_check_bounds.exit1234
  %56 = shl nuw nsw i64 1, %"364_0.sroa.15.01278"
  %57 = xor i64 %53, %56
  store i64 %57, ptr %3, align 4
  %58 = getelementptr inbounds nuw i64, ptr %2, i64 %"364_0.sroa.15.01278"
  %59 = load i64, ptr %58, align 4
  tail call void @___inc_future_refcount(i64 %59)
  %60 = load i64, ptr %3, align 4
  %61 = lshr i64 %60, %"364_0.sroa.15.01278"
  %62 = trunc i64 %61 to i1
  br i1 %62, label %__barray_check_bounds.exit1242, label %panic.i1239

panic.i1239:                                      ; preds = %__barray_check_bounds.exit1238
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1242:                   ; preds = %__barray_check_bounds.exit1238
  %63 = xor i64 %60, %56
  store i64 %63, ptr %3, align 4
  store i64 %59, ptr %58, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %59)
  tail call void @___dec_future_refcount(i64 %59)
  %64 = load i64, ptr %1, align 4
  %65 = lshr i64 %64, %"364_0.sroa.15.01278"
  %66 = trunc i64 %65 to i1
  br i1 %66, label %cond_exit_368, label %panic.i1243

panic.i1243:                                      ; preds = %__barray_check_bounds.exit1242
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_550_case_0:                                  ; preds = %cond_exit_550
  %67 = load i64, ptr %3, align 4
  %68 = or i64 %67, -1048576
  store i64 %68, ptr %3, align 4
  %69 = icmp eq i64 %68, -1
  br i1 %69, label %loop_out509, label %mask_block_err.i1248

mask_block_err.i1248:                             ; preds = %cond_550_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1252:                   ; preds = %cond_exit_368, %cond_exit_550
  %"547_0.01285" = phi i64 [ %70, %cond_exit_550 ], [ 0, %cond_exit_368 ]
  %70 = add nuw nsw i64 %"547_0.01285", 1
  %71 = load i64, ptr %3, align 4
  %72 = lshr i64 %71, %"547_0.01285"
  %73 = trunc i64 %72 to i1
  br i1 %73, label %cond_exit_550, label %__barray_mask_borrow.exit1256

__barray_mask_borrow.exit1256:                    ; preds = %__barray_check_bounds.exit1252
  %74 = shl nuw nsw i64 1, %"547_0.01285"
  %75 = xor i64 %71, %74
  store i64 %75, ptr %3, align 4
  %76 = getelementptr inbounds nuw i64, ptr %2, i64 %"547_0.01285"
  %77 = load i64, ptr %76, align 4
  tail call void @___dec_future_refcount(i64 %77)
  br label %cond_exit_550

cond_exit_550:                                    ; preds = %__barray_mask_borrow.exit1256, %__barray_check_bounds.exit1252
  %78 = icmp samesign ugt i64 %"547_0.01285", 18
  br i1 %78, label %cond_550_case_0, label %__barray_check_bounds.exit1252

cond_exit_368:                                    ; preds = %__barray_check_bounds.exit1242
  %79 = xor i64 %64, %56
  store i64 %79, ptr %1, align 4
  %80 = getelementptr inbounds nuw i1, ptr %0, i64 %"364_0.sroa.15.01278"
  store i1 %read_bool, ptr %80, align 1
  %81 = icmp eq i64 %"364_0.sroa.15.01278", 19
  br i1 %81, label %__barray_check_bounds.exit1252, label %__barray_check_bounds.exit1234

loop_out509:                                      ; preds = %cond_550_case_0
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %82 = load i64, ptr %1, align 4
  %83 = and i64 %82, 1048575
  store i64 %83, ptr %1, align 4
  %84 = icmp eq i64 %83, 0
  br i1 %84, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1257

mask_block_err.i1257:                             ; preds = %loop_out509
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out509
  %85 = tail call ptr @heap_alloc(i64 20)
  %86 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %86, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %85, ptr noundef nonnull align 1 dereferenceable(20) %0, i64 20, i1 false)
  tail call void @heap_free(ptr nonnull %85)
  %87 = load i64, ptr %1, align 4
  %88 = and i64 %87, 1048575
  store i64 %88, ptr %1, align 4
  %89 = icmp eq i64 %88, 0
  br i1 %89, label %__barray_check_none_borrowed.exit1261, label %mask_block_err.i1259

mask_block_err.i1259:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1261:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %90 = alloca [20 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %90, i8 0, i64 20, i1 false)
  store i32 20, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %90, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_tail.AD5A440E.0, i64 17, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare i64 @___lazy_measure_leaked(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare i64 @___read_future_uint(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

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
