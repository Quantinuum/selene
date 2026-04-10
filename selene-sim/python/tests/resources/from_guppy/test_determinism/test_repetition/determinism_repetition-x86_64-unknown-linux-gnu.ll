; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

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

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i64 @get_current_shot() local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @heap_free(i8*) local_unnamed_addr

declare void @print_bool(i8*, i64, i1) local_unnamed_addr

declare void @print_int(i8*, i64, i64) local_unnamed_addr

declare i32 @random_int() local_unnamed_addr

declare double @random_float() local_unnamed_addr

declare void @print_float(i8*, i64, double) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @random_seed(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  %1 = tail call i8* @heap_alloc(i64 40)
  %2 = bitcast i8* %1 to i64*
  %3 = tail call i8* @heap_alloc(i64 8)
  %4 = bitcast i8* %3 to i64*
  store i64 -1, i64* %4, align 1
  %qalloc.i.i = tail call i64 @___qalloc()
  %not_max.not.i.i = icmp eq i64 %qalloc.i.i, -1
  br i1 %not_max.not.i.i, label %id_bb.i.i, label %reset_bb.i.i

panic.i.i:                                        ; preds = %cond_exit_20.4.i, %__barray_check_bounds.exit.4.i, %__barray_mask_return.exit.2.i, %__barray_mask_return.exit.1.i, %__barray_mask_return.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit1022.i:                 ; preds = %cond_exit_20.4.i
  %5 = xor i64 %77, 1
  store i64 %5, i64* %4, align 4
  %6 = load i64, i64* %2, align 4
  tail call void @___rxy(i64 %6, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %6, double 0x400921FB54442D18)
  %7 = load i64, i64* %4, align 4
  %8 = and i64 %7, 1
  %.not.i1023.i = icmp eq i64 %8, 0
  br i1 %.not.i1023.i, label %panic.i1024.i, label %__barray_mask_return.exit.i

panic.i1024.i:                                    ; preds = %__barray_check_bounds.exit1022.4.i, %__barray_check_bounds.exit1022.3.i, %__barray_check_bounds.exit1022.2.i, %__barray_check_bounds.exit1022.1.i, %__barray_check_bounds.exit1022.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit.i:                      ; preds = %__barray_check_bounds.exit1022.i
  %9 = xor i64 %7, 1
  store i64 %9, i64* %4, align 4
  store i64 %6, i64* %2, align 4
  %10 = load i64, i64* %4, align 4
  %11 = and i64 %10, 2
  %.not.i.1.i = icmp eq i64 %11, 0
  br i1 %.not.i.1.i, label %__barray_check_bounds.exit1022.1.i, label %panic.i.i

__barray_check_bounds.exit1022.1.i:               ; preds = %__barray_mask_return.exit.i
  %12 = xor i64 %10, 2
  store i64 %12, i64* %4, align 4
  %13 = load i64, i64* %55, align 4
  tail call void @___rxy(i64 %13, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %13, double 0x400921FB54442D18)
  %14 = load i64, i64* %4, align 4
  %15 = and i64 %14, 2
  %.not.i1023.1.i = icmp eq i64 %15, 0
  br i1 %.not.i1023.1.i, label %panic.i1024.i, label %__barray_mask_return.exit.1.i

__barray_mask_return.exit.1.i:                    ; preds = %__barray_check_bounds.exit1022.1.i
  %16 = xor i64 %14, 2
  store i64 %16, i64* %4, align 4
  store i64 %13, i64* %55, align 4
  %17 = load i64, i64* %4, align 4
  %18 = and i64 %17, 4
  %.not.i.2.i = icmp eq i64 %18, 0
  br i1 %.not.i.2.i, label %__barray_check_bounds.exit1022.2.i, label %panic.i.i

__barray_check_bounds.exit1022.2.i:               ; preds = %__barray_mask_return.exit.1.i
  %19 = xor i64 %17, 4
  store i64 %19, i64* %4, align 4
  %20 = load i64, i64* %62, align 4
  tail call void @___rxy(i64 %20, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %20, double 0x400921FB54442D18)
  %21 = load i64, i64* %4, align 4
  %22 = and i64 %21, 4
  %.not.i1023.2.i = icmp eq i64 %22, 0
  br i1 %.not.i1023.2.i, label %panic.i1024.i, label %__barray_mask_return.exit.2.i

__barray_mask_return.exit.2.i:                    ; preds = %__barray_check_bounds.exit1022.2.i
  %23 = xor i64 %21, 4
  store i64 %23, i64* %4, align 4
  store i64 %20, i64* %62, align 4
  %24 = load i64, i64* %4, align 4
  %25 = and i64 %24, 8
  %.not.i.3.i = icmp eq i64 %25, 0
  br i1 %.not.i.3.i, label %__barray_check_bounds.exit1022.3.i, label %panic.i.i

__barray_check_bounds.exit1022.3.i:               ; preds = %__barray_mask_return.exit.2.i
  %26 = xor i64 %24, 8
  store i64 %26, i64* %4, align 4
  %27 = load i64, i64* %69, align 4
  tail call void @___rxy(i64 %27, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %27, double 0x400921FB54442D18)
  %28 = load i64, i64* %4, align 4
  %29 = and i64 %28, 8
  %.not.i1023.3.i = icmp eq i64 %29, 0
  br i1 %.not.i1023.3.i, label %panic.i1024.i, label %__barray_check_bounds.exit.4.i

__barray_check_bounds.exit.4.i:                   ; preds = %__barray_check_bounds.exit1022.3.i
  %30 = xor i64 %28, 8
  store i64 %30, i64* %4, align 4
  store i64 %27, i64* %69, align 4
  %31 = load i64, i64* %4, align 4
  %32 = and i64 %31, 16
  %.not.i.4.i = icmp eq i64 %32, 0
  br i1 %.not.i.4.i, label %__barray_check_bounds.exit1022.4.i, label %panic.i.i

__barray_check_bounds.exit1022.4.i:               ; preds = %__barray_check_bounds.exit.4.i
  %33 = xor i64 %31, 16
  store i64 %33, i64* %4, align 4
  %34 = load i64, i64* %76, align 4
  tail call void @___rxy(i64 %34, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %34, double 0x400921FB54442D18)
  %35 = load i64, i64* %4, align 4
  %36 = and i64 %35, 16
  %.not.i1023.4.i = icmp eq i64 %36, 0
  br i1 %.not.i1023.4.i, label %panic.i1024.i, label %__barray_mask_return.exit.4.i

__barray_mask_return.exit.4.i:                    ; preds = %__barray_check_bounds.exit1022.4.i
  %37 = xor i64 %35, 16
  store i64 %37, i64* %4, align 4
  store i64 %34, i64* %76, align 4
  %shot.i = tail call i64 @get_current_shot()
  %shot126.i = tail call i64 @get_current_shot()
  %38 = tail call i8* @heap_alloc(i64 120)
  %39 = bitcast i8* %38 to { i1, i64, i1 }*
  %40 = tail call i8* @heap_alloc(i64 8)
  %41 = bitcast i8* %40 to i64*
  store i64 -1, i64* %41, align 1
  %42 = load i64, i64* %4, align 4
  %43 = and i64 %42, 1
  %.not.i99.i.i.i = icmp eq i64 %43, 0
  br i1 %.not.i99.i.i.i, label %cond_551_case_1.i.i, label %panic.i.i.i.i

reset_bb.i.i:                                     ; preds = %entry
  tail call void @___reset(i64 %qalloc.i.i)
  br label %id_bb.i.i

id_bb.i.i:                                        ; preds = %reset_bb.i.i, %entry
  %44 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.i, 1
  %45 = select i1 %not_max.not.i.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %44
  %.fca.0.extract.i.i = extractvalue { i1, i64 } %45, 0
  br i1 %.fca.0.extract.i.i, label %__hugr__.__tk2_qalloc.410.exit.i, label %cond_405_case_0.i.i

cond_405_case_0.i.i:                              ; preds = %id_bb.i.4.i, %id_bb.i.3.i, %id_bb.i.2.i, %id_bb.i.1.i, %id_bb.i.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.410.exit.i:                 ; preds = %id_bb.i.i
  %46 = load i64, i64* %4, align 4
  %47 = and i64 %46, 1
  %.not.i1033.i = icmp eq i64 %47, 0
  br i1 %.not.i1033.i, label %panic.i1034.i, label %cond_exit_20.i

panic.i1034.i:                                    ; preds = %__barray_check_bounds.exit1032.4.i, %__hugr__.__tk2_qalloc.410.exit.3.i, %__hugr__.__tk2_qalloc.410.exit.2.i, %__hugr__.__tk2_qalloc.410.exit.1.i, %__hugr__.__tk2_qalloc.410.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_20.i:                                   ; preds = %__hugr__.__tk2_qalloc.410.exit.i
  %.fca.1.extract.i.i = extractvalue { i1, i64 } %45, 1
  %48 = xor i64 %46, 1
  store i64 %48, i64* %4, align 4
  store i64 %.fca.1.extract.i.i, i64* %2, align 4
  %qalloc.i.1.i = tail call i64 @___qalloc()
  %not_max.not.i.1.i = icmp eq i64 %qalloc.i.1.i, -1
  br i1 %not_max.not.i.1.i, label %id_bb.i.1.i, label %reset_bb.i.1.i

reset_bb.i.1.i:                                   ; preds = %cond_exit_20.i
  tail call void @___reset(i64 %qalloc.i.1.i)
  br label %id_bb.i.1.i

id_bb.i.1.i:                                      ; preds = %reset_bb.i.1.i, %cond_exit_20.i
  %49 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.1.i, 1
  %50 = select i1 %not_max.not.i.1.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %49
  %.fca.0.extract.i.1.i = extractvalue { i1, i64 } %50, 0
  br i1 %.fca.0.extract.i.1.i, label %__hugr__.__tk2_qalloc.410.exit.1.i, label %cond_405_case_0.i.i

__hugr__.__tk2_qalloc.410.exit.1.i:               ; preds = %id_bb.i.1.i
  %51 = load i64, i64* %4, align 4
  %52 = and i64 %51, 2
  %.not.i1033.1.i = icmp eq i64 %52, 0
  br i1 %.not.i1033.1.i, label %panic.i1034.i, label %cond_exit_20.1.i

cond_exit_20.1.i:                                 ; preds = %__hugr__.__tk2_qalloc.410.exit.1.i
  %.fca.1.extract.i.1.i = extractvalue { i1, i64 } %50, 1
  %53 = xor i64 %51, 2
  store i64 %53, i64* %4, align 4
  %54 = getelementptr inbounds i8, i8* %1, i64 8
  %55 = bitcast i8* %54 to i64*
  store i64 %.fca.1.extract.i.1.i, i64* %55, align 4
  %qalloc.i.2.i = tail call i64 @___qalloc()
  %not_max.not.i.2.i = icmp eq i64 %qalloc.i.2.i, -1
  br i1 %not_max.not.i.2.i, label %id_bb.i.2.i, label %reset_bb.i.2.i

reset_bb.i.2.i:                                   ; preds = %cond_exit_20.1.i
  tail call void @___reset(i64 %qalloc.i.2.i)
  br label %id_bb.i.2.i

id_bb.i.2.i:                                      ; preds = %reset_bb.i.2.i, %cond_exit_20.1.i
  %56 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.2.i, 1
  %57 = select i1 %not_max.not.i.2.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %56
  %.fca.0.extract.i.2.i = extractvalue { i1, i64 } %57, 0
  br i1 %.fca.0.extract.i.2.i, label %__hugr__.__tk2_qalloc.410.exit.2.i, label %cond_405_case_0.i.i

__hugr__.__tk2_qalloc.410.exit.2.i:               ; preds = %id_bb.i.2.i
  %58 = load i64, i64* %4, align 4
  %59 = and i64 %58, 4
  %.not.i1033.2.i = icmp eq i64 %59, 0
  br i1 %.not.i1033.2.i, label %panic.i1034.i, label %cond_exit_20.2.i

cond_exit_20.2.i:                                 ; preds = %__hugr__.__tk2_qalloc.410.exit.2.i
  %.fca.1.extract.i.2.i = extractvalue { i1, i64 } %57, 1
  %60 = xor i64 %58, 4
  store i64 %60, i64* %4, align 4
  %61 = getelementptr inbounds i8, i8* %1, i64 16
  %62 = bitcast i8* %61 to i64*
  store i64 %.fca.1.extract.i.2.i, i64* %62, align 4
  %qalloc.i.3.i = tail call i64 @___qalloc()
  %not_max.not.i.3.i = icmp eq i64 %qalloc.i.3.i, -1
  br i1 %not_max.not.i.3.i, label %id_bb.i.3.i, label %reset_bb.i.3.i

reset_bb.i.3.i:                                   ; preds = %cond_exit_20.2.i
  tail call void @___reset(i64 %qalloc.i.3.i)
  br label %id_bb.i.3.i

id_bb.i.3.i:                                      ; preds = %reset_bb.i.3.i, %cond_exit_20.2.i
  %63 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.3.i, 1
  %64 = select i1 %not_max.not.i.3.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %63
  %.fca.0.extract.i.3.i = extractvalue { i1, i64 } %64, 0
  br i1 %.fca.0.extract.i.3.i, label %__hugr__.__tk2_qalloc.410.exit.3.i, label %cond_405_case_0.i.i

__hugr__.__tk2_qalloc.410.exit.3.i:               ; preds = %id_bb.i.3.i
  %65 = load i64, i64* %4, align 4
  %66 = and i64 %65, 8
  %.not.i1033.3.i = icmp eq i64 %66, 0
  br i1 %.not.i1033.3.i, label %panic.i1034.i, label %cond_exit_20.3.i

cond_exit_20.3.i:                                 ; preds = %__hugr__.__tk2_qalloc.410.exit.3.i
  %.fca.1.extract.i.3.i = extractvalue { i1, i64 } %64, 1
  %67 = xor i64 %65, 8
  store i64 %67, i64* %4, align 4
  %68 = getelementptr inbounds i8, i8* %1, i64 24
  %69 = bitcast i8* %68 to i64*
  store i64 %.fca.1.extract.i.3.i, i64* %69, align 4
  %qalloc.i.4.i = tail call i64 @___qalloc()
  %not_max.not.i.4.i = icmp eq i64 %qalloc.i.4.i, -1
  br i1 %not_max.not.i.4.i, label %id_bb.i.4.i, label %reset_bb.i.4.i

reset_bb.i.4.i:                                   ; preds = %cond_exit_20.3.i
  tail call void @___reset(i64 %qalloc.i.4.i)
  br label %id_bb.i.4.i

id_bb.i.4.i:                                      ; preds = %reset_bb.i.4.i, %cond_exit_20.3.i
  %70 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.4.i, 1
  %71 = select i1 %not_max.not.i.4.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %70
  %.fca.0.extract.i.4.i = extractvalue { i1, i64 } %71, 0
  br i1 %.fca.0.extract.i.4.i, label %__barray_check_bounds.exit1032.4.i, label %cond_405_case_0.i.i

__barray_check_bounds.exit1032.4.i:               ; preds = %id_bb.i.4.i
  %72 = load i64, i64* %4, align 4
  %73 = and i64 %72, 16
  %.not.i1033.4.i = icmp eq i64 %73, 0
  br i1 %.not.i1033.4.i, label %panic.i1034.i, label %cond_exit_20.4.i

cond_exit_20.4.i:                                 ; preds = %__barray_check_bounds.exit1032.4.i
  %.fca.1.extract.i.4.i = extractvalue { i1, i64 } %71, 1
  %74 = xor i64 %72, 16
  store i64 %74, i64* %4, align 4
  %75 = getelementptr inbounds i8, i8* %1, i64 32
  %76 = bitcast i8* %75 to i64*
  store i64 %.fca.1.extract.i.4.i, i64* %76, align 4
  %77 = load i64, i64* %4, align 4
  %78 = and i64 %77, 1
  %.not.i.i = icmp eq i64 %78, 0
  br i1 %.not.i.i, label %__barray_check_bounds.exit1022.i, label %panic.i.i

cond_353_case_1.i:                                ; preds = %__barray_mask_borrow.exit1073.i
  tail call void @___inc_future_refcount(i64 %.fca.1.extract882.i)
  %79 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract882.i, 1
  %.pre.i = load i64, i64* %41, align 4
  br label %cond_exit_353.i

cond_exit_353.i:                                  ; preds = %__barray_mask_borrow.exit1073.i, %cond_353_case_1.i
  %80 = phi i64 [ %.pre.i, %cond_353_case_1.i ], [ %192, %__barray_mask_borrow.exit1073.i ]
  %.pn.i = phi { i1, i64, i1 } [ %79, %cond_353_case_1.i ], [ %193, %__barray_mask_borrow.exit1073.i ]
  %"0162.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %81 = and i64 %80, 1
  %.not.i1036.i = icmp eq i64 %81, 0
  br i1 %.not.i1036.i, label %panic.i1037.i, label %__barray_mask_return.exit1038.i

panic.i1037.i:                                    ; preds = %cond_exit_353.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit1038.i:                  ; preds = %cond_exit_353.i
  %"0164.fca.2.insert.i" = insertvalue { i1, i64, i1 } %193, i1 %"0162.sroa.6.0.i", 2
  %82 = xor i64 %80, 1
  store i64 %82, i64* %41, align 4
  store { i1, i64, i1 } %"0164.fca.2.insert.i", { i1, i64, i1 }* %39, align 4
  %83 = load i64, i64* %41, align 4
  %84 = and i64 %83, 2
  %.not.i1039.i = icmp eq i64 %84, 0
  br i1 %.not.i1039.i, label %__barray_mask_borrow.exit1041.i, label %panic.i1040.i

panic.i1040.i:                                    ; preds = %__barray_mask_return.exit1038.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit1041.i:                  ; preds = %__barray_mask_return.exit1038.i
  %85 = xor i64 %83, 2
  store i64 %85, i64* %41, align 4
  %86 = load { i1, i64, i1 }, { i1, i64, i1 }* %161, align 4
  %.fca.0.extract857.i = extractvalue { i1, i64, i1 } %86, 0
  %.fca.1.extract858.i = extractvalue { i1, i64, i1 } %86, 1
  br i1 %.fca.0.extract857.i, label %cond_308_case_1.i, label %cond_exit_308.i

cond_308_case_1.i:                                ; preds = %__barray_mask_borrow.exit1041.i
  tail call void @___inc_future_refcount(i64 %.fca.1.extract858.i)
  %87 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract858.i, 1
  %.pre1091.i = load i64, i64* %41, align 4
  br label %cond_exit_308.i

cond_exit_308.i:                                  ; preds = %cond_308_case_1.i, %__barray_mask_borrow.exit1041.i
  %88 = phi i64 [ %.pre1091.i, %cond_308_case_1.i ], [ %85, %__barray_mask_borrow.exit1041.i ]
  %.pn1017.i = phi { i1, i64, i1 } [ %87, %cond_308_case_1.i ], [ %86, %__barray_mask_borrow.exit1041.i ]
  %"0224.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn1017.i, 2
  %89 = and i64 %88, 2
  %.not.i1042.i = icmp eq i64 %89, 0
  br i1 %.not.i1042.i, label %panic.i1043.i, label %__barray_mask_return.exit1044.i

panic.i1043.i:                                    ; preds = %cond_exit_308.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit1044.i:                  ; preds = %cond_exit_308.i
  %"0226.fca.2.insert.i" = insertvalue { i1, i64, i1 } %86, i1 %"0224.sroa.6.0.i", 2
  %90 = xor i64 %88, 2
  store i64 %90, i64* %41, align 4
  store { i1, i64, i1 } %"0226.fca.2.insert.i", { i1, i64, i1 }* %161, align 4
  %91 = load i64, i64* %41, align 4
  %92 = and i64 %91, 4
  %.not.i1045.i = icmp eq i64 %92, 0
  br i1 %.not.i1045.i, label %__barray_mask_borrow.exit1047.i, label %panic.i1046.i

panic.i1046.i:                                    ; preds = %__barray_mask_return.exit1044.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit1047.i:                  ; preds = %__barray_mask_return.exit1044.i
  %93 = xor i64 %91, 4
  store i64 %93, i64* %41, align 4
  %94 = load { i1, i64, i1 }, { i1, i64, i1 }* %170, align 4
  %.fca.0.extract833.i = extractvalue { i1, i64, i1 } %94, 0
  %.fca.1.extract834.i = extractvalue { i1, i64, i1 } %94, 1
  br i1 %.fca.0.extract833.i, label %cond_602_case_1.i, label %cond_exit_602.i

cond_602_case_1.i:                                ; preds = %__barray_mask_borrow.exit1047.i
  tail call void @___inc_future_refcount(i64 %.fca.1.extract834.i)
  %95 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract834.i, 1
  %.pre1092.i = load i64, i64* %41, align 4
  br label %cond_exit_602.i

cond_exit_602.i:                                  ; preds = %cond_602_case_1.i, %__barray_mask_borrow.exit1047.i
  %96 = phi i64 [ %.pre1092.i, %cond_602_case_1.i ], [ %93, %__barray_mask_borrow.exit1047.i ]
  %.pn1018.i = phi { i1, i64, i1 } [ %95, %cond_602_case_1.i ], [ %94, %__barray_mask_borrow.exit1047.i ]
  %"0286.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn1018.i, 2
  %97 = and i64 %96, 4
  %.not.i1048.i = icmp eq i64 %97, 0
  br i1 %.not.i1048.i, label %panic.i1049.i, label %__barray_mask_return.exit1050.i

panic.i1049.i:                                    ; preds = %cond_exit_602.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit1050.i:                  ; preds = %cond_exit_602.i
  %"0288.fca.2.insert.i" = insertvalue { i1, i64, i1 } %94, i1 %"0286.sroa.6.0.i", 2
  %98 = xor i64 %96, 4
  store i64 %98, i64* %41, align 4
  store { i1, i64, i1 } %"0288.fca.2.insert.i", { i1, i64, i1 }* %170, align 4
  %99 = load i64, i64* %41, align 4
  %100 = and i64 %99, 8
  %.not.i1051.i = icmp eq i64 %100, 0
  br i1 %.not.i1051.i, label %__barray_mask_borrow.exit1053.i, label %panic.i1052.i

panic.i1052.i:                                    ; preds = %__barray_mask_return.exit1050.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit1053.i:                  ; preds = %__barray_mask_return.exit1050.i
  %101 = xor i64 %99, 8
  store i64 %101, i64* %41, align 4
  %102 = load { i1, i64, i1 }, { i1, i64, i1 }* %179, align 4
  %.fca.0.extract809.i = extractvalue { i1, i64, i1 } %102, 0
  %.fca.1.extract810.i = extractvalue { i1, i64, i1 } %102, 1
  br i1 %.fca.0.extract809.i, label %cond_650_case_1.i, label %cond_exit_650.i

cond_650_case_1.i:                                ; preds = %__barray_mask_borrow.exit1053.i
  tail call void @___inc_future_refcount(i64 %.fca.1.extract810.i)
  %103 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract810.i, 1
  %.pre1093.i = load i64, i64* %41, align 4
  br label %cond_exit_650.i

cond_exit_650.i:                                  ; preds = %cond_650_case_1.i, %__barray_mask_borrow.exit1053.i
  %104 = phi i64 [ %.pre1093.i, %cond_650_case_1.i ], [ %101, %__barray_mask_borrow.exit1053.i ]
  %.pn1019.i = phi { i1, i64, i1 } [ %103, %cond_650_case_1.i ], [ %102, %__barray_mask_borrow.exit1053.i ]
  %"0348.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn1019.i, 2
  %105 = and i64 %104, 8
  %.not.i1054.i = icmp eq i64 %105, 0
  br i1 %.not.i1054.i, label %panic.i1055.i, label %__barray_mask_return.exit1056.i

panic.i1055.i:                                    ; preds = %cond_exit_650.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit1056.i:                  ; preds = %cond_exit_650.i
  %"0350.fca.2.insert.i" = insertvalue { i1, i64, i1 } %102, i1 %"0348.sroa.6.0.i", 2
  %106 = xor i64 %104, 8
  store i64 %106, i64* %41, align 4
  store { i1, i64, i1 } %"0350.fca.2.insert.i", { i1, i64, i1 }* %179, align 4
  %107 = load i64, i64* %41, align 4
  %108 = and i64 %107, 16
  %.not.i1057.i = icmp eq i64 %108, 0
  br i1 %.not.i1057.i, label %__barray_mask_borrow.exit1059.i, label %panic.i1058.i

panic.i1058.i:                                    ; preds = %__barray_mask_return.exit1056.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit1059.i:                  ; preds = %__barray_mask_return.exit1056.i
  %109 = xor i64 %107, 16
  store i64 %109, i64* %41, align 4
  %110 = load { i1, i64, i1 }, { i1, i64, i1 }* %188, align 4
  %.fca.0.extract785.i = extractvalue { i1, i64, i1 } %110, 0
  %.fca.1.extract786.i = extractvalue { i1, i64, i1 } %110, 1
  br i1 %.fca.0.extract785.i, label %cond_698_case_1.i, label %cond_exit_698.i

cond_698_case_1.i:                                ; preds = %__barray_mask_borrow.exit1059.i
  tail call void @___inc_future_refcount(i64 %.fca.1.extract786.i)
  %111 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract786.i, 1
  %.pre1094.i = load i64, i64* %41, align 4
  br label %cond_exit_698.i

cond_exit_698.i:                                  ; preds = %cond_698_case_1.i, %__barray_mask_borrow.exit1059.i
  %112 = phi i64 [ %.pre1094.i, %cond_698_case_1.i ], [ %109, %__barray_mask_borrow.exit1059.i ]
  %.pn1020.i = phi { i1, i64, i1 } [ %111, %cond_698_case_1.i ], [ %110, %__barray_mask_borrow.exit1059.i ]
  %"0410.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn1020.i, 2
  %113 = and i64 %112, 16
  %.not.i1060.i = icmp eq i64 %113, 0
  br i1 %.not.i1060.i, label %panic.i1061.i, label %__barray_mask_return.exit1062.i

panic.i1061.i:                                    ; preds = %cond_exit_698.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit1062.i:                  ; preds = %cond_exit_698.i
  %"0412.fca.2.insert.i" = insertvalue { i1, i64, i1 } %110, i1 %"0410.sroa.6.0.i", 2
  %114 = xor i64 %112, 16
  store i64 %114, i64* %41, align 4
  store { i1, i64, i1 } %"0412.fca.2.insert.i", { i1, i64, i1 }* %188, align 4
  %115 = load i64, i64* %41, align 4
  %116 = and i64 %115, 1
  %.not.i = icmp eq i64 %116, 0
  br i1 %.not.i, label %__barray_mask_borrow.exit1069.i, label %cond_exit_785.i

mask_block_err.i.i:                               ; preds = %cond_exit_785.i.4
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit1069.i:                  ; preds = %__barray_mask_return.exit1062.i
  %117 = xor i64 %115, 1
  store i64 %117, i64* %41, align 4
  %118 = load { i1, i64, i1 }, { i1, i64, i1 }* %39, align 4
  %.fca.0.extract750.i = extractvalue { i1, i64, i1 } %118, 0
  br i1 %.fca.0.extract750.i, label %cond_808_case_1.i, label %cond_exit_785.i

cond_exit_785.i:                                  ; preds = %cond_808_case_1.i, %__barray_mask_borrow.exit1069.i, %__barray_mask_return.exit1062.i
  %119 = phi i64 [ %.pre, %cond_808_case_1.i ], [ %117, %__barray_mask_borrow.exit1069.i ], [ %115, %__barray_mask_return.exit1062.i ]
  %120 = and i64 %119, 2
  %.not.i.1 = icmp eq i64 %120, 0
  br i1 %.not.i.1, label %__barray_mask_borrow.exit1069.i.1, label %cond_exit_785.i.1

__barray_mask_borrow.exit1069.i.1:                ; preds = %cond_exit_785.i
  %121 = xor i64 %119, 2
  store i64 %121, i64* %41, align 4
  %122 = getelementptr inbounds i8, i8* %38, i64 24
  %123 = bitcast i8* %122 to { i1, i64, i1 }*
  %124 = load { i1, i64, i1 }, { i1, i64, i1 }* %123, align 4
  %.fca.0.extract750.i.1 = extractvalue { i1, i64, i1 } %124, 0
  br i1 %.fca.0.extract750.i.1, label %cond_808_case_1.i.1, label %cond_exit_785.i.1

cond_808_case_1.i.1:                              ; preds = %__barray_mask_borrow.exit1069.i.1
  %.fca.1.extract751.i.1 = extractvalue { i1, i64, i1 } %124, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract751.i.1)
  %.pre2 = load i64, i64* %41, align 4
  br label %cond_exit_785.i.1

