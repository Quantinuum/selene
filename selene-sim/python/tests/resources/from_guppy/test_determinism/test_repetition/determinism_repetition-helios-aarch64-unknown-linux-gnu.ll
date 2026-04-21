; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

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

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #0

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i64 @get_current_shot() local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool(ptr, i64, i1) local_unnamed_addr

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare i32 @random_int() local_unnamed_addr

declare double @random_float() local_unnamed_addr

declare void @print_float(ptr, i64, double) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @random_seed(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  %1 = tail call ptr @heap_alloc(i64 40)
  %2 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %2, align 1
  %qalloc.i.i = tail call i64 @___qalloc()
  %not_max.not.not.i.i = icmp eq i64 %qalloc.i.i, -1
  br i1 %not_max.not.not.i.i, label %cond_425_case_0.i.i, label %__hugr__.__tk2_qalloc.430.exit.i

cond_425_case_0.i.i:                              ; preds = %cond_exit_20.3.i, %cond_exit_20.2.i, %cond_exit_20.1.i, %cond_exit_20.i, %entry
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.430.exit.i:                 ; preds = %entry
  tail call void @___reset(i64 %qalloc.i.i)
  %3 = load i64, ptr %2, align 4
  %4 = trunc i64 %3 to i1
  br i1 %4, label %cond_exit_20.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.4.i, %__hugr__.__tk2_qalloc.430.exit.3.i, %__hugr__.__tk2_qalloc.430.exit.2.i, %__hugr__.__tk2_qalloc.430.exit.1.i, %__hugr__.__tk2_qalloc.430.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20.i:                                   ; preds = %__hugr__.__tk2_qalloc.430.exit.i
  %5 = and i64 %3, -2
  store i64 %5, ptr %2, align 4
  store i64 %qalloc.i.i, ptr %1, align 4
  %qalloc.i.1.i = tail call i64 @___qalloc()
  %not_max.not.not.i.1.i = icmp eq i64 %qalloc.i.1.i, -1
  br i1 %not_max.not.not.i.1.i, label %cond_425_case_0.i.i, label %__hugr__.__tk2_qalloc.430.exit.1.i

__hugr__.__tk2_qalloc.430.exit.1.i:               ; preds = %cond_exit_20.i
  tail call void @___reset(i64 %qalloc.i.1.i)
  %6 = load i64, ptr %2, align 4
  %7 = and i64 %6, 2
  %.not1026.i = icmp eq i64 %7, 0
  br i1 %.not1026.i, label %panic.i.i, label %cond_exit_20.1.i

cond_exit_20.1.i:                                 ; preds = %__hugr__.__tk2_qalloc.430.exit.1.i
  %8 = and i64 %6, -3
  store i64 %8, ptr %2, align 4
  %9 = getelementptr inbounds nuw i8, ptr %1, i64 8
  store i64 %qalloc.i.1.i, ptr %9, align 4
  %qalloc.i.2.i = tail call i64 @___qalloc()
  %not_max.not.not.i.2.i = icmp eq i64 %qalloc.i.2.i, -1
  br i1 %not_max.not.not.i.2.i, label %cond_425_case_0.i.i, label %__hugr__.__tk2_qalloc.430.exit.2.i

__hugr__.__tk2_qalloc.430.exit.2.i:               ; preds = %cond_exit_20.1.i
  tail call void @___reset(i64 %qalloc.i.2.i)
  %10 = load i64, ptr %2, align 4
  %11 = and i64 %10, 4
  %.not1027.i = icmp eq i64 %11, 0
  br i1 %.not1027.i, label %panic.i.i, label %cond_exit_20.2.i

cond_exit_20.2.i:                                 ; preds = %__hugr__.__tk2_qalloc.430.exit.2.i
  %12 = and i64 %10, -5
  store i64 %12, ptr %2, align 4
  %13 = getelementptr inbounds nuw i8, ptr %1, i64 16
  store i64 %qalloc.i.2.i, ptr %13, align 4
  %qalloc.i.3.i = tail call i64 @___qalloc()
  %not_max.not.not.i.3.i = icmp eq i64 %qalloc.i.3.i, -1
  br i1 %not_max.not.not.i.3.i, label %cond_425_case_0.i.i, label %__hugr__.__tk2_qalloc.430.exit.3.i

__hugr__.__tk2_qalloc.430.exit.3.i:               ; preds = %cond_exit_20.2.i
  tail call void @___reset(i64 %qalloc.i.3.i)
  %14 = load i64, ptr %2, align 4
  %15 = and i64 %14, 8
  %.not1028.i = icmp eq i64 %15, 0
  br i1 %.not1028.i, label %panic.i.i, label %cond_exit_20.3.i

cond_exit_20.3.i:                                 ; preds = %__hugr__.__tk2_qalloc.430.exit.3.i
  %16 = and i64 %14, -9
  store i64 %16, ptr %2, align 4
  %17 = getelementptr inbounds nuw i8, ptr %1, i64 24
  store i64 %qalloc.i.3.i, ptr %17, align 4
  %qalloc.i.4.i = tail call i64 @___qalloc()
  %not_max.not.not.i.4.i = icmp eq i64 %qalloc.i.4.i, -1
  br i1 %not_max.not.not.i.4.i, label %cond_425_case_0.i.i, label %__barray_check_bounds.exit.4.i

__barray_check_bounds.exit.4.i:                   ; preds = %cond_exit_20.3.i
  tail call void @___reset(i64 %qalloc.i.4.i)
  %18 = load i64, ptr %2, align 4
  %19 = and i64 %18, 16
  %.not1029.i = icmp eq i64 %19, 0
  br i1 %.not1029.i, label %panic.i.i, label %cond_exit_20.4.i

cond_exit_20.4.i:                                 ; preds = %__barray_check_bounds.exit.4.i
  %20 = and i64 %18, -17
  store i64 %20, ptr %2, align 4
  %21 = getelementptr inbounds nuw i8, ptr %1, i64 32
  store i64 %qalloc.i.4.i, ptr %21, align 4
  %22 = load i64, ptr %2, align 4
  %23 = trunc i64 %22 to i1
  br i1 %23, label %panic.i968.i, label %__barray_check_bounds.exit970.i

panic.i968.i:                                     ; preds = %__barray_check_bounds.exit967.4.i, %__barray_mask_return.exit972.2.i, %__barray_mask_return.exit972.1.i, %__barray_mask_return.exit972.i, %cond_exit_20.4.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit970.i:                  ; preds = %cond_exit_20.4.i
  %24 = or disjoint i64 %22, 1
  store i64 %24, ptr %2, align 4
  %25 = load i64, ptr %1, align 4
  tail call void @___rxy(i64 %25, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %25, double 0x400921FB54442D18)
  %26 = load i64, ptr %2, align 4
  %27 = trunc i64 %26 to i1
  br i1 %27, label %__barray_mask_return.exit972.i, label %panic.i971.i

panic.i971.i:                                     ; preds = %__barray_check_bounds.exit970.4.i, %__barray_check_bounds.exit970.3.i, %__barray_check_bounds.exit970.2.i, %__barray_check_bounds.exit970.1.i, %__barray_check_bounds.exit970.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit972.i:                   ; preds = %__barray_check_bounds.exit970.i
  %28 = and i64 %26, -2
  store i64 %28, ptr %2, align 4
  store i64 %25, ptr %1, align 4
  %29 = load i64, ptr %2, align 4
  %30 = and i64 %29, 2
  %.not1030.i = icmp eq i64 %30, 0
  br i1 %.not1030.i, label %__barray_check_bounds.exit970.1.i, label %panic.i968.i

__barray_check_bounds.exit970.1.i:                ; preds = %__barray_mask_return.exit972.i
  %31 = or disjoint i64 %29, 2
  store i64 %31, ptr %2, align 4
  %32 = load i64, ptr %9, align 4
  tail call void @___rxy(i64 %32, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %32, double 0x400921FB54442D18)
  %33 = load i64, ptr %2, align 4
  %34 = and i64 %33, 2
  %.not1031.i = icmp eq i64 %34, 0
  br i1 %.not1031.i, label %panic.i971.i, label %__barray_mask_return.exit972.1.i

__barray_mask_return.exit972.1.i:                 ; preds = %__barray_check_bounds.exit970.1.i
  %35 = and i64 %33, -3
  store i64 %35, ptr %2, align 4
  store i64 %32, ptr %9, align 4
  %36 = load i64, ptr %2, align 4
  %37 = and i64 %36, 4
  %.not1032.i = icmp eq i64 %37, 0
  br i1 %.not1032.i, label %__barray_check_bounds.exit970.2.i, label %panic.i968.i

__barray_check_bounds.exit970.2.i:                ; preds = %__barray_mask_return.exit972.1.i
  %38 = or disjoint i64 %36, 4
  store i64 %38, ptr %2, align 4
  %39 = load i64, ptr %13, align 4
  tail call void @___rxy(i64 %39, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %39, double 0x400921FB54442D18)
  %40 = load i64, ptr %2, align 4
  %41 = and i64 %40, 4
  %.not1033.i = icmp eq i64 %41, 0
  br i1 %.not1033.i, label %panic.i971.i, label %__barray_mask_return.exit972.2.i

__barray_mask_return.exit972.2.i:                 ; preds = %__barray_check_bounds.exit970.2.i
  %42 = and i64 %40, -5
  store i64 %42, ptr %2, align 4
  store i64 %39, ptr %13, align 4
  %43 = load i64, ptr %2, align 4
  %44 = and i64 %43, 8
  %.not1034.i = icmp eq i64 %44, 0
  br i1 %.not1034.i, label %__barray_check_bounds.exit970.3.i, label %panic.i968.i

__barray_check_bounds.exit970.3.i:                ; preds = %__barray_mask_return.exit972.2.i
  %45 = or disjoint i64 %43, 8
  store i64 %45, ptr %2, align 4
  %46 = load i64, ptr %17, align 4
  tail call void @___rxy(i64 %46, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %46, double 0x400921FB54442D18)
  %47 = load i64, ptr %2, align 4
  %48 = and i64 %47, 8
  %.not1035.i = icmp eq i64 %48, 0
  br i1 %.not1035.i, label %panic.i971.i, label %__barray_check_bounds.exit967.4.i

__barray_check_bounds.exit967.4.i:                ; preds = %__barray_check_bounds.exit970.3.i
  %49 = and i64 %47, -9
  store i64 %49, ptr %2, align 4
  store i64 %46, ptr %17, align 4
  %50 = load i64, ptr %2, align 4
  %51 = and i64 %50, 16
  %.not1036.i = icmp eq i64 %51, 0
  br i1 %.not1036.i, label %__barray_check_bounds.exit970.4.i, label %panic.i968.i

__barray_check_bounds.exit970.4.i:                ; preds = %__barray_check_bounds.exit967.4.i
  %52 = or disjoint i64 %50, 16
  store i64 %52, ptr %2, align 4
  %53 = load i64, ptr %21, align 4
  tail call void @___rxy(i64 %53, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %53, double 0x400921FB54442D18)
  %54 = load i64, ptr %2, align 4
  %55 = and i64 %54, 16
  %.not1037.i = icmp eq i64 %55, 0
  br i1 %.not1037.i, label %panic.i971.i, label %__barray_mask_return.exit972.4.i

__barray_mask_return.exit972.4.i:                 ; preds = %__barray_check_bounds.exit970.4.i
  %56 = and i64 %54, -17
  store i64 %56, ptr %2, align 4
  store i64 %53, ptr %21, align 4
  %shot.i = tail call i64 @get_current_shot()
  %shot121.i = tail call i64 @get_current_shot()
  %57 = tail call ptr @heap_alloc(i64 120)
  %58 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %58, align 1
  %59 = load i64, ptr %2, align 4
  %60 = trunc i64 %59 to i1
  br i1 %60, label %panic.i.i.i.i, label %__barray_check_bounds.exit.i.i

cond_390_case_0.i:                                ; preds = %__barray_mask_borrow.exit999.i
  %.fca.2.extract834.i = extractvalue { i1, i64, i1 } %158, 2
  br label %cond_exit_390.i

cond_390_case_1.i:                                ; preds = %__barray_mask_borrow.exit999.i
  %.fca.1.extract833.i = extractvalue { i1, i64, i1 } %158, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract833.i)
  %.pre.i = load i64, ptr %58, align 4
  br label %cond_exit_390.i

