; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_outcomes.9CB6D2E7.0 = private constant [22 x i8] c"\15USER:BOOLARR:outcomes"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 80)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit

cond_492_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.465.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_helios_qalloc.465.exit.8, %__hugr__.__tk2_helios_qalloc.465.exit.7, %__hugr__.__tk2_helios_qalloc.465.exit.6, %__hugr__.__tk2_helios_qalloc.465.exit.5, %__hugr__.__tk2_helios_qalloc.465.exit.4, %__hugr__.__tk2_helios_qalloc.465.exit.3, %__hugr__.__tk2_helios_qalloc.465.exit.2, %__hugr__.__tk2_helios_qalloc.465.exit.1, %__hugr__.__tk2_helios_qalloc.465.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.465.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit.1

__hugr__.__tk2_helios_qalloc.465.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not = icmp eq i64 %6, 0
  br i1 %.not, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.465.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit.2

__hugr__.__tk2_helios_qalloc.465.exit.2:          ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not416 = icmp eq i64 %10, 0
  br i1 %.not416, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_helios_qalloc.465.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit.3

__hugr__.__tk2_helios_qalloc.465.exit.3:          ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not417 = icmp eq i64 %14, 0
  br i1 %.not417, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_helios_qalloc.465.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit.4

__hugr__.__tk2_helios_qalloc.465.exit.4:          ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not418 = icmp eq i64 %18, 0
  br i1 %.not418, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_helios_qalloc.465.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit.5

__hugr__.__tk2_helios_qalloc.465.exit.5:          ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not419 = icmp eq i64 %22, 0
  br i1 %.not419, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_helios_qalloc.465.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit.6

__hugr__.__tk2_helios_qalloc.465.exit.6:          ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not420 = icmp eq i64 %26, 0
  br i1 %.not420, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_helios_qalloc.465.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit.7

__hugr__.__tk2_helios_qalloc.465.exit.7:          ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not421 = icmp eq i64 %30, 0
  br i1 %.not421, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__hugr__.__tk2_helios_qalloc.465.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_492_case_0.i, label %__hugr__.__tk2_helios_qalloc.465.exit.8

__hugr__.__tk2_helios_qalloc.465.exit.8:          ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not422 = icmp eq i64 %34, 0
  br i1 %.not422, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__hugr__.__tk2_helios_qalloc.465.exit.8
  %35 = and i64 %33, -257
  store i64 %35, ptr %1, align 4
  %36 = getelementptr inbounds nuw i8, ptr %0, i64 64
  store i64 %qalloc.i.8, ptr %36, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_492_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %37 = load i64, ptr %1, align 4
  %38 = and i64 %37, 512
  %.not423 = icmp eq i64 %38, 0
  br i1 %.not423, label %panic.i, label %cond_exit_20.9

cond_exit_20.9:                                   ; preds = %__barray_check_bounds.exit.9
  %39 = and i64 %37, -513
  store i64 %39, ptr %1, align 4
  %40 = getelementptr inbounds nuw i8, ptr %0, i64 72
  store i64 %qalloc.i.9, ptr %40, align 4
  %41 = load i64, ptr %1, align 4
  %42 = trunc i64 %41 to i1
  br i1 %42, label %panic.i364, label %__barray_mask_borrow.exit

panic.i364:                                       ; preds = %cond_exit_20.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit:                        ; preds = %cond_exit_20.9
  %43 = or disjoint i64 %41, 1
  store i64 %43, ptr %1, align 4
  %44 = load i64, ptr %0, align 4
  tail call void @___rxy(i64 %44, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %44, double 0x400921FB54442D18)
  %45 = load i64, ptr %1, align 4
  %46 = trunc i64 %45 to i1
  br i1 %46, label %__barray_mask_return.exit366, label %panic.i365

panic.i365:                                       ; preds = %__barray_mask_borrow.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit366:                     ; preds = %__barray_mask_borrow.exit
  %47 = and i64 %45, -2
  store i64 %47, ptr %1, align 4
  store i64 %44, ptr %0, align 4
  br label %__barray_check_bounds.exit368

__barray_check_bounds.exit368:                    ; preds = %__barray_mask_return.exit382, %__barray_mask_return.exit366
  %"54_0.0415" = phi i64 [ 0, %__barray_mask_return.exit366 ], [ %48, %__barray_mask_return.exit382 ]
  %48 = add nuw nsw i64 %"54_0.0415", 1
  %49 = load i64, ptr %1, align 4
  %50 = lshr i64 %49, %"54_0.0415"
  %51 = trunc i64 %50 to i1
  br i1 %51, label %panic.i369, label %__barray_mask_borrow.exit370

