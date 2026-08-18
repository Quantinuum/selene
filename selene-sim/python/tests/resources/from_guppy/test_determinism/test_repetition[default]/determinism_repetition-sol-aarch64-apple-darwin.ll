; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@res_a.A4A74DAF.0 = private constant [12 x i8] c"\0BUSER:BOOL:a"
@res_b.3BD50C23.0 = private constant [12 x i8] c"\0BUSER:BOOL:b"
@res_c.1C9EF4D1.0 = private constant [12 x i8] c"\0BUSER:BOOL:c"
@res_d.00B84DC7.0 = private constant [12 x i8] c"\0BUSER:BOOL:d"
@res_e.B9A29CAF.0 = private constant [12 x i8] c"\0BUSER:BOOL:e"
@res_shot.6D86EAF7.0 = private constant [14 x i8] c"\0DUSER:INT:shot"
@res_random_int.805B8DD0.0 = private constant [20 x i8] c"\13USER:INT:random_int"
@res_random_flo.4EFA2734.0 = private constant [24 x i8] c"\17USER:FLOAT:random_float"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
cond_104_case_1:
  %0 = tail call ptr @heap_alloc(i64 40)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %shot = tail call i64 @get_current_shot()
  tail call void @random_seed(i64 %shot)
  %shot2 = tail call i64 @get_current_shot()
  %2 = tail call ptr @heap_alloc(i64 40)
  %3 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %3, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_535_case_0.i, label %__barray_check_bounds.exit

cond_535_case_0.i:                                ; preds = %cond_104_case_1.4, %cond_104_case_1.3, %cond_104_case_1.2, %cond_104_case_1.1, %cond_104_case_1
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %cond_104_case_1
  tail call void @___reset(i64 %qalloc.i)
  %4 = load i64, ptr %3, align 4
  %5 = trunc i64 %4 to i1
  br i1 %5, label %cond_104_case_1.1, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.4, %__barray_check_bounds.exit.3, %__barray_check_bounds.exit.2, %__barray_check_bounds.exit.1, %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_104_case_1.1:                                ; preds = %__barray_check_bounds.exit
  %6 = and i64 %4, -2
  store i64 %6, ptr %3, align 4
  store i64 %qalloc.i, ptr %2, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_535_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_104_case_1.1
  tail call void @___reset(i64 %qalloc.i.1)
  %7 = load i64, ptr %3, align 4
  %8 = and i64 %7, 2
  %.not1178 = icmp eq i64 %8, 0
  br i1 %.not1178, label %panic.i, label %cond_104_case_1.2

cond_104_case_1.2:                                ; preds = %__barray_check_bounds.exit.1
  %9 = and i64 %7, -3
  store i64 %9, ptr %3, align 4
  %10 = getelementptr inbounds nuw i8, ptr %2, i64 8
  store i64 %qalloc.i.1, ptr %10, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_535_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_104_case_1.2
  tail call void @___reset(i64 %qalloc.i.2)
  %11 = load i64, ptr %3, align 4
  %12 = and i64 %11, 4
  %.not1179 = icmp eq i64 %12, 0
  br i1 %.not1179, label %panic.i, label %cond_104_case_1.3

cond_104_case_1.3:                                ; preds = %__barray_check_bounds.exit.2
  %13 = and i64 %11, -5
  store i64 %13, ptr %3, align 4
  %14 = getelementptr inbounds nuw i8, ptr %2, i64 16
  store i64 %qalloc.i.2, ptr %14, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_535_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_104_case_1.3
  tail call void @___reset(i64 %qalloc.i.3)
  %15 = load i64, ptr %3, align 4
  %16 = and i64 %15, 8
  %.not1180 = icmp eq i64 %16, 0
  br i1 %.not1180, label %panic.i, label %cond_104_case_1.4