cond_exit_785.i.1:                                ; preds = %cond_808_case_1.i.1, %__barray_mask_borrow.exit1069.i.1, %cond_exit_785.i
  %125 = phi i64 [ %.pre2, %cond_808_case_1.i.1 ], [ %121, %__barray_mask_borrow.exit1069.i.1 ], [ %119, %cond_exit_785.i ]
  %126 = and i64 %125, 4
  %.not.i.2 = icmp eq i64 %126, 0
  br i1 %.not.i.2, label %__barray_mask_borrow.exit1069.i.2, label %cond_exit_785.i.2

__barray_mask_borrow.exit1069.i.2:                ; preds = %cond_exit_785.i.1
  %127 = xor i64 %125, 4
  store i64 %127, i64* %41, align 4
  %128 = getelementptr inbounds i8, i8* %38, i64 48
  %129 = bitcast i8* %128 to { i1, i64, i1 }*
  %130 = load { i1, i64, i1 }, { i1, i64, i1 }* %129, align 4
  %.fca.0.extract750.i.2 = extractvalue { i1, i64, i1 } %130, 0
  br i1 %.fca.0.extract750.i.2, label %cond_808_case_1.i.2, label %cond_exit_785.i.2

cond_808_case_1.i.2:                              ; preds = %__barray_mask_borrow.exit1069.i.2
  %.fca.1.extract751.i.2 = extractvalue { i1, i64, i1 } %130, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract751.i.2)
  %.pre3 = load i64, i64* %41, align 4
  br label %cond_exit_785.i.2

