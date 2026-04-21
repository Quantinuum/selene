; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-windows-gnu"

@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_bools.B1D99BB9.0 = private constant [19 x i8] c"\12USER:BOOLARR:bools"
@res_floats.8646C2EF.0 = private constant [21 x i8] c"\14USER:FLOATARR:floats"
@res_ints.B3BC9D53.0 = private constant [17 x i8] c"\10USER:INTARR:ints"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define internal fastcc void @__hugr__.__main__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call ptr @heap_alloc(i64 80)
  %1 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %1, align 1
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.not.i, label %cond_433_case_0.i, label %__barray_check_bounds.exit

cond_433_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
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
  br i1 %not_max.not.not.i.1, label %cond_433_case_0.i, label %__barray_check_bounds.exit.1

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
  br i1 %not_max.not.not.i.2, label %cond_433_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not1017 = icmp eq i64 %10, 0
  br i1 %.not1017, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_433_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not1018 = icmp eq i64 %14, 0
  br i1 %.not1018, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_433_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not1019 = icmp eq i64 %18, 0
  br i1 %.not1019, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_433_case_0.i, label %__barray_check_bounds.exit.5

__barray_check_bounds.exit.5:                     ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not1020 = icmp eq i64 %22, 0
  br i1 %.not1020, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__barray_check_bounds.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_433_case_0.i, label %__barray_check_bounds.exit.6

__barray_check_bounds.exit.6:                     ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not1021 = icmp eq i64 %26, 0
  br i1 %.not1021, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__barray_check_bounds.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_433_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not1022 = icmp eq i64 %30, 0
  br i1 %.not1022, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_433_case_0.i, label %__barray_check_bounds.exit.8

__barray_check_bounds.exit.8:                     ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not1023 = icmp eq i64 %34, 0
  br i1 %.not1023, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__barray_check_bounds.exit.8
  %35 = and i64 %33, -257
  store i64 %35, ptr %1, align 4
  %36 = getelementptr inbounds nuw i8, ptr %0, i64 64
  store i64 %qalloc.i.8, ptr %36, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_433_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %37 = load i64, ptr %1, align 4
  %38 = and i64 %37, 512
  %.not1024 = icmp eq i64 %38, 0
  br i1 %.not1024, label %panic.i, label %cond_exit_20.9

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
  %"47_0.0991" = phi i64 [ 0, %cond_exit_20.9 ], [ %41, %__barray_mask_return.exit892 ]
  %41 = add nuw nsw i64 %"47_0.0991", 1
  %42 = load i64, ptr %1, align 4
  %43 = lshr i64 %42, %"47_0.0991"
  %44 = trunc i64 %43 to i1
  br i1 %44, label %panic.i888, label %__barray_check_bounds.exit890

panic.i888:                                       ; preds = %__barray_check_bounds.exit887
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit890:                    ; preds = %__barray_check_bounds.exit887
  %45 = shl nuw nsw i64 1, %"47_0.0991"
  %46 = xor i64 %42, %45
  store i64 %46, ptr %1, align 4
  %47 = getelementptr inbounds nuw i64, ptr %0, i64 %"47_0.0991"
  %48 = load i64, ptr %47, align 4
  tail call void @___rxy(i64 %48, double 0x400921FB54442D18, double 0.000000e+00)
  %49 = load i64, ptr %1, align 4
  %50 = lshr i64 %49, %"47_0.0991"
  %51 = trunc i64 %50 to i1
  br i1 %51, label %__barray_mask_return.exit892, label %panic.i891

panic.i891:                                       ; preds = %__barray_check_bounds.exit890
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit892:                     ; preds = %__barray_check_bounds.exit890
  %52 = xor i64 %49, %45
  store i64 %52, ptr %1, align 4
  store i64 %48, ptr %47, align 4
  %exitcond1005.not = icmp eq i64 %41, 10
  br i1 %exitcond1005.not, label %cond_exit_163, label %__barray_check_bounds.exit887

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit"
  %53 = tail call ptr @heap_alloc(i64 240)
  %54 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %54, align 1
  br label %55

mask_block_err.i:                                 ; preds = %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

55:                                               ; preds = %__barray_check_none_borrowed.exit, %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).383.exit"
  %storemerge747996 = phi i64 [ 0, %__barray_check_none_borrowed.exit ], [ %63, %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).383.exit" ]
  %56 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %284, i64 %storemerge747996
  %57 = load { i1, i64, i1 }, ptr %56, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %57, 0
  br i1 %.fca.0.extract118.i, label %cond_339_case_1.i, label %cond_339_case_0.i

cond_339_case_0.i:                                ; preds = %55
  %.fca.2.extract120.i = extractvalue { i1, i64, i1 } %57, 2
  br label %cond_exit_339.i

cond_339_case_1.i:                                ; preds = %55
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %57, 1
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  br label %cond_exit_339.i

cond_exit_339.i:                                  ; preds = %cond_339_case_0.i, %cond_339_case_1.i
  %"03.sroa.3.0.i" = phi i64 [ %.fca.1.extract119.i, %cond_339_case_1.i ], [ undef, %cond_339_case_0.i ]
  %"03.sroa.6.0.i" = phi i1 [ undef, %cond_339_case_1.i ], [ %.fca.2.extract120.i, %cond_339_case_0.i ]
  %58 = load i64, ptr %329, align 4
  %59 = lshr i64 %58, %storemerge747996
  %60 = trunc i64 %59 to i1
  br i1 %60, label %panic.i.i, label %cond_336_case_1.i