cond_exit_390.i:                                  ; preds = %cond_390_case_1.i, %cond_390_case_0.i
  %61 = phi i64 [ %.pre.i, %cond_390_case_1.i ], [ %157, %cond_390_case_0.i ]
  %"0148.sroa.3.0.i" = phi i64 [ %.fca.1.extract833.i, %cond_390_case_1.i ], [ undef, %cond_390_case_0.i ]
  %"0148.sroa.6.0.i" = phi i1 [ undef, %cond_390_case_1.i ], [ %.fca.2.extract834.i, %cond_390_case_0.i ]
  %62 = trunc i64 %61 to i1
  br i1 %62, label %__barray_mask_return.exit974.i, label %panic.i973.i

panic.i973.i:                                     ; preds = %cond_exit_390.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit974.i:                   ; preds = %cond_exit_390.i
  %"0150.fca.1.insert.i" = insertvalue { i1, i64, i1 } %158, i64 %"0148.sroa.3.0.i", 1
  %"0150.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"0150.fca.1.insert.i", i1 %"0148.sroa.6.0.i", 2
  %63 = and i64 %61, -2
  store i64 %63, ptr %58, align 4
  store { i1, i64, i1 } %"0150.fca.2.insert.i", ptr %57, align 4
  %64 = load i64, ptr %58, align 4
  %65 = and i64 %64, 2
  %.not.i = icmp eq i64 %65, 0
  br i1 %.not.i, label %__barray_mask_borrow.exit976.i, label %panic.i975.i

