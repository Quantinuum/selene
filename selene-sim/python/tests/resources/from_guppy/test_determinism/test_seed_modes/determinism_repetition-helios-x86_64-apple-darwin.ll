; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_ms.6A332612.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:ms"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 100)
  %1 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %1, i8 -1, i64 16, i1 false)
  %2 = tail call ptr @heap_alloc(i64 800)
  %3 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %3, i8 -1, i64 16, i1 false)
  %4 = tail call ptr @heap_alloc(i64 800)
  %5 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %5, i8 -1, i64 16, i1 false)
  br label %loop_body

loop_body:                                        ; preds = %cond_exit_104, %alloca_block
  %"100_2.0" = phi i64 [ 0, %alloca_block ], [ %"2109.0", %cond_exit_104 ]
  %"100_0.sroa.0.0" = phi i64 [ 0, %alloca_block ], [ %7, %cond_exit_104 ]
  %6 = icmp samesign ugt i64 %"100_0.sroa.0.0", 99
  %7 = add nuw nsw i64 %"100_0.sroa.0.0", 1
  br i1 %6, label %cond_exit_104, label %cond_104_case_1

cond_104_case_1:                                  ; preds = %loop_body
  %8 = add i64 %"100_2.0", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_409_case_0.i, label %__hugr__.__tk2_helios_qalloc.405.exit

cond_409_case_0.i:                                ; preds = %cond_104_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.405.exit:            ; preds = %cond_104_case_1
  tail call void @___reset(i64 %qalloc.i)
  %9 = icmp ult i64 %"100_2.0", 100
  br i1 %9, label %__barray_check_bounds.exit, label %out_of_bounds.i

out_of_bounds.i:                                  ; preds = %__hugr__.__tk2_helios_qalloc.405.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %__hugr__.__tk2_helios_qalloc.405.exit
  %10 = lshr i64 %"100_2.0", 6
  %11 = getelementptr inbounds nuw i64, ptr %5, i64 %10
  %12 = load i64, ptr %11, align 4
  %13 = and i64 %"100_2.0", 63
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
  %18 = getelementptr inbounds nuw i64, ptr %4, i64 %"100_2.0"
  store i64 %qalloc.i, ptr %18, align 4
  br label %cond_exit_104

cond_exit_104:                                    ; preds = %loop_body, %__barray_mask_return.exit
  %"2109.0" = phi i64 [ %8, %__barray_mask_return.exit ], [ %"100_2.0", %loop_body ]
  %exitcond = icmp eq i64 %7, 101
  br i1 %exitcond, label %__barray_check_bounds.exit1182, label %loop_body

loop_body321.preheader:                           ; preds = %__barray_mask_return.exit1187
  %19 = getelementptr i8, ptr %5, i64 8
  br label %__barray_check_bounds.exit1193

__barray_check_bounds.exit1182:                   ; preds = %cond_exit_104, %__barray_mask_return.exit1187
  %20 = phi i64 [ %35, %__barray_mask_return.exit1187 ], [ 1, %cond_exit_104 ]
  %"6_0.01240" = phi i64 [ %20, %__barray_mask_return.exit1187 ], [ 0, %cond_exit_104 ]
  %21 = lshr i64 %"6_0.01240", 6
  %22 = getelementptr inbounds nuw i64, ptr %5, i64 %21
  %23 = load i64, ptr %22, align 4
  %24 = and i64 %"6_0.01240", 63
  %25 = lshr i64 %23, %24
  %26 = trunc i64 %25 to i1
  br i1 %26, label %panic.i1183, label %__barray_check_bounds.exit1185

panic.i1183:                                      ; preds = %__barray_check_bounds.exit1182
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1185:                   ; preds = %__barray_check_bounds.exit1182
  %27 = shl nuw i64 1, %24
  %28 = xor i64 %23, %27
  store i64 %28, ptr %22, align 4
  %29 = getelementptr inbounds nuw i64, ptr %4, i64 %"6_0.01240"
  %30 = load i64, ptr %29, align 4
  tail call void @___rxy(i64 %30, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %30, double 0x400921FB54442D18)
  %31 = load i64, ptr %22, align 4
  %32 = lshr i64 %31, %24
  %33 = trunc i64 %32 to i1
  br i1 %33, label %__barray_mask_return.exit1187, label %panic.i1186

panic.i1186:                                      ; preds = %__barray_check_bounds.exit1185
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1187:                    ; preds = %__barray_check_bounds.exit1185
  %34 = xor i64 %31, %27
  store i64 %34, ptr %22, align 4
  store i64 %30, ptr %29, align 4
  %35 = add nuw nsw i64 %20, 1
  %exitcond1243 = icmp eq i64 %35, 101
  br i1 %exitcond1243, label %loop_body321.preheader, label %__barray_check_bounds.exit1182

