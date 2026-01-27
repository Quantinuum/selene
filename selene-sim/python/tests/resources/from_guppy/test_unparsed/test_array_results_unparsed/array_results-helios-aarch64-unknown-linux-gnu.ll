; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

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
  br i1 %not_max.not.not.i, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit

cond_433_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_qalloc.437.exit:                   ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_qalloc.437.exit.8, %__hugr__.__tk2_qalloc.437.exit.7, %__hugr__.__tk2_qalloc.437.exit.6, %__hugr__.__tk2_qalloc.437.exit.5, %__hugr__.__tk2_qalloc.437.exit.4, %__hugr__.__tk2_qalloc.437.exit.3, %__hugr__.__tk2_qalloc.437.exit.2, %__hugr__.__tk2_qalloc.437.exit.1, %__hugr__.__tk2_qalloc.437.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_qalloc.437.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit.1

__hugr__.__tk2_qalloc.437.exit.1:                 ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not = icmp eq i64 %6, 0
  br i1 %.not, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_qalloc.437.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit.2

__hugr__.__tk2_qalloc.437.exit.2:                 ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not1010 = icmp eq i64 %10, 0
  br i1 %.not1010, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_qalloc.437.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit.3

__hugr__.__tk2_qalloc.437.exit.3:                 ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not1011 = icmp eq i64 %14, 0
  br i1 %.not1011, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_qalloc.437.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit.4

__hugr__.__tk2_qalloc.437.exit.4:                 ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not1012 = icmp eq i64 %18, 0
  br i1 %.not1012, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_qalloc.437.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit.5

__hugr__.__tk2_qalloc.437.exit.5:                 ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not1013 = icmp eq i64 %22, 0
  br i1 %.not1013, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_qalloc.437.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit.6

__hugr__.__tk2_qalloc.437.exit.6:                 ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not1014 = icmp eq i64 %26, 0
  br i1 %.not1014, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_qalloc.437.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit.7

__hugr__.__tk2_qalloc.437.exit.7:                 ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not1015 = icmp eq i64 %30, 0
  br i1 %.not1015, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__hugr__.__tk2_qalloc.437.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_433_case_0.i, label %__hugr__.__tk2_qalloc.437.exit.8

__hugr__.__tk2_qalloc.437.exit.8:                 ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not1016 = icmp eq i64 %34, 0
  br i1 %.not1016, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__hugr__.__tk2_qalloc.437.exit.8
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
  %exitcond.not = icmp eq i64 %41, 10
  br i1 %exitcond.not, label %cond_exit_163, label %__barray_check_bounds.exit887

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
  %56 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %234, i64 %storemerge747996
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
  %58 = load i64, ptr %279, align 4
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
  %62 = getelementptr inbounds nuw { i1, { i1, i64, i1 } }, ptr %278, i64 %storemerge747996
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
  %exitcond1005.not = icmp eq i64 %63, 10
  br i1 %exitcond1005.not, label %mask_block_ok.i893, label %55

mask_block_ok.i893:                               ; preds = %"__hugr__.$__copy_scan$$n(10)$t([Bool]+[Future(Bool)])$n(1).383.exit"
  tail call void @heap_free(ptr nonnull %234)
  tail call void @heap_free(ptr nonnull %235)
  %65 = load i64, ptr %279, align 4
  %66 = and i64 %65, 1023
  store i64 %66, ptr %279, align 4
  %67 = icmp eq i64 %66, 0
  br i1 %67, label %__barray_check_none_borrowed.exit898, label %mask_block_err.i896

