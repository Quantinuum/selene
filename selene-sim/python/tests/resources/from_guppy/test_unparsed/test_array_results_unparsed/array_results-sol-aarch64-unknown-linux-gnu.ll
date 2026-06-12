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
  br i1 %not_max.not.not.i, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit

cond_607_case_0.i:                                ; preds = %cond_exit_20.8, %cond_exit_20.7, %cond_exit_20.6, %cond_exit_20.5, %cond_exit_20.4, %cond_exit_20.3, %cond_exit_20.2, %cond_exit_20.1, %cond_exit_20, %alloca_block
  tail call void @panic(i32 1001, ptr nonnull @"e_No more qu.3B2EEBF0.0")
  unreachable

__hugr__.__tk2_sol_qalloc.580.exit:               ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  %2 = load i64, ptr %1, align 4
  %3 = trunc i64 %2 to i1
  br i1 %3, label %cond_exit_20, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.9, %__hugr__.__tk2_sol_qalloc.580.exit.8, %__hugr__.__tk2_sol_qalloc.580.exit.7, %__hugr__.__tk2_sol_qalloc.580.exit.6, %__hugr__.__tk2_sol_qalloc.580.exit.5, %__hugr__.__tk2_sol_qalloc.580.exit.4, %__hugr__.__tk2_sol_qalloc.580.exit.3, %__hugr__.__tk2_sol_qalloc.580.exit.2, %__hugr__.__tk2_sol_qalloc.580.exit.1, %__hugr__.__tk2_sol_qalloc.580.exit
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_20:                                     ; preds = %__hugr__.__tk2_sol_qalloc.580.exit
  %4 = and i64 %2, -2
  store i64 %4, ptr %1, align 4
  store i64 %qalloc.i, ptr %0, align 4
  %qalloc.i.1 = tail call i64 @___qalloc()
  %not_max.not.not.i.1 = icmp eq i64 %qalloc.i.1, -1
  br i1 %not_max.not.not.i.1, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit.1

__hugr__.__tk2_sol_qalloc.580.exit.1:             ; preds = %cond_exit_20
  tail call void @___reset(i64 %qalloc.i.1)
  %5 = load i64, ptr %1, align 4
  %6 = and i64 %5, 2
  %.not = icmp eq i64 %6, 0
  br i1 %.not, label %panic.i, label %cond_exit_20.1

cond_exit_20.1:                                   ; preds = %__hugr__.__tk2_sol_qalloc.580.exit.1
  %7 = and i64 %5, -3
  store i64 %7, ptr %1, align 4
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %qalloc.i.1, ptr %8, align 4
  %qalloc.i.2 = tail call i64 @___qalloc()
  %not_max.not.not.i.2 = icmp eq i64 %qalloc.i.2, -1
  br i1 %not_max.not.not.i.2, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit.2

__hugr__.__tk2_sol_qalloc.580.exit.2:             ; preds = %cond_exit_20.1
  tail call void @___reset(i64 %qalloc.i.2)
  %9 = load i64, ptr %1, align 4
  %10 = and i64 %9, 4
  %.not851 = icmp eq i64 %10, 0
  br i1 %.not851, label %panic.i, label %cond_exit_20.2

cond_exit_20.2:                                   ; preds = %__hugr__.__tk2_sol_qalloc.580.exit.2
  %11 = and i64 %9, -5
  store i64 %11, ptr %1, align 4
  %12 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %qalloc.i.2, ptr %12, align 4
  %qalloc.i.3 = tail call i64 @___qalloc()
  %not_max.not.not.i.3 = icmp eq i64 %qalloc.i.3, -1
  br i1 %not_max.not.not.i.3, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit.3

__hugr__.__tk2_sol_qalloc.580.exit.3:             ; preds = %cond_exit_20.2
  tail call void @___reset(i64 %qalloc.i.3)
  %13 = load i64, ptr %1, align 4
  %14 = and i64 %13, 8
  %.not852 = icmp eq i64 %14, 0
  br i1 %.not852, label %panic.i, label %cond_exit_20.3

cond_exit_20.3:                                   ; preds = %__hugr__.__tk2_sol_qalloc.580.exit.3
  %15 = and i64 %13, -9
  store i64 %15, ptr %1, align 4
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store i64 %qalloc.i.3, ptr %16, align 4
  %qalloc.i.4 = tail call i64 @___qalloc()
  %not_max.not.not.i.4 = icmp eq i64 %qalloc.i.4, -1
  br i1 %not_max.not.not.i.4, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit.4

__hugr__.__tk2_sol_qalloc.580.exit.4:             ; preds = %cond_exit_20.3
  tail call void @___reset(i64 %qalloc.i.4)
  %17 = load i64, ptr %1, align 4
  %18 = and i64 %17, 16
  %.not853 = icmp eq i64 %18, 0
  br i1 %.not853, label %panic.i, label %cond_exit_20.4

cond_exit_20.4:                                   ; preds = %__hugr__.__tk2_sol_qalloc.580.exit.4
  %19 = and i64 %17, -17
  store i64 %19, ptr %1, align 4
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store i64 %qalloc.i.4, ptr %20, align 4
  %qalloc.i.5 = tail call i64 @___qalloc()
  %not_max.not.not.i.5 = icmp eq i64 %qalloc.i.5, -1
  br i1 %not_max.not.not.i.5, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit.5

