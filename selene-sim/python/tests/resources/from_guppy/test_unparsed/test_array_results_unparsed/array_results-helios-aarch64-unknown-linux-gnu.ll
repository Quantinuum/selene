; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@res_floats.8646C2EF.0 = private constant [21 x i8] c"\14USER:FLOATARR:floats"
@res_ints.B3BC9D53.0 = private constant [17 x i8] c"\10USER:INTARR:ints"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 80)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit

cond_597_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_helios_qalloc.570.exit:            ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_helios_qalloc.570.exit.8, %__hugr__.__tk2_helios_qalloc.570.exit.7, %__hugr__.__tk2_helios_qalloc.570.exit.6, %__hugr__.__tk2_helios_qalloc.570.exit.5, %__hugr__.__tk2_helios_qalloc.570.exit.4, %__hugr__.__tk2_helios_qalloc.570.exit.3, %__hugr__.__tk2_helios_qalloc.570.exit.2, %__hugr__.__tk2_helios_qalloc.570.exit.1, %__hugr__.__tk2_helios_qalloc.570.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_helios_qalloc.570.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit.1

__hugr__.__tk2_helios_qalloc.570.exit.1:          ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not = icmp eq i64 %6, 0
  br i1 %.not, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_helios_qalloc.570.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit.2

__hugr__.__tk2_helios_qalloc.570.exit.2:          ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not1010 = icmp eq i64 %10, 0
  br i1 %.not1010, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_helios_qalloc.570.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit.3

__hugr__.__tk2_helios_qalloc.570.exit.3:          ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not1011 = icmp eq i64 %14, 0
  br i1 %.not1011, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_helios_qalloc.570.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit.4

__hugr__.__tk2_helios_qalloc.570.exit.4:          ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not1012 = icmp eq i64 %18, 0
  br i1 %.not1012, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_helios_qalloc.570.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit.5

__hugr__.__tk2_helios_qalloc.570.exit.5:          ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not1013 = icmp eq i64 %22, 0
  br i1 %.not1013, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_helios_qalloc.570.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit.6

__hugr__.__tk2_helios_qalloc.570.exit.6:          ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not1014 = icmp eq i64 %26, 0
  br i1 %.not1014, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_helios_qalloc.570.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit.7

__hugr__.__tk2_helios_qalloc.570.exit.7:          ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not1015 = icmp eq i64 %30, 0
  br i1 %.not1015, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__hugr__.__tk2_helios_qalloc.570.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_597_case_0.i, label %__hugr__.__tk2_helios_qalloc.570.exit.8

__hugr__.__tk2_helios_qalloc.570.exit.8:          ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not1016 = icmp eq i64 %34, 0
  br i1 %.not1016, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__hugr__.__tk2_helios_qalloc.570.exit.8
  %35 = and i64 %33, -257
  store i64 %35, ptr %1, align 4
  %36 = getelementptr inbounds nuw i8, ptr %0, i64 64
  store i64 %qalloc.i.8, ptr %36, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_597_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %37 = load i64, ptr %1, align 4
  %38 = and i64 %37, 512
  %.not1017 = icmp eq i64 %38, 0
  br i1 %.not1017, label %panic.i, label %cond_exit_20.9

cond_exit_20.9:                                   ; preds = %__barray_check_bounds.exit.9
  %39 = and i64 %37, -513
  store i64 %39, ptr %1, align 4
  %40 = getelementptr inbounds nuw i8, ptr %0, i64 72
  store i64 %qalloc.i.9, ptr %40, align 4
  %"116.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"116.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"116.fca.0.insert", ptr %1, 1
  %"116.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"116.fca.1.insert", i64 0, 2
  br label %__barray_check_bounds.exit887

__barray_check_bounds.exit887:                    ; preds = %__barray_mask_return.exit892, %cond_exit_20.9
  %"47_0.0997" = phi i64 [ 0, %cond_exit_20.9 ], [ %41, %__barray_mask_return.exit892 ]
  %41 = add nuw nsw i64 %"47_0.0997", 1
  %42 = load i64, ptr %1, align 4
  %43 = lshr i64 %42, %"47_0.0997"
  %44 = trunc i64 %43 to i1
  br i1 %44, label %panic.i888, label %__barray_check_bounds.exit890