panic.i.i:                                        ; preds = %cond_exit_339.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

cond_336_case_1.i:                                ; preds = %cond_exit_339.i
  %"16.fca.1.insert.i" = insertvalue { i1, i64, i1 } %57, i64 %"03.sroa.3.0.i", 1
  %"16.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"16.fca.1.insert.i", i1 %"03.sroa.6.0.i", 2
  %61 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i", 1
  %62 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %328, i64 %storemerge747996
  %.fca.2.0.extract.i = load i1, ptr %62, align 1
  store { i1, { i1, i64, i1 } } %61, ptr %62, align 4
  br i1 %.fca.2.0.extract.i, label %cond_335_case_1.i, label %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).383.exit"

cond_335_case_1.i:                                ; preds = %cond_336_case_1.i
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.2F17E0A9.0")
  unreachable

"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).383.exit": ; preds = %cond_336_case_1.i
  %63 = add nuw nsw i64 %storemerge747996, 1
  %64 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %53, i64 %storemerge747996
  store { i1, i64, i1 } %"16.fca.2.insert.i", ptr %64, align 4
  %exitcond1006.not = icmp eq i64 %63, 10
  br i1 %exitcond1006.not, label %mask_block_ok.i893, label %55

mask_block_ok.i893:                               ; preds = %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).383.exit"
  tail call void @heap_free(ptr nonnull %284)
  tail call void @heap_free(ptr nonnull %285)
  %65 = load i64, ptr %329, align 4
  %66 = and i64 %65, 1023
  store i64 %66, ptr %329, align 4
  %67 = icmp eq i64 %66, 0
  br i1 %67, label %__barray_check_none_borrowed.exit898, label %mask_block_err.i896

__barray_check_none_borrowed.exit898:             ; preds = %mask_block_ok.i893
  %68 = tail call ptr @heap_alloc(i64 240)
  %69 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %69, align 1
  %70 = load { i1, { i1, i64, i1 } }, ptr %328, align 4
  %71 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %70)
  %72 = extractvalue { { i1, i64, i1 } } %71, 0
  store { i1, i64, i1 } %72, ptr %68, align 4
  %73 = getelementptr i8, ptr %328, i64 32
  %74 = load { i1, { i1, i64, i1 } }, ptr %73, align 4
  %75 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %74)
  %76 = getelementptr inbounds nuw i8, ptr %68, i64 24
  %77 = extractvalue { { i1, i64, i1 } } %75, 0
  store { i1, i64, i1 } %77, ptr %76, align 4
  %78 = getelementptr i8, ptr %328, i64 64
  %79 = load { i1, { i1, i64, i1 } }, ptr %78, align 4
  %80 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %79)
  %81 = getelementptr inbounds nuw i8, ptr %68, i64 48
  %82 = extractvalue { { i1, i64, i1 } } %80, 0
  store { i1, i64, i1 } %82, ptr %81, align 4
  %83 = getelementptr i8, ptr %328, i64 96
  %84 = load { i1, { i1, i64, i1 } }, ptr %83, align 4
  %85 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %84)
  %86 = getelementptr inbounds nuw i8, ptr %68, i64 72
  %87 = extractvalue { { i1, i64, i1 } } %85, 0
  store { i1, i64, i1 } %87, ptr %86, align 4
  %88 = getelementptr i8, ptr %328, i64 128
  %89 = load { i1, { i1, i64, i1 } }, ptr %88, align 4
  %90 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %89)
  %91 = getelementptr inbounds nuw i8, ptr %68, i64 96
  %92 = extractvalue { { i1, i64, i1 } } %90, 0
  store { i1, i64, i1 } %92, ptr %91, align 4
  %93 = getelementptr i8, ptr %328, i64 160
  %94 = load { i1, { i1, i64, i1 } }, ptr %93, align 4
  %95 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %94)
  %96 = getelementptr inbounds nuw i8, ptr %68, i64 120
  %97 = extractvalue { { i1, i64, i1 } } %95, 0
  store { i1, i64, i1 } %97, ptr %96, align 4
  %98 = getelementptr i8, ptr %328, i64 192
  %99 = load { i1, { i1, i64, i1 } }, ptr %98, align 4
  %100 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %99)
  %101 = getelementptr inbounds nuw i8, ptr %68, i64 144
  %102 = extractvalue { { i1, i64, i1 } } %100, 0
  store { i1, i64, i1 } %102, ptr %101, align 4
  %103 = getelementptr i8, ptr %328, i64 224
  %104 = load { i1, { i1, i64, i1 } }, ptr %103, align 4
  %105 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %104)
  %106 = getelementptr inbounds nuw i8, ptr %68, i64 168
  %107 = extractvalue { { i1, i64, i1 } } %105, 0
  store { i1, i64, i1 } %107, ptr %106, align 4
  %108 = getelementptr i8, ptr %328, i64 256
  %109 = load { i1, { i1, i64, i1 } }, ptr %108, align 4
  %110 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %109)
  %111 = getelementptr inbounds nuw i8, ptr %68, i64 192
  %112 = extractvalue { { i1, i64, i1 } } %110, 0
  store { i1, i64, i1 } %112, ptr %111, align 4
  %113 = getelementptr i8, ptr %328, i64 288
  %114 = load { i1, { i1, i64, i1 } }, ptr %113, align 4
  %115 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %114)
  %116 = getelementptr inbounds nuw i8, ptr %68, i64 216
  %117 = extractvalue { { i1, i64, i1 } } %115, 0
  store { i1, i64, i1 } %117, ptr %116, align 4
  tail call void @heap_free(ptr nonnull %328)
  tail call void @heap_free(ptr nonnull %329)
  %118 = load i64, ptr %69, align 4
  %119 = trunc i64 %118 to i1
  br i1 %119, label %cond_exit_665, label %__barray_mask_borrow.exit909