__hugr__.__tk2_sol_qalloc.580.exit.5:             ; preds = %cond_exit_20.4
  tail call void @___reset(i64 %qalloc.i.5)
  %21 = load i64, ptr %1, align 4
  %22 = and i64 %21, 32
  %.not854 = icmp eq i64 %22, 0
  br i1 %.not854, label %panic.i, label %cond_exit_20.5

cond_exit_20.5:                                   ; preds = %__hugr__.__tk2_sol_qalloc.580.exit.5
  %23 = and i64 %21, -33
  store i64 %23, ptr %1, align 4
  %24 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store i64 %qalloc.i.5, ptr %24, align 4
  %qalloc.i.6 = tail call i64 @___qalloc()
  %not_max.not.not.i.6 = icmp eq i64 %qalloc.i.6, -1
  br i1 %not_max.not.not.i.6, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit.6

__hugr__.__tk2_sol_qalloc.580.exit.6:             ; preds = %cond_exit_20.5
  tail call void @___reset(i64 %qalloc.i.6)
  %25 = load i64, ptr %1, align 4
  %26 = and i64 %25, 64
  %.not855 = icmp eq i64 %26, 0
  br i1 %.not855, label %panic.i, label %cond_exit_20.6

cond_exit_20.6:                                   ; preds = %__hugr__.__tk2_sol_qalloc.580.exit.6
  %27 = and i64 %25, -65
  store i64 %27, ptr %1, align 4
  %28 = getelementptr inbounds nuw i8, ptr %0, i64 48
  store i64 %qalloc.i.6, ptr %28, align 4
  %qalloc.i.7 = tail call i64 @___qalloc()
  %not_max.not.not.i.7 = icmp eq i64 %qalloc.i.7, -1
  br i1 %not_max.not.not.i.7, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit.7

__hugr__.__tk2_sol_qalloc.580.exit.7:             ; preds = %cond_exit_20.6
  tail call void @___reset(i64 %qalloc.i.7)
  %29 = load i64, ptr %1, align 4
  %30 = and i64 %29, 128
  %.not856 = icmp eq i64 %30, 0
  br i1 %.not856, label %panic.i, label %cond_exit_20.7

cond_exit_20.7:                                   ; preds = %__hugr__.__tk2_sol_qalloc.580.exit.7
  %31 = and i64 %29, -129
  store i64 %31, ptr %1, align 4
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 56
  store i64 %qalloc.i.7, ptr %32, align 4
  %qalloc.i.8 = tail call i64 @___qalloc()
  %not_max.not.not.i.8 = icmp eq i64 %qalloc.i.8, -1
  br i1 %not_max.not.not.i.8, label %cond_607_case_0.i, label %__hugr__.__tk2_sol_qalloc.580.exit.8

__hugr__.__tk2_sol_qalloc.580.exit.8:             ; preds = %cond_exit_20.7
  tail call void @___reset(i64 %qalloc.i.8)
  %33 = load i64, ptr %1, align 4
  %34 = and i64 %33, 256
  %.not857 = icmp eq i64 %34, 0
  br i1 %.not857, label %panic.i, label %cond_exit_20.8

cond_exit_20.8:                                   ; preds = %__hugr__.__tk2_sol_qalloc.580.exit.8
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
  %.not858 = icmp eq i64 %38, 0
  br i1 %.not858, label %panic.i, label %cond_exit_20.9

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
  %"47_0.0842" = phi i64 [ 0, %cond_exit_20.9 ], [ %41, %__barray_mask_return.exit756 ]
  %41 = add nuw nsw i64 %"47_0.0842", 1
  %42 = load i64, ptr %1, align 4
  %43 = lshr i64 %42, %"47_0.0842"
  %44 = trunc i64 %43 to i1
  br i1 %44, label %panic.i752, label %__barray_check_bounds.exit754

panic.i752:                                       ; preds = %__barray_check_bounds.exit751
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit754:                    ; preds = %__barray_check_bounds.exit751
  %45 = shl nuw nsw i64 1, %"47_0.0842"
  %46 = xor i64 %42, %45
  store i64 %46, ptr %1, align 4
  %47 = getelementptr inbounds nuw i64, ptr %0, i64 %"47_0.0842"
  %48 = load i64, ptr %47, align 4
  tail call void @___rp(i64 %48, double 0x400921FB54442D18, double 0.000000e+00)
  %49 = load i64, ptr %1, align 4
  %50 = lshr i64 %49, %"47_0.0842"
  %51 = trunc i64 %50 to i1
  br i1 %51, label %__barray_mask_return.exit756, label %panic.i755

panic.i755:                                       ; preds = %__barray_check_bounds.exit754
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

__barray_mask_return.exit756:                     ; preds = %__barray_check_bounds.exit754
  %52 = xor i64 %49, %45
  store i64 %52, ptr %1, align 4
  store i64 %48, ptr %47, align 4
  %exitcond.not = icmp eq i64 %41, 10
  br i1 %exitcond.not, label %cond_exit_161, label %__barray_check_bounds.exit751

pow.i.preheader:                                  ; preds = %cond_exit_89, %__barray_check_none_borrowed.exit818
  %"84_0.sroa.0.0844" = phi i64 [ 0, %__barray_check_none_borrowed.exit818 ], [ %53, %cond_exit_89 ]
  %53 = add nuw nsw i64 %"84_0.sroa.0.0844", 1
  br label %pow.i

