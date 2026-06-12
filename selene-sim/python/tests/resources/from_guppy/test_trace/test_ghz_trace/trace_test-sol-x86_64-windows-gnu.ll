; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

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
  br i1 %not_max.not.not.i, label %cond_491_case_0.i, label %__barray_check_bounds.exit

cond_491_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__barray_check_bounds.exit:                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__barray_check_bounds.exit.8, %__barray_check_bounds.exit.7, %__barray_check_bounds.exit.6, %__barray_check_bounds.exit.5, %__barray_check_bounds.exit.4, %__barray_check_bounds.exit.3, %__barray_check_bounds.exit.2, %__barray_check_bounds.exit.1, %__barray_check_bounds.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__barray_check_bounds.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_491_case_0.i, label %__barray_check_bounds.exit.1

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not = icmp eq i64 %6, 0
  br i1 %.not, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__barray_check_bounds.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_491_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not418 = icmp eq i64 %10, 0
  br i1 %.not418, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_491_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not419 = icmp eq i64 %14, 0
  br i1 %.not419, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_491_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not420 = icmp eq i64 %18, 0
  br i1 %.not420, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_491_case_0.i, label %__barray_check_bounds.exit.5

__barray_check_bounds.exit.5:                     ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not421 = icmp eq i64 %22, 0
  br i1 %.not421, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__barray_check_bounds.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_491_case_0.i, label %__barray_check_bounds.exit.6

__barray_check_bounds.exit.6:                     ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not422 = icmp eq i64 %26, 0
  br i1 %.not422, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__barray_check_bounds.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_491_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not423 = icmp eq i64 %30, 0
  br i1 %.not423, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_491_case_0.i, label %__barray_check_bounds.exit.8