cond_104_case_1.4:                                ; preds = %__barray_check_bounds.exit.3
  %17 = and i64 %15, -9
  store i64 %17, ptr %3, align 4
  %18 = getelementptr inbounds nuw i8, ptr %2, i64 24
  store i64 %qalloc.i.3, ptr %18, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_535_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_104_case_1.4
  tail call void @___reset(i64 %qalloc.i.4)
  %19 = load i64, ptr %3, align 4
  %20 = and i64 %19, 16
  %.not1181 = icmp eq i64 %20, 0
  br i1 %.not1181, label %panic.i, label %cond_exit_104.5

cond_exit_104.5:                                  ; preds = %__barray_check_bounds.exit.4
  %21 = and i64 %19, -17
  store i64 %21, ptr %3, align 4
  %22 = getelementptr inbounds nuw i8, ptr %2, i64 32
  store i64 %qalloc.i.4, ptr %22, align 4
  %.pre = load i64, ptr %3, align 4
  %23 = trunc i64 %.pre to i1
  br i1 %23, label %panic.i1116, label %__barray_check_bounds.exit1118

panic.i1116:                                      ; preds = %__barray_check_bounds.exit1115.4, %__barray_mask_return.exit1120.2, %__barray_mask_return.exit1120.1, %__barray_mask_return.exit1120, %cond_exit_104.5
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit1118:                   ; preds = %cond_exit_104.5
  %24 = or disjoint i64 %.pre, 1
  store i64 %24, ptr %3, align 4
  %25 = load i64, ptr %2, align 4
  tail call void @___rp(i64 %25, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %25, double 0x400921FB54442D18)
  %26 = load i64, ptr %3, align 4
  %27 = trunc i64 %26 to i1
  br i1 %27, label %__barray_mask_return.exit1120, label %panic.i1119

panic.i1119:                                      ; preds = %__barray_check_bounds.exit1118.4, %__barray_check_bounds.exit1118.3, %__barray_check_bounds.exit1118.2, %__barray_check_bounds.exit1118.1, %__barray_check_bounds.exit1118
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1120:                    ; preds = %__barray_check_bounds.exit1118
  %28 = and i64 %26, -2
  store i64 %28, ptr %3, align 4
  store i64 %25, ptr %2, align 4
  %29 = load i64, ptr %3, align 4
  %30 = and i64 %29, 2
  %.not1182 = icmp eq i64 %30, 0
  br i1 %.not1182, label %__barray_check_bounds.exit1118.1, label %panic.i1116

__barray_check_bounds.exit1118.1:                 ; preds = %__barray_mask_return.exit1120
  %31 = or disjoint i64 %29, 2
  store i64 %31, ptr %3, align 4
  %32 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %33 = load i64, ptr %32, align 4
  tail call void @___rp(i64 %33, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %33, double 0x400921FB54442D18)
  %34 = load i64, ptr %3, align 4
  %35 = and i64 %34, 2
  %.not1183 = icmp eq i64 %35, 0
  br i1 %.not1183, label %panic.i1119, label %__barray_mask_return.exit1120.1

__barray_mask_return.exit1120.1:                  ; preds = %__barray_check_bounds.exit1118.1
  %36 = and i64 %34, -3
  store i64 %36, ptr %3, align 4
  store i64 %33, ptr %32, align 4
  %37 = load i64, ptr %3, align 4
  %38 = and i64 %37, 4
  %.not1184 = icmp eq i64 %38, 0
  br i1 %.not1184, label %__barray_check_bounds.exit1118.2, label %panic.i1116

__barray_check_bounds.exit1118.2:                 ; preds = %__barray_mask_return.exit1120.1
  %39 = or disjoint i64 %37, 4
  store i64 %39, ptr %3, align 4
  %40 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %41 = load i64, ptr %40, align 4
  tail call void @___rp(i64 %41, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %41, double 0x400921FB54442D18)
  %42 = load i64, ptr %3, align 4
  %43 = and i64 %42, 4
  %.not1185 = icmp eq i64 %43, 0
  br i1 %.not1185, label %panic.i1119, label %__barray_mask_return.exit1120.2

