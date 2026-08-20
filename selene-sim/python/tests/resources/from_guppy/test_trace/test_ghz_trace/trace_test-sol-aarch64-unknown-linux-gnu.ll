; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_outcomes.9CB6D2E7.0 = private constant [22 x i8] c"\15USER:BOOLARR:outcomes"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 10)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %2 = tail call ptr @heap_alloc(i64 80)
  %3 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %3, align 1
  %4 = tail call ptr @heap_alloc(i64 80)
  %5 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %5, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit

cond_441_case_0.i:                                ; preds = %cond_exit_12.8, %cond_exit_12.7, %cond_exit_12.6, %cond_exit_12.5, %cond_exit_12.4, %cond_exit_12.3, %cond_exit_12.2, %cond_exit_12.1, %cond_exit_12, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.437.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %6 = load i64, ptr %5, align 4
  %7 = trunc i64 %6 to i1
  br i1 %7, label %cond_exit_12, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_sol_qalloc.437.exit.8, %__hugr__.__tk2_sol_qalloc.437.exit.7, %__hugr__.__tk2_sol_qalloc.437.exit.6, %__hugr__.__tk2_sol_qalloc.437.exit.5, %__hugr__.__tk2_sol_qalloc.437.exit.4, %__hugr__.__tk2_sol_qalloc.437.exit.3, %__hugr__.__tk2_sol_qalloc.437.exit.2, %__hugr__.__tk2_sol_qalloc.437.exit.1, %__hugr__.__tk2_sol_qalloc.437.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_12:                                     ; preds = %__hugr__.__tk2_sol_qalloc.437.exit
  %8 = and i64 %6, -2
  store i64 %8, ptr %5, align 4
  store i64 %qalloc.i, ptr %4, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit.1

__hugr__.__tk2_sol_qalloc.437.exit.1:             ; preds = %cond_exit_12
  tail call void @___reset(i64 %qalloc.i.1)
  %9 = load i64, ptr %5, align 4
  %10 = and i64 %9, 2
  %.not = icmp eq i64 %10, 0
  br i1 %.not, label %panic.i, label %cond_exit_12.1

cond_exit_12.1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.437.exit.1
  %11 = and i64 %9, -3
  store i64 %11, ptr %5, align 4
  %12 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %qalloc.i.1, ptr %12, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit.2

__hugr__.__tk2_sol_qalloc.437.exit.2:             ; preds = %cond_exit_12.1
  tail call void @___reset(i64 %qalloc.i.2)
  %13 = load i64, ptr %5, align 4
  %14 = and i64 %13, 4
  %.not1192 = icmp eq i64 %14, 0
  br i1 %.not1192, label %panic.i, label %cond_exit_12.2

cond_exit_12.2:                                   ; preds = %__hugr__.__tk2_sol_qalloc.437.exit.2
  %15 = and i64 %13, -5
  store i64 %15, ptr %5, align 4
  %16 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %qalloc.i.2, ptr %16, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit.3

__hugr__.__tk2_sol_qalloc.437.exit.3:             ; preds = %cond_exit_12.2
  tail call void @___reset(i64 %qalloc.i.3)
  %17 = load i64, ptr %5, align 4
  %18 = and i64 %17, 8
  %.not1193 = icmp eq i64 %18, 0
  br i1 %.not1193, label %panic.i, label %cond_exit_12.3

cond_exit_12.3:                                   ; preds = %__hugr__.__tk2_sol_qalloc.437.exit.3
  %19 = and i64 %17, -9
  store i64 %19, ptr %5, align 4
  %20 = getelementptr inbounds nuw i8, ptr %4, i64 24
  store i64 %qalloc.i.3, ptr %20, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit.4

__hugr__.__tk2_sol_qalloc.437.exit.4:             ; preds = %cond_exit_12.3
  tail call void @___reset(i64 %qalloc.i.4)
  %21 = load i64, ptr %5, align 4
  %22 = and i64 %21, 16
  %.not1194 = icmp eq i64 %22, 0
  br i1 %.not1194, label %panic.i, label %cond_exit_12.4

cond_exit_12.4:                                   ; preds = %__hugr__.__tk2_sol_qalloc.437.exit.4
  %23 = and i64 %21, -17
  store i64 %23, ptr %5, align 4
  %24 = getelementptr inbounds nuw i8, ptr %4, i64 32
  store i64 %qalloc.i.4, ptr %24, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit.5

