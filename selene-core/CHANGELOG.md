# Changelog

## [0.3.0-alpha.1](https://github.com/Quantinuum/selene/compare/selene-core-v0.3.0-alpha.0...selene-core-v0.3.0-alpha.1) (2026-06-12)


### ⚠ BREAKING CHANGES

* Use struct exports for all plugin types, separate error model and simulator ([#169](https://github.com/Quantinuum/selene/issues/169))
* Add handling for an additional gateset ([#119](https://github.com/Quantinuum/selene/issues/119))

### Features

* Add __version__ attributes ([#137](https://github.com/Quantinuum/selene/issues/137)) ([379ae01](https://github.com/Quantinuum/selene/commit/379ae0151f18c7410a5f02457a79cc86b5df9d30))
* Add handling for an additional gateset ([#119](https://github.com/Quantinuum/selene/issues/119)) ([5180b80](https://github.com/Quantinuum/selene/commit/5180b80bd64bfddce68da4b61827d995642fc3d7))
* Add simulate_delay functionality ([#139](https://github.com/Quantinuum/selene/issues/139)) ([cca97fa](https://github.com/Quantinuum/selene/commit/cca97fa0c4cbc22185351be33508fe09713c792c))
* Add support for object files provided as bytes ([#94](https://github.com/Quantinuum/selene/issues/94)) ([c4cfac6](https://github.com/Quantinuum/selene/commit/c4cfac69d916650bb716d56bc00a1da79645faf2))
* add timing to builtin runtimes and batching options to softrz runtime ([#158](https://github.com/Quantinuum/selene/issues/158)) ([049e123](https://github.com/Quantinuum/selene/commit/049e1231ba70ced08aa6477cf9c7efb579d4f659))
* Build improvements ([#142](https://github.com/Quantinuum/selene/issues/142)) ([12f399b](https://github.com/Quantinuum/selene/commit/12f399bc1005b2bf041e9e4cbe15dc7ed1737417))
* Interactive use of Selene from python ([#135](https://github.com/Quantinuum/selene/issues/135)) ([db3028d](https://github.com/Quantinuum/selene/commit/db3028d250746b00e4f4cb671a780b9cb888d95f))
* Make interfaces shared, add ArgReader ([#171](https://github.com/Quantinuum/selene/issues/171)) ([143e742](https://github.com/Quantinuum/selene/commit/143e742d1a5912dd8c92f44dd31a69f462ac3c88))
* QIR support using QIR-QIS ([#114](https://github.com/Quantinuum/selene/issues/114)) ([70ab294](https://github.com/Quantinuum/selene/commit/70ab294ffcabbb2cc81a29263bca60cd04f6579f))
* Result stream handling refactor ([#93](https://github.com/Quantinuum/selene/issues/93)) ([607a55e](https://github.com/Quantinuum/selene/commit/607a55e6033e737bbaf5fd665f9ec04dc1348618))
* Stim improvements (more ops + state printing) ([#115](https://github.com/Quantinuum/selene/issues/115)) ([867d5e5](https://github.com/Quantinuum/selene/commit/867d5e5eba308eda3087e61690181b2030cbb56f))
* test on QIS instead of relying on the upper stack ([#150](https://github.com/Quantinuum/selene/issues/150)) ([b80a9c4](https://github.com/Quantinuum/selene/commit/b80a9c411e58ef4987e90fd8511088f9b617f889))
* Traces for analytics ([#160](https://github.com/Quantinuum/selene/issues/160)) ([24b9978](https://github.com/Quantinuum/selene/commit/24b997803cc91a5efc7039c91dd19509f1883e8e))
* Use mingw instead of msvc for windows wheels ([#143](https://github.com/Quantinuum/selene/issues/143)) ([3d91514](https://github.com/Quantinuum/selene/commit/3d91514ad96d43924c9444190aa8a4af73554722))
* Use struct exports for all plugin types, separate error model and simulator ([#169](https://github.com/Quantinuum/selene/issues/169)) ([c44a5c9](https://github.com/Quantinuum/selene/commit/c44a5c9e226165db1100a43fa2f57a37f4dca6fa))


### Bug Fixes

* add `___barrier` to Helios QIS for QIR emulation ([#136](https://github.com/Quantinuum/selene/issues/136)) ([dfbc4c3](https://github.com/Quantinuum/selene/commit/dfbc4c37e3533b23ae843d4a5b232786afb8b6b7))
* avoid using qir_major_version string for QIR detection ([#123](https://github.com/Quantinuum/selene/issues/123)) ([deaa0dc](https://github.com/Quantinuum/selene/commit/deaa0dcee72833a0695cb3cdd82cad3c2374343e))
* classify lowered qir-qis bitcode as helios ([#157](https://github.com/Quantinuum/selene/issues/157)) ([67fca60](https://github.com/Quantinuum/selene/commit/67fca60db58dd6b04de8656cfc9dbd9d62a9d92f))
* make qir-qis optional and stabilize CI ([#164](https://github.com/Quantinuum/selene/issues/164)) ([e52c0b2](https://github.com/Quantinuum/selene/commit/e52c0b2b30a5f227943477857ca1f0175ae6a2d5))

## [0.2.10](https://github.com/Quantinuum/selene/compare/selene-core-v0.2.9...selene-core-v0.2.10) (2026-05-21)


### Features

* Make interfaces shared, add ArgReader ([#171](https://github.com/Quantinuum/selene/issues/171)) ([143e742](https://github.com/Quantinuum/selene/commit/143e742d1a5912dd8c92f44dd31a69f462ac3c88))

## [0.2.9](https://github.com/Quantinuum/selene/compare/selene-core-v0.2.8...selene-core-v0.2.9) (2026-04-27)


### Bug Fixes

* make qir-qis optional and stabilize CI ([#164](https://github.com/Quantinuum/selene/issues/164)) ([e52c0b2](https://github.com/Quantinuum/selene/commit/e52c0b2b30a5f227943477857ca1f0175ae6a2d5))

## [0.2.8](https://github.com/Quantinuum/selene/compare/selene-core-v0.2.7...selene-core-v0.2.8) (2026-04-21)


### Features

* add timing to builtin runtimes and batching options to softrz runtime ([#158](https://github.com/Quantinuum/selene/issues/158)) ([049e123](https://github.com/Quantinuum/selene/commit/049e1231ba70ced08aa6477cf9c7efb579d4f659))
* Traces for analytics ([#160](https://github.com/Quantinuum/selene/issues/160)) ([24b9978](https://github.com/Quantinuum/selene/commit/24b997803cc91a5efc7039c91dd19509f1883e8e))


### Bug Fixes

* classify lowered qir-qis bitcode as helios ([#157](https://github.com/Quantinuum/selene/issues/157)) ([67fca60](https://github.com/Quantinuum/selene/commit/67fca60db58dd6b04de8656cfc9dbd9d62a9d92f))

## [0.2.7](https://github.com/Quantinuum/selene/compare/selene-core-v0.2.6...selene-core-v0.2.7) (2026-04-10)


### Features

* Build improvements ([#142](https://github.com/Quantinuum/selene/issues/142)) ([12f399b](https://github.com/Quantinuum/selene/commit/12f399bc1005b2bf041e9e4cbe15dc7ed1737417))
* test on QIS instead of relying on the upper stack ([#150](https://github.com/Quantinuum/selene/issues/150)) ([b80a9c4](https://github.com/Quantinuum/selene/commit/b80a9c411e58ef4987e90fd8511088f9b617f889))
* Use mingw instead of msvc for windows wheels ([#143](https://github.com/Quantinuum/selene/issues/143)) ([3d91514](https://github.com/Quantinuum/selene/commit/3d91514ad96d43924c9444190aa8a4af73554722))

## [0.2.6](https://github.com/Quantinuum/selene/compare/selene-core-v0.2.5...selene-core-v0.2.6) (2026-03-02)


### Features

* Add simulate_delay functionality ([#139](https://github.com/Quantinuum/selene/issues/139)) ([cca97fa](https://github.com/Quantinuum/selene/commit/cca97fa0c4cbc22185351be33508fe09713c792c))

## [0.2.5](https://github.com/Quantinuum/selene/compare/selene-core-v0.2.4...selene-core-v0.2.5) (2026-02-24)


### Features

* Add __version__ attributes ([#137](https://github.com/Quantinuum/selene/issues/137)) ([379ae01](https://github.com/Quantinuum/selene/commit/379ae0151f18c7410a5f02457a79cc86b5df9d30))
* Interactive use of Selene from python ([#135](https://github.com/Quantinuum/selene/issues/135)) ([db3028d](https://github.com/Quantinuum/selene/commit/db3028d250746b00e4f4cb671a780b9cb888d95f))
* Stim improvements (more ops + state printing) ([#115](https://github.com/Quantinuum/selene/issues/115)) ([867d5e5](https://github.com/Quantinuum/selene/commit/867d5e5eba308eda3087e61690181b2030cbb56f))


### Bug Fixes

* add `___barrier` to Helios QIS for QIR emulation ([#136](https://github.com/Quantinuum/selene/issues/136)) ([dfbc4c3](https://github.com/Quantinuum/selene/commit/dfbc4c37e3533b23ae843d4a5b232786afb8b6b7))

## [0.2.4](https://github.com/Quantinuum/selene/compare/selene-core-v0.2.3...selene-core-v0.2.4) (2026-01-29)


### Bug Fixes

* avoid using qir_major_version string for QIR detection ([#123](https://github.com/Quantinuum/selene/issues/123)) ([deaa0dc](https://github.com/Quantinuum/selene/commit/deaa0dcee72833a0695cb3cdd82cad3c2374343e))

## [0.2.3](https://github.com/Quantinuum/selene/compare/selene-core-v0.2.2...selene-core-v0.2.3) (2026-01-26)


### Features

* QIR support using QIR-QIS ([#114](https://github.com/Quantinuum/selene/issues/114)) ([70ab294](https://github.com/Quantinuum/selene/commit/70ab294ffcabbb2cc81a29263bca60cd04f6579f))

## [0.2.2](https://github.com/quantinuum/selene/compare/selene-core-v0.2.1...selene-core-v0.2.2) (2025-11-07)


### Features

* Add support for object files provided as bytes ([#94](https://github.com/quantinuum/selene/issues/94)) ([c4cfac6](https://github.com/quantinuum/selene/commit/c4cfac69d916650bb716d56bc00a1da79645faf2))
* Result stream handling refactor ([#93](https://github.com/quantinuum/selene/issues/93)) ([607a55e](https://github.com/quantinuum/selene/commit/607a55e6033e737bbaf5fd665f9ec04dc1348618))
