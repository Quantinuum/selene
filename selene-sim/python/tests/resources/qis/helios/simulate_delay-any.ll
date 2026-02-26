; ModuleID = 'custom'
source_filename = "custom"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

declare void @setup(i64) local_unnamed_addr
declare i64 @teardown() local_unnamed_addr
declare void @___dec_future_refcount(i64) local_unnamed_addr
declare i64 @___lazy_measure(i64) local_unnamed_addr
declare void @___qfree(i64) local_unnamed_addr
declare i1 @___read_future_bool(i64) local_unnamed_addr
declare void @print_bool(i8*, i64, i1) local_unnamed_addr
declare i64 @___qalloc() local_unnamed_addr
declare void @___reset(i64) local_unnamed_addr
declare void @___inc_future_refcount(i64) local_unnamed_addr
declare void @simulate_delay(i64) local_unnamed_addr

@result_0_tag = private constant [18 x i8] c"\11USER:BOOL:qubit_0"
@result_1_tag = private constant [18 x i8] c"\11USER:BOOL:qubit_1"

define private void @main_inner() unnamed_addr {
alloca_block:
  %qubit_0 = call i64 @___qalloc()
  %qubit_1 = call i64 @___qalloc()
  call void @___reset(i64 %qubit_0)
  call void @___reset(i64 %qubit_1)

  ; measure first qubit
  %meas_fut_0 = tail call i64 @___lazy_measure(i64 %qubit_0)
  call void @___qfree(i64 %qubit_0)
  %meas_res0 = tail call i1 @___read_future_bool(i64 %meas_fut_0)
  call void @___dec_future_refcount(i64 %meas_fut_0)

  ; simulate a delay
  call void @simulate_delay(i64 1234500000) ; 1.2345 seconds

  ; measure second qubit
  %meas_fut_1 = tail call i64 @___lazy_measure(i64 %qubit_1)
  call void @___qfree(i64 %qubit_1)
  %meas_res1 = tail call i1 @___read_future_bool(i64 %meas_fut_1)
  call void @___dec_future_refcount(i64 %meas_fut_1)

  ; print measurements
  call void @print_bool(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @result_0_tag, i64 0, i64 0), i64 17, i1 %meas_res0)
  call void @print_bool(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @result_1_tag, i64 0, i64 0), i64 17, i1 %meas_res1)
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