__barray_check_none_borrowed.exit898:             ; preds = %mask_block_ok.i893
  %68 = tail call ptr @heap_alloc(i64 240)
  %69 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %69, align 1
  %70 = load { i1, { i1, i64, i1 } }, ptr %278, align 4
  %71 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %70)
  %72 = extractvalue { { i1, i64, i1 } } %71, 0
  store { i1, i64, i1 } %72, ptr %68, align 4
  %73 = getelementptr i8, ptr %278, i64 32
  %74 = load { i1, { i1, i64, i1 } }, ptr %73, align 4
  %75 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %74)
  %76 = getelementptr inbounds nuw i8, ptr %68, i64 24
  %77 = extractvalue { { i1, i64, i1 } } %75, 0
  store { i1, i64, i1 } %77, ptr %76, align 4
  %78 = getelementptr i8, ptr %278, i64 64
  %79 = load { i1, { i1, i64, i1 } }, ptr %78, align 4
  %80 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %79)
  %81 = getelementptr inbounds nuw i8, ptr %68, i64 48
  %82 = extractvalue { { i1, i64, i1 } } %80, 0
  store { i1, i64, i1 } %82, ptr %81, align 4
  %83 = getelementptr i8, ptr %278, i64 96
  %84 = load { i1, { i1, i64, i1 } }, ptr %83, align 4
  %85 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %84)
  %86 = getelementptr inbounds nuw i8, ptr %68, i64 72
  %87 = extractvalue { { i1, i64, i1 } } %85, 0
  store { i1, i64, i1 } %87, ptr %86, align 4
  %88 = getelementptr i8, ptr %278, i64 128
  %89 = load { i1, { i1, i64, i1 } }, ptr %88, align 4
  %90 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %89)
  %91 = getelementptr inbounds nuw i8, ptr %68, i64 96
  %92 = extractvalue { { i1, i64, i1 } } %90, 0
  store { i1, i64, i1 } %92, ptr %91, align 4
  %93 = getelementptr i8, ptr %278, i64 160
  %94 = load { i1, { i1, i64, i1 } }, ptr %93, align 4
  %95 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %94)
  %96 = getelementptr inbounds nuw i8, ptr %68, i64 120
  %97 = extractvalue { { i1, i64, i1 } } %95, 0
  store { i1, i64, i1 } %97, ptr %96, align 4
  %98 = getelementptr i8, ptr %278, i64 192
  %99 = load { i1, { i1, i64, i1 } }, ptr %98, align 4
  %100 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %99)
  %101 = getelementptr inbounds nuw i8, ptr %68, i64 144
  %102 = extractvalue { { i1, i64, i1 } } %100, 0
  store { i1, i64, i1 } %102, ptr %101, align 4
  %103 = getelementptr i8, ptr %278, i64 224
  %104 = load { i1, { i1, i64, i1 } }, ptr %103, align 4
  %105 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %104)
  %106 = getelementptr inbounds nuw i8, ptr %68, i64 168
  %107 = extractvalue { { i1, i64, i1 } } %105, 0
  store { i1, i64, i1 } %107, ptr %106, align 4
  %108 = getelementptr i8, ptr %278, i64 256
  %109 = load { i1, { i1, i64, i1 } }, ptr %108, align 4
  %110 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %109)
  %111 = getelementptr inbounds nuw i8, ptr %68, i64 192
  %112 = extractvalue { { i1, i64, i1 } } %110, 0
  store { i1, i64, i1 } %112, ptr %111, align 4
  %113 = getelementptr i8, ptr %278, i64 288
  %114 = load { i1, { i1, i64, i1 } }, ptr %113, align 4
  %115 = tail call { { i1, i64, i1 } } @"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).299"({ i1, { i1, i64, i1 } } %114)
  %116 = getelementptr inbounds nuw i8, ptr %68, i64 216
  %117 = extractvalue { { i1, i64, i1 } } %115, 0
  store { i1, i64, i1 } %117, ptr %116, align 4
  tail call void @heap_free(ptr nonnull %278)
  tail call void @heap_free(ptr nonnull %279)
  br label %__barray_check_bounds.exit905

mask_block_err.i896:                              ; preds = %mask_block_ok.i893
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_665_case_0:                                  ; preds = %cond_exit_665
  %118 = load i64, ptr %69, align 4
  %119 = or i64 %118, -1024
  store i64 %119, ptr %69, align 4
  %120 = icmp eq i64 %119, -1
  br i1 %120, label %loop_out147, label %mask_block_err.i902