panic.i369:                                       ; preds = %__barray_check_bounds.exit368
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit370:                     ; preds = %__barray_check_bounds.exit368
  %52 = shl nuw nsw i64 1, %"54_0.0415"
  %53 = xor i64 %49, %52
  store i64 %53, ptr %1, align 4
  %54 = getelementptr inbounds nuw i64, ptr %0, i64 %"54_0.0415"
  %55 = load i64, ptr %54, align 4
  %56 = lshr i64 %53, %48
  %57 = trunc i64 %56 to i1
  br i1 %57, label %panic.i373, label %__barray_check_bounds.exit376

panic.i373:                                       ; preds = %__barray_mask_borrow.exit370
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit376:                    ; preds = %__barray_mask_borrow.exit370
  %58 = shl nuw nsw i64 2, %"54_0.0415"
  %59 = xor i64 %53, %58
  store i64 %59, ptr %1, align 4
  %60 = getelementptr inbounds nuw i64, ptr %0, i64 %48
  %61 = load i64, ptr %60, align 4
  tail call void @___rxy(i64 %61, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %55, i64 %61, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %55, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %61, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %61, double 0xBFF921FB54442D18)
  %62 = load i64, ptr %1, align 4
  %63 = lshr i64 %62, %"54_0.0415"
  %64 = trunc i64 %63 to i1
  br i1 %64, label %__barray_check_bounds.exit380, label %panic.i377

panic.i377:                                       ; preds = %__barray_check_bounds.exit376
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_check_bounds.exit380:                    ; preds = %__barray_check_bounds.exit376
  %65 = xor i64 %62, %52
  store i64 %65, ptr %1, align 4
  store i64 %55, ptr %54, align 4
  %66 = load i64, ptr %1, align 4
  %67 = lshr i64 %66, %48
  %68 = trunc i64 %67 to i1
  br i1 %68, label %__barray_mask_return.exit382, label %panic.i381

panic.i381:                                       ; preds = %__barray_check_bounds.exit380
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit382:                     ; preds = %__barray_check_bounds.exit380
  %69 = xor i64 %66, %58
  store i64 %69, ptr %1, align 4
  store i64 %61, ptr %60, align 4
  %exitcond.not = icmp eq i64 %48, 9
  br i1 %exitcond.not, label %cond_exit_89, label %__barray_check_bounds.exit368

cond_exit_89:                                     ; preds = %__barray_mask_return.exit382
  %"54_380.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"54_380.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"54_380.fca.0.insert", ptr %1, 1
  %"54_380.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"54_380.fca.1.insert", i64 0, 2
  %70 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"54_380.fca.2.insert", 0
  %71 = tail call ptr @heap_alloc(i64 80)
  %72 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %72, align 1
  br label %__barray_check_bounds.exit.i.i

73:                                               ; preds = %loop_body.i
  %74 = lshr i64 %.fca.2.extract.i.i, 6
  %75 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %74
  %76 = load i64, ptr %75, align 4
  %77 = and i64 %.fca.2.extract.i.i, 63
  %78 = sub nuw nsw i64 64, %77
  %79 = lshr i64 -1, %78
  %80 = icmp eq i64 %77, 0
  %81 = select i1 %80, i64 0, i64 %79
  %82 = or i64 %76, %81
  store i64 %82, ptr %75, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %83 = lshr i64 %last_valid.i.i.i, 6
  %84 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %83
  %85 = load i64, ptr %84, align 4
  %86 = and i64 %last_valid.i.i.i, 63
  %87 = shl nsw i64 -2, %86
  %88 = icmp eq i64 %86, 63
  %89 = select i1 %88, i64 0, i64 %87
  %90 = or i64 %85, %89
  store i64 %90, ptr %84, align 4
  %reass.sub.i.i.i = sub nsw i64 %83, %74
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit", label %mask_block_ok.i.i.i

