; ModuleID = 'custom'
source_filename = "custom"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

; standard QIS
declare void @setup(i64) local_unnamed_addr
declare i64 @teardown() local_unnamed_addr
declare void @___rxy(i64, double, double) local_unnamed_addr
declare void @___dec_future_refcount(i64) local_unnamed_addr
declare i64 @___lazy_measure(i64) local_unnamed_addr
declare void @___qfree(i64) local_unnamed_addr
declare i1 @___read_future_bool(i64) local_unnamed_addr
declare void @print_bool(i8*, i64, i1) local_unnamed_addr
declare void @print_uint(i8*, i64, i64) local_unnamed_addr
declare void @print_int(i8*, i64, i64) local_unnamed_addr
declare void @print_float(i8*, i64, double) local_unnamed_addr
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

; tags for printing
@bool_tag = private constant [32 x i8] c"\1fUSER:BOOL:casing_is_logarithmic"
@u64_tag = private constant [31 x i8] c"\1eUSER:INT:num_spurving_bearings"
@i64_tag = private constant [23 x i8] c"\16USER:INT:side_fumbling"
@f64_tag = private constant [30 x i8] c"\1dUSER:FLOAT:magneto_reluctance"


define private void @main_inner() unnamed_addr {
alloca_block:
  %bool_value = call i8 @argreader_get_bool(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @bool_label, i64 0, i64 0))
  %u64_value = call i64 @argreader_get_u64(i8* getelementptr inbounds ([22 x i8], [22 x i8]* @u64_label, i64 0, i64 0))
  %i64_value = call i64 @argreader_get_i64(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @i64_label, i64 0, i64 0))
  %f64_value = call double @argreader_get_f64(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @f64_label, i64 0, i64 0))


  %bool_value_i1 = trunc i8 %bool_value to i1
  call void @print_bool(i8* getelementptr inbounds ([32 x i8], [32 x i8]* @bool_tag, i64 0, i64 0), i64 0, i1 %bool_value_i1)
  call void @print_uint(i8* getelementptr inbounds ([31 x i8], [31 x i8]* @u64_tag, i64 0, i64 0), i64 0, i64 %u64_value)
  call void @print_int(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @i64_tag, i64 0, i64 0), i64 0, i64 %i64_value)
  call void @print_float(i8* getelementptr inbounds ([30 x i8], [30 x i8]* @f64_tag, i64 0, i64 0), i64 0, double %f64_value)
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
