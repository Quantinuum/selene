; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-darwin"

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
  br i1 %not_max.not.not.i, label %cond_607_case_0.i, label %__barray_check_bounds.exit

cond_607_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
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
  br i1 %not_max.not.not.i.1, label %cond_607_case_0.i, label %__barray_check_bounds.exit.1

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
  br i1 %not_max.not.not.i.2, label %cond_607_case_0.i, label %__barray_check_bounds.exit.2

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not857 = icmp eq i64 %10, 0
  br i1 %.not857, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__barray_check_bounds.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_607_case_0.i, label %__barray_check_bounds.exit.3

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not858 = icmp eq i64 %14, 0
  br i1 %.not858, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__barray_check_bounds.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_607_case_0.i, label %__barray_check_bounds.exit.4

__barray_check_bounds.exit.4:                     ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not859 = icmp eq i64 %18, 0
  br i1 %.not859, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__barray_check_bounds.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_607_case_0.i, label %__barray_check_bounds.exit.5

__barray_check_bounds.exit.5:                     ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not860 = icmp eq i64 %22, 0
  br i1 %.not860, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__barray_check_bounds.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_607_case_0.i, label %__barray_check_bounds.exit.6

__barray_check_bounds.exit.6:                     ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not861 = icmp eq i64 %26, 0
  br i1 %.not861, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__barray_check_bounds.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_607_case_0.i, label %__barray_check_bounds.exit.7

__barray_check_bounds.exit.7:                     ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not862 = icmp eq i64 %30, 0
  br i1 %.not862, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__barray_check_bounds.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_607_case_0.i, label %__barray_check_bounds.exit.8

__barray_check_bounds.exit.8:                     ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not863 = icmp eq i64 %34, 0
  br i1 %.not863, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__barray_check_bounds.exit.8
  %35 = and i64 %33, -257
  store i64 %35, ptr %1, align 4
  %36 = getelementptr inbounds nuw i8, ptr %0, i64 64
  store i64 %qalloc.i.8, ptr %36, align 4
  %qalloc.i.9 = tail call i64 @___qalloc()
  %not_max.not.not.i.9 = icmp eq i64 %qalloc.i.9, -1
  br i1 %not_max.not.not.i.9, label %cond_607_case_0.i, label %__barray_check_bounds.exit.9

__barray_check_bounds.exit.9:                     ; preds = %cond_exit_20.8
  tail call void @___reset(i64 %qalloc.i.9)
  %37 = load i64, ptr %1, align 4
  %38 = and i64 %37, 512
  %.not864 = icmp eq i64 %38, 0
  br i1 %.not864, label %panic.i, label %cond_exit_20.9

cond_exit_20.9:                                   ; preds = %__barray_check_bounds.exit.9
  %39 = and i64 %37, -513
  store i64 %39, ptr %1, align 4
  %40 = getelementptr inbounds nuw i8, ptr %0, i64 72
  store i64 %qalloc.i.9, ptr %40, align 4
  %"116.fca.0.insert" = insertvalue { ptr, ptr, i64 } poison, ptr %0, 0
  %"116.fca.1.insert" = insertvalue { ptr, ptr, i64 } %"116.fca.0.insert", ptr %1, 1
  %"116.fca.2.insert" = insertvalue { ptr, ptr, i64 } %"116.fca.1.insert", i64 0, 2
  br label %__barray_check_bounds.exit751

__barray_check_bounds.exit751:                    ; preds = %__barray_mask_return.exit756, %cond_exit_20.9
  %"47_0.0843" = phi i64 [ 0, %cond_exit_20.9 ], [ %41, %__barray_mask_return.exit756 ]
  %41 = add nuw nsw i64 %"47_0.0843", 1
  %42 = load i64, ptr %1, align 4
  %43 = lshr i64 %42, %"47_0.0843"
  %44 = trunc i64 %43 to i1
  br i1 %44, label %panic.i752, label %__barray_check_bounds.exit754