__barray_mask_return.exit1120.2:                  ; preds = %__barray_check_bounds.exit1118.2
  %44 = and i64 %42, -5
  store i64 %44, ptr %3, align 4
  store i64 %41, ptr %40, align 4
  %45 = load i64, ptr %3, align 4
  %46 = and i64 %45, 8
  %.not1186 = icmp eq i64 %46, 0
  br i1 %.not1186, label %__barray_check_bounds.exit1118.3, label %panic.i1116

__barray_check_bounds.exit1118.3:                 ; preds = %__barray_mask_return.exit1120.2
  %47 = or disjoint i64 %45, 8
  store i64 %47, ptr %3, align 4
  %48 = getelementptr inbounds nuw i8, ptr %2, i64 24
  %49 = load i64, ptr %48, align 4
  tail call void @___rp(i64 %49, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %49, double 0x400921FB54442D18)
  %50 = load i64, ptr %3, align 4
  %51 = and i64 %50, 8
  %.not1187 = icmp eq i64 %51, 0
  br i1 %.not1187, label %panic.i1119, label %__barray_check_bounds.exit1115.4

__barray_check_bounds.exit1115.4:                 ; preds = %__barray_check_bounds.exit1118.3
  %52 = and i64 %50, -9
  store i64 %52, ptr %3, align 4
  store i64 %49, ptr %48, align 4
  %53 = load i64, ptr %3, align 4
  %54 = and i64 %53, 16
  %.not1188 = icmp eq i64 %54, 0
  br i1 %.not1188, label %__barray_check_bounds.exit1118.4, label %panic.i1116

__barray_check_bounds.exit1118.4:                 ; preds = %__barray_check_bounds.exit1115.4
  %55 = or disjoint i64 %53, 16
  store i64 %55, ptr %3, align 4
  %56 = getelementptr inbounds nuw i8, ptr %2, i64 32
  %57 = load i64, ptr %56, align 4
  tail call void @___rp(i64 %57, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %57, double 0x400921FB54442D18)
  %58 = load i64, ptr %3, align 4
  %59 = and i64 %58, 16
  %.not1189 = icmp eq i64 %59, 0
  br i1 %.not1189, label %panic.i1119, label %__barray_mask_return.exit1120.4

__barray_mask_return.exit1120.4:                  ; preds = %__barray_check_bounds.exit1118.4
  %60 = and i64 %58, -17
  store i64 %60, ptr %3, align 4
  store i64 %57, ptr %56, align 4
  %61 = load i64, ptr %3, align 4
  %62 = trunc i64 %61 to i1
  br i1 %62, label %panic.i1127, label %.thread

panic.i1123:                                      ; preds = %__barray_check_bounds.exit1122.4, %.thread.3, %.thread.2, %.thread.1, %.thread
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_out318:                                      ; preds = %cond_exit_298.4
  tail call void @heap_free(ptr nonnull %2)
  tail call void @heap_free(ptr nonnull %3)
  %63 = load i64, ptr %1, align 4
  %64 = trunc i64 %63 to i1
  br i1 %64, label %panic.i1129, label %__barray_mask_borrow.exit1130

mask_block_err.i:                                 ; preds = %cond_exit_298.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i1127:                                      ; preds = %__barray_check_bounds.exit1126.4, %cond_exit_298.2, %cond_exit_298.1, %cond_exit_298, %__barray_mask_return.exit1120.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

.thread:                                          ; preds = %__barray_mask_return.exit1120.4
  %65 = or disjoint i64 %61, 1
  store i64 %65, ptr %3, align 4
  %66 = load i64, ptr %2, align 4
  %lazy_measure = tail call i64 @___lazy_measure(i64 %66)
  tail call void @___qfree(i64 %66)
  %67 = load i64, ptr %1, align 4
  %68 = trunc i64 %67 to i1
  br i1 %68, label %cond_exit_298, label %panic.i1123

