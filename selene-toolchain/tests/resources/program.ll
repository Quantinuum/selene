@message = private constant [3 x i8] c"ok\00"
declare i32 @puts(ptr)
define i32 @main(i32 %argc, ptr %argv) {
    %result = call i32 @puts(ptr @message)
    ret i32 0
}