panic.i888:                                       ; preds = %__barray_check_bounds.exit887
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit890:                    ; preds = %__barray_check_bounds.exit887
  %45 = shl nuw nsw i64 1, %"47_0.0997"
  %46 = xor i64 %42, %45
  store i64 %46, ptr %1, align 4
  %47 = getelementptr inbounds nuw i64, ptr %0, i64 %"47_0.0997"
  %48 = load i64, ptr %47, align 4
  tail call void @___rxy(i64 %48, double 0x400921FB54442D18, double 0.000000e+00)
  %49 = load i64, ptr %1, align 4
  %50 = lshr i64 %49, %"47_0.0997"
  %51 = trunc i64 %50 to i1
  br i1 %51, label %__barray_mask_return.exit892, label %panic.i891

panic.i891:                                       ; preds = %__barray_check_bounds.exit890
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit892:                     ; preds = %__barray_check_bounds.exit890
  %52 = xor i64 %49, %45
  store i64 %52, ptr %1, align 4
  store i64 %48, ptr %47, align 4
  %exitcond.not = icmp eq i64 %41, 10
  br i1 %exitcond.not, label %cond_exit_192, label %__barray_check_bounds.exit887

loop_body.preheader.i:                            ; preds = %loop_body122
  %"617_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %204, 2
  %"617_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %204, 1
  %"617_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %204, 0
  %53 = lshr i64 %"617_1.sroa.10.0.i", 6
  %54 = getelementptr i64, ptr %"617_1.sroa.5.0.i", i64 %53
  %55 = load i64, ptr %54, align 4
  %56 = and i64 %"617_1.sroa.10.0.i", 63
  %57 = lshr i64 %55, %56
  %58 = trunc i64 %57 to i1
  br i1 %58, label %cond_exit_620.thread.i, label %__barray_mask_borrow.exit228.i

