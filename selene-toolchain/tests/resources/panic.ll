; We archive this function on its own so the linker has to extract it to
; satisfy main's call, even though libSystem also exports panic on macOS.
define i32 @panic() {
    ret i32 42
}
