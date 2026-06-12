; ModuleID = 'hugr'
source_filename = "hugr"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: nofree norecurse noreturn nosync nounwind memory(none)
define void @__hugr__.__main__.main.1() local_unnamed_addr #0 {
alloca_block:
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %tailrecurse.i, %alloca_block
  br label %tailrecurse.i
}

; Function Attrs: noreturn
define noundef i64 @qmain(i64 %0) local_unnamed_addr #1 {
entry:
  tail call void @setup(i64 %0)
  br label %tailrecurse.i.i

tailrecurse.i.i:                                  ; preds = %tailrecurse.i.i, %entry
  br label %tailrecurse.i.i
}

declare void @setup(i64) local_unnamed_addr

attributes #0 = { nofree norecurse noreturn nosync nounwind memory(none) }
attributes #1 = { noreturn }

!name = !{!0}

!0 = !{!"mainlib"}
