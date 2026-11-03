@global_data = global i32 7
@common_data = common global i32 0
@external_data = external global i32

declare void @selene_load_config()

define i32 @qmain() {
  call void @selene_load_config()
  %value = load i32, ptr @external_data
  ret i32 %value
}

define void @_keep_underscore() {
  ret void
}