pow.i:                                            ; preds = %pow.i.preheader, %pow_body.i
  %storemerge53.i = phi i64 [ %new_acc.i, %pow_body.i ], [ 2, %pow.i.preheader ]
  %storemerge.i = phi i64 [ %new_exp.i, %pow_body.i ], [ %"84_0.sroa.0.0844", %pow.i.preheader ]
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
  %55 = load i64, ptr %98, align 4
  %56 = lshr i64 %55, %"84_0.sroa.0.0844"
  %57 = trunc i64 %56 to i1
  br i1 %57, label %cond_exit_89, label %panic.i765

panic.i765:                                       ; preds = %__barray_check_bounds.exit764
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_89:                                     ; preds = %__barray_check_bounds.exit764
  %58 = fdiv double 1.000000e+00, %storemerge55.i
  %59 = shl nuw nsw i64 1, %"84_0.sroa.0.0844"
  %60 = xor i64 %55, %59
  store i64 %60, ptr %98, align 4
  %61 = getelementptr inbounds nuw double, ptr %97, i64 %"84_0.sroa.0.0844"
  store double %58, ptr %61, align 8
  %exitcond849.not = icmp eq i64 %53, 10
  br i1 %exitcond849.not, label %loop_out132, label %pow.i.preheader

loop_out132:                                      ; preds = %cond_exit_89
  %62 = load i64, ptr %98, align 4
  %63 = and i64 %62, 1023
  store i64 %63, ptr %98, align 4
  %64 = icmp eq i64 %63, 0
  br i1 %64, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %loop_out132
  %65 = call ptr @heap_alloc(i64 80)
  %66 = call ptr @heap_alloc(i64 8)
  store i64 0, ptr %66, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(80) %65, ptr noundef nonnull align 1 dereferenceable(80) %97, i64 80, i1 false)
  call void @heap_free(ptr nonnull %65)
  %67 = load i64, ptr %98, align 4
  %68 = and i64 %67, 1023
  store i64 %68, ptr %98, align 4
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
  store ptr %97, ptr %arr_ptr215, align 8
  store ptr %70, ptr %mask_ptr216, align 8
  call void @print_float_arr(ptr nonnull @res_floats.8646C2EF.0, i64 20, ptr nonnull %out_arr_alloca212)
  br label %__barray_check_bounds.exit779

mask_block_err.i769:                              ; preds = %__barray_check_none_borrowed.exit
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_bounds.exit779:                    ; preds = %cond_exit_131, %__barray_check_none_borrowed.exit771
  %"126_0.sroa.0.0846" = phi i64 [ 0, %__barray_check_none_borrowed.exit771 ], [ %77, %cond_exit_131 ]
  %71 = lshr i64 %"126_0.sroa.0.0846", 6
  %72 = getelementptr inbounds nuw i64, ptr %96, i64 %71
  %73 = load i64, ptr %72, align 4
  %74 = and i64 %"126_0.sroa.0.0846", 63
  %75 = lshr i64 %73, %74
  %76 = trunc i64 %75 to i1
  br i1 %76, label %cond_exit_131, label %panic.i780

panic.i780:                                       ; preds = %__barray_check_bounds.exit779
  call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

cond_exit_131:                                    ; preds = %__barray_check_bounds.exit779
  %77 = add nuw nsw i64 %"126_0.sroa.0.0846", 1
  %78 = shl nuw i64 1, %74
  %79 = xor i64 %73, %78
  store i64 %79, ptr %72, align 4
  %80 = getelementptr inbounds nuw i64, ptr %95, i64 %"126_0.sroa.0.0846"
  store i64 %"126_0.sroa.0.0846", ptr %80, align 4
  %exitcond850.not = icmp eq i64 %77, 100
  br i1 %exitcond850.not, label %loop_out220, label %__barray_check_bounds.exit779

loop_out220:                                      ; preds = %cond_exit_131
  %81 = getelementptr inbounds nuw i8, ptr %96, i64 8
  %82 = load i64, ptr %81, align 4
  %83 = and i64 %82, 68719476735
  store i64 %83, ptr %81, align 4
  %84 = load i64, ptr %96, align 4
  %85 = icmp eq i64 %84, 0
  %86 = icmp eq i64 %83, 0
  %or.cond = select i1 %85, i1 %86, i1 false
  br i1 %or.cond, label %__barray_check_none_borrowed.exit786, label %mask_block_err.i784

__barray_check_none_borrowed.exit786:             ; preds = %loop_out220
  %87 = call ptr @heap_alloc(i64 800)
  %88 = call ptr @heap_alloc(i64 16)
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %88, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(800) %87, ptr noundef nonnull align 1 dereferenceable(800) %95, i64 800, i1 false)
  call void @heap_free(ptr nonnull %87)
  %89 = load i64, ptr %81, align 4
  %90 = and i64 %89, 68719476735
  store i64 %90, ptr %81, align 4
  %91 = load i64, ptr %96, align 4
  %92 = icmp eq i64 %91, 0
  %93 = icmp eq i64 %90, 0
  %or.cond860 = select i1 %92, i1 %93, i1 false
  br i1 %or.cond860, label %__barray_check_none_borrowed.exit791, label %mask_block_err.i789