cond_exit_785.i.2:                                ; preds = %cond_808_case_1.i.2, %__barray_mask_borrow.exit1069.i.2, %cond_exit_785.i.1
  %131 = phi i64 [ %.pre3, %cond_808_case_1.i.2 ], [ %127, %__barray_mask_borrow.exit1069.i.2 ], [ %125, %cond_exit_785.i.1 ]
  %132 = and i64 %131, 8
  %.not.i.3 = icmp eq i64 %132, 0
  br i1 %.not.i.3, label %__barray_mask_borrow.exit1069.i.3, label %cond_exit_785.i.3

__barray_mask_borrow.exit1069.i.3:                ; preds = %cond_exit_785.i.2
  %133 = xor i64 %131, 8
  store i64 %133, i64* %41, align 4
  %134 = getelementptr inbounds i8, i8* %38, i64 72
  %135 = bitcast i8* %134 to { i1, i64, i1 }*
  %136 = load { i1, i64, i1 }, { i1, i64, i1 }* %135, align 4
  %.fca.0.extract750.i.3 = extractvalue { i1, i64, i1 } %136, 0
  br i1 %.fca.0.extract750.i.3, label %cond_808_case_1.i.3, label %cond_exit_785.i.3

cond_808_case_1.i.3:                              ; preds = %__barray_mask_borrow.exit1069.i.3
  %.fca.1.extract751.i.3 = extractvalue { i1, i64, i1 } %136, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract751.i.3)
  %.pre4 = load i64, i64* %41, align 4
  br label %cond_exit_785.i.3