__hugr__.__tk2_sol_qalloc.437.exit.5:             ; preds = %cond_exit_12.4
  tail call void @___reset(i64 %qalloc.i.5)
  %25 = load i64, ptr %5, align 4
  %26 = and i64 %25, 32
  %.not1195 = icmp eq i64 %26, 0
  br i1 %.not1195, label %panic.i, label %cond_exit_12.5

cond_exit_12.5:                                   ; preds = %__hugr__.__tk2_sol_qalloc.437.exit.5
  %27 = and i64 %25, -33
  store i64 %27, ptr %5, align 4
  %28 = getelementptr inbounds nuw i8, ptr %4, i64 40
  store i64 %qalloc.i.5, ptr %28, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit.6

__hugr__.__tk2_sol_qalloc.437.exit.6:             ; preds = %cond_exit_12.5
  tail call void @___reset(i64 %qalloc.i.6)
  %29 = load i64, ptr %5, align 4
  %30 = and i64 %29, 64
  %.not1196 = icmp eq i64 %30, 0
  br i1 %.not1196, label %panic.i, label %cond_exit_12.6

cond_exit_12.6:                                   ; preds = %__hugr__.__tk2_sol_qalloc.437.exit.6
  %31 = and i64 %29, -65
  store i64 %31, ptr %5, align 4
  %32 = getelementptr inbounds nuw i8, ptr %4, i64 48
  store i64 %qalloc.i.6, ptr %32, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit.7

__hugr__.__tk2_sol_qalloc.437.exit.7:             ; preds = %cond_exit_12.6
  tail call void @___reset(i64 %qalloc.i.7)
  %33 = load i64, ptr %5, align 4
  %34 = and i64 %33, 128
  %.not1197 = icmp eq i64 %34, 0
  br i1 %.not1197, label %panic.i, label %cond_exit_12.7

cond_exit_12.7:                                   ; preds = %__hugr__.__tk2_sol_qalloc.437.exit.7
  %35 = and i64 %33, -129
  store i64 %35, ptr %5, align 4
  %36 = getelementptr inbounds nuw i8, ptr %4, i64 56
  store i64 %qalloc.i.7, ptr %36, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_441_case_0.i, label %__hugr__.__tk2_sol_qalloc.437.exit.8

__hugr__.__tk2_sol_qalloc.437.exit.8:             ; preds = %cond_exit_12.7
  tail call void @___reset(i64 %qalloc.i.8)
  %37 = load i64, ptr %5, align 4
  %38 = and i64 %37, 256
  %.not1198 = icmp eq i64 %38, 0
  br i1 %.not1198, label %panic.i, label %cond_exit_12.8

cond_exit_12.8:                                   ; preds = %__hugr__.__tk2_sol_qalloc.437.exit.8
  %39 = and i64 %37, -257
  store i64 %39, ptr %5, align 4
  %40 = getelementptr inbounds nuw i8, ptr %4, i64 64
  store i64 %qalloc.i.8, ptr %40, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_441_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_12.8
  tail call void @___reset(i64 %qalloc.i.9)
  %41 = load i64, ptr %5, align 4
  %42 = and i64 %41, 512
  %.not1199 = icmp eq i64 %42, 0
  br i1 %.not1199, label %panic.i, label %cond_exit_12.9

cond_exit_12.9:                                   ; preds = %__barray_check_bounds.exit.9
  %43 = and i64 %41, -513
  store i64 %43, ptr %5, align 4
  %44 = getelementptr inbounds nuw i8, ptr %4, i64 72
  store i64 %qalloc.i.9, ptr %44, align 4
  %45 = load i64, ptr %5, align 4
  %46 = trunc i64 %45 to i1
  br i1 %46, label %panic.i1117, label %__barray_mask_borrow.exit

panic.i1117:                                      ; preds = %cond_exit_12.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_12.9
  %47 = or disjoint i64 %45, 1
  store i64 %47, ptr %5, align 4
  %48 = load i64, ptr %4, align 4
  tail call void @___rp(i64 %48, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %48, double 0x400921FB54442D18)
  %49 = load i64, ptr %5, align 4
  %50 = trunc i64 %49 to i1
  br i1 %50, label %__barray_mask_return.exit1119, label %panic.i1118

