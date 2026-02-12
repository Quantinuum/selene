; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

@"sa.static_pyarray.%tmp160.8bfddccb.0" = constant { i64, [4 x i1] } { i64 4, [4 x i1] [i1 true, i1 true, i1 false, i1 true] }
@"sa.static_pyarray.%tmp159.7d66e70e.0" = constant { i64, [4 x i1] } { i64 4, [4 x i1] [i1 true, i1 true, i1 false, i1 false] }
@"e_Some array.A77EF32E.0" = private constant [48 x i8] c"/EXIT:INT:Some array elements have been borrowed"
@"e_Array cont.EFA5AC45.0" = private constant [70 x i8] c"EEXIT:INT:Array contains non-borrowed elements and cannot be discarded"
@"e_Index out .DD115165.0" = private constant [29 x i8] c"\1CEXIT:INT:Index out of bounds"
@"e_Array elem.E746B1A3.0" = private constant [43 x i8] c"*EXIT:INT:Array element is already borrowed"
@res_b_reg.8EAD6F09.0 = private constant [19 x i8] c"\12USER:BOOLARR:b_reg"
@res_carry_out.3DB2874F.0 = private constant [20 x i8] c"\13USER:BOOL:carry_out"
@"e_Array alre.5A300C2A.0" = private constant [57 x i8] c"8EXIT:INT:Array already contains an element at this index"
@e_Frozenarra.36077F52.0 = private constant [41 x i8] c"(EXIT:INT:Frozenarray index out of bounds"
@"e_No more qu.3B2EEBF0.0" = private constant [47 x i8] c".EXIT:INT:No more qubits available to allocate."
@"e_Expected v.E6312129.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 1 but got variant 0"
@"e_Expected v.2F17E0A9.0" = private constant [46 x i8] c"-EXIT:INT:Expected variant 0 but got variant 1"

define private fastcc void @__hugr__.main.1() unnamed_addr {
alloca_block:
  %0 = tail call i8* @heap_alloc(i64 32)
  %1 = bitcast i8* %0 to i64*
  %2 = tail call i8* @heap_alloc(i64 8)
  %3 = bitcast i8* %2 to i64*
  store i64 -1, i64* %3, align 1
  %4 = tail call i8* @heap_alloc(i64 32)
  %5 = bitcast i8* %4 to i64*
  %6 = tail call i8* @heap_alloc(i64 8)
  %7 = bitcast i8* %6 to i64*
  store i64 -1, i64* %7, align 1
  %qalloc.i.i = tail call i64 @___qalloc()
  %not_max.not.i.i = icmp eq i64 %qalloc.i.i, -1
  br i1 %not_max.not.i.i, label %id_bb.i.i, label %reset_bb.i.i

reset_bb.i.i:                                     ; preds = %alloca_block
  tail call void @___reset(i64 %qalloc.i.i)
  br label %id_bb.i.i

id_bb.i.i:                                        ; preds = %reset_bb.i.i, %alloca_block
  %8 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.i, 1
  %9 = select i1 %not_max.not.i.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %8
  %.fca.0.extract.i.i = extractvalue { i1, i64 } %9, 0
  br i1 %.fca.0.extract.i.i, label %__hugr__.__tk2_qalloc.1930.exit.i, label %cond_1979_case_0.i.i

cond_1979_case_0.i.i:                             ; preds = %id_bb.i.3.i, %id_bb.i.2.i, %id_bb.i.1.i, %id_bb.i.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.1930.exit.i:                ; preds = %id_bb.i.i
  %10 = load i64, i64* %7, align 4
  %11 = and i64 %10, 1
  %.not.i.i = icmp eq i64 %11, 0
  br i1 %.not.i.i, label %panic.i.i, label %cond_exit_2178.i

panic.i.i:                                        ; preds = %__barray_check_bounds.exit.3.i, %__hugr__.__tk2_qalloc.1930.exit.2.i, %__hugr__.__tk2_qalloc.1930.exit.1.i, %__hugr__.__tk2_qalloc.1930.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_2178.i:                                 ; preds = %__hugr__.__tk2_qalloc.1930.exit.i
  %.fca.1.extract.i.i = extractvalue { i1, i64 } %9, 1
  %12 = xor i64 %10, 1
  store i64 %12, i64* %7, align 4
  store i64 %.fca.1.extract.i.i, i64* %5, align 4
  %qalloc.i.1.i = tail call i64 @___qalloc()
  %not_max.not.i.1.i = icmp eq i64 %qalloc.i.1.i, -1
  br i1 %not_max.not.i.1.i, label %id_bb.i.1.i, label %reset_bb.i.1.i

reset_bb.i.1.i:                                   ; preds = %cond_exit_2178.i
  tail call void @___reset(i64 %qalloc.i.1.i)
  br label %id_bb.i.1.i

id_bb.i.1.i:                                      ; preds = %reset_bb.i.1.i, %cond_exit_2178.i
  %13 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.1.i, 1
  %14 = select i1 %not_max.not.i.1.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %13
  %.fca.0.extract.i.1.i = extractvalue { i1, i64 } %14, 0
  br i1 %.fca.0.extract.i.1.i, label %__hugr__.__tk2_qalloc.1930.exit.1.i, label %cond_1979_case_0.i.i

__hugr__.__tk2_qalloc.1930.exit.1.i:              ; preds = %id_bb.i.1.i
  %15 = load i64, i64* %7, align 4
  %16 = and i64 %15, 2
  %.not.i.1.i = icmp eq i64 %16, 0
  br i1 %.not.i.1.i, label %panic.i.i, label %cond_exit_2178.1.i

cond_exit_2178.1.i:                               ; preds = %__hugr__.__tk2_qalloc.1930.exit.1.i
  %.fca.1.extract.i.1.i = extractvalue { i1, i64 } %14, 1
  %17 = xor i64 %15, 2
  store i64 %17, i64* %7, align 4
  %18 = getelementptr inbounds i8, i8* %4, i64 8
  %19 = bitcast i8* %18 to i64*
  store i64 %.fca.1.extract.i.1.i, i64* %19, align 4
  %qalloc.i.2.i = tail call i64 @___qalloc()
  %not_max.not.i.2.i = icmp eq i64 %qalloc.i.2.i, -1
  br i1 %not_max.not.i.2.i, label %id_bb.i.2.i, label %reset_bb.i.2.i

reset_bb.i.2.i:                                   ; preds = %cond_exit_2178.1.i
  tail call void @___reset(i64 %qalloc.i.2.i)
  br label %id_bb.i.2.i

id_bb.i.2.i:                                      ; preds = %reset_bb.i.2.i, %cond_exit_2178.1.i
  %20 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.2.i, 1
  %21 = select i1 %not_max.not.i.2.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %20
  %.fca.0.extract.i.2.i = extractvalue { i1, i64 } %21, 0
  br i1 %.fca.0.extract.i.2.i, label %__hugr__.__tk2_qalloc.1930.exit.2.i, label %cond_1979_case_0.i.i

__hugr__.__tk2_qalloc.1930.exit.2.i:              ; preds = %id_bb.i.2.i
  %22 = load i64, i64* %7, align 4
  %23 = and i64 %22, 4
  %.not.i.2.i = icmp eq i64 %23, 0
  br i1 %.not.i.2.i, label %panic.i.i, label %cond_exit_2178.2.i

cond_exit_2178.2.i:                               ; preds = %__hugr__.__tk2_qalloc.1930.exit.2.i
  %.fca.1.extract.i.2.i = extractvalue { i1, i64 } %21, 1
  %24 = xor i64 %22, 4
  store i64 %24, i64* %7, align 4
  %25 = getelementptr inbounds i8, i8* %4, i64 16
  %26 = bitcast i8* %25 to i64*
  store i64 %.fca.1.extract.i.2.i, i64* %26, align 4
  %qalloc.i.3.i = tail call i64 @___qalloc()
  %not_max.not.i.3.i = icmp eq i64 %qalloc.i.3.i, -1
  br i1 %not_max.not.i.3.i, label %id_bb.i.3.i, label %reset_bb.i.3.i

reset_bb.i.3.i:                                   ; preds = %cond_exit_2178.2.i
  tail call void @___reset(i64 %qalloc.i.3.i)
  br label %id_bb.i.3.i

id_bb.i.3.i:                                      ; preds = %reset_bb.i.3.i, %cond_exit_2178.2.i
  %27 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.3.i, 1
  %28 = select i1 %not_max.not.i.3.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %27
  %.fca.0.extract.i.3.i = extractvalue { i1, i64 } %28, 0
  br i1 %.fca.0.extract.i.3.i, label %__barray_check_bounds.exit.3.i, label %cond_1979_case_0.i.i

__barray_check_bounds.exit.3.i:                   ; preds = %id_bb.i.3.i
  %29 = load i64, i64* %7, align 4
  %30 = and i64 %29, 8
  %.not.i.3.i = icmp eq i64 %30, 0
  br i1 %.not.i.3.i, label %panic.i.i, label %cond_exit_2178.3.i

cond_exit_2178.3.i:                               ; preds = %__barray_check_bounds.exit.3.i
  %.fca.1.extract.i.3.i = extractvalue { i1, i64 } %28, 1
  %31 = xor i64 %29, 8
  store i64 %31, i64* %7, align 4
  %32 = getelementptr inbounds i8, i8* %4, i64 24
  %33 = bitcast i8* %32 to i64*
  store i64 %.fca.1.extract.i.3.i, i64* %33, align 4
  %"130.fca.0.insert.i" = insertvalue { i64*, i64*, i64 } poison, i64* %5, 0
  %"130.fca.1.insert.i" = insertvalue { i64*, i64*, i64 } %"130.fca.0.insert.i", i64* %7, 1
  %"130.fca.2.insert.i" = insertvalue { i64*, i64*, i64 } %"130.fca.1.insert.i", i64 0, 2
  %34 = tail call fastcc { i64*, i64*, i64 } @"__hugr__.$apply_bitstring$$n(4).2199"({ i64*, i64*, i64 } %"130.fca.2.insert.i", { i64, [0 x i1] }* bitcast ({ i64, [4 x i1] }* @"sa.static_pyarray.%tmp159.7d66e70e.0" to { i64, [0 x i1] }*))
  %qalloc.i7.i = tail call i64 @___qalloc()
  %not_max.not.i8.i = icmp eq i64 %qalloc.i7.i, -1
  br i1 %not_max.not.i8.i, label %id_bb.i11.i, label %reset_bb.i9.i

reset_bb.i9.i:                                    ; preds = %cond_exit_2178.3.i
  tail call void @___reset(i64 %qalloc.i7.i)
  br label %id_bb.i11.i

id_bb.i11.i:                                      ; preds = %reset_bb.i9.i, %cond_exit_2178.3.i
  %35 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i7.i, 1
  %36 = select i1 %not_max.not.i8.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %35
  %.fca.0.extract.i10.i = extractvalue { i1, i64 } %36, 0
  br i1 %.fca.0.extract.i10.i, label %__hugr__.__tk2_qalloc.1930.exit14.i, label %cond_1979_case_0.i13.i

cond_1979_case_0.i13.i:                           ; preds = %id_bb.i11.3.i, %id_bb.i11.2.i, %id_bb.i11.1.i, %id_bb.i11.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.1930.exit14.i:              ; preds = %id_bb.i11.i
  %37 = load i64, i64* %3, align 4
  %38 = and i64 %37, 1
  %.not.i17.i = icmp eq i64 %38, 0
  br i1 %.not.i17.i, label %panic.i18.i, label %cond_exit_2340.i

panic.i18.i:                                      ; preds = %__barray_check_bounds.exit16.3.i, %__hugr__.__tk2_qalloc.1930.exit14.2.i, %__hugr__.__tk2_qalloc.1930.exit14.1.i, %__hugr__.__tk2_qalloc.1930.exit14.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_2340.i:                                 ; preds = %__hugr__.__tk2_qalloc.1930.exit14.i
  %.fca.1.extract.i12.i = extractvalue { i1, i64 } %36, 1
  %39 = xor i64 %37, 1
  store i64 %39, i64* %3, align 4
  store i64 %.fca.1.extract.i12.i, i64* %1, align 4
  %qalloc.i7.1.i = tail call i64 @___qalloc()
  %not_max.not.i8.1.i = icmp eq i64 %qalloc.i7.1.i, -1
  br i1 %not_max.not.i8.1.i, label %id_bb.i11.1.i, label %reset_bb.i9.1.i

reset_bb.i9.1.i:                                  ; preds = %cond_exit_2340.i
  tail call void @___reset(i64 %qalloc.i7.1.i)
  br label %id_bb.i11.1.i

id_bb.i11.1.i:                                    ; preds = %reset_bb.i9.1.i, %cond_exit_2340.i
  %40 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i7.1.i, 1
  %41 = select i1 %not_max.not.i8.1.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %40
  %.fca.0.extract.i10.1.i = extractvalue { i1, i64 } %41, 0
  br i1 %.fca.0.extract.i10.1.i, label %__hugr__.__tk2_qalloc.1930.exit14.1.i, label %cond_1979_case_0.i13.i

__hugr__.__tk2_qalloc.1930.exit14.1.i:            ; preds = %id_bb.i11.1.i
  %42 = load i64, i64* %3, align 4
  %43 = and i64 %42, 2
  %.not.i17.1.i = icmp eq i64 %43, 0
  br i1 %.not.i17.1.i, label %panic.i18.i, label %cond_exit_2340.1.i

cond_exit_2340.1.i:                               ; preds = %__hugr__.__tk2_qalloc.1930.exit14.1.i
  %.fca.1.extract.i12.1.i = extractvalue { i1, i64 } %41, 1
  %44 = xor i64 %42, 2
  store i64 %44, i64* %3, align 4
  %45 = getelementptr inbounds i8, i8* %0, i64 8
  %46 = bitcast i8* %45 to i64*
  store i64 %.fca.1.extract.i12.1.i, i64* %46, align 4
  %qalloc.i7.2.i = tail call i64 @___qalloc()
  %not_max.not.i8.2.i = icmp eq i64 %qalloc.i7.2.i, -1
  br i1 %not_max.not.i8.2.i, label %id_bb.i11.2.i, label %reset_bb.i9.2.i

reset_bb.i9.2.i:                                  ; preds = %cond_exit_2340.1.i
  tail call void @___reset(i64 %qalloc.i7.2.i)
  br label %id_bb.i11.2.i

id_bb.i11.2.i:                                    ; preds = %reset_bb.i9.2.i, %cond_exit_2340.1.i
  %47 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i7.2.i, 1
  %48 = select i1 %not_max.not.i8.2.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %47
  %.fca.0.extract.i10.2.i = extractvalue { i1, i64 } %48, 0
  br i1 %.fca.0.extract.i10.2.i, label %__hugr__.__tk2_qalloc.1930.exit14.2.i, label %cond_1979_case_0.i13.i

__hugr__.__tk2_qalloc.1930.exit14.2.i:            ; preds = %id_bb.i11.2.i
  %49 = load i64, i64* %3, align 4
  %50 = and i64 %49, 4
  %.not.i17.2.i = icmp eq i64 %50, 0
  br i1 %.not.i17.2.i, label %panic.i18.i, label %cond_exit_2340.2.i

cond_exit_2340.2.i:                               ; preds = %__hugr__.__tk2_qalloc.1930.exit14.2.i
  %.fca.1.extract.i12.2.i = extractvalue { i1, i64 } %48, 1
  %51 = xor i64 %49, 4
  store i64 %51, i64* %3, align 4
  %52 = getelementptr inbounds i8, i8* %0, i64 16
  %53 = bitcast i8* %52 to i64*
  store i64 %.fca.1.extract.i12.2.i, i64* %53, align 4
  %qalloc.i7.3.i = tail call i64 @___qalloc()
  %not_max.not.i8.3.i = icmp eq i64 %qalloc.i7.3.i, -1
  br i1 %not_max.not.i8.3.i, label %id_bb.i11.3.i, label %reset_bb.i9.3.i

reset_bb.i9.3.i:                                  ; preds = %cond_exit_2340.2.i
  tail call void @___reset(i64 %qalloc.i7.3.i)
  br label %id_bb.i11.3.i

id_bb.i11.3.i:                                    ; preds = %reset_bb.i9.3.i, %cond_exit_2340.2.i
  %54 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i7.3.i, 1
  %55 = select i1 %not_max.not.i8.3.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %54
  %.fca.0.extract.i10.3.i = extractvalue { i1, i64 } %55, 0
  br i1 %.fca.0.extract.i10.3.i, label %__barray_check_bounds.exit16.3.i, label %cond_1979_case_0.i13.i

__barray_check_bounds.exit16.3.i:                 ; preds = %id_bb.i11.3.i
  %56 = load i64, i64* %3, align 4
  %57 = and i64 %56, 8
  %.not.i17.3.i = icmp eq i64 %57, 0
  br i1 %.not.i17.3.i, label %panic.i18.i, label %cond_exit_2340.3.i

cond_exit_2340.3.i:                               ; preds = %__barray_check_bounds.exit16.3.i
  %.fca.1.extract.i12.3.i = extractvalue { i1, i64 } %55, 1
  %58 = xor i64 %56, 8
  store i64 %58, i64* %3, align 4
  %59 = getelementptr inbounds i8, i8* %0, i64 24
  %60 = bitcast i8* %59 to i64*
  store i64 %.fca.1.extract.i12.3.i, i64* %60, align 4
  %"195.fca.0.insert.i" = insertvalue { i64*, i64*, i64 } poison, i64* %1, 0
  %"195.fca.1.insert.i" = insertvalue { i64*, i64*, i64 } %"195.fca.0.insert.i", i64* %3, 1
  %"195.fca.2.insert.i" = insertvalue { i64*, i64*, i64 } %"195.fca.1.insert.i", i64 0, 2
  %61 = tail call fastcc { i64*, i64*, i64 } @"__hugr__.$apply_bitstring$$n(4).2199"({ i64*, i64*, i64 } %"195.fca.2.insert.i", { i64, [0 x i1] }* bitcast ({ i64, [4 x i1] }* @"sa.static_pyarray.%tmp160.8bfddccb.0" to { i64, [0 x i1] }*))
  %qalloc.i20.i = tail call i64 @___qalloc()
  %not_max.not.i21.i = icmp eq i64 %qalloc.i20.i, -1
  br i1 %not_max.not.i21.i, label %id_bb.i24.i, label %reset_bb.i22.i

reset_bb.i22.i:                                   ; preds = %cond_exit_2340.3.i
  tail call void @___reset(i64 %qalloc.i20.i)
  br label %id_bb.i24.i

id_bb.i24.i:                                      ; preds = %reset_bb.i22.i, %cond_exit_2340.3.i
  %62 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i20.i, 1
  %63 = select i1 %not_max.not.i21.i, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %62
  %.fca.0.extract.i23.i = extractvalue { i1, i64 } %63, 0
  br i1 %.fca.0.extract.i23.i, label %"__hugr__.$crc_prep_regs$$n(4).2143.exit", label %cond_1979_case_0.i26.i

cond_1979_case_0.i26.i:                           ; preds = %id_bb.i24.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

"__hugr__.$crc_prep_regs$$n(4).2143.exit":        ; preds = %id_bb.i24.i
  %.fca.1.extract.i25.i = extractvalue { i1, i64 } %63, 1
  %qalloc.i.i210 = tail call i64 @___qalloc()
  %not_max.not.i.i211 = icmp eq i64 %qalloc.i.i210, -1
  br i1 %not_max.not.i.i211, label %id_bb.i.i214, label %reset_bb.i.i212

reset_bb.i.i212:                                  ; preds = %"__hugr__.$crc_prep_regs$$n(4).2143.exit"
  tail call void @___reset(i64 %qalloc.i.i210)
  br label %id_bb.i.i214

id_bb.i.i214:                                     ; preds = %reset_bb.i.i212, %"__hugr__.$crc_prep_regs$$n(4).2143.exit"
  %64 = insertvalue { i1, i64 } { i1 true, i64 poison }, i64 %qalloc.i.i210, 1
  %65 = select i1 %not_max.not.i.i211, { i1, i64 } { i1 false, i64 poison }, { i1, i64 } %64
  %.fca.0.extract.i.i213 = extractvalue { i1, i64 } %65, 0
  br i1 %.fca.0.extract.i.i213, label %__hugr__.__tk2_qalloc.1930.exit.i217, label %cond_1979_case_0.i.i215

cond_1979_case_0.i.i215:                          ; preds = %id_bb.i.i214
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([47 x i8], [47 x i8]* @"e_No more qu.3B2EEBF0.0", i64 0, i64 0))
  unreachable