__barray_check_bounds.exit.i:                     ; preds = %loop_body122, %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit"
  %59 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit" ], [ %204, %loop_body122 ]
  %"79_0.sroa.15.01000" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit" ], [ %60, %loop_body122 ]
  %.pn987999 = phi { { ptr, ptr, i64 }, i64 } [ %302, %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit" ], [ %200, %loop_body122 ]
  %60 = add nuw nsw i64 %"79_0.sroa.15.01000", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %59, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %59, 1
  %61 = add i64 %.fca.2.extract208.i, %"79_0.sroa.15.01000"
  %62 = lshr i64 %61, 6
  %63 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %62
  %64 = load i64, ptr %63, align 4
  %65 = and i64 %61, 63
  %66 = lshr i64 %64, %65
  %67 = trunc i64 %66 to i1
  br i1 %67, label %panic.i.i, label %__barray_check_bounds.exit221.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %59, 0
  %68 = shl nuw i64 1, %65
  %69 = xor i64 %64, %68
  store i64 %69, ptr %63, align 4
  %70 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %61
  %71 = load i64, ptr %70, align 4
  tail call void @___inc_future_refcount(i64 %71)
  %72 = load i64, ptr %63, align 4
  %73 = lshr i64 %72, %65
  %74 = trunc i64 %73 to i1
  br i1 %74, label %__barray_check_bounds.exit894, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

75:                                               ; preds = %mask_block_ok.i.i
  %76 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_exit_620.thread.9.i, %75
  %.02.i.i = phi i64 [ %76, %75 ], [ 0, %cond_exit_620.thread.9.i ]
  %gep.i.i = getelementptr i64, ptr %54, i64 %.02.i.i
  %77 = load i64, ptr %gep.i.i, align 4
  %78 = icmp eq i64 %77, -1
  br i1 %78, label %75, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i:                   ; preds = %loop_body.preheader.i
  %79 = shl nuw i64 1, %56
  %80 = xor i64 %55, %79
  store i64 %80, ptr %54, align 4
  %81 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %"617_1.sroa.10.0.i"
  %82 = load i64, ptr %81, align 4
  tail call void @___dec_future_refcount(i64 %82)
  br label %cond_exit_620.thread.i

cond_exit_620.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %loop_body.preheader.i
  %83 = add i64 %"617_1.sroa.10.0.i", 1
  %84 = lshr i64 %83, 6
  %85 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %84
  %86 = load i64, ptr %85, align 4
  %87 = and i64 %83, 63
  %88 = lshr i64 %86, %87
  %89 = trunc i64 %88 to i1
  br i1 %89, label %cond_exit_620.thread.1.i, label %__barray_mask_borrow.exit228.1.i

__barray_mask_borrow.exit228.1.i:                 ; preds = %cond_exit_620.thread.i
  %90 = shl nuw i64 1, %87
  %91 = xor i64 %86, %90
  store i64 %91, ptr %85, align 4
  %92 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %83
  %93 = load i64, ptr %92, align 4
  tail call void @___dec_future_refcount(i64 %93)
  br label %cond_exit_620.thread.1.i

cond_exit_620.thread.1.i:                         ; preds = %__barray_mask_borrow.exit228.1.i, %cond_exit_620.thread.i
  %94 = add i64 %"617_1.sroa.10.0.i", 2
  %95 = lshr i64 %94, 6
  %96 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %95
  %97 = load i64, ptr %96, align 4
  %98 = and i64 %94, 63
  %99 = lshr i64 %97, %98
  %100 = trunc i64 %99 to i1
  br i1 %100, label %cond_exit_620.thread.2.i, label %__barray_mask_borrow.exit228.2.i

__barray_mask_borrow.exit228.2.i:                 ; preds = %cond_exit_620.thread.1.i
  %101 = shl nuw i64 1, %98
  %102 = xor i64 %97, %101
  store i64 %102, ptr %96, align 4
  %103 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %94
  %104 = load i64, ptr %103, align 4
  tail call void @___dec_future_refcount(i64 %104)
  br label %cond_exit_620.thread.2.i

cond_exit_620.thread.2.i:                         ; preds = %__barray_mask_borrow.exit228.2.i, %cond_exit_620.thread.1.i
  %105 = add i64 %"617_1.sroa.10.0.i", 3
  %106 = lshr i64 %105, 6
  %107 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %106
  %108 = load i64, ptr %107, align 4
  %109 = and i64 %105, 63
  %110 = lshr i64 %108, %109
  %111 = trunc i64 %110 to i1
  br i1 %111, label %cond_exit_620.thread.3.i, label %__barray_mask_borrow.exit228.3.i

__barray_mask_borrow.exit228.3.i:                 ; preds = %cond_exit_620.thread.2.i
  %112 = shl nuw i64 1, %109
  %113 = xor i64 %108, %112
  store i64 %113, ptr %107, align 4
  %114 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %105
  %115 = load i64, ptr %114, align 4
  tail call void @___dec_future_refcount(i64 %115)
  br label %cond_exit_620.thread.3.i

cond_exit_620.thread.3.i:                         ; preds = %__barray_mask_borrow.exit228.3.i, %cond_exit_620.thread.2.i
  %116 = add i64 %"617_1.sroa.10.0.i", 4
  %117 = lshr i64 %116, 6
  %118 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %117
  %119 = load i64, ptr %118, align 4
  %120 = and i64 %116, 63
  %121 = lshr i64 %119, %120
  %122 = trunc i64 %121 to i1
  br i1 %122, label %cond_exit_620.thread.4.i, label %__barray_mask_borrow.exit228.4.i

__barray_mask_borrow.exit228.4.i:                 ; preds = %cond_exit_620.thread.3.i
  %123 = shl nuw i64 1, %120
  %124 = xor i64 %119, %123
  store i64 %124, ptr %118, align 4
  %125 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %116
  %126 = load i64, ptr %125, align 4
  tail call void @___dec_future_refcount(i64 %126)
  br label %cond_exit_620.thread.4.i

cond_exit_620.thread.4.i:                         ; preds = %__barray_mask_borrow.exit228.4.i, %cond_exit_620.thread.3.i
  %127 = add i64 %"617_1.sroa.10.0.i", 5
  %128 = lshr i64 %127, 6
  %129 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %128
  %130 = load i64, ptr %129, align 4
  %131 = and i64 %127, 63
  %132 = lshr i64 %130, %131
  %133 = trunc i64 %132 to i1
  br i1 %133, label %cond_exit_620.thread.5.i, label %__barray_mask_borrow.exit228.5.i

__barray_mask_borrow.exit228.5.i:                 ; preds = %cond_exit_620.thread.4.i
  %134 = shl nuw i64 1, %131
  %135 = xor i64 %130, %134
  store i64 %135, ptr %129, align 4
  %136 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %127
  %137 = load i64, ptr %136, align 4
  tail call void @___dec_future_refcount(i64 %137)
  br label %cond_exit_620.thread.5.i

cond_exit_620.thread.5.i:                         ; preds = %__barray_mask_borrow.exit228.5.i, %cond_exit_620.thread.4.i
  %138 = add i64 %"617_1.sroa.10.0.i", 6
  %139 = lshr i64 %138, 6
  %140 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %139
  %141 = load i64, ptr %140, align 4
  %142 = and i64 %138, 63
  %143 = lshr i64 %141, %142
  %144 = trunc i64 %143 to i1
  br i1 %144, label %cond_exit_620.thread.6.i, label %__barray_mask_borrow.exit228.6.i

__barray_mask_borrow.exit228.6.i:                 ; preds = %cond_exit_620.thread.5.i
  %145 = shl nuw i64 1, %142
  %146 = xor i64 %141, %145
  store i64 %146, ptr %140, align 4
  %147 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %138
  %148 = load i64, ptr %147, align 4
  tail call void @___dec_future_refcount(i64 %148)
  br label %cond_exit_620.thread.6.i

cond_exit_620.thread.6.i:                         ; preds = %__barray_mask_borrow.exit228.6.i, %cond_exit_620.thread.5.i
  %149 = add i64 %"617_1.sroa.10.0.i", 7
  %150 = lshr i64 %149, 6
  %151 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %150
  %152 = load i64, ptr %151, align 4
  %153 = and i64 %149, 63
  %154 = lshr i64 %152, %153
  %155 = trunc i64 %154 to i1
  br i1 %155, label %cond_exit_620.thread.7.i, label %__barray_mask_borrow.exit228.7.i

__barray_mask_borrow.exit228.7.i:                 ; preds = %cond_exit_620.thread.6.i
  %156 = shl nuw i64 1, %153
  %157 = xor i64 %152, %156
  store i64 %157, ptr %151, align 4
  %158 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %149
  %159 = load i64, ptr %158, align 4
  tail call void @___dec_future_refcount(i64 %159)
  br label %cond_exit_620.thread.7.i

cond_exit_620.thread.7.i:                         ; preds = %__barray_mask_borrow.exit228.7.i, %cond_exit_620.thread.6.i
  %160 = add i64 %"617_1.sroa.10.0.i", 8
  %161 = lshr i64 %160, 6
  %162 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %161
  %163 = load i64, ptr %162, align 4
  %164 = and i64 %160, 63
  %165 = lshr i64 %163, %164
  %166 = trunc i64 %165 to i1
  br i1 %166, label %cond_exit_620.thread.8.i, label %__barray_mask_borrow.exit228.8.i

__barray_mask_borrow.exit228.8.i:                 ; preds = %cond_exit_620.thread.7.i
  %167 = shl nuw i64 1, %164
  %168 = xor i64 %163, %167
  store i64 %168, ptr %162, align 4
  %169 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %160
  %170 = load i64, ptr %169, align 4
  tail call void @___dec_future_refcount(i64 %170)
  br label %cond_exit_620.thread.8.i

cond_exit_620.thread.8.i:                         ; preds = %__barray_mask_borrow.exit228.8.i, %cond_exit_620.thread.7.i
  %171 = add i64 %"617_1.sroa.10.0.i", 9
  %172 = lshr i64 %171, 6
  %173 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %172
  %174 = load i64, ptr %173, align 4
  %175 = and i64 %171, 63
  %176 = lshr i64 %174, %175
  %177 = trunc i64 %176 to i1
  br i1 %177, label %cond_exit_620.thread.9.i, label %__barray_mask_borrow.exit228.9.i

__barray_mask_borrow.exit228.9.i:                 ; preds = %cond_exit_620.thread.8.i
  %178 = shl nuw i64 1, %175
  %179 = xor i64 %174, %178
  store i64 %179, ptr %173, align 4
  %180 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %171
  %181 = load i64, ptr %180, align 4
  tail call void @___dec_future_refcount(i64 %181)
  br label %cond_exit_620.thread.9.i

cond_exit_620.thread.9.i:                         ; preds = %__barray_mask_borrow.exit228.9.i, %cond_exit_620.thread.8.i
  %182 = load i64, ptr %54, align 4
  %183 = sub nuw nsw i64 64, %56
  %184 = lshr i64 -1, %183
  %185 = icmp eq i64 %56, 0
  %186 = select i1 %185, i64 0, i64 %184
  %187 = or i64 %182, %186
  store i64 %187, ptr %54, align 4
  %188 = load i64, ptr %173, align 4
  %189 = shl nsw i64 -2, %175
  %190 = icmp eq i64 %175, 63
  %191 = select i1 %190, i64 0, i64 %189
  %192 = or i64 %188, %191
  store i64 %192, ptr %173, align 4
  %reass.sub.i.i = sub nsw i64 %172, %53
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit", label %mask_block_ok.i.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit": ; preds = %75, %cond_exit_620.thread.9.i
  tail call void @heap_free(ptr %"617_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"617_1.sroa.5.0.i")
  %193 = load i64, ptr %304, align 4
  %194 = and i64 %193, 1023
  store i64 %194, ptr %304, align 4
  %195 = icmp eq i64 %194, 0
  br i1 %195, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit894:                    ; preds = %__barray_check_bounds.exit221.i
  %196 = xor i64 %72, %68
  store i64 %196, ptr %63, align 4
  store i64 %71, ptr %70, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %71)
  tail call void @___dec_future_refcount(i64 %71)
  %197 = load i64, ptr %304, align 4
  %198 = lshr i64 %197, %"79_0.sroa.15.01000"
  %199 = trunc i64 %198 to i1
  br i1 %199, label %loop_body122, label %panic.i895

panic.i895:                                       ; preds = %__barray_check_bounds.exit894
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body122:                                     ; preds = %__barray_check_bounds.exit894
  %200 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn987999, i64 %60, 1
  %201 = shl nuw nsw i64 1, %"79_0.sroa.15.01000"
  %202 = xor i64 %197, %201
  store i64 %202, ptr %304, align 4
  %203 = getelementptr inbounds nuw i1, ptr %303, i64 %"79_0.sroa.15.01000"
  store i1 %read_bool, ptr %203, align 1
  %204 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn987999, 0
  %exitcond1007.not = icmp eq i64 %60, 10
  br i1 %exitcond1007.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit"
  %205 = tail call ptr @heap_alloc(i64 10)
  %206 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %206, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %205, ptr noundef nonnull align 1 dereferenceable(10) %303, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %205)
  %207 = load i64, ptr %304, align 4
  %208 = and i64 %207, 1023
  store i64 %208, ptr %304, align 4
  %209 = icmp eq i64 %208, 0
  br i1 %209, label %__barray_check_none_borrowed.exit901, label %mask_block_err.i899

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit901:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %210 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %210, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %303, ptr %arr_ptr, align 8
  store ptr %210, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  br label %pow.i.preheader