91:                                               ; preds = %mask_block_ok.i.i.i
  %92 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %73, %91
  %.02.i.i.i = phi i64 [ %92, %91 ], [ 0, %73 ]
  %gep.i.i.i = getelementptr i64, ptr %75, i64 %.02.i.i.i
  %93 = load i64, ptr %gep.i.i.i, align 4
  %94 = icmp eq i64 %93, -1
  br i1 %94, label %91, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_89
  %.fca.2.extract.i181.i = phi i64 [ 0, %cond_exit_89 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %cond_exit_89 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %cond_exit_89 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"270_0.sroa.15.0178.i" = phi i64 [ 0, %cond_exit_89 ], [ %95, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %70, %cond_exit_89 ], [ %110, %loop_body.i ]
  %95 = add nuw nsw i64 %"270_0.sroa.15.0178.i", 1
  %96 = add i64 %"270_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %97 = lshr i64 %96, 6
  %98 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %97
  %99 = load i64, ptr %98, align 4
  %100 = and i64 %96, 63
  %101 = lshr i64 %99, %100
  %102 = trunc i64 %101 to i1
  br i1 %102, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %103 = shl nuw i64 1, %100
  %104 = xor i64 %103, %99
  store i64 %104, ptr %98, align 4
  %105 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %96
  %106 = load i64, ptr %105, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %106)
  tail call void @___qfree(i64 %106)
  %107 = load i64, ptr %72, align 4
  %108 = lshr i64 %107, %"270_0.sroa.15.0178.i"
  %109 = trunc i64 %108 to i1
  br i1 %109, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %110 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %95, 1
  %111 = shl nuw nsw i64 1, %"270_0.sroa.15.0178.i"
  %112 = xor i64 %107, %111
  store i64 %112, ptr %72, align 4
  %113 = getelementptr inbounds nuw i64, ptr %71, i64 %"270_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %113, align 4
  %114 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %114, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %114, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %114, 2
  %exitcond.not.i = icmp eq i64 %95, 10
  br i1 %exitcond.not.i, label %73, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.256.exit": ; preds = %91, %73
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %71, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %72, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %115 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %116 = tail call ptr @heap_alloc(i64 10)
  %117 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %117, align 1
  br label %__barray_check_bounds.exit.i.i383