mask_block_err.i902:                              ; preds = %cond_665_case_0
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit905:                    ; preds = %__barray_check_none_borrowed.exit898, %cond_exit_665
  %"662_0.01022" = phi i64 [ 0, %__barray_check_none_borrowed.exit898 ], [ %121, %cond_exit_665 ]
  %121 = add nuw nsw i64 %"662_0.01022", 1
  %122 = load i64, ptr %69, align 4
  %123 = lshr i64 %122, %"662_0.01022"
  %124 = trunc i64 %123 to i1
  br i1 %124, label %cond_exit_665, label %__barray_mask_borrow.exit909

__barray_mask_borrow.exit909:                     ; preds = %__barray_check_bounds.exit905
  %125 = shl nuw nsw i64 1, %"662_0.01022"
  %126 = xor i64 %122, %125
  store i64 %126, ptr %69, align 4
  %127 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %68, i64 %"662_0.01022"
  %128 = load { i1, i64, i1 }, ptr %127, align 4
  %.fca.0.extract578 = extractvalue { i1, i64, i1 } %128, 0
  br i1 %.fca.0.extract578, label %cond_688_case_1, label %cond_exit_665

cond_exit_665:                                    ; preds = %cond_688_case_1, %__barray_mask_borrow.exit909, %__barray_check_bounds.exit905
  %129 = icmp samesign ugt i64 %"662_0.01022", 8
  br i1 %129, label %cond_665_case_0, label %__barray_check_bounds.exit905

loop_out147:                                      ; preds = %cond_665_case_0
  tail call void @heap_free(ptr nonnull %68)
  tail call void @heap_free(ptr nonnull %69)
  %130 = load i64, ptr %54, align 4
  %131 = and i64 %130, 1023
  store i64 %131, ptr %54, align 4
  %132 = icmp eq i64 %131, 0
  br i1 %132, label %__barray_check_none_borrowed.exit915, label %mask_block_err.i913