mask_block_err.i896:                              ; preds = %mask_block_ok.i893
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

mask_block_err.i902:                              ; preds = %cond_exit_665.9
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit909:                     ; preds = %__barray_check_none_borrowed.exit898
  %120 = or disjoint i64 %118, 1
  store i64 %120, ptr %69, align 4
  %121 = load { i1, i64, i1 }, ptr %68, align 4
  %.fca.0.extract578 = extractvalue { i1, i64, i1 } %121, 0
  br i1 %.fca.0.extract578, label %cond_688_case_1, label %cond_exit_665

cond_exit_665:                                    ; preds = %cond_688_case_1, %__barray_mask_borrow.exit909, %__barray_check_none_borrowed.exit898
  %122 = load i64, ptr %69, align 4
  %123 = and i64 %122, 2
  %.not1025 = icmp eq i64 %123, 0
  br i1 %.not1025, label %__barray_mask_borrow.exit909.1, label %cond_exit_665.1

__barray_mask_borrow.exit909.1:                   ; preds = %cond_exit_665
  %124 = or disjoint i64 %122, 2
  store i64 %124, ptr %69, align 4
  %125 = getelementptr inbounds nuw i8, ptr %68, i64 24
  %126 = load { i1, i64, i1 }, ptr %125, align 4
  %.fca.0.extract578.1 = extractvalue { i1, i64, i1 } %126, 0
  br i1 %.fca.0.extract578.1, label %cond_688_case_1.1, label %cond_exit_665.1

cond_688_case_1.1:                                ; preds = %__barray_mask_borrow.exit909.1
  %.fca.1.extract579.1 = extractvalue { i1, i64, i1 } %126, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.1)
  br label %cond_exit_665.1

cond_exit_665.1:                                  ; preds = %cond_688_case_1.1, %__barray_mask_borrow.exit909.1, %cond_exit_665
  %127 = load i64, ptr %69, align 4
  %128 = and i64 %127, 4
  %.not1026 = icmp eq i64 %128, 0
  br i1 %.not1026, label %__barray_mask_borrow.exit909.2, label %cond_exit_665.2

__barray_mask_borrow.exit909.2:                   ; preds = %cond_exit_665.1
  %129 = or disjoint i64 %127, 4
  store i64 %129, ptr %69, align 4
  %130 = getelementptr inbounds nuw i8, ptr %68, i64 48
  %131 = load { i1, i64, i1 }, ptr %130, align 4
  %.fca.0.extract578.2 = extractvalue { i1, i64, i1 } %131, 0
  br i1 %.fca.0.extract578.2, label %cond_688_case_1.2, label %cond_exit_665.2

cond_688_case_1.2:                                ; preds = %__barray_mask_borrow.exit909.2
  %.fca.1.extract579.2 = extractvalue { i1, i64, i1 } %131, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.2)
  br label %cond_exit_665.2

cond_exit_665.2:                                  ; preds = %cond_688_case_1.2, %__barray_mask_borrow.exit909.2, %cond_exit_665.1
  %132 = load i64, ptr %69, align 4
  %133 = and i64 %132, 8
  %.not1027 = icmp eq i64 %133, 0
  br i1 %.not1027, label %__barray_mask_borrow.exit909.3, label %cond_exit_665.3

__barray_mask_borrow.exit909.3:                   ; preds = %cond_exit_665.2
  %134 = or disjoint i64 %132, 8
  store i64 %134, ptr %69, align 4
  %135 = getelementptr inbounds nuw i8, ptr %68, i64 72
  %136 = load { i1, i64, i1 }, ptr %135, align 4
  %.fca.0.extract578.3 = extractvalue { i1, i64, i1 } %136, 0
  br i1 %.fca.0.extract578.3, label %cond_688_case_1.3, label %cond_exit_665.3

cond_688_case_1.3:                                ; preds = %__barray_mask_borrow.exit909.3
  %.fca.1.extract579.3 = extractvalue { i1, i64, i1 } %136, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.3)
  br label %cond_exit_665.3

cond_exit_665.3:                                  ; preds = %cond_688_case_1.3, %__barray_mask_borrow.exit909.3, %cond_exit_665.2
  %137 = load i64, ptr %69, align 4
  %138 = and i64 %137, 16
  %.not1028 = icmp eq i64 %138, 0
  br i1 %.not1028, label %__barray_mask_borrow.exit909.4, label %cond_exit_665.4

__barray_mask_borrow.exit909.4:                   ; preds = %cond_exit_665.3
  %139 = or disjoint i64 %137, 16
  store i64 %139, ptr %69, align 4
  %140 = getelementptr inbounds nuw i8, ptr %68, i64 96
  %141 = load { i1, i64, i1 }, ptr %140, align 4
  %.fca.0.extract578.4 = extractvalue { i1, i64, i1 } %141, 0
  br i1 %.fca.0.extract578.4, label %cond_688_case_1.4, label %cond_exit_665.4

