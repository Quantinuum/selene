; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_00.00F9F73D.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:00"
@res_01.2F21FB33.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:01"
@res_10.90CD55C3.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:10"
@res_11.7D0DF573.0 = private constant [16 x i8] c"\0FUSER:BOOLARR:11"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %qalloc.i = tail call i64 @___qalloc()
  %not_max.not.i = icmp eq i64 %qalloc.i, -1
  br i1 %not_max.not.i, label %id_bb.i, label %reset_bb.i

reset_bb.i:                                       ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i)
  br label %id_bb.i

id_bb.i:                                          ; preds = %reset_bb.i, %alloca_block
  %0 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i, 1
  %1 = select i1 %not_max.not.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %0
  %.fca.0.extract.i = extractvalue { i1, i64 } %1, 0
  br i1 %.fca.0.extract.i, label %__hugr__.__tk2_qalloc.90.exit, label %cond_94_case_0.i

cond_94_case_0.i:                                 ; preds = %id_bb.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.90.exit:                    ; preds = %id_bb.i
  %.fca.1.extract.i = extractvalue { i1, i64 } %1, 1
  %qalloc.i773 = tail call i64 @___qalloc()
  %not_max.not.i774 = icmp eq i64 %qalloc.i773, -1
  br i1 %not_max.not.i774, label %id_bb.i777, label %reset_bb.i775

reset_bb.i775:                                    ; preds = %__hugr__.__tk2_qalloc.90.exit
  tail call void @___reset(i64 %qalloc.i773)
  br label %id_bb.i777

id_bb.i777:                                       ; preds = %reset_bb.i775, %__hugr__.__tk2_qalloc.90.exit
  %2 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i773, 1
  %3 = select i1 %not_max.not.i774, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %2
  %.fca.0.extract.i776 = extractvalue { i1, i64 } %3, 0
  br i1 %.fca.0.extract.i776, label %__hugr__.__tk2_qalloc.90.exit780, label %cond_94_case_0.i779

cond_94_case_0.i779:                              ; preds = %id_bb.i777
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.90.exit780:                 ; preds = %id_bb.i777
  %.fca.1.extract.i778 = extractvalue { i1, i64 } %3, 1
  tail call void @___rxy(i64 %.fca.1.extract.i778, double 0xBFF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i, double 0x400921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rzz(i64 %.fca.1.extract.i, i64 %.fca.1.extract.i778, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i778, double 0xBFF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i778, double 0x3FF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i, double 0xBFF921FB54442D18)
  %lazy_measure = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i)
  tail call void @___qfree(i64 %.fca.1.extract.i)
  tail call void @___rxy(i64 %.fca.1.extract.i778, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure10 = tail call i64 @___lazy_measure(i64 %.fca.1.extract.i778)
  tail call void @___qfree(i64 %.fca.1.extract.i778)
  %"10_013.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure, 1
  %"11_014.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure10, 1
  %4 = tail call i8* @heap_alloc(i64 48)
  %5 = bitcast i8* %4 to { i1, i64, i1 }*
  %6 = tail call i8* @heap_alloc(i64 8)
  %7 = bitcast i8* %6 to i64*
  store i64 0, i64* %7, align 1
  store { i1, i64, i1 } %"10_013.fca.1.insert", { i1, i64, i1 }* %5, align 4
  %8 = getelementptr inbounds i8, i8* %4, i64 24
  %9 = bitcast i8* %8 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"11_014.fca.1.insert", { i1, i64, i1 }* %9, align 4
  %10 = tail call i8* @heap_alloc(i64 64)
  %11 = tail call i8* @heap_alloc(i64 8)
  %12 = bitcast i8* %11 to i64*
  store i64 0, i64* %12, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(64) %10, i8 0, i64 64, i1 false)
  %13 = load i64, i64* %7, align 4
  %14 = and i64 %13, 3
  store i64 %14, i64* %7, align 4
  %15 = icmp eq i64 %14, 0
  br i1 %15, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %__hugr__.__tk2_qalloc.90.exit780
  %16 = tail call i8* @heap_alloc(i64 48)
  %17 = bitcast i8* %16 to { i1, i64, i1 }*
  %18 = tail call i8* @heap_alloc(i64 8)
  %19 = bitcast i8* %18 to i64*
  store i64 0, i64* %19, align 1
  %20 = bitcast i8* %10 to { i1, { i1, i64, i1 } }*
  %21 = load { i1, i64, i1 }, { i1, i64, i1 }* %5, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %21, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %21, 1
  br i1 %.fca.0.extract118.i, label %cond_455_case_1.i, label %23

mask_block_err.i:                                 ; preds = %__hugr__.__tk2_qalloc.90.exit780
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_455_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %22 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %23

23:                                               ; preds = %__barray_check_none_borrowed.exit, %cond_455_case_1.i
  %.pn.i = phi { i1, i64, i1 } [ %22, %cond_455_case_1.i ], [ %21, %__barray_check_none_borrowed.exit ]
  %24 = load i64, i64* %12, align 4
  %25 = and i64 %24, 1
  %.not.i.i = icmp eq i64 %25, 0
  br i1 %.not.i.i, label %cond_458_case_1.i, label %panic.i.i

panic.i.i:                                        ; preds = %33, %23
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_458_case_1.i:                                ; preds = %23
  %"04.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %"17.fca.2.insert.i" = insertvalue { i1, i64, i1 } %21, i1 %"04.sroa.6.0.i", 2
  %26 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i", 1
  %27 = bitcast i8* %10 to i1*
  %28 = load i1, i1* %27, align 1
  store { i1, { i1, i64, i1 } } %26, { i1, { i1, i64, i1 } }* %20, align 4
  br i1 %28, label %cond_459_case_1.i, label %__hugr__.const_fun_161.158.exit

cond_459_case_1.i:                                ; preds = %cond_458_case_1.i.1, %cond_458_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_161.158.exit:                  ; preds = %cond_458_case_1.i
  store { i1, i64, i1 } %"17.fca.2.insert.i", { i1, i64, i1 }* %17, align 4
  %29 = getelementptr inbounds i8, i8* %4, i64 24
  %30 = bitcast i8* %29 to { i1, i64, i1 }*
  %31 = load { i1, i64, i1 }, { i1, i64, i1 }* %30, align 4
  %.fca.0.extract118.i.1 = extractvalue { i1, i64, i1 } %31, 0
  %.fca.1.extract119.i.1 = extractvalue { i1, i64, i1 } %31, 1
  br i1 %.fca.0.extract118.i.1, label %cond_455_case_1.i.1, label %33

cond_455_case_1.i.1:                              ; preds = %__hugr__.const_fun_161.158.exit
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i.1)
  %32 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i.1, 1
  br label %33

33:                                               ; preds = %__hugr__.const_fun_161.158.exit, %cond_455_case_1.i.1
  %.pn.i.1 = phi { i1, i64, i1 } [ %32, %cond_455_case_1.i.1 ], [ %31, %__hugr__.const_fun_161.158.exit ]
  %34 = load i64, i64* %12, align 4
  %35 = and i64 %34, 2
  %.not.i.i.1 = icmp eq i64 %35, 0
  br i1 %.not.i.i.1, label %cond_458_case_1.i.1, label %panic.i.i

cond_458_case_1.i.1:                              ; preds = %33
  %"04.sroa.6.0.i.1" = extractvalue { i1, i64, i1 } %.pn.i.1, 2
  %"17.fca.2.insert.i.1" = insertvalue { i1, i64, i1 } %31, i1 %"04.sroa.6.0.i.1", 2
  %36 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i.1", 1
  %37 = getelementptr inbounds i8, i8* %10, i64 32
  %38 = bitcast i8* %37 to { i1, { i1, i64, i1 } }*
  %39 = bitcast i8* %37 to i1*
  %40 = load i1, i1* %39, align 1
  store { i1, { i1, i64, i1 } } %36, { i1, { i1, i64, i1 } }* %38, align 4
  br i1 %40, label %cond_459_case_1.i, label %mask_block_ok.i784

mask_block_ok.i784:                               ; preds = %cond_458_case_1.i.1
  %41 = getelementptr inbounds i8, i8* %16, i64 24
  %42 = bitcast i8* %41 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"17.fca.2.insert.i.1", { i1, i64, i1 }* %42, align 4
  tail call void @heap_free(i8* nonnull %4)
  tail call void @heap_free(i8* nonnull %6)
  %43 = load i64, i64* %12, align 4
  %44 = and i64 %43, 3
  store i64 %44, i64* %12, align 4
  %45 = icmp eq i64 %44, 0
  br i1 %45, label %__barray_check_none_borrowed.exit786, label %mask_block_err.i785

mask_block_err.i785:                              ; preds = %mask_block_ok.i784
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

__barray_check_none_borrowed.exit786:             ; preds = %mask_block_ok.i784
  %46 = tail call i8* @heap_alloc(i64 48)
  %47 = bitcast i8* %46 to { i1, i64, i1 }*
  %48 = tail call i8* @heap_alloc(i64 8)
  %49 = bitcast i8* %48 to i64*
  store i64 0, i64* %49, align 1
  %50 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %20, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %50, 0
  br i1 %.fca.0.extract11.i, label %__hugr__.const_fun_166.161.exit, label %cond_500_case_0.i