cond_exit_785.i.3:                                ; preds = %cond_808_case_1.i.3, %__barray_mask_borrow.exit1069.i.3, %cond_exit_785.i.2
  %137 = phi i64 [ %.pre4, %cond_808_case_1.i.3 ], [ %133, %__barray_mask_borrow.exit1069.i.3 ], [ %131, %cond_exit_785.i.2 ]
  %138 = and i64 %137, 16
  %.not.i.4 = icmp eq i64 %138, 0
  br i1 %.not.i.4, label %__barray_mask_borrow.exit1069.i.4, label %cond_exit_785.i.4

__barray_mask_borrow.exit1069.i.4:                ; preds = %cond_exit_785.i.3
  %139 = xor i64 %137, 16
  store i64 %139, i64* %41, align 4
  %140 = getelementptr inbounds i8, i8* %38, i64 96
  %141 = bitcast i8* %140 to { i1, i64, i1 }*
  %142 = load { i1, i64, i1 }, { i1, i64, i1 }* %141, align 4
  %.fca.0.extract750.i.4 = extractvalue { i1, i64, i1 } %142, 0
  br i1 %.fca.0.extract750.i.4, label %cond_808_case_1.i.4, label %cond_exit_785.i.4

cond_808_case_1.i.4:                              ; preds = %__barray_mask_borrow.exit1069.i.4
  %.fca.1.extract751.i.4 = extractvalue { i1, i64, i1 } %142, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract751.i.4)
  %.pre5 = load i64, i64* %41, align 4
  br label %cond_exit_785.i.4