__hugr__.__tk2_qalloc.1930.exit.i217:             ; preds = %id_bb.i.i214
  %.fca.1.extract.i.i216 = extractvalue { i1, i64 } %65, 1
  %.fca.0.extract311.i.i = extractvalue { i64*, i64*, i64 } %34, 0
  %.fca.1.extract312.i.i = extractvalue { i64*, i64*, i64 } %34, 1
  %.fca.2.extract313.i.i = extractvalue { i64*, i64*, i64 } %34, 2
  %.fca.0.extract308.i.i = extractvalue { i64*, i64*, i64 } %61, 0
  %.fca.1.extract309.i.i = extractvalue { i64*, i64*, i64 } %61, 1
  %.fca.2.extract310.i.i = extractvalue { i64*, i64*, i64 } %61, 2
  br label %__barray_check_bounds.exit.i.i

__barray_check_bounds.exit.i.i:                   ; preds = %__barray_mask_return.exit16.i.i, %__hugr__.__tk2_qalloc.1930.exit.i217
  %"2408_0.025.i.i" = phi i64 [ 1, %__hugr__.__tk2_qalloc.1930.exit.i217 ], [ %66, %__barray_mask_return.exit16.i.i ]
  %66 = add nuw nsw i64 %"2408_0.025.i.i", 1
  %67 = add i64 %"2408_0.025.i.i", %.fca.2.extract310.i.i
  %68 = lshr i64 %67, 6
  %69 = getelementptr inbounds i64, i64* %.fca.1.extract309.i.i, i64 %68
  %70 = load i64, i64* %69, align 4
  %71 = and i64 %67, 63
  %72 = shl nuw i64 1, %71
  %73 = and i64 %72, %70
  %.not.i.i.i = icmp eq i64 %73, 0
  br i1 %.not.i.i.i, label %__barray_check_bounds.exit4.i.i, label %panic.i.i.i

panic.i.i.i:                                      ; preds = %__barray_check_bounds.exit.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit4.i.i:                  ; preds = %__barray_check_bounds.exit.i.i
  %74 = xor i64 %72, %70
  store i64 %74, i64* %69, align 4
  %75 = getelementptr inbounds i64, i64* %.fca.0.extract308.i.i, i64 %67
  %76 = load i64, i64* %75, align 4
  %77 = add i64 %"2408_0.025.i.i", %.fca.2.extract313.i.i
  %78 = lshr i64 %77, 6
  %79 = getelementptr inbounds i64, i64* %.fca.1.extract312.i.i, i64 %78
  %80 = load i64, i64* %79, align 4
  %81 = and i64 %77, 63
  %82 = shl nuw i64 1, %81
  %83 = and i64 %80, %82
  %.not.i5.i.i = icmp eq i64 %83, 0
  br i1 %.not.i5.i.i, label %__barray_check_bounds.exit9.i.i, label %panic.i6.i.i

panic.i6.i.i:                                     ; preds = %__barray_check_bounds.exit4.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit9.i.i:                  ; preds = %__barray_check_bounds.exit4.i.i
  %84 = xor i64 %80, %82
  store i64 %84, i64* %79, align 4
  %85 = getelementptr inbounds i64, i64* %.fca.0.extract311.i.i, i64 %77
  %86 = load i64, i64* %85, align 4
  tail call void @___rxy(i64 %76, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %86, i64 %76, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %86, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %76, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %76, double 0xBFF921FB54442D18)
  %87 = load i64, i64* %69, align 4
  %88 = and i64 %87, %72
  %.not.i10.i.i = icmp eq i64 %88, 0
  br i1 %.not.i10.i.i, label %panic.i11.i.i, label %__barray_check_bounds.exit13.i.i

panic.i11.i.i:                                    ; preds = %__barray_check_bounds.exit9.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit13.i.i:                 ; preds = %__barray_check_bounds.exit9.i.i
  %89 = xor i64 %87, %72
  store i64 %89, i64* %69, align 4
  store i64 %76, i64* %75, align 4
  %90 = load i64, i64* %79, align 4
  %91 = and i64 %90, %82
  %.not.i14.i.i = icmp eq i64 %91, 0
  br i1 %.not.i14.i.i, label %panic.i15.i.i, label %__barray_mask_return.exit16.i.i

panic.i15.i.i:                                    ; preds = %__barray_check_bounds.exit13.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit16.i.i:                  ; preds = %__barray_check_bounds.exit13.i.i
  %92 = xor i64 %90, %82
  store i64 %92, i64* %79, align 4
  store i64 %86, i64* %85, align 4
  %exitcond.not.i.i = icmp eq i64 %66, 4
  br i1 %exitcond.not.i.i, label %"__hugr__.$traversal2_start_end$$n(4).2395.exit.i", label %__barray_check_bounds.exit.i.i

"__hugr__.$traversal2_start_end$$n(4).2395.exit.i": ; preds = %__barray_mask_return.exit16.i.i
  %93 = add i64 %.fca.2.extract313.i.i, 1
  %94 = lshr i64 %93, 6
  %95 = getelementptr inbounds i64, i64* %.fca.1.extract312.i.i, i64 %94
  %96 = load i64, i64* %95, align 4
  %97 = and i64 %93, 63
  %98 = shl nuw i64 1, %97
  %99 = and i64 %96, %98
  %.not.i.i218 = icmp eq i64 %99, 0
  br i1 %.not.i.i218, label %__barray_mask_borrow.exit.i, label %panic.i.i219

panic.i.i219:                                     ; preds = %"__hugr__.$traversal2_start_end$$n(4).2395.exit.i"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit.i:                      ; preds = %"__hugr__.$traversal2_start_end$$n(4).2395.exit.i"
  %100 = xor i64 %96, %98
  store i64 %100, i64* %95, align 4
  %101 = getelementptr inbounds i64, i64* %.fca.0.extract311.i.i, i64 %93
  %102 = load i64, i64* %101, align 4
  tail call void @___rxy(i64 %.fca.1.extract.i.i216, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %102, i64 %.fca.1.extract.i.i216, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %102, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i.i216, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i.i216, double 0xBFF921FB54442D18)
  %103 = load i64, i64* %95, align 4
  %104 = and i64 %103, %98
  %.not.i838.i = icmp eq i64 %104, 0
  br i1 %.not.i838.i, label %panic.i839.i, label %__barray_mask_return.exit.i

panic.i839.i:                                     ; preds = %__barray_mask_borrow.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit.i:                      ; preds = %__barray_mask_borrow.exit.i
  %105 = xor i64 %103, %98
  store i64 %105, i64* %95, align 4
  store i64 %102, i64* %101, align 4
  %106 = lshr i64 %.fca.2.extract313.i.i, 6
  %107 = getelementptr inbounds i64, i64* %.fca.1.extract312.i.i, i64 %106
  %108 = load i64, i64* %107, align 4
  %109 = and i64 %.fca.2.extract313.i.i, 63
  %110 = shl nuw i64 1, %109
  %111 = and i64 %108, %110
  %.not.i.i840.i = icmp eq i64 %111, 0
  br i1 %.not.i.i840.i, label %__barray_mask_borrow.exit.i.i, label %panic.i.i841.i

panic.i.i841.i:                                   ; preds = %__barray_mask_return.exit.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit.i.i:                    ; preds = %__barray_mask_return.exit.i
  %112 = xor i64 %108, %110
  store i64 %112, i64* %107, align 4
  %113 = getelementptr inbounds i64, i64* %.fca.0.extract311.i.i, i64 %.fca.2.extract313.i.i
  %114 = load i64, i64* %113, align 4
  %115 = load i64, i64* %95, align 4
  %116 = and i64 %115, %98
  %.not.i694.i.i = icmp eq i64 %116, 0
  br i1 %.not.i694.i.i, label %__barray_mask_borrow.exit696.i.i, label %panic.i695.i.i

panic.i695.i.i:                                   ; preds = %__barray_mask_borrow.exit.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit696.i.i:                 ; preds = %__barray_mask_borrow.exit.i.i
  %117 = xor i64 %115, %98
  store i64 %117, i64* %95, align 4
  %118 = load i64, i64* %101, align 4
  %119 = add i64 %.fca.2.extract313.i.i, 2
  %120 = lshr i64 %119, 6
  %121 = getelementptr inbounds i64, i64* %.fca.1.extract312.i.i, i64 %120
  %122 = load i64, i64* %121, align 4
  %123 = and i64 %119, 63
  %124 = shl nuw i64 1, %123
  %125 = and i64 %122, %124
  %.not.i697.i.i = icmp eq i64 %125, 0
  br i1 %.not.i697.i.i, label %__barray_mask_borrow.exit699.i.i, label %panic.i698.i.i

panic.i698.i.i:                                   ; preds = %__barray_mask_borrow.exit696.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit699.i.i:                 ; preds = %__barray_mask_borrow.exit696.i.i
  %126 = xor i64 %122, %124
  store i64 %126, i64* %121, align 4
  %127 = getelementptr inbounds i64, i64* %.fca.0.extract311.i.i, i64 %119
  %128 = load i64, i64* %127, align 4
  %129 = lshr i64 %.fca.2.extract310.i.i, 6
  %130 = getelementptr inbounds i64, i64* %.fca.1.extract309.i.i, i64 %129
  %131 = load i64, i64* %130, align 4
  %132 = and i64 %.fca.2.extract310.i.i, 63
  %133 = shl nuw i64 1, %132
  %134 = and i64 %131, %133
  %.not.i700.i.i = icmp eq i64 %134, 0
  br i1 %.not.i700.i.i, label %__barray_mask_borrow.exit702.i.i, label %panic.i701.i.i

panic.i701.i.i:                                   ; preds = %__barray_mask_borrow.exit699.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit702.i.i:                 ; preds = %__barray_mask_borrow.exit699.i.i
  %135 = xor i64 %131, %133
  store i64 %135, i64* %130, align 4
  %136 = getelementptr inbounds i64, i64* %.fca.0.extract308.i.i, i64 %.fca.2.extract310.i.i
  %137 = load i64, i64* %136, align 4
  tail call void @___rxy(i64 %118, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %128, i64 %118, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %128, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %118, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %118, double 0xBFF921FB54442D18)
  %138 = tail call fastcc { i64, i64, i64 } @__hugr__.ccx.1244(i64 %137, i64 %114, i64 %.fca.1.extract.i.i216)
  %139 = extractvalue { i64, i64, i64 } %138, 0
  %140 = extractvalue { i64, i64, i64 } %138, 2
  %141 = load i64, i64* %107, align 4
  %142 = and i64 %141, %110
  %.not.i703.i.i = icmp eq i64 %142, 0
  br i1 %.not.i703.i.i, label %panic.i704.i.i, label %__barray_mask_return.exit.i.i

panic.i704.i.i:                                   ; preds = %__barray_mask_borrow.exit702.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit.i.i:                    ; preds = %__barray_mask_borrow.exit702.i.i
  %143 = extractvalue { i64, i64, i64 } %138, 1
  %144 = xor i64 %141, %110
  store i64 %144, i64* %107, align 4
  store i64 %143, i64* %113, align 4
  %145 = load i64, i64* %95, align 4
  %146 = and i64 %145, %98
  %.not.i705.i.i = icmp eq i64 %146, 0
  br i1 %.not.i705.i.i, label %panic.i706.i.i, label %__barray_mask_return.exit707.i.i

panic.i706.i.i:                                   ; preds = %__barray_mask_return.exit.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit707.i.i:                 ; preds = %__barray_mask_return.exit.i.i
  %147 = xor i64 %145, %98
  store i64 %147, i64* %95, align 4
  store i64 %118, i64* %101, align 4
  %148 = load i64, i64* %121, align 4
  %149 = and i64 %148, %124
  %.not.i708.i.i = icmp eq i64 %149, 0
  br i1 %.not.i708.i.i, label %panic.i709.i.i, label %__barray_mask_return.exit710.i.i

panic.i709.i.i:                                   ; preds = %__barray_mask_return.exit707.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit710.i.i:                 ; preds = %__barray_mask_return.exit707.i.i
  %150 = xor i64 %148, %124
  store i64 %150, i64* %121, align 4
  store i64 %128, i64* %127, align 4
  %151 = load i64, i64* %95, align 4
  %152 = and i64 %151, %98
  %.not.i711.i.i = icmp eq i64 %152, 0
  br i1 %.not.i711.i.i, label %__barray_mask_borrow.exit713.i.i, label %panic.i712.i.i

panic.i712.i.i:                                   ; preds = %__barray_mask_return.exit710.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit713.i.i:                 ; preds = %__barray_mask_return.exit710.i.i
  %153 = xor i64 %151, %98
  store i64 %153, i64* %95, align 4
  %154 = load i64, i64* %101, align 4
  %155 = load i64, i64* %121, align 4
  %156 = and i64 %155, %124
  %.not.i714.i.i = icmp eq i64 %156, 0
  br i1 %.not.i714.i.i, label %__barray_mask_borrow.exit716.i.i, label %panic.i715.i.i

