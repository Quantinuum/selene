; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

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
  br i1 %not_max.not.not.i, label %cond_597_case_0.i, label %__barray_check_bounds.exit

cond_597_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
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
  br i1 %not_max.not.not.i.1, label %cond_597_case_0.i, label %__barray_check_bounds.exit.1

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
  br i1 %not_max.not.not.i.2, label %cond_597_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not1015 = icmp eq i64 %10, 0
  br i1 %.not1015, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_597_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not1016 = icmp eq i64 %14, 0
  br i1 %.not1016, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_597_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not1017 = icmp eq i64 %18, 0
  br i1 %.not1017, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_597_case_0.i, label %__barray_check_bounds.exit.5

__barray_check_bounds.exit.5:                     ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not1018 = icmp eq i64 %22, 0
  br i1 %.not1018, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__barray_check_bounds.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_597_case_0.i, label %__barray_check_bounds.exit.6

__barray_check_bounds.exit.6:                     ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not1019 = icmp eq i64 %26, 0
  br i1 %.not1019, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__barray_check_bounds.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_597_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not1020 = icmp eq i64 %30, 0
  br i1 %.not1020, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_597_case_0.i, label %__barray_check_bounds.exit.8

__barray_check_bounds.exit.8:                     ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not1021 = icmp eq i64 %34, 0
  br i1 %.not1021, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__barray_check_bounds.exit.8
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
  %.not1022 = icmp eq i64 %38, 0
  br i1 %.not1022, label %panic.i, label %cond_exit_20.9

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
  tail call void @___rp(i64 %48, double 0x400921FB54442D18, double 0.000000e+00)
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
  %exitcond1007.not = icmp eq i64 %41, 10
  br i1 %exitcond1007.not, label %cond_exit_192, label %__barray_check_bounds.exit887

loop_body.preheader.i:                            ; preds = %loop_body122
  %"617_1.sroa.10.0.i" = extractvalue { ptr, ptr, i64 } %113, 2
  %"617_1.sroa.5.0.i" = extractvalue { ptr, ptr, i64 } %113, 1
  %"617_1.sroa.0.0.i" = extractvalue { ptr, ptr, i64 } %113, 0
  br label %__barray_check_bounds.exit224.i