panic.i975.i:                                     ; preds = %__barray_mask_return.exit974.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit976.i:                   ; preds = %__barray_mask_return.exit974.i
  %66 = or disjoint i64 %64, 2
  store i64 %66, ptr %58, align 4
  %67 = load { i1, i64, i1 }, ptr %132, align 4
  %.fca.0.extract810.i = extractvalue { i1, i64, i1 } %67, 0
  br i1 %.fca.0.extract810.i, label %cond_320_case_1.i, label %cond_320_case_0.i

cond_320_case_0.i:                                ; preds = %__barray_mask_borrow.exit976.i
  %.fca.2.extract812.i = extractvalue { i1, i64, i1 } %67, 2
  br label %cond_exit_320.i

cond_320_case_1.i:                                ; preds = %__barray_mask_borrow.exit976.i
  %.fca.1.extract811.i = extractvalue { i1, i64, i1 } %67, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract811.i)
  %.pre1022.i = load i64, ptr %58, align 4
  br label %cond_exit_320.i

cond_exit_320.i:                                  ; preds = %cond_320_case_1.i, %cond_320_case_0.i
  %68 = phi i64 [ %.pre1022.i, %cond_320_case_1.i ], [ %66, %cond_320_case_0.i ]
  %"0204.sroa.3.0.i" = phi i64 [ %.fca.1.extract811.i, %cond_320_case_1.i ], [ undef, %cond_320_case_0.i ]
  %"0204.sroa.6.0.i" = phi i1 [ undef, %cond_320_case_1.i ], [ %.fca.2.extract812.i, %cond_320_case_0.i ]
  %69 = and i64 %68, 2
  %.not1012.i = icmp eq i64 %69, 0
  br i1 %.not1012.i, label %panic.i977.i, label %__barray_mask_return.exit978.i

panic.i977.i:                                     ; preds = %cond_exit_320.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit978.i:                   ; preds = %cond_exit_320.i
  %"0206.fca.1.insert.i" = insertvalue { i1, i64, i1 } %67, i64 %"0204.sroa.3.0.i", 1
  %"0206.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"0206.fca.1.insert.i", i1 %"0204.sroa.6.0.i", 2
  %70 = and i64 %68, -3
  store i64 %70, ptr %58, align 4
  store { i1, i64, i1 } %"0206.fca.2.insert.i", ptr %132, align 4
  %71 = load i64, ptr %58, align 4
  %72 = and i64 %71, 4
  %.not1013.i = icmp eq i64 %72, 0
  br i1 %.not1013.i, label %__barray_mask_borrow.exit980.i, label %panic.i979.i

