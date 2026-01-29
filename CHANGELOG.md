# Changelog

## [0.2.9](https://github.com/Quantinuum/selene/compare/selene-sim-v0.2.8...selene-sim-v0.2.9) (2026-01-29)


### Bug Fixes

* avoid using qir_major_version string for QIR detection ([#123](https://github.com/Quantinuum/selene/issues/123)) ([deaa0dc](https://github.com/Quantinuum/selene/commit/deaa0dcee72833a0695cb3cdd82cad3c2374343e))


### Documentation

* Correct URL to guppy repository ([#121](https://github.com/Quantinuum/selene/issues/121)) ([27ded00](https://github.com/Quantinuum/selene/commit/27ded0063caa71db2a851835a6a290db8bdd085a))

## [0.2.8](https://github.com/Quantinuum/selene/compare/selene-sim-v0.2.7...selene-sim-v0.2.8) (2026-01-27)


### Features

* Bump selene-core dependency and relax guppylang testing dependency ([#120](https://github.com/Quantinuum/selene/issues/120)) ([6375791](https://github.com/Quantinuum/selene/commit/6375791d047a4de2293f624e810101a50ac6a5f8))
* QIR support using QIR-QIS ([#114](https://github.com/Quantinuum/selene/issues/114)) ([70ab294](https://github.com/Quantinuum/selene/commit/70ab294ffcabbb2cc81a29263bca60cd04f6579f))

## [0.2.7](https://github.com/Quantinuum/selene/compare/selene-sim-v0.2.6...selene-sim-v0.2.7) (2026-01-08)


### Features

* Add event hook which records measurement results ([#104](https://github.com/Quantinuum/selene/issues/104)) ([01300ee](https://github.com/Quantinuum/selene/commit/01300ee5d4825e2dfc6500941d0540c3ff06988a)), closes [#103](https://github.com/Quantinuum/selene/issues/103)
* Support state-dump passthrough on quantum replay simulator ([#108](https://github.com/Quantinuum/selene/issues/108)) ([1b01a01](https://github.com/Quantinuum/selene/commit/1b01a014f836c040554c3d1fffe8b9fc9d1eb2e3))

## [0.2.6](https://github.com/quantinuum/selene/compare/selene-sim-v0.2.5...selene-sim-v0.2.6) (2025-11-18)


### Bug Fixes

* Add ENDING to allowed shot state on receiving meta information ([#100](https://github.com/quantinuum/selene/issues/100)) ([fc4d673](https://github.com/quantinuum/selene/commit/fc4d673172f907c791713f8d5b0c6cfd920b3d4e))

## [0.2.5](https://github.com/quantinuum/selene/compare/selene-sim-v0.2.4...selene-sim-v0.2.5) (2025-11-07)


### Features

* Add support for object files provided as bytes ([#94](https://github.com/quantinuum/selene/issues/94)) ([c4cfac6](https://github.com/quantinuum/selene/commit/c4cfac69d916650bb716d56bc00a1da79645faf2))
* Cleanup error'd processes before log collection ([#98](https://github.com/quantinuum/selene/issues/98)) ([77e698e](https://github.com/quantinuum/selene/commit/77e698eb20bc60b6449e8655c1b655a12a8a363d))
* **compiler:** Bump tket version; add wasm + gpu to the hugr-qis registry ([c69155d](https://github.com/quantinuum/selene/commit/c69155d9717e942c6c67065dbf47cdb156542689))
* correct shot end strategy and error processing ([#91](https://github.com/quantinuum/selene/issues/91)) ([93eaeb0](https://github.com/quantinuum/selene/commit/93eaeb00fe22c701a5de81afee238f31e089ea03))
* Emit a nicer error when trying to emulate unsupported pytket ops ([#72](https://github.com/quantinuum/selene/issues/72)) ([d88a28a](https://github.com/quantinuum/selene/commit/d88a28a827d15fb2fcbc036964452fdcfd7b1cd8))
* Result stream handling refactor ([#93](https://github.com/quantinuum/selene/issues/93)) ([607a55e](https://github.com/quantinuum/selene/commit/607a55e6033e737bbaf5fd665f9ec04dc1348618))


### Bug Fixes

* **compiler:** error when entrypoint has arguments ([#84](https://github.com/quantinuum/selene/issues/84)) ([604b131](https://github.com/quantinuum/selene/commit/604b1311b96593609e699a6bb8251ad3c952ebdb))
* **compiler:** update tket-qystem to fix CZ bug ([#78](https://github.com/quantinuum/selene/issues/78)) ([3991f11](https://github.com/quantinuum/selene/commit/3991f11a73d8ceebf0346a8c43248fde73e1b549))

## [0.2.4](https://github.com/quantinuum/selene/compare/selene-sim-v0.2.3...selene-sim-v0.2.4) (2025-08-28)


### Bug Fixes

* correct post_runtime duration metric ([#74](https://github.com/quantinuum/selene/issues/74)) ([0bef66a](https://github.com/quantinuum/selene/commit/0bef66aeaaccbadf08ba38a735a5146382326c2a))

## [0.2.3](https://github.com/quantinuum/selene/compare/selene-sim-v0.2.2...selene-sim-v0.2.3) (2025-08-26)


### Features

* Better exception handling for parse_shots=False ([#70](https://github.com/quantinuum/selene/issues/70)) ([3caf530](https://github.com/quantinuum/selene/commit/3caf530dfcf616fa3f2e335692b6963a1b828b11))
* Fine-grained timeout configuration ([#69](https://github.com/quantinuum/selene/issues/69)) ([072842e](https://github.com/quantinuum/selene/commit/072842efa396ab9d964f4abd6ef4badb49bf002a))
* update to tket-qsystem 0.20 ([#66](https://github.com/quantinuum/selene/issues/66)) ([7191b07](https://github.com/quantinuum/selene/commit/7191b07c00571c0298b3cfc334058d3e649fe377))

## [0.2.2](https://github.com/quantinuum/selene/compare/selene-sim-v0.2.1...selene-sim-v0.2.2) (2025-08-20)


### Features

* random_advance ([#55](https://github.com/quantinuum/selene/issues/55)) ([974b496](https://github.com/quantinuum/selene/commit/974b496e3bc15b8ce155542d4f31e4e9fad245ed))
