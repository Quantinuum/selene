; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@e_Option.unw.32D4E82D.0 = private constant [43 x i8] c"*EXIT:INT:Option.unwrap: value is `Nothing`"
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
  br i1 %not_max.not.not.i, label %cond_489_case_0.i, label %__hugr__.__tk2_helios_qalloc.485.exit

cond_489_case_0.i:                                ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.485.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  tail call void @___rxy(i64 %qalloc.i, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0x400921FB54442D18)
  br label %cond_13_case_1

cond_13_case_1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.485.exit, %cond_exit_13
  %"9_2.01321" = phi i64 [ 0, %__hugr__.__tk2_helios_qalloc.485.exit ], [ %6, %cond_exit_13 ]
  %6 = add nuw nsw i64 %"9_2.01321", 1
  %qalloc.i1244 = tail call i64 @___qalloc()
  %not_max.not.not.i1245 = icmp eq i64 %qalloc.i1244, -1
  br i1 %not_max.not.not.i1245, label %cond_489_case_0.i1246, label %__barray_check_bounds.exit

cond_489_case_0.i1246:                            ; preds = %cond_13_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_13_case_1
  tail call void @___reset(i64 %qalloc.i1244)
  %7 = load i64, ptr %5, align 4
  %8 = lshr i64 %7, %"9_2.01321"
  %9 = trunc i64 %8 to i1
  br i1 %9, label %cond_exit_13, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_13:                                     ; preds = %__barray_check_bounds.exit
  %10 = shl nuw nsw i64 1, %"9_2.01321"
  %11 = xor i64 %7, %10
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i64, ptr %4, i64 %"9_2.01321"
  store i64 %qalloc.i1244, ptr %12, align 4
  %exitcond = icmp eq i64 %6, 20
  br i1 %exitcond, label %loop_out, label %cond_13_case_1

loop_out:                                         ; preds = %cond_exit_13
  %13 = load i64, ptr %5, align 4
  %14 = trunc i64 %13 to i1
  br i1 %14, label %panic.i1248, label %__barray_mask_borrow.exit

panic.i1248:                                      ; preds = %loop_out
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %loop_out
  %15 = or disjoint i64 %13, 1
  store i64 %15, ptr %5, align 4
  %16 = load i64, ptr %4, align 4
  tail call void @___rxy(i64 %16, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %qalloc.i, i64 %16, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %qalloc.i, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %16, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %16, double 0xBFF921FB54442D18)
  %17 = load i64, ptr %5, align 4
  %18 = trunc i64 %17 to i1
  br i1 %18, label %__barray_mask_return.exit1250, label %panic.i1249

panic.i1249:                                      ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1250:                    ; preds = %__barray_mask_borrow.exit
  %19 = and i64 %17, -2
  store i64 %19, ptr %5, align 4
  store i64 %16, ptr %4, align 4
  br label %__barray_check_bounds.exit1252

__barray_check_bounds.exit1252:                   ; preds = %__barray_mask_return.exit1250, %__barray_mask_return.exit1268
  %20 = phi i64 [ 1, %__barray_mask_return.exit1250 ], [ %42, %__barray_mask_return.exit1268 ]
  %"118_0.01322" = phi i64 [ 0, %__barray_mask_return.exit1250 ], [ %20, %__barray_mask_return.exit1268 ]
  %21 = load i64, ptr %5, align 4
  %22 = lshr i64 %21, %"118_0.01322"
  %23 = trunc i64 %22 to i1
  br i1 %23, label %panic.i1253, label %__barray_check_bounds.exit1256

panic.i1253:                                      ; preds = %__barray_check_bounds.exit1252
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1256:                   ; preds = %__barray_check_bounds.exit1252
  %24 = shl nuw nsw i64 1, %"118_0.01322"
  %25 = xor i64 %21, %24
  store i64 %25, ptr %5, align 4
  %26 = getelementptr inbounds nuw i64, ptr %4, i64 %"118_0.01322"
  %27 = load i64, ptr %26, align 4
  %28 = lshr i64 %25, %20
  %29 = trunc i64 %28 to i1
  br i1 %29, label %panic.i1257, label %__barray_check_bounds.exit1262