panic.i979.i:                                     ; preds = %__barray_mask_return.exit978.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit980.i:                   ; preds = %__barray_mask_return.exit978.i
  %73 = or disjoint i64 %71, 4
  store i64 %73, ptr %58, align 4
  %74 = load { i1, i64, i1 }, ptr %140, align 4
  %.fca.0.extract788.i = extractvalue { i1, i64, i1 } %74, 0
  br i1 %.fca.0.extract788.i, label %cond_593_case_1.i, label %cond_593_case_0.i

cond_593_case_0.i:                                ; preds = %__barray_mask_borrow.exit980.i
  %.fca.2.extract790.i = extractvalue { i1, i64, i1 } %74, 2
  br label %cond_exit_593.i

cond_593_case_1.i:                                ; preds = %__barray_mask_borrow.exit980.i
  %.fca.1.extract789.i = extractvalue { i1, i64, i1 } %74, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract789.i)
  %.pre1023.i = load i64, ptr %58, align 4
  br label %cond_exit_593.i

cond_exit_593.i:                                  ; preds = %cond_593_case_1.i, %cond_593_case_0.i
  %75 = phi i64 [ %.pre1023.i, %cond_593_case_1.i ], [ %73, %cond_593_case_0.i ]
  %"0260.sroa.3.0.i" = phi i64 [ %.fca.1.extract789.i, %cond_593_case_1.i ], [ undef, %cond_593_case_0.i ]
  %"0260.sroa.6.0.i" = phi i1 [ undef, %cond_593_case_1.i ], [ %.fca.2.extract790.i, %cond_593_case_0.i ]
  %76 = and i64 %75, 4
  %.not1014.i = icmp eq i64 %76, 0
  br i1 %.not1014.i, label %panic.i981.i, label %__barray_mask_return.exit982.i

panic.i981.i:                                     ; preds = %cond_exit_593.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit982.i:                   ; preds = %cond_exit_593.i
  %"0262.fca.1.insert.i" = insertvalue { i1, i64, i1 } %74, i64 %"0260.sroa.3.0.i", 1
  %"0262.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"0262.fca.1.insert.i", i1 %"0260.sroa.6.0.i", 2
  %77 = and i64 %75, -5
  store i64 %77, ptr %58, align 4
  store { i1, i64, i1 } %"0262.fca.2.insert.i", ptr %140, align 4
  %78 = load i64, ptr %58, align 4
  %79 = and i64 %78, 8
  %.not1015.i = icmp eq i64 %79, 0
  br i1 %.not1015.i, label %__barray_mask_borrow.exit984.i, label %panic.i983.i

panic.i983.i:                                     ; preds = %__barray_mask_return.exit982.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit984.i:                   ; preds = %__barray_mask_return.exit982.i
  %80 = or disjoint i64 %78, 8
  store i64 %80, ptr %58, align 4
  %81 = load { i1, i64, i1 }, ptr %148, align 4
  %.fca.0.extract766.i = extractvalue { i1, i64, i1 } %81, 0
  br i1 %.fca.0.extract766.i, label %cond_638_case_1.i, label %cond_638_case_0.i

cond_638_case_0.i:                                ; preds = %__barray_mask_borrow.exit984.i
  %.fca.2.extract768.i = extractvalue { i1, i64, i1 } %81, 2
  br label %cond_exit_638.i

cond_638_case_1.i:                                ; preds = %__barray_mask_borrow.exit984.i
  %.fca.1.extract767.i = extractvalue { i1, i64, i1 } %81, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract767.i)
  %.pre1024.i = load i64, ptr %58, align 4
  br label %cond_exit_638.i

cond_exit_638.i:                                  ; preds = %cond_638_case_1.i, %cond_638_case_0.i
  %82 = phi i64 [ %.pre1024.i, %cond_638_case_1.i ], [ %80, %cond_638_case_0.i ]
  %"0316.sroa.3.0.i" = phi i64 [ %.fca.1.extract767.i, %cond_638_case_1.i ], [ undef, %cond_638_case_0.i ]
  %"0316.sroa.6.0.i" = phi i1 [ undef, %cond_638_case_1.i ], [ %.fca.2.extract768.i, %cond_638_case_0.i ]
  %83 = and i64 %82, 8
  %.not1016.i = icmp eq i64 %83, 0
  br i1 %.not1016.i, label %panic.i985.i, label %__barray_mask_return.exit986.i

panic.i985.i:                                     ; preds = %cond_exit_638.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit986.i:                   ; preds = %cond_exit_638.i
  %"0318.fca.1.insert.i" = insertvalue { i1, i64, i1 } %81, i64 %"0316.sroa.3.0.i", 1
  %"0318.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"0318.fca.1.insert.i", i1 %"0316.sroa.6.0.i", 2
  %84 = and i64 %82, -9
  store i64 %84, ptr %58, align 4
  store { i1, i64, i1 } %"0318.fca.2.insert.i", ptr %148, align 4
  %85 = load i64, ptr %58, align 4
  %86 = and i64 %85, 16
  %.not1017.i = icmp eq i64 %86, 0
  br i1 %.not1017.i, label %__barray_mask_borrow.exit988.i, label %panic.i987.i

panic.i987.i:                                     ; preds = %__barray_mask_return.exit986.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit988.i:                   ; preds = %__barray_mask_return.exit986.i
  %87 = or disjoint i64 %85, 16
  store i64 %87, ptr %58, align 4
  %88 = load { i1, i64, i1 }, ptr %116, align 4
  %.fca.0.extract744.i = extractvalue { i1, i64, i1 } %88, 0
  br i1 %.fca.0.extract744.i, label %cond_683_case_1.i, label %cond_683_case_0.i