__barray_check_none_borrowed.exit915:             ; preds = %loop_out147
  %133 = tail call ptr @heap_alloc(i64 10)
  %134 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %134, align 1
  %135 = load { i1, i64, i1 }, ptr %53, align 4
  %136 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %135)
  %137 = extractvalue { i1 } %136, 0
  store i1 %137, ptr %133, align 1
  %138 = getelementptr inbounds nuw i8, ptr %53, i64 24
  %139 = load { i1, i64, i1 }, ptr %138, align 4
  %140 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %139)
  %141 = getelementptr inbounds nuw i8, ptr %133, i64 1
  %142 = extractvalue { i1 } %140, 0
  store i1 %142, ptr %141, align 1
  %143 = getelementptr inbounds nuw i8, ptr %53, i64 48
  %144 = load { i1, i64, i1 }, ptr %143, align 4
  %145 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %144)
  %146 = getelementptr inbounds nuw i8, ptr %133, i64 2
  %147 = extractvalue { i1 } %145, 0
  store i1 %147, ptr %146, align 1
  %148 = getelementptr inbounds nuw i8, ptr %53, i64 72
  %149 = load { i1, i64, i1 }, ptr %148, align 4
  %150 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %149)
  %151 = getelementptr inbounds nuw i8, ptr %133, i64 3
  %152 = extractvalue { i1 } %150, 0
  store i1 %152, ptr %151, align 1
  %153 = getelementptr inbounds nuw i8, ptr %53, i64 96
  %154 = load { i1, i64, i1 }, ptr %153, align 4
  %155 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %154)
  %156 = getelementptr inbounds nuw i8, ptr %133, i64 4
  %157 = extractvalue { i1 } %155, 0
  store i1 %157, ptr %156, align 1
  %158 = getelementptr inbounds nuw i8, ptr %53, i64 120
  %159 = load { i1, i64, i1 }, ptr %158, align 4
  %160 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %159)
  %161 = getelementptr inbounds nuw i8, ptr %133, i64 5
  %162 = extractvalue { i1 } %160, 0
  store i1 %162, ptr %161, align 1
  %163 = getelementptr inbounds nuw i8, ptr %53, i64 144
  %164 = load { i1, i64, i1 }, ptr %163, align 4
  %165 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %164)
  %166 = getelementptr inbounds nuw i8, ptr %133, i64 6
  %167 = extractvalue { i1 } %165, 0
  store i1 %167, ptr %166, align 1
  %168 = getelementptr inbounds nuw i8, ptr %53, i64 168
  %169 = load { i1, i64, i1 }, ptr %168, align 4
  %170 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %169)
  %171 = getelementptr inbounds nuw i8, ptr %133, i64 7
  %172 = extractvalue { i1 } %170, 0
  store i1 %172, ptr %171, align 1
  %173 = getelementptr inbounds nuw i8, ptr %53, i64 192
  %174 = load { i1, i64, i1 }, ptr %173, align 4
  %175 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %174)
  %176 = getelementptr inbounds nuw i8, ptr %133, i64 8
  %177 = extractvalue { i1 } %175, 0
  store i1 %177, ptr %176, align 1
  %178 = getelementptr inbounds nuw i8, ptr %53, i64 216
  %179 = load { i1, i64, i1 }, ptr %178, align 4
  %180 = tail call { i1 } @__hugr__.array.__read_bool.3.345({ i1, i64, i1 } %179)
  %181 = getelementptr inbounds nuw i8, ptr %133, i64 9
  %182 = extractvalue { i1 } %180, 0
  store i1 %182, ptr %181, align 1
  tail call void @heap_free(ptr nonnull %53)
  tail call void @heap_free(ptr nonnull %54)
  %183 = load i64, ptr %134, align 4
  %184 = and i64 %183, 1023
  store i64 %184, ptr %134, align 4
  %185 = icmp eq i64 %184, 0
  br i1 %185, label %__barray_check_none_borrowed.exit921, label %mask_block_err.i919

mask_block_err.i913:                              ; preds = %loop_out147
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_688_case_1:                                  ; preds = %__barray_mask_borrow.exit909
  %.fca.1.extract579 = extractvalue { i1, i64, i1 } %128, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract579)
  br label %cond_exit_665

__barray_check_none_borrowed.exit921:             ; preds = %__barray_check_none_borrowed.exit915
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %186 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %186, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %133, ptr %arr_ptr, align 8
  store ptr %186, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  br label %pow.i.preheader

mask_block_err.i919:                              ; preds = %__barray_check_none_borrowed.exit915
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

pow.i.preheader:                                  ; preds = %cond_exit_91, %__barray_check_none_borrowed.exit921
  %"86_0.sroa.0.01000" = phi i64 [ 0, %__barray_check_none_borrowed.exit921 ], [ %187, %cond_exit_91 ]
  %187 = add nuw nsw i64 %"86_0.sroa.0.01000", 1
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
  %188 = sitofp i64 %storemerge71.i to double
  br label %__barray_check_bounds.exit929

__barray_check_bounds.exit929:                    ; preds = %pow.i, %__hugr__.guppylang.std.num.int.__pow__.349.exit.loopexit
  %storemerge73.i = phi double [ %188, %__hugr__.guppylang.std.num.int.__pow__.349.exit.loopexit ], [ 1.000000e+00, %pow.i ]
  %189 = load i64, ptr %232, align 4
  %190 = lshr i64 %189, %"86_0.sroa.0.01000"
  %191 = trunc i64 %190 to i1
  br i1 %191, label %cond_exit_91, label %panic.i930