panic.i715.i.i:                                   ; preds = %__barray_mask_borrow.exit713.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit716.i.i:                 ; preds = %__barray_mask_borrow.exit713.i.i
  %157 = xor i64 %155, %124
  store i64 %157, i64* %121, align 4
  %158 = load i64, i64* %127, align 4
  %159 = add i64 %.fca.2.extract313.i.i, 3
  %160 = lshr i64 %159, 6
  %161 = getelementptr inbounds i64, i64* %.fca.1.extract312.i.i, i64 %160
  %162 = load i64, i64* %161, align 4
  %163 = and i64 %159, 63
  %164 = shl nuw i64 1, %163
  %165 = and i64 %162, %164
  %.not.i717.i.i = icmp eq i64 %165, 0
  br i1 %.not.i717.i.i, label %__barray_mask_borrow.exit719.i.i, label %panic.i718.i.i

panic.i718.i.i:                                   ; preds = %__barray_mask_borrow.exit716.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit719.i.i:                 ; preds = %__barray_mask_borrow.exit716.i.i
  %166 = xor i64 %162, %164
  store i64 %166, i64* %161, align 4
  %167 = getelementptr inbounds i64, i64* %.fca.0.extract311.i.i, i64 %159
  %168 = load i64, i64* %167, align 4
  %169 = load i64, i64* %130, align 4
  %170 = and i64 %169, %133
  %.not.i720.i.i = icmp eq i64 %170, 0
  br i1 %.not.i720.i.i, label %panic.i721.i.i, label %__barray_mask_return.exit722.i.i

panic.i721.i.i:                                   ; preds = %__barray_mask_borrow.exit719.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit722.i.i:                 ; preds = %__barray_mask_borrow.exit719.i.i
  %171 = xor i64 %169, %133
  store i64 %171, i64* %130, align 4
  store i64 %139, i64* %136, align 4
  %172 = add i64 %.fca.2.extract310.i.i, 1
  %173 = lshr i64 %172, 6
  %174 = getelementptr inbounds i64, i64* %.fca.1.extract309.i.i, i64 %173
  %175 = load i64, i64* %174, align 4
  %176 = and i64 %172, 63
  %177 = shl nuw i64 1, %176
  %178 = and i64 %175, %177
  %.not.i723.i.i = icmp eq i64 %178, 0
  br i1 %.not.i723.i.i, label %__barray_mask_borrow.exit725.i.i, label %panic.i724.i.i

panic.i724.i.i:                                   ; preds = %__barray_mask_return.exit722.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit725.i.i:                 ; preds = %__barray_mask_return.exit722.i.i
  %179 = xor i64 %175, %177
  store i64 %179, i64* %174, align 4
  %180 = getelementptr inbounds i64, i64* %.fca.0.extract308.i.i, i64 %172
  %181 = load i64, i64* %180, align 4
  tail call void @___rxy(i64 %158, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %168, i64 %158, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %168, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %158, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %158, double 0xBFF921FB54442D18)
  %182 = tail call fastcc { i64, i64, i64 } @__hugr__.ccx.1244(i64 %140, i64 %181, i64 %154)
  %183 = extractvalue { i64, i64, i64 } %182, 1
  %184 = load i64, i64* %95, align 4
  %185 = and i64 %184, %98
  %.not.i731.i.i = icmp eq i64 %185, 0
  br i1 %.not.i731.i.i, label %panic.i732.i.i, label %__barray_mask_return.exit733.i.i

panic.i732.i.i:                                   ; preds = %__barray_mask_borrow.exit725.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit733.i.i:                 ; preds = %__barray_mask_borrow.exit725.i.i
  %186 = extractvalue { i64, i64, i64 } %182, 2
  %187 = xor i64 %184, %98
  store i64 %187, i64* %95, align 4
  store i64 %186, i64* %101, align 4
  %188 = load i64, i64* %121, align 4
  %189 = and i64 %188, %124
  %.not.i734.i.i = icmp eq i64 %189, 0
  br i1 %.not.i734.i.i, label %panic.i735.i.i, label %__barray_mask_return.exit736.i.i

panic.i735.i.i:                                   ; preds = %__barray_mask_return.exit733.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit736.i.i:                 ; preds = %__barray_mask_return.exit733.i.i
  %190 = xor i64 %188, %124
  store i64 %190, i64* %121, align 4
  store i64 %158, i64* %127, align 4
  %191 = load i64, i64* %161, align 4
  %192 = and i64 %191, %164
  %.not.i737.i.i = icmp eq i64 %192, 0
  br i1 %.not.i737.i.i, label %panic.i738.i.i, label %__barray_mask_return.exit739.i.i

panic.i738.i.i:                                   ; preds = %__barray_mask_return.exit736.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit739.i.i:                 ; preds = %__barray_mask_return.exit736.i.i
  %193 = xor i64 %191, %164
  store i64 %193, i64* %161, align 4
  store i64 %168, i64* %167, align 4
  %194 = load i64, i64* %174, align 4
  %195 = and i64 %194, %177
  %.not.i740.i.i = icmp eq i64 %195, 0
  br i1 %.not.i740.i.i, label %panic.i741.i.i, label %__barray_mask_return.exit742.i.i

panic.i741.i.i:                                   ; preds = %__barray_mask_return.exit739.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit742.i.i:                 ; preds = %__barray_mask_return.exit739.i.i
  %196 = xor i64 %194, %177
  store i64 %196, i64* %174, align 4
  store i64 %183, i64* %180, align 4
  %197 = add i64 %.fca.2.extract310.i.i, 2
  %198 = lshr i64 %197, 6
  %199 = getelementptr inbounds i64, i64* %.fca.1.extract309.i.i, i64 %198
  %200 = load i64, i64* %199, align 4
  %201 = and i64 %197, 63
  %202 = shl nuw i64 1, %201
  %203 = and i64 %200, %202
  %.not.i796.i.i = icmp eq i64 %203, 0
  br i1 %.not.i796.i.i, label %__barray_mask_borrow.exit798.i.i, label %panic.i797.i.i

panic.i797.i.i:                                   ; preds = %__barray_mask_return.exit742.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit798.i.i:                 ; preds = %__barray_mask_return.exit742.i.i
  %204 = xor i64 %200, %202
  store i64 %204, i64* %199, align 4
  %205 = getelementptr inbounds i64, i64* %.fca.0.extract308.i.i, i64 %197
  %206 = load i64, i64* %205, align 4
  %207 = load i64, i64* %95, align 4
  %208 = and i64 %207, %98
  %.not.i799.i.i = icmp eq i64 %208, 0
  br i1 %.not.i799.i.i, label %__barray_mask_borrow.exit801.i.i, label %panic.i800.i.i

panic.i800.i.i:                                   ; preds = %__barray_mask_borrow.exit798.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit801.i.i:                 ; preds = %__barray_mask_borrow.exit798.i.i
  %209 = xor i64 %207, %98
  store i64 %209, i64* %95, align 4
  %210 = load i64, i64* %101, align 4
  %211 = load i64, i64* %121, align 4
  %212 = and i64 %211, %124
  %.not.i802.i.i = icmp eq i64 %212, 0
  br i1 %.not.i802.i.i, label %__barray_mask_borrow.exit804.i.i, label %panic.i803.i.i

panic.i803.i.i:                                   ; preds = %__barray_mask_borrow.exit801.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit804.i.i:                 ; preds = %__barray_mask_borrow.exit801.i.i
  %213 = xor i64 %211, %124
  store i64 %213, i64* %121, align 4
  %214 = load i64, i64* %161, align 4
  %215 = and i64 %214, %164
  %.not.i805.i.i = icmp eq i64 %215, 0
  br i1 %.not.i805.i.i, label %__barray_mask_borrow.exit807.i.i, label %panic.i806.i.i

panic.i806.i.i:                                   ; preds = %__barray_mask_borrow.exit804.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit807.i.i:                 ; preds = %__barray_mask_borrow.exit804.i.i
  %216 = load i64, i64* %127, align 4
  %217 = xor i64 %214, %164
  store i64 %217, i64* %161, align 4
  %218 = load i64, i64* %167, align 4
  tail call void @___rxy(i64 %.fca.1.extract.i25.i, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %218, i64 %.fca.1.extract.i25.i, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %218, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %.fca.1.extract.i25.i, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %.fca.1.extract.i25.i, double 0xBFF921FB54442D18)
  %219 = tail call fastcc { i64, i64, i64 } @__hugr__.ccx.1244(i64 %210, i64 %206, i64 %216)
  %220 = extractvalue { i64, i64, i64 } %219, 0
  %221 = extractvalue { i64, i64, i64 } %219, 2
  %222 = load i64, i64* %199, align 4
  %223 = and i64 %222, %202
  %.not.i813.i.i = icmp eq i64 %223, 0
  br i1 %.not.i813.i.i, label %panic.i814.i.i, label %__barray_mask_return.exit815.i.i

panic.i814.i.i:                                   ; preds = %__barray_mask_borrow.exit807.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit815.i.i:                 ; preds = %__barray_mask_borrow.exit807.i.i
  %224 = extractvalue { i64, i64, i64 } %219, 1
  %225 = xor i64 %222, %202
  store i64 %225, i64* %199, align 4
  store i64 %224, i64* %205, align 4
  %226 = load i64, i64* %95, align 4
  %227 = and i64 %226, %98
  %.not.i816.i.i = icmp eq i64 %227, 0
  br i1 %.not.i816.i.i, label %panic.i817.i.i, label %__barray_mask_return.exit818.i.i

panic.i817.i.i:                                   ; preds = %__barray_mask_return.exit815.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit818.i.i:                 ; preds = %__barray_mask_return.exit815.i.i
  %228 = xor i64 %226, %98
  store i64 %228, i64* %95, align 4
  store i64 %220, i64* %101, align 4
  %229 = load i64, i64* %121, align 4
  %230 = and i64 %229, %124
  %.not.i819.i.i = icmp eq i64 %230, 0
  br i1 %.not.i819.i.i, label %panic.i820.i.i, label %__barray_mask_return.exit821.i.i

panic.i820.i.i:                                   ; preds = %__barray_mask_return.exit818.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit821.i.i:                 ; preds = %__barray_mask_return.exit818.i.i
  %231 = xor i64 %229, %124
  store i64 %231, i64* %121, align 4
  store i64 %221, i64* %127, align 4
  %232 = load i64, i64* %161, align 4
  %233 = and i64 %232, %164
  %.not.i822.i.i = icmp eq i64 %233, 0
  br i1 %.not.i822.i.i, label %panic.i823.i.i, label %"__hugr__.$_block_1_layers$$n(4).2501.exit.i"

panic.i823.i.i:                                   ; preds = %__barray_mask_return.exit821.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

"__hugr__.$_block_1_layers$$n(4).2501.exit.i":    ; preds = %__barray_mask_return.exit821.i.i
  %234 = extractvalue { i64, i64, i64 } %182, 0
  %235 = xor i64 %232, %164
  store i64 %235, i64* %161, align 4
  store i64 %218, i64* %167, align 4
  %236 = load i64, i64* %174, align 4
  %237 = and i64 %236, %177
  %.not.i843.i = icmp eq i64 %237, 0
  br i1 %.not.i843.i, label %__barray_check_bounds.exit847.i, label %panic.i844.i

panic.i844.i:                                     ; preds = %__barray_check_bounds.exit.1.i, %"__hugr__.$_block_1_layers$$n(4).2501.exit.i"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit847.i:                  ; preds = %"__hugr__.$_block_1_layers$$n(4).2501.exit.i"
  %238 = xor i64 %236, %177
  store i64 %238, i64* %174, align 4
  %239 = load i64, i64* %180, align 4
  tail call void @___rxy(i64 %239, double 0x400921FB54442D18, double 0.000000e+00)
  %240 = load i64, i64* %174, align 4
  %241 = and i64 %240, %177
  %.not.i848.i = icmp eq i64 %241, 0
  br i1 %.not.i848.i, label %panic.i849.i, label %__barray_check_bounds.exit.1.i

panic.i849.i:                                     ; preds = %__barray_check_bounds.exit847.1.i, %__barray_check_bounds.exit847.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit.1.i:                   ; preds = %__barray_check_bounds.exit847.i
  %242 = xor i64 %240, %177
  store i64 %242, i64* %174, align 4
  store i64 %239, i64* %180, align 4
  %243 = load i64, i64* %199, align 4
  %244 = and i64 %243, %202
  %.not.i843.1.i = icmp eq i64 %244, 0
  br i1 %.not.i843.1.i, label %__barray_check_bounds.exit847.1.i, label %panic.i844.i

__barray_check_bounds.exit847.1.i:                ; preds = %__barray_check_bounds.exit.1.i
  %245 = xor i64 %243, %202
  store i64 %245, i64* %199, align 4
  %246 = load i64, i64* %205, align 4
  tail call void @___rxy(i64 %246, double 0x400921FB54442D18, double 0.000000e+00)
  %247 = load i64, i64* %199, align 4
  %248 = and i64 %247, %202
  %.not.i848.1.i = icmp eq i64 %248, 0
  br i1 %.not.i848.1.i, label %panic.i849.i, label %__barray_mask_return.exit850.1.i

__barray_mask_return.exit850.1.i:                 ; preds = %__barray_check_bounds.exit847.1.i
  %249 = xor i64 %247, %202
  store i64 %249, i64* %199, align 4
  store i64 %246, i64* %205, align 4
  %250 = add i64 %.fca.2.extract310.i.i, 3
  %251 = lshr i64 %250, 6
  %252 = getelementptr inbounds i64, i64* %.fca.1.extract309.i.i, i64 %251
  %253 = load i64, i64* %252, align 4
  %254 = and i64 %250, 63
  %255 = shl nuw i64 1, %254
  %256 = and i64 %253, %255
  %.not.i879.i = icmp eq i64 %256, 0
  br i1 %.not.i879.i, label %__barray_mask_borrow.exit881.i, label %panic.i880.i

panic.i860.i:                                     ; preds = %__barray_mask_return.exit898.i, %__barray_check_bounds.exit858.1.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit861.i:                   ; preds = %__barray_mask_return.exit898.i
  %257 = xor i64 %308, %202
  store i64 %257, i64* %199, align 4
  %258 = load i64, i64* %205, align 4
  %259 = load i64, i64* %95, align 4
  %260 = and i64 %259, %98
  %.not.i864.i = icmp eq i64 %260, 0
  br i1 %.not.i864.i, label %__barray_check_bounds.exit870.i, label %panic.i865.i

panic.i865.i:                                     ; preds = %__barray_check_bounds.exit863.1.i, %__barray_mask_borrow.exit861.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit870.i:                  ; preds = %__barray_mask_borrow.exit861.i
  %261 = xor i64 %259, %98
  store i64 %261, i64* %95, align 4
  %262 = load i64, i64* %101, align 4
  tail call void @___rxy(i64 %258, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %262, i64 %258, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %262, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %258, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %258, double 0xBFF921FB54442D18)
  %263 = load i64, i64* %199, align 4
  %264 = and i64 %263, %202
  %.not.i871.i = icmp eq i64 %264, 0
  br i1 %.not.i871.i, label %panic.i872.i, label %__barray_check_bounds.exit875.i

panic.i872.i:                                     ; preds = %__barray_check_bounds.exit870.1.i, %__barray_check_bounds.exit870.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit875.i:                  ; preds = %__barray_check_bounds.exit870.i
  %265 = xor i64 %263, %202
  store i64 %265, i64* %199, align 4
  store i64 %258, i64* %205, align 4
  %266 = load i64, i64* %95, align 4
  %267 = and i64 %266, %98
  %.not.i876.i = icmp eq i64 %267, 0
  br i1 %.not.i876.i, label %panic.i877.i, label %__barray_check_bounds.exit858.1.i

panic.i877.i:                                     ; preds = %__barray_check_bounds.exit875.1.i, %__barray_check_bounds.exit875.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit858.1.i:                ; preds = %__barray_check_bounds.exit875.i
  %268 = xor i64 %266, %98
  store i64 %268, i64* %95, align 4
  store i64 %262, i64* %101, align 4
  %269 = load i64, i64* %252, align 4
  %270 = and i64 %269, %255
  %.not.i859.1.i = icmp eq i64 %270, 0
  br i1 %.not.i859.1.i, label %__barray_check_bounds.exit863.1.i, label %panic.i860.i

__barray_check_bounds.exit863.1.i:                ; preds = %__barray_check_bounds.exit858.1.i
  %271 = xor i64 %269, %255
  store i64 %271, i64* %252, align 4
  %272 = load i64, i64* %286, align 4
  %273 = load i64, i64* %121, align 4
  %274 = and i64 %273, %124
  %.not.i864.1.i = icmp eq i64 %274, 0
  br i1 %.not.i864.1.i, label %__barray_check_bounds.exit870.1.i, label %panic.i865.i