cond_683_case_0.i:                                ; preds = %__barray_mask_borrow.exit988.i
  %.fca.2.extract746.i = extractvalue { i1, i64, i1 } %88, 2
  br label %cond_exit_683.i

cond_683_case_1.i:                                ; preds = %__barray_mask_borrow.exit988.i
  %.fca.1.extract745.i = extractvalue { i1, i64, i1 } %88, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract745.i)
  %.pre1025.i = load i64, ptr %58, align 4
  br label %cond_exit_683.i

cond_exit_683.i:                                  ; preds = %cond_683_case_1.i, %cond_683_case_0.i
  %89 = phi i64 [ %.pre1025.i, %cond_683_case_1.i ], [ %87, %cond_683_case_0.i ]
  %"0372.sroa.3.0.i" = phi i64 [ %.fca.1.extract745.i, %cond_683_case_1.i ], [ undef, %cond_683_case_0.i ]
  %"0372.sroa.6.0.i" = phi i1 [ undef, %cond_683_case_1.i ], [ %.fca.2.extract746.i, %cond_683_case_0.i ]
  %90 = and i64 %89, 16
  %.not1018.i = icmp eq i64 %90, 0
  br i1 %.not1018.i, label %panic.i989.i, label %__barray_mask_return.exit990.i

panic.i989.i:                                     ; preds = %cond_exit_683.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit990.i:                   ; preds = %cond_exit_683.i
  %"0374.fca.1.insert.i" = insertvalue { i1, i64, i1 } %88, i64 %"0372.sroa.3.0.i", 1
  %"0374.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"0374.fca.1.insert.i", i1 %"0372.sroa.6.0.i", 2
  %91 = and i64 %89, -17
  store i64 %91, ptr %58, align 4
  store { i1, i64, i1 } %"0374.fca.2.insert.i", ptr %116, align 4
  %92 = load i64, ptr %58, align 4
  %93 = trunc i64 %92 to i1
  br i1 %93, label %cond_exit_771.i, label %__barray_mask_borrow.exit996.i

mask_block_err.i.i:                               ; preds = %cond_exit_771.i.4
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit996.i:                   ; preds = %__barray_mask_return.exit990.i
  %94 = or disjoint i64 %92, 1
  store i64 %94, ptr %58, align 4
  %95 = load { i1, i64, i1 }, ptr %57, align 4
  %.fca.0.extract709.i = extractvalue { i1, i64, i1 } %95, 0
  br i1 %.fca.0.extract709.i, label %cond_794_case_1.i, label %cond_exit_771.i

cond_exit_771.i:                                  ; preds = %cond_794_case_1.i, %__barray_mask_borrow.exit996.i, %__barray_mask_return.exit990.i
  %96 = phi i64 [ %.pre, %cond_794_case_1.i ], [ %94, %__barray_mask_borrow.exit996.i ], [ %92, %__barray_mask_return.exit990.i ]
  %97 = and i64 %96, 2
  %.not = icmp eq i64 %97, 0
  br i1 %.not, label %__barray_mask_borrow.exit996.i.1, label %cond_exit_771.i.1

__barray_mask_borrow.exit996.i.1:                 ; preds = %cond_exit_771.i
  %98 = or disjoint i64 %96, 2
  store i64 %98, ptr %58, align 4
  %99 = load { i1, i64, i1 }, ptr %132, align 4
  %.fca.0.extract709.i.1 = extractvalue { i1, i64, i1 } %99, 0
  br i1 %.fca.0.extract709.i.1, label %cond_794_case_1.i.1, label %cond_exit_771.i.1

cond_794_case_1.i.1:                              ; preds = %__barray_mask_borrow.exit996.i.1
  %.fca.1.extract710.i.1 = extractvalue { i1, i64, i1 } %99, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract710.i.1)
  %.pre2 = load i64, ptr %58, align 4
  br label %cond_exit_771.i.1

cond_exit_771.i.1:                                ; preds = %cond_794_case_1.i.1, %__barray_mask_borrow.exit996.i.1, %cond_exit_771.i
  %100 = phi i64 [ %.pre2, %cond_794_case_1.i.1 ], [ %98, %__barray_mask_borrow.exit996.i.1 ], [ %96, %cond_exit_771.i ]
  %101 = and i64 %100, 4
  %.not6 = icmp eq i64 %101, 0
  br i1 %.not6, label %__barray_mask_borrow.exit996.i.2, label %cond_exit_771.i.2

__barray_mask_borrow.exit996.i.2:                 ; preds = %cond_exit_771.i.1
  %102 = or disjoint i64 %100, 4
  store i64 %102, ptr %58, align 4
  %103 = load { i1, i64, i1 }, ptr %140, align 4
  %.fca.0.extract709.i.2 = extractvalue { i1, i64, i1 } %103, 0
  br i1 %.fca.0.extract709.i.2, label %cond_794_case_1.i.2, label %cond_exit_771.i.2

cond_794_case_1.i.2:                              ; preds = %__barray_mask_borrow.exit996.i.2
  %.fca.1.extract710.i.2 = extractvalue { i1, i64, i1 } %103, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract710.i.2)
  %.pre3 = load i64, ptr %58, align 4
  br label %cond_exit_771.i.2

cond_exit_771.i.2:                                ; preds = %cond_794_case_1.i.2, %__barray_mask_borrow.exit996.i.2, %cond_exit_771.i.1
  %104 = phi i64 [ %.pre3, %cond_794_case_1.i.2 ], [ %102, %__barray_mask_borrow.exit996.i.2 ], [ %100, %cond_exit_771.i.1 ]
  %105 = and i64 %104, 8
  %.not7 = icmp eq i64 %105, 0
  br i1 %.not7, label %__barray_mask_borrow.exit996.i.3, label %cond_exit_771.i.3