panic.i1118:                                      ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1119:                    ; preds = %__barray_mask_borrow.exit
  %51 = and i64 %49, -2
  store i64 %51, ptr %5, align 4
  store i64 %48, ptr %4, align 4
  br label %__barray_check_bounds.exit1121

__barray_check_bounds.exit1121:                   ; preds = %__barray_mask_return.exit1119, %__barray_mask_return.exit1135
  %52 = phi i64 [ 1, %__barray_mask_return.exit1119 ], [ %74, %__barray_mask_return.exit1135 ]
  %"116_0.01189" = phi i64 [ 0, %__barray_mask_return.exit1119 ], [ %52, %__barray_mask_return.exit1135 ]
  %53 = load i64, ptr %5, align 4
  %54 = lshr i64 %53, %"116_0.01189"
  %55 = trunc i64 %54 to i1
  br i1 %55, label %panic.i1122, label %__barray_check_bounds.exit1125

panic.i1122:                                      ; preds = %__barray_check_bounds.exit1121
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1125:                   ; preds = %__barray_check_bounds.exit1121
  %56 = shl nuw nsw i64 1, %"116_0.01189"
  %57 = xor i64 %53, %56
  store i64 %57, ptr %5, align 4
  %58 = getelementptr inbounds nuw i64, ptr %4, i64 %"116_0.01189"
  %59 = load i64, ptr %58, align 4
  %60 = lshr i64 %57, %52
  %61 = trunc i64 %60 to i1
  br i1 %61, label %panic.i1126, label %__barray_check_bounds.exit1129

panic.i1126:                                      ; preds = %__barray_check_bounds.exit1125
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1129:                   ; preds = %__barray_check_bounds.exit1125
  %62 = shl nuw nsw i64 2, %"116_0.01189"
  %63 = xor i64 %57, %62
  store i64 %63, ptr %5, align 4
  %64 = getelementptr inbounds nuw i64, ptr %4, i64 %52
  %65 = load i64, ptr %64, align 4
  tail call void @___rp(i64 %59, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %59, i64 %65, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %65, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %59, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %59, double 0xBFF921FB54442D18)
  %66 = load i64, ptr %5, align 4
  %67 = lshr i64 %66, %"116_0.01189"
  %68 = trunc i64 %67 to i1
  br i1 %68, label %__barray_check_bounds.exit1133, label %panic.i1130

panic.i1130:                                      ; preds = %__barray_check_bounds.exit1129
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1133:                   ; preds = %__barray_check_bounds.exit1129
  %69 = xor i64 %66, %56
  store i64 %69, ptr %5, align 4
  store i64 %59, ptr %58, align 4
  %70 = load i64, ptr %5, align 4
  %71 = lshr i64 %70, %52
  %72 = trunc i64 %71 to i1
  br i1 %72, label %__barray_mask_return.exit1135, label %panic.i1134

panic.i1134:                                      ; preds = %__barray_check_bounds.exit1133
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1135:                    ; preds = %__barray_check_bounds.exit1133
  %73 = xor i64 %70, %62
  store i64 %73, ptr %5, align 4
  store i64 %65, ptr %64, align 4
  %74 = add nuw nsw i64 %52, 1
  %exitcond = icmp eq i64 %74, 10
  br i1 %exitcond, label %loop_body346.preheader, label %__barray_check_bounds.exit1121

out_of_bounds.i1136:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1137:                   ; preds = %.thread
  %75 = load i64, ptr %3, align 4
  %76 = lshr i64 %75, %"237_2.01203"
  %77 = trunc i64 %76 to i1
  br i1 %77, label %cond_exit_241, label %panic.i1138

panic.i1138:                                      ; preds = %__barray_check_bounds.exit1137
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_241
  %78 = load i64, ptr %5, align 4
  %79 = or i64 %78, -1024
  store i64 %79, ptr %5, align 4
  %80 = icmp eq i64 %79, -1
  br i1 %80, label %loop_body455.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

loop_body346.preheader:                           ; preds = %__barray_mask_return.exit1135, %cond_exit_241
  %"237_0.sroa.15.01204" = phi i64 [ %81, %cond_exit_241 ], [ 0, %__barray_mask_return.exit1135 ]
  %"237_2.01203" = phi i64 [ %89, %cond_exit_241 ], [ 0, %__barray_mask_return.exit1135 ]
  %81 = add nuw nsw i64 %"237_0.sroa.15.01204", 1
  %82 = load i64, ptr %5, align 4
  %83 = lshr i64 %82, %"237_0.sroa.15.01204"
  %84 = trunc i64 %83 to i1
  br i1 %84, label %panic.i1142, label %.thread