__barray_check_bounds.exit870.1.i:                ; preds = %__barray_check_bounds.exit863.1.i
  %275 = xor i64 %273, %124
  store i64 %275, i64* %121, align 4
  %276 = load i64, i64* %127, align 4
  tail call void @___rxy(i64 %272, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %276, i64 %272, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %276, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %272, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %272, double 0xBFF921FB54442D18)
  %277 = load i64, i64* %252, align 4
  %278 = and i64 %277, %255
  %.not.i871.1.i = icmp eq i64 %278, 0
  br i1 %.not.i871.1.i, label %panic.i872.i, label %__barray_check_bounds.exit875.1.i

__barray_check_bounds.exit875.1.i:                ; preds = %__barray_check_bounds.exit870.1.i
  %279 = xor i64 %277, %255
  store i64 %279, i64* %252, align 4
  store i64 %272, i64* %286, align 4
  %280 = load i64, i64* %121, align 4
  %281 = and i64 %280, %124
  %.not.i876.1.i = icmp eq i64 %281, 0
  br i1 %.not.i876.1.i, label %panic.i877.i, label %__barray_mask_return.exit878.1.i

__barray_mask_return.exit878.1.i:                 ; preds = %__barray_check_bounds.exit875.1.i
  %282 = xor i64 %280, %124
  store i64 %282, i64* %121, align 4
  store i64 %276, i64* %127, align 4
  %283 = load i64, i64* %199, align 4
  %284 = and i64 %283, %202
  %.not.i.i899.i = icmp eq i64 %284, 0
  br i1 %.not.i.i899.i, label %__barray_mask_borrow.exit.i901.i, label %panic.i.i900.i

panic.i880.i:                                     ; preds = %__barray_mask_return.exit850.1.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit881.i:                   ; preds = %__barray_mask_return.exit850.1.i
  %285 = xor i64 %253, %255
  store i64 %285, i64* %252, align 4
  %286 = getelementptr inbounds i64, i64* %.fca.0.extract308.i.i, i64 %250
  %287 = load i64, i64* %121, align 4
  %288 = and i64 %287, %124
  %.not.i882.i = icmp eq i64 %288, 0
  br i1 %.not.i882.i, label %__barray_mask_borrow.exit884.i, label %panic.i883.i

panic.i883.i:                                     ; preds = %__barray_mask_borrow.exit881.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit884.i:                   ; preds = %__barray_mask_borrow.exit881.i
  %289 = load i64, i64* %286, align 4
  %290 = xor i64 %287, %124
  store i64 %290, i64* %121, align 4
  %291 = load i64, i64* %127, align 4
  %292 = tail call fastcc { i64, i64, i64 } @__hugr__.ccx.1244(i64 %291, i64 %289, i64 %.fca.1.extract.i25.i)
  %293 = extractvalue { i64, i64, i64 } %292, 0
  %294 = load i64, i64* %252, align 4
  %295 = and i64 %294, %255
  %.not.i885.i = icmp eq i64 %295, 0
  br i1 %.not.i885.i, label %panic.i886.i, label %__barray_mask_return.exit887.i

panic.i886.i:                                     ; preds = %__barray_mask_borrow.exit884.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit887.i:                   ; preds = %__barray_mask_borrow.exit884.i
  %296 = extractvalue { i64, i64, i64 } %292, 1
  %297 = xor i64 %294, %255
  store i64 %297, i64* %252, align 4
  store i64 %296, i64* %286, align 4
  %298 = load i64, i64* %174, align 4
  %299 = and i64 %298, %177
  %.not.i888.i = icmp eq i64 %299, 0
  br i1 %.not.i888.i, label %__barray_mask_borrow.exit890.i, label %panic.i889.i

panic.i889.i:                                     ; preds = %__barray_mask_return.exit887.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit890.i:                   ; preds = %__barray_mask_return.exit887.i
  %300 = xor i64 %298, %177
  store i64 %300, i64* %174, align 4
  %301 = load i64, i64* %180, align 4
  tail call void @___rxy(i64 %301, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %234, i64 %301, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %234, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %301, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %301, double 0xBFF921FB54442D18)
  %302 = load i64, i64* %174, align 4
  %303 = and i64 %302, %177
  %.not.i893.i = icmp eq i64 %303, 0
  br i1 %.not.i893.i, label %panic.i894.i, label %__barray_mask_return.exit895.i

panic.i894.i:                                     ; preds = %__barray_mask_borrow.exit890.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit895.i:                   ; preds = %__barray_mask_borrow.exit890.i
  %304 = xor i64 %302, %177
  store i64 %304, i64* %174, align 4
  store i64 %301, i64* %180, align 4
  %305 = load i64, i64* %121, align 4
  %306 = and i64 %305, %124
  %.not.i896.i = icmp eq i64 %306, 0
  br i1 %.not.i896.i, label %panic.i897.i, label %__barray_mask_return.exit898.i

panic.i897.i:                                     ; preds = %__barray_mask_return.exit895.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit898.i:                   ; preds = %__barray_mask_return.exit895.i
  %307 = xor i64 %305, %124
  store i64 %307, i64* %121, align 4
  store i64 %293, i64* %127, align 4
  %308 = load i64, i64* %199, align 4
  %309 = and i64 %308, %202
  %.not.i859.i = icmp eq i64 %309, 0
  br i1 %.not.i859.i, label %__barray_mask_borrow.exit861.i, label %panic.i860.i

panic.i.i900.i:                                   ; preds = %__barray_mask_return.exit878.1.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit.i901.i:                 ; preds = %__barray_mask_return.exit878.1.i
  %310 = xor i64 %283, %202
  store i64 %310, i64* %199, align 4
  %311 = load i64, i64* %205, align 4
  %312 = load i64, i64* %95, align 4
  %313 = and i64 %312, %98
  %.not.i692.i.i = icmp eq i64 %313, 0
  br i1 %.not.i692.i.i, label %__barray_mask_borrow.exit694.i.i, label %panic.i693.i.i

panic.i693.i.i:                                   ; preds = %__barray_mask_borrow.exit.i901.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit694.i.i:                 ; preds = %__barray_mask_borrow.exit.i901.i
  %314 = xor i64 %312, %98
  store i64 %314, i64* %95, align 4
  %315 = load i64, i64* %121, align 4
  %316 = and i64 %315, %124
  %.not.i695.i.i = icmp eq i64 %316, 0
  br i1 %.not.i695.i.i, label %__barray_mask_borrow.exit697.i.i, label %panic.i696.i.i

panic.i696.i.i:                                   ; preds = %__barray_mask_borrow.exit694.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit697.i.i:                 ; preds = %__barray_mask_borrow.exit694.i.i
  %317 = load i64, i64* %101, align 4
  %318 = xor i64 %315, %124
  store i64 %318, i64* %121, align 4
  %319 = load i64, i64* %127, align 4
  %320 = tail call fastcc { i64, i64, i64 } @__hugr__.ccx.1244(i64 %317, i64 %311, i64 %319)
  %321 = extractvalue { i64, i64, i64 } %320, 0
  %322 = extractvalue { i64, i64, i64 } %320, 2
  %323 = load i64, i64* %199, align 4
  %324 = and i64 %323, %202
  %.not.i698.i.i = icmp eq i64 %324, 0
  br i1 %.not.i698.i.i, label %panic.i699.i.i, label %__barray_mask_return.exit.i903.i

panic.i699.i.i:                                   ; preds = %__barray_mask_borrow.exit697.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit.i903.i:                 ; preds = %__barray_mask_borrow.exit697.i.i
  %325 = extractvalue { i64, i64, i64 } %320, 1
  %326 = xor i64 %323, %202
  store i64 %326, i64* %199, align 4
  store i64 %325, i64* %205, align 4
  %327 = load i64, i64* %95, align 4
  %328 = and i64 %327, %98
  %.not.i700.i902.i = icmp eq i64 %328, 0
  br i1 %.not.i700.i902.i, label %panic.i701.i904.i, label %__barray_mask_return.exit702.i.i

panic.i701.i904.i:                                ; preds = %__barray_mask_return.exit.i903.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit702.i.i:                 ; preds = %__barray_mask_return.exit.i903.i
  %329 = xor i64 %327, %98
  store i64 %329, i64* %95, align 4
  store i64 %321, i64* %101, align 4
  %330 = load i64, i64* %121, align 4
  %331 = and i64 %330, %124
  %.not.i703.i905.i = icmp eq i64 %331, 0
  br i1 %.not.i703.i905.i, label %panic.i704.i906.i, label %__barray_mask_return.exit705.i.i

panic.i704.i906.i:                                ; preds = %__barray_mask_return.exit702.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit705.i.i:                 ; preds = %__barray_mask_return.exit702.i.i
  %332 = xor i64 %330, %124
  store i64 %332, i64* %121, align 4
  store i64 %322, i64* %127, align 4
  %333 = load i64, i64* %95, align 4
  %334 = and i64 %333, %98
  %.not.i764.i.i = icmp eq i64 %334, 0
  br i1 %.not.i764.i.i, label %__barray_mask_borrow.exit766.i.i, label %panic.i765.i.i

panic.i765.i.i:                                   ; preds = %__barray_mask_return.exit705.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit766.i.i:                 ; preds = %__barray_mask_return.exit705.i.i
  %335 = xor i64 %333, %98
  store i64 %335, i64* %95, align 4
  %336 = load i64, i64* %101, align 4
  %337 = load i64, i64* %121, align 4
  %338 = and i64 %337, %124
  %.not.i767.i.i = icmp eq i64 %338, 0
  br i1 %.not.i767.i.i, label %__barray_mask_borrow.exit769.i.i, label %panic.i768.i.i

panic.i768.i.i:                                   ; preds = %__barray_mask_borrow.exit766.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit769.i.i:                 ; preds = %__barray_mask_borrow.exit766.i.i
  %339 = xor i64 %337, %124
  store i64 %339, i64* %121, align 4
  %340 = load i64, i64* %127, align 4
  %341 = load i64, i64* %161, align 4
  %342 = and i64 %341, %164
  %.not.i770.i.i = icmp eq i64 %342, 0
  br i1 %.not.i770.i.i, label %__barray_mask_borrow.exit772.i.i, label %panic.i771.i.i

panic.i771.i.i:                                   ; preds = %__barray_mask_borrow.exit769.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit772.i.i:                 ; preds = %__barray_mask_borrow.exit769.i.i
  %343 = xor i64 %341, %164
  store i64 %343, i64* %161, align 4
  %344 = load i64, i64* %167, align 4
  %345 = load i64, i64* %174, align 4
  %346 = and i64 %345, %177
  %.not.i773.i.i = icmp eq i64 %346, 0
  br i1 %.not.i773.i.i, label %__barray_mask_borrow.exit775.i.i, label %panic.i774.i.i

panic.i774.i.i:                                   ; preds = %__barray_mask_borrow.exit772.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit775.i.i:                 ; preds = %__barray_mask_borrow.exit772.i.i
  %347 = xor i64 %345, %177
  store i64 %347, i64* %174, align 4
  %348 = load i64, i64* %199, align 4
  %349 = and i64 %348, %202
  %.not.i776.i.i = icmp eq i64 %349, 0
  br i1 %.not.i776.i.i, label %__barray_mask_borrow.exit778.i.i, label %panic.i777.i.i

panic.i777.i.i:                                   ; preds = %__barray_mask_borrow.exit775.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit778.i.i:                 ; preds = %__barray_mask_borrow.exit775.i.i
  %350 = load i64, i64* %180, align 4
  %351 = xor i64 %348, %202
  store i64 %351, i64* %199, align 4
  %352 = load i64, i64* %205, align 4
  tail call void @___rxy(i64 %340, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %344, i64 %340, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %344, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %340, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %340, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %352, double 0x400921FB54442D18, double 0.000000e+00)
  %353 = tail call fastcc { i64, i64, i64 } @__hugr__.ccx.1244(i64 %234, i64 %350, i64 %336)
  %354 = extractvalue { i64, i64, i64 } %353, 0
  %355 = extractvalue { i64, i64, i64 } %353, 1
  %356 = load i64, i64* %95, align 4
  %357 = and i64 %356, %98
  %.not.i785.i.i = icmp eq i64 %357, 0
  br i1 %.not.i785.i.i, label %panic.i786.i.i, label %__barray_mask_return.exit787.i.i

panic.i786.i.i:                                   ; preds = %__barray_mask_borrow.exit778.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit787.i.i:                 ; preds = %__barray_mask_borrow.exit778.i.i
  %358 = extractvalue { i64, i64, i64 } %353, 2
  %359 = xor i64 %356, %98
  store i64 %359, i64* %95, align 4
  store i64 %358, i64* %101, align 4
  %360 = load i64, i64* %121, align 4
  %361 = and i64 %360, %124
  %.not.i788.i.i = icmp eq i64 %361, 0
  br i1 %.not.i788.i.i, label %panic.i789.i.i, label %__barray_mask_return.exit790.i.i

panic.i789.i.i:                                   ; preds = %__barray_mask_return.exit787.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit790.i.i:                 ; preds = %__barray_mask_return.exit787.i.i
  %362 = xor i64 %360, %124
  store i64 %362, i64* %121, align 4
  store i64 %340, i64* %127, align 4
  %363 = load i64, i64* %161, align 4
  %364 = and i64 %363, %164
  %.not.i791.i.i = icmp eq i64 %364, 0
  br i1 %.not.i791.i.i, label %panic.i792.i.i, label %__barray_mask_return.exit793.i.i

panic.i792.i.i:                                   ; preds = %__barray_mask_return.exit790.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit793.i.i:                 ; preds = %__barray_mask_return.exit790.i.i
  %365 = xor i64 %363, %164
  store i64 %365, i64* %161, align 4
  store i64 %344, i64* %167, align 4
  %366 = load i64, i64* %107, align 4
  %367 = and i64 %366, %110
  %.not.i794.i.i = icmp eq i64 %367, 0
  br i1 %.not.i794.i.i, label %__barray_mask_borrow.exit796.i.i, label %panic.i795.i.i

panic.i795.i.i:                                   ; preds = %__barray_mask_return.exit793.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit796.i.i:                 ; preds = %__barray_mask_return.exit793.i.i
  %368 = xor i64 %366, %110
  store i64 %368, i64* %107, align 4
  %369 = load i64, i64* %113, align 4
  %370 = load i64, i64* %95, align 4
  %371 = and i64 %370, %98
  %.not.i797.i.i = icmp eq i64 %371, 0
  br i1 %.not.i797.i.i, label %__barray_mask_borrow.exit799.i.i, label %panic.i798.i.i

panic.i798.i.i:                                   ; preds = %__barray_mask_borrow.exit796.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit799.i.i:                 ; preds = %__barray_mask_borrow.exit796.i.i
  %372 = xor i64 %370, %98
  store i64 %372, i64* %95, align 4
  %373 = load i64, i64* %101, align 4
  %374 = load i64, i64* %121, align 4
  %375 = and i64 %374, %124
  %.not.i800.i.i = icmp eq i64 %375, 0
  br i1 %.not.i800.i.i, label %__barray_mask_borrow.exit802.i.i, label %panic.i801.i.i

panic.i801.i.i:                                   ; preds = %__barray_mask_borrow.exit799.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit802.i.i:                 ; preds = %__barray_mask_borrow.exit799.i.i
  %376 = xor i64 %374, %124
  store i64 %376, i64* %121, align 4
  %377 = load i64, i64* %127, align 4
  %378 = load i64, i64* %174, align 4
  %379 = and i64 %378, %177
  %.not.i803.i.i = icmp eq i64 %379, 0
  br i1 %.not.i803.i.i, label %panic.i804.i.i, label %__barray_mask_return.exit805.i.i

panic.i804.i.i:                                   ; preds = %__barray_mask_borrow.exit802.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit805.i.i:                 ; preds = %__barray_mask_borrow.exit802.i.i
  %380 = xor i64 %378, %177
  store i64 %380, i64* %174, align 4
  store i64 %355, i64* %180, align 4
  %381 = load i64, i64* %199, align 4
  %382 = and i64 %381, %202
  %.not.i806.i.i = icmp eq i64 %382, 0
  br i1 %.not.i806.i.i, label %panic.i807.i.i, label %__barray_mask_return.exit808.i.i

panic.i807.i.i:                                   ; preds = %__barray_mask_return.exit805.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit808.i.i:                 ; preds = %__barray_mask_return.exit805.i.i
  %383 = xor i64 %381, %202
  store i64 %383, i64* %199, align 4
  store i64 %352, i64* %205, align 4
  %384 = load i64, i64* %130, align 4
  %385 = and i64 %384, %133
  %.not.i809.i.i = icmp eq i64 %385, 0
  br i1 %.not.i809.i.i, label %__barray_mask_borrow.exit811.i.i, label %panic.i810.i.i