cond_500_case_0.i:                                ; preds = %__hugr__.const_fun_166.161.exit, %__barray_check_none_borrowed.exit786
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_166.161.exit:                  ; preds = %__barray_check_none_borrowed.exit786
  %51 = extractvalue { i1, { i1, i64, i1 } } %50, 1
  store { i1, i64, i1 } %51, { i1, i64, i1 }* %47, align 4
  %52 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %38, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %52, 0
  br i1 %.fca.0.extract11.i.1, label %__hugr__.const_fun_166.161.exit.1, label %cond_500_case_0.i

__hugr__.const_fun_166.161.exit.1:                ; preds = %__hugr__.const_fun_166.161.exit
  %53 = extractvalue { i1, { i1, i64, i1 } } %52, 1
  %54 = getelementptr inbounds i8, i8* %46, i64 24
  %55 = bitcast i8* %54 to { i1, i64, i1 }*
  store { i1, i64, i1 } %53, { i1, i64, i1 }* %55, align 4
  tail call void @heap_free(i8* nonnull %10)
  tail call void @heap_free(i8* nonnull %11)
  %56 = load i64, i64* %49, align 4
  %57 = and i64 %56, 1
  %.not1007 = icmp eq i64 %57, 0
  br i1 %.not1007, label %__barray_mask_borrow.exit, label %cond_exit_267

mask_block_err.i790:                              ; preds = %cond_exit_267.1
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit:                        ; preds = %__hugr__.const_fun_166.161.exit.1
  %58 = xor i64 %56, 1
  store i64 %58, i64* %49, align 4
  %59 = load { i1, i64, i1 }, { i1, i64, i1 }* %47, align 4
  %.fca.0.extract602 = extractvalue { i1, i64, i1 } %59, 0
  br i1 %.fca.0.extract602, label %cond_290_case_1, label %cond_exit_267

cond_exit_267:                                    ; preds = %cond_290_case_1, %__barray_mask_borrow.exit, %__hugr__.const_fun_166.161.exit.1
  %60 = load i64, i64* %49, align 4
  %61 = and i64 %60, 2
  %.not1007.1 = icmp eq i64 %61, 0
  br i1 %.not1007.1, label %__barray_mask_borrow.exit.1, label %cond_exit_267.1

__barray_mask_borrow.exit.1:                      ; preds = %cond_exit_267
  %62 = xor i64 %60, 2
  store i64 %62, i64* %49, align 4
  %63 = getelementptr inbounds i8, i8* %46, i64 24
  %64 = bitcast i8* %63 to { i1, i64, i1 }*
  %65 = load { i1, i64, i1 }, { i1, i64, i1 }* %64, align 4
  %.fca.0.extract602.1 = extractvalue { i1, i64, i1 } %65, 0
  br i1 %.fca.0.extract602.1, label %cond_290_case_1.1, label %cond_exit_267.1

cond_290_case_1.1:                                ; preds = %__barray_mask_borrow.exit.1
  %.fca.1.extract603.1 = extractvalue { i1, i64, i1 } %65, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract603.1)
  br label %cond_exit_267.1

cond_exit_267.1:                                  ; preds = %cond_290_case_1.1, %__barray_mask_borrow.exit.1, %cond_exit_267
  %66 = load i64, i64* %49, align 4
  %67 = or i64 %66, -4
  store i64 %67, i64* %49, align 4
  %68 = icmp eq i64 %67, -1
  br i1 %68, label %loop_out, label %mask_block_err.i790

loop_out:                                         ; preds = %cond_exit_267.1
  tail call void @heap_free(i8* %46)
  tail call void @heap_free(i8* nonnull %48)
  %69 = load i64, i64* %19, align 4
  %70 = and i64 %69, 3
  store i64 %70, i64* %19, align 4
  %71 = icmp eq i64 %70, 0
  br i1 %71, label %__barray_check_none_borrowed.exit796, label %mask_block_err.i795

__barray_check_none_borrowed.exit796:             ; preds = %loop_out
  %72 = tail call i8* @heap_alloc(i64 2)
  %73 = tail call i8* @heap_alloc(i64 8)
  %74 = bitcast i8* %73 to i64*
  store i64 0, i64* %74, align 1
  %75 = load { i1, i64, i1 }, { i1, i64, i1 }* %17, align 4
  %.fca.0.extract.i797 = extractvalue { i1, i64, i1 } %75, 0
  %.fca.1.extract.i798 = extractvalue { i1, i64, i1 } %75, 1
  br i1 %.fca.0.extract.i797, label %cond_244_case_1.i, label %cond_244_case_0.i

mask_block_err.i795:                              ; preds = %loop_out
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_290_case_1:                                  ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract603 = extractvalue { i1, i64, i1 } %59, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract603)
  br label %cond_exit_267

cond_244_case_0.i:                                ; preds = %__barray_check_none_borrowed.exit796
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %75, 2
  br label %__hugr__.array.__read_bool.3.85.exit

cond_244_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit796
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i798)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i798)
  br label %__hugr__.array.__read_bool.3.85.exit

__hugr__.array.__read_bool.3.85.exit:             ; preds = %cond_244_case_0.i, %cond_244_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_244_case_1.i ], [ %.fca.2.extract.i, %cond_244_case_0.i ]
  %76 = bitcast i8* %72 to i1*
  store i1 %"03.0.i", i1* %76, align 1
  %77 = load { i1, i64, i1 }, { i1, i64, i1 }* %42, align 4
  %.fca.0.extract.i797.1 = extractvalue { i1, i64, i1 } %77, 0
  %.fca.1.extract.i798.1 = extractvalue { i1, i64, i1 } %77, 1
  br i1 %.fca.0.extract.i797.1, label %cond_244_case_1.i.1, label %cond_244_case_0.i.1

cond_244_case_0.i.1:                              ; preds = %__hugr__.array.__read_bool.3.85.exit
  %.fca.2.extract.i.1 = extractvalue { i1, i64, i1 } %77, 2
  br label %__hugr__.array.__read_bool.3.85.exit.1

cond_244_case_1.i.1:                              ; preds = %__hugr__.array.__read_bool.3.85.exit
  %read_bool.i.1 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i798.1)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i798.1)
  br label %__hugr__.array.__read_bool.3.85.exit.1

__hugr__.array.__read_bool.3.85.exit.1:           ; preds = %cond_244_case_1.i.1, %cond_244_case_0.i.1
  %"03.0.i.1" = phi i1 [ %read_bool.i.1, %cond_244_case_1.i.1 ], [ %.fca.2.extract.i.1, %cond_244_case_0.i.1 ]
  %78 = getelementptr inbounds i8, i8* %72, i64 1
  %79 = bitcast i8* %78 to i1*
  store i1 %"03.0.i.1", i1* %79, align 1
  tail call void @heap_free(i8* nonnull %16)
  tail call void @heap_free(i8* nonnull %18)
  %80 = load i64, i64* %74, align 4
  %81 = and i64 %80, 3
  store i64 %81, i64* %74, align 4
  %82 = icmp eq i64 %81, 0
  br i1 %82, label %__barray_check_none_borrowed.exit803, label %mask_block_err.i802

__barray_check_none_borrowed.exit803:             ; preds = %__hugr__.array.__read_bool.3.85.exit.1
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %83 = alloca [2 x i1], align 1
  %.sub = getelementptr inbounds [2 x i1], [2 x i1]* %83, i64 0, i64 0
  store i1 false, i1* %.sub, align 1
  %.repack665 = getelementptr inbounds [2 x i1], [2 x i1]* %83, i64 0, i64 1
  store i1 false, i1* %.repack665, align 1
  store i32 2, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %84 = bitcast i1** %arr_ptr to i8**
  store i8* %72, i8** %84, align 8
  store i1* %.sub, i1** %mask_ptr, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @res_00.00F9F73D.0, i64 0, i64 0), i64 15, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  %qalloc.i804 = call i64 @___qalloc()
  %not_max.not.i805 = icmp eq i64 %qalloc.i804, -1
  br i1 %not_max.not.i805, label %id_bb.i808, label %reset_bb.i806

mask_block_err.i802:                              ; preds = %__hugr__.array.__read_bool.3.85.exit.1
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

reset_bb.i806:                                    ; preds = %__barray_check_none_borrowed.exit803
  call void @___reset(i64 %qalloc.i804)
  br label %id_bb.i808

id_bb.i808:                                       ; preds = %reset_bb.i806, %__barray_check_none_borrowed.exit803
  %85 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i804, 1
  %86 = select i1 %not_max.not.i805, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %85
  %.fca.0.extract.i807 = extractvalue { i1, i64 } %86, 0
  br i1 %.fca.0.extract.i807, label %__hugr__.__tk2_qalloc.90.exit811, label %cond_94_case_0.i810

cond_94_case_0.i810:                              ; preds = %id_bb.i808
  call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.90.exit811:                 ; preds = %id_bb.i808
  %.fca.1.extract.i809 = extractvalue { i1, i64 } %86, 1
  %qalloc.i812 = call i64 @___qalloc()
  %not_max.not.i813 = icmp eq i64 %qalloc.i812, -1
  br i1 %not_max.not.i813, label %id_bb.i816, label %reset_bb.i814

reset_bb.i814:                                    ; preds = %__hugr__.__tk2_qalloc.90.exit811
  call void @___reset(i64 %qalloc.i812)
  br label %id_bb.i816

id_bb.i816:                                       ; preds = %reset_bb.i814, %__hugr__.__tk2_qalloc.90.exit811
  %87 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i812, 1
  %88 = select i1 %not_max.not.i813, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %87
  %.fca.0.extract.i815 = extractvalue { i1, i64 } %88, 0
  br i1 %.fca.0.extract.i815, label %__hugr__.__tk2_qalloc.90.exit819, label %cond_94_case_0.i818