mask_block_err.i899:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

pow.i.preheader:                                  ; preds = %cond_exit_120, %__barray_check_none_borrowed.exit901
  %"115_0.sroa.0.01002" = phi i64 [ 0, %__barray_check_none_borrowed.exit901 ], [ %211, %cond_exit_120 ]
  %211 = add nuw nsw i64 %"115_0.sroa.0.01002", 1
  br label %pow.i

pow.i:                                            ; preds = %pow.i.preheader, %pow_body.i
  %storemerge53.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %pow.i.preheader ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"115_0.sroa.0.01002", %pow.i.preheader ]
  switch i64 %storemerge.i, label %pow_body.i [
    i64 1, label %__hugr__.guppylang.std.num.int.__pow__.434.exit.loopexit
    i64 0, label %__barray_check_bounds.exit909
  ]

pow_body.i:                                       ; preds = %pow.i
  %new_acc.i = shl i64 %storemerge53.i, 1
  %new_exp.i = add i64 %storemerge.i, -1
  br label %pow.i

__hugr__.guppylang.std.num.int.__pow__.434.exit.loopexit: ; preds = %pow.i
  %212 = sitofp i64 %storemerge53.i to double
  br label %__barray_check_bounds.exit909

__barray_check_bounds.exit909:                    ; preds = %pow.i, %__hugr__.guppylang.std.num.int.__pow__.434.exit.loopexit
  %storemerge55.i = phi double [ %212, %__hugr__.guppylang.std.num.int.__pow__.434.exit.loopexit ], [ 1.000000e+00, %pow.i ]
  %213 = load i64, ptr %256, align 4
  %214 = lshr i64 %213, %"115_0.sroa.0.01002"
  %215 = trunc i64 %214 to i1
  br i1 %215, label %cond_exit_120, label %panic.i910