__barray_mask_borrow.exit996.i.3:                 ; preds = %cond_exit_771.i.2
  %106 = or disjoint i64 %104, 8
  store i64 %106, ptr %58, align 4
  %107 = load { i1, i64, i1 }, ptr %148, align 4
  %.fca.0.extract709.i.3 = extractvalue { i1, i64, i1 } %107, 0
  br i1 %.fca.0.extract709.i.3, label %cond_794_case_1.i.3, label %cond_exit_771.i.3

cond_794_case_1.i.3:                              ; preds = %__barray_mask_borrow.exit996.i.3
  %.fca.1.extract710.i.3 = extractvalue { i1, i64, i1 } %107, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract710.i.3)
  %.pre4 = load i64, ptr %58, align 4
  br label %cond_exit_771.i.3

cond_exit_771.i.3:                                ; preds = %cond_794_case_1.i.3, %__barray_mask_borrow.exit996.i.3, %cond_exit_771.i.2
  %108 = phi i64 [ %.pre4, %cond_794_case_1.i.3 ], [ %106, %__barray_mask_borrow.exit996.i.3 ], [ %104, %cond_exit_771.i.2 ]
  %109 = and i64 %108, 16
  %.not8 = icmp eq i64 %109, 0
  br i1 %.not8, label %__barray_mask_borrow.exit996.i.4, label %cond_exit_771.i.4

__barray_mask_borrow.exit996.i.4:                 ; preds = %cond_exit_771.i.3
  %110 = or disjoint i64 %108, 16
  store i64 %110, ptr %58, align 4
  %111 = load { i1, i64, i1 }, ptr %116, align 4
  %.fca.0.extract709.i.4 = extractvalue { i1, i64, i1 } %111, 0
  br i1 %.fca.0.extract709.i.4, label %cond_794_case_1.i.4, label %cond_exit_771.i.4

cond_794_case_1.i.4:                              ; preds = %__barray_mask_borrow.exit996.i.4
  %.fca.1.extract710.i.4 = extractvalue { i1, i64, i1 } %111, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract710.i.4)
  %.pre5 = load i64, ptr %58, align 4
  br label %cond_exit_771.i.4

cond_exit_771.i.4:                                ; preds = %cond_794_case_1.i.4, %__barray_mask_borrow.exit996.i.4, %cond_exit_771.i.3
  %112 = phi i64 [ %.pre5, %cond_794_case_1.i.4 ], [ %110, %__barray_mask_borrow.exit996.i.4 ], [ %108, %cond_exit_771.i.3 ]
  %113 = or i64 %112, -32
  store i64 %113, ptr %58, align 4
  %114 = icmp eq i64 %113, -1
  br i1 %114, label %loop_out406.i, label %mask_block_err.i.i

loop_out406.i:                                    ; preds = %cond_exit_771.i.4
  tail call void @heap_free(ptr nonnull %57)
  tail call void @heap_free(ptr nonnull %58)
  br i1 %.fca.0.extract832.i, label %cond_341_case_1.i, label %cond_exit_341.i

cond_794_case_1.i:                                ; preds = %__barray_mask_borrow.exit996.i
  %.fca.1.extract710.i = extractvalue { i1, i64, i1 } %95, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract710.i)
  %.pre = load i64, ptr %58, align 4
  br label %cond_exit_771.i

cond_341_case_1.i:                                ; preds = %loop_out406.i
  %read_bool477.i = tail call i1 @___read_future_bool(i64 %"0148.sroa.3.0.i")
  tail call void @___dec_future_refcount(i64 %"0148.sroa.3.0.i")
  br label %cond_exit_341.i

cond_exit_341.i:                                  ; preds = %cond_341_case_1.i, %loop_out406.i
  %"0469.0.i" = phi i1 [ %read_bool477.i, %cond_341_case_1.i ], [ %"0148.sroa.6.0.i", %loop_out406.i ]
  tail call void @print_bool(ptr nonnull @res_a.A4A74DAF.0, i64 11, i1 %"0469.0.i")
  br i1 %.fca.0.extract810.i, label %cond_221_case_1.i, label %cond_exit_221.i

cond_221_case_1.i:                                ; preds = %cond_exit_341.i
  %read_bool502.i = tail call i1 @___read_future_bool(i64 %"0204.sroa.3.0.i")
  tail call void @___dec_future_refcount(i64 %"0204.sroa.3.0.i")
  br label %cond_exit_221.i

cond_exit_221.i:                                  ; preds = %cond_221_case_1.i, %cond_exit_341.i
  %"0494.0.i" = phi i1 [ %read_bool502.i, %cond_221_case_1.i ], [ %"0204.sroa.6.0.i", %cond_exit_341.i ]
  tail call void @print_bool(ptr nonnull @res_b.3BD50C23.0, i64 11, i1 %"0494.0.i")
  br i1 %.fca.0.extract788.i, label %cond_614_case_1.i, label %cond_exit_614.i

cond_614_case_1.i:                                ; preds = %cond_exit_221.i
  %read_bool528.i = tail call i1 @___read_future_bool(i64 %"0260.sroa.3.0.i")
  tail call void @___dec_future_refcount(i64 %"0260.sroa.3.0.i")
  br label %cond_exit_614.i