loop_body.preheader.i.i:                          ; preds = %loop_body.i386
  %"512_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %266, 2
  %"512_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %266, 1
  %"512_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %266, 0
  %118 = lshr i64 %"512_1.sroa.10.0.i.i", 6
  %119 = getelementptr i64, ptr %"512_1.sroa.5.0.i.i", i64 %118
  %120 = load i64, ptr %119, align 4
  %121 = and i64 %"512_1.sroa.10.0.i.i", 63
  %122 = lshr i64 %120, %121
  %123 = trunc i64 %122 to i1
  br i1 %123, label %cond_exit_515.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_check_bounds.exit.i.i383:                ; preds = %loop_body.i386, %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit"
  %124 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit" ], [ %266, %loop_body.i386 ]
  %"229_0.sroa.15.0168.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit" ], [ %125, %loop_body.i386 ]
  %.pn159167.i = phi { { ptr, ptr, i64 }, i64 } [ %115, %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit" ], [ %262, %loop_body.i386 ]
  %125 = add nuw nsw i64 %"229_0.sroa.15.0168.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %124, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %124, 1
  %126 = add i64 %.fca.2.extract208.i.i, %"229_0.sroa.15.0168.i"
  %127 = lshr i64 %126, 6
  %128 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %127
  %129 = load i64, ptr %128, align 4
  %130 = and i64 %126, 63
  %131 = lshr i64 %129, %130
  %132 = trunc i64 %131 to i1
  br i1 %132, label %panic.i.i.i398, label %__barray_check_bounds.exit221.i.i

panic.i.i.i398:                                   ; preds = %__barray_check_bounds.exit.i.i383
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i383
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %124, 0
  %133 = shl nuw i64 1, %130
  %134 = xor i64 %133, %129
  store i64 %134, ptr %128, align 4
  %135 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %126
  %136 = load i64, ptr %135, align 4
  tail call void @___inc_future_refcount(i64 %136)
  %137 = load i64, ptr %128, align 4
  %138 = lshr i64 %137, %130
  %139 = trunc i64 %138 to i1
  br i1 %139, label %__barray_check_bounds.exit.i384, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

140:                                              ; preds = %mask_block_ok.i.i.i390
  %141 = add nuw i64 %.02.i.i.i391, 1
  %exitcond.not.i.i.i394 = icmp eq i64 %.02.i.i.i391, %reass.sub.i.i.i388
  br i1 %exitcond.not.i.i.i394, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit", label %mask_block_ok.i.i.i390

mask_block_ok.i.i.i390:                           ; preds = %cond_exit_515.thread.9.i.i, %140
  %.02.i.i.i391 = phi i64 [ %141, %140 ], [ 0, %cond_exit_515.thread.9.i.i ]
  %gep.i.i.i392 = getelementptr i64, ptr %119, i64 %.02.i.i.i391
  %142 = load i64, ptr %gep.i.i.i392, align 4
  %143 = icmp eq i64 %142, -1
  br i1 %143, label %140, label %mask_block_err.i.i.i393

mask_block_err.i.i.i393:                          ; preds = %mask_block_ok.i.i.i390
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i.i:                 ; preds = %loop_body.preheader.i.i
  %144 = shl nuw i64 1, %121
  %145 = xor i64 %120, %144
  store i64 %145, ptr %119, align 4
  %146 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %"512_1.sroa.10.0.i.i"
  %147 = load i64, ptr %146, align 4
  tail call void @___dec_future_refcount(i64 %147)
  br label %cond_exit_515.thread.i.i

cond_exit_515.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %loop_body.preheader.i.i
  %148 = add i64 %"512_1.sroa.10.0.i.i", 1
  %149 = lshr i64 %148, 6
  %150 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %149
  %151 = load i64, ptr %150, align 4
  %152 = and i64 %148, 63
  %153 = lshr i64 %151, %152
  %154 = trunc i64 %153 to i1
  br i1 %154, label %cond_exit_515.thread.1.i.i, label %__barray_mask_borrow.exit228.1.i.i

__barray_mask_borrow.exit228.1.i.i:               ; preds = %cond_exit_515.thread.i.i
  %155 = shl nuw i64 1, %152
  %156 = xor i64 %151, %155
  store i64 %156, ptr %150, align 4
  %157 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %148
  %158 = load i64, ptr %157, align 4
  tail call void @___dec_future_refcount(i64 %158)
  br label %cond_exit_515.thread.1.i.i

cond_exit_515.thread.1.i.i:                       ; preds = %__barray_mask_borrow.exit228.1.i.i, %cond_exit_515.thread.i.i
  %159 = add i64 %"512_1.sroa.10.0.i.i", 2
  %160 = lshr i64 %159, 6
  %161 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %160
  %162 = load i64, ptr %161, align 4
  %163 = and i64 %159, 63
  %164 = lshr i64 %162, %163
  %165 = trunc i64 %164 to i1
  br i1 %165, label %cond_exit_515.thread.2.i.i, label %__barray_mask_borrow.exit228.2.i.i

__barray_mask_borrow.exit228.2.i.i:               ; preds = %cond_exit_515.thread.1.i.i
  %166 = shl nuw i64 1, %163
  %167 = xor i64 %162, %166
  store i64 %167, ptr %161, align 4
  %168 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %159
  %169 = load i64, ptr %168, align 4
  tail call void @___dec_future_refcount(i64 %169)
  br label %cond_exit_515.thread.2.i.i

cond_exit_515.thread.2.i.i:                       ; preds = %__barray_mask_borrow.exit228.2.i.i, %cond_exit_515.thread.1.i.i
  %170 = add i64 %"512_1.sroa.10.0.i.i", 3
  %171 = lshr i64 %170, 6
  %172 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %171
  %173 = load i64, ptr %172, align 4
  %174 = and i64 %170, 63
  %175 = lshr i64 %173, %174
  %176 = trunc i64 %175 to i1
  br i1 %176, label %cond_exit_515.thread.3.i.i, label %__barray_mask_borrow.exit228.3.i.i

__barray_mask_borrow.exit228.3.i.i:               ; preds = %cond_exit_515.thread.2.i.i
  %177 = shl nuw i64 1, %174
  %178 = xor i64 %173, %177
  store i64 %178, ptr %172, align 4
  %179 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %170
  %180 = load i64, ptr %179, align 4
  tail call void @___dec_future_refcount(i64 %180)
  br label %cond_exit_515.thread.3.i.i

cond_exit_515.thread.3.i.i:                       ; preds = %__barray_mask_borrow.exit228.3.i.i, %cond_exit_515.thread.2.i.i
  %181 = add i64 %"512_1.sroa.10.0.i.i", 4
  %182 = lshr i64 %181, 6
  %183 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %182
  %184 = load i64, ptr %183, align 4
  %185 = and i64 %181, 63
  %186 = lshr i64 %184, %185
  %187 = trunc i64 %186 to i1
  br i1 %187, label %cond_exit_515.thread.4.i.i, label %__barray_mask_borrow.exit228.4.i.i

__barray_mask_borrow.exit228.4.i.i:               ; preds = %cond_exit_515.thread.3.i.i
  %188 = shl nuw i64 1, %185
  %189 = xor i64 %184, %188
  store i64 %189, ptr %183, align 4
  %190 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %181
  %191 = load i64, ptr %190, align 4
  tail call void @___dec_future_refcount(i64 %191)
  br label %cond_exit_515.thread.4.i.i

cond_exit_515.thread.4.i.i:                       ; preds = %__barray_mask_borrow.exit228.4.i.i, %cond_exit_515.thread.3.i.i
  %192 = add i64 %"512_1.sroa.10.0.i.i", 5
  %193 = lshr i64 %192, 6
  %194 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %193
  %195 = load i64, ptr %194, align 4
  %196 = and i64 %192, 63
  %197 = lshr i64 %195, %196
  %198 = trunc i64 %197 to i1
  br i1 %198, label %cond_exit_515.thread.5.i.i, label %__barray_mask_borrow.exit228.5.i.i

__barray_mask_borrow.exit228.5.i.i:               ; preds = %cond_exit_515.thread.4.i.i
  %199 = shl nuw i64 1, %196
  %200 = xor i64 %195, %199
  store i64 %200, ptr %194, align 4
  %201 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %192
  %202 = load i64, ptr %201, align 4
  tail call void @___dec_future_refcount(i64 %202)
  br label %cond_exit_515.thread.5.i.i

cond_exit_515.thread.5.i.i:                       ; preds = %__barray_mask_borrow.exit228.5.i.i, %cond_exit_515.thread.4.i.i
  %203 = add i64 %"512_1.sroa.10.0.i.i", 6
  %204 = lshr i64 %203, 6
  %205 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %204
  %206 = load i64, ptr %205, align 4
  %207 = and i64 %203, 63
  %208 = lshr i64 %206, %207
  %209 = trunc i64 %208 to i1
  br i1 %209, label %cond_exit_515.thread.6.i.i, label %__barray_mask_borrow.exit228.6.i.i

__barray_mask_borrow.exit228.6.i.i:               ; preds = %cond_exit_515.thread.5.i.i
  %210 = shl nuw i64 1, %207
  %211 = xor i64 %206, %210
  store i64 %211, ptr %205, align 4
  %212 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %203
  %213 = load i64, ptr %212, align 4
  tail call void @___dec_future_refcount(i64 %213)
  br label %cond_exit_515.thread.6.i.i

cond_exit_515.thread.6.i.i:                       ; preds = %__barray_mask_borrow.exit228.6.i.i, %cond_exit_515.thread.5.i.i
  %214 = add i64 %"512_1.sroa.10.0.i.i", 7
  %215 = lshr i64 %214, 6
  %216 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %215
  %217 = load i64, ptr %216, align 4
  %218 = and i64 %214, 63
  %219 = lshr i64 %217, %218
  %220 = trunc i64 %219 to i1
  br i1 %220, label %cond_exit_515.thread.7.i.i, label %__barray_mask_borrow.exit228.7.i.i

__barray_mask_borrow.exit228.7.i.i:               ; preds = %cond_exit_515.thread.6.i.i
  %221 = shl nuw i64 1, %218
  %222 = xor i64 %217, %221
  store i64 %222, ptr %216, align 4
  %223 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %214
  %224 = load i64, ptr %223, align 4
  tail call void @___dec_future_refcount(i64 %224)
  br label %cond_exit_515.thread.7.i.i

cond_exit_515.thread.7.i.i:                       ; preds = %__barray_mask_borrow.exit228.7.i.i, %cond_exit_515.thread.6.i.i
  %225 = add i64 %"512_1.sroa.10.0.i.i", 8
  %226 = lshr i64 %225, 6
  %227 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %226
  %228 = load i64, ptr %227, align 4
  %229 = and i64 %225, 63
  %230 = lshr i64 %228, %229
  %231 = trunc i64 %230 to i1
  br i1 %231, label %cond_exit_515.thread.8.i.i, label %__barray_mask_borrow.exit228.8.i.i

__barray_mask_borrow.exit228.8.i.i:               ; preds = %cond_exit_515.thread.7.i.i
  %232 = shl nuw i64 1, %229
  %233 = xor i64 %228, %232
  store i64 %233, ptr %227, align 4
  %234 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %225
  %235 = load i64, ptr %234, align 4
  tail call void @___dec_future_refcount(i64 %235)
  br label %cond_exit_515.thread.8.i.i

cond_exit_515.thread.8.i.i:                       ; preds = %__barray_mask_borrow.exit228.8.i.i, %cond_exit_515.thread.7.i.i
  %236 = add i64 %"512_1.sroa.10.0.i.i", 9
  %237 = lshr i64 %236, 6
  %238 = getelementptr inbounds nuw i64, ptr %"512_1.sroa.5.0.i.i", i64 %237
  %239 = load i64, ptr %238, align 4
  %240 = and i64 %236, 63
  %241 = lshr i64 %239, %240
  %242 = trunc i64 %241 to i1
  br i1 %242, label %cond_exit_515.thread.9.i.i, label %__barray_mask_borrow.exit228.9.i.i

__barray_mask_borrow.exit228.9.i.i:               ; preds = %cond_exit_515.thread.8.i.i
  %243 = shl nuw i64 1, %240
  %244 = xor i64 %239, %243
  store i64 %244, ptr %238, align 4
  %245 = getelementptr inbounds i64, ptr %"512_1.sroa.0.0.i.i", i64 %236
  %246 = load i64, ptr %245, align 4
  tail call void @___dec_future_refcount(i64 %246)
  br label %cond_exit_515.thread.9.i.i

cond_exit_515.thread.9.i.i:                       ; preds = %__barray_mask_borrow.exit228.9.i.i, %cond_exit_515.thread.8.i.i
  %247 = load i64, ptr %119, align 4
  %248 = sub nuw nsw i64 64, %121
  %249 = lshr i64 -1, %248
  %250 = icmp eq i64 %121, 0
  %251 = select i1 %250, i64 0, i64 %249
  %252 = or i64 %247, %251
  store i64 %252, ptr %119, align 4
  %253 = load i64, ptr %238, align 4
  %254 = shl nsw i64 -2, %240
  %255 = icmp eq i64 %240, 63
  %256 = select i1 %255, i64 0, i64 %254
  %257 = or i64 %253, %256
  store i64 %257, ptr %238, align 4
  %reass.sub.i.i.i388 = sub nsw i64 %237, %118
  %.not.i.i.i389 = icmp eq i64 %reass.sub.i.i.i388, -1
  br i1 %.not.i.i.i389, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit", label %mask_block_ok.i.i.i390

__barray_check_bounds.exit.i384:                  ; preds = %__barray_check_bounds.exit221.i.i
  %258 = xor i64 %137, %133
  store i64 %258, ptr %128, align 4
  store i64 %136, ptr %135, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %136)
  tail call void @___dec_future_refcount(i64 %136)
  %259 = load i64, ptr %117, align 4
  %260 = lshr i64 %259, %"229_0.sroa.15.0168.i"
  %261 = trunc i64 %260 to i1
  br i1 %261, label %loop_body.i386, label %panic.i.i385