cond_exit_298:                                    ; preds = %.thread
  %69 = and i64 %67, -2
  store i64 %69, ptr %1, align 4
  store i64 %lazy_measure, ptr %0, align 4
  %70 = load i64, ptr %3, align 4
  %71 = and i64 %70, 2
  %.not1190 = icmp eq i64 %71, 0
  br i1 %.not1190, label %.thread.1, label %panic.i1127

.thread.1:                                        ; preds = %cond_exit_298
  %72 = or disjoint i64 %70, 2
  store i64 %72, ptr %3, align 4
  %73 = load i64, ptr %32, align 4
  %lazy_measure.1 = tail call i64 @___lazy_measure(i64 %73)
  tail call void @___qfree(i64 %73)
  %74 = load i64, ptr %1, align 4
  %75 = and i64 %74, 2
  %.not1191 = icmp eq i64 %75, 0
  br i1 %.not1191, label %panic.i1123, label %cond_exit_298.1

cond_exit_298.1:                                  ; preds = %.thread.1
  %76 = and i64 %74, -3
  store i64 %76, ptr %1, align 4
  %77 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %lazy_measure.1, ptr %77, align 4
  %78 = load i64, ptr %3, align 4
  %79 = and i64 %78, 4
  %.not1192 = icmp eq i64 %79, 0
  br i1 %.not1192, label %.thread.2, label %panic.i1127

.thread.2:                                        ; preds = %cond_exit_298.1
  %80 = or disjoint i64 %78, 4
  store i64 %80, ptr %3, align 4
  %81 = load i64, ptr %40, align 4
  %lazy_measure.2 = tail call i64 @___lazy_measure(i64 %81)
  tail call void @___qfree(i64 %81)
  %82 = load i64, ptr %1, align 4
  %83 = and i64 %82, 4
  %.not1193 = icmp eq i64 %83, 0
  br i1 %.not1193, label %panic.i1123, label %cond_exit_298.2

cond_exit_298.2:                                  ; preds = %.thread.2
  %84 = and i64 %82, -5
  store i64 %84, ptr %1, align 4
  %85 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %lazy_measure.2, ptr %85, align 4
  %86 = load i64, ptr %3, align 4
  %87 = and i64 %86, 8
  %.not1194 = icmp eq i64 %87, 0
  br i1 %.not1194, label %.thread.3, label %panic.i1127

.thread.3:                                        ; preds = %cond_exit_298.2
  %88 = or disjoint i64 %86, 8
  store i64 %88, ptr %3, align 4
  %89 = load i64, ptr %48, align 4
  %lazy_measure.3 = tail call i64 @___lazy_measure(i64 %89)
  tail call void @___qfree(i64 %89)
  %90 = load i64, ptr %1, align 4
  %91 = and i64 %90, 8
  %.not1195 = icmp eq i64 %91, 0
  br i1 %.not1195, label %panic.i1123, label %__barray_check_bounds.exit1126.4

__barray_check_bounds.exit1126.4:                 ; preds = %.thread.3
  %92 = and i64 %90, -9
  store i64 %92, ptr %1, align 4
  %93 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %lazy_measure.3, ptr %93, align 4
  %94 = load i64, ptr %3, align 4
  %95 = and i64 %94, 16
  %.not1196 = icmp eq i64 %95, 0
  br i1 %.not1196, label %__barray_check_bounds.exit1122.4, label %panic.i1127

__barray_check_bounds.exit1122.4:                 ; preds = %__barray_check_bounds.exit1126.4
  %96 = or disjoint i64 %94, 16
  store i64 %96, ptr %3, align 4
  %97 = load i64, ptr %56, align 4
  %lazy_measure.4 = tail call i64 @___lazy_measure(i64 %97)
  tail call void @___qfree(i64 %97)
  %98 = load i64, ptr %1, align 4
  %99 = and i64 %98, 16
  %.not1197 = icmp eq i64 %99, 0
  br i1 %.not1197, label %panic.i1123, label %cond_exit_298.4

