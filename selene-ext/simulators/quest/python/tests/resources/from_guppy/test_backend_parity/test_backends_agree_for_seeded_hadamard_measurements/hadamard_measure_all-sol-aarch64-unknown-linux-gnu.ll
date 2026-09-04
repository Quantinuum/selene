; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_measuremen.F30240EB.0 = private constant [26 x i8] c"\19USER:BOOLARR:measurements"
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
  br label %loop_body

loop_body:                                        ; preds = %cond_exit_104, %alloca_block
  %"100_2.0" = phi i64 [ 0, %alloca_block ], [ %"2106.0", %cond_exit_104 ]
  %"100_0.sroa.0.0" = phi i64 [ 0, %alloca_block ], [ %7, %cond_exit_104 ]
  %6 = icmp samesign ugt i64 %"100_0.sroa.0.0", 9
  %7 = add nuw nsw i64 %"100_0.sroa.0.0", 1
  br i1 %6, label %cond_exit_104, label %cond_104_case_1

cond_104_case_1:                                  ; preds = %loop_body
  %8 = add i64 %"100_2.0", 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_409_case_0.i, label %__hugr__.__tk2_sol_qalloc.405.exit

cond_409_case_0.i:                                ; preds = %cond_104_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.405.exit:               ; preds = %cond_104_case_1
  tail call void @___reset(i64 %qalloc.i)
  %9 = icmp ult i64 %"100_2.0", 10
  br i1 %9, label %__barray_check_bounds.exit, label %out_of_bounds.i

out_of_bounds.i:                                  ; preds = %__hugr__.__tk2_sol_qalloc.405.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %__hugr__.__tk2_sol_qalloc.405.exit
  %10 = load i64, ptr %5, align 4
  %11 = lshr i64 %10, %"100_2.0"
  %12 = trunc i64 %11 to i1
  br i1 %12, label %__barray_mask_return.exit, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit
  %13 = shl nuw nsw i64 1, %"100_2.0"
  %14 = xor i64 %10, %13
  store i64 %14, ptr %5, align 4
  %15 = getelementptr inbounds nuw i64, ptr %4, i64 %"100_2.0"
  store i64 %qalloc.i, ptr %15, align 4
  br label %cond_exit_104

cond_exit_104:                                    ; preds = %loop_body, %__barray_mask_return.exit
  %"2106.0" = phi i64 [ %8, %__barray_mask_return.exit ], [ %"100_2.0", %loop_body ]
  %exitcond = icmp eq i64 %7, 11
  br i1 %exitcond, label %__barray_check_bounds.exit1088, label %loop_body

__barray_check_bounds.exit1088:                   ; preds = %cond_exit_104, %__barray_mask_return.exit1093
  %16 = phi i64 [ %28, %__barray_mask_return.exit1093 ], [ 1, %cond_exit_104 ]
  %"6_0.01145" = phi i64 [ %16, %__barray_mask_return.exit1093 ], [ 0, %cond_exit_104 ]
  %17 = load i64, ptr %5, align 4
  %18 = lshr i64 %17, %"6_0.01145"
  %19 = trunc i64 %18 to i1
  br i1 %19, label %panic.i1089, label %__barray_check_bounds.exit1091

panic.i1089:                                      ; preds = %__barray_check_bounds.exit1088
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1091:                   ; preds = %__barray_check_bounds.exit1088
  %20 = shl nuw nsw i64 1, %"6_0.01145"
  %21 = xor i64 %17, %20
  store i64 %21, ptr %5, align 4
  %22 = getelementptr inbounds nuw i64, ptr %4, i64 %"6_0.01145"
  %23 = load i64, ptr %22, align 4
  tail call void @___rp(i64 %23, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %23, double 0x400921FB54442D18)
  %24 = load i64, ptr %5, align 4
  %25 = lshr i64 %24, %"6_0.01145"
  %26 = trunc i64 %25 to i1
  br i1 %26, label %__barray_mask_return.exit1093, label %panic.i1092

panic.i1092:                                      ; preds = %__barray_check_bounds.exit1091
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1093:                    ; preds = %__barray_check_bounds.exit1091
  %27 = xor i64 %24, %20
  store i64 %27, ptr %5, align 4
  store i64 %23, ptr %22, align 4
  %28 = add nuw nsw i64 %16, 1
  %exitcond1148 = icmp eq i64 %28, 11
  br i1 %exitcond1148, label %loop_body318.preheader, label %__barray_check_bounds.exit1088

out_of_bounds.i1094:                              ; preds = %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Index out .DD115165.0")
  unreachable

__barray_check_bounds.exit1095:                   ; preds = %.thread
  %29 = load i64, ptr %3, align 4
  %30 = lshr i64 %29, %"223_2.01152"
  %31 = trunc i64 %30 to i1
  br i1 %31, label %cond_exit_227, label %panic.i1096