cond_688_case_1.4:                                ; preds = %__barray_mask_borrow.exit909.4
  %.fca.1.extract579.4 = extractvalue { i1, i64, i1 } %141, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.4)
  br label %cond_exit_665.4

cond_exit_665.4:                                  ; preds = %cond_688_case_1.4, %__barray_mask_borrow.exit909.4, %cond_exit_665.3
  %142 = load i64, ptr %69, align 4
  %143 = and i64 %142, 32
  %.not1029 = icmp eq i64 %143, 0
  br i1 %.not1029, label %__barray_mask_borrow.exit909.5, label %cond_exit_665.5

__barray_mask_borrow.exit909.5:                   ; preds = %cond_exit_665.4
  %144 = or disjoint i64 %142, 32
  store i64 %144, ptr %69, align 4
  %145 = getelementptr inbounds nuw i8, ptr %68, i64 120
  %146 = load { i1, i64, i1 }, ptr %145, align 4
  %.fca.0.extract578.5 = extractvalue { i1, i64, i1 } %146, 0
  br i1 %.fca.0.extract578.5, label %cond_688_case_1.5, label %cond_exit_665.5

cond_688_case_1.5:                                ; preds = %__barray_mask_borrow.exit909.5
  %.fca.1.extract579.5 = extractvalue { i1, i64, i1 } %146, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.5)
  br label %cond_exit_665.5

cond_exit_665.5:                                  ; preds = %cond_688_case_1.5, %__barray_mask_borrow.exit909.5, %cond_exit_665.4
  %147 = load i64, ptr %69, align 4
  %148 = and i64 %147, 64
  %.not1030 = icmp eq i64 %148, 0
  br i1 %.not1030, label %__barray_mask_borrow.exit909.6, label %cond_exit_665.6

__barray_mask_borrow.exit909.6:                   ; preds = %cond_exit_665.5
  %149 = or disjoint i64 %147, 64
  store i64 %149, ptr %69, align 4
  %150 = getelementptr inbounds nuw i8, ptr %68, i64 144
  %151 = load { i1, i64, i1 }, ptr %150, align 4
  %.fca.0.extract578.6 = extractvalue { i1, i64, i1 } %151, 0
  br i1 %.fca.0.extract578.6, label %cond_688_case_1.6, label %cond_exit_665.6

cond_688_case_1.6:                                ; preds = %__barray_mask_borrow.exit909.6
  %.fca.1.extract579.6 = extractvalue { i1, i64, i1 } %151, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.6)
  br label %cond_exit_665.6

cond_exit_665.6:                                  ; preds = %cond_688_case_1.6, %__barray_mask_borrow.exit909.6, %cond_exit_665.5
  %152 = load i64, ptr %69, align 4
  %153 = and i64 %152, 128
  %.not1031 = icmp eq i64 %153, 0
  br i1 %.not1031, label %__barray_mask_borrow.exit909.7, label %cond_exit_665.7

__barray_mask_borrow.exit909.7:                   ; preds = %cond_exit_665.6
  %154 = or disjoint i64 %152, 128
  store i64 %154, ptr %69, align 4
  %155 = getelementptr inbounds nuw i8, ptr %68, i64 168
  %156 = load { i1, i64, i1 }, ptr %155, align 4
  %.fca.0.extract578.7 = extractvalue { i1, i64, i1 } %156, 0
  br i1 %.fca.0.extract578.7, label %cond_688_case_1.7, label %cond_exit_665.7

cond_688_case_1.7:                                ; preds = %__barray_mask_borrow.exit909.7
  %.fca.1.extract579.7 = extractvalue { i1, i64, i1 } %156, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.7)
  br label %cond_exit_665.7

cond_exit_665.7:                                  ; preds = %cond_688_case_1.7, %__barray_mask_borrow.exit909.7, %cond_exit_665.6
  %157 = load i64, ptr %69, align 4
  %158 = and i64 %157, 256
  %.not1032 = icmp eq i64 %158, 0
  br i1 %.not1032, label %__barray_mask_borrow.exit909.8, label %cond_exit_665.8

__barray_mask_borrow.exit909.8:                   ; preds = %cond_exit_665.7
  %159 = or disjoint i64 %157, 256
  store i64 %159, ptr %69, align 4
  %160 = getelementptr inbounds nuw i8, ptr %68, i64 192
  %161 = load { i1, i64, i1 }, ptr %160, align 4
  %.fca.0.extract578.8 = extractvalue { i1, i64, i1 } %161, 0
  br i1 %.fca.0.extract578.8, label %cond_688_case_1.8, label %cond_exit_665.8

cond_688_case_1.8:                                ; preds = %__barray_mask_borrow.exit909.8
  %.fca.1.extract579.8 = extractvalue { i1, i64, i1 } %161, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.8)
  br label %cond_exit_665.8

cond_exit_665.8:                                  ; preds = %cond_688_case_1.8, %__barray_mask_borrow.exit909.8, %cond_exit_665.7
  %162 = load i64, ptr %69, align 4
  %163 = and i64 %162, 512
  %.not1033 = icmp eq i64 %163, 0
  br i1 %.not1033, label %__barray_mask_borrow.exit909.9, label %cond_exit_665.9