cond_exit_298.4:                                  ; preds = %__barray_check_bounds.exit1122.4
  %100 = and i64 %98, -17
  store i64 %100, ptr %1, align 4
  %101 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %lazy_measure.4, ptr %101, align 4
  %102 = load i64, ptr %3, align 4
  %103 = or i64 %102, -32
  store i64 %103, ptr %3, align 4
  %104 = icmp eq i64 %103, -1
  br i1 %104, label %loop_out318, label %mask_block_err.i

panic.i1129:                                      ; preds = %loop_out318
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1130:                    ; preds = %loop_out318
  %105 = or disjoint i64 %63, 1
  store i64 %105, ptr %1, align 4
  %106 = load i64, ptr %0, align 4
  tail call void @___inc_future_refcount(i64 %106)
  %107 = load i64, ptr %1, align 4
  %108 = trunc i64 %107 to i1
  br i1 %108, label %__barray_mask_return.exit1132, label %panic.i1131

panic.i1131:                                      ; preds = %__barray_mask_borrow.exit1130
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1132:                    ; preds = %__barray_mask_borrow.exit1130
  %109 = and i64 %107, -2
  store i64 %109, ptr %1, align 4
  store i64 %106, ptr %0, align 4
  %110 = load i64, ptr %1, align 4
  %111 = and i64 %110, 2
  %.not = icmp eq i64 %111, 0
  br i1 %.not, label %__barray_mask_borrow.exit1134, label %panic.i1133

panic.i1133:                                      ; preds = %__barray_mask_return.exit1132
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1134:                    ; preds = %__barray_mask_return.exit1132
  %112 = or disjoint i64 %110, 2
  store i64 %112, ptr %1, align 4
  %113 = load i64, ptr %77, align 4
  tail call void @___inc_future_refcount(i64 %113)
  %114 = load i64, ptr %1, align 4
  %115 = and i64 %114, 2
  %.not1168 = icmp eq i64 %115, 0
  br i1 %.not1168, label %panic.i1135, label %__barray_mask_return.exit1136

panic.i1135:                                      ; preds = %__barray_mask_borrow.exit1134
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1136:                    ; preds = %__barray_mask_borrow.exit1134
  %116 = and i64 %114, -3
  store i64 %116, ptr %1, align 4
  store i64 %113, ptr %77, align 4
  %117 = load i64, ptr %1, align 4
  %118 = and i64 %117, 4
  %.not1169 = icmp eq i64 %118, 0
  br i1 %.not1169, label %__barray_mask_borrow.exit1138, label %panic.i1137

panic.i1137:                                      ; preds = %__barray_mask_return.exit1136
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1138:                    ; preds = %__barray_mask_return.exit1136
  %119 = or disjoint i64 %117, 4
  store i64 %119, ptr %1, align 4
  %120 = load i64, ptr %85, align 4
  tail call void @___inc_future_refcount(i64 %120)
  %121 = load i64, ptr %1, align 4
  %122 = and i64 %121, 4
  %.not1170 = icmp eq i64 %122, 0
  br i1 %.not1170, label %panic.i1139, label %__barray_mask_return.exit1140

panic.i1139:                                      ; preds = %__barray_mask_borrow.exit1138
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1140:                    ; preds = %__barray_mask_borrow.exit1138
  %123 = and i64 %121, -5
  store i64 %123, ptr %1, align 4
  store i64 %120, ptr %85, align 4
  %124 = load i64, ptr %1, align 4
  %125 = and i64 %124, 8
  %.not1171 = icmp eq i64 %125, 0
  br i1 %.not1171, label %__barray_mask_borrow.exit1142, label %panic.i1141