cond_exit_785.i.4:                                ; preds = %cond_808_case_1.i.4, %__barray_mask_borrow.exit1069.i.4, %cond_exit_785.i.3
  %143 = phi i64 [ %.pre5, %cond_808_case_1.i.4 ], [ %139, %__barray_mask_borrow.exit1069.i.4 ], [ %137, %cond_exit_785.i.3 ]
  %144 = or i64 %143, -32
  store i64 %144, i64* %41, align 4
  %145 = icmp eq i64 %144, -1
  br i1 %145, label %loop_out447.i, label %mask_block_err.i.i

loop_out447.i:                                    ; preds = %cond_exit_785.i.4
  tail call void @heap_free(i8* nonnull %38)
  tail call void @heap_free(i8* nonnull %40)
  br i1 %.fca.0.extract881.i, label %cond_336_case_1.i, label %cond_exit_336.i

cond_808_case_1.i:                                ; preds = %__barray_mask_borrow.exit1069.i
  %.fca.1.extract751.i = extractvalue { i1, i64, i1 } %118, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract751.i)
  %.pre = load i64, i64* %41, align 4
  br label %cond_exit_785.i

cond_336_case_1.i:                                ; preds = %loop_out447.i
  %read_bool518.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract882.i)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract882.i)
  br label %cond_exit_336.i