panic.i910:                                       ; preds = %__barray_check_bounds.exit909
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_120:                                    ; preds = %__barray_check_bounds.exit909
  %216 = fdiv double 1.000000e+00, %storemerge55.i
  %217 = shl nuw nsw i64 1, %"115_0.sroa.0.01002"
  %218 = xor i64 %213, %217
  store i64 %218, ptr %256, align 4
  %219 = getelementptr inbounds nuw double, ptr %255, i64 %"115_0.sroa.0.01002"
  store double %216, ptr %219, align 8
  %exitcond1008.not = icmp eq i64 %211, 10
  br i1 %exitcond1008.not, label %loop_out197, label %pow.i.preheader

loop_out197:                                      ; preds = %cond_exit_120
  %220 = load i64, ptr %256, align 4
  %221 = and i64 %220, 1023
  store i64 %221, ptr %256, align 4
  %222 = icmp eq i64 %221, 0
  br i1 %222, label %__barray_check_none_borrowed.exit916, label %mask_block_err.i914

__barray_check_none_borrowed.exit916:             ; preds = %loop_out197
  %223 = call ptr @heap_alloc(i64 80)
  %224 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %224, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(80) %223, ptr noundef nonnull align 1 dereferenceable(80) %255, i64 80, i1 false)
  call void @heap_free(ptr nonnull %223)
  %225 = load i64, ptr %256, align 4
  %226 = and i64 %225, 1023
  store i64 %226, ptr %256, align 4
  %227 = icmp eq i64 %226, 0
  br i1 %227, label %__barray_check_none_borrowed.exit921, label %mask_block_err.i919