panic.i1142:                                      ; preds = %loop_body346.preheader
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %loop_body346.preheader
  %85 = shl nuw nsw i64 1, %"237_0.sroa.15.01204"
  %86 = xor i64 %82, %85
  store i64 %86, ptr %5, align 4
  %87 = getelementptr inbounds nuw i64, ptr %4, i64 %"237_0.sroa.15.01204"
  %88 = load i64, ptr %87, align 4
  %89 = add i64 %"237_2.01203", 1
  %lazy_measure = tail call i64 @___lazy_measure(i64 %88)
  tail call void @___qfree(i64 %88)
  %90 = icmp ult i64 %"237_2.01203", 10
  br i1 %90, label %__barray_check_bounds.exit1137, label %out_of_bounds.i1136

cond_exit_241:                                    ; preds = %__barray_check_bounds.exit1137
  %91 = shl nuw nsw i64 1, %"237_2.01203"
  %92 = xor i64 %75, %91
  store i64 %92, ptr %3, align 4
  %93 = getelementptr inbounds nuw i64, ptr %2, i64 %"237_2.01203"
  store i64 %lazy_measure, ptr %93, align 4
  %94 = icmp samesign ugt i64 %"237_0.sroa.15.01204", 8
  br i1 %94, label %mask_block_ok.i, label %loop_body346.preheader

loop_body455.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  br label %__barray_check_bounds.exit1145

__barray_check_bounds.exit1145:                   ; preds = %cond_exit_307, %loop_body455.preheader.preheader
  %"303_0.sroa.15.01191" = phi i64 [ %95, %cond_exit_307 ], [ 0, %loop_body455.preheader.preheader ]
  %95 = add nuw nsw i64 %"303_0.sroa.15.01191", 1
  %96 = load i64, ptr %3, align 4
  %97 = lshr i64 %96, %"303_0.sroa.15.01191"
  %98 = trunc i64 %97 to i1
  br i1 %98, label %panic.i1146, label %__barray_check_bounds.exit1149

panic.i1146:                                      ; preds = %__barray_check_bounds.exit1145
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1149:                   ; preds = %__barray_check_bounds.exit1145
  %99 = shl nuw nsw i64 1, %"303_0.sroa.15.01191"
  %100 = xor i64 %96, %99
  store i64 %100, ptr %3, align 4
  %101 = getelementptr inbounds nuw i64, ptr %2, i64 %"303_0.sroa.15.01191"
  %102 = load i64, ptr %101, align 4
  tail call void @___inc_future_refcount(i64 %102)
  %103 = load i64, ptr %3, align 4
  %104 = lshr i64 %103, %"303_0.sroa.15.01191"
  %105 = trunc i64 %104 to i1
  br i1 %105, label %__barray_check_bounds.exit1153, label %panic.i1150

panic.i1150:                                      ; preds = %__barray_check_bounds.exit1149
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1153:                   ; preds = %__barray_check_bounds.exit1149
  %106 = xor i64 %103, %99
  store i64 %106, ptr %3, align 4
  store i64 %102, ptr %101, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %102)
  tail call void @___dec_future_refcount(i64 %102)
  %107 = load i64, ptr %1, align 4
  %108 = lshr i64 %107, %"303_0.sroa.15.01191"
  %109 = trunc i64 %108 to i1
  br i1 %109, label %cond_exit_307, label %panic.i1154

panic.i1154:                                      ; preds = %__barray_check_bounds.exit1153
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_err.i1159:                             ; preds = %cond_exit_487.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit1167:                    ; preds = %__barray_check_bounds.exit1163.preheader
  %110 = or disjoint i64 %163, 1
  store i64 %110, ptr %3, align 4
  %111 = load i64, ptr %2, align 4
  tail call void @___dec_future_refcount(i64 %111)
  br label %cond_exit_487

cond_exit_487:                                    ; preds = %__barray_mask_borrow.exit1167, %__barray_check_bounds.exit1163.preheader
  %112 = load i64, ptr %3, align 4
  %113 = and i64 %112, 2
  %.not1206 = icmp eq i64 %113, 0
  br i1 %.not1206, label %__barray_mask_borrow.exit1167.1, label %cond_exit_487.1