panic.i810.i.i:                                   ; preds = %__barray_mask_return.exit808.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit811.i.i:                 ; preds = %__barray_mask_return.exit808.i.i
  %386 = xor i64 %384, %133
  store i64 %386, i64* %130, align 4
  %387 = load i64, i64* %174, align 4
  %388 = and i64 %387, %177
  %.not.i812.i.i = icmp eq i64 %388, 0
  br i1 %.not.i812.i.i, label %__barray_mask_borrow.exit814.i.i, label %panic.i813.i.i

panic.i813.i.i:                                   ; preds = %__barray_mask_borrow.exit811.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit814.i.i:                 ; preds = %__barray_mask_borrow.exit811.i.i
  %389 = load i64, i64* %136, align 4
  %390 = xor i64 %387, %177
  store i64 %390, i64* %174, align 4
  %391 = load i64, i64* %180, align 4
  tail call void @___rxy(i64 %373, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %377, i64 %373, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %377, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %373, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %373, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %391, double 0x400921FB54442D18, double 0.000000e+00)
  %392 = tail call fastcc { i64, i64, i64 } @__hugr__.ccx.1244(i64 %389, i64 %369, i64 %354)
  %393 = extractvalue { i64, i64, i64 } %392, 0
  %394 = load i64, i64* %107, align 4
  %395 = and i64 %394, %110
  %.not.i821.i.i = icmp eq i64 %395, 0
  br i1 %.not.i821.i.i, label %panic.i822.i.i, label %__barray_mask_return.exit823.i.i

panic.i822.i.i:                                   ; preds = %__barray_mask_borrow.exit814.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit823.i.i:                 ; preds = %__barray_mask_borrow.exit814.i.i
  %396 = extractvalue { i64, i64, i64 } %392, 1
  %397 = xor i64 %394, %110
  store i64 %397, i64* %107, align 4
  store i64 %396, i64* %113, align 4
  %398 = load i64, i64* %95, align 4
  %399 = and i64 %398, %98
  %.not.i824.i.i = icmp eq i64 %399, 0
  br i1 %.not.i824.i.i, label %panic.i825.i.i, label %__barray_mask_return.exit826.i.i

panic.i825.i.i:                                   ; preds = %__barray_mask_return.exit823.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit826.i.i:                 ; preds = %__barray_mask_return.exit823.i.i
  %400 = xor i64 %398, %98
  store i64 %400, i64* %95, align 4
  store i64 %373, i64* %101, align 4
  %401 = load i64, i64* %121, align 4
  %402 = and i64 %401, %124
  %.not.i827.i.i = icmp eq i64 %402, 0
  br i1 %.not.i827.i.i, label %panic.i828.i.i, label %__barray_mask_return.exit829.i.i

panic.i828.i.i:                                   ; preds = %__barray_mask_return.exit826.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit829.i.i:                 ; preds = %__barray_mask_return.exit826.i.i
  %403 = xor i64 %401, %124
  store i64 %403, i64* %121, align 4
  store i64 %377, i64* %127, align 4
  %404 = load i64, i64* %130, align 4
  %405 = and i64 %404, %133
  %.not.i830.i.i = icmp eq i64 %405, 0
  br i1 %.not.i830.i.i, label %panic.i831.i.i, label %__barray_mask_return.exit832.i.i

panic.i831.i.i:                                   ; preds = %__barray_mask_return.exit829.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit832.i.i:                 ; preds = %__barray_mask_return.exit829.i.i
  %406 = xor i64 %404, %133
  store i64 %406, i64* %130, align 4
  store i64 %393, i64* %136, align 4
  %407 = load i64, i64* %174, align 4
  %408 = and i64 %407, %177
  %.not.i833.i.i = icmp eq i64 %408, 0
  br i1 %.not.i833.i.i, label %panic.i834.i.i, label %"__hugr__.$_block_2_layers$$n(4).3218.exit.i"

panic.i834.i.i:                                   ; preds = %__barray_mask_return.exit832.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

"__hugr__.$_block_2_layers$$n(4).3218.exit.i":    ; preds = %__barray_mask_return.exit832.i.i
  %409 = extractvalue { i64, i64, i64 } %392, 2
  %410 = xor i64 %407, %177
  store i64 %410, i64* %174, align 4
  store i64 %391, i64* %180, align 4
  %411 = load i64, i64* %95, align 4
  %412 = and i64 %411, %98
  %.not.i908.i = icmp eq i64 %412, 0
  br i1 %.not.i908.i, label %__barray_mask_borrow.exit910.i, label %panic.i909.i

panic.i909.i:                                     ; preds = %"__hugr__.$_block_2_layers$$n(4).3218.exit.i"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit910.i:                   ; preds = %"__hugr__.$_block_2_layers$$n(4).3218.exit.i"
  %413 = xor i64 %411, %98
  store i64 %413, i64* %95, align 4
  %414 = load i64, i64* %101, align 4
  tail call void @___rxy(i64 %409, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %414, i64 %409, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %414, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %409, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %409, double 0xBFF921FB54442D18)
  %415 = load i64, i64* %95, align 4
  %416 = and i64 %415, %98
  %.not.i913.i = icmp eq i64 %416, 0
  br i1 %.not.i913.i, label %panic.i914.i, label %__barray_mask_return.exit915.i

panic.i914.i:                                     ; preds = %__barray_mask_borrow.exit910.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit915.i:                   ; preds = %__barray_mask_borrow.exit910.i
  %417 = xor i64 %415, %98
  store i64 %417, i64* %95, align 4
  store i64 %414, i64* %101, align 4
  %418 = tail call i8* @heap_alloc(i64 0)
  %419 = tail call i8* @heap_alloc(i64 0)
  br label %__barray_check_bounds.exit.i.i.i

__barray_check_bounds.exit.i.i.i:                 ; preds = %__barray_mask_return.exit14.i.i.i, %__barray_mask_return.exit915.i
  %"3555_0.023.i.i.i" = phi i64 [ 0, %__barray_mask_return.exit915.i ], [ %420, %__barray_mask_return.exit14.i.i.i ]
  %420 = add nuw nsw i64 %"3555_0.023.i.i.i", 1
  %421 = add i64 %"3555_0.023.i.i.i", %.fca.2.extract310.i.i
  %422 = lshr i64 %421, 6
  %423 = getelementptr inbounds i64, i64* %.fca.1.extract309.i.i, i64 %422
  %424 = load i64, i64* %423, align 4
  %425 = and i64 %421, 63
  %426 = shl nuw i64 1, %425
  %427 = and i64 %426, %424
  %.not.i.i.i.i = icmp eq i64 %427, 0
  br i1 %.not.i.i.i.i, label %__barray_check_bounds.exit2.i.i.i, label %panic.i.i.i.i

panic.i.i.i.i:                                    ; preds = %__barray_check_bounds.exit.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit2.i.i.i:                ; preds = %__barray_check_bounds.exit.i.i.i
  %428 = xor i64 %426, %424
  store i64 %428, i64* %423, align 4
  %429 = getelementptr inbounds i64, i64* %.fca.0.extract308.i.i, i64 %421
  %430 = load i64, i64* %429, align 4
  %431 = add i64 %"3555_0.023.i.i.i", %.fca.2.extract313.i.i
  %432 = lshr i64 %431, 6
  %433 = getelementptr inbounds i64, i64* %.fca.1.extract312.i.i, i64 %432
  %434 = load i64, i64* %433, align 4
  %435 = and i64 %431, 63
  %436 = shl nuw i64 1, %435
  %437 = and i64 %434, %436
  %.not.i3.i.i.i = icmp eq i64 %437, 0
  br i1 %.not.i3.i.i.i, label %__barray_check_bounds.exit7.i.i.i, label %panic.i4.i.i.i

panic.i4.i.i.i:                                   ; preds = %__barray_check_bounds.exit2.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit7.i.i.i:                ; preds = %__barray_check_bounds.exit2.i.i.i
  %438 = xor i64 %434, %436
  store i64 %438, i64* %433, align 4
  %439 = getelementptr inbounds i64, i64* %.fca.0.extract311.i.i, i64 %431
  %440 = load i64, i64* %439, align 4
  tail call void @___rxy(i64 %430, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %440, i64 %430, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %440, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %430, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %430, double 0xBFF921FB54442D18)
  %441 = load i64, i64* %423, align 4
  %442 = and i64 %441, %426
  %.not.i8.i.i.i = icmp eq i64 %442, 0
  br i1 %.not.i8.i.i.i, label %panic.i9.i.i.i, label %__barray_check_bounds.exit11.i.i.i

panic.i9.i.i.i:                                   ; preds = %__barray_check_bounds.exit7.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit11.i.i.i:               ; preds = %__barray_check_bounds.exit7.i.i.i
  %443 = xor i64 %441, %426
  store i64 %443, i64* %423, align 4
  store i64 %430, i64* %429, align 4
  %444 = load i64, i64* %433, align 4
  %445 = and i64 %444, %436
  %.not.i12.i.i.i = icmp eq i64 %445, 0
  br i1 %.not.i12.i.i.i, label %panic.i13.i.i.i, label %__barray_mask_return.exit14.i.i.i

panic.i13.i.i.i:                                  ; preds = %__barray_check_bounds.exit11.i.i.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit14.i.i.i:                ; preds = %__barray_check_bounds.exit11.i.i.i
  %446 = xor i64 %444, %436
  store i64 %446, i64* %433, align 4
  store i64 %440, i64* %439, align 4
  %exitcond.not.i.i.i = icmp eq i64 %420, 4
  br i1 %exitcond.not.i.i.i, label %"__hugr__.$ripple_carry_adder$$n(4).2370.exit", label %__barray_check_bounds.exit.i.i.i

"__hugr__.$ripple_carry_adder$$n(4).2370.exit":   ; preds = %__barray_mask_return.exit14.i.i.i
  tail call void @heap_free(i8* %418)
  tail call void @___qfree(i64 %409)
  %447 = extractvalue { i64, i64, i64 } %292, 2
  %448 = insertvalue { { i64*, i64*, i64 }, i64 } poison, { i64*, i64*, i64 } %34, 0
  %"3882_023.fca.1.insert155.i" = insertvalue { { i64*, i64*, i64 }, i64 } %448, i64 0, 1
  %449 = tail call fastcc { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } @"__hugr__.$__next__$$t(qubit)$n(4).3884"({ { i64*, i64*, i64 }, i64 } %"3882_023.fca.1.insert155.i")
  %.fca.0.extract99156.i = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %449, 0
  br i1 %.fca.0.extract99156.i, label %cond_3965_case_1.i, label %"__hugr__.$discard_array$$n(4).3852.exit"

cond_3965_case_1.i:                               ; preds = %"__hugr__.$ripple_carry_adder$$n(4).2370.exit", %cond_3965_case_1.i
  %450 = phi { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } [ %456, %cond_3965_case_1.i ], [ %449, %"__hugr__.$ripple_carry_adder$$n(4).2370.exit" ]
  %451 = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %450, 1
  %.fca.1.0.0.0.extract.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %451, 0, 0, 0
  %.fca.1.0.0.1.extract.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %451, 0, 0, 1
  %.fca.1.0.0.2.extract.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %451, 0, 0, 2
  %.fca.1.0.1.extract.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %451, 0, 1
  %.fca.1.1.extract.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %451, 1
  tail call void @___qfree(i64 %.fca.1.1.extract.i)
  %452 = insertvalue { i64*, i64*, i64 } poison, i64* %.fca.1.0.0.0.extract.i, 0
  %453 = insertvalue { i64*, i64*, i64 } %452, i64* %.fca.1.0.0.1.extract.i, 1
  %454 = insertvalue { i64*, i64*, i64 } %453, i64 %.fca.1.0.0.2.extract.i, 2
  %455 = insertvalue { { i64*, i64*, i64 }, i64 } poison, { i64*, i64*, i64 } %454, 0
  %"3882_023.fca.1.insert.i" = insertvalue { { i64*, i64*, i64 }, i64 } %455, i64 %.fca.1.0.1.extract.i, 1
  %456 = tail call fastcc { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } @"__hugr__.$__next__$$t(qubit)$n(4).3884"({ { i64*, i64*, i64 }, i64 } %"3882_023.fca.1.insert.i")
  %.fca.0.extract99.i = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %456, 0
  br i1 %.fca.0.extract99.i, label %cond_3965_case_1.i, label %"__hugr__.$discard_array$$n(4).3852.exit"

"__hugr__.$discard_array$$n(4).3852.exit":        ; preds = %cond_3965_case_1.i, %"__hugr__.$ripple_carry_adder$$n(4).2370.exit"
  %457 = tail call i8* @heap_alloc(i64 96)
  %458 = bitcast i8* %457 to { i1, i64, i1 }*
  %459 = tail call i8* @heap_alloc(i64 8)
  %460 = bitcast i8* %459 to i64*
  store i64 -1, i64* %460, align 1
  %"3996_011.fca.0.0.insert9.i" = insertvalue { { i64*, i64*, i64 }, i64 } poison, i64* %.fca.0.extract308.i.i, 0, 0
  %"3996_011.fca.0.1.insert10.i" = insertvalue { { i64*, i64*, i64 }, i64 } %"3996_011.fca.0.0.insert9.i", i64* %.fca.1.extract309.i.i, 0, 1
  %"3996_011.fca.0.2.insert11.i" = insertvalue { { i64*, i64*, i64 }, i64 } %"3996_011.fca.0.1.insert10.i", i64 %.fca.2.extract310.i.i, 0, 2
  %"3996_011.fca.1.insert12.i" = insertvalue { { i64*, i64*, i64 }, i64 } %"3996_011.fca.0.2.insert11.i", i64 0, 1
  %461 = tail call fastcc { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } @"__hugr__.$__next__$$t(qubit)$n(4).3884"({ { i64*, i64*, i64 }, i64 } %"3996_011.fca.1.insert12.i")
  %.fca.0.extract9713.i = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %461, 0
  br i1 %.fca.0.extract9713.i, label %cond_4002_case_1.preheader.i, label %"__hugr__.$measure_array$$n(4).3981.exit"

cond_4002_case_1.preheader.i:                     ; preds = %"__hugr__.$discard_array$$n(4).3852.exit"
  %462 = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %461, 1
  %.fca.1.extract93.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %462, 1
  %lazy_measure.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract93.i)
  tail call void @___qfree(i64 %.fca.1.extract93.i)
  %463 = load i64, i64* %460, align 4
  %464 = and i64 %463, 1
  %.not.i.i220 = icmp eq i64 %464, 0
  br i1 %.not.i.i220, label %panic.i.i221, label %cond_exit_4002.i

out_of_bounds.i.i:                                ; preds = %cond_exit_4002.3.i
  %465 = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %492, 1
  %.fca.1.extract93.4.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %465, 1
  %lazy_measure.4.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract93.4.i)
  tail call void @___qfree(i64 %.fca.1.extract93.4.i)
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @"e_Index out .DD115165.0", i64 0, i64 0))
  unreachable

panic.i.i221:                                     ; preds = %cond_4002_case_1.3.i, %cond_4002_case_1.2.i, %cond_4002_case_1.1.i, %cond_4002_case_1.preheader.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

cond_exit_4002.i:                                 ; preds = %cond_4002_case_1.preheader.i
  %"4016_054.fca.1.insert.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.i, 1
  %466 = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %462, 0
  %467 = xor i64 %463, 1
  store i64 %467, i64* %460, align 4
  store { i1, i64, i1 } %"4016_054.fca.1.insert.i", { i1, i64, i1 }* %458, align 4
  %468 = tail call fastcc { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } @"__hugr__.$__next__$$t(qubit)$n(4).3884"({ { i64*, i64*, i64 }, i64 } %466)
  %.fca.0.extract97.i = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %468, 0
  br i1 %.fca.0.extract97.i, label %cond_4002_case_1.1.i, label %"__hugr__.$measure_array$$n(4).3981.exit"

cond_4002_case_1.1.i:                             ; preds = %cond_exit_4002.i
  %469 = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %468, 1
  %.fca.1.extract93.1.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %469, 1
  %lazy_measure.1.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract93.1.i)
  tail call void @___qfree(i64 %.fca.1.extract93.1.i)
  %470 = load i64, i64* %460, align 4
  %471 = and i64 %470, 2
  %.not.i.1.i222 = icmp eq i64 %471, 0
  br i1 %.not.i.1.i222, label %panic.i.i221, label %cond_exit_4002.1.i

cond_exit_4002.1.i:                               ; preds = %cond_4002_case_1.1.i
  %"4016_054.fca.1.insert.1.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.1.i, 1
  %472 = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %469, 0
  %473 = xor i64 %470, 2
  store i64 %473, i64* %460, align 4
  %474 = getelementptr inbounds i8, i8* %457, i64 24
  %475 = bitcast i8* %474 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"4016_054.fca.1.insert.1.i", { i1, i64, i1 }* %475, align 4
  %476 = tail call fastcc { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } @"__hugr__.$__next__$$t(qubit)$n(4).3884"({ { i64*, i64*, i64 }, i64 } %472)
  %.fca.0.extract97.1.i = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %476, 0
  br i1 %.fca.0.extract97.1.i, label %cond_4002_case_1.2.i, label %"__hugr__.$measure_array$$n(4).3981.exit"