__barray_check_bounds.exit.i:                     ; preds = %loop_body122, %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit"
  %53 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit" ], [ %113, %loop_body122 ]
  %"79_0.sroa.15.01000" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit" ], [ %54, %loop_body122 ]
  %.pn987999 = phi { { ptr, ptr, i64 }, i64 } [ %221, %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit" ], [ %109, %loop_body122 ]
  %54 = add nuw nsw i64 %"79_0.sroa.15.01000", 1
  %.fca.2.extract208.i = extractvalue { ptr, ptr, i64 } %53, 2
  %.fca.1.extract207.i = extractvalue { ptr, ptr, i64 } %53, 1
  %55 = add i64 %.fca.2.extract208.i, %"79_0.sroa.15.01000"
  %56 = lshr i64 %55, 6
  %57 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i, i64 %56
  %58 = load i64, ptr %57, align 4
  %59 = and i64 %55, 63
  %60 = lshr i64 %58, %59
  %61 = trunc i64 %60 to i1
  br i1 %61, label %panic.i.i, label %__barray_check_bounds.exit221.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i:                  ; preds = %__barray_check_bounds.exit.i
  %.fca.0.extract206.i = extractvalue { ptr, ptr, i64 } %53, 0
  %62 = shl nuw i64 1, %59
  %63 = xor i64 %58, %62
  store i64 %63, ptr %57, align 4
  %64 = getelementptr inbounds i64, ptr %.fca.0.extract206.i, i64 %55
  %65 = load i64, ptr %64, align 4
  tail call void @___inc_future_refcount(i64 %65)
  %66 = load i64, ptr %57, align 4
  %67 = lshr i64 %66, %59
  %68 = trunc i64 %67 to i1
  br i1 %68, label %__barray_check_bounds.exit894, label %panic.i222.i

panic.i222.i:                                     ; preds = %__barray_check_bounds.exit221.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_620_case_0.i:                                ; preds = %cond_exit_620.thread.i
  %69 = lshr i64 %"617_1.sroa.10.0.i", 6
  %70 = getelementptr i64, ptr %"617_1.sroa.5.0.i", i64 %69
  %71 = load i64, ptr %70, align 4
  %72 = and i64 %"617_1.sroa.10.0.i", 63
  %73 = sub nuw nsw i64 64, %72
  %74 = lshr i64 -1, %73
  %75 = icmp eq i64 %72, 0
  %76 = select i1 %75, i64 0, i64 %74
  %77 = or i64 %71, %76
  store i64 %77, ptr %70, align 4
  %last_valid.i.i = add i64 %"617_1.sroa.10.0.i", 9
  %78 = lshr i64 %last_valid.i.i, 6
  %79 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %78
  %80 = load i64, ptr %79, align 4
  %81 = and i64 %last_valid.i.i, 63
  %82 = shl nsw i64 -2, %81
  %83 = icmp eq i64 %81, 63
  %84 = select i1 %83, i64 0, i64 %82
  %85 = or i64 %80, %84
  store i64 %85, ptr %79, align 4
  %reass.sub.i.i = sub nsw i64 %78, %69
  %.not.i.i = icmp eq i64 %reass.sub.i.i, -1
  br i1 %.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit", label %mask_block_ok.i.i

86:                                               ; preds = %mask_block_ok.i.i
  %87 = add nuw i64 %.02.i.i, 1
  %exitcond.not.i.i = icmp eq i64 %.02.i.i, %reass.sub.i.i
  br i1 %exitcond.not.i.i, label %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit", label %mask_block_ok.i.i

mask_block_ok.i.i:                                ; preds = %cond_620_case_0.i, %86
  %.02.i.i = phi i64 [ %87, %86 ], [ 0, %cond_620_case_0.i ]
  %gep.i.i = getelementptr i64, ptr %70, i64 %.02.i.i
  %88 = load i64, ptr %gep.i.i, align 4
  %89 = icmp eq i64 %88, -1
  br i1 %89, label %86, label %mask_block_err.i.i

mask_block_err.i.i:                               ; preds = %mask_block_ok.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i:                  ; preds = %cond_exit_620.thread.i, %loop_body.preheader.i
  %"617_0.0239.i" = phi i64 [ 0, %loop_body.preheader.i ], [ %90, %cond_exit_620.thread.i ]
  %90 = add nuw nsw i64 %"617_0.0239.i", 1
  %91 = add i64 %"617_0.0239.i", %"617_1.sroa.10.0.i"
  %92 = lshr i64 %91, 6
  %93 = getelementptr inbounds nuw i64, ptr %"617_1.sroa.5.0.i", i64 %92
  %94 = load i64, ptr %93, align 4
  %95 = and i64 %91, 63
  %96 = lshr i64 %94, %95
  %97 = trunc i64 %96 to i1
  br i1 %97, label %cond_exit_620.thread.i, label %__barray_mask_borrow.exit228.i

__barray_mask_borrow.exit228.i:                   ; preds = %__barray_check_bounds.exit224.i
  %98 = shl nuw i64 1, %95
  %99 = xor i64 %98, %94
  store i64 %99, ptr %93, align 4
  %100 = getelementptr inbounds i64, ptr %"617_1.sroa.0.0.i", i64 %91
  %101 = load i64, ptr %100, align 4
  tail call void @___dec_future_refcount(i64 %101)
  br label %cond_exit_620.thread.i

cond_exit_620.thread.i:                           ; preds = %__barray_mask_borrow.exit228.i, %__barray_check_bounds.exit224.i
  %exitcond.i = icmp eq i64 %90, 10
  br i1 %exitcond.i, label %cond_620_case_0.i, label %__barray_check_bounds.exit224.i

"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit": ; preds = %86, %cond_620_case_0.i
  tail call void @heap_free(ptr %"617_1.sroa.0.0.i")
  tail call void @heap_free(ptr nonnull %"617_1.sroa.5.0.i")
  %102 = load i64, ptr %223, align 4
  %103 = and i64 %102, 1023
  store i64 %103, ptr %223, align 4
  %104 = icmp eq i64 %103, 0
  br i1 %104, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_bounds.exit894:                    ; preds = %__barray_check_bounds.exit221.i
  %105 = xor i64 %66, %62
  store i64 %105, ptr %57, align 4
  store i64 %65, ptr %64, align 4
  %read_bool = tail call i1 @___read_future_bool(i64 %65)
  tail call void @___dec_future_refcount(i64 %65)
  %106 = load i64, ptr %223, align 4
  %107 = lshr i64 %106, %"79_0.sroa.15.01000"
  %108 = trunc i64 %107 to i1
  br i1 %108, label %loop_body122, label %panic.i895

panic.i895:                                       ; preds = %__barray_check_bounds.exit894
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body122:                                     ; preds = %__barray_check_bounds.exit894
  %109 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn987999, i64 %54, 1
  %110 = shl nuw nsw i64 1, %"79_0.sroa.15.01000"
  %111 = xor i64 %106, %110
  store i64 %111, ptr %223, align 4
  %112 = getelementptr inbounds nuw i1, ptr %222, i64 %"79_0.sroa.15.01000"
  store i1 %read_bool, ptr %112, align 1
  %113 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn987999, 0
  %exitcond1008.not = icmp eq i64 %54, 10
  br i1 %exitcond1008.not, label %loop_body.preheader.i, label %__barray_check_bounds.exit.i

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit"
  %114 = tail call ptr @heap_alloc(i64 10)
  %115 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %115, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %114, ptr noundef nonnull align 1 dereferenceable(10) %222, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %114)
  %116 = load i64, ptr %223, align 4
  %117 = and i64 %116, 1023
  store i64 %117, ptr %223, align 4
  %118 = icmp eq i64 %117, 0
  br i1 %118, label %__barray_check_none_borrowed.exit901, label %mask_block_err.i899