panic.i752:                                       ; preds = %__barray_check_bounds.exit751
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit754:                    ; preds = %__barray_check_bounds.exit751
  %45 = shl nuw nsw i64 1, %"47_0.0843"
  %46 = xor i64 %42, %45
  store i64 %46, ptr %1, align 4
  %47 = getelementptr inbounds nuw i64, ptr %0, i64 %"47_0.0843"
  %48 = load i64, ptr %47, align 4
  tail call void @___rp(i64 %48, double 0x400921FB54442D18, double 0.000000e+00)
  %49 = load i64, ptr %1, align 4
  %50 = lshr i64 %49, %"47_0.0843"
  %51 = trunc i64 %50 to i1
  br i1 %51, label %__barray_mask_return.exit756, label %panic.i755

panic.i755:                                       ; preds = %__barray_check_bounds.exit754
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit756:                     ; preds = %__barray_check_bounds.exit754
  %52 = xor i64 %49, %45
  store i64 %52, ptr %1, align 4
  store i64 %48, ptr %47, align 4
  %exitcond850.not = icmp eq i64 %41, 10
  br i1 %exitcond850.not, label %cond_exit_161, label %__barray_check_bounds.exit751

pow.i.preheader:                                  ; preds = %cond_exit_89, %__barray_check_none_borrowed.exit819
  %"84_0.sroa.0.0845" = phi i64 [ 0, %__barray_check_none_borrowed.exit819 ], [ %53, %cond_exit_89 ]
  %53 = add nuw nsw i64 %"84_0.sroa.0.0845", 1
  br label %pow.i

pow.i:                                            ; preds = %pow.i.preheader, %pow_body.i
  %storemerge53.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %pow.i.preheader ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"84_0.sroa.0.0845", %pow.i.preheader ]
  switch i64 %storemerge.i, label %pow_body.i [
    i64 1, label %__hugr__.guppylang.std.num.int.__pow__.381.exit.loopexit
    i64 0, label %__barray_check_bounds.exit764
  ]

pow_body.i:                                       ; preds = %pow.i
  %new_acc.i = shl i64 %storemerge53.i, 1
  %new_exp.i = add i64 %storemerge.i, -1
  br label %pow.i

__hugr__.guppylang.std.num.int.__pow__.381.exit.loopexit: ; preds = %pow.i
  %54 = sitofp i64 %storemerge53.i to double
  br label %__barray_check_bounds.exit764

__barray_check_bounds.exit764:                    ; preds = %pow.i, %__hugr__.guppylang.std.num.int.__pow__.381.exit.loopexit
  %storemerge55.i = phi double [ %54, %__hugr__.guppylang.std.num.int.__pow__.381.exit.loopexit ], [ 1.000000e+00, %pow.i ]
  %55 = load i64, ptr %108, align 4
  %56 = lshr i64 %55, %"84_0.sroa.0.0845"
  %57 = trunc i64 %56 to i1
  br i1 %57, label %cond_exit_89, label %panic.i765

panic.i765:                                       ; preds = %__barray_check_bounds.exit764
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_89:                                     ; preds = %__barray_check_bounds.exit764
  %58 = fdiv double 1.000000e+00, %storemerge55.i
  %59 = shl nuw nsw i64 1, %"84_0.sroa.0.0845"
  %60 = xor i64 %55, %59
  store i64 %60, ptr %108, align 4
  %61 = getelementptr inbounds nuw double, ptr %107, i64 %"84_0.sroa.0.0845"
  store double %58, ptr %61, align 8
  %exitcond851.not = icmp eq i64 %53, 10
  br i1 %exitcond851.not, label %loop_out132, label %pow.i.preheader

loop_out132:                                      ; preds = %cond_exit_89
  %62 = load i64, ptr %108, align 4
  %63 = and i64 %62, 1023
  store i64 %63, ptr %108, align 4
  %64 = icmp eq i64 %63, 0
  br i1 %64, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %loop_out132
  %65 = call ptr @heap_alloc(i64 80)
  %66 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %66, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(80) %65, ptr noundef nonnull align 1 dereferenceable(80) %107, i64 80, i1 false)
  call void @heap_free(ptr nonnull %65)
  %67 = load i64, ptr %108, align 4
  %68 = and i64 %67, 1023
  store i64 %68, ptr %108, align 4
  %69 = icmp eq i64 %68, 0
  br i1 %69, label %__barray_check_none_borrowed.exit771, label %mask_block_err.i769