out_of_bounds.i1188:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1189:                   ; preds = %.thread
  %36 = lshr i64 %"223_2.01248", 6
  %37 = getelementptr inbounds nuw i64, ptr %3, i64 %36
  %38 = load i64, ptr %37, align 4
  %39 = and i64 %"223_2.01248", 63
  %40 = lshr i64 %38, %39
  %41 = trunc i64 %40 to i1
  br i1 %41, label %cond_exit_227, label %panic.i1190

panic.i1190:                                      ; preds = %__barray_check_bounds.exit1189
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_227
  %42 = load i64, ptr %19, align 4
  %43 = or i64 %42, -68719476736
  store i64 %43, ptr %19, align 4
  %44 = load i64, ptr %5, align 4
  %45 = icmp eq i64 %44, -1
  %46 = icmp eq i64 %43, -1
  %or.cond = select i1 %45, i1 %46, i1 false
  br i1 %or.cond, label %loop_body430.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1193:                   ; preds = %loop_body321.preheader, %cond_exit_227
  %"223_0.sroa.15.01249" = phi i64 [ 0, %loop_body321.preheader ], [ %47, %cond_exit_227 ]
  %"223_2.01248" = phi i64 [ 0, %loop_body321.preheader ], [ %58, %cond_exit_227 ]
  %47 = add nuw nsw i64 %"223_0.sroa.15.01249", 1
  %48 = lshr i64 %"223_0.sroa.15.01249", 6
  %49 = getelementptr inbounds nuw i64, ptr %5, i64 %48
  %50 = load i64, ptr %49, align 4
  %51 = and i64 %"223_0.sroa.15.01249", 63
  %52 = lshr i64 %50, %51
  %53 = trunc i64 %52 to i1
  br i1 %53, label %panic.i1194, label %.thread

panic.i1194:                                      ; preds = %__barray_check_bounds.exit1193
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_check_bounds.exit1193
  %54 = shl nuw i64 1, %51
  %55 = xor i64 %50, %54
  store i64 %55, ptr %49, align 4
  %56 = getelementptr inbounds nuw i64, ptr %4, i64 %"223_0.sroa.15.01249"
  %57 = load i64, ptr %56, align 4
  %58 = add i64 %"223_2.01248", 1
  %lazy_measure = tail call i64 @___lazy_measure(i64 %57)
  tail call void @___qfree(i64 %57)
  %59 = icmp ult i64 %"223_2.01248", 100
  br i1 %59, label %__barray_check_bounds.exit1189, label %out_of_bounds.i1188

cond_exit_227:                                    ; preds = %__barray_check_bounds.exit1189
  %60 = shl nuw i64 1, %39
  %61 = xor i64 %38, %60
  store i64 %61, ptr %37, align 4
  %62 = getelementptr inbounds nuw i64, ptr %2, i64 %"223_2.01248"
  store i64 %lazy_measure, ptr %62, align 4
  %63 = icmp samesign ugt i64 %"223_0.sroa.15.01249", 98
  br i1 %63, label %mask_block_ok.i, label %__barray_check_bounds.exit1193

loop_body430.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  br label %__barray_check_bounds.exit1197

loop_body534.preheader:                           ; preds = %cond_exit_293
  %64 = getelementptr i8, ptr %3, i64 8
  br label %__barray_check_bounds.exit1215

__barray_check_bounds.exit1197:                   ; preds = %cond_exit_293, %loop_body430.preheader.preheader
  %"289_0.sroa.15.01242" = phi i64 [ %65, %cond_exit_293 ], [ 0, %loop_body430.preheader.preheader ]
  %65 = add nuw nsw i64 %"289_0.sroa.15.01242", 1
  %66 = lshr i64 %"289_0.sroa.15.01242", 6
  %67 = getelementptr inbounds nuw i64, ptr %3, i64 %66
  %68 = load i64, ptr %67, align 4
  %69 = and i64 %"289_0.sroa.15.01242", 63
  %70 = lshr i64 %68, %69
  %71 = trunc i64 %70 to i1
  br i1 %71, label %panic.i1198, label %__barray_check_bounds.exit1201

panic.i1198:                                      ; preds = %__barray_check_bounds.exit1197
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1201:                   ; preds = %__barray_check_bounds.exit1197
  %72 = shl nuw i64 1, %69
  %73 = xor i64 %68, %72
  store i64 %73, ptr %67, align 4
  %74 = getelementptr inbounds nuw i64, ptr %2, i64 %"289_0.sroa.15.01242"
  %75 = load i64, ptr %74, align 4
  tail call void @___inc_future_refcount(i64 %75)
  %76 = load i64, ptr %67, align 4
  %77 = lshr i64 %76, %69
  %78 = trunc i64 %77 to i1
  br i1 %78, label %__barray_check_bounds.exit1205, label %panic.i1202

