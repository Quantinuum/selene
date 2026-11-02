# These compatibility functions let the existing planner use the Rust
# toolchain's build plans and store without changing its artifact kinds.

from selene_toolchain import compile_object, link_executable, target_triple

__all__ = ["compile_object", "link_executable", "target_triple"]