cond_94_case_0.i818:                              ; preds = %id_bb.i816
  call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.90.exit819:                 ; preds = %id_bb.i816
  %.fca.1.extract.i817 = extractvalue { i1, i64 } %88, 1
  call void @___rxy(i64 %.fca.1.extract.i817, double 0x400921FB54442D18, double 0.000000e+00)
  call void @___rxy(i64 %.fca.1.extract.i817, double 0xBFF921FB54442D18, double 0x400921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i809, double 0x400921FB54442D18, double 0x400921FB54442D18)
  call void @___rzz(i64 %.fca.1.extract.i809, i64 %.fca.1.extract.i817, double 0x3FF921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i817, double 0xBFF921FB54442D18, double 0xBFF921FB54442D18)
  call void @___rz(i64 %.fca.1.extract.i817, double 0x3FF921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i809, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %.fca.1.extract.i809, double 0xBFF921FB54442D18)
  %lazy_measure103 = call i64 @___lazy_measure(i64 %.fca.1.extract.i809)
  call void @___qfree(i64 %.fca.1.extract.i809)
  call void @___rxy(i64 %.fca.1.extract.i817, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure109 = call i64 @___lazy_measure(i64 %.fca.1.extract.i817)
  call void @___qfree(i64 %.fca.1.extract.i817)
  %"29_0112.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure103, 1
  %"30_0113.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure109, 1
  %89 = call i8* @heap_alloc(i64 48)
  %90 = bitcast i8* %89 to { i1, i64, i1 }*
  %91 = call i8* @heap_alloc(i64 8)
  %92 = bitcast i8* %91 to i64*
  store i64 0, i64* %92, align 1
  store { i1, i64, i1 } %"29_0112.fca.1.insert", { i1, i64, i1 }* %90, align 4
  %93 = getelementptr inbounds i8, i8* %89, i64 24
  %94 = bitcast i8* %93 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"30_0113.fca.1.insert", { i1, i64, i1 }* %94, align 4
  %95 = call i8* @heap_alloc(i64 64)
  %96 = call i8* @heap_alloc(i64 8)
  %97 = bitcast i8* %96 to i64*
  store i64 0, i64* %97, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(64) %95, i8 0, i64 64, i1 false)
  %98 = load i64, i64* %92, align 4
  %99 = and i64 %98, 3
  store i64 %99, i64* %92, align 4
  %100 = icmp eq i64 %99, 0
  br i1 %100, label %__barray_check_none_borrowed.exit826, label %mask_block_err.i825

__barray_check_none_borrowed.exit826:             ; preds = %__hugr__.__tk2_qalloc.90.exit819
  %101 = call i8* @heap_alloc(i64 48)
  %102 = bitcast i8* %101 to { i1, i64, i1 }*
  %103 = call i8* @heap_alloc(i64 8)
  %104 = bitcast i8* %103 to i64*
  store i64 0, i64* %104, align 1
  %105 = bitcast i8* %95 to { i1, { i1, i64, i1 } }*
  %106 = load { i1, i64, i1 }, { i1, i64, i1 }* %90, align 4
  %.fca.0.extract118.i827 = extractvalue { i1, i64, i1 } %106, 0
  %.fca.1.extract119.i828 = extractvalue { i1, i64, i1 } %106, 1
  br i1 %.fca.0.extract118.i827, label %cond_518_case_1.i, label %108

mask_block_err.i825:                              ; preds = %__hugr__.__tk2_qalloc.90.exit819
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_518_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit826
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i828)
  %107 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i828, 1
  br label %108

108:                                              ; preds = %__barray_check_none_borrowed.exit826, %cond_518_case_1.i
  %.pn.i829 = phi { i1, i64, i1 } [ %107, %cond_518_case_1.i ], [ %106, %__barray_check_none_borrowed.exit826 ]
  %109 = load i64, i64* %97, align 4
  %110 = and i64 %109, 1
  %.not.i.i831 = icmp eq i64 %110, 0
  br i1 %.not.i.i831, label %cond_521_case_1.i, label %panic.i.i832

panic.i.i832:                                     ; preds = %118, %108
  call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_521_case_1.i:                                ; preds = %108
  %"04.sroa.6.0.i830" = extractvalue { i1, i64, i1 } %.pn.i829, 2
  %"17.fca.2.insert.i833" = insertvalue { i1, i64, i1 } %106, i1 %"04.sroa.6.0.i830", 2
  %111 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i833", 1
  %112 = bitcast i8* %95 to i1*
  %113 = load i1, i1* %112, align 1
  store { i1, { i1, i64, i1 } } %111, { i1, { i1, i64, i1 } }* %105, align 4
  br i1 %113, label %cond_522_case_1.i, label %__hugr__.const_fun_185.182.exit

cond_522_case_1.i:                                ; preds = %cond_521_case_1.i.1, %cond_521_case_1.i
  call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_185.182.exit:                  ; preds = %cond_521_case_1.i
  store { i1, i64, i1 } %"17.fca.2.insert.i833", { i1, i64, i1 }* %102, align 4
  %114 = getelementptr inbounds i8, i8* %89, i64 24
  %115 = bitcast i8* %114 to { i1, i64, i1 }*
  %116 = load { i1, i64, i1 }, { i1, i64, i1 }* %115, align 4
  %.fca.0.extract118.i827.1 = extractvalue { i1, i64, i1 } %116, 0
  %.fca.1.extract119.i828.1 = extractvalue { i1, i64, i1 } %116, 1
  br i1 %.fca.0.extract118.i827.1, label %cond_518_case_1.i.1, label %118

cond_518_case_1.i.1:                              ; preds = %__hugr__.const_fun_185.182.exit
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i828.1)
  %117 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i828.1, 1
  br label %118

118:                                              ; preds = %__hugr__.const_fun_185.182.exit, %cond_518_case_1.i.1
  %.pn.i829.1 = phi { i1, i64, i1 } [ %117, %cond_518_case_1.i.1 ], [ %116, %__hugr__.const_fun_185.182.exit ]
  %119 = load i64, i64* %97, align 4
  %120 = and i64 %119, 2
  %.not.i.i831.1 = icmp eq i64 %120, 0
  br i1 %.not.i.i831.1, label %cond_521_case_1.i.1, label %panic.i.i832

cond_521_case_1.i.1:                              ; preds = %118
  %"04.sroa.6.0.i830.1" = extractvalue { i1, i64, i1 } %.pn.i829.1, 2
  %"17.fca.2.insert.i833.1" = insertvalue { i1, i64, i1 } %116, i1 %"04.sroa.6.0.i830.1", 2
  %121 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i833.1", 1
  %122 = getelementptr inbounds i8, i8* %95, i64 32
  %123 = bitcast i8* %122 to { i1, { i1, i64, i1 } }*
  %124 = bitcast i8* %122 to i1*
  %125 = load i1, i1* %124, align 1
  store { i1, { i1, i64, i1 } } %121, { i1, { i1, i64, i1 } }* %123, align 4
  br i1 %125, label %cond_522_case_1.i, label %__hugr__.const_fun_185.182.exit.1

__hugr__.const_fun_185.182.exit.1:                ; preds = %cond_521_case_1.i.1
  %126 = getelementptr inbounds i8, i8* %101, i64 24
  %127 = bitcast i8* %126 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"17.fca.2.insert.i833.1", { i1, i64, i1 }* %127, align 4
  call void @heap_free(i8* nonnull %89)
  call void @heap_free(i8* nonnull %91)
  %128 = load i64, i64* %97, align 4
  %129 = and i64 %128, 3
  store i64 %129, i64* %97, align 4
  %130 = icmp eq i64 %129, 0
  br i1 %130, label %__barray_check_none_borrowed.exit843, label %mask_block_err.i842

__barray_check_none_borrowed.exit843:             ; preds = %__hugr__.const_fun_185.182.exit.1
  %131 = call i8* @heap_alloc(i64 48)
  %132 = bitcast i8* %131 to { i1, i64, i1 }*
  %133 = call i8* @heap_alloc(i64 8)
  %134 = bitcast i8* %133 to i64*
  store i64 0, i64* %134, align 1
  %135 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %105, align 4
  %.fca.0.extract11.i844 = extractvalue { i1, { i1, i64, i1 } } %135, 0
  br i1 %.fca.0.extract11.i844, label %__hugr__.const_fun_190.185.exit, label %cond_563_case_0.i

mask_block_err.i842:                              ; preds = %__hugr__.const_fun_185.182.exit.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_563_case_0.i:                                ; preds = %__hugr__.const_fun_190.185.exit, %__barray_check_none_borrowed.exit843
  call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_190.185.exit:                  ; preds = %__barray_check_none_borrowed.exit843
  %136 = extractvalue { i1, { i1, i64, i1 } } %135, 1
  store { i1, i64, i1 } %136, { i1, i64, i1 }* %132, align 4
  %137 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %123, align 4
  %.fca.0.extract11.i844.1 = extractvalue { i1, { i1, i64, i1 } } %137, 0
  br i1 %.fca.0.extract11.i844.1, label %__hugr__.const_fun_190.185.exit.1, label %cond_563_case_0.i

__hugr__.const_fun_190.185.exit.1:                ; preds = %__hugr__.const_fun_190.185.exit
  %138 = extractvalue { i1, { i1, i64, i1 } } %137, 1
  %139 = getelementptr inbounds i8, i8* %131, i64 24
  %140 = bitcast i8* %139 to { i1, i64, i1 }*
  store { i1, i64, i1 } %138, { i1, i64, i1 }* %140, align 4
  call void @heap_free(i8* nonnull %95)
  call void @heap_free(i8* nonnull %96)
  %141 = load i64, i64* %134, align 4
  %142 = and i64 %141, 1
  %.not1006 = icmp eq i64 %142, 0
  br i1 %.not1006, label %__barray_mask_borrow.exit852, label %cond_exit_316