panic.i1257:                                      ; preds = %__barray_check_bounds.exit1256
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1262:                   ; preds = %__barray_check_bounds.exit1256
  %30 = shl nuw nsw i64 2, %"118_0.01322"
  %31 = xor i64 %25, %30
  store i64 %31, ptr %5, align 4
  %32 = getelementptr inbounds nuw i64, ptr %4, i64 %20
  %33 = load i64, ptr %32, align 4
  tail call void @___rxy(i64 %33, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %27, i64 %33, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %27, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %33, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %33, double 0xBFF921FB54442D18)
  %34 = load i64, ptr %5, align 4
  %35 = lshr i64 %34, %"118_0.01322"
  %36 = trunc i64 %35 to i1
  br i1 %36, label %__barray_check_bounds.exit1266, label %panic.i1263

panic.i1263:                                      ; preds = %__barray_check_bounds.exit1262
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1266:                   ; preds = %__barray_check_bounds.exit1262
  %37 = xor i64 %34, %24
  store i64 %37, ptr %5, align 4
  store i64 %27, ptr %26, align 4
  %38 = load i64, ptr %5, align 4
  %39 = lshr i64 %38, %20
  %40 = trunc i64 %39 to i1
  br i1 %40, label %__barray_mask_return.exit1268, label %panic.i1267

panic.i1267:                                      ; preds = %__barray_check_bounds.exit1266
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1268:                    ; preds = %__barray_check_bounds.exit1266
  %41 = xor i64 %38, %30
  store i64 %41, ptr %5, align 4
  store i64 %33, ptr %32, align 4
  %42 = add nuw nsw i64 %20, 1
  %exitcond1325 = icmp eq i64 %42, 20
  br i1 %exitcond1325, label %cond_exit_189, label %__barray_check_bounds.exit1252

cond_exit_189:                                    ; preds = %__barray_mask_return.exit1268
  %___lazy_measure_leaked = tail call i64 @___lazy_measure_leaked(i64 %qalloc.i)
  tail call void @___qfree(i64 %qalloc.i)
  tail call void @___inc_future_refcount(i64 %___lazy_measure_leaked)
  %read_uint = tail call i64 @___read_future_uint(i64 %___lazy_measure_leaked)
  tail call void @___dec_future_refcount(i64 %___lazy_measure_leaked)
  %43 = icmp eq i64 %read_uint, 2
  br i1 %43, label %44, label %cond_exit_267

cond_exit_267:                                    ; preds = %cond_exit_189
  %read_uint378 = tail call i64 @___read_future_uint(i64 %___lazy_measure_leaked)
  tail call void @___dec_future_refcount(i64 %___lazy_measure_leaked)
  %.not = icmp eq i64 %read_uint378, 2
  br i1 %.not, label %cond_247_case_0, label %cond_247_case_1

44:                                               ; preds = %cond_exit_189
  tail call void @___dec_future_refcount(i64 %___lazy_measure_leaked)
  tail call void @print_int(ptr nonnull @res_head_leake.F4F32972.0, i64 20, i64 1)
  br label %__barray_check_bounds.exit1274.preheader

__barray_check_bounds.exit1274.preheader:         ; preds = %cond_247_case_1, %44
  br label %__barray_check_bounds.exit1274

cond_247_case_1:                                  ; preds = %cond_exit_267
  %45 = icmp eq i64 %read_uint378, 1
  tail call void @print_bool(ptr nonnull @res_head.AFE8E005.0, i64 14, i1 %45)
  br label %__barray_check_bounds.exit1274.preheader

cond_247_case_0:                                  ; preds = %cond_exit_267
  tail call void @panic(i32 1001, ptr nonnull @e_Option.unw.32D4E82D.0)
  unreachable

