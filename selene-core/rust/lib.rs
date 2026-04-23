pub mod encoder;
pub mod error_model;
pub mod runtime;
pub mod simulator;
pub mod time;
pub mod utils;

pub const PLUGIN_DESCRIPTOR_V1_MAGIC: u64 = 0x5345_4C45_4E45_5F31;

pub const fn fnv1a64(bytes: &[u8]) -> u64 {
    let mut hash = 0xcbf29ce484222325u64;
    let mut i = 0usize;
    while i < bytes.len() {
        hash ^= bytes[i] as u64;
        hash = hash.wrapping_mul(0x100000001b3);
        i += 1;
    }
    hash
}

#[macro_export]
macro_rules! export_plugin_descriptor_v1 {
    ($symbol:ident, $descriptor_ty:ident, $api_version:expr, { $($field:ident : $value:expr),* $(,)? }) => {
        #[unsafe(no_mangle)]
        pub static mut $symbol: $descriptor_ty = $descriptor_ty {
            struct_size: core::mem::size_of::<$descriptor_ty>() as u64,
            api_version: $api_version,
            $($field: $value,)*
        };
    };
}