mask_block_err.i:                                 ; preds = %loop_out132
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit771:             ; preds = %__barray_check_none_borrowed.exit
  %out_arr_alloca212 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr214 = getelementptr inbounds nuw i8, ptr %out_arr_alloca212, i64 4
  %arr_ptr215 = getelementptr inbounds nuw i8, ptr %out_arr_alloca212, i64 8
  %mask_ptr216 = getelementptr inbounds nuw i8, ptr %out_arr_alloca212, i64 16
  %70 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %70, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca212, align 8
  store i32 1, ptr %y_ptr214, align 4
  store ptr %107, ptr %arr_ptr215, align 8
  store ptr %70, ptr %mask_ptr216, align 8
  call void @print_float_arr(ptr nonnull @res_floats.8646C2EF.0, i64 20, ptr nonnull %out_arr_alloca212)
  br label %__barray_check_bounds.exit779

mask_block_err.i769:                              ; preds = %__barray_check_none_borrowed.exit
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit779:                    ; preds = %cond_exit_131.1, %__barray_check_none_borrowed.exit771
  %"126_0.sroa.0.0847" = phi i64 [ 0, %__barray_check_none_borrowed.exit771 ], [ %87, %cond_exit_131.1 ]
  %71 = lshr i64 %"126_0.sroa.0.0847", 6
  %72 = getelementptr inbounds nuw i64, ptr %106, i64 %71
  %73 = load i64, ptr %72, align 4
  %74 = and i64 %"126_0.sroa.0.0847", 62
  %75 = lshr i64 %73, %74
  %76 = trunc i64 %75 to i1
  br i1 %76, label %cond_exit_131, label %panic.i780

panic.i780:                                       ; preds = %cond_exit_131, %__barray_check_bounds.exit779
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_131:                                    ; preds = %__barray_check_bounds.exit779
  %77 = or disjoint i64 %"126_0.sroa.0.0847", 1
  %78 = shl nuw nsw i64 1, %74
  %79 = xor i64 %73, %78
  store i64 %79, ptr %72, align 4
  %80 = getelementptr inbounds nuw i64, ptr %105, i64 %"126_0.sroa.0.0847"
  store i64 %"126_0.sroa.0.0847", ptr %80, align 4
  %81 = lshr i64 %"126_0.sroa.0.0847", 6
  %82 = getelementptr inbounds nuw i64, ptr %106, i64 %81
  %83 = load i64, ptr %82, align 4
  %84 = and i64 %77, 63
  %85 = lshr i64 %83, %84
  %86 = trunc i64 %85 to i1
  br i1 %86, label %cond_exit_131.1, label %panic.i780

cond_exit_131.1:                                  ; preds = %cond_exit_131
  %87 = add nuw nsw i64 %"126_0.sroa.0.0847", 2
  %88 = shl nuw i64 1, %84
  %89 = xor i64 %83, %88
  store i64 %89, ptr %82, align 4
  %90 = getelementptr inbounds nuw i64, ptr %105, i64 %77
  store i64 %77, ptr %90, align 4
  %exitcond852.not.1 = icmp eq i64 %87, 100
  br i1 %exitcond852.not.1, label %loop_out220, label %__barray_check_bounds.exit779

loop_out220:                                      ; preds = %cond_exit_131.1
  %91 = getelementptr inbounds nuw i8, ptr %106, i64 8
  %92 = load i64, ptr %91, align 4
  %93 = and i64 %92, 68719476735
  store i64 %93, ptr %91, align 4
  %94 = load i64, ptr %106, align 4
  %95 = icmp eq i64 %94, 0
  %96 = icmp eq i64 %93, 0
  %or.cond = select i1 %95, i1 %96, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit786, label %mask_block_err.i784

__barray_check_none_borrowed.exit786:             ; preds = %loop_out220
  %97 = call ptr @heap_alloc(i64 800)
  %98 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %98, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %97, ptr noundef nonnull align 1 dereferenceable(800) %105, i64 800, i1 false)
  call void @heap_free(ptr nonnull %97)
  %99 = load i64, ptr %91, align 4
  %100 = and i64 %99, 68719476735
  store i64 %100, ptr %91, align 4
  %101 = load i64, ptr %106, align 4
  %102 = icmp eq i64 %101, 0
  %103 = icmp eq i64 %100, 0
  %or.cond854 = select i1 %102, i1 %103, i1 false
  br i1 %or.cond854, label %__barray_check_none_borrowed.exit791, label %mask_block_err.i789

