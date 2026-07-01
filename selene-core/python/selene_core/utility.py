from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path
import re


@dataclass
class Utility(ABC):
    """
    An abstract base class for link-time "utility" plugins.

    Simulator plugins' python API should provide a specialisation of this class
    that provides the path to files which should be linked in with the selene executable
    """

    @property
    @abstractmethod
    def library_file(self) -> Path:
        """
        Utilities expose symbols that user programs can call into directly,
        rather than via the Selene interface itself. They are implemented as
        a compiled library, which you should provide through this property.
        """
        pass

    @property
    def link_flags(self) -> list[str]:
        """
        Returns the flags to be used when linking the plugin against the selene
        executable, if any. This is likely to include rpath entries, but may also
        include other flags.
        """
        return []

    @property
    def library_search_dirs(self) -> list[Path]:
        """
        Returns the paths to any additional libraries required by the plugin.
        """
        return []

    @property
    def registration_symbol(self) -> str | None:
        """
        Optional C symbol used to register runtime event callbacks.

        Utility libraries are linked into the final executable rather than
        loaded from Selene's plugin configuration. If this returns a symbol,
        Selene's build step generates a tiny registration object that calls
        the symbol once after Selene has been configured. The function must
        have this C signature:

            struct selene_void_result_t symbol(SeleneInstance *instance);

        The utility may then call selene_register_utility_event_callbacks().
        """
        return None

    def validate_registration_symbol(self) -> str | None:
        symbol = self.registration_symbol
        if symbol is None:
            return None
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", symbol):
            raise ValueError(f"Invalid utility registration symbol: {symbol!r}")
        return symbol