cond_exit_614.i:                                  ; preds = %cond_614_case_1.i, %cond_exit_221.i
  %"0520.0.i" = phi i1 [ %read_bool528.i, %cond_614_case_1.i ], [ %"0260.sroa.6.0.i", %cond_exit_221.i ]
  tail call void @print_bool(ptr nonnull @res_c.1C9EF4D1.0, i64 11, i1 %"0520.0.i")
  br i1 %.fca.0.extract766.i, label %cond_659_case_1.i, label %cond_exit_659.i

cond_659_case_1.i:                                ; preds = %cond_exit_614.i
  %read_bool554.i = tail call i1 @___read_future_bool(i64 %"0316.sroa.3.0.i")
  tail call void @___dec_future_refcount(i64 %"0316.sroa.3.0.i")
  br label %cond_exit_659.i

cond_exit_659.i:                                  ; preds = %cond_659_case_1.i, %cond_exit_614.i
  %"0546.0.i" = phi i1 [ %read_bool554.i, %cond_659_case_1.i ], [ %"0316.sroa.6.0.i", %cond_exit_614.i ]
  tail call void @print_bool(ptr nonnull @res_d.00B84DC7.0, i64 11, i1 %"0546.0.i")
  br i1 %.fca.0.extract744.i, label %cond_704_case_1.i, label %__hugr__.__main__.main.1.exit

cond_704_case_1.i:                                ; preds = %cond_exit_659.i
  %read_bool580.i = tail call i1 @___read_future_bool(i64 %"0372.sroa.3.0.i")
  tail call void @___dec_future_refcount(i64 %"0372.sroa.3.0.i")
  br label %__hugr__.__main__.main.1.exit

mask_block_ok.i.i.i.preheader.i:                  ; preds = %__barray_check_bounds.exit.i.4.i
  %"571_054.fca.1.insert.i.4.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i.4.i, 1
  %"571_054.fca.2.insert.i.4.i" = insertvalue { i1, i64, i1 } %"571_054.fca.1.insert.i.4.i", i1 undef, 2
  %115 = and i64 %153, -17
  store i64 %115, ptr %58, align 4
  %116 = getelementptr inbounds nuw i8, ptr %57, i64 96
  store { i1, i64, i1 } %"571_054.fca.2.insert.i.4.i", ptr %116, align 4
  %117 = load i64, ptr %2, align 4
  %118 = or i64 %117, -32
  store i64 %118, ptr %2, align 4
  %119 = icmp eq i64 %118, -1
  br i1 %119, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(5).480.exit.i", label %mask_block_err.i.i.i.i

mask_block_err.i.i.i.i:                           ; preds = %mask_block_ok.i.i.i.preheader.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

panic.i.i.i.i:                                    ; preds = %loop_body.i.3.i, %loop_body.i.2.i, %loop_body.i.1.i, %loop_body.i.i, %__barray_mask_return.exit972.4.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %__barray_mask_return.exit972.4.i
  %120 = or disjoint i64 %59, 1
  store i64 %120, ptr %2, align 4
  %121 = load i64, ptr %1, align 4
  %lazy_measure.i.i = tail call i64 @___lazy_measure(i64 %121)
  tail call void @___qfree(i64 %121)
  %122 = load i64, ptr %58, align 4
  %123 = trunc i64 %122 to i1
  br i1 %123, label %loop_body.i.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.4.i, %__barray_check_bounds.exit.i.3.i, %__barray_check_bounds.exit.i.2.i, %__barray_check_bounds.exit.i.1.i, %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i.i:                                    ; preds = %__barray_check_bounds.exit.i.i
  %"571_054.fca.1.insert.i.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i.i, 1
  %"571_054.fca.2.insert.i.i" = insertvalue { i1, i64, i1 } %"571_054.fca.1.insert.i.i", i1 undef, 2
  %124 = and i64 %122, -2
  store i64 %124, ptr %58, align 4
  store { i1, i64, i1 } %"571_054.fca.2.insert.i.i", ptr %57, align 4
  %125 = load i64, ptr %2, align 4
  %126 = and i64 %125, 2
  %.not1038.i = icmp eq i64 %126, 0
  br i1 %.not1038.i, label %__barray_check_bounds.exit.i.1.i, label %panic.i.i.i.i

__barray_check_bounds.exit.i.1.i:                 ; preds = %loop_body.i.i
  %127 = or disjoint i64 %125, 2
  store i64 %127, ptr %2, align 4
  %128 = load i64, ptr %9, align 4
  %lazy_measure.i.1.i = tail call i64 @___lazy_measure(i64 %128)
  tail call void @___qfree(i64 %128)
  %129 = load i64, ptr %58, align 4
  %130 = and i64 %129, 2
  %.not1039.i = icmp eq i64 %130, 0
  br i1 %.not1039.i, label %panic.i.i.i, label %loop_body.i.1.i

loop_body.i.1.i:                                  ; preds = %__barray_check_bounds.exit.i.1.i
  %"571_054.fca.1.insert.i.1.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i.1.i, 1
  %"571_054.fca.2.insert.i.1.i" = insertvalue { i1, i64, i1 } %"571_054.fca.1.insert.i.1.i", i1 undef, 2
  %131 = and i64 %129, -3
  store i64 %131, ptr %58, align 4
  %132 = getelementptr inbounds nuw i8, ptr %57, i64 24
  store { i1, i64, i1 } %"571_054.fca.2.insert.i.1.i", ptr %132, align 4
  %133 = load i64, ptr %2, align 4
  %134 = and i64 %133, 4
  %.not1040.i = icmp eq i64 %134, 0
  br i1 %.not1040.i, label %__barray_check_bounds.exit.i.2.i, label %panic.i.i.i.i

