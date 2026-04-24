pub mod encoder;
pub mod error_model;
pub mod runtime;
pub mod simulator;
pub mod time;
pub mod utils;

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