mask_block_err.i784:                              ; preds = %loop_out220
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit791:             ; preds = %__barray_check_none_borrowed.exit786
  %out_arr_alloca296 = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr298 = getelementptr inbounds nuw i8, ptr %out_arr_alloca296, i64 4
  %arr_ptr299 = getelementptr inbounds nuw i8, ptr %out_arr_alloca296, i64 8
  %mask_ptr300 = getelementptr inbounds nuw i8, ptr %out_arr_alloca296, i64 16
  %94 = alloca [100 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(100) %94, i8 0, i64 100, i1 false)
  store i32 100, ptr %out_arr_alloca296, align 8
  store i32 1, ptr %y_ptr298, align 4
  store ptr %95, ptr %arr_ptr299, align 8
  store ptr %94, ptr %mask_ptr300, align 8
  call void @print_int_arr(ptr nonnull @res_ints.B3BC9D53.0, i64 16, ptr nonnull %out_arr_alloca296)
  ret void

mask_block_err.i789:                              ; preds = %__barray_check_none_borrowed.exit786
  call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

cond_exit_161:                                    ; preds = %__barray_mask_return.exit756
  %95 = tail call ptr @heap_alloc(i64 800)
  %96 = tail call ptr @heap_alloc(i64 16)
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(16) %96, i8 -1, i64 16, i1 false)
  %97 = tail call ptr @heap_alloc(i64 80)
  %98 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %98, align 1
  %99 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"116.fca.2.insert", 0
  %100 = tail call ptr @heap_alloc(i64 80)
  %101 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %101, align 1
  br label %__barray_check_bounds.exit.i.i

102:                                              ; preds = %loop_body.i
  %103 = lshr i64 %.fca.2.extract.i.i, 6
  %104 = getelementptr i64, ptr %.fca.1.extract63.i.i, i64 %103
  %105 = load i64, ptr %104, align 4
  %106 = and i64 %.fca.2.extract.i.i, 63
  %107 = sub nuw nsw i64 64, %106
  %108 = lshr i64 -1, %107
  %109 = icmp eq i64 %106, 0
  %110 = select i1 %109, i64 0, i64 %108
  %111 = or i64 %105, %110
  store i64 %111, ptr %104, align 4
  %last_valid.i.i.i = add i64 %.fca.2.extract.i.i, 9
  %112 = lshr i64 %last_valid.i.i.i, 6
  %113 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i.i, i64 %112
  %114 = load i64, ptr %113, align 4
  %115 = and i64 %last_valid.i.i.i, 63
  %116 = shl nsw i64 -2, %115
  %117 = icmp eq i64 %115, 63
  %118 = select i1 %117, i64 0, i64 %116
  %119 = or i64 %114, %118
  store i64 %119, ptr %113, align 4
  %reass.sub.i.i.i = sub nsw i64 %112, %103
  %.not.i.i.i = icmp eq i64 %reass.sub.i.i.i, -1
  br i1 %.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit", label %mask_block_ok.i.i.i

120:                                              ; preds = %mask_block_ok.i.i.i
  %121 = add nuw i64 %.02.i.i.i, 1
  %exitcond.not.i.i.i = icmp eq i64 %.02.i.i.i, %reass.sub.i.i.i
  br i1 %exitcond.not.i.i.i, label %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit", label %mask_block_ok.i.i.i

mask_block_ok.i.i.i:                              ; preds = %102, %120
  %.02.i.i.i = phi i64 [ %121, %120 ], [ 0, %102 ]
  %gep.i.i.i = getelementptr i64, ptr %104, i64 %.02.i.i.i
  %122 = load i64, ptr %gep.i.i.i, align 4
  %123 = icmp eq i64 %122, -1
  br i1 %123, label %120, label %mask_block_err.i.i.i

mask_block_err.i.i.i:                             ; preds = %mask_block_ok.i.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_check_bounds.exit.i.i:                   ; preds = %loop_body.i, %cond_exit_161
  %.fca.2.extract.i181.i = phi i64 [ 0, %cond_exit_161 ], [ %.fca.2.extract.i.i, %loop_body.i ]
  %.fca.1.extract63.i180.i = phi ptr [ %1, %cond_exit_161 ], [ %.fca.1.extract63.i.i, %loop_body.i ]
  %.fca.0.extract62.i179.i = phi ptr [ %0, %cond_exit_161 ], [ %.fca.0.extract62.i.i, %loop_body.i ]
  %"313_0.sroa.15.0178.i" = phi i64 [ 0, %cond_exit_161 ], [ %124, %loop_body.i ]
  %.pn159177.i = phi { { ptr, ptr, i64 }, i64 } [ %99, %cond_exit_161 ], [ %139, %loop_body.i ]
  %124 = add nuw nsw i64 %"313_0.sroa.15.0178.i", 1
  %125 = add i64 %"313_0.sroa.15.0178.i", %.fca.2.extract.i181.i
  %126 = lshr i64 %125, 6
  %127 = getelementptr inbounds nuw i64, ptr %.fca.1.extract63.i180.i, i64 %126
  %128 = load i64, ptr %127, align 4
  %129 = and i64 %125, 63
  %130 = lshr i64 %128, %129
  %131 = trunc i64 %130 to i1
  br i1 %131, label %panic.i.i.i, label %__barray_check_bounds.exit.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit.i:                     ; preds = %__barray_check_bounds.exit.i.i
  %132 = shl nuw i64 1, %129
  %133 = xor i64 %132, %128
  store i64 %133, ptr %127, align 4
  %134 = getelementptr inbounds i64, ptr %.fca.0.extract62.i179.i, i64 %125
  %135 = load i64, ptr %134, align 4
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %135)
  tail call void @___qfree(i64 %135)
  %136 = load i64, ptr %101, align 4
  %137 = lshr i64 %136, %"313_0.sroa.15.0178.i"
  %138 = trunc i64 %137 to i1
  br i1 %138, label %loop_body.i, label %panic.i.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i:                                      ; preds = %__barray_check_bounds.exit.i
  %139 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, i64 %124, 1
  %140 = shl nuw nsw i64 1, %"313_0.sroa.15.0178.i"
  %141 = xor i64 %136, %140
  store i64 %141, ptr %101, align 4
  %142 = getelementptr inbounds nuw i64, ptr %100, i64 %"313_0.sroa.15.0178.i"
  store i64 %lazy_measure.i, ptr %142, align 4
  %143 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159177.i, 0
  %.fca.0.extract62.i.i = extractvalue { ptr, ptr, i64 } %143, 0
  %.fca.1.extract63.i.i = extractvalue { ptr, ptr, i64 } %143, 1
  %.fca.2.extract.i.i = extractvalue { ptr, ptr, i64 } %143, 2
  %exitcond.not.i792 = icmp eq i64 %124, 10
  br i1 %exitcond.not.i792, label %102, label %__barray_check_bounds.exit.i.i