panic.i1096:                                      ; preds = %__barray_check_bounds.exit1095
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_ok.i:                                  ; preds = %cond_exit_227
  %32 = load i64, ptr %5, align 4
  %33 = or i64 %32, -1024
  store i64 %33, ptr %5, align 4
  %34 = icmp eq i64 %33, -1
  br i1 %34, label %loop_body427.preheader.preheader, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

loop_body318.preheader:                           ; preds = %__barray_mask_return.exit1093, %cond_exit_227
  %"223_0.sroa.15.01153" = phi i64 [ %35, %cond_exit_227 ], [ 0, %__barray_mask_return.exit1093 ]
  %"223_2.01152" = phi i64 [ %43, %cond_exit_227 ], [ 0, %__barray_mask_return.exit1093 ]
  %35 = add nuw nsw i64 %"223_0.sroa.15.01153", 1
  %36 = load i64, ptr %5, align 4
  %37 = lshr i64 %36, %"223_0.sroa.15.01153"
  %38 = trunc i64 %37 to i1
  br i1 %38, label %panic.i1100, label %.thread

panic.i1100:                                      ; preds = %loop_body318.preheader
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %loop_body318.preheader
  %39 = shl nuw nsw i64 1, %"223_0.sroa.15.01153"
  %40 = xor i64 %36, %39
  store i64 %40, ptr %5, align 4
  %41 = getelementptr inbounds nuw i64, ptr %4, i64 %"223_0.sroa.15.01153"
  %42 = load i64, ptr %41, align 4
  %43 = add i64 %"223_2.01152", 1
  %lazy_measure = tail call i64 @___lazy_measure(i64 %42)
  tail call void @___qfree(i64 %42)
  %44 = icmp ult i64 %"223_2.01152", 10
  br i1 %44, label %__barray_check_bounds.exit1095, label %out_of_bounds.i1094

cond_exit_227:                                    ; preds = %__barray_check_bounds.exit1095
  %45 = shl nuw nsw i64 1, %"223_2.01152"
  %46 = xor i64 %29, %45
  store i64 %46, ptr %3, align 4
  %47 = getelementptr inbounds nuw i64, ptr %2, i64 %"223_2.01152"
  store i64 %lazy_measure, ptr %47, align 4
  %48 = icmp samesign ugt i64 %"223_0.sroa.15.01153", 8
  br i1 %48, label %mask_block_ok.i, label %loop_body318.preheader

loop_body427.preheader.preheader:                 ; preds = %mask_block_ok.i
  tail call void @heap_free(ptr nonnull %4)
  tail call void @heap_free(ptr nonnull %5)
  br label %__barray_check_bounds.exit1103

__barray_check_bounds.exit1103:                   ; preds = %cond_exit_293, %loop_body427.preheader.preheader
  %"289_0.sroa.15.01147" = phi i64 [ %49, %cond_exit_293 ], [ 0, %loop_body427.preheader.preheader ]
  %49 = add nuw nsw i64 %"289_0.sroa.15.01147", 1
  %50 = load i64, ptr %3, align 4
  %51 = lshr i64 %50, %"289_0.sroa.15.01147"
  %52 = trunc i64 %51 to i1
  br i1 %52, label %panic.i1104, label %__barray_check_bounds.exit1107

panic.i1104:                                      ; preds = %__barray_check_bounds.exit1103
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1107:                   ; preds = %__barray_check_bounds.exit1103
  %53 = shl nuw nsw i64 1, %"289_0.sroa.15.01147"
  %54 = xor i64 %50, %53
  store i64 %54, ptr %3, align 4
  %55 = getelementptr inbounds nuw i64, ptr %2, i64 %"289_0.sroa.15.01147"
  %56 = load i64, ptr %55, align 4
  tail call void @___inc_future_refcount(i64 %56)
  %57 = load i64, ptr %3, align 4
  %58 = lshr i64 %57, %"289_0.sroa.15.01147"
  %59 = trunc i64 %58 to i1
  br i1 %59, label %__barray_check_bounds.exit1111, label %panic.i1108

panic.i1108:                                      ; preds = %__barray_check_bounds.exit1107
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit1111:                   ; preds = %__barray_check_bounds.exit1107
  %60 = xor i64 %57, %53
  store i64 %60, ptr %3, align 4
  store i64 %56, ptr %55, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %56)
  tail call void @___dec_future_refcount(i64 %56)
  %61 = load i64, ptr %1, align 4
  %62 = lshr i64 %61, %"289_0.sroa.15.01147"
  %63 = trunc i64 %62 to i1
  br i1 %63, label %cond_exit_293, label %panic.i1112