out_of_bounds.i1269:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1270:                   ; preds = %.thread
  %46 = load i64, ptr %3, align 4
  %47 = lshr i64 %46, %"310_2.01329"
  %48 = trunc i64 %47 to i1
  br i1 %48, label %cond_exit_314, label %panic.i1271

panic.i1271:                                      ; preds = %__barray_check_bounds.exit1270
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_314
  %49 = load i64, ptr %5, align 4
  %50 = or i64 %49, -1048576
  store i64 %50, ptr %5, align 4
  %51 = icmp eq i64 %50, -1
  br i1 %51, label %loop_body538.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1274:                   ; preds = %__barray_check_bounds.exit1274.preheader, %cond_exit_314
  %"310_0.sroa.15.01330" = phi i64 [ %52, %cond_exit_314 ], [ 0, %__barray_check_bounds.exit1274.preheader ]
  %"310_2.01329" = phi i64 [ %60, %cond_exit_314 ], [ 0, %__barray_check_bounds.exit1274.preheader ]
  %52 = add nuw nsw i64 %"310_0.sroa.15.01330", 1
  %53 = load i64, ptr %5, align 4
  %54 = lshr i64 %53, %"310_0.sroa.15.01330"
  %55 = trunc i64 %54 to i1
  br i1 %55, label %panic.i1275, label %.thread

panic.i1275:                                      ; preds = %__barray_check_bounds.exit1274
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_check_bounds.exit1274
  %56 = shl nuw nsw i64 1, %"310_0.sroa.15.01330"
  %57 = xor i64 %53, %56
  store i64 %57, ptr %5, align 4
  %58 = getelementptr inbounds nuw i64, ptr %4, i64 %"310_0.sroa.15.01330"
  %59 = load i64, ptr %58, align 4
  %60 = add i64 %"310_2.01329", 1
  %___lazy_measure = tail call i64 @___lazy_measure(i64 %59)
  tail call void @___qfree(i64 %59)
  %61 = icmp ult i64 %"310_2.01329", 20
  br i1 %61, label %__barray_check_bounds.exit1270, label %out_of_bounds.i1269

cond_exit_314:                                    ; preds = %__barray_check_bounds.exit1270
  %62 = shl nuw nsw i64 1, %"310_2.01329"
  %63 = xor i64 %46, %62
  store i64 %63, ptr %3, align 4
  %64 = getelementptr inbounds nuw i64, ptr %2, i64 %"310_2.01329"
  store i64 %___lazy_measure, ptr %64, align 4
  %65 = icmp samesign ugt i64 %"310_0.sroa.15.01330", 18
  br i1 %65, label %mask_block_ok.i, label %__barray_check_bounds.exit1274

loop_body538.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  br label %__barray_check_bounds.exit1278

__barray_check_bounds.exit1278:                   ; preds = %cond_exit_380, %loop_body538.preheader.preheader
  %"376_0.sroa.15.01324" = phi i64 [ %66, %cond_exit_380 ], [ 0, %loop_body538.preheader.preheader ]
  %66 = add nuw nsw i64 %"376_0.sroa.15.01324", 1
  %67 = load i64, ptr %3, align 4
  %68 = lshr i64 %67, %"376_0.sroa.15.01324"
  %69 = trunc i64 %68 to i1
  br i1 %69, label %panic.i1279, label %__barray_check_bounds.exit1282

panic.i1279:                                      ; preds = %__barray_check_bounds.exit1278
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1282:                   ; preds = %__barray_check_bounds.exit1278
  %70 = shl nuw nsw i64 1, %"376_0.sroa.15.01324"
  %71 = xor i64 %67, %70
  store i64 %71, ptr %3, align 4
  %72 = getelementptr inbounds nuw i64, ptr %2, i64 %"376_0.sroa.15.01324"
  %73 = load i64, ptr %72, align 4
  tail call void @___inc_future_refcount(i64 %73)
  %74 = load i64, ptr %3, align 4
  %75 = lshr i64 %74, %"376_0.sroa.15.01324"
  %76 = trunc i64 %75 to i1
  br i1 %76, label %__barray_check_bounds.exit1286, label %panic.i1283