panic.i1202:                                      ; preds = %__barray_check_bounds.exit1201
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1205:                   ; preds = %__barray_check_bounds.exit1201
  %79 = xor i64 %76, %72
  store i64 %79, ptr %67, align 4
  store i64 %75, ptr %74, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %75)
  tail call void @___dec_future_refcount(i64 %75)
  %80 = getelementptr inbounds nuw i64, ptr %1, i64 %66
  %81 = load i64, ptr %80, align 4
  %82 = lshr i64 %81, %69
  %83 = trunc i64 %82 to i1
  br i1 %83, label %cond_exit_293, label %panic.i1206

panic.i1206:                                      ; preds = %__barray_check_bounds.exit1205
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_455_case_0:                                  ; preds = %cond_exit_455
  %84 = load i64, ptr %64, align 4
  %85 = or i64 %84, -68719476736
  store i64 %85, ptr %64, align 4
  %86 = load i64, ptr %3, align 4
  %87 = icmp eq i64 %86, -1
  %88 = icmp eq i64 %85, -1
  %or.cond1247 = select i1 %87, i1 %88, i1 false
  br i1 %or.cond1247, label %loop_out429, label %mask_block_err.i1211

mask_block_err.i1211:                             ; preds = %cond_455_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit1215:                   ; preds = %loop_body534.preheader, %cond_exit_455
  %"452_0.01250" = phi i64 [ 0, %loop_body534.preheader ], [ %89, %cond_exit_455 ]
  %89 = add nuw nsw i64 %"452_0.01250", 1
  %90 = lshr i64 %"452_0.01250", 6
  %91 = getelementptr inbounds nuw i64, ptr %3, i64 %90
  %92 = load i64, ptr %91, align 4
  %93 = and i64 %"452_0.01250", 63
  %94 = lshr i64 %92, %93
  %95 = trunc i64 %94 to i1
  br i1 %95, label %cond_exit_455, label %__barray_mask_borrow.exit1219

__barray_mask_borrow.exit1219:                    ; preds = %__barray_check_bounds.exit1215
  %96 = shl nuw i64 1, %93
  %97 = xor i64 %92, %96
  store i64 %97, ptr %91, align 4
  %98 = getelementptr inbounds nuw i64, ptr %2, i64 %"452_0.01250"
  %99 = load i64, ptr %98, align 4
  tail call void @___dec_future_refcount(i64 %99)
  br label %cond_exit_455

cond_exit_455:                                    ; preds = %__barray_mask_borrow.exit1219, %__barray_check_bounds.exit1215
  %100 = icmp samesign ugt i64 %"452_0.01250", 98
  br i1 %100, label %cond_455_case_0, label %__barray_check_bounds.exit1215

cond_exit_293:                                    ; preds = %__barray_check_bounds.exit1205
  %101 = xor i64 %81, %72
  store i64 %101, ptr %80, align 4
  %102 = getelementptr inbounds nuw i1, ptr %0, i64 %"289_0.sroa.15.01242"
  store i1 %read_bool, ptr %102, align 1
  %103 = icmp eq i64 %"289_0.sroa.15.01242", 99
  br i1 %103, label %loop_body534.preheader, label %__barray_check_bounds.exit1197

loop_out429:                                      ; preds = %cond_455_case_0
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %104 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %105 = load i64, ptr %104, align 4
  %106 = and i64 %105, 68719476735
  store i64 %106, ptr %104, align 4
  %107 = load i64, ptr %1, align 4
  %108 = icmp eq i64 %107, 0
  %109 = icmp eq i64 %106, 0
  %or.cond.i = select i1 %108, i1 %109, i1 false
  br i1 %or.cond.i, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1221

mask_block_err.i1221:                             ; preds = %loop_out429
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out429
  %110 = tail call ptr @heap_alloc(i64 100)
  %111 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %111, i8 0, i64 16, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %110, ptr noundef nonnull align 1 dereferenceable(100) %0, i64 100, i1 false)
  tail call void @heap_free(ptr nonnull %110)
  %112 = load i64, ptr %104, align 4
  %113 = and i64 %112, 68719476735
  store i64 %113, ptr %104, align 4
  %114 = load i64, ptr %1, align 4
  %115 = icmp eq i64 %114, 0
  %116 = icmp eq i64 %113, 0
  %or.cond.i1223 = select i1 %115, i1 %116, i1 false
  br i1 %or.cond.i1223, label %__barray_check_none_borrowed.exit1225, label %mask_block_err.i1224

mask_block_err.i1224:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1225:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %117 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %117, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %117, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_ms.6A332612.0, i64 15, ptr nonnull %out_arr_alloca)
  ret void
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

declare void @___rxy(i64, double, double) local_unnamed_addr

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

attributes #0 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #1 = { noreturn }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!name = !{!0}

!0 = !{!"mainlib"}