__barray_mask_borrow.exit909.9:                   ; preds = %cond_exit_665.8
  %164 = or disjoint i64 %162, 512
  store i64 %164, ptr %69, align 4
  %165 = getelementptr inbounds nuw i8, ptr %68, i64 216
  %166 = load { i1, i64, i1 }, ptr %165, align 4
  %.fca.0.extract578.9 = extractvalue { i1, i64, i1 } %166, 0
  br i1 %.fca.0.extract578.9, label %cond_688_case_1.9, label %cond_exit_665.9

cond_688_case_1.9:                                ; preds = %__barray_mask_borrow.exit909.9
  %.fca.1.extract579.9 = extractvalue { i1, i64, i1 } %166, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579.9)
  br label %cond_exit_665.9

cond_exit_665.9:                                  ; preds = %cond_688_case_1.9, %__barray_mask_borrow.exit909.9, %cond_exit_665.8
  %167 = load i64, ptr %69, align 4
  %168 = or i64 %167, -1024
  store i64 %168, ptr %69, align 4
  %169 = icmp eq i64 %168, -1
  br i1 %169, label %loop_out147, label %mask_block_err.i902

loop_out147:                                      ; preds = %cond_exit_665.9
  tail call void @heap_free(ptr nonnull %68)
  tail call void @heap_free(ptr nonnull %69)
  %170 = load i64, ptr %54, align 4
  %171 = and i64 %170, 1023
  store i64 %171, ptr %54, align 4
  %172 = icmp eq i64 %171, 0
  br i1 %172, label %__barray_check_none_borrowed.exit915, label %mask_block_err.i913

__barray_check_none_borrowed.exit915:             ; preds = %loop_out147
  %173 = tail call ptr @heap_alloc(i64 10)
  %174 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %174, align 1
  %175 = load { i1, i64, i1 }, ptr %53, align 4
  %176 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %175)
  %177 = extractvalue { i1 } %176, 0
  store i1 %177, ptr %173, align 1
  %178 = getelementptr inbounds nuw i8, ptr %53, i64 24
  %179 = load { i1, i64, i1 }, ptr %178, align 4
  %180 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %179)
  %181 = getelementptr inbounds nuw i8, ptr %173, i64 1
  %182 = extractvalue { i1 } %180, 0
  store i1 %182, ptr %181, align 1
  %183 = getelementptr inbounds nuw i8, ptr %53, i64 48
  %184 = load { i1, i64, i1 }, ptr %183, align 4
  %185 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %184)
  %186 = getelementptr inbounds nuw i8, ptr %173, i64 2
  %187 = extractvalue { i1 } %185, 0
  store i1 %187, ptr %186, align 1
  %188 = getelementptr inbounds nuw i8, ptr %53, i64 72
  %189 = load { i1, i64, i1 }, ptr %188, align 4
  %190 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %189)
  %191 = getelementptr inbounds nuw i8, ptr %173, i64 3
  %192 = extractvalue { i1 } %190, 0
  store i1 %192, ptr %191, align 1
  %193 = getelementptr inbounds nuw i8, ptr %53, i64 96
  %194 = load { i1, i64, i1 }, ptr %193, align 4
  %195 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %194)
  %196 = getelementptr inbounds nuw i8, ptr %173, i64 4
  %197 = extractvalue { i1 } %195, 0
  store i1 %197, ptr %196, align 1
  %198 = getelementptr inbounds nuw i8, ptr %53, i64 120
  %199 = load { i1, i64, i1 }, ptr %198, align 4
  %200 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %199)
  %201 = getelementptr inbounds nuw i8, ptr %173, i64 5
  %202 = extractvalue { i1 } %200, 0
  store i1 %202, ptr %201, align 1
  %203 = getelementptr inbounds nuw i8, ptr %53, i64 144
  %204 = load { i1, i64, i1 }, ptr %203, align 4
  %205 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %204)
  %206 = getelementptr inbounds nuw i8, ptr %173, i64 6
  %207 = extractvalue { i1 } %205, 0
  store i1 %207, ptr %206, align 1
  %208 = getelementptr inbounds nuw i8, ptr %53, i64 168
  %209 = load { i1, i64, i1 }, ptr %208, align 4
  %210 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %209)
  %211 = getelementptr inbounds nuw i8, ptr %173, i64 7
  %212 = extractvalue { i1 } %210, 0
  store i1 %212, ptr %211, align 1
  %213 = getelementptr inbounds nuw i8, ptr %53, i64 192
  %214 = load { i1, i64, i1 }, ptr %213, align 4
  %215 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %214)
  %216 = getelementptr inbounds nuw i8, ptr %173, i64 8
  %217 = extractvalue { i1 } %215, 0
  store i1 %217, ptr %216, align 1
  %218 = getelementptr inbounds nuw i8, ptr %53, i64 216
  %219 = load { i1, i64, i1 }, ptr %218, align 4
  %220 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %219)
  %221 = getelementptr inbounds nuw i8, ptr %173, i64 9
  %222 = extractvalue { i1 } %220, 0
  store i1 %222, ptr %221, align 1
  tail call void @heap_free(ptr nonnull %53)
  tail call void @heap_free(ptr nonnull %54)
  %223 = load i64, ptr %174, align 4
  %224 = and i64 %223, 1023
  store i64 %224, ptr %174, align 4
  %225 = icmp eq i64 %224, 0
  br i1 %225, label %__barray_check_none_borrowed.exit921, label %mask_block_err.i919