panic.i1283:                                      ; preds = %__barray_check_bounds.exit1282
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1286:                   ; preds = %__barray_check_bounds.exit1282
  %77 = xor i64 %74, %70
  store i64 %77, ptr %3, align 4
  store i64 %73, ptr %72, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %73)
  tail call void @___dec_future_refcount(i64 %73)
  %78 = load i64, ptr %1, align 4
  %79 = lshr i64 %78, %"376_0.sroa.15.01324"
  %80 = trunc i64 %79 to i1
  br i1 %80, label %cond_exit_380, label %panic.i1287

panic.i1287:                                      ; preds = %__barray_check_bounds.exit1286
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_566_case_0:                                  ; preds = %cond_exit_566
  %81 = load i64, ptr %3, align 4
  %82 = or i64 %81, -1048576
  store i64 %82, ptr %3, align 4
  %83 = icmp eq i64 %82, -1
  br i1 %83, label %loop_out537, label %mask_block_err.i1292

mask_block_err.i1292:                             ; preds = %cond_566_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1296:                   ; preds = %cond_exit_380, %cond_exit_566
  %"563_0.01331" = phi i64 [ %84, %cond_exit_566 ], [ 0, %cond_exit_380 ]
  %84 = add nuw nsw i64 %"563_0.01331", 1
  %85 = load i64, ptr %3, align 4
  %86 = lshr i64 %85, %"563_0.01331"
  %87 = trunc i64 %86 to i1
  br i1 %87, label %cond_exit_566, label %__barray_mask_borrow.exit1300

__barray_mask_borrow.exit1300:                    ; preds = %__barray_check_bounds.exit1296
  %88 = shl nuw nsw i64 1, %"563_0.01331"
  %89 = xor i64 %85, %88
  store i64 %89, ptr %3, align 4
  %90 = getelementptr inbounds nuw i64, ptr %2, i64 %"563_0.01331"
  %91 = load i64, ptr %90, align 4
  tail call void @___dec_future_refcount(i64 %91)
  br label %cond_exit_566

cond_exit_566:                                    ; preds = %__barray_mask_borrow.exit1300, %__barray_check_bounds.exit1296
  %92 = icmp samesign ugt i64 %"563_0.01331", 18
  br i1 %92, label %cond_566_case_0, label %__barray_check_bounds.exit1296

cond_exit_380:                                    ; preds = %__barray_check_bounds.exit1286
  %93 = xor i64 %78, %70
  store i64 %93, ptr %1, align 4
  %94 = getelementptr inbounds nuw i1, ptr %0, i64 %"376_0.sroa.15.01324"
  store i1 %read_bool, ptr %94, align 1
  %95 = icmp eq i64 %"376_0.sroa.15.01324", 19
  br i1 %95, label %__barray_check_bounds.exit1296, label %__barray_check_bounds.exit1278

loop_out537:                                      ; preds = %cond_566_case_0
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %96 = load i64, ptr %1, align 4
  %97 = and i64 %96, 1048575
  store i64 %97, ptr %1, align 4
  %98 = icmp eq i64 %97, 0
  br i1 %98, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1301

mask_block_err.i1301:                             ; preds = %loop_out537
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out537
  %99 = tail call ptr @heap_alloc(i64 20)
  %100 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %100, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %99, ptr noundef nonnull align 1 dereferenceable(20) %0, i64 20, i1 false)
  tail call void @heap_free(ptr nonnull %99)
  %101 = load i64, ptr %1, align 4
  %102 = and i64 %101, 1048575
  store i64 %102, ptr %1, align 4
  %103 = icmp eq i64 %102, 0
  br i1 %103, label %__barray_check_none_borrowed.exit1305, label %mask_block_err.i1303

mask_block_err.i1303:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1305:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %104 = alloca [20 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(20) %104, i8 0, i64 20, i1 false)
  store i32 20, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %104, ptr %mask_ptr, align 8
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
