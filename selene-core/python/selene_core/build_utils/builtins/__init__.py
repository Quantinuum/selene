"""
This module exposes the selene and hugr artifacts and steps, for
registration with a build planner. Note that it does not expose
the compilation from hugr to selene-compatible object files, as
this is managed by the Interface plugin being used.
"""

import importlib.util

from ..planner import BuildPlanner
from .selene import (
    SeleneExecutableKind,
    SeleneObjectFileKind,
    SeleneObjectToSeleneExecutableStep,
    register_selene_builtins,
)

from .helios import (
    HeliosLLVMIRStringKind,
    HeliosLLVMIRFileKind,
    HeliosLLVMBitcodeStringKind,
    HeliosLLVMBitcodeFileKind,
    HeliosObjectFileKind,
    LLVMBitcodeStringToLLVMBitcodeFileStep,
    LLVMIRStringToLLVMIRFileStep,
    HeliosLLVMIRFileToHeliosObjectFileStep,
    HeliosLLVMBitcodeFileToHeliosObjectFileStep,
    HeliosObjectFileToSeleneExecutableStep,
    register_helios_builtins,
)

additional_registrations = []
additional_exports = []

if importlib.util.find_spec("hugr") is not None:
    from .hugr import register_hugr_builtins

    additional_registrations.append(register_hugr_builtins)

    from .hugr import (
        HUGRPackageKind,  # noqa: F401
        HUGRPackagePointerKind,  # noqa: F401
        HUGREnvelopeFileKind,  # noqa: F401
        HUGREnvelopeBytesKind,  # noqa: F401
        HUGRPackageToHUGREnvelopeBytesStep,  # noqa: F401
        HUGRPackagePointerToHugrPackageStep,  # noqa: F401
        HUGREnvelopeBytesToHUGRPackageStep,  # noqa: F401
        HUGREnvelopeBytesToHUGREnvelopeFileStep,  # noqa: F401
        HUGREnvelopeFileToHUGREnvelopeBytesStep,  # noqa: F401
    )

    additional_exports.extend(
        [
            "HUGRPackageKind",
            "HUGRPackagePointerKind",
            "HUGREnvelopeFileKind",
            "HUGREnvelopeBytesKind",
            "HUGRPackageToHUGREnvelopeBytesStep",
            "HUGRPackagePointerToHugrPackageStep",
            "HUGREnvelopeBytesToHUGRPackageStep",
            "HUGREnvelopeBytesToHUGREnvelopeFileStep",
            "HUGREnvelopeFileToHUGREnvelopeBytesStep",
        ]
    )

if importlib.util.find_spec("qir_qis") is not None:
    from .qir import register_qir_builtins

    additional_registrations.append(register_qir_builtins)

    from .qir import (
        QIRIRFileKind,  # noqa: F401
        QIRIRStringKind,  # noqa: F401
        QIRBitcodeFileKind,  # noqa: F401
        QIRBitcodeStringKind,  # noqa: F401
        QIRIRStringToQIRIRFileStep,  # noqa: F401
        QIRIRFileToQIRIRStringStep,  # noqa: F401
        QIRBitcodeStringToQIRBitcodeFileStep,  # noqa: F401
        QIRIRFileToQIRBitcodeFileStep,  # noqa: F401
        QIRBitcodeFileToQIRBitcodeStringStep,  # noqa: F401
        QIRBitcodeStringToHeliosBitcodeStringStep,  # noqa: F401
    )

    additional_exports.extend(
        [
            "QIRIRFileKind",
            "QIRIRStringKind",
            "QIRBitcodeFileKind",
            "QIRBitcodeStringKind",
            "QIRIRStringToQIRIRFileStep",
            "QIRIRFileToQIRIRStringStep",
            "QIRBitcodeStringToQIRBitcodeFileStep",
            "QIRIRFileToQIRBitcodeFileStep",
            "QIRBitcodeFileToQIRBitcodeStringStep",
            "QIRBitcodeStringToHeliosBitcodeStringStep",
        ]
    )


def register_builtins(planner: BuildPlanner):
    """
    Register built-in types and steps to the build planner.
    """
    register_selene_builtins(planner)
    register_helios_builtins(planner)
    for reg in additional_registrations:
        reg(planner)


__all__ = [
    "SeleneExecutableKind",
    "SeleneObjectFileKind",
    "HeliosLLVMIRStringKind",
    "HeliosLLVMIRFileKind",
    "HeliosLLVMBitcodeStringKind",
    "HeliosLLVMBitcodeFileKind",
    "HeliosObjectFileKind",
    "LLVMBitcodeStringToLLVMBitcodeFileStep",
    "LLVMIRStringToLLVMIRFileStep",
    "HeliosLLVMIRFileToHeliosObjectFileStep",
    "HeliosLLVMBitcodeFileToHeliosObjectFileStep",
    "HeliosObjectFileToSeleneExecutableStep",
    "SeleneObjectToSeleneExecutableStep",
    "register_builtins",
] + additional_exports