cond_4002_case_1.2.i:                             ; preds = %cond_exit_4002.1.i
  %477 = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %476, 1
  %.fca.1.extract93.2.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %477, 1
  %lazy_measure.2.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract93.2.i)
  tail call void @___qfree(i64 %.fca.1.extract93.2.i)
  %478 = load i64, i64* %460, align 4
  %479 = and i64 %478, 4
  %.not.i.2.i223 = icmp eq i64 %479, 0
  br i1 %.not.i.2.i223, label %panic.i.i221, label %cond_exit_4002.2.i

cond_exit_4002.2.i:                               ; preds = %cond_4002_case_1.2.i
  %"4016_054.fca.1.insert.2.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.2.i, 1
  %480 = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %477, 0
  %481 = xor i64 %478, 4
  store i64 %481, i64* %460, align 4
  %482 = getelementptr inbounds i8, i8* %457, i64 48
  %483 = bitcast i8* %482 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"4016_054.fca.1.insert.2.i", { i1, i64, i1 }* %483, align 4
  %484 = tail call fastcc { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } @"__hugr__.$__next__$$t(qubit)$n(4).3884"({ { i64*, i64*, i64 }, i64 } %480)
  %.fca.0.extract97.2.i = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %484, 0
  br i1 %.fca.0.extract97.2.i, label %cond_4002_case_1.3.i, label %"__hugr__.$measure_array$$n(4).3981.exit"

cond_4002_case_1.3.i:                             ; preds = %cond_exit_4002.2.i
  %485 = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %484, 1
  %.fca.1.extract93.3.i = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %485, 1
  %lazy_measure.3.i = tail call i64 @___lazy_measure(i64 %.fca.1.extract93.3.i)
  tail call void @___qfree(i64 %.fca.1.extract93.3.i)
  %486 = load i64, i64* %460, align 4
  %487 = and i64 %486, 8
  %.not.i.3.i224 = icmp eq i64 %487, 0
  br i1 %.not.i.3.i224, label %panic.i.i221, label %cond_exit_4002.3.i

cond_exit_4002.3.i:                               ; preds = %cond_4002_case_1.3.i
  %"4016_054.fca.1.insert.3.i" = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %lazy_measure.3.i, 1
  %488 = extractvalue { { { i64*, i64*, i64 }, i64 }, i64 } %485, 0
  %489 = xor i64 %486, 8
  store i64 %489, i64* %460, align 4
  %490 = getelementptr inbounds i8, i8* %457, i64 72
  %491 = bitcast i8* %490 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"4016_054.fca.1.insert.3.i", { i1, i64, i1 }* %491, align 4
  %492 = tail call fastcc { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } @"__hugr__.$__next__$$t(qubit)$n(4).3884"({ { i64*, i64*, i64 }, i64 } %488)
  %.fca.0.extract97.3.i = extractvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %492, 0
  br i1 %.fca.0.extract97.3.i, label %out_of_bounds.i.i, label %"__hugr__.$measure_array$$n(4).3981.exit"

"__hugr__.$measure_array$$n(4).3981.exit":        ; preds = %"__hugr__.$discard_array$$n(4).3852.exit", %cond_exit_4002.i, %cond_exit_4002.1.i, %cond_exit_4002.2.i, %cond_exit_4002.3.i
  %493 = tail call i8* @heap_alloc(i64 128)
  %494 = tail call i8* @heap_alloc(i64 8)
  %495 = bitcast i8* %494 to i64*
  store i64 0, i64* %495, align 1
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(128) %493, i8 0, i64 128, i1 false)
  %496 = load i64, i64* %460, align 4
  %497 = and i64 %496, 15
  store i64 %497, i64* %460, align 4
  %498 = icmp eq i64 %497, 0
  br i1 %498, label %__barray_check_none_borrowed.exit, label %mask_block_err.i

__barray_check_none_borrowed.exit:                ; preds = %"__hugr__.$measure_array$$n(4).3981.exit"
  %499 = tail call i8* @heap_alloc(i64 96)
  %500 = bitcast i8* %499 to { i1, i64, i1 }*
  %501 = tail call i8* @heap_alloc(i64 8)
  %502 = bitcast i8* %501 to i64*
  store i64 0, i64* %502, align 1
  %503 = bitcast i8* %493 to { i1, { i1, i64, i1 } }*
  %504 = load { i1, i64, i1 }, { i1, i64, i1 }* %458, align 4
  %.fca.0.extract118.i = extractvalue { i1, i64, i1 } %504, 0
  %.fca.1.extract119.i = extractvalue { i1, i64, i1 } %504, 1
  br i1 %.fca.0.extract118.i, label %cond_1995_case_1.i, label %506

mask_block_err.i:                                 ; preds = %"__hugr__.$measure_array$$n(4).3981.exit"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_1995_case_1.i:                               ; preds = %__barray_check_none_borrowed.exit
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i)
  %505 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i, 1
  br label %506

506:                                              ; preds = %__barray_check_none_borrowed.exit, %cond_1995_case_1.i
  %.pn.i = phi { i1, i64, i1 } [ %505, %cond_1995_case_1.i ], [ %504, %__barray_check_none_borrowed.exit ]
  %507 = load i64, i64* %495, align 4
  %508 = and i64 %507, 1
  %.not.i.i225 = icmp eq i64 %508, 0
  br i1 %.not.i.i225, label %cond_1950_case_1.i, label %panic.i.i226

panic.i.i226:                                     ; preds = %544, %530, %516, %506
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

cond_1950_case_1.i:                               ; preds = %506
  %"03.sroa.6.0.i" = extractvalue { i1, i64, i1 } %.pn.i, 2
  %"16.fca.2.insert.i" = insertvalue { i1, i64, i1 } %504, i1 %"03.sroa.6.0.i", 2
  %509 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i", 1
  %510 = bitcast i8* %493 to i1*
  %511 = load i1, i1* %510, align 1
  store { i1, { i1, i64, i1 } } %509, { i1, { i1, i64, i1 } }* %503, align 4
  br i1 %511, label %cond_1922_case_1.i, label %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit"

cond_1922_case_1.i:                               ; preds = %cond_1950_case_1.i.3, %cond_1950_case_1.i.2, %cond_1950_case_1.i.1, %cond_1950_case_1.i
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.2F17E0A9.0", i64 0, i64 0))
  unreachable

"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit": ; preds = %cond_1950_case_1.i
  store { i1, i64, i1 } %"16.fca.2.insert.i", { i1, i64, i1 }* %500, align 4
  %512 = getelementptr inbounds i8, i8* %457, i64 24
  %513 = bitcast i8* %512 to { i1, i64, i1 }*
  %514 = load { i1, i64, i1 }, { i1, i64, i1 }* %513, align 4
  %.fca.0.extract118.i.1 = extractvalue { i1, i64, i1 } %514, 0
  %.fca.1.extract119.i.1 = extractvalue { i1, i64, i1 } %514, 1
  br i1 %.fca.0.extract118.i.1, label %cond_1995_case_1.i.1, label %516

cond_1995_case_1.i.1:                             ; preds = %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit"
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i.1)
  %515 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i.1, 1
  br label %516

516:                                              ; preds = %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit", %cond_1995_case_1.i.1
  %.pn.i.1 = phi { i1, i64, i1 } [ %515, %cond_1995_case_1.i.1 ], [ %514, %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit" ]
  %517 = load i64, i64* %495, align 4
  %518 = and i64 %517, 2
  %.not.i.i225.1 = icmp eq i64 %518, 0
  br i1 %.not.i.i225.1, label %cond_1950_case_1.i.1, label %panic.i.i226

cond_1950_case_1.i.1:                             ; preds = %516
  %"03.sroa.6.0.i.1" = extractvalue { i1, i64, i1 } %.pn.i.1, 2
  %"16.fca.2.insert.i.1" = insertvalue { i1, i64, i1 } %514, i1 %"03.sroa.6.0.i.1", 2
  %519 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i.1", 1
  %520 = getelementptr inbounds i8, i8* %493, i64 32
  %521 = bitcast i8* %520 to { i1, { i1, i64, i1 } }*
  %522 = bitcast i8* %520 to i1*
  %523 = load i1, i1* %522, align 1
  store { i1, { i1, i64, i1 } } %519, { i1, { i1, i64, i1 } }* %521, align 4
  br i1 %523, label %cond_1922_case_1.i, label %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.1"

"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.1": ; preds = %cond_1950_case_1.i.1
  %524 = getelementptr inbounds i8, i8* %499, i64 24
  %525 = bitcast i8* %524 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"16.fca.2.insert.i.1", { i1, i64, i1 }* %525, align 4
  %526 = getelementptr inbounds i8, i8* %457, i64 48
  %527 = bitcast i8* %526 to { i1, i64, i1 }*
  %528 = load { i1, i64, i1 }, { i1, i64, i1 }* %527, align 4
  %.fca.0.extract118.i.2 = extractvalue { i1, i64, i1 } %528, 0
  %.fca.1.extract119.i.2 = extractvalue { i1, i64, i1 } %528, 1
  br i1 %.fca.0.extract118.i.2, label %cond_1995_case_1.i.2, label %530

cond_1995_case_1.i.2:                             ; preds = %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.1"
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i.2)
  %529 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i.2, 1
  br label %530

530:                                              ; preds = %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.1", %cond_1995_case_1.i.2
  %.pn.i.2 = phi { i1, i64, i1 } [ %529, %cond_1995_case_1.i.2 ], [ %528, %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.1" ]
  %531 = load i64, i64* %495, align 4
  %532 = and i64 %531, 4
  %.not.i.i225.2 = icmp eq i64 %532, 0
  br i1 %.not.i.i225.2, label %cond_1950_case_1.i.2, label %panic.i.i226

cond_1950_case_1.i.2:                             ; preds = %530
  %"03.sroa.6.0.i.2" = extractvalue { i1, i64, i1 } %.pn.i.2, 2
  %"16.fca.2.insert.i.2" = insertvalue { i1, i64, i1 } %528, i1 %"03.sroa.6.0.i.2", 2
  %533 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i.2", 1
  %534 = getelementptr inbounds i8, i8* %493, i64 64
  %535 = bitcast i8* %534 to { i1, { i1, i64, i1 } }*
  %536 = bitcast i8* %534 to i1*
  %537 = load i1, i1* %536, align 1
  store { i1, { i1, i64, i1 } } %533, { i1, { i1, i64, i1 } }* %535, align 4
  br i1 %537, label %cond_1922_case_1.i, label %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.2"

"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.2": ; preds = %cond_1950_case_1.i.2
  %538 = getelementptr inbounds i8, i8* %499, i64 48
  %539 = bitcast i8* %538 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"16.fca.2.insert.i.2", { i1, i64, i1 }* %539, align 4
  %540 = getelementptr inbounds i8, i8* %457, i64 72
  %541 = bitcast i8* %540 to { i1, i64, i1 }*
  %542 = load { i1, i64, i1 }, { i1, i64, i1 }* %541, align 4
  %.fca.0.extract118.i.3 = extractvalue { i1, i64, i1 } %542, 0
  %.fca.1.extract119.i.3 = extractvalue { i1, i64, i1 } %542, 1
  br i1 %.fca.0.extract118.i.3, label %cond_1995_case_1.i.3, label %544

cond_1995_case_1.i.3:                             ; preds = %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.2"
  tail call void @___inc_future_refcount(i64 %.fca.1.extract119.i.3)
  %543 = insertvalue { i1, i64, i1 } { i1 true, i64 poison, i1 poison }, i64 %.fca.1.extract119.i.3, 1
  br label %544

544:                                              ; preds = %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.2", %cond_1995_case_1.i.3
  %.pn.i.3 = phi { i1, i64, i1 } [ %543, %cond_1995_case_1.i.3 ], [ %542, %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.2" ]
  %545 = load i64, i64* %495, align 4
  %546 = and i64 %545, 8
  %.not.i.i225.3 = icmp eq i64 %546, 0
  br i1 %.not.i.i225.3, label %cond_1950_case_1.i.3, label %panic.i.i226

cond_1950_case_1.i.3:                             ; preds = %544
  %"03.sroa.6.0.i.3" = extractvalue { i1, i64, i1 } %.pn.i.3, 2
  %"16.fca.2.insert.i.3" = insertvalue { i1, i64, i1 } %542, i1 %"03.sroa.6.0.i.3", 2
  %547 = insertvalue { i1, { i1, i64, i1 } } { i1 true, { i1, i64, i1 } poison }, { i1, i64, i1 } %"16.fca.2.insert.i.3", 1
  %548 = getelementptr inbounds i8, i8* %493, i64 96
  %549 = bitcast i8* %548 to { i1, { i1, i64, i1 } }*
  %550 = bitcast i8* %548 to i1*
  %551 = load i1, i1* %550, align 1
  store { i1, { i1, i64, i1 } } %547, { i1, { i1, i64, i1 } }* %549, align 4
  br i1 %551, label %cond_1922_case_1.i, label %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.3"

"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.3": ; preds = %cond_1950_case_1.i.3
  %552 = getelementptr inbounds i8, i8* %499, i64 72
  %553 = bitcast i8* %552 to { i1, i64, i1 }*
  store { i1, i64, i1 } %"16.fca.2.insert.i.3", { i1, i64, i1 }* %553, align 4
  tail call void @heap_free(i8* nonnull %457)
  tail call void @heap_free(i8* nonnull %459)
  %554 = load i64, i64* %495, align 4
  %555 = and i64 %554, 15
  store i64 %555, i64* %495, align 4
  %556 = icmp eq i64 %555, 0
  br i1 %556, label %__barray_check_none_borrowed.exit232, label %mask_block_err.i231

__barray_check_none_borrowed.exit232:             ; preds = %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.3"
  %557 = tail call i8* @heap_alloc(i64 96)
  %558 = bitcast i8* %557 to { i1, i64, i1 }*
  %559 = tail call i8* @heap_alloc(i64 8)
  %560 = bitcast i8* %559 to i64*
  store i64 0, i64* %560, align 1
  %561 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %503, align 4
  %.fca.0.extract11.i = extractvalue { i1, { i1, i64, i1 } } %561, 0
  br i1 %.fca.0.extract11.i, label %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit", label %cond_1696_case_0.i

mask_block_err.i231:                              ; preds = %"__hugr__.$__copy_scan$$n(4)$t([Bool]+[Future(Bool)])$n(1).1912.exit.3"
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_1696_case_0.i:                               ; preds = %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.2", %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.1", %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit", %__barray_check_none_borrowed.exit232
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([46 x i8], [46 x i8]* @"e_Expected v.E6312129.0", i64 0, i64 0))
  unreachable

"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit": ; preds = %__barray_check_none_borrowed.exit232
  %562 = extractvalue { i1, { i1, i64, i1 } } %561, 1
  store { i1, i64, i1 } %562, { i1, i64, i1 }* %558, align 4
  %563 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %521, align 4
  %.fca.0.extract11.i.1 = extractvalue { i1, { i1, i64, i1 } } %563, 0
  br i1 %.fca.0.extract11.i.1, label %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.1", label %cond_1696_case_0.i

"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.1": ; preds = %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit"
  %564 = extractvalue { i1, { i1, i64, i1 } } %563, 1
  %565 = getelementptr inbounds i8, i8* %557, i64 24
  %566 = bitcast i8* %565 to { i1, i64, i1 }*
  store { i1, i64, i1 } %564, { i1, i64, i1 }* %566, align 4
  %567 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %535, align 4
  %.fca.0.extract11.i.2 = extractvalue { i1, { i1, i64, i1 } } %567, 0
  br i1 %.fca.0.extract11.i.2, label %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.2", label %cond_1696_case_0.i

"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.2": ; preds = %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.1"
  %568 = extractvalue { i1, { i1, i64, i1 } } %567, 1
  %569 = getelementptr inbounds i8, i8* %557, i64 48
  %570 = bitcast i8* %569 to { i1, i64, i1 }*
  store { i1, i64, i1 } %568, { i1, i64, i1 }* %570, align 4
  %571 = load { i1, { i1, i64, i1 } }, { i1, { i1, i64, i1 } }* %549, align 4
  %.fca.0.extract11.i.3 = extractvalue { i1, { i1, i64, i1 } } %571, 0
  br i1 %.fca.0.extract11.i.3, label %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.3", label %cond_1696_case_0.i

"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.3": ; preds = %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.2"
  %572 = extractvalue { i1, { i1, i64, i1 } } %571, 1
  %573 = getelementptr inbounds i8, i8* %557, i64 72
  %574 = bitcast i8* %573 to { i1, i64, i1 }*
  store { i1, i64, i1 } %572, { i1, i64, i1 }* %574, align 4
  tail call void @heap_free(i8* nonnull %493)
  tail call void @heap_free(i8* nonnull %494)
  %575 = load i64, i64* %560, align 4
  %576 = and i64 %575, 1
  %.not = icmp eq i64 %576, 0
  br i1 %.not, label %__barray_mask_borrow.exit, label %cond_exit_1484

mask_block_err.i236:                              ; preds = %cond_exit_1484.3
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit:                        ; preds = %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.3"
  %577 = xor i64 %575, 1
  store i64 %577, i64* %560, align 4
  %578 = load { i1, i64, i1 }, { i1, i64, i1 }* %558, align 4
  %.fca.0.extract124 = extractvalue { i1, i64, i1 } %578, 0
  br i1 %.fca.0.extract124, label %cond_1463_case_1, label %cond_exit_1484

cond_exit_1484:                                   ; preds = %"__hugr__.$__unwrap$$t([Bool]+[Future(Bool)]).1705.exit.3", %__barray_mask_borrow.exit, %cond_1463_case_1
  %579 = load i64, i64* %560, align 4
  %580 = and i64 %579, 2
  %.not.1 = icmp eq i64 %580, 0
  br i1 %.not.1, label %__barray_mask_borrow.exit.1, label %cond_exit_1484.1

__barray_mask_borrow.exit.1:                      ; preds = %cond_exit_1484
  %581 = xor i64 %579, 2
  store i64 %581, i64* %560, align 4
  %582 = getelementptr inbounds i8, i8* %557, i64 24
  %583 = bitcast i8* %582 to { i1, i64, i1 }*
  %584 = load { i1, i64, i1 }, { i1, i64, i1 }* %583, align 4
  %.fca.0.extract124.1 = extractvalue { i1, i64, i1 } %584, 0
  br i1 %.fca.0.extract124.1, label %cond_1463_case_1.1, label %cond_exit_1484.1

cond_1463_case_1.1:                               ; preds = %__barray_mask_borrow.exit.1
  %.fca.1.extract125.1 = extractvalue { i1, i64, i1 } %584, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract125.1)
  br label %cond_exit_1484.1