mask_block_err.i913:                              ; preds = %loop_out147
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_688_case_1:                                  ; preds = %__barray_mask_borrow.exit909
  %.fca.1.extract579 = extractvalue { i1, i64, i1 } %121, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579)
  br label %cond_exit_665

__barray_check_none_borrowed.exit921:             ; preds = %__barray_check_none_borrowed.exit915
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %226 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %226, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %173, ptr %arr_ptr, align 8
  store ptr %226, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  br label %pow.i.preheader

mask_block_err.i919:                              ; preds = %__barray_check_none_borrowed.exit915
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

pow.i.preheader:                                  ; preds = %cond_exit_91, %__barray_check_none_borrowed.exit921
  %"86_0.sroa.0.01000" = phi i64 [ 0, %__barray_check_none_borrowed.exit921 ], [ %227, %cond_exit_91 ]
  %227 = add nuw nsw i64 %"86_0.sroa.0.01000", 1
  br label %pow.i

pow.i:                                            ; preds = %pow.i.preheader, %pow_body.i
  %storemerge71.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %pow.i.preheader ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"86_0.sroa.0.01000", %pow.i.preheader ]
  switch i64 %storemerge.i, label %pow_body.i [
    i64 1, label %__hugr__.guppylang.std.num.int.__pow__.349.exit.loopexit
    i64 0, label %__barray_check_bounds.exit929
  ]

pow_body.i:                                       ; preds = %pow.i
  %new_acc.i = shl i64 %storemerge71.i, 1
  %new_exp.i = add i64 %storemerge.i, -1
  br label %pow.i

__hugr__.guppylang.std.num.int.__pow__.349.exit.loopexit: ; preds = %pow.i
  %228 = sitofp i64 %storemerge71.i to double
  br label %__barray_check_bounds.exit929

__barray_check_bounds.exit929:                    ; preds = %pow.i, %__hugr__.guppylang.std.num.int.__pow__.349.exit.loopexit
  %storemerge73.i = phi double [ %228, %__hugr__.guppylang.std.num.int.__pow__.349.exit.loopexit ], [ 1.000000e+00, %pow.i ]
  %229 = load i64, ptr %282, align 4
  %230 = lshr i64 %229, %"86_0.sroa.0.01000"
  %231 = trunc i64 %230 to i1
  br i1 %231, label %cond_exit_91, label %panic.i930

panic.i930:                                       ; preds = %__barray_check_bounds.exit929
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_91:                                     ; preds = %__barray_check_bounds.exit929
  %232 = fdiv double 1.000000e+00, %storemerge73.i
  %233 = shl nuw nsw i64 1, %"86_0.sroa.0.01000"
  %234 = xor i64 %229, %233
  store i64 %234, ptr %282, align 4
  %235 = getelementptr inbounds nuw double, ptr %281, i64 %"86_0.sroa.0.01000"
  store double %232, ptr %235, align 8
  %exitcond1009.not = icmp eq i64 %227, 10
  br i1 %exitcond1009.not, label %loop_out217, label %pow.i.preheader

loop_out217:                                      ; preds = %cond_exit_91
  %236 = load i64, ptr %282, align 4
  %237 = and i64 %236, 1023
  store i64 %237, ptr %282, align 4
  %238 = icmp eq i64 %237, 0
  br i1 %238, label %__barray_check_none_borrowed.exit937, label %mask_block_err.i935

__barray_check_none_borrowed.exit937:             ; preds = %loop_out217
  %239 = call ptr @heap_alloc(i64 80)
  %240 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %240, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(80) %239, ptr noundef nonnull align 1 dereferenceable(80) %281, i64 80, i1 false)
  call void @heap_free(ptr nonnull %239)
  %241 = load i64, ptr %282, align 4
  %242 = and i64 %241, 1023
  store i64 %242, ptr %282, align 4
  %243 = icmp eq i64 %242, 0
  br i1 %243, label %__barray_check_none_borrowed.exit943, label %mask_block_err.i941

mask_block_err.i935:                              ; preds = %loop_out217
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit943:             ; preds = %__barray_check_none_borrowed.exit937
  %out_arr_alloca297 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr299 = getelementptr inbounds nuw i8, ptr %out_arr_alloca297, i64 4
  %arr_ptr300 = getelementptr inbounds nuw i8, ptr %out_arr_alloca297, i64 8
  %mask_ptr301 = getelementptr inbounds nuw i8, ptr %out_arr_alloca297, i64 16
  %244 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %244, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca297, align 8
  store i32 1, ptr %y_ptr299, align 4
  store ptr %281, ptr %arr_ptr300, align 8
  store ptr %244, ptr %mask_ptr301, align 8
  call void @print_float_arr(ptr nonnull @res_floats.8646C2EF.0, i64 20, ptr nonnull %out_arr_alloca297)
  br label %__barray_check_bounds.exit951

mask_block_err.i941:                              ; preds = %__barray_check_none_borrowed.exit937
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit951:                    ; preds = %cond_exit_133.1, %__barray_check_none_borrowed.exit943
  %"128_0.sroa.0.01002" = phi i64 [ 0, %__barray_check_none_borrowed.exit943 ], [ %261, %cond_exit_133.1 ]
  %245 = lshr i64 %"128_0.sroa.0.01002", 6
  %246 = getelementptr inbounds nuw i64, ptr %280, i64 %245
  %247 = load i64, ptr %246, align 4
  %248 = and i64 %"128_0.sroa.0.01002", 62
  %249 = lshr i64 %247, %248
  %250 = trunc i64 %249 to i1
  br i1 %250, label %cond_exit_133, label %panic.i952