cond_exit_336.i:                                  ; preds = %cond_336_case_1.i, %loop_out447.i
  %"0510.0.i" = phi i1 [ %read_bool518.i, %cond_336_case_1.i ], [ %"0162.sroa.6.0.i", %loop_out447.i ]
  tail call void @print_bool(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @res_a.A4A74DAF.0, i64 0, i64 0), i64 11, i1 %"0510.0.i")
  br i1 %.fca.0.extract857.i, label %cond_213_case_1.i, label %cond_exit_213.i

cond_213_case_1.i:                                ; preds = %cond_exit_336.i
  %read_bool543.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract858.i)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract858.i)
  br label %cond_exit_213.i

cond_exit_213.i:                                  ; preds = %cond_213_case_1.i, %cond_exit_336.i
  %"0535.0.i" = phi i1 [ %read_bool543.i, %cond_213_case_1.i ], [ %"0224.sroa.6.0.i", %cond_exit_336.i ]
  tail call void @print_bool(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @res_b.3BD50C23.0, i64 0, i64 0), i64 11, i1 %"0535.0.i")
  br i1 %.fca.0.extract833.i, label %cond_620_case_1.i, label %cond_exit_620.i

cond_620_case_1.i:                                ; preds = %cond_exit_213.i
  %read_bool569.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract834.i)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract834.i)
  br label %cond_exit_620.i