mask_block_err.i848:                              ; preds = %cond_exit_316.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit852:                     ; preds = %__hugr__.const_fun_190.185.exit.1
  %143 = xor i64 %141, 1
  store i64 %143, i64* %134, align 4
  %144 = load { i1, i64, i1 }, { i1, i64, i1 }* %132, align 4
  %.fca.0.extract552 = extractvalue { i1, i64, i1 } %144, 0
  br i1 %.fca.0.extract552, label %cond_339_case_1, label %cond_exit_316

cond_exit_316:                                    ; preds = %cond_339_case_1, %__barray_mask_borrow.exit852, %__hugr__.const_fun_190.185.exit.1
  %145 = load i64, i64* %134, align 4
  %146 = and i64 %145, 2
  %.not1006.1 = icmp eq i64 %146, 0
  br i1 %.not1006.1, label %__barray_mask_borrow.exit852.1, label %cond_exit_316.1

__barray_mask_borrow.exit852.1:                   ; preds = %cond_exit_316
  %147 = xor i64 %145, 2
  store i64 %147, i64* %134, align 4
  %148 = getelementptr inbounds i8, i8* %131, i64 24
  %149 = bitcast i8* %148 to { i1, i64, i1 }*
  %150 = load { i1, i64, i1 }, { i1, i64, i1 }* %149, align 4
  %.fca.0.extract552.1 = extractvalue { i1, i64, i1 } %150, 0
  br i1 %.fca.0.extract552.1, label %cond_339_case_1.1, label %cond_exit_316.1

cond_339_case_1.1:                                ; preds = %__barray_mask_borrow.exit852.1
  %.fca.1.extract553.1 = extractvalue { i1, i64, i1 } %150, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract553.1)
  br label %cond_exit_316.1

cond_exit_316.1:                                  ; preds = %cond_339_case_1.1, %__barray_mask_borrow.exit852.1, %cond_exit_316
  %151 = load i64, i64* %134, align 4
  %152 = or i64 %151, -4
  store i64 %152, i64* %134, align 4
  %153 = icmp eq i64 %152, -1
  br i1 %153, label %loop_out137, label %mask_block_err.i848

loop_out137:                                      ; preds = %cond_exit_316.1
  call void @heap_free(i8* %131)
  call void @heap_free(i8* nonnull %133)
  %154 = load i64, i64* %104, align 4
  %155 = and i64 %154, 3
  store i64 %155, i64* %104, align 4
  %156 = icmp eq i64 %155, 0
  br i1 %156, label %__barray_check_none_borrowed.exit857, label %mask_block_err.i856

__barray_check_none_borrowed.exit857:             ; preds = %loop_out137
  %157 = call i8* @heap_alloc(i64 2)
  %158 = call i8* @heap_alloc(i64 8)
  %159 = bitcast i8* %158 to i64*
  store i64 0, i64* %159, align 1
  %160 = load { i1, i64, i1 }, { i1, i64, i1 }* %102, align 4
  %.fca.0.extract.i858 = extractvalue { i1, i64, i1 } %160, 0
  %.fca.1.extract.i859 = extractvalue { i1, i64, i1 } %160, 1
  br i1 %.fca.0.extract.i858, label %cond_244_case_1.i863, label %cond_244_case_0.i861

mask_block_err.i856:                              ; preds = %loop_out137
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_339_case_1:                                  ; preds = %__barray_mask_borrow.exit852
  %.fca.1.extract553 = extractvalue { i1, i64, i1 } %144, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract553)
  br label %cond_exit_316

cond_244_case_0.i861:                             ; preds = %__barray_check_none_borrowed.exit857
  %.fca.2.extract.i860 = extractvalue { i1, i64, i1 } %160, 2
  br label %__hugr__.array.__read_bool.3.85.exit865

cond_244_case_1.i863:                             ; preds = %__barray_check_none_borrowed.exit857
  %read_bool.i862 = call i1 @___read_future_bool(i64 %.fca.1.extract.i859)
  call void @___dec_future_refcount(i64 %.fca.1.extract.i859)
  br label %__hugr__.array.__read_bool.3.85.exit865

__hugr__.array.__read_bool.3.85.exit865:          ; preds = %cond_244_case_0.i861, %cond_244_case_1.i863
  %"03.0.i864" = phi i1 [ %read_bool.i862, %cond_244_case_1.i863 ], [ %.fca.2.extract.i860, %cond_244_case_0.i861 ]
  %161 = bitcast i8* %157 to i1*
  store i1 %"03.0.i864", i1* %161, align 1
  %162 = load { i1, i64, i1 }, { i1, i64, i1 }* %127, align 4
  %.fca.0.extract.i858.1 = extractvalue { i1, i64, i1 } %162, 0
  %.fca.1.extract.i859.1 = extractvalue { i1, i64, i1 } %162, 1
  br i1 %.fca.0.extract.i858.1, label %cond_244_case_1.i863.1, label %cond_244_case_0.i861.1

cond_244_case_0.i861.1:                           ; preds = %__hugr__.array.__read_bool.3.85.exit865
  %.fca.2.extract.i860.1 = extractvalue { i1, i64, i1 } %162, 2
  br label %__hugr__.array.__read_bool.3.85.exit865.1

cond_244_case_1.i863.1:                           ; preds = %__hugr__.array.__read_bool.3.85.exit865
  %read_bool.i862.1 = call i1 @___read_future_bool(i64 %.fca.1.extract.i859.1)
  call void @___dec_future_refcount(i64 %.fca.1.extract.i859.1)
  br label %__hugr__.array.__read_bool.3.85.exit865.1

__hugr__.array.__read_bool.3.85.exit865.1:        ; preds = %cond_244_case_1.i863.1, %cond_244_case_0.i861.1
  %"03.0.i864.1" = phi i1 [ %read_bool.i862.1, %cond_244_case_1.i863.1 ], [ %.fca.2.extract.i860.1, %cond_244_case_0.i861.1 ]
  %163 = getelementptr inbounds i8, i8* %157, i64 1
  %164 = bitcast i8* %163 to i1*
  store i1 %"03.0.i864.1", i1* %164, align 1
  call void @heap_free(i8* nonnull %101)
  call void @heap_free(i8* nonnull %103)
  %165 = load i64, i64* %159, align 4
  %166 = and i64 %165, 3
  store i64 %166, i64* %159, align 4
  %167 = icmp eq i64 %166, 0
  br i1 %167, label %__barray_check_none_borrowed.exit870, label %mask_block_err.i869

__barray_check_none_borrowed.exit870:             ; preds = %__hugr__.array.__read_bool.3.85.exit865.1
  %out_arr_alloca204 = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr205 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca204, i64 0, i32 0
  %y_ptr206 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca204, i64 0, i32 1
  %arr_ptr207 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca204, i64 0, i32 2
  %mask_ptr208 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca204, i64 0, i32 3
  %168 = alloca [2 x i1], align 1
  %.sub678 = getelementptr inbounds [2 x i1], [2 x i1]* %168, i64 0, i64 0
  store i1 false, i1* %.sub678, align 1
  %.repack680 = getelementptr inbounds [2 x i1], [2 x i1]* %168, i64 0, i64 1
  store i1 false, i1* %.repack680, align 1
  store i32 2, i32* %x_ptr205, align 8
  store i32 1, i32* %y_ptr206, align 4
  %169 = bitcast i1** %arr_ptr207 to i8**
  store i8* %157, i8** %169, align 8
  store i1* %.sub678, i1** %mask_ptr208, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @res_01.2F21FB33.0, i64 0, i64 0), i64 15, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca204)
  %qalloc.i871 = call i64 @___qalloc()
  %not_max.not.i872 = icmp eq i64 %qalloc.i871, -1
  br i1 %not_max.not.i872, label %id_bb.i875, label %reset_bb.i873

mask_block_err.i869:                              ; preds = %__hugr__.array.__read_bool.3.85.exit865.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

reset_bb.i873:                                    ; preds = %__barray_check_none_borrowed.exit870
  call void @___reset(i64 %qalloc.i871)
  br label %id_bb.i875

id_bb.i875:                                       ; preds = %reset_bb.i873, %__barray_check_none_borrowed.exit870
  %170 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i871, 1
  %171 = select i1 %not_max.not.i872, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %170
  %.fca.0.extract.i874 = extractvalue { i1, i64 } %171, 0
  br i1 %.fca.0.extract.i874, label %__hugr__.__tk2_qalloc.90.exit878, label %cond_94_case_0.i877