panic.i1141:                                      ; preds = %__barray_mask_return.exit1140
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1142:                    ; preds = %__barray_mask_return.exit1140
  %126 = or disjoint i64 %124, 8
  store i64 %126, ptr %1, align 4
  %127 = load i64, ptr %93, align 4
  tail call void @___inc_future_refcount(i64 %127)
  %128 = load i64, ptr %1, align 4
  %129 = and i64 %128, 8
  %.not1172 = icmp eq i64 %129, 0
  br i1 %.not1172, label %panic.i1143, label %__barray_mask_return.exit1144

panic.i1143:                                      ; preds = %__barray_mask_borrow.exit1142
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1144:                    ; preds = %__barray_mask_borrow.exit1142
  %130 = and i64 %128, -9
  store i64 %130, ptr %1, align 4
  store i64 %127, ptr %93, align 4
  %131 = load i64, ptr %1, align 4
  %132 = and i64 %131, 16
  %.not1173 = icmp eq i64 %132, 0
  br i1 %.not1173, label %__barray_mask_borrow.exit1146, label %panic.i1145

panic.i1145:                                      ; preds = %__barray_mask_return.exit1144
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit1146:                    ; preds = %__barray_mask_return.exit1144
  %133 = or disjoint i64 %131, 16
  store i64 %133, ptr %1, align 4
  %134 = load i64, ptr %101, align 4
  tail call void @___inc_future_refcount(i64 %134)
  %135 = load i64, ptr %1, align 4
  %136 = and i64 %135, 16
  %.not1174 = icmp eq i64 %136, 0
  br i1 %.not1174, label %panic.i1147, label %__barray_mask_return.exit1148

panic.i1147:                                      ; preds = %__barray_mask_borrow.exit1146
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit1148:                    ; preds = %__barray_mask_borrow.exit1146
  %137 = and i64 %135, -17
  store i64 %137, ptr %1, align 4
  store i64 %134, ptr %101, align 4
  %138 = load i64, ptr %1, align 4
  %139 = trunc i64 %138 to i1
  br i1 %139, label %cond_exit_558, label %__barray_mask_borrow.exit1160

mask_block_err.i1152:                             ; preds = %cond_exit_558.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit1160:                    ; preds = %__barray_mask_return.exit1148
  %140 = or disjoint i64 %138, 1
  store i64 %140, ptr %1, align 4
  %141 = load i64, ptr %0, align 4
  tail call void @___dec_future_refcount(i64 %141)
  br label %cond_exit_558

cond_exit_558:                                    ; preds = %__barray_mask_borrow.exit1160, %__barray_mask_return.exit1148
  %142 = load i64, ptr %1, align 4
  %143 = and i64 %142, 2
  %.not1200 = icmp eq i64 %143, 0
  br i1 %.not1200, label %__barray_mask_borrow.exit1160.1, label %cond_exit_558.1

__barray_mask_borrow.exit1160.1:                  ; preds = %cond_exit_558
  %144 = or disjoint i64 %142, 2
  store i64 %144, ptr %1, align 4
  %145 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %146 = load i64, ptr %145, align 4
  tail call void @___dec_future_refcount(i64 %146)
  br label %cond_exit_558.1

cond_exit_558.1:                                  ; preds = %__barray_mask_borrow.exit1160.1, %cond_exit_558
  %147 = load i64, ptr %1, align 4
  %148 = and i64 %147, 4
  %.not1201 = icmp eq i64 %148, 0
  br i1 %.not1201, label %__barray_mask_borrow.exit1160.2, label %cond_exit_558.2

__barray_mask_borrow.exit1160.2:                  ; preds = %cond_exit_558.1
  %149 = or disjoint i64 %147, 4
  store i64 %149, ptr %1, align 4
  %150 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %151 = load i64, ptr %150, align 4
  tail call void @___dec_future_refcount(i64 %151)
  br label %cond_exit_558.2

cond_exit_558.2:                                  ; preds = %__barray_mask_borrow.exit1160.2, %cond_exit_558.1
  %152 = load i64, ptr %1, align 4
  %153 = and i64 %152, 8
  %.not1202 = icmp eq i64 %153, 0
  br i1 %.not1202, label %__barray_mask_borrow.exit1160.3, label %cond_exit_558.3

