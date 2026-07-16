; ModuleID = 'custom'
source_filename = "custom"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

; standard QIS
declare void @setup(i64) local_unnamed_addr
declare i64 @teardown() local_unnamed_addr
declare void @print_bool(i8*, i64, i1) local_unnamed_addr
declare void @print_uint(i8*, i64, i64) local_unnamed_addr
declare void @print_int(i8*, i64, i64) local_unnamed_addr
declare void @print_float(i8*, i64, double) local_unnamed_addr

; env reader plugin functions
declare i8 @envreader_get_bool(i8*) local_unnamed_addr
declare i64 @envreader_get_u64(i8*) local_unnamed_addr
declare i64 @envreader_get_i64(i8*) local_unnamed_addr
declare double @envreader_get_f64(i8*) local_unnamed_addr


; labels for argument fetching (first byte encodes length)
@bool_label = private constant [13 x i8] c"\0CBOOL_ENV_VAR"
@u64_label = private constant [13 x i8] c"\0CUINT_ENV_VAR"
@i64_label = private constant [12 x i8] c"\0BINT_ENV_VAR"
@f64_label = private constant [14 x i8] c"\0DFLOAT_ENV_VAR"

; tags for printing (first byte encodes length)
@bool_tag = private constant [21 x i8] c"\14USER:BOOL:input_bool"
@u64_tag = private constant [20 x i8] c"\13USER:INT:input_uint"
@i64_tag = private constant [19 x i8] c"\12USER:INT:input_int"
@f64_tag = private constant [23 x i8] c"\16USER:FLOAT:input_float"


define private void @main_inner() unnamed_addr {
alloca_block:
; first, a demonstration of reading and printing of scalar values.
  %bool_value = call i8 @envreader_get_bool(ptr @bool_label)
  %u64_value = call i64 @envreader_get_u64(ptr @u64_label)
  %i64_value = call i64 @envreader_get_i64(ptr @i64_label)
  %f64_value = call double @envreader_get_f64(ptr @f64_label)
  
  %bool_value_i1 = trunc i8 %bool_value to i1
  call void @print_bool(ptr @bool_tag, i64 0, i1 %bool_value_i1)
  call void @print_uint(ptr @u64_tag, i64 0, i64 %u64_value)
  call void @print_int(ptr @i64_tag, i64 0, i64 %i64_value)
  call void @print_float(ptr @f64_tag, i64 0, double %f64_value)
  
  ret void
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