cond_94_case_0.i877:                              ; preds = %id_bb.i875
  call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.90.exit878:                 ; preds = %id_bb.i875
  %.fca.1.extract.i876 = extractvalue { i1, i64 } %171, 1
  call void @___rxy(i64 %.fca.1.extract.i876, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i879 = call i64 @___qalloc()
  %not_max.not.i880 = icmp eq i64 %qalloc.i879, -1
  br i1 %not_max.not.i880, label %id_bb.i883, label %reset_bb.i881

reset_bb.i881:                                    ; preds = %__hugr__.__tk2_qalloc.90.exit878
  call void @___reset(i64 %qalloc.i879)
  br label %id_bb.i883

id_bb.i883:                                       ; preds = %reset_bb.i881, %__hugr__.__tk2_qalloc.90.exit878
  %172 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i879, 1
  %173 = select i1 %not_max.not.i880, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %172
  %.fca.0.extract.i882 = extractvalue { i1, i64 } %173, 0
  br i1 %.fca.0.extract.i882, label %__hugr__.__tk2_qalloc.90.exit886, label %cond_94_case_0.i885

cond_94_case_0.i885:                              ; preds = %id_bb.i883
  call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.90.exit886:                 ; preds = %id_bb.i883
  %.fca.1.extract.i884 = extractvalue { i1, i64 } %173, 1
  call void @___rxy(i64 %.fca.1.extract.i884, double 0xBFF921FB54442D18, double 0x400921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i876, double 0x400921FB54442D18, double 0x400921FB54442D18)
  call void @___rzz(i64 %.fca.1.extract.i876, i64 %.fca.1.extract.i884, double 0x3FF921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i884, double 0xBFF921FB54442D18, double 0xBFF921FB54442D18)
  call void @___rz(i64 %.fca.1.extract.i884, double 0x3FF921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i876, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %.fca.1.extract.i876, double 0xBFF921FB54442D18)
  %lazy_measure214 = call i64 @___lazy_measure(i64 %.fca.1.extract.i876)
  call void @___qfree(i64 %.fca.1.extract.i876)
  call void @___rxy(i64 %.fca.1.extract.i884, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure220 = call i64 @___lazy_measure(i64 %.fca.1.extract.i884)
  call void @___qfree(i64 %.fca.1.extract.i884)
  %"48_0223.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure214, 1
  %"49_0224.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure220, 1
  %174 = call i8* @heap_alloc(i64 48)
  %175 = bitcast i8* %174 to { i1, i64, i1 }*
  %176 = call i8* @heap_alloc(i64 8)
  %177 = bitcast i8* %176 to i64*
  store i64 0, i64* %177, align 1
  store { i1, i64, i1 } %"48_0223.fca.1.insert", { i1, i64, i1 }* %175, align 4
  %178 = getelementptr inbounds i8, i8* %174, i64 24
  %179 = bitcast i8* %178 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"49_0224.fca.1.insert", { i1, i64, i1 }* %179, align 4
  %180 = call i8* @heap_alloc(i64 64)
  %181 = call i8* @heap_alloc(i64 8)
  %182 = bitcast i8* %181 to i64*
  store i64 0, i64* %182, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(64) %180, i8 0, i64 64, i1 false)
  %183 = load i64, i64* %177, align 4
  %184 = and i64 %183, 3
  store i64 %184, i64* %177, align 4
  %185 = icmp eq i64 %184, 0
  br i1 %185, label %__barray_check_none_borrowed.exit893, label %mask_block_err.i892

__barray_check_none_borrowed.exit893:             ; preds = %__hugr__.__tk2_qalloc.90.exit886
  %186 = call i8* @heap_alloc(i64 48)
  %187 = bitcast i8* %186 to { i1, i64, i1 }*
  %188 = call i8* @heap_alloc(i64 8)
  %189 = bitcast i8* %188 to i64*
  store i64 0, i64* %189, align 1
  %190 = bitcast i8* %180 to { i1, { i1, i64, i1 } }*
  %191 = load { i1, i64, i1 }, { i1, i64, i1 }* %175, align 4
  %.fca.0.extract118.i894 = extractvalue { i1, i64, i1 } %191, 0
  %.fca.1.extract119.i895 = extractvalue { i1, i64, i1 } %191, 1
  br i1 %.fca.0.extract118.i894, label %cond_581_case_1.i, label %193

mask_block_err.i892:                              ; preds = %__hugr__.__tk2_qalloc.90.exit886
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_581_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit893
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i895)
  %192 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i895, 1
  br label %193

193:                                              ; preds = %__barray_check_none_borrowed.exit893, %cond_581_case_1.i
  %.pn.i896 = phi { i1, i64, i1 } [ %192, %cond_581_case_1.i ], [ %191, %__barray_check_none_borrowed.exit893 ]
  %194 = load i64, i64* %182, align 4
  %195 = and i64 %194, 1
  %.not.i.i898 = icmp eq i64 %195, 0
  br i1 %.not.i.i898, label %cond_584_case_1.i, label %panic.i.i899

panic.i.i899:                                     ; preds = %203, %193
  call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_584_case_1.i:                                ; preds = %193
  %"04.sroa.6.0.i897" = extractvalue { i1, i64, i1 } %.pn.i896, 2
  %"17.fca.2.insert.i900" = insertvalue { i1, i64, i1 } %191, i1 %"04.sroa.6.0.i897", 2
  %196 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i900", 1
  %197 = bitcast i8* %180 to i1*
  %198 = load i1, i1* %197, align 1
  store { i1, { i1, i64, i1 } } %196, { i1, { i1, i64, i1 } }* %190, align 4
  br i1 %198, label %cond_585_case_1.i, label %__hugr__.const_fun_209.206.exit

cond_585_case_1.i:                                ; preds = %cond_584_case_1.i.1, %cond_584_case_1.i
  call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_209.206.exit:                  ; preds = %cond_584_case_1.i
  store { i1, i64, i1 } %"17.fca.2.insert.i900", { i1, i64, i1 }* %187, align 4
  %199 = getelementptr inbounds i8, i8* %174, i64 24
  %200 = bitcast i8* %199 to { i1, i64, i1 }*
  %201 = load { i1, i64, i1 }, { i1, i64, i1 }* %200, align 4
  %.fca.0.extract118.i894.1 = extractvalue { i1, i64, i1 } %201, 0
  %.fca.1.extract119.i895.1 = extractvalue { i1, i64, i1 } %201, 1
  br i1 %.fca.0.extract118.i894.1, label %cond_581_case_1.i.1, label %203

cond_581_case_1.i.1:                              ; preds = %__hugr__.const_fun_209.206.exit
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i895.1)
  %202 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i895.1, 1
  br label %203

203:                                              ; preds = %__hugr__.const_fun_209.206.exit, %cond_581_case_1.i.1
  %.pn.i896.1 = phi { i1, i64, i1 } [ %202, %cond_581_case_1.i.1 ], [ %201, %__hugr__.const_fun_209.206.exit ]
  %204 = load i64, i64* %182, align 4
  %205 = and i64 %204, 2
  %.not.i.i898.1 = icmp eq i64 %205, 0
  br i1 %.not.i.i898.1, label %cond_584_case_1.i.1, label %panic.i.i899

cond_584_case_1.i.1:                              ; preds = %203
  %"04.sroa.6.0.i897.1" = extractvalue { i1, i64, i1 } %.pn.i896.1, 2
  %"17.fca.2.insert.i900.1" = insertvalue { i1, i64, i1 } %201, i1 %"04.sroa.6.0.i897.1", 2
  %206 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i900.1", 1
  %207 = getelementptr inbounds i8, i8* %180, i64 32
  %208 = bitcast i8* %207 to { i1, { i1, i64, i1 } }*
  %209 = bitcast i8* %207 to i1*
  %210 = load i1, i1* %209, align 1
  store { i1, { i1, i64, i1 } } %206, { i1, { i1, i64, i1 } }* %208, align 4
  br i1 %210, label %cond_585_case_1.i, label %__hugr__.const_fun_209.206.exit.1

__hugr__.const_fun_209.206.exit.1:                ; preds = %cond_584_case_1.i.1
  %211 = getelementptr inbounds i8, i8* %186, i64 24
  %212 = bitcast i8* %211 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"17.fca.2.insert.i900.1", { i1, i64, i1 }* %212, align 4
  call void @heap_free(i8* nonnull %174)
  call void @heap_free(i8* nonnull %176)
  %213 = load i64, i64* %182, align 4
  %214 = and i64 %213, 3
  store i64 %214, i64* %182, align 4
  %215 = icmp eq i64 %214, 0
  br i1 %215, label %__barray_check_none_borrowed.exit910, label %mask_block_err.i909

__barray_check_none_borrowed.exit910:             ; preds = %__hugr__.const_fun_209.206.exit.1
  %216 = call i8* @heap_alloc(i64 48)
  %217 = bitcast i8* %216 to { i1, i64, i1 }*
  %218 = call i8* @heap_alloc(i64 8)
  %219 = bitcast i8* %218 to i64*
  store i64 0, i64* %219, align 1
  %220 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %190, align 4
  %.fca.0.extract11.i911 = extractvalue { i1, { i1, i64, i1 } } %220, 0
  br i1 %.fca.0.extract11.i911, label %__hugr__.const_fun_214.209.exit, label %cond_626_case_0.i

mask_block_err.i909:                              ; preds = %__hugr__.const_fun_209.206.exit.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_626_case_0.i:                                ; preds = %__hugr__.const_fun_214.209.exit, %__barray_check_none_borrowed.exit910
  call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_214.209.exit:                  ; preds = %__barray_check_none_borrowed.exit910
  %221 = extractvalue { i1, { i1, i64, i1 } } %220, 1
  store { i1, i64, i1 } %221, { i1, i64, i1 }* %217, align 4
  %222 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %208, align 4
  %.fca.0.extract11.i911.1 = extractvalue { i1, { i1, i64, i1 } } %222, 0
  br i1 %.fca.0.extract11.i911.1, label %__hugr__.const_fun_214.209.exit.1, label %cond_626_case_0.i