mask_block_err.i914:                              ; preds = %loop_out197
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit921:             ; preds = %__barray_check_none_borrowed.exit916
  %out_arr_alloca277 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr279 = getelementptr inbounds nuw i8, ptr %out_arr_alloca277, i64 4
  %arr_ptr280 = getelementptr inbounds nuw i8, ptr %out_arr_alloca277, i64 8
  %mask_ptr281 = getelementptr inbounds nuw i8, ptr %out_arr_alloca277, i64 16
  %228 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %228, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca277, align 8
  store i32 1, ptr %y_ptr279, align 4
  store ptr %255, ptr %arr_ptr280, align 8
  store ptr %228, ptr %mask_ptr281, align 8
  call void @print_float_arr(ptr nonnull @res_floats.8646C2EF.0, i64 20, ptr nonnull %out_arr_alloca277)
  br label %__barray_check_bounds.exit929

mask_block_err.i919:                              ; preds = %__barray_check_none_borrowed.exit916
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit929:                    ; preds = %cond_exit_162, %__barray_check_none_borrowed.exit921
  %"157_0.sroa.0.01004" = phi i64 [ 0, %__barray_check_none_borrowed.exit921 ], [ %235, %cond_exit_162 ]
  %229 = lshr i64 %"157_0.sroa.0.01004", 6
  %230 = getelementptr inbounds nuw i64, ptr %254, i64 %229
  %231 = load i64, ptr %230, align 4
  %232 = and i64 %"157_0.sroa.0.01004", 63
  %233 = lshr i64 %231, %232
  %234 = trunc i64 %233 to i1
  br i1 %234, label %cond_exit_162, label %panic.i930