panic.i1112:                                      ; preds = %__barray_check_bounds.exit1111
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

mask_block_err.i1117:                             ; preds = %cond_exit_455.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit1125:                    ; preds = %__barray_check_bounds.exit1121.preheader
  %64 = or disjoint i64 %117, 1
  store i64 %64, ptr %3, align 4
  %65 = load i64, ptr %2, align 4
  tail call void @___dec_future_refcount(i64 %65)
  br label %cond_exit_455

cond_exit_455:                                    ; preds = %__barray_mask_borrow.exit1125, %__barray_check_bounds.exit1121.preheader
  %66 = load i64, ptr %3, align 4
  %67 = and i64 %66, 2
  %.not = icmp eq i64 %67, 0
  br i1 %.not, label %__barray_mask_borrow.exit1125.1, label %cond_exit_455.1

__barray_mask_borrow.exit1125.1:                  ; preds = %cond_exit_455
  %68 = or disjoint i64 %66, 2
  store i64 %68, ptr %3, align 4
  %69 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %70 = load i64, ptr %69, align 4
  tail call void @___dec_future_refcount(i64 %70)
  br label %cond_exit_455.1

cond_exit_455.1:                                  ; preds = %__barray_mask_borrow.exit1125.1, %cond_exit_455
  %71 = load i64, ptr %3, align 4
  %72 = and i64 %71, 4
  %.not1155 = icmp eq i64 %72, 0
  br i1 %.not1155, label %__barray_mask_borrow.exit1125.2, label %cond_exit_455.2

__barray_mask_borrow.exit1125.2:                  ; preds = %cond_exit_455.1
  %73 = or disjoint i64 %71, 4
  store i64 %73, ptr %3, align 4
  %74 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %75 = load i64, ptr %74, align 4
  tail call void @___dec_future_refcount(i64 %75)
  br label %cond_exit_455.2

cond_exit_455.2:                                  ; preds = %__barray_mask_borrow.exit1125.2, %cond_exit_455.1
  %76 = load i64, ptr %3, align 4
  %77 = and i64 %76, 8
  %.not1156 = icmp eq i64 %77, 0
  br i1 %.not1156, label %__barray_mask_borrow.exit1125.3, label %cond_exit_455.3

__barray_mask_borrow.exit1125.3:                  ; preds = %cond_exit_455.2
  %78 = or disjoint i64 %76, 8
  store i64 %78, ptr %3, align 4
  %79 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %80 = load i64, ptr %79, align 4
  tail call void @___dec_future_refcount(i64 %80)
  br label %cond_exit_455.3

cond_exit_455.3:                                  ; preds = %__barray_mask_borrow.exit1125.3, %cond_exit_455.2
  %81 = load i64, ptr %3, align 4
  %82 = and i64 %81, 16
  %.not1157 = icmp eq i64 %82, 0
  br i1 %.not1157, label %__barray_mask_borrow.exit1125.4, label %cond_exit_455.4

__barray_mask_borrow.exit1125.4:                  ; preds = %cond_exit_455.3
  %83 = or disjoint i64 %81, 16
  store i64 %83, ptr %3, align 4
  %84 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %85 = load i64, ptr %84, align 4
  tail call void @___dec_future_refcount(i64 %85)
  br label %cond_exit_455.4

cond_exit_455.4:                                  ; preds = %__barray_mask_borrow.exit1125.4, %cond_exit_455.3
  %86 = load i64, ptr %3, align 4
  %87 = and i64 %86, 32
  %.not1158 = icmp eq i64 %87, 0
  br i1 %.not1158, label %__barray_mask_borrow.exit1125.5, label %cond_exit_455.5

__barray_mask_borrow.exit1125.5:                  ; preds = %cond_exit_455.4
  %88 = or disjoint i64 %86, 32
  store i64 %88, ptr %3, align 4
  %89 = getelementptr inbounds nuw i8, ptr %2, i64 40
  %90 = load i64, ptr %89, align 4
  tail call void @___dec_future_refcount(i64 %90)
  br label %cond_exit_455.5

cond_exit_455.5:                                  ; preds = %__barray_mask_borrow.exit1125.5, %cond_exit_455.4
  %91 = load i64, ptr %3, align 4
  %92 = and i64 %91, 64
  %.not1159 = icmp eq i64 %92, 0
  br i1 %.not1159, label %__barray_mask_borrow.exit1125.6, label %cond_exit_455.6

__barray_mask_borrow.exit1125.6:                  ; preds = %cond_exit_455.5
  %93 = or disjoint i64 %91, 64
  store i64 %93, ptr %3, align 4
  %94 = getelementptr inbounds nuw i8, ptr %2, i64 48
  %95 = load i64, ptr %94, align 4
  tail call void @___dec_future_refcount(i64 %95)
  br label %cond_exit_455.6