__hugr__.const_fun_214.209.exit.1:                ; preds = %__hugr__.const_fun_214.209.exit
  %223 = extractvalue { i1, { i1, i64, i1 } } %222, 1
  %224 = getelementptr inbounds i8, i8* %216, i64 24
  %225 = bitcast i8* %224 to { i1, i64, i1 }*
  store { i1, i64, i1 } %223, { i1, i64, i1 }* %225, align 4
  call void @heap_free(i8* nonnull %180)
  call void @heap_free(i8* nonnull %181)
  %226 = load i64, i64* %219, align 4
  %227 = and i64 %226, 1
  %.not1005 = icmp eq i64 %227, 0
  br i1 %.not1005, label %__barray_mask_borrow.exit919, label %cond_exit_365

mask_block_err.i915:                              ; preds = %cond_exit_365.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit919:                     ; preds = %__hugr__.const_fun_214.209.exit.1
  %228 = xor i64 %226, 1
  store i64 %228, i64* %219, align 4
  %229 = load { i1, i64, i1 }, { i1, i64, i1 }* %217, align 4
  %.fca.0.extract502 = extractvalue { i1, i64, i1 } %229, 0
  br i1 %.fca.0.extract502, label %cond_388_case_1, label %cond_exit_365

cond_exit_365:                                    ; preds = %cond_388_case_1, %__barray_mask_borrow.exit919, %__hugr__.const_fun_214.209.exit.1
  %230 = load i64, i64* %219, align 4
  %231 = and i64 %230, 2
  %.not1005.1 = icmp eq i64 %231, 0
  br i1 %.not1005.1, label %__barray_mask_borrow.exit919.1, label %cond_exit_365.1

__barray_mask_borrow.exit919.1:                   ; preds = %cond_exit_365
  %232 = xor i64 %230, 2
  store i64 %232, i64* %219, align 4
  %233 = getelementptr inbounds i8, i8* %216, i64 24
  %234 = bitcast i8* %233 to { i1, i64, i1 }*
  %235 = load { i1, i64, i1 }, { i1, i64, i1 }* %234, align 4
  %.fca.0.extract502.1 = extractvalue { i1, i64, i1 } %235, 0
  br i1 %.fca.0.extract502.1, label %cond_388_case_1.1, label %cond_exit_365.1

cond_388_case_1.1:                                ; preds = %__barray_mask_borrow.exit919.1
  %.fca.1.extract503.1 = extractvalue { i1, i64, i1 } %235, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract503.1)
  br label %cond_exit_365.1

cond_exit_365.1:                                  ; preds = %cond_388_case_1.1, %__barray_mask_borrow.exit919.1, %cond_exit_365
  %236 = load i64, i64* %219, align 4
  %237 = or i64 %236, -4
  store i64 %237, i64* %219, align 4
  %238 = icmp eq i64 %237, -1
  br i1 %238, label %loop_out248, label %mask_block_err.i915

loop_out248:                                      ; preds = %cond_exit_365.1
  call void @heap_free(i8* %216)
  call void @heap_free(i8* nonnull %218)
  %239 = load i64, i64* %189, align 4
  %240 = and i64 %239, 3
  store i64 %240, i64* %189, align 4
  %241 = icmp eq i64 %240, 0
  br i1 %241, label %__barray_check_none_borrowed.exit924, label %mask_block_err.i923

__barray_check_none_borrowed.exit924:             ; preds = %loop_out248
  %242 = call i8* @heap_alloc(i64 2)
  %243 = call i8* @heap_alloc(i64 8)
  %244 = bitcast i8* %243 to i64*
  store i64 0, i64* %244, align 1
  %245 = load { i1, i64, i1 }, { i1, i64, i1 }* %187, align 4
  %.fca.0.extract.i925 = extractvalue { i1, i64, i1 } %245, 0
  %.fca.1.extract.i926 = extractvalue { i1, i64, i1 } %245, 1
  br i1 %.fca.0.extract.i925, label %cond_244_case_1.i930, label %cond_244_case_0.i928

mask_block_err.i923:                              ; preds = %loop_out248
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_388_case_1:                                  ; preds = %__barray_mask_borrow.exit919
  %.fca.1.extract503 = extractvalue { i1, i64, i1 } %229, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract503)
  br label %cond_exit_365

cond_244_case_0.i928:                             ; preds = %__barray_check_none_borrowed.exit924
  %.fca.2.extract.i927 = extractvalue { i1, i64, i1 } %245, 2
  br label %__hugr__.array.__read_bool.3.85.exit932

cond_244_case_1.i930:                             ; preds = %__barray_check_none_borrowed.exit924
  %read_bool.i929 = call i1 @___read_future_bool(i64 %.fca.1.extract.i926)
  call void @___dec_future_refcount(i64 %.fca.1.extract.i926)
  br label %__hugr__.array.__read_bool.3.85.exit932

__hugr__.array.__read_bool.3.85.exit932:          ; preds = %cond_244_case_0.i928, %cond_244_case_1.i930
  %"03.0.i931" = phi i1 [ %read_bool.i929, %cond_244_case_1.i930 ], [ %.fca.2.extract.i927, %cond_244_case_0.i928 ]
  %246 = bitcast i8* %242 to i1*
  store i1 %"03.0.i931", i1* %246, align 1
  %247 = load { i1, i64, i1 }, { i1, i64, i1 }* %212, align 4
  %.fca.0.extract.i925.1 = extractvalue { i1, i64, i1 } %247, 0
  %.fca.1.extract.i926.1 = extractvalue { i1, i64, i1 } %247, 1
  br i1 %.fca.0.extract.i925.1, label %cond_244_case_1.i930.1, label %cond_244_case_0.i928.1

cond_244_case_0.i928.1:                           ; preds = %__hugr__.array.__read_bool.3.85.exit932
  %.fca.2.extract.i927.1 = extractvalue { i1, i64, i1 } %247, 2
  br label %__hugr__.array.__read_bool.3.85.exit932.1

cond_244_case_1.i930.1:                           ; preds = %__hugr__.array.__read_bool.3.85.exit932
  %read_bool.i929.1 = call i1 @___read_future_bool(i64 %.fca.1.extract.i926.1)
  call void @___dec_future_refcount(i64 %.fca.1.extract.i926.1)
  br label %__hugr__.array.__read_bool.3.85.exit932.1

__hugr__.array.__read_bool.3.85.exit932.1:        ; preds = %cond_244_case_1.i930.1, %cond_244_case_0.i928.1
  %"03.0.i931.1" = phi i1 [ %read_bool.i929.1, %cond_244_case_1.i930.1 ], [ %.fca.2.extract.i927.1, %cond_244_case_0.i928.1 ]
  %248 = getelementptr inbounds i8, i8* %242, i64 1
  %249 = bitcast i8* %248 to i1*
  store i1 %"03.0.i931.1", i1* %249, align 1
  call void @heap_free(i8* nonnull %186)
  call void @heap_free(i8* nonnull %188)
  %250 = load i64, i64* %244, align 4
  %251 = and i64 %250, 3
  store i64 %251, i64* %244, align 4
  %252 = icmp eq i64 %251, 0
  br i1 %252, label %__barray_check_none_borrowed.exit937, label %mask_block_err.i936

__barray_check_none_borrowed.exit937:             ; preds = %__hugr__.array.__read_bool.3.85.exit932.1
  %out_arr_alloca315 = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr316 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca315, i64 0, i32 0
  %y_ptr317 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca315, i64 0, i32 1
  %arr_ptr318 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca315, i64 0, i32 2
  %mask_ptr319 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca315, i64 0, i32 3
  %253 = alloca [2 x i1], align 1
  %.sub693 = getelementptr inbounds [2 x i1], [2 x i1]* %253, i64 0, i64 0
  store i1 false, i1* %.sub693, align 1
  %.repack695 = getelementptr inbounds [2 x i1], [2 x i1]* %253, i64 0, i64 1
  store i1 false, i1* %.repack695, align 1
  store i32 2, i32* %x_ptr316, align 8
  store i32 1, i32* %y_ptr317, align 4
  %254 = bitcast i1** %arr_ptr318 to i8**
  store i8* %242, i8** %254, align 8
  store i1* %.sub693, i1** %mask_ptr319, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @res_10.90CD55C3.0, i64 0, i64 0), i64 15, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca315)
  %qalloc.i938 = call i64 @___qalloc()
  %not_max.not.i939 = icmp eq i64 %qalloc.i938, -1
  br i1 %not_max.not.i939, label %id_bb.i942, label %reset_bb.i940

mask_block_err.i936:                              ; preds = %__hugr__.array.__read_bool.3.85.exit932.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

reset_bb.i940:                                    ; preds = %__barray_check_none_borrowed.exit937
  call void @___reset(i64 %qalloc.i938)
  br label %id_bb.i942

id_bb.i942:                                       ; preds = %reset_bb.i940, %__barray_check_none_borrowed.exit937
  %255 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i938, 1
  %256 = select i1 %not_max.not.i939, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %255
  %.fca.0.extract.i941 = extractvalue { i1, i64 } %256, 0
  br i1 %.fca.0.extract.i941, label %__hugr__.__tk2_qalloc.90.exit945, label %cond_94_case_0.i944

cond_94_case_0.i944:                              ; preds = %id_bb.i942
  call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.90.exit945:                 ; preds = %id_bb.i942
  %.fca.1.extract.i943 = extractvalue { i1, i64 } %256, 1
  call void @___rxy(i64 %.fca.1.extract.i943, double 0x400921FB54442D18, double 0.000000e+00)
  %qalloc.i946 = call i64 @___qalloc()
  %not_max.not.i947 = icmp eq i64 %qalloc.i946, -1
  br i1 %not_max.not.i947, label %id_bb.i950, label %reset_bb.i948

