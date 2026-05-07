; ModuleID = 'custom'
source_filename = "custom"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

; standard QIS
declare ptr @heap_alloc(i64) local_unnamed_addr
declare void @heap_free(ptr) local_unnamed_addr
declare void @setup(i64) local_unnamed_addr
declare i64 @teardown() local_unnamed_addr
declare void @___rxy(i64, double, double) local_unnamed_addr
declare void @___dec_future_refcount(i64) local_unnamed_addr
declare i64 @___lazy_measure(i64) local_unnamed_addr
declare void @___qfree(i64) local_unnamed_addr
declare i1 @___read_future_bool(i64) local_unnamed_addr
declare void @print_bool(i8*, i64, i1) local_unnamed_addr
declare void @print_bool_arr(i8*, i64, i1) local_unnamed_addr
declare void @print_uint(i8*, i64, i64) local_unnamed_addr
declare void @print_uint_arr(ptr, i64, ptr) local_unnamed_addr
declare void @print_int(i8*, i64, i64) local_unnamed_addr
declare void @print_int_arr(ptr, i64, ptr) local_unnamed_addr
declare void @print_float(i8*, i64, double) local_unnamed_addr
declare void @print_float_arr(ptr, i64, ptr) local_unnamed_addr
declare i64 @___qalloc() local_unnamed_addr
declare void @___reset(i64) local_unnamed_addr
declare void @___inc_future_refcount(i64) local_unnamed_addr

; arg reader plugin functions
declare i8 @argreader_get_bool(i8*) local_unnamed_addr
declare i64 @argreader_get_u64(i64*) local_unnamed_addr
declare i64 @argreader_get_i64(i64*) local_unnamed_addr
declare double @argreader_get_f64(double*) local_unnamed_addr
declare void @argreader_get_bool_array(i8*, i64*, i64) local_unnamed_addr
declare void @argreader_get_u64_array(i64*, i64*, i64) local_unnamed_addr
declare void @argreader_get_i64_array(i64*, i64*, i64) local_unnamed_addr
declare void @argreader_get_f64_array(double*, i64*, i64) local_unnamed_addr


; labels for argument fetching
@bool_label = private constant [22 x i8] c"casing_is_logarithmic\00"
@u64_label = private constant [22 x i8] c"num_spurving_bearings\00"
@i64_label = private constant [14 x i8] c"side_fumbling\00"
@f64_label = private constant [19 x i8] c"magneto_reluctance\00"
@bool_array_label = private constant [20 x i8] c"cardinal_grammeters\00"
@u64_array_label = private constant [17 x i8] c"marzelvane_sizes\00"
@i64_array_label = private constant [20 x i8] c"tremie_pipe_lengths\00"
@f64_array_label = private constant [21 x i8] c"encabulation_extents\00"

; tags for printing
@bool_tag = private constant [32 x i8] c"\1fUSER:BOOL:casing_is_logarithmic"
@u64_tag = private constant [31 x i8] c"\1eUSER:INT:num_spurving_bearings"
@i64_tag = private constant [23 x i8] c"\16USER:INT:side_fumbling"
@f64_tag = private constant [30 x i8] c"\1dUSER:FLOAT:magneto_reluctance"
@bool_array_tag = private constant [33 x i8] c"\20USER:BOOLARR:cardinal_grammeters"
@u64_array_tag = private constant [29 x i8] c"\1cUSER:INTARR:marzelvane_sizes"
@i64_array_tag = private constant [32 x i8] c"\1fUSER:INTARR:tremie_pipe_lengths"
@f64_array_tag = private constant [35 x i8] c"\22USER:FLOATARR:encabulation_extents"


define private void @main_inner() unnamed_addr {
alloca_block:
; first, a demonstration of reading and printing of scalar values.
  %bool_value = call i8 @argreader_get_bool(ptr @bool_label)
  %u64_value = call i64 @argreader_get_u64(ptr @u64_label)
  %i64_value = call i64 @argreader_get_i64(ptr @i64_label)
  %f64_value = call double @argreader_get_f64(ptr @f64_label)
  
  %bool_value_i1 = trunc i8 %bool_value to i1
  call void @print_bool(ptr @bool_tag, i64 0, i1 %bool_value_i1)
  call void @print_uint(ptr @u64_tag, i64 0, i64 %u64_value)
  call void @print_int(ptr @i64_tag, i64 0, i64 %i64_value)
  call void @print_float(ptr @f64_tag, i64 0, double %f64_value)
  
; now we demonstrate reading and printing array values.
; first allocate space (here we do that on the stack), then point to it in the argreader array call, along with the size.
  %bool_array_value = alloca [5 x i1], align 8
  %u64_array_value = alloca [5 x i64], align 8
  %i64_array_value = alloca [5 x i64], align 8
  %f64_array_value = alloca [5 x double], align 8
  call void @argreader_get_bool_array(ptr @bool_array_label, ptr %bool_array_value, i64 5)
  call void @argreader_get_u64_array(ptr @u64_array_label, ptr %u64_array_value, i64 5)
  call void @argreader_get_i64_array(ptr @i64_array_label, ptr %i64_array_value, i64 5)
  call void @argreader_get_f64_array(ptr @f64_array_label, ptr %f64_array_value, i64 5)


; the print_T_arr functions require a struct holding array information, so we use a helper to create that struct on the heap.
  %bool_array_cl = call ptr @_get_cl_array(ptr %bool_array_value, i32 5)
  %u64_array_cl = call ptr @_get_cl_array(ptr %u64_array_value, i32 5)
  %i64_array_cl = call ptr @_get_cl_array(ptr %i64_array_value, i32 5)
  %f64_array_cl = call ptr @_get_cl_array(ptr %f64_array_value, i32 5)

  call void @print_bool_arr(ptr @bool_array_tag, i64 0, ptr nonnull %bool_array_cl)
  call void @print_uint_arr(ptr @u64_array_tag, i64 0, ptr nonnull %u64_array_cl)
  call void @print_int_arr(ptr @i64_array_tag, i64 0, ptr nonnull %i64_array_cl)
  call void @print_float_arr(ptr @f64_array_tag, i64 0, ptr nonnull %f64_array_cl)

  call void @heap_free(ptr %bool_array_cl)
  call void @heap_free(ptr %u64_array_cl)
  call void @heap_free(ptr %i64_array_cl)
  call void @heap_free(ptr %f64_array_cl)

  ret void
}

define private ptr @_get_cl_array(ptr %array_contents, i32 %array_len) unnamed_addr {
  %array_wrapper = call ptr @heap_alloc(i64 16)
  %x_ptr = getelementptr inbounds <{ i32, i32, ptr }>, ptr %array_wrapper, i64 0, i32 0
  %y_ptr = getelementptr inbounds <{ i32, i32, ptr }>, ptr %array_wrapper, i64 0, i32 1
  %arr_ptr = getelementptr inbounds <{ i32, i32, ptr }>, ptr %array_wrapper, i64 0, i32 2
  store i32 %array_len, ptr %x_ptr, align 8
  store i32 1, ptr %y_ptr, align 4
  store ptr %array_contents, ptr %arr_ptr, align 8
  ret ptr %array_wrapper
}


define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call fastcc void @main_inner()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

!name = !{!0}

!0 = !{!"mainlib"}