panic.i930:                                       ; preds = %__barray_check_bounds.exit929
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_91:                                     ; preds = %__barray_check_bounds.exit929
  %192 = fdiv double 1.000000e+00, %storemerge73.i
  %193 = shl nuw nsw i64 1, %"86_0.sroa.0.01000"
  %194 = xor i64 %189, %193
  store i64 %194, ptr %232, align 4
  %195 = getelementptr inbounds nuw double, ptr %231, i64 %"86_0.sroa.0.01000"
  store double %192, ptr %195, align 8
  %exitcond1008.not = icmp eq i64 %187, 10
  br i1 %exitcond1008.not, label %loop_out217, label %pow.i.preheader

loop_out217:                                      ; preds = %cond_exit_91
  %196 = load i64, ptr %232, align 4
  %197 = and i64 %196, 1023
  store i64 %197, ptr %232, align 4
  %198 = icmp eq i64 %197, 0
  br i1 %198, label %__barray_check_none_borrowed.exit937, label %mask_block_err.i935

__barray_check_none_borrowed.exit937:             ; preds = %loop_out217
  %199 = call ptr @heap_alloc(i64 80)
  %200 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %200, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(80) %199, ptr noundef nonnull align 1 dereferenceable(80) %231, i64 80, i1 false)
  call void @heap_free(ptr nonnull %199)
  %201 = load i64, ptr %232, align 4
  %202 = and i64 %201, 1023
  store i64 %202, ptr %232, align 4
  %203 = icmp eq i64 %202, 0
  br i1 %203, label %__barray_check_none_borrowed.exit943, label %mask_block_err.i941

mask_block_err.i935:                              ; preds = %loop_out217
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit943:             ; preds = %__barray_check_none_borrowed.exit937
  %out_arr_alloca297 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr299 = getelementptr inbounds nuw i8, ptr %out_arr_alloca297, i64 4
  %arr_ptr300 = getelementptr inbounds nuw i8, ptr %out_arr_alloca297, i64 8
  %mask_ptr301 = getelementptr inbounds nuw i8, ptr %out_arr_alloca297, i64 16
  %204 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %204, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca297, align 8
  store i32 1, ptr %y_ptr299, align 4
  store ptr %231, ptr %arr_ptr300, align 8
  store ptr %204, ptr %mask_ptr301, align 8
  call void @print_float_arr(ptr nonnull @res_floats.8646C2EF.0, i64 20, ptr nonnull %out_arr_alloca297)
  br label %__barray_check_bounds.exit951

mask_block_err.i941:                              ; preds = %__barray_check_none_borrowed.exit937
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit951:                    ; preds = %cond_exit_133, %__barray_check_none_borrowed.exit943
  %"128_0.sroa.0.01002" = phi i64 [ 0, %__barray_check_none_borrowed.exit943 ], [ %211, %cond_exit_133 ]
  %205 = lshr i64 %"128_0.sroa.0.01002", 6
  %206 = getelementptr inbounds nuw i64, ptr %230, i64 %205
  %207 = load i64, ptr %206, align 4
  %208 = and i64 %"128_0.sroa.0.01002", 63
  %209 = lshr i64 %207, %208
  %210 = trunc i64 %209 to i1
  br i1 %210, label %cond_exit_133, label %panic.i952

panic.i952:                                       ; preds = %__barray_check_bounds.exit951
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_133:                                    ; preds = %__barray_check_bounds.exit951
  %211 = add nuw nsw i64 %"128_0.sroa.0.01002", 1
  %212 = shl nuw i64 1, %208
  %213 = xor i64 %207, %212
  store i64 %213, ptr %206, align 4
  %214 = getelementptr inbounds nuw i64, ptr %229, i64 %"128_0.sroa.0.01002"
  store i64 %"128_0.sroa.0.01002", ptr %214, align 4
  %exitcond1009.not = icmp eq i64 %211, 100
  br i1 %exitcond1009.not, label %loop_out305, label %__barray_check_bounds.exit951