reset_bb.i948:                                    ; preds = %__hugr__.__tk2_qalloc.90.exit945
  call void @___reset(i64 %qalloc.i946)
  br label %id_bb.i950

id_bb.i950:                                       ; preds = %reset_bb.i948, %__hugr__.__tk2_qalloc.90.exit945
  %257 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i946, 1
  %258 = select i1 %not_max.not.i947, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %257
  %.fca.0.extract.i949 = extractvalue { i1, i64 } %258, 0
  br i1 %.fca.0.extract.i949, label %__hugr__.__tk2_qalloc.90.exit953, label %cond_94_case_0.i952

cond_94_case_0.i952:                              ; preds = %id_bb.i950
  call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.90.exit953:                 ; preds = %id_bb.i950
  %.fca.1.extract.i951 = extractvalue { i1, i64 } %258, 1
  call void @___rxy(i64 %.fca.1.extract.i951, double 0x400921FB54442D18, double 0.000000e+00)
  call void @___rxy(i64 %.fca.1.extract.i951, double 0xBFF921FB54442D18, double 0x400921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i943, double 0x400921FB54442D18, double 0x400921FB54442D18)
  call void @___rzz(i64 %.fca.1.extract.i943, i64 %.fca.1.extract.i951, double 0x3FF921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i951, double 0xBFF921FB54442D18, double 0xBFF921FB54442D18)
  call void @___rz(i64 %.fca.1.extract.i951, double 0x3FF921FB54442D18)
  call void @___rxy(i64 %.fca.1.extract.i943, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  call void @___rz(i64 %.fca.1.extract.i943, double 0xBFF921FB54442D18)
  %lazy_measure326 = call i64 @___lazy_measure(i64 %.fca.1.extract.i943)
  call void @___qfree(i64 %.fca.1.extract.i943)
  call void @___rxy(i64 %.fca.1.extract.i951, double 0x400921FB54442D18, double 0x3FF921FB54442D18)
  %lazy_measure332 = call i64 @___lazy_measure(i64 %.fca.1.extract.i951)
  call void @___qfree(i64 %.fca.1.extract.i951)
  %"69_0335.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure326, 1
  %"70_0336.fca.1.insert" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure332, 1
  %259 = call i8* @heap_alloc(i64 48)
  %260 = bitcast i8* %259 to { i1, i64, i1 }*
  %261 = call i8* @heap_alloc(i64 8)
  %262 = bitcast i8* %261 to i64*
  store i64 0, i64* %262, align 1
  store { i1, i64, i1 } %"69_0335.fca.1.insert", { i1, i64, i1 }* %260, align 4
  %263 = getelementptr inbounds i8, i8* %259, i64 24
  %264 = bitcast i8* %263 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"70_0336.fca.1.insert", { i1, i64, i1 }* %264, align 4
  %265 = call i8* @heap_alloc(i64 64)
  %266 = call i8* @heap_alloc(i64 8)
  %267 = bitcast i8* %266 to i64*
  store i64 0, i64* %267, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(64) %265, i8 0, i64 64, i1 false)
  %268 = load i64, i64* %262, align 4
  %269 = and i64 %268, 3
  store i64 %269, i64* %262, align 4
  %270 = icmp eq i64 %269, 0
  br i1 %270, label %__barray_check_none_borrowed.exit960, label %mask_block_err.i959

__barray_check_none_borrowed.exit960:             ; preds = %__hugr__.__tk2_qalloc.90.exit953
  %271 = call i8* @heap_alloc(i64 48)
  %272 = bitcast i8* %271 to { i1, i64, i1 }*
  %273 = call i8* @heap_alloc(i64 8)
  %274 = bitcast i8* %273 to i64*
  store i64 0, i64* %274, align 1
  %275 = bitcast i8* %265 to { i1, { i1, i64, i1 } }*
  %276 = load { i1, i64, i1 }, { i1, i64, i1 }* %260, align 4
  %.fca.0.extract118.i961 = extractvalue { i1, i64, i1 } %276, 0
  %.fca.1.extract119.i962 = extractvalue { i1, i64, i1 } %276, 1
  br i1 %.fca.0.extract118.i961, label %cond_644_case_1.i, label %278

mask_block_err.i959:                              ; preds = %__hugr__.__tk2_qalloc.90.exit953
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_644_case_1.i:                                ; preds = %__barray_check_none_borrowed.exit960
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i962)
  %277 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i962, 1
  br label %278

278:                                              ; preds = %__barray_check_none_borrowed.exit960, %cond_644_case_1.i
  %.pn.i963 = phi { i1, i64, i1 } [ %277, %cond_644_case_1.i ], [ %276, %__barray_check_none_borrowed.exit960 ]
  %279 = load i64, i64* %267, align 4
  %280 = and i64 %279, 1
  %.not.i.i965 = icmp eq i64 %280, 0
  br i1 %.not.i.i965, label %cond_647_case_1.i, label %panic.i.i966

panic.i.i966:                                     ; preds = %288, %278
  call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_647_case_1.i:                                ; preds = %278
  %"04.sroa.6.0.i964" = extractvalue { i1, i64, i1 } %.pn.i963, 2
  %"17.fca.2.insert.i967" = insertvalue { i1, i64, i1 } %276, i1 %"04.sroa.6.0.i964", 2
  %281 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i967", 1
  %282 = bitcast i8* %265 to i1*
  %283 = load i1, i1* %282, align 1
  store { i1, { i1, i64, i1 } } %281, { i1, { i1, i64, i1 } }* %275, align 4
  br i1 %283, label %cond_648_case_1.i, label %__hugr__.const_fun_233.230.exit

cond_648_case_1.i:                                ; preds = %cond_647_case_1.i.1, %cond_647_case_1.i
  call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_233.230.exit:                  ; preds = %cond_647_case_1.i
  store { i1, i64, i1 } %"17.fca.2.insert.i967", { i1, i64, i1 }* %272, align 4
  %284 = getelementptr inbounds i8, i8* %259, i64 24
  %285 = bitcast i8* %284 to { i1, i64, i1 }*
  %286 = load { i1, i64, i1 }, { i1, i64, i1 }* %285, align 4
  %.fca.0.extract118.i961.1 = extractvalue { i1, i64, i1 } %286, 0
  %.fca.1.extract119.i962.1 = extractvalue { i1, i64, i1 } %286, 1
  br i1 %.fca.0.extract118.i961.1, label %cond_644_case_1.i.1, label %288

cond_644_case_1.i.1:                              ; preds = %__hugr__.const_fun_233.230.exit
  call void @___inc_future_refcount(i64 %.fca.1.extract119.i962.1)
  %287 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i962.1, 1
  br label %288

288:                                              ; preds = %__hugr__.const_fun_233.230.exit, %cond_644_case_1.i.1
  %.pn.i963.1 = phi { i1, i64, i1 } [ %287, %cond_644_case_1.i.1 ], [ %286, %__hugr__.const_fun_233.230.exit ]
  %289 = load i64, i64* %267, align 4
  %290 = and i64 %289, 2
  %.not.i.i965.1 = icmp eq i64 %290, 0
  br i1 %.not.i.i965.1, label %cond_647_case_1.i.1, label %panic.i.i966

cond_647_case_1.i.1:                              ; preds = %288
  %"04.sroa.6.0.i964.1" = extractvalue { i1, i64, i1 } %.pn.i963.1, 2
  %"17.fca.2.insert.i967.1" = insertvalue { i1, i64, i1 } %286, i1 %"04.sroa.6.0.i964.1", 2
  %291 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"17.fca.2.insert.i967.1", 1
  %292 = getelementptr inbounds i8, i8* %265, i64 32
  %293 = bitcast i8* %292 to { i1, { i1, i64, i1 } }*
  %294 = bitcast i8* %292 to i1*
  %295 = load i1, i1* %294, align 1
  store { i1, { i1, i64, i1 } } %291, { i1, { i1, i64, i1 } }* %293, align 4
  br i1 %295, label %cond_648_case_1.i, label %__hugr__.const_fun_233.230.exit.1

__hugr__.const_fun_233.230.exit.1:                ; preds = %cond_647_case_1.i.1
  %296 = getelementptr inbounds i8, i8* %271, i64 24
  %297 = bitcast i8* %296 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"17.fca.2.insert.i967.1", { i1, i64, i1 }* %297, align 4
  call void @heap_free(i8* nonnull %259)
  call void @heap_free(i8* nonnull %261)
  %298 = load i64, i64* %267, align 4
  %299 = and i64 %298, 3
  store i64 %299, i64* %267, align 4
  %300 = icmp eq i64 %299, 0
  br i1 %300, label %__barray_check_none_borrowed.exit977, label %mask_block_err.i976

__barray_check_none_borrowed.exit977:             ; preds = %__hugr__.const_fun_233.230.exit.1
  %301 = call i8* @heap_alloc(i64 48)
  %302 = bitcast i8* %301 to { i1, i64, i1 }*
  %303 = call i8* @heap_alloc(i64 8)
  %304 = bitcast i8* %303 to i64*
  store i64 0, i64* %304, align 1
  %305 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %275, align 4
  %.fca.0.extract11.i978 = extractvalue { i1, { i1, i64, i1 } } %305, 0
  br i1 %.fca.0.extract11.i978, label %__hugr__.const_fun_238.233.exit, label %cond_689_case_0.i

mask_block_err.i976:                              ; preds = %__hugr__.const_fun_233.230.exit.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_689_case_0.i:                                ; preds = %__hugr__.const_fun_238.233.exit, %__barray_check_none_borrowed.exit977
  call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

