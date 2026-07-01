const N: usize = 624;
const M: usize = 397;
const MATRIX_A: u64 = 0x9908_b0df;
const UPPER_MASK: u64 = 0x8000_0000;
const LOWER_MASK: u64 = 0x7fff_ffff;
const WORD_MASK: u64 = 0xffff_ffff;

/// Reproduces the old QuEST MT19937 measurement RNG on 64-bit Unix platforms.
///
/// The old plugin passed Selene's `u64` shot seed as a single C `unsigned long`.
/// QuEST then ran the reference MT19937 implementation whose state is stored in
/// `unsigned long` but masked to 32 bits after each state update.
pub struct LegacyQuestRng {
    mt: [u64; N],
    mti: usize,
}

impl LegacyQuestRng {
    pub fn seed_from_u64(seed: u64) -> Self {
        let mut rng = Self {
            mt: [0; N],
            mti: N + 1,
        };
        rng.init_by_array(&[seed]);
        rng
    }

    fn init_genrand(&mut self, seed: u64) {
        self.mt[0] = seed & WORD_MASK;
        for i in 1..N {
            self.mt[i] = (1_812_433_253_u64
                .wrapping_mul(self.mt[i - 1] ^ (self.mt[i - 1] >> 30))
                .wrapping_add(i as u64))
                & WORD_MASK;
        }
        self.mti = N;
    }

    fn init_by_array(&mut self, keys: &[u64]) {
        self.init_genrand(19_650_218);
        let mut i = 1;
        let mut j = 0;
        for _ in 0..N.max(keys.len()) {
            self.mt[i] = ((self.mt[i]
                ^ (self.mt[i - 1] ^ (self.mt[i - 1] >> 30)).wrapping_mul(1_664_525))
            .wrapping_add(keys[j])
            .wrapping_add(j as u64))
                & WORD_MASK;
            i += 1;
            j += 1;
            if i >= N {
                self.mt[0] = self.mt[N - 1];
                i = 1;
            }
            if j >= keys.len() {
                j = 0;
            }
        }
        for _ in 0..(N - 1) {
            self.mt[i] = ((self.mt[i]
                ^ (self.mt[i - 1] ^ (self.mt[i - 1] >> 30)).wrapping_mul(1_566_083_941))
            .wrapping_sub(i as u64))
                & WORD_MASK;
            i += 1;
            if i >= N {
                self.mt[0] = self.mt[N - 1];
                i = 1;
            }
        }
        self.mt[0] = UPPER_MASK;
    }

    fn genrand_int32(&mut self) -> u64 {
        if self.mti >= N {
            if self.mti == N + 1 {
                self.init_genrand(5489);
            }

            for kk in 0..(N - M) {
                let y = (self.mt[kk] & UPPER_MASK) | (self.mt[kk + 1] & LOWER_MASK);
                self.mt[kk] = self.mt[kk + M] ^ (y >> 1) ^ if y & 1 == 0 { 0 } else { MATRIX_A };
            }
            for kk in (N - M)..(N - 1) {
                let y = (self.mt[kk] & UPPER_MASK) | (self.mt[kk + 1] & LOWER_MASK);
                self.mt[kk] =
                    self.mt[kk + M - N] ^ (y >> 1) ^ if y & 1 == 0 { 0 } else { MATRIX_A };
            }
            let y = (self.mt[N - 1] & UPPER_MASK) | (self.mt[0] & LOWER_MASK);
            self.mt[N - 1] = self.mt[M - 1] ^ (y >> 1) ^ if y & 1 == 0 { 0 } else { MATRIX_A };
            self.mti = 0;
        }

        let mut y = self.mt[self.mti];
        self.mti += 1;

        y ^= y >> 11;
        y ^= (y << 7) & 0x9d2c_5680;
        y ^= (y << 15) & 0xefc6_0000;
        y ^= y >> 18;
        y & WORD_MASK
    }

    pub fn genrand_real1(&mut self) -> f64 {
        self.genrand_int32() as f64 * (1.0 / 4_294_967_295.0)
    }
}

#[cfg(test)]
mod tests {
    use super::LegacyQuestRng;

    #[test]
    fn matches_legacy_quest_linux_sequence() {
        let mut rng = LegacyQuestRng::seed_from_u64(1_234_567_890_123_456_789);
        assert_eq!(rng.genrand_int32(), 2_637_397_608);
        assert_eq!(rng.genrand_int32(), 835_775_448);
        assert_eq!(rng.genrand_int32(), 1_010_521_472);
        assert_eq!(rng.genrand_int32(), 3_788_146_913);
        assert_eq!(rng.genrand_int32(), 4_227_692_770);

        let mut rng = LegacyQuestRng::seed_from_u64(1_234_567_890_123_456_789);
        assert_eq!(rng.genrand_real1(), 0.6140669827847898);
        assert_eq!(rng.genrand_real1(), 0.19459413555324873);
        assert_eq!(rng.genrand_real1(), 0.23528036480659628);
        assert_eq!(rng.genrand_real1(), 0.8819966842145651);
        assert_eq!(rng.genrand_real1(), 0.9843364290390947);
    }
}
