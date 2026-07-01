#[macro_export]
macro_rules! export_plugin_descriptor_v1 {
    (
        $symbol:ident,
        $descriptor_ty:ident,
        $api_version:expr,
        {
            last_error_fn: $last_error_fn:expr,
            get_name_fn: $get_name_fn:expr,
            $($field:ident : $value:expr),* $(,)?
        }
    ) => {
        #[unsafe(no_mangle)]
        pub static mut $symbol: $descriptor_ty = $descriptor_ty {
            header: $crate::plugin::PluginDescriptorHeaderV1 {
                struct_size: core::mem::size_of::<$descriptor_ty>() as u64,
                api_version: $api_version,
                last_error_fn: $last_error_fn,
                get_name_fn: Some($get_name_fn),
            },
            $($field: $value,)*
        };
    };
}

#[macro_export]
macro_rules! define_gate {
    (
        $vis:vis struct $name:ident [
            id = $id:expr,
            display = $display:expr,
            version = $version:expr,
        ] {
            $( $field:ident : $field_ty:ty ),* $(,)?
        }
    ) => {
        #[derive(Clone, Debug, PartialEq)]
        $vis struct $name { $(pub $field: $field_ty),* }

        impl $name {
            pub fn semantic_id() -> $crate::gatewire::GateSemanticId {
                <Self as $crate::gatewire::GateSpec>::semantic_id()
            }

            pub fn declaration() -> $crate::gatewire::GateDecl {
                <Self as $crate::gatewire::GateSpec>::declaration()
            }
        }

        impl $crate::gatewire::GateSpec for $name {
            fn id_text() -> &'static str { $id }
            fn name() -> &'static str { $display }
            fn version() -> u32 { $version }

            fn declaration() -> $crate::gatewire::GateDecl {
                $crate::gatewire::GateDecl::new(
                    Self::semantic_id(),
                    Self::name(),
                    vec![$($crate::gatewire::OperandSpec::new(stringify!($field), <$field_ty as $crate::gatewire::GateOperand>::KIND),)*],
                    Self::version(),
                )
            }

            fn to_instance(&self) -> $crate::gatewire::OwnedGateInstance {
                $crate::gatewire::OwnedGateInstance::new(
                    Self::semantic_id(),
                    vec![$(<$field_ty as $crate::gatewire::GateOperand>::into_value(self.$field.clone()),)*],
                )
            }

            fn try_from_instance(instance: &$crate::gatewire::OwnedGateInstance) -> Result<Option<Self>, $crate::gatewire::GateError> {
                if instance.semantic_id != Self::semantic_id() { return Ok(None); }
                let expected = 0usize $(+ { let _ = stringify!($field); 1usize })*;
                if instance.operands.len() != expected {
                    return Err($crate::gatewire::GateError::WrongArity { gate: Self::name().to_string(), expected, actual: instance.operands.len() });
                }
                let mut index = 0usize;
                $(
                    let $field = {
                        let value = &instance.operands[index];
                        index += 1;
                        <$field_ty as $crate::gatewire::GateOperand>::from_value(value)?
                    };
                )*
                let _ = index;
                Ok(Some(Self { $($field),* }))
            }
        }
    };
}

#[macro_export]
macro_rules! define_builtin_gate {
    (
        $vis:vis struct $name:ident {
            $( $field:ident : $field_ty:ty ),* $(,)?
        }
    ) => {
        $crate::define_gate! {
            $vis struct $name [
                id = concat!(
                    "gatewire.builtin.",
                    stringify!($name),
                    ".v1"
                ),
                display = stringify!($name),
                version = 1,
            ] {
                $( $field : $field_ty ),*
            }
        }
    };

    (
        $vis:vis struct $name:ident [
            version = $version:literal $(,)?
        ] {
            $( $field:ident : $field_ty:ty ),* $(,)?
        }
    ) => {
        $crate::define_gate! {
            $vis struct $name [
                id = concat!(
                    "gatewire.builtin.",
                    stringify!($name),
                    ".v",
                    stringify!($version)
                ),
                display = stringify!($name),
                version = $version,
            ] {
                $( $field : $field_ty ),*
            }
        }
    };
}

#[macro_export]
macro_rules! define_builtin_gates {
    (
        $(
            $vis:vis struct $name:ident {
                $( $field:ident : $field_ty:ty ),* $(,)?
            }
        )*
    ) => {
        $(
            $crate::define_builtin_gate! {
                $vis struct $name [
                    version = 1,
                ] {
                    $( $field : $field_ty ),*
                }
            }
        )*
    };

    (
        $(
            $vis:vis struct $name:ident [
                version = $version:literal $(,)?
            ] {
                $( $field:ident : $field_ty:ty ),* $(,)?
            }
        )*
    ) => {
        $(
            $crate::define_builtin_gate! {
                $vis struct $name [
                    version = $version,
                ] {
                    $( $field : $field_ty ),*
                }
            }
        )*
    };
}

#[macro_export]
macro_rules! define_gateset {
    (
        $vis:vis enum $name:ident {
            $( $variant:ident ( $gate_ty:ty ) ),* $(,)?
        }
    ) => {
        #[derive(Clone, Debug, PartialEq)]
        $vis enum $name { $( $variant($gate_ty) ),* }

        impl $crate::gatewire::GateSetSpec for $name {
            fn declarations() -> Vec<$crate::gatewire::GateDecl> {
                vec![$(<$gate_ty as $crate::gatewire::GateSpec>::declaration(),)*]
            }

            fn to_instance(&self) -> $crate::gatewire::OwnedGateInstance {
                match self { $( Self::$variant(inner) => <$gate_ty as $crate::gatewire::GateSpec>::to_instance(inner), )* }
            }

            fn try_from_instance(instance: &$crate::gatewire::OwnedGateInstance) -> Result<Option<Self>, $crate::gatewire::GateError> {
                $(
                    if let Some(gate) = <$gate_ty as $crate::gatewire::GateSpec>::try_from_instance(instance)? {
                        return Ok(Some(Self::$variant(gate)));
                    }
                )*
                Ok(None)
            }
        }
    };
}
