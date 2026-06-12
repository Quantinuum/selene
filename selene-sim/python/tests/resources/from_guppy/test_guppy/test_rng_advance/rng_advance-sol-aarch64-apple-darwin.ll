; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-apple-darwin"

@res_rint.B928E41E.0 = private constant [14 x i8] c"\0DUSER:INT:rint"
@res_rfloat.F0E4DD2C.0 = private constant [18 x i8] c"\11USER:FLOAT:rfloat"
@res_rint2.F0335598.0 = private constant [15 x i8] c"\0EUSER:INT:rint2"
@res_rfloat2.4DAB941F.0 = private constant [19 x i8] c"\12USER:FLOAT:rfloat2"

define void @__hugr__.__main__.main.1() local_unnamed_addr {
alloca_block:
  %shot = tail call i64 @get_current_shot()
  %0 = add i64 %shot, 42
  tail call void @random_seed(i64 %0)
  %rint = tail call i32 @random_int()
  %rfloat = tail call double @random_float()
  tail call void @random_advance(i64 -2)
  %rint9 = tail call i32 @random_int()
  %rfloat11 = tail call double @random_float()
  %1 = sext i32 %rint9 to i64
  %2 = sext i32 %rint to i64
  tail call void @print_int(ptr nonnull @res_rint.B928E41E.0, i64 13, i64 %2)
  tail call void @print_float(ptr nonnull @res_rfloat.F0E4DD2C.0, i64 17, double %rfloat)
  tail call void @print_int(ptr nonnull @res_rint2.F0335598.0, i64 14, i64 %1)
  tail call void @print_float(ptr nonnull @res_rfloat2.4DAB941F.0, i64 18, double %rfloat11)
  ret void
}

declare i64 @get_current_shot() local_unnamed_addr

declare i32 @random_int() local_unnamed_addr

declare double @random_float() local_unnamed_addr

declare void @random_advance(i64) local_unnamed_addr

declare void @print_int(ptr, i64, i64) local_unnamed_addr

declare void @print_float(ptr, i64, double) local_unnamed_addr

declare void @random_seed(i64) local_unnamed_addr

define i64 @qmain(i64 %0) local_unnamed_addr {
entry:
  tail call void @setup(i64 %0)
  tail call void @__hugr__.__main__.main.1()
  %1 = tail call i64 @teardown()
  ret i64 %1
}

declare void @setup(i64) local_unnamed_addr

declare i64 @teardown() local_unnamed_addr

!name = !{!0}

!0 = !{!"mainlib"}