"__hugr__.guppylang.std.quantum.measure_array$10.299.exit": ; preds = %120, %102
  tail call void @heap_free(ptr %.fca.0.extract62.i.i)
  tail call void @heap_free(ptr nonnull %.fca.1.extract63.i.i)
  %"123.fca.0.insert.i" = insertvalue { ptr, ptr, i64 } poison, ptr %100, 0
  %"123.fca.1.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.0.insert.i", ptr %101, 1
  %"123.fca.2.insert.i" = insertvalue { ptr, ptr, i64 } %"123.fca.1.insert.i", i64 0, 2
  %144 = insertvalue { { ptr, ptr, i64 }, i64 } poison, { ptr, ptr, i64 } %"123.fca.2.insert.i", 0
  %145 = tail call ptr @heap_alloc(i64 10)
  %146 = tail call ptr @heap_alloc(i64 8)
  store i64 -1, ptr %146, align 1
  br label %__barray_check_bounds.exit.i.i793

loop_body.preheader.i.i:                          ; preds = %loop_body.i796
  %"627_1.sroa.10.0.i.i" = extractvalue { ptr, ptr, i64 } %295, 2
  %"627_1.sroa.5.0.i.i" = extractvalue { ptr, ptr, i64 } %295, 1
  %"627_1.sroa.0.0.i.i" = extractvalue { ptr, ptr, i64 } %295, 0
  %147 = lshr i64 %"627_1.sroa.10.0.i.i", 6
  %148 = getelementptr i64, ptr %"627_1.sroa.5.0.i.i", i64 %147
  %149 = load i64, ptr %148, align 4
  %150 = and i64 %"627_1.sroa.10.0.i.i", 63
  %151 = lshr i64 %149, %150
  %152 = trunc i64 %151 to i1
  br i1 %152, label %cond_exit_630.thread.i.i, label %__barray_mask_borrow.exit228.i.i