mask_block_err.i784:                              ; preds = %loop_out220
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit791:             ; preds = %__barray_check_none_borrowed.exit786
  %out_arr_alloca296 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr298 = getelementptr inbounds nuw i8, ptr %out_arr_alloca296, i64 4
  %arr_ptr299 = getelementptr inbounds nuw i8, ptr %out_arr_alloca296, i64 8
  %mask_ptr300 = getelementptr inbounds nuw i8, ptr %out_arr_alloca296, i64 16
  %104 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %104, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca296, align 8
  store i32 1, ptr %y_ptr298, align 4
  store ptr %105, ptr %arr_ptr299, align 8
  store ptr %104, ptr %mask_ptr300, align 8
  call void @print_int_arr(ptr nonnull @res_ints.B3BC9D53.0, i64 16, ptr nonnull %out_arr_alloca296)
  ret void

mask_block_err.i789:                              ; preds = %__barray_check_none_borrowed.exit786
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_161:                                    ; preds = %__barray_mask_return.exit756
  %105 = tail call ptr @heap_alloc(i64 800)
  %106 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %106, i8 -1, i64 16, i1 false)
  %107 = tail call ptr @heap_alloc(i64 80)
  %108 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %108, align 1
  %109 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"116.fca.2.insert", 0
  %110 = tail call ptr @heap_alloc(i64 80)
  %111 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %111, align 1
  br label %__barray_check_bounds.exit.i.i

112:                                              ; preds = %loop_body.i
  %113 = lshr i64 %.fca.2.extract.i.i, 6
  %114 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %113
  %115 = load i64, ptr %114, align 4
  %116 = and i64 %.fca.2.extract.i.i, 63
  %117 = sub nuw nsw i64 64, %116
  %118 = lshr i64 -1, %117
  %119 = icmp eq i64 %116, 0
  %120 = select i1 %119, i64 0, i64 %118
  %121 = or i64 %115, %120
  store i64 %121, ptr %114, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %122 = lshr i64 %last_valid.i.i.i, 6
  %123 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %122
  %124 = load i64, ptr %123, align 4
  %125 = and i64 %last_valid.i.i.i, 63
  %126 = shl nsw i64 -2, %125
  %127 = icmp eq i64 %125, 63
  %128 = select i1 %127, i64 0, i64 %126
  %129 = or i64 %124, %128
  store i64 %129, ptr %123, align 4
  %reass.sub.i.i.i = sub nsw i64 %122, %113
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit", label %mask_block_ok.i.i.i

130:                                              ; preds = %mask_block_ok.i.i.i
  %131 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %112, %130
  %.02.i.i.i = phi i64 [ %131, %130 ], [ 0, %112 ]
  %gep.i.i.i = getelementptr i64, ptr %114, i64 %.02.i.i.i
  %132 = load i64, ptr %gep.i.i.i, align 4
  %133 = icmp eq i64 %132, -1
  br i1 %133, label %130, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_161
  %.fca.2.extract.i181.i = phi i64 [ 0, %cond_exit_161 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %cond_exit_161 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %cond_exit_161 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"313_0.sroa.15.0178.i" = phi i64 [ 0, %cond_exit_161 ], [ %134, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %109, %cond_exit_161 ], [ %149, %loop_body.i ]
  %134 = add nuw nsw i64 %"313_0.sroa.15.0178.i", 1
  %135 = add i64 %"313_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %136 = lshr i64 %135, 6
  %137 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %136
  %138 = load i64, ptr %137, align 4
  %139 = and i64 %135, 63
  %140 = lshr i64 %138, %139
  %141 = trunc i64 %140 to i1
  br i1 %141, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %142 = shl nuw i64 1, %139
  %143 = xor i64 %142, %138
  store i64 %143, ptr %137, align 4
  %144 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %135
  %145 = load i64, ptr %144, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %145)
  tail call void @___qfree(i64 %145)
  %146 = load i64, ptr %111, align 4
  %147 = lshr i64 %146, %"313_0.sroa.15.0178.i"
  %148 = trunc i64 %147 to i1
  br i1 %148, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %149 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %134, 1
  %150 = shl nuw nsw i64 1, %"313_0.sroa.15.0178.i"
  %151 = xor i64 %146, %150
  store i64 %151, ptr %111, align 4
  %152 = getelementptr inbounds nuw i64, ptr %110, i64 %"313_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %152, align 4
  %153 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %153, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %153, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %153, 2
  %exitcond.not.i792 = icmp eq i64 %134, 10
  br i1 %exitcond.not.i792, label %112, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.299.exit": ; preds = %130, %112
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %110, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %111, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %154 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %155 = tail call ptr @heap_alloc(i64 10)
  %156 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %156, align 1
  br label %__barray_check_bounds.exit.i.i793