panic.i.i385:                                     ; preds = %__barray_check_bounds.exit.i384
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i386:                                   ; preds = %__barray_check_bounds.exit.i384
  %262 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, i64 %125, 1
  %263 = shl nuw nsw i64 1, %"229_0.sroa.15.0168.i"
  %264 = xor i64 %259, %263
  store i64 %264, ptr %117, align 4
  %265 = getelementptr inbounds nuw i1, ptr %116, i64 %"229_0.sroa.15.0168.i"
  store i1 %read_bool.i, ptr %265, align 1
  %266 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, 0
  %exitcond.not.i387 = icmp eq i64 %125, 10
  br i1 %exitcond.not.i387, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i383

"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit": ; preds = %140, %cond_exit_515.thread.9.i.i
  tail call void @heap_free(ptr %"512_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"512_1.sroa.5.0.i.i")
  %267 = load i64, ptr %117, align 4
  %268 = and i64 %267, 1023
  store i64 %268, ptr %117, align 4
  %269 = icmp eq i64 %268, 0
  br i1 %269, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit"
  %270 = tail call ptr @heap_alloc(i64 10)
  %271 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %271, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %270, ptr noundef nonnull align 1 dereferenceable(10) %116, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %270)
  %272 = load i64, ptr %117, align 4
  %273 = and i64 %272, 1023
  store i64 %273, ptr %117, align 4
  %274 = icmp eq i64 %273, 0
  br i1 %274, label %__barray_check_none_borrowed.exit400, label %mask_block_err.i399

mask_block_err.i399:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit400:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %275 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %275, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %116, ptr %arr_ptr, align 8
  store ptr %275, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_outcomes.9CB6D2E7.0, i64 21, ptr nonnull %out_arr_alloca)
  ret void
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

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