__barray_check_bounds.exit.8:                     ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not424 = icmp eq i64 %34, 0
  br i1 %.not424, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__barray_check_bounds.exit.8
  %35 = and i64 %33, -257
  store i64 %35, ptr %1, align 4
  %36 = getelementptr inbounds nuw i8, ptr %0, i64 64
  store i64 %qalloc.i.8, ptr %36, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_491_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %37 = load i64, ptr %1, align 4
  %38 = and i64 %37, 512
  %.not425 = icmp eq i64 %38, 0
  br i1 %.not425, label %panic.i, label %cond_exit_20.9

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
  tail call void @___rp(i64 %44, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
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
  %"54_0.0416" = phi i64 [ 0, %__barray_mask_return.exit366 ], [ %48, %__barray_mask_return.exit382 ]
  %48 = add nuw nsw i64 %"54_0.0416", 1
  %49 = load i64, ptr %1, align 4
  %50 = lshr i64 %49, %"54_0.0416"
  %51 = trunc i64 %50 to i1
  br i1 %51, label %panic.i369, label %__barray_mask_borrow.exit370

panic.i369:                                       ; preds = %__barray_check_bounds.exit368
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_mask_borrow.exit370:                     ; preds = %__barray_check_bounds.exit368
  %52 = shl nuw nsw i64 1, %"54_0.0416"
  %53 = xor i64 %49, %52
  store i64 %53, ptr %1, align 4
  %54 = getelementptr inbounds nuw i64, ptr %0, i64 %"54_0.0416"
  %55 = load i64, ptr %54, align 4
  %56 = lshr i64 %53, %48
  %57 = trunc i64 %56 to i1
  br i1 %57, label %panic.i373, label %__barray_check_bounds.exit376

panic.i373:                                       ; preds = %__barray_mask_borrow.exit370
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit376:                    ; preds = %__barray_mask_borrow.exit370
  %58 = shl nuw nsw i64 2, %"54_0.0416"
  %59 = xor i64 %53, %58
  store i64 %59, ptr %1, align 4
  %60 = getelementptr inbounds nuw i64, ptr %0, i64 %48
  %61 = load i64, ptr %60, align 4
  tail call void @___rp(i64 %55, double 0x3FF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rpp(i64 %55, i64 %61, double 0x3FF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %61, double 0xBFF921FB54442D18, double 0.000000e+00)
  tail call void @___rp(i64 %55, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %55, double 0xBFF921FB54442D18)
  %62 = load i64, ptr %1, align 4
  %63 = lshr i64 %62, %"54_0.0416"
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
  %exitcond417.not = icmp eq i64 %48, 9
  br i1 %exitcond417.not, label %cond_exit_89, label %__barray_check_bounds.exit368

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
  %"511_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %175, 2
  %"511_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %175, 1
  %"511_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %175, 0
  br label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i.i383:                ; preds = %loop_body.i386, %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit"
  %118 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit" ], [ %175, %loop_body.i386 ]
  %"229_0.sroa.15.0168.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit" ], [ %119, %loop_body.i386 ]
  %.pn159167.i = phi { { ptr, ptr, i64 }, i64 } [ %115, %"__hugr__.guppylang.std.quantum.measure_array$10.256.exit" ], [ %171, %loop_body.i386 ]
  %119 = add nuw nsw i64 %"229_0.sroa.15.0168.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %118, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %118, 1
  %120 = add i64 %.fca.2.extract208.i.i, %"229_0.sroa.15.0168.i"
  %121 = lshr i64 %120, 6
  %122 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %121
  %123 = load i64, ptr %122, align 4
  %124 = and i64 %120, 63
  %125 = lshr i64 %123, %124
  %126 = trunc i64 %125 to i1
  br i1 %126, label %panic.i.i.i399, label %__barray_check_bounds.exit221.i.i

panic.i.i.i399:                                   ; preds = %__barray_check_bounds.exit.i.i383
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i383
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %118, 0
  %127 = shl nuw i64 1, %124
  %128 = xor i64 %127, %123
  store i64 %128, ptr %122, align 4
  %129 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %120
  %130 = load i64, ptr %129, align 4
  tail call void @___inc_future_refcount(i64 %130)
  %131 = load i64, ptr %122, align 4
  %132 = lshr i64 %131, %124
  %133 = trunc i64 %132 to i1
  br i1 %133, label %__barray_check_bounds.exit.i384, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_514_case_0.i.i:                              ; preds = %cond_exit_514.thread.i.i
  %134 = lshr i64 %"511_1.sroa.10.0.i.i", 6
  %135 = getelementptr i64, ptr %"511_1.sroa.5.0.i.i", i64 %134
  %136 = load i64, ptr %135, align 4
  %137 = and i64 %"511_1.sroa.10.0.i.i", 63
  %138 = sub nuw nsw i64 64, %137
  %139 = lshr i64 -1, %138
  %140 = icmp eq i64 %137, 0
  %141 = select i1 %140, i64 0, i64 %139
  %142 = or i64 %136, %141
  store i64 %142, ptr %135, align 4
  %last_valid.i.i.i388 = add i64 %"511_1.sroa.10.0.i.i", 9
  %143 = lshr i64 %last_valid.i.i.i388, 6
  %144 = getelementptr inbounds nuw i64, ptr %"511_1.sroa.5.0.i.i", i64 %143
  %145 = load i64, ptr %144, align 4
  %146 = and i64 %last_valid.i.i.i388, 63
  %147 = shl nsw i64 -2, %146
  %148 = icmp eq i64 %146, 63
  %149 = select i1 %148, i64 0, i64 %147
  %150 = or i64 %145, %149
  store i64 %150, ptr %144, align 4
  %reass.sub.i.i.i389 = sub nsw i64 %143, %134
  %.not.i.i.i390 = icmp eq i64 %reass.sub.i.i.i389, -1
  br i1 %.not.i.i.i390, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit", label %mask_block_ok.i.i.i391

151:                                              ; preds = %mask_block_ok.i.i.i391
  %152 = add nuw i64 %.02.i.i.i392, 1
  %exitcond.not.i.i.i395 = icmp eq i64 %.02.i.i.i392, %reass.sub.i.i.i389
  br i1 %exitcond.not.i.i.i395, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit", label %mask_block_ok.i.i.i391

mask_block_ok.i.i.i391:                           ; preds = %cond_514_case_0.i.i, %151
  %.02.i.i.i392 = phi i64 [ %152, %151 ], [ 0, %cond_514_case_0.i.i ]
  %gep.i.i.i393 = getelementptr i64, ptr %135, i64 %.02.i.i.i392
  %153 = load i64, ptr %gep.i.i.i393, align 4
  %154 = icmp eq i64 %153, -1
  br i1 %154, label %151, label %mask_block_err.i.i.i394

mask_block_err.i.i.i394:                          ; preds = %mask_block_ok.i.i.i391
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i.i:                ; preds = %cond_exit_514.thread.i.i, %loop_body.preheader.i.i
  %"511_0.0239.i.i" = phi i64 [ 0, %loop_body.preheader.i.i ], [ %155, %cond_exit_514.thread.i.i ]
  %155 = add nuw nsw i64 %"511_0.0239.i.i", 1
  %156 = add i64 %"511_0.0239.i.i", %"511_1.sroa.10.0.i.i"
  %157 = lshr i64 %156, 6
  %158 = getelementptr inbounds nuw i64, ptr %"511_1.sroa.5.0.i.i", i64 %157
  %159 = load i64, ptr %158, align 4
  %160 = and i64 %156, 63
  %161 = lshr i64 %159, %160
  %162 = trunc i64 %161 to i1
  br i1 %162, label %cond_exit_514.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_mask_borrow.exit228.i.i:                 ; preds = %__barray_check_bounds.exit224.i.i
  %163 = shl nuw i64 1, %160
  %164 = xor i64 %163, %159
  store i64 %164, ptr %158, align 4
  %165 = getelementptr inbounds i64, ptr %"511_1.sroa.0.0.i.i", i64 %156
  %166 = load i64, ptr %165, align 4
  tail call void @___dec_future_refcount(i64 %166)
  br label %cond_exit_514.thread.i.i

cond_exit_514.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %__barray_check_bounds.exit224.i.i
  %exitcond.i.i = icmp eq i64 %155, 10
  br i1 %exitcond.i.i, label %cond_514_case_0.i.i, label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i384:                  ; preds = %__barray_check_bounds.exit221.i.i
  %167 = xor i64 %131, %127
  store i64 %167, ptr %122, align 4
  store i64 %130, ptr %129, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %130)
  tail call void @___dec_future_refcount(i64 %130)
  %168 = load i64, ptr %117, align 4
  %169 = lshr i64 %168, %"229_0.sroa.15.0168.i"
  %170 = trunc i64 %169 to i1
  br i1 %170, label %loop_body.i386, label %panic.i.i385