panic.i952:                                       ; preds = %cond_exit_133, %__barray_check_bounds.exit951
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_133:                                    ; preds = %__barray_check_bounds.exit951
  %251 = or disjoint i64 %"128_0.sroa.0.01002", 1
  %252 = shl nuw nsw i64 1, %248
  %253 = xor i64 %247, %252
  store i64 %253, ptr %246, align 4
  %254 = getelementptr inbounds nuw i64, ptr %279, i64 %"128_0.sroa.0.01002"
  store i64 %"128_0.sroa.0.01002", ptr %254, align 4
  %255 = lshr i64 %"128_0.sroa.0.01002", 6
  %256 = getelementptr inbounds nuw i64, ptr %280, i64 %255
  %257 = load i64, ptr %256, align 4
  %258 = and i64 %251, 63
  %259 = lshr i64 %257, %258
  %260 = trunc i64 %259 to i1
  br i1 %260, label %cond_exit_133.1, label %panic.i952

cond_exit_133.1:                                  ; preds = %cond_exit_133
  %261 = add nuw nsw i64 %"128_0.sroa.0.01002", 2
  %262 = shl nuw i64 1, %258
  %263 = xor i64 %257, %262
  store i64 %263, ptr %256, align 4
  %264 = getelementptr inbounds nuw i64, ptr %279, i64 %251
  store i64 %251, ptr %264, align 4
  %exitcond1010.not.1 = icmp eq i64 %261, 100
  br i1 %exitcond1010.not.1, label %loop_out305, label %__barray_check_bounds.exit951

loop_out305:                                      ; preds = %cond_exit_133.1
  %265 = getelementptr i8, ptr %280, i64 8
  %266 = load i64, ptr %265, align 4
  %267 = and i64 %266, 68719476735
  store i64 %267, ptr %265, align 4
  %268 = load i64, ptr %280, align 4
  %269 = icmp eq i64 %268, 0
  %270 = icmp eq i64 %267, 0
  %or.cond = select i1 %269, i1 %270, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit959, label %mask_block_err.i957

__barray_check_none_borrowed.exit959:             ; preds = %loop_out305
  %271 = call ptr @heap_alloc(i64 800)
  %272 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %272, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %271, ptr noundef nonnull align 1 dereferenceable(800) %279, i64 800, i1 false)
  call void @heap_free(ptr nonnull %271)
  %273 = load i64, ptr %265, align 4
  %274 = and i64 %273, 68719476735
  store i64 %274, ptr %265, align 4
  %275 = load i64, ptr %280, align 4
  %276 = icmp eq i64 %275, 0
  %277 = icmp eq i64 %274, 0
  %or.cond1013 = select i1 %276, i1 %277, i1 false
  br i1 %or.cond1013, label %__barray_check_none_borrowed.exit965, label %mask_block_err.i963

mask_block_err.i957:                              ; preds = %loop_out305
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit965:             ; preds = %__barray_check_none_borrowed.exit959
  %out_arr_alloca381 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr383 = getelementptr inbounds nuw i8, ptr %out_arr_alloca381, i64 4
  %arr_ptr384 = getelementptr inbounds nuw i8, ptr %out_arr_alloca381, i64 8
  %mask_ptr385 = getelementptr inbounds nuw i8, ptr %out_arr_alloca381, i64 16
  %278 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %278, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca381, align 8
  store i32 1, ptr %y_ptr383, align 4
  store ptr %279, ptr %arr_ptr384, align 8
  store ptr %278, ptr %mask_ptr385, align 8
  call void @print_int_arr(ptr nonnull @res_ints.B3BC9D53.0, i64 16, ptr nonnull %out_arr_alloca381)
  ret void

mask_block_err.i963:                              ; preds = %__barray_check_none_borrowed.exit959
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_163:                                    ; preds = %__barray_mask_return.exit892
  %279 = tail call ptr @heap_alloc(i64 800)
  %280 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %280, i8 -1, i64 16, i1 false)
  %281 = tail call ptr @heap_alloc(i64 80)
  %282 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %282, align 1
  %283 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"116.fca.2.insert", 0
  %284 = tail call ptr @heap_alloc(i64 240)
  %285 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %285, align 1
  br label %__barray_check_bounds.exit.i.i

286:                                              ; preds = %loop_body.i
  %287 = lshr i64 %.fca.2.extract82.i.i, 6
  %288 = getelementptr i64, ptr %.fca.1.extract81.i.i, i64 %287
  %289 = load i64, ptr %288, align 4
  %290 = and i64 %.fca.2.extract82.i.i, 63
  %291 = sub nuw nsw i64 64, %290
  %292 = lshr i64 -1, %291
  %293 = icmp eq i64 %290, 0
  %294 = select i1 %293, i64 0, i64 %292
  %295 = or i64 %289, %294
  store i64 %295, ptr %288, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract82.i.i, 9
  %296 = lshr i64 %last_valid.i.i.i, 6
  %297 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i.i, i64 %296
  %298 = load i64, ptr %297, align 4
  %299 = and i64 %last_valid.i.i.i, 63
  %300 = shl nsw i64 -2, %299
  %301 = icmp eq i64 %299, 63
  %302 = select i1 %301, i64 0, i64 %300
  %303 = or i64 %298, %302
  store i64 %303, ptr %297, align 4
  %reass.sub.i.i.i = sub nsw i64 %296, %287
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit", label %mask_block_ok.i.i.i