__hugr__.const_fun_238.233.exit:                  ; preds = %__barray_check_none_borrowed.exit977
  %306 = extractvalue { i1, { i1, i64, i1 } } %305, 1
  store { i1, i64, i1 } %306, { i1, i64, i1 }* %302, align 4
  %307 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %293, align 4
  %.fca.0.extract11.i978.1 = extractvalue { i1, { i1, i64, i1 } } %307, 0
  br i1 %.fca.0.extract11.i978.1, label %__hugr__.const_fun_238.233.exit.1, label %cond_689_case_0.i

__hugr__.const_fun_238.233.exit.1:                ; preds = %__hugr__.const_fun_238.233.exit
  %308 = extractvalue { i1, { i1, i64, i1 } } %307, 1
  %309 = getelementptr inbounds i8, i8* %301, i64 24
  %310 = bitcast i8* %309 to { i1, i64, i1 }*
  store { i1, i64, i1 } %308, { i1, i64, i1 }* %310, align 4
  call void @heap_free(i8* nonnull %265)
  call void @heap_free(i8* nonnull %266)
  %311 = load i64, i64* %304, align 4
  %312 = and i64 %311, 1
  %.not = icmp eq i64 %312, 0
  br i1 %.not, label %__barray_mask_borrow.exit986, label %cond_exit_414

mask_block_err.i982:                              ; preds = %cond_exit_414.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit986:                     ; preds = %__hugr__.const_fun_238.233.exit.1
  %313 = xor i64 %311, 1
  store i64 %313, i64* %304, align 4
  %314 = load { i1, i64, i1 }, { i1, i64, i1 }* %302, align 4
  %.fca.0.extract452 = extractvalue { i1, i64, i1 } %314, 0
  br i1 %.fca.0.extract452, label %cond_437_case_1, label %cond_exit_414

cond_exit_414:                                    ; preds = %cond_437_case_1, %__barray_mask_borrow.exit986, %__hugr__.const_fun_238.233.exit.1
  %315 = load i64, i64* %304, align 4
  %316 = and i64 %315, 2
  %.not.1 = icmp eq i64 %316, 0
  br i1 %.not.1, label %__barray_mask_borrow.exit986.1, label %cond_exit_414.1

__barray_mask_borrow.exit986.1:                   ; preds = %cond_exit_414
  %317 = xor i64 %315, 2
  store i64 %317, i64* %304, align 4
  %318 = getelementptr inbounds i8, i8* %301, i64 24
  %319 = bitcast i8* %318 to { i1, i64, i1 }*
  %320 = load { i1, i64, i1 }, { i1, i64, i1 }* %319, align 4
  %.fca.0.extract452.1 = extractvalue { i1, i64, i1 } %320, 0
  br i1 %.fca.0.extract452.1, label %cond_437_case_1.1, label %cond_exit_414.1

cond_437_case_1.1:                                ; preds = %__barray_mask_borrow.exit986.1
  %.fca.1.extract453.1 = extractvalue { i1, i64, i1 } %320, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract453.1)
  br label %cond_exit_414.1

cond_exit_414.1:                                  ; preds = %cond_437_case_1.1, %__barray_mask_borrow.exit986.1, %cond_exit_414
  %321 = load i64, i64* %304, align 4
  %322 = or i64 %321, -4
  store i64 %322, i64* %304, align 4
  %323 = icmp eq i64 %322, -1
  br i1 %323, label %loop_out360, label %mask_block_err.i982

loop_out360:                                      ; preds = %cond_exit_414.1
  call void @heap_free(i8* %301)
  call void @heap_free(i8* nonnull %303)
  %324 = load i64, i64* %274, align 4
  %325 = and i64 %324, 3
  store i64 %325, i64* %274, align 4
  %326 = icmp eq i64 %325, 0
  br i1 %326, label %__barray_check_none_borrowed.exit991, label %mask_block_err.i990

__barray_check_none_borrowed.exit991:             ; preds = %loop_out360
  %327 = call i8* @heap_alloc(i64 2)
  %328 = call i8* @heap_alloc(i64 8)
  %329 = bitcast i8* %328 to i64*
  store i64 0, i64* %329, align 1
  %330 = load { i1, i64, i1 }, { i1, i64, i1 }* %272, align 4
  %.fca.0.extract.i992 = extractvalue { i1, i64, i1 } %330, 0
  %.fca.1.extract.i993 = extractvalue { i1, i64, i1 } %330, 1
  br i1 %.fca.0.extract.i992, label %cond_244_case_1.i997, label %cond_244_case_0.i995

mask_block_err.i990:                              ; preds = %loop_out360
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_437_case_1:                                  ; preds = %__barray_mask_borrow.exit986
  %.fca.1.extract453 = extractvalue { i1, i64, i1 } %314, 1
  call void @___dec_future_refcount(i64 %.fca.1.extract453)
  br label %cond_exit_414

cond_244_case_0.i995:                             ; preds = %__barray_check_none_borrowed.exit991
  %.fca.2.extract.i994 = extractvalue { i1, i64, i1 } %330, 2
  br label %__hugr__.array.__read_bool.3.85.exit999

cond_244_case_1.i997:                             ; preds = %__barray_check_none_borrowed.exit991
  %read_bool.i996 = call i1 @___read_future_bool(i64 %.fca.1.extract.i993)
  call void @___dec_future_refcount(i64 %.fca.1.extract.i993)
  br label %__hugr__.array.__read_bool.3.85.exit999

__hugr__.array.__read_bool.3.85.exit999:          ; preds = %cond_244_case_0.i995, %cond_244_case_1.i997
  %"03.0.i998" = phi i1 [ %read_bool.i996, %cond_244_case_1.i997 ], [ %.fca.2.extract.i994, %cond_244_case_0.i995 ]
  %331 = bitcast i8* %327 to i1*
  store i1 %"03.0.i998", i1* %331, align 1
  %332 = load { i1, i64, i1 }, { i1, i64, i1 }* %297, align 4
  %.fca.0.extract.i992.1 = extractvalue { i1, i64, i1 } %332, 0
  %.fca.1.extract.i993.1 = extractvalue { i1, i64, i1 } %332, 1
  br i1 %.fca.0.extract.i992.1, label %cond_244_case_1.i997.1, label %cond_244_case_0.i995.1

cond_244_case_0.i995.1:                           ; preds = %__hugr__.array.__read_bool.3.85.exit999
  %.fca.2.extract.i994.1 = extractvalue { i1, i64, i1 } %332, 2
  br label %__hugr__.array.__read_bool.3.85.exit999.1

cond_244_case_1.i997.1:                           ; preds = %__hugr__.array.__read_bool.3.85.exit999
  %read_bool.i996.1 = call i1 @___read_future_bool(i64 %.fca.1.extract.i993.1)
  call void @___dec_future_refcount(i64 %.fca.1.extract.i993.1)
  br label %__hugr__.array.__read_bool.3.85.exit999.1

__hugr__.array.__read_bool.3.85.exit999.1:        ; preds = %cond_244_case_1.i997.1, %cond_244_case_0.i995.1
  %"03.0.i998.1" = phi i1 [ %read_bool.i996.1, %cond_244_case_1.i997.1 ], [ %.fca.2.extract.i994.1, %cond_244_case_0.i995.1 ]
  %333 = getelementptr inbounds i8, i8* %327, i64 1
  %334 = bitcast i8* %333 to i1*
  store i1 %"03.0.i998.1", i1* %334, align 1
  call void @heap_free(i8* nonnull %271)
  call void @heap_free(i8* nonnull %273)
  %335 = load i64, i64* %329, align 4
  %336 = and i64 %335, 3
  store i64 %336, i64* %329, align 4
  %337 = icmp eq i64 %336, 0
  br i1 %337, label %__barray_check_none_borrowed.exit1004, label %mask_block_err.i1003

__barray_check_none_borrowed.exit1004:            ; preds = %__hugr__.array.__read_bool.3.85.exit999.1
  %out_arr_alloca427 = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr428 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca427, i64 0, i32 0
  %y_ptr429 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca427, i64 0, i32 1
  %arr_ptr430 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca427, i64 0, i32 2
  %mask_ptr431 = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca427, i64 0, i32 3
  %338 = alloca [2 x i1], align 1
  %.sub708 = getelementptr inbounds [2 x i1], [2 x i1]* %338, i64 0, i64 0
  store i1 false, i1* %.sub708, align 1
  %.repack710 = getelementptr inbounds [2 x i1], [2 x i1]* %338, i64 0, i64 1
  store i1 false, i1* %.repack710, align 1
  store i32 2, i32* %x_ptr428, align 8
  store i32 1, i32* %y_ptr429, align 4
  %339 = bitcast i1** %arr_ptr430 to i8**
  store i8* %327, i8** %339, align 8
  store i1* %.sub708, i1** %mask_ptr431, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @res_11.7D0DF573.0, i64 0, i64 0), i64 15, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca427)
  ret void

mask_block_err.i1003:                             ; preds = %__hugr__.array.__read_bool.3.85.exit999.1
  call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable
}

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare void @heap_free(i8*) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool_arr(i8*, i64, <{ i32, i32, i1*, i1* }>*) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare void @___inc_future_refcount(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @__hugr__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

; Function Attrs: argmemonly nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #1

attributes #0 = { noreturn }
attributes #1 = { argmemonly nofree nounwind willreturn writeonly }

!name = !{!0}

!0 = !{!"mainlib"}