panic.i930:                                       ; preds = %__barray_check_bounds.exit929
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_162:                                    ; preds = %__barray_check_bounds.exit929
  %235 = add nuw nsw i64 %"157_0.sroa.0.01004", 1
  %236 = shl nuw i64 1, %232
  %237 = xor i64 %231, %236
  store i64 %237, ptr %230, align 4
  %238 = getelementptr inbounds nuw i64, ptr %253, i64 %"157_0.sroa.0.01004"
  store i64 %"157_0.sroa.0.01004", ptr %238, align 4
  %exitcond1009.not = icmp eq i64 %235, 100
  br i1 %exitcond1009.not, label %loop_out285, label %__barray_check_bounds.exit929

loop_out285:                                      ; preds = %cond_exit_162
  %239 = getelementptr inbounds nuw i8, ptr %254, i64 8
  %240 = load i64, ptr %239, align 4
  %241 = and i64 %240, 68719476735
  store i64 %241, ptr %239, align 4
  %242 = load i64, ptr %254, align 4
  %243 = icmp eq i64 %242, 0
  %244 = icmp eq i64 %241, 0
  %or.cond = select i1 %243, i1 %244, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit936, label %mask_block_err.i934

__barray_check_none_borrowed.exit936:             ; preds = %loop_out285
  %245 = call ptr @heap_alloc(i64 800)
  %246 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %246, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %245, ptr noundef nonnull align 1 dereferenceable(800) %253, i64 800, i1 false)
  call void @heap_free(ptr nonnull %245)
  %247 = load i64, ptr %239, align 4
  %248 = and i64 %247, 68719476735
  store i64 %248, ptr %239, align 4
  %249 = load i64, ptr %254, align 4
  %250 = icmp eq i64 %249, 0
  %251 = icmp eq i64 %248, 0
  %or.cond1019 = select i1 %250, i1 %251, i1 false
  br i1 %or.cond1019, label %__barray_check_none_borrowed.exit941, label %mask_block_err.i939

mask_block_err.i934:                              ; preds = %loop_out285
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit941:             ; preds = %__barray_check_none_borrowed.exit936
  %out_arr_alloca361 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr363 = getelementptr inbounds nuw i8, ptr %out_arr_alloca361, i64 4
  %arr_ptr364 = getelementptr inbounds nuw i8, ptr %out_arr_alloca361, i64 8
  %mask_ptr365 = getelementptr inbounds nuw i8, ptr %out_arr_alloca361, i64 16
  %252 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %252, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca361, align 8
  store i32 1, ptr %y_ptr363, align 4
  store ptr %253, ptr %arr_ptr364, align 8
  store ptr %252, ptr %mask_ptr365, align 8
  call void @print_int_arr(ptr nonnull @res_ints.B3BC9D53.0, i64 16, ptr nonnull %out_arr_alloca361)
  ret void

