# Bundled inputs

We originally performed linking by use of the python ziglang package, but
have since moved to bundling more direct tools. One left over aspect is
`darwin/libSystem.tbd`, which is sourced from Zig 0.13.0's
`lib/libc/darwin/libSystem.tbd`. This stub is for macos usage, and allows us
to link to the macOS system libraries that are present on the user's system.
Zig's history identifies the upstream update as an import from Apple's SDK 14.0
release candidate (commit `52e835492626b34b34a46115f953591e01d1088e`). Zig's MIT licence is included
as attribution.

LLVM binaries come from the hugrenv version pinned by the repository's
`hugrenv.lock`. `LLVM.txt` contains Apache-2.0 with LLVM exceptions.
`LLVM-regex.txt` contains the additional regex copyright notice. A complete
inventory of third-party code in the shipped LLVM binaries is still needed.

Linux startup and link libraries come from the build compiler's glibc and GCC.
The wheel records the compiler version in `_dist/link.json`. glibc permits
LGPL-2.1 or later; we distribute its copied link inputs under LGPL-3.0 so we can
provide corresponding source through a separate download server. The original
notices and both licence texts are included. GCC runtime libraries use GPL-3.0
with the GCC runtime exception.
Release Linux wheels include `_dist/sources.json` with links and checksums for
the matching glibc and GCC source RPMs, including distribution patches and
build recipes. These RPMs are separate assets on the same GitHub release as
the wheels, and the PyPI description also directs users there. We keep these
downloads available while distributing the wheels.

The GCC runtime exception permits eligible combinations with independent
programs, but we also distribute the runtime archives themselves. Corresponding
source access for those files is provided by the release assets above.

Windows startup and import libraries come from the selected MinGW GCC installation.
Its MinGW-w64 and GCC runtime licence texts are included. These libraries must
remain aligned with Selene's MinGW target and C runtime choice.
The compiler's own build information and source links accompany the wheel.
For the current CI compiler, GCC's unmodified sources are available at
https://gcc.gnu.org/pub/gcc/releases/gcc-14.2.0/gcc-14.2.0.tar.xz and the
build scripts and patches at
https://github.com/niXman/mingw-builds/tree/77e2ab8eb66a49de8602f141ae67bedaa4ebe88b.
The copied build information lists which patches and configure arguments were
used. A release build fails if that information changes, so a different
compiler distribution can't silently inherit these source links.

Windows LLVM tools come from hugrenv's `win_mingw_amd64` archive. We copy its
GNU runtime DLLs alongside the tools, and build the inspector with the same
MinGW compiler distribution. The build checks that the compiler's build
information matches hugrenv's before using its LLVM libraries. The source links
and GNU/MinGW licence notices above cover these runtime inputs as well.

The package's Apache-2.0 metadata describes our own source code; it
doesn't replace the licences of the bundled third-party files.

Upstream locations:

- https://github.com/ziglang/zig/tree/0.13.0/lib/libc/darwin
- https://github.com/llvm/llvm-project/tree/llvmorg-21.1.8
- https://sourceware.org/glibc/
- https://gcc.gnu.org/
- https://github.com/mingw-w64/mingw-w64