loop_out305:                                      ; preds = %cond_exit_133
  %215 = getelementptr i8, ptr %230, i64 8
  %216 = load i64, ptr %215, align 4
  %217 = and i64 %216, 68719476735
  store i64 %217, ptr %215, align 4
  %218 = load i64, ptr %230, align 4
  %219 = icmp eq i64 %218, 0
  %220 = icmp eq i64 %217, 0
  %or.cond = select i1 %219, i1 %220, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit959, label %mask_block_err.i957

__barray_check_none_borrowed.exit959:             ; preds = %loop_out305
  %221 = call ptr @heap_alloc(i64 800)
  %222 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %222, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %221, ptr noundef nonnull align 1 dereferenceable(800) %229, i64 800, i1 false)
  call void @heap_free(ptr nonnull %221)
  %223 = load i64, ptr %215, align 4
  %224 = and i64 %223, 68719476735
  store i64 %224, ptr %215, align 4
  %225 = load i64, ptr %230, align 4
  %226 = icmp eq i64 %225, 0
  %227 = icmp eq i64 %224, 0
  %or.cond1020 = select i1 %226, i1 %227, i1 false
  br i1 %or.cond1020, label %__barray_check_none_borrowed.exit965, label %mask_block_err.i963

mask_block_err.i957:                              ; preds = %loop_out305
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit965:             ; preds = %__barray_check_none_borrowed.exit959
  %out_arr_alloca381 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr383 = getelementptr inbounds nuw i8, ptr %out_arr_alloca381, i64 4
  %arr_ptr384 = getelementptr inbounds nuw i8, ptr %out_arr_alloca381, i64 8
  %mask_ptr385 = getelementptr inbounds nuw i8, ptr %out_arr_alloca381, i64 16
  %228 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %228, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca381, align 8
  store i32 1, ptr %y_ptr383, align 4
  store ptr %229, ptr %arr_ptr384, align 8
  store ptr %228, ptr %mask_ptr385, align 8
  call void @print_int_arr(ptr nonnull @res_ints.B3BC9D53.0, i64 16, ptr nonnull %out_arr_alloca381)
  ret void

mask_block_err.i963:                              ; preds = %__barray_check_none_borrowed.exit959
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_163:                                    ; preds = %__barray_mask_return.exit892
  %229 = tail call ptr @heap_alloc(i64 800)
  %230 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %230, i8 -1, i64 16, i1 false)
  %231 = tail call ptr @heap_alloc(i64 80)
  %232 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %232, align 1
  %233 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"116.fca.2.insert", 0
  %234 = tail call ptr @heap_alloc(i64 240)
  %235 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %235, align 1
  br label %__barray_check_bounds.exit.i.i

236:                                              ; preds = %loop_body.i
  %237 = lshr i64 %.fca.2.extract82.i.i, 6
  %238 = getelementptr i64, ptr %.fca.1.extract81.i.i, i64 %237
  %239 = load i64, ptr %238, align 4
  %240 = and i64 %.fca.2.extract82.i.i, 63
  %241 = sub nuw nsw i64 64, %240
  %242 = lshr i64 -1, %241
  %243 = icmp eq i64 %240, 0
  %244 = select i1 %243, i64 0, i64 %242
  %245 = or i64 %239, %244
  store i64 %245, ptr %238, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract82.i.i, 9
  %246 = lshr i64 %last_valid.i.i.i, 6
  %247 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i.i, i64 %246
  %248 = load i64, ptr %247, align 4
  %249 = and i64 %last_valid.i.i.i, 63
  %250 = shl nsw i64 -2, %249
  %251 = icmp eq i64 %249, 63
  %252 = select i1 %251, i64 0, i64 %250
  %253 = or i64 %248, %252
  store i64 %253, ptr %247, align 4
  %reass.sub.i.i.i = sub nsw i64 %246, %237
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit", label %mask_block_ok.i.i.i