mask_block_err.i:                                 ; preds = %"__hugr__.guppylang.std.array.ArrayIter.__next__$Measurement&10.383.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit901:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %119 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %119, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %222, ptr %arr_ptr, align 8
  store ptr %119, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  br label %pow.i.preheader

mask_block_err.i899:                              ; preds = %__barray_check_none_borrowed.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

pow.i.preheader:                                  ; preds = %cond_exit_120, %__barray_check_none_borrowed.exit901
  %"115_0.sroa.0.01002" = phi i64 [ 0, %__barray_check_none_borrowed.exit901 ], [ %120, %cond_exit_120 ]
  %120 = add nuw nsw i64 %"115_0.sroa.0.01002", 1
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
  %121 = sitofp i64 %storemerge53.i to double
  br label %__barray_check_bounds.exit909

__barray_check_bounds.exit909:                    ; preds = %pow.i, %__hugr__.guppylang.std.num.int.__pow__.434.exit.loopexit
  %storemerge55.i = phi double [ %121, %__hugr__.guppylang.std.num.int.__pow__.434.exit.loopexit ], [ 1.000000e+00, %pow.i ]
  %122 = load i64, ptr %175, align 4
  %123 = lshr i64 %122, %"115_0.sroa.0.01002"
  %124 = trunc i64 %123 to i1
  br i1 %124, label %cond_exit_120, label %panic.i910

panic.i910:                                       ; preds = %__barray_check_bounds.exit909
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_120:                                    ; preds = %__barray_check_bounds.exit909
  %125 = fdiv double 1.000000e+00, %storemerge55.i
  %126 = shl nuw nsw i64 1, %"115_0.sroa.0.01002"
  %127 = xor i64 %122, %126
  store i64 %127, ptr %175, align 4
  %128 = getelementptr inbounds nuw double, ptr %174, i64 %"115_0.sroa.0.01002"
  store double %125, ptr %128, align 8
  %exitcond1009.not = icmp eq i64 %120, 10
  br i1 %exitcond1009.not, label %loop_out197, label %pow.i.preheader

loop_out197:                                      ; preds = %cond_exit_120
  %129 = load i64, ptr %175, align 4
  %130 = and i64 %129, 1023
  store i64 %130, ptr %175, align 4
  %131 = icmp eq i64 %130, 0
  br i1 %131, label %__barray_check_none_borrowed.exit916, label %mask_block_err.i914

__barray_check_none_borrowed.exit916:             ; preds = %loop_out197
  %132 = call ptr @heap_alloc(i64 80)
  %133 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %133, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(80) %132, ptr noundef nonnull align 1 dereferenceable(80) %174, i64 80, i1 false)
  call void @heap_free(ptr nonnull %132)
  %134 = load i64, ptr %175, align 4
  %135 = and i64 %134, 1023
  store i64 %135, ptr %175, align 4
  %136 = icmp eq i64 %135, 0
  br i1 %136, label %__barray_check_none_borrowed.exit921, label %mask_block_err.i919

mask_block_err.i914:                              ; preds = %loop_out197
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit921:             ; preds = %__barray_check_none_borrowed.exit916
  %out_arr_alloca277 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr279 = getelementptr inbounds nuw i8, ptr %out_arr_alloca277, i64 4
  %arr_ptr280 = getelementptr inbounds nuw i8, ptr %out_arr_alloca277, i64 8
  %mask_ptr281 = getelementptr inbounds nuw i8, ptr %out_arr_alloca277, i64 16
  %137 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %137, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca277, align 8
  store i32 1, ptr %y_ptr279, align 4
  store ptr %174, ptr %arr_ptr280, align 8
  store ptr %137, ptr %mask_ptr281, align 8
  call void @print_float_arr(ptr nonnull @res_floats.8646C2EF.0, i64 20, ptr nonnull %out_arr_alloca277)
  br label %__barray_check_bounds.exit929