cond_exit_1484.1:                                 ; preds = %cond_1463_case_1.1, %__barray_mask_borrow.exit.1, %cond_exit_1484
  %585 = load i64, i64* %560, align 4
  %586 = and i64 %585, 4
  %.not.2 = icmp eq i64 %586, 0
  br i1 %.not.2, label %__barray_mask_borrow.exit.2, label %cond_exit_1484.2

__barray_mask_borrow.exit.2:                      ; preds = %cond_exit_1484.1
  %587 = xor i64 %585, 4
  store i64 %587, i64* %560, align 4
  %588 = getelementptr inbounds i8, i8* %557, i64 48
  %589 = bitcast i8* %588 to { i1, i64, i1 }*
  %590 = load { i1, i64, i1 }, { i1, i64, i1 }* %589, align 4
  %.fca.0.extract124.2 = extractvalue { i1, i64, i1 } %590, 0
  br i1 %.fca.0.extract124.2, label %cond_1463_case_1.2, label %cond_exit_1484.2

cond_1463_case_1.2:                               ; preds = %__barray_mask_borrow.exit.2
  %.fca.1.extract125.2 = extractvalue { i1, i64, i1 } %590, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract125.2)
  br label %cond_exit_1484.2

cond_exit_1484.2:                                 ; preds = %cond_1463_case_1.2, %__barray_mask_borrow.exit.2, %cond_exit_1484.1
  %591 = load i64, i64* %560, align 4
  %592 = and i64 %591, 8
  %.not.3 = icmp eq i64 %592, 0
  br i1 %.not.3, label %__barray_mask_borrow.exit.3, label %cond_exit_1484.3

__barray_mask_borrow.exit.3:                      ; preds = %cond_exit_1484.2
  %593 = xor i64 %591, 8
  store i64 %593, i64* %560, align 4
  %594 = getelementptr inbounds i8, i8* %557, i64 72
  %595 = bitcast i8* %594 to { i1, i64, i1 }*
  %596 = load { i1, i64, i1 }, { i1, i64, i1 }* %595, align 4
  %.fca.0.extract124.3 = extractvalue { i1, i64, i1 } %596, 0
  br i1 %.fca.0.extract124.3, label %cond_1463_case_1.3, label %cond_exit_1484.3

cond_1463_case_1.3:                               ; preds = %__barray_mask_borrow.exit.3
  %.fca.1.extract125.3 = extractvalue { i1, i64, i1 } %596, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract125.3)
  br label %cond_exit_1484.3

cond_exit_1484.3:                                 ; preds = %cond_1463_case_1.3, %__barray_mask_borrow.exit.3, %cond_exit_1484.2
  %597 = load i64, i64* %560, align 4
  %598 = or i64 %597, -16
  store i64 %598, i64* %560, align 4
  %599 = icmp eq i64 %598, -1
  br i1 %599, label %loop_out, label %mask_block_err.i236

loop_out:                                         ; preds = %cond_exit_1484.3
  tail call void @heap_free(i8* %557)
  tail call void @heap_free(i8* nonnull %559)
  %600 = load i64, i64* %502, align 4
  %601 = and i64 %600, 15
  store i64 %601, i64* %502, align 4
  %602 = icmp eq i64 %601, 0
  br i1 %602, label %__barray_check_none_borrowed.exit244, label %mask_block_err.i243

__barray_check_none_borrowed.exit244:             ; preds = %loop_out
  %603 = tail call i8* @heap_alloc(i64 4)
  %604 = tail call i8* @heap_alloc(i64 8)
  %605 = bitcast i8* %604 to i64*
  store i64 0, i64* %605, align 1
  %606 = load { i1, i64, i1 }, { i1, i64, i1 }* %500, align 4
  %.fca.0.extract.i = extractvalue { i1, i64, i1 } %606, 0
  %.fca.1.extract.i = extractvalue { i1, i64, i1 } %606, 1
  br i1 %.fca.0.extract.i, label %cond_1968_case_1.i, label %cond_1968_case_0.i

mask_block_err.i243:                              ; preds = %loop_out
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable

cond_1463_case_1:                                 ; preds = %__barray_mask_borrow.exit
  %.fca.1.extract125 = extractvalue { i1, i64, i1 } %578, 1
  tail call void @___dec_future_refcount(i64 %.fca.1.extract125)
  br label %cond_exit_1484

cond_1968_case_0.i:                               ; preds = %__barray_check_none_borrowed.exit244
  %.fca.2.extract.i = extractvalue { i1, i64, i1 } %606, 2
  br label %__hugr__.array.__read_bool.3.483.exit

cond_1968_case_1.i:                               ; preds = %__barray_check_none_borrowed.exit244
  %read_bool.i = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i)
  br label %__hugr__.array.__read_bool.3.483.exit

__hugr__.array.__read_bool.3.483.exit:            ; preds = %cond_1968_case_0.i, %cond_1968_case_1.i
  %"03.0.i" = phi i1 [ %read_bool.i, %cond_1968_case_1.i ], [ %.fca.2.extract.i, %cond_1968_case_0.i ]
  %607 = bitcast i8* %603 to i1*
  store i1 %"03.0.i", i1* %607, align 1
  %608 = load { i1, i64, i1 }, { i1, i64, i1 }* %525, align 4
  %.fca.0.extract.i.1 = extractvalue { i1, i64, i1 } %608, 0
  %.fca.1.extract.i.1 = extractvalue { i1, i64, i1 } %608, 1
  br i1 %.fca.0.extract.i.1, label %cond_1968_case_1.i.1, label %cond_1968_case_0.i.1

cond_1968_case_0.i.1:                             ; preds = %__hugr__.array.__read_bool.3.483.exit
  %.fca.2.extract.i.1 = extractvalue { i1, i64, i1 } %608, 2
  br label %__hugr__.array.__read_bool.3.483.exit.1

cond_1968_case_1.i.1:                             ; preds = %__hugr__.array.__read_bool.3.483.exit
  %read_bool.i.1 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i.1)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i.1)
  br label %__hugr__.array.__read_bool.3.483.exit.1

__hugr__.array.__read_bool.3.483.exit.1:          ; preds = %cond_1968_case_1.i.1, %cond_1968_case_0.i.1
  %"03.0.i.1" = phi i1 [ %read_bool.i.1, %cond_1968_case_1.i.1 ], [ %.fca.2.extract.i.1, %cond_1968_case_0.i.1 ]
  %609 = getelementptr inbounds i8, i8* %603, i64 1
  %610 = bitcast i8* %609 to i1*
  store i1 %"03.0.i.1", i1* %610, align 1
  %611 = load { i1, i64, i1 }, { i1, i64, i1 }* %539, align 4
  %.fca.0.extract.i.2 = extractvalue { i1, i64, i1 } %611, 0
  %.fca.1.extract.i.2 = extractvalue { i1, i64, i1 } %611, 1
  br i1 %.fca.0.extract.i.2, label %cond_1968_case_1.i.2, label %cond_1968_case_0.i.2

cond_1968_case_0.i.2:                             ; preds = %__hugr__.array.__read_bool.3.483.exit.1
  %.fca.2.extract.i.2 = extractvalue { i1, i64, i1 } %611, 2
  br label %__hugr__.array.__read_bool.3.483.exit.2

cond_1968_case_1.i.2:                             ; preds = %__hugr__.array.__read_bool.3.483.exit.1
  %read_bool.i.2 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i.2)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i.2)
  br label %__hugr__.array.__read_bool.3.483.exit.2

__hugr__.array.__read_bool.3.483.exit.2:          ; preds = %cond_1968_case_1.i.2, %cond_1968_case_0.i.2
  %"03.0.i.2" = phi i1 [ %read_bool.i.2, %cond_1968_case_1.i.2 ], [ %.fca.2.extract.i.2, %cond_1968_case_0.i.2 ]
  %612 = getelementptr inbounds i8, i8* %603, i64 2
  %613 = bitcast i8* %612 to i1*
  store i1 %"03.0.i.2", i1* %613, align 1
  %614 = load { i1, i64, i1 }, { i1, i64, i1 }* %553, align 4
  %.fca.0.extract.i.3 = extractvalue { i1, i64, i1 } %614, 0
  %.fca.1.extract.i.3 = extractvalue { i1, i64, i1 } %614, 1
  br i1 %.fca.0.extract.i.3, label %cond_1968_case_1.i.3, label %cond_1968_case_0.i.3

cond_1968_case_0.i.3:                             ; preds = %__hugr__.array.__read_bool.3.483.exit.2
  %.fca.2.extract.i.3 = extractvalue { i1, i64, i1 } %614, 2
  br label %__hugr__.array.__read_bool.3.483.exit.3

cond_1968_case_1.i.3:                             ; preds = %__hugr__.array.__read_bool.3.483.exit.2
  %read_bool.i.3 = tail call i1 @___read_future_bool(i64 %.fca.1.extract.i.3)
  tail call void @___dec_future_refcount(i64 %.fca.1.extract.i.3)
  br label %__hugr__.array.__read_bool.3.483.exit.3

__hugr__.array.__read_bool.3.483.exit.3:          ; preds = %cond_1968_case_1.i.3, %cond_1968_case_0.i.3
  %"03.0.i.3" = phi i1 [ %read_bool.i.3, %cond_1968_case_1.i.3 ], [ %.fca.2.extract.i.3, %cond_1968_case_0.i.3 ]
  %615 = getelementptr inbounds i8, i8* %603, i64 3
  %616 = bitcast i8* %615 to i1*
  store i1 %"03.0.i.3", i1* %616, align 1
  tail call void @heap_free(i8* nonnull %499)
  tail call void @heap_free(i8* nonnull %501)
  %617 = load i64, i64* %605, align 4
  %618 = and i64 %617, 15
  store i64 %618, i64* %605, align 4
  %619 = icmp eq i64 %618, 0
  br i1 %619, label %__barray_check_none_borrowed.exit249, label %mask_block_err.i248

__barray_check_none_borrowed.exit249:             ; preds = %__hugr__.array.__read_bool.3.483.exit.3
  %out_arr_alloca = alloca <{ i32, i32, i1*, i1* }>, align 8
  %x_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 2
  %mask_ptr = getelementptr inbounds <{ i32, i32, i1*, i1* }>, <{ i32, i32, i1*, i1* }>* %out_arr_alloca, i64 0, i32 3
  %620 = alloca i32, align 4
  store i32 0, i32* %620, align 4
  store i32 4, i32* %x_ptr, align 8
  store i32 1, i32* %y_ptr, align 4
  %621 = bitcast i1** %arr_ptr to i8**
  store i8* %603, i8** %621, align 8
  %622 = bitcast i1** %mask_ptr to i32**
  store i32* %620, i32** %622, align 8
  call void @print_bool_arr(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @res_b_reg.8EAD6F09.0, i64 0, i64 0), i64 18, <{ i32, i32, i1*, i1* }>* nonnull %out_arr_alloca)
  %lazy_measure = call i64 @___lazy_measure(i64 %447)
  call void @___qfree(i64 %447)
  %read_bool = call i1 @___read_future_bool(i64 %lazy_measure)
  call void @___dec_future_refcount(i64 %lazy_measure)
  call void @print_bool(i8* getelementptr inbounds ([20 x i8], [20 x i8]* @res_carry_out.3DB2874F.0, i64 0, i64 0), i64 19, i1 %read_bool)
  ret void

mask_block_err.i248:                              ; preds = %__hugr__.array.__read_bool.3.483.exit.3
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([48 x i8], [48 x i8]* @"e_Some array.A77EF32E.0", i64 0, i64 0))
  unreachable
}

declare i8* @heap_alloc(i64) local_unnamed_addr

; Function Attrs: noreturn
declare void @panic(i32, i8*) local_unnamed_addr #0

declare void @heap_free(i8*) local_unnamed_addr

declare void @___dec_future_refcount(i64) local_unnamed_addr

declare void @print_bool_arr(i8*, i64, <{ i32, i32, i1*, i1* }>*) local_unnamed_addr

declare i64 @___lazy_measure(i64) local_unnamed_addr

declare void @___qfree(i64) local_unnamed_addr

declare i1 @___read_future_bool(i64) local_unnamed_addr

declare void @print_bool(i8*, i64, i1) local_unnamed_addr

