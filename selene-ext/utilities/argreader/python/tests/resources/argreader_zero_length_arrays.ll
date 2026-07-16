; ModuleID = 'custom'
source_filename = "custom"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

; standard QIS
declare void @setup(i64) local_unnamed_addr
declare i64 @teardown() local_unnamed_addr
declare void @print_uint(i8*, i64, i64) local_unnamed_addr

; arg reader plugin functions
declare void @argreader_get_bool_array(i8*, i8*, i64) local_unnamed_addr
declare void @argreader_get_u64_array(i8*, i64*, i64) local_unnamed_addr
declare void @argreader_get_i64_array(i8*, i64*, i64) local_unnamed_addr
declare void @argreader_get_f64_array(i8*, double*, i64) local_unnamed_addr

@bool_array_label = private constant [17 x i8] c"\10input_bool_array"
@u64_array_label = private constant [16 x i8] c"\0Finput_u64_array"
@i64_array_label = private constant [16 x i8] c"\0Finput_i64_array"
@f64_array_label = private constant [16 x i8] c"\0Finput_f64_array"
@done_tag = private constant [14 x i8] c"\0DUSER:INT:done"

define private void @main_inner() unnamed_addr {
alloca_block:
  call void @argreader_get_bool_array(ptr @bool_array_label, ptr null, i64 0)
  call void @argreader_get_u64_array(ptr @u64_array_label, ptr null, i64 0)
  call void @argreader_get_i64_array(ptr @i64_array_label, ptr null, i64 0)
  call void @argreader_get_f64_array(ptr @f64_array_label, ptr null, i64 0)

  call void @print_uint(ptr @done_tag, i64 0, i64 0)
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