__barray_mask_borrow.exit1160.3:                  ; preds = %cond_exit_558.2
  %154 = or disjoint i64 %152, 8
  store i64 %154, ptr %1, align 4
  %155 = getelementptr inbounds nuw i8, ptr %0, i64 24
  %156 = load i64, ptr %155, align 4
  tail call void @___dec_future_refcount(i64 %156)
  br label %cond_exit_558.3

cond_exit_558.3:                                  ; preds = %__barray_mask_borrow.exit1160.3, %cond_exit_558.2
  %157 = load i64, ptr %1, align 4
  %158 = and i64 %157, 16
  %.not1203 = icmp eq i64 %158, 0
  br i1 %.not1203, label %__barray_mask_borrow.exit1160.4, label %cond_exit_558.4

__barray_mask_borrow.exit1160.4:                  ; preds = %cond_exit_558.3
  %159 = or disjoint i64 %157, 16
  store i64 %159, ptr %1, align 4
  %160 = getelementptr inbounds nuw i8, ptr %0, i64 32
  %161 = load i64, ptr %160, align 4
  tail call void @___dec_future_refcount(i64 %161)
  br label %cond_exit_558.4

cond_exit_558.4:                                  ; preds = %__barray_mask_borrow.exit1160.4, %cond_exit_558.3
  %162 = load i64, ptr %1, align 4
  %163 = or i64 %162, -32
  store i64 %163, ptr %1, align 4
  %164 = icmp eq i64 %163, -1
  br i1 %164, label %loop_out620, label %mask_block_err.i1152

loop_out620:                                      ; preds = %cond_exit_558.4
  tail call void @heap_free(ptr nonnull %0)
  tail call void @heap_free(ptr nonnull %1)
  %read_bool = tail call i1 @___read_future_bool(i64 %106)
  tail call void @___dec_future_refcount(i64 %106)
  tail call void @print_bool(ptr nonnull @res_a.A4A74DAF.0, i64 11, i1 %read_bool)
  %read_bool690 = tail call i1 @___read_future_bool(i64 %113)
  tail call void @___dec_future_refcount(i64 %113)
  tail call void @print_bool(ptr nonnull @res_b.3BD50C23.0, i64 11, i1 %read_bool690)
  %read_bool705 = tail call i1 @___read_future_bool(i64 %120)
  tail call void @___dec_future_refcount(i64 %120)
  tail call void @print_bool(ptr nonnull @res_c.1C9EF4D1.0, i64 11, i1 %read_bool705)
  %read_bool720 = tail call i1 @___read_future_bool(i64 %127)
  tail call void @___dec_future_refcount(i64 %127)
  tail call void @print_bool(ptr nonnull @res_d.00B84DC7.0, i64 11, i1 %read_bool720)
  %read_bool735 = tail call i1 @___read_future_bool(i64 %134)
  tail call void @___dec_future_refcount(i64 %134)
  tail call void @print_bool(ptr nonnull @res_e.B9A29CAF.0, i64 11, i1 %read_bool735)
  tail call void @print_int(ptr nonnull @res_shot.6D86EAF7.0, i64 13, i64 %shot2)
  %rint = tail call i32 @random_int()
  %rfloat = tail call double @random_float()
  %165 = sext i32 %rint to i64
  tail call void @print_int(ptr nonnull @res_random_int.805B8DD0.0, i64 19, i64 %165)
  tail call void @print_float(ptr nonnull @res_random_flo.4EFA2734.0, i64 23, double %rfloat)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

declare i64 @get_current_shot() local_unnamed_addr

declare void @random_seed(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare void @heap_free(ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare i32 @random_int() local_unnamed_addr

declare double @random_float() local_unnamed_addr

declare void @print_float(ptr, i64, double) local_unnamed_addr

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
