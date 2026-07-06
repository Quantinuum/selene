use crate::gatewire::{
    DynamicGateSet, GateDecl, GateError, GateSemanticId, GateValue, OperandKind, OperandSpec,
    OwnedGateInstance,
};

const GATE_MAGIC: [u8; 4] = *b"GWG1";
const GATESET_MAGIC: [u8; 4] = *b"GWS1";
const WIRE_VERSION: u16 = 1;

pub fn serialize_gateset(set: &DynamicGateSet) -> Vec<u8> {
    let mut out = Vec::new();
    out.extend_from_slice(&GATESET_MAGIC);
    write_u16(&mut out, WIRE_VERSION);
    write_u16(&mut out, 0);
    write_u32(&mut out, set.len() as u32);

    for decl in set.declarations() {
        out.extend_from_slice(&decl.semantic_id.bytes);
        write_string(&mut out, &decl.name);
        write_u32(&mut out, decl.version);
        write_u32(&mut out, decl.operands.len() as u32);
        for operand in &decl.operands {
            write_u32(&mut out, operand.kind.as_u32());
            write_string(&mut out, &operand.name);
        }
    }

    out
}

pub fn deserialize_gateset(data: &[u8]) -> Result<DynamicGateSet, GateError> {
    let mut cur = Cursor::new(data);
    let magic = cur.read_exact(4)?;
    if magic != GATESET_MAGIC.as_slice() {
        return Err(GateError::Decode("bad gateset magic"));
    }
    let version = cur.read_u16()?;
    if version != WIRE_VERSION {
        return Err(GateError::Decode("unsupported gateset wire version"));
    }
    let _reserved = cur.read_u16()?;
    let count = cur.read_u32()? as usize;
    let mut declarations = Vec::with_capacity(count);

    for _ in 0..count {
        let id_bytes = cur.read_array_16()?;
        let name = cur.read_string()?;
        let version = cur.read_u32()?;
        let operand_count = cur.read_u32()? as usize;
        let mut operands = Vec::with_capacity(operand_count);
        for _ in 0..operand_count {
            let kind = OperandKind::from_u32(cur.read_u32()?)?;
            let name = cur.read_string()?;
            operands.push(OperandSpec::new(name, kind));
        }
        declarations.push(GateDecl::new(
            GateSemanticId::from_bytes(id_bytes),
            name,
            operands,
            version,
        ));
    }

    cur.finish()?;
    DynamicGateSet::from_declarations(declarations)
}

pub fn serialize_gate_instance(instance: &OwnedGateInstance) -> Vec<u8> {
    let mut out = Vec::new();
    out.extend_from_slice(&GATE_MAGIC);
    write_u16(&mut out, WIRE_VERSION);
    write_u16(&mut out, 0);
    out.extend_from_slice(&instance.semantic_id.bytes);
    write_u32(&mut out, instance.operands.len() as u32);

    for value in &instance.operands {
        write_u32(&mut out, value.kind().as_u32());
        match value {
            GateValue::Qubit(v) => write_u32(&mut out, *v),
            GateValue::F64(v) => write_u64(&mut out, v.to_bits()),
            GateValue::U64(v) => write_u64(&mut out, *v),
            GateValue::I64(v) => write_u64(&mut out, *v as u64),
            GateValue::U8(v) => out.push(*v),
            GateValue::Bool(v) => out.push(if *v { 1 } else { 0 }),
        }
    }

    out
}

pub fn deserialize_gate_instance(data: &[u8]) -> Result<OwnedGateInstance, GateError> {
    let mut cur = Cursor::new(data);
    let magic = cur.read_exact(4)?;
    if magic != GATE_MAGIC.as_slice() {
        return Err(GateError::Decode("bad gate magic"));
    }
    let version = cur.read_u16()?;
    if version != WIRE_VERSION {
        return Err(GateError::Decode("unsupported gate wire version"));
    }
    let _reserved = cur.read_u16()?;
    let semantic_id = GateSemanticId::from_bytes(cur.read_array_16()?);
    let operand_count = cur.read_u32()? as usize;
    let mut operands = Vec::with_capacity(operand_count);

    for _ in 0..operand_count {
        let kind = OperandKind::from_u32(cur.read_u32()?)?;
        let value = match kind {
            OperandKind::Qubit => GateValue::Qubit(cur.read_u32()?),
            OperandKind::F64 => GateValue::F64(f64::from_bits(cur.read_u64()?)),
            OperandKind::U64 => GateValue::U64(cur.read_u64()?),
            OperandKind::I64 => GateValue::I64(cur.read_u64()? as i64),
            OperandKind::U8 => GateValue::U8(cur.read_u8()?),
            OperandKind::Bool => match cur.read_u8()? {
                0 => GateValue::Bool(false),
                1 => GateValue::Bool(true),
                _ => return Err(GateError::Decode("invalid bool operand")),
            },
        };
        operands.push(value);
    }

    cur.finish()?;
    Ok(OwnedGateInstance::new(semantic_id, operands))
}

fn write_u16(out: &mut Vec<u8>, value: u16) {
    out.extend_from_slice(&value.to_le_bytes());
}
fn write_u32(out: &mut Vec<u8>, value: u32) {
    out.extend_from_slice(&value.to_le_bytes());
}
fn write_u64(out: &mut Vec<u8>, value: u64) {
    out.extend_from_slice(&value.to_le_bytes());
}

fn write_string(out: &mut Vec<u8>, value: &str) {
    write_u32(out, value.len() as u32);
    out.extend_from_slice(value.as_bytes());
}

struct Cursor<'a> {
    data: &'a [u8],
    offset: usize,
}

impl<'a> Cursor<'a> {
    fn new(data: &'a [u8]) -> Self {
        Self { data, offset: 0 }
    }

    fn read_exact(&mut self, len: usize) -> Result<&'a [u8], GateError> {
        let end = self
            .offset
            .checked_add(len)
            .ok_or(GateError::Decode("integer overflow while decoding"))?;
        if end > self.data.len() {
            return Err(GateError::Decode("truncated input"));
        }
        let bytes = &self.data[self.offset..end];
        self.offset = end;
        Ok(bytes)
    }

    fn read_u8(&mut self) -> Result<u8, GateError> {
        Ok(self.read_exact(1)?[0])
    }

    fn read_u16(&mut self) -> Result<u16, GateError> {
        let bytes = self.read_exact(2)?;
        Ok(u16::from_le_bytes([bytes[0], bytes[1]]))
    }

    fn read_u32(&mut self) -> Result<u32, GateError> {
        let bytes = self.read_exact(4)?;
        Ok(u32::from_le_bytes([bytes[0], bytes[1], bytes[2], bytes[3]]))
    }

    fn read_u64(&mut self) -> Result<u64, GateError> {
        let bytes = self.read_exact(8)?;
        Ok(u64::from_le_bytes([
            bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
        ]))
    }

    fn read_array_16(&mut self) -> Result<[u8; 16], GateError> {
        let bytes = self.read_exact(16)?;
        let mut out = [0u8; 16];
        out.copy_from_slice(bytes);
        Ok(out)
    }

    fn read_string(&mut self) -> Result<String, GateError> {
        let len = self.read_u32()? as usize;
        Ok(String::from_utf8(self.read_exact(len)?.to_vec())?)
    }

    fn finish(self) -> Result<(), GateError> {
        if self.offset == self.data.len() {
            Ok(())
        } else {
            Err(GateError::Decode("trailing bytes"))
        }
    }
}