cond_exit_455.6:                                  ; preds = %__barray_mask_borrow.exit1125.6, %cond_exit_455.5
  %96 = load i64, ptr %3, align 4
  %97 = and i64 %96, 128
  %.not1160 = icmp eq i64 %97, 0
  br i1 %.not1160, label %__barray_mask_borrow.exit1125.7, label %cond_exit_455.7

__barray_mask_borrow.exit1125.7:                  ; preds = %cond_exit_455.6
  %98 = or disjoint i64 %96, 128
  store i64 %98, ptr %3, align 4
  %99 = getelementptr inbounds nuw i8, ptr %2, i64 56
  %100 = load i64, ptr %99, align 4
  tail call void @___dec_future_refcount(i64 %100)
  br label %cond_exit_455.7

cond_exit_455.7:                                  ; preds = %__barray_mask_borrow.exit1125.7, %cond_exit_455.6
  %101 = load i64, ptr %3, align 4
  %102 = and i64 %101, 256
  %.not1161 = icmp eq i64 %102, 0
  br i1 %.not1161, label %__barray_mask_borrow.exit1125.8, label %cond_exit_455.8

__barray_mask_borrow.exit1125.8:                  ; preds = %cond_exit_455.7
  %103 = or disjoint i64 %101, 256
  store i64 %103, ptr %3, align 4
  %104 = getelementptr inbounds nuw i8, ptr %2, i64 64
  %105 = load i64, ptr %104, align 4
  tail call void @___dec_future_refcount(i64 %105)
  br label %cond_exit_455.8

cond_exit_455.8:                                  ; preds = %__barray_mask_borrow.exit1125.8, %cond_exit_455.7
  %106 = load i64, ptr %3, align 4
  %107 = and i64 %106, 512
  %.not1162 = icmp eq i64 %107, 0
  br i1 %.not1162, label %__barray_mask_borrow.exit1125.9, label %cond_exit_455.9

__barray_mask_borrow.exit1125.9:                  ; preds = %cond_exit_455.8
  %108 = or disjoint i64 %106, 512
  store i64 %108, ptr %3, align 4
  %109 = getelementptr inbounds nuw i8, ptr %2, i64 72
  %110 = load i64, ptr %109, align 4
  tail call void @___dec_future_refcount(i64 %110)
  br label %cond_exit_455.9

cond_exit_455.9:                                  ; preds = %__barray_mask_borrow.exit1125.9, %cond_exit_455.8
  %111 = load i64, ptr %3, align 4
  %112 = or i64 %111, -1024
  store i64 %112, ptr %3, align 4
  %113 = icmp eq i64 %112, -1
  br i1 %113, label %loop_out426, label %mask_block_err.i1117

cond_exit_293:                                    ; preds = %__barray_check_bounds.exit1111
  %114 = xor i64 %61, %53
  store i64 %114, ptr %1, align 4
  %115 = getelementptr inbounds nuw i1, ptr %0, i64 %"289_0.sroa.15.01147"
  store i1 %read_bool, ptr %115, align 1
  %116 = icmp eq i64 %"289_0.sroa.15.01147", 9
  br i1 %116, label %__barray_check_bounds.exit1121.preheader, label %__barray_check_bounds.exit1103

__barray_check_bounds.exit1121.preheader:         ; preds = %cond_exit_293
  %117 = load i64, ptr %3, align 4
  %118 = trunc i64 %117 to i1
  br i1 %118, label %cond_exit_455, label %__barray_mask_borrow.exit1125

loop_out426:                                      ; preds = %cond_exit_455.9
  tail call void @heap_free(ptr %2)
  tail call void @heap_free(ptr nonnull %3)
  %119 = load i64, ptr %1, align 4
  %120 = and i64 %119, 1023
  store i64 %120, ptr %1, align 4
  %121 = icmp eq i64 %120, 0
  br i1 %121, label %__barray_check_none_borrowed.exit, label %mask_block_err.i1126

mask_block_err.i1126:                             ; preds = %loop_out426
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %loop_out426
  %122 = tail call ptr @heap_alloc(i64 10)
  %123 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %123, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %122, ptr noundef nonnull align 1 dereferenceable(10) %0, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %122)
  %124 = load i64, ptr %1, align 4
  %125 = and i64 %124, 1023
  store i64 %125, ptr %1, align 4
  %126 = icmp eq i64 %125, 0
  br i1 %126, label %__barray_check_none_borrowed.exit1130, label %mask_block_err.i1128

mask_block_err.i1128:                             ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit1130:            ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %127 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %127, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %0, ptr %arr_ptr, align 8
  store ptr %127, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_measuremen.F30240EB.0, i64 25, ptr nonnull %out_arr_alloca)
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