__barray_check_bounds.exit.i.i793:                ; preds = %loop_body.i796, %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit"
  %153 = phi { ptr, ptr, i64 } [ %"123.fca.2.insert.i", %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit" ], [ %295, %loop_body.i796 ]
  %"354_0.sroa.15.0168.i" = phi i64 [ 0, %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit" ], [ %154, %loop_body.i796 ]
  %.pn159167.i = phi { { ptr, ptr, i64 }, i64 } [ %144, %"__hugr__.guppylang.std.quantum.measure_array$10.299.exit" ], [ %291, %loop_body.i796 ]
  %154 = add nuw nsw i64 %"354_0.sroa.15.0168.i", 1
  %.fca.2.extract208.i.i = extractvalue { ptr, ptr, i64 } %153, 2
  %.fca.1.extract207.i.i = extractvalue { ptr, ptr, i64 } %153, 1
  %155 = add i64 %.fca.2.extract208.i.i, %"354_0.sroa.15.0168.i"
  %156 = lshr i64 %155, 6
  %157 = getelementptr inbounds nuw i64, ptr %.fca.1.extract207.i.i, i64 %156
  %158 = load i64, ptr %157, align 4
  %159 = and i64 %155, 63
  %160 = lshr i64 %158, %159
  %161 = trunc i64 %160 to i1
  br i1 %161, label %panic.i.i.i808, label %__barray_check_bounds.exit221.i.i

panic.i.i.i808:                                   ; preds = %__barray_check_bounds.exit.i.i793
  tail call void @panic(i32 1002, ptr nonnull @"e_Array elem.E746B1A3.0")
  unreachable

__barray_check_bounds.exit221.i.i:                ; preds = %__barray_check_bounds.exit.i.i793
  %.fca.0.extract206.i.i = extractvalue { ptr, ptr, i64 } %153, 0
  %162 = shl nuw i64 1, %159
  %163 = xor i64 %162, %158
  store i64 %163, ptr %157, align 4
  %164 = getelementptr inbounds i64, ptr %.fca.0.extract206.i.i, i64 %155
  %165 = load i64, ptr %164, align 4
  tail call void @___inc_future_refcount(i64 %165)
  %166 = load i64, ptr %157, align 4
  %167 = lshr i64 %166, %159
  %168 = trunc i64 %167 to i1
  br i1 %168, label %__barray_check_bounds.exit.i794, label %panic.i222.i.i

panic.i222.i.i:                                   ; preds = %__barray_check_bounds.exit221.i.i
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

169:                                              ; preds = %mask_block_ok.i.i.i800
  %170 = add nuw i64 %.02.i.i.i801, 1
  %exitcond.not.i.i.i804 = icmp eq i64 %.02.i.i.i801, %reass.sub.i.i.i798
  br i1 %exitcond.not.i.i.i804, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit", label %mask_block_ok.i.i.i800

mask_block_ok.i.i.i800:                           ; preds = %cond_exit_630.thread.9.i.i, %169
  %.02.i.i.i801 = phi i64 [ %170, %169 ], [ 0, %cond_exit_630.thread.9.i.i ]
  %gep.i.i.i802 = getelementptr i64, ptr %148, i64 %.02.i.i.i801
  %171 = load i64, ptr %gep.i.i.i802, align 4
  %172 = icmp eq i64 %171, -1
  br i1 %172, label %169, label %mask_block_err.i.i.i803

mask_block_err.i.i.i803:                          ; preds = %mask_block_ok.i.i.i800
  tail call void @panic(i32 1002, ptr nonnull @"e_Array cont.EFA5AC45.0")
  unreachable

__barray_mask_borrow.exit228.i.i:                 ; preds = %loop_body.preheader.i.i
  %173 = shl nuw i64 1, %150
  %174 = xor i64 %149, %173
  store i64 %174, ptr %148, align 4
  %175 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %"627_1.sroa.10.0.i.i"
  %176 = load i64, ptr %175, align 4
  tail call void @___dec_future_refcount(i64 %176)
  br label %cond_exit_630.thread.i.i

cond_exit_630.thread.i.i:                         ; preds = %__barray_mask_borrow.exit228.i.i, %loop_body.preheader.i.i
  %177 = add i64 %"627_1.sroa.10.0.i.i", 1
  %178 = lshr i64 %177, 6
  %179 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %178
  %180 = load i64, ptr %179, align 4
  %181 = and i64 %177, 63
  %182 = lshr i64 %180, %181
  %183 = trunc i64 %182 to i1
  br i1 %183, label %cond_exit_630.thread.1.i.i, label %__barray_mask_borrow.exit228.1.i.i

__barray_mask_borrow.exit228.1.i.i:               ; preds = %cond_exit_630.thread.i.i
  %184 = shl nuw i64 1, %181
  %185 = xor i64 %180, %184
  store i64 %185, ptr %179, align 4
  %186 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %177
  %187 = load i64, ptr %186, align 4
  tail call void @___dec_future_refcount(i64 %187)
  br label %cond_exit_630.thread.1.i.i

cond_exit_630.thread.1.i.i:                       ; preds = %__barray_mask_borrow.exit228.1.i.i, %cond_exit_630.thread.i.i
  %188 = add i64 %"627_1.sroa.10.0.i.i", 2
  %189 = lshr i64 %188, 6
  %190 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %189
  %191 = load i64, ptr %190, align 4
  %192 = and i64 %188, 63
  %193 = lshr i64 %191, %192
  %194 = trunc i64 %193 to i1
  br i1 %194, label %cond_exit_630.thread.2.i.i, label %__barray_mask_borrow.exit228.2.i.i

__barray_mask_borrow.exit228.2.i.i:               ; preds = %cond_exit_630.thread.1.i.i
  %195 = shl nuw i64 1, %192
  %196 = xor i64 %191, %195
  store i64 %196, ptr %190, align 4
  %197 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %188
  %198 = load i64, ptr %197, align 4
  tail call void @___dec_future_refcount(i64 %198)
  br label %cond_exit_630.thread.2.i.i

cond_exit_630.thread.2.i.i:                       ; preds = %__barray_mask_borrow.exit228.2.i.i, %cond_exit_630.thread.1.i.i
  %199 = add i64 %"627_1.sroa.10.0.i.i", 3
  %200 = lshr i64 %199, 6
  %201 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %200
  %202 = load i64, ptr %201, align 4
  %203 = and i64 %199, 63
  %204 = lshr i64 %202, %203
  %205 = trunc i64 %204 to i1
  br i1 %205, label %cond_exit_630.thread.3.i.i, label %__barray_mask_borrow.exit228.3.i.i

__barray_mask_borrow.exit228.3.i.i:               ; preds = %cond_exit_630.thread.2.i.i
  %206 = shl nuw i64 1, %203
  %207 = xor i64 %202, %206
  store i64 %207, ptr %201, align 4
  %208 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %199
  %209 = load i64, ptr %208, align 4
  tail call void @___dec_future_refcount(i64 %209)
  br label %cond_exit_630.thread.3.i.i

cond_exit_630.thread.3.i.i:                       ; preds = %__barray_mask_borrow.exit228.3.i.i, %cond_exit_630.thread.2.i.i
  %210 = add i64 %"627_1.sroa.10.0.i.i", 4
  %211 = lshr i64 %210, 6
  %212 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %211
  %213 = load i64, ptr %212, align 4
  %214 = and i64 %210, 63
  %215 = lshr i64 %213, %214
  %216 = trunc i64 %215 to i1
  br i1 %216, label %cond_exit_630.thread.4.i.i, label %__barray_mask_borrow.exit228.4.i.i

__barray_mask_borrow.exit228.4.i.i:               ; preds = %cond_exit_630.thread.3.i.i
  %217 = shl nuw i64 1, %214
  %218 = xor i64 %213, %217
  store i64 %218, ptr %212, align 4
  %219 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %210
  %220 = load i64, ptr %219, align 4
  tail call void @___dec_future_refcount(i64 %220)
  br label %cond_exit_630.thread.4.i.i

cond_exit_630.thread.4.i.i:                       ; preds = %__barray_mask_borrow.exit228.4.i.i, %cond_exit_630.thread.3.i.i
  %221 = add i64 %"627_1.sroa.10.0.i.i", 5
  %222 = lshr i64 %221, 6
  %223 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %222
  %224 = load i64, ptr %223, align 4
  %225 = and i64 %221, 63
  %226 = lshr i64 %224, %225
  %227 = trunc i64 %226 to i1
  br i1 %227, label %cond_exit_630.thread.5.i.i, label %__barray_mask_borrow.exit228.5.i.i

__barray_mask_borrow.exit228.5.i.i:               ; preds = %cond_exit_630.thread.4.i.i
  %228 = shl nuw i64 1, %225
  %229 = xor i64 %224, %228
  store i64 %229, ptr %223, align 4
  %230 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %221
  %231 = load i64, ptr %230, align 4
  tail call void @___dec_future_refcount(i64 %231)
  br label %cond_exit_630.thread.5.i.i

cond_exit_630.thread.5.i.i:                       ; preds = %__barray_mask_borrow.exit228.5.i.i, %cond_exit_630.thread.4.i.i
  %232 = add i64 %"627_1.sroa.10.0.i.i", 6
  %233 = lshr i64 %232, 6
  %234 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %233
  %235 = load i64, ptr %234, align 4
  %236 = and i64 %232, 63
  %237 = lshr i64 %235, %236
  %238 = trunc i64 %237 to i1
  br i1 %238, label %cond_exit_630.thread.6.i.i, label %__barray_mask_borrow.exit228.6.i.i

__barray_mask_borrow.exit228.6.i.i:               ; preds = %cond_exit_630.thread.5.i.i
  %239 = shl nuw i64 1, %236
  %240 = xor i64 %235, %239
  store i64 %240, ptr %234, align 4
  %241 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %232
  %242 = load i64, ptr %241, align 4
  tail call void @___dec_future_refcount(i64 %242)
  br label %cond_exit_630.thread.6.i.i

cond_exit_630.thread.6.i.i:                       ; preds = %__barray_mask_borrow.exit228.6.i.i, %cond_exit_630.thread.5.i.i
  %243 = add i64 %"627_1.sroa.10.0.i.i", 7
  %244 = lshr i64 %243, 6
  %245 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %244
  %246 = load i64, ptr %245, align 4
  %247 = and i64 %243, 63
  %248 = lshr i64 %246, %247
  %249 = trunc i64 %248 to i1
  br i1 %249, label %cond_exit_630.thread.7.i.i, label %__barray_mask_borrow.exit228.7.i.i

__barray_mask_borrow.exit228.7.i.i:               ; preds = %cond_exit_630.thread.6.i.i
  %250 = shl nuw i64 1, %247
  %251 = xor i64 %246, %250
  store i64 %251, ptr %245, align 4
  %252 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %243
  %253 = load i64, ptr %252, align 4
  tail call void @___dec_future_refcount(i64 %253)
  br label %cond_exit_630.thread.7.i.i

cond_exit_630.thread.7.i.i:                       ; preds = %__barray_mask_borrow.exit228.7.i.i, %cond_exit_630.thread.6.i.i
  %254 = add i64 %"627_1.sroa.10.0.i.i", 8
  %255 = lshr i64 %254, 6
  %256 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %255
  %257 = load i64, ptr %256, align 4
  %258 = and i64 %254, 63
  %259 = lshr i64 %257, %258
  %260 = trunc i64 %259 to i1
  br i1 %260, label %cond_exit_630.thread.8.i.i, label %__barray_mask_borrow.exit228.8.i.i

__barray_mask_borrow.exit228.8.i.i:               ; preds = %cond_exit_630.thread.7.i.i
  %261 = shl nuw i64 1, %258
  %262 = xor i64 %257, %261
  store i64 %262, ptr %256, align 4
  %263 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %254
  %264 = load i64, ptr %263, align 4
  tail call void @___dec_future_refcount(i64 %264)
  br label %cond_exit_630.thread.8.i.i

cond_exit_630.thread.8.i.i:                       ; preds = %__barray_mask_borrow.exit228.8.i.i, %cond_exit_630.thread.7.i.i
  %265 = add i64 %"627_1.sroa.10.0.i.i", 9
  %266 = lshr i64 %265, 6
  %267 = getelementptr inbounds nuw i64, ptr %"627_1.sroa.5.0.i.i", i64 %266
  %268 = load i64, ptr %267, align 4
  %269 = and i64 %265, 63
  %270 = lshr i64 %268, %269
  %271 = trunc i64 %270 to i1
  br i1 %271, label %cond_exit_630.thread.9.i.i, label %__barray_mask_borrow.exit228.9.i.i

__barray_mask_borrow.exit228.9.i.i:               ; preds = %cond_exit_630.thread.8.i.i
  %272 = shl nuw i64 1, %269
  %273 = xor i64 %268, %272
  store i64 %273, ptr %267, align 4
  %274 = getelementptr inbounds i64, ptr %"627_1.sroa.0.0.i.i", i64 %265
  %275 = load i64, ptr %274, align 4
  tail call void @___dec_future_refcount(i64 %275)
  br label %cond_exit_630.thread.9.i.i

cond_exit_630.thread.9.i.i:                       ; preds = %__barray_mask_borrow.exit228.9.i.i, %cond_exit_630.thread.8.i.i
  %276 = load i64, ptr %148, align 4
  %277 = sub nuw nsw i64 64, %150
  %278 = lshr i64 -1, %277
  %279 = icmp eq i64 %150, 0
  %280 = select i1 %279, i64 0, i64 %278
  %281 = or i64 %276, %280
  store i64 %281, ptr %148, align 4
  %282 = load i64, ptr %267, align 4
  %283 = shl nsw i64 -2, %269
  %284 = icmp eq i64 %269, 63
  %285 = select i1 %284, i64 0, i64 %283
  %286 = or i64 %282, %285
  store i64 %286, ptr %267, align 4
  %reass.sub.i.i.i798 = sub nsw i64 %266, %147
  %.not.i.i.i799 = icmp eq i64 %reass.sub.i.i.i798, -1
  br i1 %.not.i.i.i799, label %"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit", label %mask_block_ok.i.i.i800

__barray_check_bounds.exit.i794:                  ; preds = %__barray_check_bounds.exit221.i.i
  %287 = xor i64 %166, %162
  store i64 %287, ptr %157, align 4
  store i64 %165, ptr %164, align 4
  %read_bool.i = tail call i1 @___read_future_bool(i64 %165)
  tail call void @___dec_future_refcount(i64 %165)
  %288 = load i64, ptr %146, align 4
  %289 = lshr i64 %288, %"354_0.sroa.15.0168.i"
  %290 = trunc i64 %289 to i1
  br i1 %290, label %loop_body.i796, label %panic.i.i795

panic.i.i795:                                     ; preds = %__barray_check_bounds.exit.i794
  tail call void @panic(i32 1002, ptr nonnull @"e_Array alre.5A300C2A.0")
  unreachable

loop_body.i796:                                   ; preds = %__barray_check_bounds.exit.i794
  %291 = insertvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, i64 %154, 1
  %292 = shl nuw nsw i64 1, %"354_0.sroa.15.0168.i"
  %293 = xor i64 %288, %292
  store i64 %293, ptr %146, align 4
  %294 = getelementptr inbounds nuw i1, ptr %145, i64 %"354_0.sroa.15.0168.i"
  store i1 %read_bool.i, ptr %294, align 1
  %295 = extractvalue { { ptr, ptr, i64 }, i64 } %.pn159167.i, 0
  %exitcond.not.i797 = icmp eq i64 %154, 10
  br i1 %exitcond.not.i797, label %loop_body.preheader.i.i, label %__barray_check_bounds.exit.i.i793

"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit": ; preds = %169, %cond_exit_630.thread.9.i.i
  tail call void @heap_free(ptr %"627_1.sroa.0.0.i.i")
  tail call void @heap_free(ptr nonnull %"627_1.sroa.5.0.i.i")
  %296 = load i64, ptr %146, align 4
  %297 = and i64 %296, 1023
  store i64 %297, ptr %146, align 4
  %298 = icmp eq i64 %297, 0
  br i1 %298, label %__barray_check_none_borrowed.exit813, label %mask_block_err.i811

__barray_check_none_borrowed.exit813:             ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit"
  %299 = tail call ptr @heap_alloc(i64 10)
  %300 = tail call ptr @heap_alloc(i64 8)
  store i64 0, ptr %300, align 1
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %299, ptr noundef nonnull align 1 dereferenceable(10) %145, i64 10, i1 false)
  tail call void @heap_free(ptr nonnull %299)
  %301 = load i64, ptr %146, align 4
  %302 = and i64 %301, 1023
  store i64 %302, ptr %146, align 4
  %303 = icmp eq i64 %302, 0
  br i1 %303, label %__barray_check_none_borrowed.exit818, label %mask_block_err.i816

mask_block_err.i811:                              ; preds = %"__hugr__.guppylang.std.quantum.collect_measurements$10.340.exit"
  tail call void @panic(i32 1002, ptr nonnull @"e_Some array.A77EF32E.0")
  unreachable

__barray_check_none_borrowed.exit818:             ; preds = %__barray_check_none_borrowed.exit813
  %out_arr_alloca = alloca <{ i32, i32, ptr, ptr }>, align 8
  %y_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 4
  %arr_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 8
  %mask_ptr = getelementptr inbounds nuw i8, ptr %out_arr_alloca, i64 16
  %304 = alloca [10 x i1], align 1
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 1 dereferenceable(10) %304, i8 0, i64 10, i1 false)
  store i32 10, ptr %out_arr_alloca, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %145, ptr %arr_ptr, align 8
  store ptr %304, ptr %mask_ptr, align 8
  call void @print_bool_arr(ptr nonnull @res_bools.B1D99BB9.0, i64 18, ptr nonnull %out_arr_alloca)
  br label %pow.i.preheader

mask_block_err.i816:                              ; preds = %__barray_check_none_borrowed.exit813
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