cond_exit_620.i:                                  ; preds = %cond_620_case_1.i, %cond_exit_213.i
  %"0561.0.i" = phi i1 [ %read_bool569.i, %cond_620_case_1.i ], [ %"0286.sroa.6.0.i", %cond_exit_213.i ]
  tail call void @print_bool(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @res_c.1C9EF4D1.0, i64 0, i64 0), i64 11, i1 %"0561.0.i")
  br i1 %.fca.0.extract809.i, label %cond_668_case_1.i, label %cond_exit_668.i

cond_668_case_1.i:                                ; preds = %cond_exit_620.i
  %read_bool595.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract810.i)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract810.i)
  br label %cond_exit_668.i

cond_exit_668.i:                                  ; preds = %cond_668_case_1.i, %cond_exit_620.i
  %"0587.0.i" = phi i1 [ %read_bool595.i, %cond_668_case_1.i ], [ %"0348.sroa.6.0.i", %cond_exit_620.i ]
  tail call void @print_bool(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @res_d.00B84DC7.0, i64 0, i64 0), i64 11, i1 %"0587.0.i")
  br i1 %.fca.0.extract785.i, label %cond_716_case_1.i, label %__hugr__.main.1.exit

cond_716_case_1.i:                                ; preds = %cond_exit_668.i
  %read_bool621.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract786.i)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract786.i)
  br label %__hugr__.main.1.exit

"__hugr__.$measure_array$$n(5).475.exit.i":       ; preds = %cond_exit_551.i.4.i
  tail call void @heap_free(i8* nonnull %1)
  tail call void @heap_free(i8* nonnull %3)
  %146 = load i64, i64* %41, align 4
  %147 = and i64 %146, 1
  %.not.i1071.i = icmp eq i64 %147, 0
  br i1 %.not.i1071.i, label %__barray_mask_borrow.exit1073.i, label %panic.i1072.i

mask_block_err.i.i.i.i:                           ; preds = %cond_exit_551.i.4.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

panic.i.i.i.i:                                    ; preds = %cond_exit_551.i.3.i, %cond_exit_551.i.2.i, %cond_exit_551.i.1.i, %cond_exit_551.i.i, %__barray_mask_return.exit.4.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_551_case_1.i.i:                              ; preds = %__barray_mask_return.exit.4.i
  %148 = xor i64 %42, 1
  store i64 %148, i64* %4, align 4
  %149 = load i64, i64* %2, align 4
  %lazy_measure.i.i = tail call i64 @___lazy_measure(i64 %149)
  tail call void @___qfree(i64 %149)
  %150 = load i64, i64* %41, align 4
  %151 = and i64 %150, 1
  %.not.i.i.i = icmp eq i64 %151, 0
  br i1 %.not.i.i.i, label %panic.i.i.i, label %cond_exit_551.i.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.4.i, %cond_551_case_1.i.3.i, %cond_551_case_1.i.2.i, %cond_551_case_1.i.1.i, %cond_551_case_1.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_551.i.i:                                ; preds = %cond_551_case_1.i.i
  %"565_054.fca.1.insert.i.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i.i, 1
  %152 = xor i64 %150, 1
  store i64 %152, i64* %41, align 4
  store { i1, i64, i1 } %"565_054.fca.1.insert.i.i", { i1, i64, i1 }* %39, align 4
  %153 = load i64, i64* %4, align 4
  %154 = and i64 %153, 2
  %.not.i99.i.i.1.i = icmp eq i64 %154, 0
  br i1 %.not.i99.i.i.1.i, label %cond_551_case_1.i.1.i, label %panic.i.i.i.i

cond_551_case_1.i.1.i:                            ; preds = %cond_exit_551.i.i
  %155 = xor i64 %153, 2
  store i64 %155, i64* %4, align 4
  %156 = load i64, i64* %55, align 4
  %lazy_measure.i.1.i = tail call i64 @___lazy_measure(i64 %156)
  tail call void @___qfree(i64 %156)
  %157 = load i64, i64* %41, align 4
  %158 = and i64 %157, 2
  %.not.i.i.1.i = icmp eq i64 %158, 0
  br i1 %.not.i.i.1.i, label %panic.i.i.i, label %cond_exit_551.i.1.i

cond_exit_551.i.1.i:                              ; preds = %cond_551_case_1.i.1.i
  %"565_054.fca.1.insert.i.1.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i.1.i, 1
  %159 = xor i64 %157, 2
  store i64 %159, i64* %41, align 4
  %160 = getelementptr inbounds i8, i8* %38, i64 24
  %161 = bitcast i8* %160 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"565_054.fca.1.insert.i.1.i", { i1, i64, i1 }* %161, align 4
  %162 = load i64, i64* %4, align 4
  %163 = and i64 %162, 4
  %.not.i99.i.i.2.i = icmp eq i64 %163, 0
  br i1 %.not.i99.i.i.2.i, label %cond_551_case_1.i.2.i, label %panic.i.i.i.i

