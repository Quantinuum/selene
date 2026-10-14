@external_data = external global i64
@global_data = global i64 0
@function_alias = alias i64 (i64), ptr @qmain

declare void @setup()
declare void @unused_function()
declare extern_weak void @weak_function()
declare void @llvm.donothing()

define internal void @internal_helper() {
    ret void
}

define i64 @qmain(i64 %argument) {
    ret i64 %argument
}

define void @"quoted\22 name\5Ctail"() {
    ret void
}

define void @"caf\C3\A9"() {
    ret void
}