__barray_check_bounds.exit.i.2.i:                 ; preds = %loop_body.i.1.i
  %135 = or disjoint i64 %133, 4
  store i64 %135, ptr %2, align 4
  %136 = load i64, ptr %13, align 4
  %lazy_measure.i.2.i = tail call i64 @___lazy_measure(i64 %136)
  tail call void @___qfree(i64 %136)
  %137 = load i64, ptr %58, align 4
  %138 = and i64 %137, 4
  %.not1041.i = icmp eq i64 %138, 0
  br i1 %.not1041.i, label %panic.i.i.i, label %loop_body.i.2.i

loop_body.i.2.i:                                  ; preds = %__barray_check_bounds.exit.i.2.i
  %"571_054.fca.1.insert.i.2.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i.2.i, 1
  %"571_054.fca.2.insert.i.2.i" = insertvalue { i1, i64, i1 } %"571_054.fca.1.insert.i.2.i", i1 undef, 2
  %139 = and i64 %137, -5
  store i64 %139, ptr %58, align 4
  %140 = getelementptr inbounds nuw i8, ptr %57, i64 48
  store { i1, i64, i1 } %"571_054.fca.2.insert.i.2.i", ptr %140, align 4
  %141 = load i64, ptr %2, align 4
  %142 = and i64 %141, 8
  %.not1042.i = icmp eq i64 %142, 0
  br i1 %.not1042.i, label %__barray_check_bounds.exit.i.3.i, label %panic.i.i.i.i

__barray_check_bounds.exit.i.3.i:                 ; preds = %loop_body.i.2.i
  %143 = or disjoint i64 %141, 8
  store i64 %143, ptr %2, align 4
  %144 = load i64, ptr %17, align 4
  %lazy_measure.i.3.i = tail call i64 @___lazy_measure(i64 %144)
  tail call void @___qfree(i64 %144)
  %145 = load i64, ptr %58, align 4
  %146 = and i64 %145, 8
  %.not1043.i = icmp eq i64 %146, 0
  br i1 %.not1043.i, label %panic.i.i.i, label %loop_body.i.3.i

loop_body.i.3.i:                                  ; preds = %__barray_check_bounds.exit.i.3.i
  %"571_054.fca.1.insert.i.3.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i.3.i, 1
  %"571_054.fca.2.insert.i.3.i" = insertvalue { i1, i64, i1 } %"571_054.fca.1.insert.i.3.i", i1 undef, 2
  %147 = and i64 %145, -9
  store i64 %147, ptr %58, align 4
  %148 = getelementptr inbounds nuw i8, ptr %57, i64 72
  store { i1, i64, i1 } %"571_054.fca.2.insert.i.3.i", ptr %148, align 4
  %149 = load i64, ptr %2, align 4
  %150 = and i64 %149, 16
  %.not1044.i = icmp eq i64 %150, 0
  br i1 %.not1044.i, label %__barray_check_bounds.exit.i.4.i, label %panic.i.i.i.i

__barray_check_bounds.exit.i.4.i:                 ; preds = %loop_body.i.3.i
  %151 = or disjoint i64 %149, 16
  store i64 %151, ptr %2, align 4
  %152 = load i64, ptr %21, align 4
  %lazy_measure.i.4.i = tail call i64 @___lazy_measure(i64 %152)
  tail call void @___qfree(i64 %152)
  %153 = load i64, ptr %58, align 4
  %154 = and i64 %153, 16
  %.not1045.i = icmp eq i64 %154, 0
  br i1 %.not1045.i, label %panic.i.i.i, label %mask_block_ok.i.i.i.preheader.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(5).480.exit.i": ; preds = %mask_block_ok.i.i.i.preheader.i
  tail call void @heap_free(ptr nonnull %1)
  tail call void @heap_free(ptr nonnull %2)
  %155 = load i64, ptr %58, align 4
  %156 = trunc i64 %155 to i1
  br i1 %156, label %panic.i998.i, label %__barray_mask_borrow.exit999.i

panic.i998.i:                                     ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(5).480.exit.i"
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit999.i:                   ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(5).480.exit.i"
  %157 = or disjoint i64 %155, 1
  store i64 %157, ptr %58, align 4
  %158 = load { i1, i64, i1 }, ptr %57, align 4
  %.fca.0.extract832.i = extractvalue { i1, i64, i1 } %158, 0
  br i1 %.fca.0.extract832.i, label %cond_390_case_1.i, label %cond_390_case_0.i

__hugr__.__main__.main.1.exit:                    ; preds = %cond_exit_659.i, %cond_704_case_1.i
  %"0572.0.i" = phi i1 [ %read_bool580.i, %cond_704_case_1.i ], [ %"0372.sroa.6.0.i", %cond_exit_659.i ]
  tail call void @print_bool(ptr nonnull @res_e.B9A29CAF.0, i64 11, i1 %"0572.0.i")
  tail call void @print_int(ptr nonnull @res_shot.6D86EAF7.0, i64 13, i64 %shot121.i)
  tail call void @random_seed(i64 %shot.i)
  %rint.i = tail call i32 @random_int()
  %rfloat.i = tail call double @random_float()
  %159 = sext i32 %rint.i to i64
  tail call void @print_int(ptr nonnull @res_random_int.805B8DD0.0, i64 19, i64 %159)
  tail call void @print_float(ptr nonnull @res_random_flo.4EFA2734.0, i64 23, double %rfloat.i)
  %160 = tail call i64 @teardown()
  ret i64 %160
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