304:                                              ; preds = %mask_block_ok.i.i.i
  %305 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %286, %304
  %.02.i.i.i = phi i64 [ %305, %304 ], [ 0, %286 ]
  %gep.i.i.i = getelementptr i64, ptr %288, i64 %.02.i.i.i
  %306 = load i64, ptr %gep.i.i.i, align 4
  %307 = icmp eq i64 %306, -1
  br i1 %307, label %304, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_163
  %.fca.2.extract82.i187.i = phi i64 [ 0, %cond_exit_163 ], [ %.fca.2.extract82.i.i, %loop_body.i ]
  %.fca.1.extract81.i186.i = phi ptr [ %1, %cond_exit_163 ], [ %.fca.1.extract81.i.i, %loop_body.i ]
  %.fca.0.extract80.i185.i = phi ptr [ %0, %cond_exit_163 ], [ %.fca.0.extract80.i.i, %loop_body.i ]
  %"515_0.sroa.15.0184.i" = phi i64 [ 0, %cond_exit_163 ], [ %308, %loop_body.i ]
  %.pn165183.i = phi { { ptr, ptr, i64 }, i64 } [ %283, %cond_exit_163 ], [ %323, %loop_body.i ]
  %308 = add nuw nsw i64 %"515_0.sroa.15.0184.i", 1
  %309 = add i64 %"515_0.sroa.15.0184.i", %.fca.2.extract82.i187.i
  %310 = lshr i64 %309, 6
  %311 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i186.i, i64 %310
  %312 = load i64, ptr %311, align 4
  %313 = and i64 %309, 63
  %314 = lshr i64 %312, %313
  %315 = trunc i64 %314 to i1
  br i1 %315, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %316 = shl nuw i64 1, %313
  %317 = xor i64 %316, %312
  store i64 %317, ptr %311, align 4
  %318 = getelementptr inbounds i64, ptr %.fca.0.extract80.i185.i, i64 %309
  %319 = load i64, ptr %318, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %319)
  tail call void @___qfree(i64 %319)
  %320 = load i64, ptr %285, align 4
  %321 = lshr i64 %320, %"515_0.sroa.15.0184.i"
  %322 = trunc i64 %321 to i1
  br i1 %322, label %loop_body.i, label %panic.i.i966

panic.i.i966:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"580_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"580_054.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"580_054.fca.1.insert.i", i1 undef, 2
  %323 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, i64 %308, 1
  %324 = shl nuw nsw i64 1, %"515_0.sroa.15.0184.i"
  %325 = xor i64 %320, %324
  store i64 %325, ptr %285, align 4
  %326 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %284, i64 %"515_0.sroa.15.0184.i"
  store { i1, i64, i1 } %"580_054.fca.2.insert.i", ptr %326, align 4
  %327 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %327, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %327, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %327, 2
  %exitcond.not.i967 = icmp eq i64 %308, 10
  br i1 %exitcond.not.i967, label %286, label %__barray_check_bounds.exit.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit": ; preds = %304, %286
  tail call void @heap_free(ptr %.fca.0.extract80.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract81.i.i)
  %328 = tail call ptr @heap_alloc(i64 320)
  %329 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %329, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(320) %328, i8 0, i64 320, i1 false)
  %330 = load i64, ptr %285, align 4
  %331 = and i64 %330, 1023
  store i64 %331, ptr %285, align 4
  %332 = icmp eq i64 %331, 0
  br i1 %332, label %__barray_check_none_borrowed.exit, label %mask_block_err.i
}

declare ptr @heap_alloc(i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: noreturn
declare void @panic(i32, ptr) local_unnamed_addr #1

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

define internal i1 @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract = extractvalue { i1, i64, i1 } %0, 0
  br i1 %.fca.0.extract, label %cond_456_case_1, label %cond_456_case_0

cond_456_case_0:                                  ; preds = %alloca_block
  %.fca.2.extract = extractvalue { i1, i64, i1 } %0, 2
  br label %cond_exit_456

cond_456_case_1:                                  ; preds = %alloca_block
  %.fca.1.extract = extractvalue { i1, i64, i1 } %0, 1
  %read_bool = tail call i1 @___read_future_bool(i64 %.fca.1.extract)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract)
  br label %cond_exit_456

cond_exit_456:                                    ; preds = %cond_456_case_1, %cond_456_case_0
  %"03.0" = phi i1 [ %read_bool, %cond_456_case_1 ], [ %.fca.2.extract, %cond_456_case_0 ]
  ret i1 %"03.0"
}

declare void @heap_free(ptr) local_unnamed_addr

define internal { i1, i64, i1 } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %0) unnamed_addr {
alloca_block:
  %.fca.0.extract11 = extractvalue { i1, { i1, i64, i1 } } %0, 0
  br i1 %.fca.0.extract11, label %cond_303_case_1, label %cond_303_case_0

cond_303_case_1:                                  ; preds = %alloca_block
  %1 = extractvalue { i1, { i1, i64, i1 } } %0, 1
  ret { i1, i64, i1 } %1

cond_303_case_0:                                  ; preds = %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_Expected v.E6312129.0")
  unreachable
}

declare void @print_bool_arr(ptr, i64, ptr) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @__hugr__.__main__.main.1()
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