__barray_mask_borrow.exit1167.1:                  ; preds = %cond_exit_487
  %114 = or disjoint i64 %112, 2
  store i64 %114, ptr %3, align 4
  %115 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %116 = load i64, ptr %115, align 4
  tail call void @___dec_future_refcount(i64 %116)
  br label %cond_exit_487.1

cond_exit_487.1:                                  ; preds = %__barray_mask_borrow.exit1167.1, %cond_exit_487
  %117 = load i64, ptr %3, align 4
  %118 = and i64 %117, 4
  %.not1207 = icmp eq i64 %118, 0
  br i1 %.not1207, label %__barray_mask_borrow.exit1167.2, label %cond_exit_487.2

__barray_mask_borrow.exit1167.2:                  ; preds = %cond_exit_487.1
  %119 = or disjoint i64 %117, 4
  store i64 %119, ptr %3, align 4
  %120 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %121 = load i64, ptr %120, align 4
  tail call void @___dec_future_refcount(i64 %121)
  br label %cond_exit_487.2

cond_exit_487.2:                                  ; preds = %__barray_mask_borrow.exit1167.2, %cond_exit_487.1
  %122 = load i64, ptr %3, align 4
  %123 = and i64 %122, 8
  %.not1208 = icmp eq i64 %123, 0
  br i1 %.not1208, label %__barray_mask_borrow.exit1167.3, label %cond_exit_487.3

__barray_mask_borrow.exit1167.3:                  ; preds = %cond_exit_487.2
  %124 = or disjoint i64 %122, 8
  store i64 %124, ptr %3, align 4
  %125 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %126 = load i64, ptr %125, align 4
  tail call void @___dec_future_refcount(i64 %126)
  br label %cond_exit_487.3

cond_exit_487.3:                                  ; preds = %__barray_mask_borrow.exit1167.3, %cond_exit_487.2
  %127 = load i64, ptr %3, align 4
  %128 = and i64 %127, 16
  %.not1209 = icmp eq i64 %128, 0
  br i1 %.not1209, label %__barray_mask_borrow.exit1167.4, label %cond_exit_487.4

__barray_mask_borrow.exit1167.4:                  ; preds = %cond_exit_487.3
  %129 = or disjoint i64 %127, 16
  store i64 %129, ptr %3, align 4
  %130 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %131 = load i64, ptr %130, align 4
  tail call void @___dec_future_refcount(i64 %131)
  br label %cond_exit_487.4

cond_exit_487.4:                                  ; preds = %__barray_mask_borrow.exit1167.4, %cond_exit_487.3
  %132 = load i64, ptr %3, align 4
  %133 = and i64 %132, 32
  %.not1210 = icmp eq i64 %133, 0
  br i1 %.not1210, label %__barray_mask_borrow.exit1167.5, label %cond_exit_487.5

__barray_mask_borrow.exit1167.5:                  ; preds = %cond_exit_487.4
  %134 = or disjoint i64 %132, 32
  store i64 %134, ptr %3, align 4
  %135 = getelementptr inbounds nuw i8, ptr %2, i64 40
  %136 = load i64, ptr %135, align 4
  tail call void @___dec_future_refcount(i64 %136)
  br label %cond_exit_487.5

cond_exit_487.5:                                  ; preds = %__barray_mask_borrow.exit1167.5, %cond_exit_487.4
  %137 = load i64, ptr %3, align 4
  %138 = and i64 %137, 64
  %.not1211 = icmp eq i64 %138, 0
  br i1 %.not1211, label %__barray_mask_borrow.exit1167.6, label %cond_exit_487.6

__barray_mask_borrow.exit1167.6:                  ; preds = %cond_exit_487.5
  %139 = or disjoint i64 %137, 64
  store i64 %139, ptr %3, align 4
  %140 = getelementptr inbounds nuw i8, ptr %2, i64 48
  %141 = load i64, ptr %140, align 4
  tail call void @___dec_future_refcount(i64 %141)
  br label %cond_exit_487.6

cond_exit_487.6:                                  ; preds = %__barray_mask_borrow.exit1167.6, %cond_exit_487.5
  %142 = load i64, ptr %3, align 4
  %143 = and i64 %142, 128
  %.not1212 = icmp eq i64 %143, 0
  br i1 %.not1212, label %__barray_mask_borrow.exit1167.7, label %cond_exit_487.7