254:                                              ; preds = %mask_block_ok.i.i.i
  %255 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %236, %254
  %.02.i.i.i = phi i64 [ %255, %254 ], [ 0, %236 ]
  %gep.i.i.i = getelementptr i64, ptr %238, i64 %.02.i.i.i
  %256 = load i64, ptr %gep.i.i.i, align 4
  %257 = icmp eq i64 %256, -1
  br i1 %257, label %254, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_163
  %.fca.2.extract82.i187.i = phi i64 [ 0, %cond_exit_163 ], [ %.fca.2.extract82.i.i, %loop_body.i ]
  %.fca.1.extract81.i186.i = phi ptr [ %1, %cond_exit_163 ], [ %.fca.1.extract81.i.i, %loop_body.i ]
  %.fca.0.extract80.i185.i = phi ptr [ %0, %cond_exit_163 ], [ %.fca.0.extract80.i.i, %loop_body.i ]
  %"515_0.sroa.15.0184.i" = phi i64 [ 0, %cond_exit_163 ], [ %258, %loop_body.i ]
  %.pn165183.i = phi { { ptr, ptr, i64 }, i64 } [ %233, %cond_exit_163 ], [ %273, %loop_body.i ]
  %258 = add nuw nsw i64 %"515_0.sroa.15.0184.i", 1
  %259 = add i64 %"515_0.sroa.15.0184.i", %.fca.2.extract82.i187.i
  %260 = lshr i64 %259, 6
  %261 = getelementptr inbounds nuw i64, ptr %.fca.1.extract81.i186.i, i64 %260
  %262 = load i64, ptr %261, align 4
  %263 = and i64 %259, 63
  %264 = lshr i64 %262, %263
  %265 = trunc i64 %264 to i1
  br i1 %265, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %266 = shl nuw i64 1, %263
  %267 = xor i64 %266, %262
  store i64 %267, ptr %261, align 4
  %268 = getelementptr inbounds i64, ptr %.fca.0.extract80.i185.i, i64 %259
  %269 = load i64, ptr %268, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %269)
  tail call void @___qfree(i64 %269)
  %270 = load i64, ptr %235, align 4
  %271 = lshr i64 %270, %"515_0.sroa.15.0184.i"
  %272 = trunc i64 %271 to i1
  br i1 %272, label %loop_body.i, label %panic.i.i966

panic.i.i966:                                     ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %"580_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 undef }, i64 %lazy_measure.i, 1
  %"580_054.fca.2.insert.i" = insertvalue { i1, i64, i1 } %"580_054.fca.1.insert.i", i1 undef, 2
  %273 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, i64 %258, 1
  %274 = shl nuw nsw i64 1, %"515_0.sroa.15.0184.i"
  %275 = xor i64 %270, %274
  store i64 %275, ptr %235, align 4
  %276 = getelementptr inbounds nuw { i1, i64, i1 }, ptr %234, i64 %"515_0.sroa.15.0184.i"
  store { i1, i64, i1 } %"580_054.fca.2.insert.i", ptr %276, align 4
  %277 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn165183.i, 0
  %.fca.0.extract80.i.i = extractvalue { ptr, ptr, i64 } %277, 0
  %.fca.1.extract81.i.i = extractvalue { ptr, ptr, i64 } %277, 1
  %.fca.2.extract82.i.i = extractvalue { ptr, ptr, i64 } %277, 2
  %exitcond.not.i967 = icmp eq i64 %258, 10
  br i1 %exitcond.not.i967, label %236, label %__barray_check_bounds.exit.i.i

"__hugr__.$guppylang.std.quantum.measure_array$$n(10).489.exit": ; preds = %254, %236
  tail call void @heap_free(ptr %.fca.0.extract80.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract81.i.i)
  %278 = tail call ptr @heap_alloc(i64 320)
  %279 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %279, align 1
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(320) %278, i8 0, i64 320, i1 false)
  %280 = load i64, ptr %235, align 4
  %281 = and i64 %280, 1023
  store i64 %281, ptr %235, align 4
  %282 = icmp eq i64 %281, 0
  br i1 %282, label %__barray_check_none_borrowed.exit, label %mask_block_err.i
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