mask_block_err.i939:                              ; preds = %__barray_check_none_borrowed.exit936
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_192:                                    ; preds = %__barray_mask_return.exit892
  %253 = tail call ptr @heap_alloc(i64 800)
  %254 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %254, i8 -1, i64 16, i1 false)
  %255 = tail call ptr @heap_alloc(i64 80)
  %256 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %256, align 1
  %257 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"116.fca.2.insert", 0
  %258 = tail call ptr @heap_alloc(i64 80)
  %259 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %259, align 1
  br label %__barray_check_bounds.exit.i.i

260:                                              ; preds = %loop_body.i
  %261 = lshr i64 %.fca.2.extract.i.i, 6
  %262 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %261
  %263 = load i64, ptr %262, align 4
  %264 = and i64 %.fca.2.extract.i.i, 63
  %265 = sub nuw nsw i64 64, %264
  %266 = lshr i64 -1, %265
  %267 = icmp eq i64 %264, 0
  %268 = select i1 %267, i64 0, i64 %266
  %269 = or i64 %263, %268
  store i64 %269, ptr %262, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %270 = lshr i64 %last_valid.i.i.i, 6
  %271 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %270
  %272 = load i64, ptr %271, align 4
  %273 = and i64 %last_valid.i.i.i, 63
  %274 = shl nsw i64 -2, %273
  %275 = icmp eq i64 %273, 63
  %276 = select i1 %275, i64 0, i64 %274
  %277 = or i64 %272, %276
  store i64 %277, ptr %271, align 4
  %reass.sub.i.i.i = sub nsw i64 %270, %261
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit", label %mask_block_ok.i.i.i

278:                                              ; preds = %mask_block_ok.i.i.i
  %279 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %260, %278
  %.02.i.i.i = phi i64 [ %279, %278 ], [ 0, %260 ]
  %gep.i.i.i = getelementptr i64, ptr %262, i64 %.02.i.i.i
  %280 = load i64, ptr %gep.i.i.i, align 4
  %281 = icmp eq i64 %280, -1
  br i1 %281, label %278, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_192
  %.fca.2.extract.i181.i = phi i64 [ 0, %cond_exit_192 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %cond_exit_192 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %cond_exit_192 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"356_0.sroa.15.0178.i" = phi i64 [ 0, %cond_exit_192 ], [ %282, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %257, %cond_exit_192 ], [ %297, %loop_body.i ]
  %282 = add nuw nsw i64 %"356_0.sroa.15.0178.i", 1
  %283 = add i64 %"356_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %284 = lshr i64 %283, 6
  %285 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %284
  %286 = load i64, ptr %285, align 4
  %287 = and i64 %283, 63
  %288 = lshr i64 %286, %287
  %289 = trunc i64 %288 to i1
  br i1 %289, label %panic.i.i.i, label %__barray_check_bounds.exit.i942

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i942:                  ; preds = %__barray_check_bounds.exit.i.i
  %290 = shl nuw i64 1, %287
  %291 = xor i64 %290, %286
  store i64 %291, ptr %285, align 4
  %292 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %283
  %293 = load i64, ptr %292, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %293)
  tail call void @___qfree(i64 %293)
  %294 = load i64, ptr %259, align 4
  %295 = lshr i64 %294, %"356_0.sroa.15.0178.i"
  %296 = trunc i64 %295 to i1
  br i1 %296, label %loop_body.i, label %panic.i.i943

panic.i.i943:                                     ; preds = %__barray_check_bounds.exit.i942
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i942
  %297 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %282, 1
  %298 = shl nuw nsw i64 1, %"356_0.sroa.15.0178.i"
  %299 = xor i64 %294, %298
  store i64 %299, ptr %259, align 4
  %300 = getelementptr inbounds nuw i64, ptr %258, i64 %"356_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %300, align 4
  %301 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %301, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %301, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %301, 2
  %exitcond.not.i944 = icmp eq i64 %282, 10
  br i1 %exitcond.not.i944, label %260, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.342.exit": ; preds = %278, %260
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %258, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %259, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %302 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %303 = tail call ptr @heap_alloc(i64 10)
  %304 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %304, align 1
  br label %__barray_check_bounds.exit.i
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @heap_free(ptr) local_unnamed_addr

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

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