__barray_mask_borrow.exit1167.7:                  ; preds = %cond_exit_487.6
  %144 = or disjoint i64 %142, 128
  store i64 %144, ptr %3, align 4
  %145 = getelementptr inbounds nuw i8, ptr %2, i64 56
  %146 = load i64, ptr %145, align 4
  tail call void @___dec_future_refcount(i64 %146)
  br label %cond_exit_487.7

cond_exit_487.7:                                  ; preds = %__barray_mask_borrow.exit1167.7, %cond_exit_487.6
  %147 = load i64, ptr %3, align 4
  %148 = and i64 %147, 256
  %.not1213 = icmp eq i64 %148, 0
  br i1 %.not1213, label %__barray_mask_borrow.exit1167.8, label %cond_exit_487.8

__barray_mask_borrow.exit1167.8:                  ; preds = %cond_exit_487.7
  %149 = or disjoint i64 %147, 256
  store i64 %149, ptr %3, align 4
  %150 = getelementptr inbounds nuw i8, ptr %2, i64 64
  %151 = load i64, ptr %150, align 4
  tail call void @___dec_future_refcount(i64 %151)
  br label %cond_exit_487.8

cond_exit_487.8:                                  ; preds = %__barray_mask_borrow.exit1167.8, %cond_exit_487.7
  %152 = load i64, ptr %3, align 4
  %153 = and i64 %152, 512
  %.not1214 = icmp eq i64 %153, 0
  br i1 %.not1214, label %__barray_mask_borrow.exit1167.9, label %cond_exit_487.9

__barray_mask_borrow.exit1167.9:                  ; preds = %cond_exit_487.8
  %154 = or disjoint i64 %152, 512
  store i64 %154, ptr %3, align 4
  %155 = getelementptr inbounds nuw i8, ptr %2, i64 72
  %156 = load i64, ptr %155, align 4
  tail call void @___dec_future_refcount(i64 %156)
  br label %cond_exit_487.9

cond_exit_487.9:                                  ; preds = %__barray_mask_borrow.exit1167.9, %cond_exit_487.8
  %157 = load i64, ptr %3, align 4
  %158 = or i64 %157, -1024
  store i64 %158, ptr %3, align 4
  %159 = icmp eq i64 %158, -1
  br i1 %159, label %loop_out454, label %mask_block_err.i1159

cond_exit_307:                                    ; preds = %__barray_check_bounds.exit1153
  %160 = xor i64 %107, %99
  store i64 %160, ptr %1, align 4
  %161 = getelementptr inbounds nuw i1, ptr %0, i64 %"303_0.sroa.15.01191"
  store i1 %read_bool, ptr %161, align 1
  %162 = icmp eq i64 %"303_0.sroa.15.01191", 9
  br i1 %162, label %__barray_check_bounds.exit1163.preheader, label %__barray_check_bounds.exit1145

__barray_check_bounds.exit1163.preheader:         ; preds = %cond_exit_307
  %163 = load i64, ptr %3, align 4
  %164 = trunc i64 %163 to i1
  br i1 %164, label %cond_exit_487, label %__barray_mask_borrow.exit1167

loop_out454:                                      ; preds = %cond_exit_487.9
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %165 = load i64, ptr %1, align 4
  %166 = and i64 %165, 1023
  store i64 %166, ptr %1, align 4
  %167 = icmp eq i64 %166, 0
  br i1 %167, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1168

mask_block_err.i1168:                             ; preds = %loop_out454
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out454
  %168 = tail call ptr @heap_alloc(i64 10)
  %169 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %169, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %168, ptr noundef nonnull align 1 dereferenceable(10) %0, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %168)
  %170 = load i64, ptr %1, align 4
  %171 = and i64 %170, 1023
  store i64 %171, ptr %1, align 4
  %172 = icmp eq i64 %171, 0
  br i1 %172, label %__barray_check_none_borrowed.exit1172, label %mask_block_err.i1170

mask_block_err.i1170:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1172:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %173 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %173, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %173, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_outcomes.9CB6D2E7.0, i64 21, ptr nonnull %out_arr_alloca)
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

attributes #0 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #1 = { noreturn }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!name = !{!0}

!0 = !{!"mainlib"}