define private fastcc { i64*, i64*, i64 } @"__hugr__.$apply_bitstring$$n(4).2199"({ i64*, i64*, i64 } %0, { i64, [0 x i1] }* nocapture readonly %1) unnamed_addr {
alloca_block:
  %.fca.0.extract380 = extractvalue { i64*, i64*, i64 } %0, 0
  %.fca.1.extract381 = extractvalue { i64*, i64*, i64 } %0, 1
  %2 = getelementptr inbounds { i64, [0 x i1] }, { i64, [0 x i1] }* %1, i64 0, i32 0
  %3 = load i64, i64* %2, align 4
  %.not = icmp eq i64 %3, 0
  br i1 %.not, label %cond_2283_case_0.i, label %cond_exit_1517

cond_2283_case_0.i:                               ; preds = %cond_2265_case_1.3, %cond_2265_case_1.2, %cond_2265_case_1.1, %alloca_block
  tail call void @panic(i32 1001, i8* getelementptr inbounds ([41 x i8], [41 x i8]* @e_Frozenarra.36077F52.0, i64 0, i64 0))
  unreachable

cond_2265_case_1.1:                               ; preds = %cond_exit_1517, %__barray_mask_return.exit
  %4 = phi i64 [ %3, %cond_exit_1517 ], [ %.pre, %__barray_mask_return.exit ]
  %5 = icmp ugt i64 %4, 1
  br i1 %5, label %cond_exit_1517.1, label %cond_2283_case_0.i

cond_exit_1517.1:                                 ; preds = %cond_2265_case_1.1
  %6 = getelementptr inbounds { i64, [0 x i1] }, { i64, [0 x i1] }* %1, i64 0, i32 1, i64 1
  %7 = load i1, i1* %6, align 1
  br i1 %7, label %__barray_check_bounds.exit.1, label %cond_2265_case_1.2

__barray_check_bounds.exit.1:                     ; preds = %cond_exit_1517.1
  %8 = load i64, i64* %.fca.1.extract381, align 4
  %9 = and i64 %8, 2
  %.not.i.1 = icmp eq i64 %9, 0
  br i1 %.not.i.1, label %__barray_check_bounds.exit384.1, label %panic.i

__barray_check_bounds.exit384.1:                  ; preds = %__barray_check_bounds.exit.1
  %10 = xor i64 %8, 2
  store i64 %10, i64* %.fca.1.extract381, align 4
  %11 = getelementptr inbounds i64, i64* %.fca.0.extract380, i64 1
  %12 = load i64, i64* %11, align 4
  tail call void @___rxy(i64 %12, double 0x400921FB54442D18, double 0.000000e+00)
  %13 = load i64, i64* %.fca.1.extract381, align 4
  %14 = and i64 %13, 2
  %.not.i385.1 = icmp eq i64 %14, 0
  br i1 %.not.i385.1, label %panic.i386, label %__barray_mask_return.exit.1

__barray_mask_return.exit.1:                      ; preds = %__barray_check_bounds.exit384.1
  %15 = xor i64 %13, 2
  store i64 %15, i64* %.fca.1.extract381, align 4
  store i64 %12, i64* %11, align 4
  %.pre397 = load i64, i64* %2, align 4
  br label %cond_2265_case_1.2

cond_2265_case_1.2:                               ; preds = %__barray_mask_return.exit.1, %cond_exit_1517.1
  %16 = phi i64 [ %.pre397, %__barray_mask_return.exit.1 ], [ %4, %cond_exit_1517.1 ]
  %17 = icmp ugt i64 %16, 2
  br i1 %17, label %cond_exit_1517.2, label %cond_2283_case_0.i

cond_exit_1517.2:                                 ; preds = %cond_2265_case_1.2
  %18 = getelementptr inbounds { i64, [0 x i1] }, { i64, [0 x i1] }* %1, i64 0, i32 1, i64 2
  %19 = load i1, i1* %18, align 1
  br i1 %19, label %__barray_check_bounds.exit.2, label %cond_2265_case_1.3

__barray_check_bounds.exit.2:                     ; preds = %cond_exit_1517.2
  %20 = load i64, i64* %.fca.1.extract381, align 4
  %21 = and i64 %20, 4
  %.not.i.2 = icmp eq i64 %21, 0
  br i1 %.not.i.2, label %__barray_check_bounds.exit384.2, label %panic.i

__barray_check_bounds.exit384.2:                  ; preds = %__barray_check_bounds.exit.2
  %22 = xor i64 %20, 4
  store i64 %22, i64* %.fca.1.extract381, align 4
  %23 = getelementptr inbounds i64, i64* %.fca.0.extract380, i64 2
  %24 = load i64, i64* %23, align 4
  tail call void @___rxy(i64 %24, double 0x400921FB54442D18, double 0.000000e+00)
  %25 = load i64, i64* %.fca.1.extract381, align 4
  %26 = and i64 %25, 4
  %.not.i385.2 = icmp eq i64 %26, 0
  br i1 %.not.i385.2, label %panic.i386, label %__barray_mask_return.exit.2

__barray_mask_return.exit.2:                      ; preds = %__barray_check_bounds.exit384.2
  %27 = xor i64 %25, 4
  store i64 %27, i64* %.fca.1.extract381, align 4
  store i64 %24, i64* %23, align 4
  %.pre399 = load i64, i64* %2, align 4
  br label %cond_2265_case_1.3

cond_2265_case_1.3:                               ; preds = %__barray_mask_return.exit.2, %cond_exit_1517.2
  %28 = phi i64 [ %.pre399, %__barray_mask_return.exit.2 ], [ %16, %cond_exit_1517.2 ]
  %29 = icmp ugt i64 %28, 3
  br i1 %29, label %cond_exit_1517.3, label %cond_2283_case_0.i

cond_exit_1517.3:                                 ; preds = %cond_2265_case_1.3
  %30 = getelementptr inbounds { i64, [0 x i1] }, { i64, [0 x i1] }* %1, i64 0, i32 1, i64 3
  %31 = load i1, i1* %30, align 1
  br i1 %31, label %__barray_check_bounds.exit.3, label %cond_exit_2250

__barray_check_bounds.exit.3:                     ; preds = %cond_exit_1517.3
  %32 = load i64, i64* %.fca.1.extract381, align 4
  %33 = and i64 %32, 8
  %.not.i.3 = icmp eq i64 %33, 0
  br i1 %.not.i.3, label %__barray_check_bounds.exit384.3, label %panic.i

__barray_check_bounds.exit384.3:                  ; preds = %__barray_check_bounds.exit.3
  %34 = xor i64 %32, 8
  store i64 %34, i64* %.fca.1.extract381, align 4
  %35 = getelementptr inbounds i64, i64* %.fca.0.extract380, i64 3
  %36 = load i64, i64* %35, align 4
  tail call void @___rxy(i64 %36, double 0x400921FB54442D18, double 0.000000e+00)
  %37 = load i64, i64* %.fca.1.extract381, align 4
  %38 = and i64 %37, 8
  %.not.i385.3 = icmp eq i64 %38, 0
  br i1 %.not.i385.3, label %panic.i386, label %__barray_mask_return.exit.3

__barray_mask_return.exit.3:                      ; preds = %__barray_check_bounds.exit384.3
  %39 = xor i64 %37, 8
  store i64 %39, i64* %.fca.1.extract381, align 4
  store i64 %36, i64* %35, align 4
  br label %cond_exit_2250

cond_exit_2250:                                   ; preds = %__barray_mask_return.exit.3, %cond_exit_1517.3
  %"2212_424.fca.2.insert" = insertvalue { i64*, i64*, i64 } %0, i64 0, 2
  ret { i64*, i64*, i64 } %"2212_424.fca.2.insert"

cond_exit_1517:                                   ; preds = %alloca_block
  %40 = getelementptr inbounds { i64, [0 x i1] }, { i64, [0 x i1] }* %1, i64 0, i32 1, i64 0
  %41 = load i1, i1* %40, align 1
  br i1 %41, label %__barray_check_bounds.exit, label %cond_2265_case_1.1

__barray_check_bounds.exit:                       ; preds = %cond_exit_1517
  %42 = load i64, i64* %.fca.1.extract381, align 4
  %43 = and i64 %42, 1
  %.not.i = icmp eq i64 %43, 0
  br i1 %.not.i, label %__barray_check_bounds.exit384, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit.3, %__barray_check_bounds.exit.2, %__barray_check_bounds.exit.1, %__barray_check_bounds.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit384:                    ; preds = %__barray_check_bounds.exit
  %44 = xor i64 %42, 1
  store i64 %44, i64* %.fca.1.extract381, align 4
  %45 = load i64, i64* %.fca.0.extract380, align 4
  tail call void @___rxy(i64 %45, double 0x400921FB54442D18, double 0.000000e+00)
  %46 = load i64, i64* %.fca.1.extract381, align 4
  %47 = and i64 %46, 1
  %.not.i385 = icmp eq i64 %47, 0
  br i1 %.not.i385, label %panic.i386, label %__barray_mask_return.exit

panic.i386:                                       ; preds = %__barray_check_bounds.exit384.3, %__barray_check_bounds.exit384.2, %__barray_check_bounds.exit384.1, %__barray_check_bounds.exit384
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([57 x i8], [57 x i8]* @"e_Array alre.5A300C2A.0", i64 0, i64 0))
  unreachable

__barray_mask_return.exit:                        ; preds = %__barray_check_bounds.exit384
  %48 = xor i64 %46, 1
  store i64 %48, i64* %.fca.1.extract381, align 4
  store i64 %45, i64* %.fca.0.extract380, align 4
  %.pre = load i64, i64* %2, align 4
  br label %cond_2265_case_1.1
}

define private fastcc { i64, i64, i64 } @__hugr__.ccx.1244(i64 %0, i64 %1, i64 %2) unnamed_addr {
alloca_block:
  tail call void @___rxy(i64 %2, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %2, double 0x400921FB54442D18)
  tail call void @___rxy(i64 %2, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %1, i64 %2, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %1, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %2, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %2, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %2, double 0xBFE921FB54442D18)
  tail call void @___rxy(i64 %2, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %0, i64 %2, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %0, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %2, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %2, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %2, double 0x3FE921FB54442D18)
  tail call void @___rxy(i64 %2, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %1, i64 %2, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %1, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %2, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %2, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %2, double 0xBFE921FB54442D18)
  tail call void @___rxy(i64 %2, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %0, i64 %2, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %0, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %2, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %2, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %2, double 0x3FE921FB54442D18)
  %mrv.i.i = insertvalue { i64, i64, i64 } undef, i64 %0, 0
  %mrv39.i.i = insertvalue { i64, i64, i64 } %mrv.i.i, i64 %1, 1
  tail call void @___rxy(i64 %2, double 0x3FF921FB54442D18, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %2, double 0x400921FB54442D18)
  %mrv33.i = insertvalue { i64, i64, i64 } %mrv39.i.i, i64 %2, 2
  tail call void @___rz(i64 %1, double 0x3FE921FB54442D18)
  tail call void @___rxy(i64 %1, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %0, i64 %1, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %0, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %1, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %1, double 0xBFF921FB54442D18)
  tail call void @___rz(i64 %1, double 0xBFE921FB54442D18)
  tail call void @___rz(i64 %0, double 0x3FE921FB54442D18)
  tail call void @___rxy(i64 %1, double 0xBFF921FB54442D18, double 0x3FF921FB54442D18)
  tail call void @___rzz(i64 %0, i64 %1, double 0x3FF921FB54442D18)
  tail call void @___rz(i64 %0, double 0xBFF921FB54442D18)
  tail call void @___rxy(i64 %1, double 0x3FF921FB54442D18, double 0x400921FB54442D18)
  tail call void @___rz(i64 %1, double 0xBFF921FB54442D18)
  ret { i64, i64, i64 } %mrv33.i
}

define private fastcc { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } @"__hugr__.$__next__$$t(qubit)$n(4).3884"({ { i64*, i64*, i64 }, i64 } %0) unnamed_addr {
alloca_block:
  %.fca.1.extract98 = extractvalue { { i64*, i64*, i64 }, i64 } %0, 1
  %1 = extractvalue { { i64*, i64*, i64 }, i64 } %0, 0
  %.fca.0.extract81 = extractvalue { i64*, i64*, i64 } %1, 0
  %.fca.1.extract82 = extractvalue { i64*, i64*, i64 } %1, 1
  %.fca.2.extract83 = extractvalue { i64*, i64*, i64 } %1, 2
  %2 = icmp slt i64 %.fca.1.extract98, 4
  br i1 %2, label %32, label %4

3:                                                ; preds = %__barray_check_all_borrowed.exit, %__barray_mask_borrow.exit
  %"02.sroa.3.0" = phi i64* [ %.fca.1.0.0.0.extract, %__barray_mask_borrow.exit ], [ poison, %__barray_check_all_borrowed.exit ]
  %"02.sroa.6.0" = phi i64* [ %.fca.1.0.0.1.extract, %__barray_mask_borrow.exit ], [ poison, %__barray_check_all_borrowed.exit ]
  %"02.sroa.9.0" = phi i64 [ %.fca.1.0.0.2.extract, %__barray_mask_borrow.exit ], [ poison, %__barray_check_all_borrowed.exit ]
  %"02.sroa.12.0" = phi i64 [ %33, %__barray_mask_borrow.exit ], [ poison, %__barray_check_all_borrowed.exit ]
  %"02.sroa.15.0" = phi i64 [ %44, %__barray_mask_borrow.exit ], [ poison, %__barray_check_all_borrowed.exit ]
  %"038.fca.0.insert" = insertvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } poison, i1 %2, 0
  %"038.fca.1.0.0.0.insert" = insertvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %"038.fca.0.insert", i64* %"02.sroa.3.0", 1, 0, 0, 0
  %"038.fca.1.0.0.1.insert" = insertvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %"038.fca.1.0.0.0.insert", i64* %"02.sroa.6.0", 1, 0, 0, 1
  %"038.fca.1.0.0.2.insert" = insertvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %"038.fca.1.0.0.1.insert", i64 %"02.sroa.9.0", 1, 0, 0, 2
  %"038.fca.1.0.1.insert" = insertvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %"038.fca.1.0.0.2.insert", i64 %"02.sroa.12.0", 1, 0, 1
  %"038.fca.1.1.insert" = insertvalue { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %"038.fca.1.0.1.insert", i64 %"02.sroa.15.0", 1, 1
  ret { i1, { { { i64*, i64*, i64 }, i64 }, i64 } } %"038.fca.1.1.insert"

4:                                                ; preds = %alloca_block
  %5 = lshr i64 %.fca.2.extract83, 6
  %6 = getelementptr inbounds i64, i64* %.fca.1.extract82, i64 %5
  %7 = load i64, i64* %6, align 4
  %8 = and i64 %.fca.2.extract83, 63
  %9 = sub nuw nsw i64 64, %8
  %10 = lshr i64 -1, %9
  %11 = icmp eq i64 %8, 0
  %12 = select i1 %11, i64 0, i64 %10
  %13 = or i64 %7, %12
  store i64 %13, i64* %6, align 4
  %last_valid.i = add i64 %.fca.2.extract83, 3
  %14 = lshr i64 %last_valid.i, 6
  %15 = getelementptr inbounds i64, i64* %.fca.1.extract82, i64 %14
  %16 = load i64, i64* %15, align 4
  %17 = and i64 %last_valid.i, 63
  %18 = shl i64 -2, %17
  %19 = icmp eq i64 %17, 63
  %20 = select i1 %19, i64 0, i64 %18
  %21 = or i64 %16, %20
  store i64 %21, i64* %15, align 4
  %22 = sub nsw i64 1, %5
  %23 = add nsw i64 %22, %14
  %.not.i = icmp eq i64 %23, 0
  br i1 %.not.i, label %__barray_check_all_borrowed.exit, label %mask_block_ok.i

24:                                               ; preds = %mask_block_ok.i
  %exitcond.not.i = icmp eq i64 %29, %23
  br i1 %exitcond.not.i, label %__barray_check_all_borrowed.exit, label %mask_block_ok.i

mask_block_ok.i:                                  ; preds = %4, %24
  %.01.i = phi i64 [ %29, %24 ], [ 0, %4 ]
  %25 = add i64 %.01.i, %5
  %26 = getelementptr inbounds i64, i64* %.fca.1.extract82, i64 %25
  %27 = load i64, i64* %26, align 4
  %28 = icmp eq i64 %27, -1
  %29 = add nuw i64 %.01.i, 1
  br i1 %28, label %24, label %mask_block_err.i

mask_block_err.i:                                 ; preds = %mask_block_ok.i
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([70 x i8], [70 x i8]* @"e_Array cont.EFA5AC45.0", i64 0, i64 0))
  unreachable

__barray_check_all_borrowed.exit:                 ; preds = %24, %4
  %30 = bitcast i64* %.fca.0.extract81 to i8*
  tail call void @heap_free(i8* %30)
  %31 = bitcast i64* %.fca.1.extract82 to i8*
  tail call void @heap_free(i8* %31)
  br label %3

32:                                               ; preds = %alloca_block
  %33 = add nsw i64 %.fca.1.extract98, 1
  %34 = icmp ult i64 %.fca.1.extract98, 4
  br i1 %34, label %__barray_check_bounds.exit, label %out_of_bounds.i

out_of_bounds.i:                                  ; preds = %32
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([29 x i8], [29 x i8]* @"e_Index out .DD115165.0", i64 0, i64 0))
  unreachable

__barray_check_bounds.exit:                       ; preds = %32
  %35 = add i64 %.fca.2.extract83, %.fca.1.extract98
  %36 = lshr i64 %35, 6
  %37 = getelementptr inbounds i64, i64* %.fca.1.extract82, i64 %36
  %38 = load i64, i64* %37, align 4
  %39 = and i64 %35, 63
  %40 = shl nuw i64 1, %39
  %41 = and i64 %38, %40
  %.not.i99 = icmp eq i64 %41, 0
  br i1 %.not.i99, label %__barray_mask_borrow.exit, label %panic.i

panic.i:                                          ; preds = %__barray_check_bounds.exit
  tail call void @panic(i32 1002, i8* getelementptr inbounds ([43 x i8], [43 x i8]* @"e_Array elem.E746B1A3.0", i64 0, i64 0))
  unreachable

__barray_mask_borrow.exit:                        ; preds = %__barray_check_bounds.exit
  %42 = xor i64 %38, %40
  store i64 %42, i64* %37, align 4
  %43 = getelementptr inbounds i64, i64* %.fca.0.extract81, i64 %35
  %44 = load i64, i64* %43, align 4
  %.fca.1.0.0.0.extract = extractvalue { { i64*, i64*, i64 }, i64 } %0, 0, 0
  %.fca.1.0.0.1.extract = extractvalue { { i64*, i64*, i64 }, i64 } %0, 0, 1
  %.fca.1.0.0.2.extract = extractvalue { { i64*, i64*, i64 }, i64 } %0, 0, 2
  br label %3
}

declare void @___rxy(i64, double, double) local_unnamed_addr

declare void @___rzz(i64, i64, double) local_unnamed_addr

declare void @___rz(i64, double) local_unnamed_addr

declare i64 @___qalloc() local_unnamed_addr

declare void @___reset(i64) local_unnamed_addr

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