loop_body.preheader.i.i:                          ; preds = %loop_body.i796
  %"627_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %214, 2
  %"627_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %214, 1
  %"627_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %214, 0
  br label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i.i793:                ; preds = %loop_body.i796, %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit"
  %157 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit" ], [ %214, %loop_body.i796 ]
  %"354_0.sroa.15.0168.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit" ], [ %158, %loop_body.i796 ]
  %.pn159167.i = phi { { ptr, ptr, i64 }, i64 } [ %154, %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit" ], [ %210, %loop_body.i796 ]
  %158 = add nuw nsw i64 %"354_0.sroa.15.0168.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %157, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %157, 1
  %159 = add i64 %.fca.2.extract208.i.i, %"354_0.sroa.15.0168.i"
  %160 = lshr i64 %159, 6
  %161 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %160
  %162 = load i64, ptr %161, align 4
  %163 = and i64 %159, 63
  %164 = lshr i64 %162, %163
  %165 = trunc i64 %164 to i1
  br i1 %165, label %panic.i.i.i809, label %__barray_check_bounds.exit221.i.i

panic.i.i.i809:                                   ; preds = %__barray_check_bounds.exit.i.i793
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i793
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %157, 0
  %166 = shl nuw i64 1, %163
  %167 = xor i64 %166, %162
  store i64 %167, ptr %161, align 4
  %168 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %159
  %169 = load i64, ptr %168, align 4
  tail call void @___inc_future_refcount(i64 %169)
  %170 = load i64, ptr %161, align 4
  %171 = lshr i64 %170, %163
  %172 = trunc i64 %171 to i1
  br i1 %172, label %__barray_check_bounds.exit.i794, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_630_case_0.i.i:                              ; preds = %cond_exit_630.thread.i.i
  %173 = lshr i64 %"627_1.sroa.10.0.i.i", 6
  %174 = getelementptr i64, ptr %"627_1.sroa.5.0.i.i", i64 %173
  %175 = load i64, ptr %174, align 4
  %176 = and i64 %"627_1.sroa.10.0.i.i", 63
  %177 = sub nuw nsw i64 64, %176
  %178 = lshr i64 -1, %177
  %179 = icmp eq i64 %176, 0
  %180 = select i1 %179, i64 0, i64 %178
  %181 = or i64 %175, %180
  store i64 %181, ptr %174, align 4
  %last_valid.i.i.i798 = add i64 %"627_1.sroa.10.0.i.i", 9
  %182 = lshr i64 %last_valid.i.i.i798, 6
  %183 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %182
  %184 = load i64, ptr %183, align 4
  %185 = and i64 %last_valid.i.i.i798, 63
  %186 = shl nsw i64 -2, %185
  %187 = icmp eq i64 %185, 63
  %188 = select i1 %187, i64 0, i64 %186
  %189 = or i64 %184, %188
  store i64 %189, ptr %183, align 4
  %reass.sub.i.i.i799 = sub nsw i64 %182, %173
  %.not.i.i.i800 = icmp eq i64 %reass.sub.i.i.i799, -1
  br i1 %.not.i.i.i800, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit", label %mask_block_ok.i.i.i801

190:                                              ; preds = %mask_block_ok.i.i.i801
  %191 = add nuw i64 %.02.i.i.i802, 1
  %exitcond.not.i.i.i805 = icmp eq i64 %.02.i.i.i802, %reass.sub.i.i.i799
  br i1 %exitcond.not.i.i.i805, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit", label %mask_block_ok.i.i.i801

mask_block_ok.i.i.i801:                           ; preds = %cond_630_case_0.i.i, %190
  %.02.i.i.i802 = phi i64 [ %191, %190 ], [ 0, %cond_630_case_0.i.i ]
  %gep.i.i.i803 = getelementptr i64, ptr %174, i64 %.02.i.i.i802
  %192 = load i64, ptr %gep.i.i.i803, align 4
  %193 = icmp eq i64 %192, -1
  br i1 %193, label %190, label %mask_block_err.i.i.i804

mask_block_err.i.i.i804:                          ; preds = %mask_block_ok.i.i.i801
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit224.i.i:                ; preds = %cond_exit_630.thread.i.i, %loop_body.preheader.i.i
  %"627_0.0239.i.i" = phi i64 [ 0, %loop_body.preheader.i.i ], [ %194, %cond_exit_630.thread.i.i ]
  %194 = add nuw nsw i64 %"627_0.0239.i.i", 1
  %195 = add i64 %"627_0.0239.i.i", %"627_1.sroa.10.0.i.i"
  %196 = lshr i64 %195, 6
  %197 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %196
  %198 = load i64, ptr %197, align 4
  %199 = and i64 %195, 63
  %200 = lshr i64 %198, %199
  %201 = trunc i64 %200 to i1
  br i1 %201, label %cond_exit_630.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_mask_borrow.exit228.i.i:                 ; preds = %__barray_check_bounds.exit224.i.i
  %202 = shl nuw i64 1, %199
  %203 = xor i64 %202, %198
  store i64 %203, ptr %197, align 4
  %204 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %195
  %205 = load i64, ptr %204, align 4
  tail call void @___dec_future_refcount(i64 %205)
  br label %cond_exit_630.thread.i.i

cond_exit_630.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %__barray_check_bounds.exit224.i.i
  %exitcond.i.i = icmp eq i64 %194, 10
  br i1 %exitcond.i.i, label %cond_630_case_0.i.i, label %__barray_check_bounds.exit224.i.i

__barray_check_bounds.exit.i794:                  ; preds = %__barray_check_bounds.exit221.i.i
  %206 = xor i64 %170, %166
  store i64 %206, ptr %161, align 4
  store i64 %169, ptr %168, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %169)
  tail call void @___dec_future_refcount(i64 %169)
  %207 = load i64, ptr %156, align 4
  %208 = lshr i64 %207, %"354_0.sroa.15.0168.i"
  %209 = trunc i64 %208 to i1
  br i1 %209, label %loop_body.i796, label %panic.i.i795