cond_551_case_1.i.2.i:                            ; preds = %cond_exit_551.i.1.i
  %164 = xor i64 %162, 4
  store i64 %164, i64* %4, align 4
  %165 = load i64, i64* %62, align 4
  %lazy_measure.i.2.i = tail call i64 @___lazy_measure(i64 %165)
  tail call void @___qfree(i64 %165)
  %166 = load i64, i64* %41, align 4
  %167 = and i64 %166, 4
  %.not.i.i.2.i = icmp eq i64 %167, 0
  br i1 %.not.i.i.2.i, label %panic.i.i.i, label %cond_exit_551.i.2.i

cond_exit_551.i.2.i:                              ; preds = %cond_551_case_1.i.2.i
  %"565_054.fca.1.insert.i.2.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i.2.i, 1
  %168 = xor i64 %166, 4
  store i64 %168, i64* %41, align 4
  %169 = getelementptr inbounds i8, i8* %38, i64 48
  %170 = bitcast i8* %169 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"565_054.fca.1.insert.i.2.i", { i1, i64, i1 }* %170, align 4
  %171 = load i64, i64* %4, align 4
  %172 = and i64 %171, 8
  %.not.i99.i.i.3.i = icmp eq i64 %172, 0
  br i1 %.not.i99.i.i.3.i, label %cond_551_case_1.i.3.i, label %panic.i.i.i.i

cond_551_case_1.i.3.i:                            ; preds = %cond_exit_551.i.2.i
  %173 = xor i64 %171, 8
  store i64 %173, i64* %4, align 4
  %174 = load i64, i64* %69, align 4
  %lazy_measure.i.3.i = tail call i64 @___lazy_measure(i64 %174)
  tail call void @___qfree(i64 %174)
  %175 = load i64, i64* %41, align 4
  %176 = and i64 %175, 8
  %.not.i.i.3.i = icmp eq i64 %176, 0
  br i1 %.not.i.i.3.i, label %panic.i.i.i, label %cond_exit_551.i.3.i

cond_exit_551.i.3.i:                              ; preds = %cond_551_case_1.i.3.i
  %"565_054.fca.1.insert.i.3.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i.3.i, 1
  %177 = xor i64 %175, 8
  store i64 %177, i64* %41, align 4
  %178 = getelementptr inbounds i8, i8* %38, i64 72
  %179 = bitcast i8* %178 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"565_054.fca.1.insert.i.3.i", { i1, i64, i1 }* %179, align 4
  %180 = load i64, i64* %4, align 4
  %181 = and i64 %180, 16
  %.not.i99.i.i.4.i = icmp eq i64 %181, 0
  br i1 %.not.i99.i.i.4.i, label %__barray_check_bounds.exit.i.4.i, label %panic.i.i.i.i

__barray_check_bounds.exit.i.4.i:                 ; preds = %cond_exit_551.i.3.i
  %182 = xor i64 %180, 16
  store i64 %182, i64* %4, align 4
  %183 = load i64, i64* %76, align 4
  %lazy_measure.i.4.i = tail call i64 @___lazy_measure(i64 %183)
  tail call void @___qfree(i64 %183)
  %184 = load i64, i64* %41, align 4
  %185 = and i64 %184, 16
  %.not.i.i.4.i = icmp eq i64 %185, 0
  br i1 %.not.i.i.4.i, label %panic.i.i.i, label %cond_exit_551.i.4.i

cond_exit_551.i.4.i:                              ; preds = %__barray_check_bounds.exit.i.4.i
  %"565_054.fca.1.insert.i.4.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i.4.i, 1
  %186 = xor i64 %184, 16
  store i64 %186, i64* %41, align 4
  %187 = getelementptr inbounds i8, i8* %38, i64 96
  %188 = bitcast i8* %187 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"565_054.fca.1.insert.i.4.i", { i1, i64, i1 }* %188, align 4
  %189 = load i64, i64* %4, align 4
  %190 = or i64 %189, -32
  store i64 %190, i64* %4, align 4
  %191 = icmp eq i64 %190, -1
  br i1 %191, label %"__hugr__.$measure_array$$n(5).475.exit.i", label %mask_block_err.i.i.i.i

panic.i1072.i:                                    ; preds = %"__hugr__.$measure_array$$n(5).475.exit.i"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit1073.i:                  ; preds = %"__hugr__.$measure_array$$n(5).475.exit.i"
  %192 = xor i64 %146, 1
  store i64 %192, i64* %41, align 4
  %193 = load { i1, i64, i1 }, { i1, i64, i1 }* %39, align 4
  %.fca.0.extract881.i = extractvalue { i1, i64, i1 } %193, 0
  %.fca.1.extract882.i = extractvalue { i1, i64, i1 } %193, 1
  br i1 %.fca.0.extract881.i, label %cond_353_case_1.i, label %cond_exit_353.i

__hugr__.main.1.exit:                             ; preds = %cond_exit_668.i, %cond_716_case_1.i
  %"0613.0.i" = phi i1 [ %read_bool621.i, %cond_716_case_1.i ], [ %"0410.sroa.6.0.i", %cond_exit_668.i ]
  tail call void @print_bool(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @res_e.B9A29CAF.0, i64 0, i64 0), i64 11, i1 %"0613.0.i")
  tail call void @print_int(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @res_shot.6D86EAF7.0, i64 0, i64 0), i64 13, i64 %shot126.i)
  tail call void @random_seed(i64 %shot.i)
  %rint.i = tail call i32 @random_int()
  %rfloat.i = tail call double @random_float()
  %194 = sext i32 %rint.i to i64
  tail call void @print_int(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @res_random_int.805B8DD0.0, i64 0, i64 0), i64 19, i64 %194)
  tail call void @print_float(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @res_random_flo.4EFA2734.0, i64 0, i64 0), i64 23, double %rfloat.i)
  %195 = tail call i64 @teardown()
  ret i64 %195
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

attributes #0 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
