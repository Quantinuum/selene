use selene_core::runtime::{
    RuntimeInstruction as I, RuntimeInstructionResult as R,
    instruction::{RuntimeInstructionRaw, RuntimeInstructionResultRaw},
    output::{ExitRequest, PrintRequest},
};

#[test]
fn c_requests_copy_nested_buffers_before_the_caller_reuses_them() {
    let instruction = I::Exit {
        request: ExitRequest {
            error_code: 1001,
            message: "program failed".into(),
            backtrace: vec![PrintRequest::new("DEBUG:BACKTRACE:program", 123u64)],
        },
    };
    let owned = instruction
        .with_raw(|raw| unsafe { I::from_raw(raw) })
        .unwrap();
    drop(instruction);
    let I::Exit { request } = owned else {
        panic!("Expected Exit");
    };
    assert_eq!(request.message, "program failed");
    assert_eq!(
        request.backtrace,
        vec![PrintRequest::new("DEBUG:BACKTRACE:program", 123u64)]
    );

    let print = I::Print {
        request: PrintRequest::new("array", &[3i64, -4][..]),
    };
    let owned = print.with_raw(|raw| unsafe { I::from_raw(raw) }).unwrap();
    drop(print);
    let I::Print { request } = owned else {
        panic!("Expected Print");
    };
    assert_eq!(request, PrintRequest::new("array", &[3i64, -4][..]));
}

#[test]
fn malformed_instructions_are_rejected_before_reading_the_payload() {
    assert!(unsafe { I::from_raw(std::ptr::null()) }.is_err());
    I::QAlloc.with_raw(|raw| {
        let unknown = RuntimeInstructionRaw {
            tag: u32::MAX,
            ..*raw
        };
        assert!(unsafe { I::from_raw(&unknown) }.is_err());
        let short = RuntimeInstructionRaw {
            struct_size: 8,
            ..*raw
        };
        assert!(unsafe { I::from_raw(&short) }.is_err());
    });
}

#[test]
fn optional_results_do_not_reserve_a_u64_value() {
    for result in [
        R::None,
        R::Qubit(7),
        R::Future(8),
        R::Bool(None),
        R::Bool(Some(false)),
        R::Bool(Some(true)),
        R::U64(None),
        R::U64(Some(u64::MAX)),
    ] {
        assert_eq!(R::from_raw(result.as_raw()).unwrap(), result);
    }
    assert!(
        R::from_raw(RuntimeInstructionResultRaw {
            tag: 99,
            available: true,
            value: 0
        })
        .is_err()
    );
    assert!(
        R::from_raw(RuntimeInstructionResultRaw {
            tag: 3,
            available: true,
            value: 2
        })
        .is_err()
    );
}