panic.i.i795:                                     ; preds = %__barray_check_bounds.exit.i794
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i796:                                   ; preds = %__barray_check_bounds.exit.i794
  %210 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, i64 %158, 1
  %211 = shl nuw nsw i64 1, %"354_0.sroa.15.0168.i"
  %212 = xor i64 %207, %211
  store i64 %212, ptr %156, align 4
  %213 = getelementptr inbounds nuw i1, ptr %155, i64 %"354_0.sroa.15.0168.i"
  store i1 %read_bool.i, ptr %213, align 1
  %214 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, 0
  %exitcond.not.i797 = icmp eq i64 %158, 10
  br i1 %exitcond.not.i797, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i793

"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit": ; preds = %190, %cond_630_case_0.i.i
  tail call void @heap_free(ptr %"627_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"627_1.sroa.5.0.i.i")
  %215 = load i64, ptr %156, align 4
  %216 = and i64 %215, 1023
  store i64 %216, ptr %156, align 4
  %217 = icmp eq i64 %216, 0
  br i1 %217, label %__barray_check_none_borrowed.exit814, label %mask_block_err.i812

__barray_check_none_borrowed.exit814:             ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit"
  %218 = tail call ptr @heap_alloc(i64 10)
  %219 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %219, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %218, ptr noundef nonnull align 1 dereferenceable(10) %155, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %218)
  %220 = load i64, ptr %156, align 4
  %221 = and i64 %220, 1023
  store i64 %221, ptr %156, align 4
  %222 = icmp eq i64 %221, 0
  br i1 %222, label %__barray_check_none_borrowed.exit819, label %mask_block_err.i817

mask_block_err.i812:                              ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit819:             ; preds = %__barray_check_none_borrowed.exit814
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %223 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %223, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %155, ptr %arr_ptr, align 8
  store ptr %223, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  br label %pow.i.preheader

mask_block_err.i817:                              ; preds = %__barray_check_none_borrowed.exit814
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable
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

declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr

declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

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