mask_block_err.i919:                              ; preds = %__barray_check_none_borrowed.exit916
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit929:                    ; preds = %cond_exit_162.1, %__barray_check_none_borrowed.exit921
  %"157_0.sroa.0.01004" = phi i64 [ 0, %__barray_check_none_borrowed.exit921 ], [ %154, %cond_exit_162.1 ]
  %138 = lshr i64 %"157_0.sroa.0.01004", 6
  %139 = getelementptr inbounds nuw i64, ptr %173, i64 %138
  %140 = load i64, ptr %139, align 4
  %141 = and i64 %"157_0.sroa.0.01004", 62
  %142 = lshr i64 %140, %141
  %143 = trunc i64 %142 to i1
  br i1 %143, label %cond_exit_162, label %panic.i930

panic.i930:                                       ; preds = %cond_exit_162, %__barray_check_bounds.exit929
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_162:                                    ; preds = %__barray_check_bounds.exit929
  %144 = or disjoint i64 %"157_0.sroa.0.01004", 1
  %145 = shl nuw nsw i64 1, %141
  %146 = xor i64 %140, %145
  store i64 %146, ptr %139, align 4
  %147 = getelementptr inbounds nuw i64, ptr %172, i64 %"157_0.sroa.0.01004"
  store i64 %"157_0.sroa.0.01004", ptr %147, align 4
  %148 = lshr i64 %"157_0.sroa.0.01004", 6
  %149 = getelementptr inbounds nuw i64, ptr %173, i64 %148
  %150 = load i64, ptr %149, align 4
  %151 = and i64 %144, 63
  %152 = lshr i64 %150, %151
  %153 = trunc i64 %152 to i1
  br i1 %153, label %cond_exit_162.1, label %panic.i930

cond_exit_162.1:                                  ; preds = %cond_exit_162
  %154 = add nuw nsw i64 %"157_0.sroa.0.01004", 2
  %155 = shl nuw i64 1, %151
  %156 = xor i64 %150, %155
  store i64 %156, ptr %149, align 4
  %157 = getelementptr inbounds nuw i64, ptr %172, i64 %144
  store i64 %144, ptr %157, align 4
  %exitcond1010.not.1 = icmp eq i64 %154, 100
  br i1 %exitcond1010.not.1, label %loop_out285, label %__barray_check_bounds.exit929

loop_out285:                                      ; preds = %cond_exit_162.1
  %158 = getelementptr inbounds nuw i8, ptr %173, i64 8
  %159 = load i64, ptr %158, align 4
  %160 = and i64 %159, 68719476735
  store i64 %160, ptr %158, align 4
  %161 = load i64, ptr %173, align 4
  %162 = icmp eq i64 %161, 0
  %163 = icmp eq i64 %160, 0
  %or.cond = select i1 %162, i1 %163, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit936, label %mask_block_err.i934

__barray_check_none_borrowed.exit936:             ; preds = %loop_out285
  %164 = call ptr @heap_alloc(i64 800)
  %165 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %165, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %164, ptr noundef nonnull align 1 dereferenceable(800) %172, i64 800, i1 false)
  call void @heap_free(ptr nonnull %164)
  %166 = load i64, ptr %158, align 4
  %167 = and i64 %166, 68719476735
  store i64 %167, ptr %158, align 4
  %168 = load i64, ptr %173, align 4
  %169 = icmp eq i64 %168, 0
  %170 = icmp eq i64 %167, 0
  %or.cond1012 = select i1 %169, i1 %170, i1 false
  br i1 %or.cond1012, label %__barray_check_none_borrowed.exit941, label %mask_block_err.i939

mask_block_err.i934:                              ; preds = %loop_out285
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit941:             ; preds = %__barray_check_none_borrowed.exit936
  %out_arr_alloca361 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr363 = getelementptr inbounds nuw i8, ptr %out_arr_alloca361, i64 4
  %arr_ptr364 = getelementptr inbounds nuw i8, ptr %out_arr_alloca361, i64 8
  %mask_ptr365 = getelementptr inbounds nuw i8, ptr %out_arr_alloca361, i64 16
  %171 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %171, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca361, align 8
  store i32 1, ptr %y_ptr363, align 4
  store ptr %172, ptr %arr_ptr364, align 8
  store ptr %171, ptr %mask_ptr365, align 8
  call void @print_int_arr(ptr nonnull @res_ints.B3BC9D53.0, i64 16, ptr nonnull %out_arr_alloca361)
  ret void