panic.i.i385:                                     ; preds = %__barray_check_bounds.exit.i384
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i386:                                   ; preds = %__barray_check_bounds.exit.i384
  %171 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, i64 %119, 1
  %172 = shl nuw nsw i64 1, %"229_0.sroa.15.0168.i"
  %173 = xor i64 %168, %172
  store i64 %173, ptr %117, align 4
  %174 = getelementptr inbounds nuw i1, ptr %116, i64 %"229_0.sroa.15.0168.i"
  store i1 %read_bool.i, ptr %174, align 1
  %175 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, 0
  %exitcond.not.i387 = icmp eq i64 %119, 10
  br i1 %exitcond.not.i387, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i383

"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit": ; preds = %151, %cond_514_case_0.i.i
  tail call void @heap_free(ptr %"511_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"511_1.sroa.5.0.i.i")
  %176 = load i64, ptr %117, align 4
  %177 = and i64 %176, 1023
  store i64 %177, ptr %117, align 4
  %178 = icmp eq i64 %177, 0
  br i1 %178, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.215.exit"
  %179 = tail call ptr @heap_alloc(i64 10)
  %180 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %180, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %179, ptr noundef nonnull align 1 dereferenceable(10) %116, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %179)
  %181 = load i64, ptr %117, align 4
  %182 = and i64 %181, 1023
  store i64 %182, ptr %117, align 4
  %183 = icmp eq i64 %182, 0
  br i1 %183, label %__barray_check_none_borrowed.exit401, label %mask_block_err.i400

mask_block_err.i400:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit401:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %184 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %184, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %116, ptr %arr_ptr, align 8
  store ptr %184, ptr %mask_ptr, align 8
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