mask_block_err.i939:                              ; preds = %__barray_check_none_borrowed.exit936
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_192:                                    ; preds = %__barray_mask_return.exit892
  %172 = tail call ptr @heap_alloc(i64 800)
  %173 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %173, i8 -1, i64 16, i1 false)
  %174 = tail call ptr @heap_alloc(i64 80)
  %175 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %175, align 1
  %176 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"116.fca.2.insert", 0
  %177 = tail call ptr @heap_alloc(i64 80)
  %178 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %178, align 1
  br label %__barray_check_bounds.exit.i.i

179:                                              ; preds = %loop_body.i
  %180 = lshr i64 %.fca.2.extract.i.i, 6
  %181 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %180
  %182 = load i64, ptr %181, align 4
  %183 = and i64 %.fca.2.extract.i.i, 63
  %184 = sub nuw nsw i64 64, %183
  %185 = lshr i64 -1, %184
  %186 = icmp eq i64 %183, 0
  %187 = select i1 %186, i64 0, i64 %185
  %188 = or i64 %182, %187
  store i64 %188, ptr %181, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %189 = lshr i64 %last_valid.i.i.i, 6
  %190 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %189
  %191 = load i64, ptr %190, align 4
  %192 = and i64 %last_valid.i.i.i, 63
  %193 = shl nsw i64 -2, %192
  %194 = icmp eq i64 %192, 63
  %195 = select i1 %194, i64 0, i64 %193
  %196 = or i64 %191, %195
  store i64 %196, ptr %190, align 4
  %reass.sub.i.i.i = sub nsw i64 %189, %180
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit", label %mask_block_ok.i.i.i

197:                                              ; preds = %mask_block_ok.i.i.i
  %198 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.342.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %179, %197
  %.02.i.i.i = phi i64 [ %198, %197 ], [ 0, %179 ]
  %gep.i.i.i = getelementptr i64, ptr %181, i64 %.02.i.i.i
  %199 = load i64, ptr %gep.i.i.i, align 4
  %200 = icmp eq i64 %199, -1
  br i1 %200, label %197, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_192
  %.fca.2.extract.i181.i = phi i64 [ 0, %cond_exit_192 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %cond_exit_192 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %cond_exit_192 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"356_0.sroa.15.0178.i" = phi i64 [ 0, %cond_exit_192 ], [ %201, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %176, %cond_exit_192 ], [ %216, %loop_body.i ]
  %201 = add nuw nsw i64 %"356_0.sroa.15.0178.i", 1
  %202 = add i64 %"356_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %203 = lshr i64 %202, 6
  %204 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %203
  %205 = load i64, ptr %204, align 4
  %206 = and i64 %202, 63
  %207 = lshr i64 %205, %206
  %208 = trunc i64 %207 to i1
  br i1 %208, label %panic.i.i.i, label %__barray_check_bounds.exit.i942

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i942:                  ; preds = %__barray_check_bounds.exit.i.i
  %209 = shl nuw i64 1, %206
  %210 = xor i64 %209, %205
  store i64 %210, ptr %204, align 4
  %211 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %202
  %212 = load i64, ptr %211, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %212)
  tail call void @___qfree(i64 %212)
  %213 = load i64, ptr %178, align 4
  %214 = lshr i64 %213, %"356_0.sroa.15.0178.i"
  %215 = trunc i64 %214 to i1
  br i1 %215, label %loop_body.i, label %panic.i.i943

panic.i.i943:                                     ; preds = %__barray_check_bounds.exit.i942
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i942
  %216 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %201, 1
  %217 = shl nuw nsw i64 1, %"356_0.sroa.15.0178.i"
  %218 = xor i64 %213, %217
  store i64 %218, ptr %178, align 4
  %219 = getelementptr inbounds nuw i64, ptr %177, i64 %"356_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %219, align 4
  %220 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %220, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %220, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %220, 2
  %exitcond.not.i944 = icmp eq i64 %201, 10
  br i1 %exitcond.not.i944, label %179, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.342.exit": ; preds = %197, %179
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %177, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %178, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %221 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %222 = tail call ptr @heap_alloc(i64 10)
  %223 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %223, align 1
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

declare void @___rp(i64, double, double) local_unnamed_addr

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
