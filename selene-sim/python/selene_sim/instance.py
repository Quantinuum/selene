import shutil
from pathlib import Path
from typing import Iterator
from dataclasses import dataclass
import yaml

from selene_core import SeleneComponent, Simulator, ErrorModel, Runtime

from .backends import SimpleRuntime, IdealErrorModel
from .result_handling import TaggedResult
from .event_hooks import EventHook, NoEventHook
from .result_handling import ResultStream, TCPStream, parse_shot
from .result_handling import DataStream, ShmemStream
from .result_handling.shmem_stream import DEFAULT_CAPACITY
from .timeout import Timeout, TimeoutInput
from .process import SeleneProcess, SeleneProcessList


@dataclass
class ShotSpec:
    """
    Describes how a simulation run should progress through shot numbers.
    This can be customised to interleave multiple runs.
    """

    count: int
    offset: int = 0
    increment: int = 1

    def __contains__(self, shot: int) -> bool:
        delta = shot - self.offset
        if delta % self.increment != 0:
            return False
        return 0 <= (delta // self.increment) < self.count


yaml.SafeDumper.add_representer(
    ShotSpec,
    lambda dumper, data: dumper.represent_mapping(
        "tag:yaml.org,2002:map",
        {
            "count": data.count,
            "offset": data.offset,
            "increment": data.increment,
        },
    ),
)


@dataclass
class SeleneInstance:
    """
    Represents a selene instance, which is a wrapper around the selene executable
    generated from a user program by build.py's `build` function.
    """

    root: Path
    artifacts: Path
    runs: Path
    executable: Path
    library_search_dirs: list[Path]

    def __post_init__(self):
        """
        Setup the run directory ready for invocation.
        """
        self.artifacts.mkdir(parents=True, exist_ok=True)
        self.runs.mkdir(exist_ok=True)

    def write_manifest(self, data: dict):
        """
        Writes the build manifest corresponding to this instance
        for future reference.
        """
        with open(self.root / "selene.yaml", "w") as fh:
            yaml.safe_dump(data, fh)

    @staticmethod
    def _get_component_config(
        component: SeleneComponent, default_seed: int | None
    ) -> dict:
        """
        Helper method to generate a dictionary form of the configuration
        required for a selene component (e.g. runtime, error model, simulator).

        This is later written to a yaml file ready for selene loading.
        """
        full_python_name = ".".join(
            (component.__class__.__module__, component.__class__.__qualname__)
        )
        result = {
            "name": full_python_name,
            "file": component.library_file,
            "args": component.get_init_args(),
        }
        if component.random_seed is not None:
            result["seed"] = component.random_seed
        elif default_seed is not None:
            result["seed"] = default_seed
        return result

    def _create_new_run_directory(self) -> Path:
        """
        Creates and returns the run directory for the next user program
        invocation.
        """
        i = 1
        while (self.runs / f"{i:04d}").exists():
            i += 1
        run_dir = self.runs / f"{i:04d}"
        run_dir.mkdir()
        return run_dir

    def delete_files(self):
        """
        Deletes the files associated with this instance, including the
        executable, artifacts, and run directories.
        """
        shutil.rmtree(self.root)

    def delete_run_directories(self):
        """
        Deletes the run directories associated with this instance.
        This does not delete the artifacts directory or the executable.
        """
        for run_dir in self.runs.iterdir():
            if run_dir.is_dir():
                shutil.rmtree(run_dir)

    def _check_health(self):
        """
        Checks the health of the instance, ensuring that the root directory
        and executable exist. If they do not, raises a FileNotFoundError.

        If the runs directory does not exist, it is created.
        """
        if not self.root.exists():
            raise FileNotFoundError(
                f"This Selene instance's root directory does not exist ({self.root}). "
                "This is likely because the instance has been deleted. Please rebuild."
            )
        if not self.executable.exists():
            raise FileNotFoundError(
                f"This Selene instance's executable does not exist ({self.root}). "
                f"This is likely because the file has been deleted manually. Please rebuild."
            )

        if not self.runs.exists():
            print("Warning: The runs directory does not exist. Creating it again.")
            self.runs.mkdir(parents=True, exist_ok=True)

    def _make_data_stream(
        self,
        transport: str,
        timeout: Timeout,
        logfile: Path | None,
        shot_offset: int,
        shot_increment: int,
        shmem_capacity: int,
    ) -> DataStream:
        """
        Construct the results-stream transport for a run.
        """
        match transport:
            case "tcp":
                return TCPStream(
                    timeout=timeout,
                    logfile=logfile,
                    shot_offset=shot_offset,
                    shot_increment=shot_increment,
                )
            case "shmem":
                return ShmemStream(
                    capacity=shmem_capacity,
                    timeout=timeout,
                    logfile=logfile,
                    shot_offset=shot_offset,
                    shot_increment=shot_increment,
                )
            case _:
                raise ValueError(
                    f"Unknown transport '{transport}'. Expected 'tcp' or 'shmem'."
                )

    def run_shots(
        self,
        simulator: Simulator,
        n_qubits: int,
        n_shots: int = 1,
        error_model: ErrorModel = IdealErrorModel(),
        runtime: Runtime = SimpleRuntime(),
        event_hook: EventHook = NoEventHook(),
        verbose: bool = False,
        timeout: TimeoutInput = None,
        results_logfile: Path | None = None,
        random_seed: int | None = None,
        shot_offset: int = 0,
        shot_increment: int = 1,
        n_processes: int = 1,
        parse_results: bool = True,
        transport: str = "tcp",
        shmem_capacity: int = DEFAULT_CAPACITY,
    ) -> Iterator[Iterator[TaggedResult]]:
        """
        Run the compiled program through multiple selene shots.
        Args:
            simulator: The simulator plugin to use
            n_qubits: The maximum number of qubits to simulate
            n_shots: The number of shots to run
            error_model: The error model plugin to use (if any)
            runtime: The runtime plugin to use
            event_hook: Event hook that configures Selene to output
                        additional information to the results stream,
                        and handles the output.
            verbose: Whether to print verbose output for diagnostics
            timeout: Timeout configuration for various aspects of the
                     emulation run. If a timedelta is provided directly,
                     it is assumed to be the time limit of the overall
                     run. If None is provided, no timeout is set. If
                     a float is provided, it is assumed to be the time limit
                     in seconds of the overall run.
            results_logfile: The file to write the results to (if any)
            random_seed: The random seed to use for the simulator, error model,
                         and runtime if they have not been set explicitly. On
                         each shot, the random seed will be incremented by 1.
            parse_results:
                Whether to interpret tags in the result stream.
                If True (default), tags will be stripped, interpreted,
                and routed according to their type, e.g:
                - ("USER:INT:example", 42) will be interpreted as
                    an output variable "example"
                - ("METRICS:INT:user_program:qalloc_count", 5) will
                    be interpreted as a metric with the name "qalloc_count"
                    in the "user_program" namespace, and given to a MetricStore
                    event hook WITHOUT yielding it as a result.
                If False, no stripping or routing will be done: everything
                in the result stream is passed directly to the result iterator,
                e.g:
                - ("USER:INT:example", 42) will be yielded as-is,
                  without interpretation.
                - ("METRICS:INT:user_program:qalloc_count", 5) will
                  also be yielded as-is, without interpretation.
                Setting to True provides the high level Selene interface, and
                using False allows for Selene to be used as an intermediate
                component for use with an external result stream handler.
            transport:
                The results-stream transport to use. Either "tcp" (default),
                which streams results over a loopback TCP socket and supports
                multiple writer processes, or "shmem", which streams results
                through a fixed-size, single-writer/single-reader shared-memory
                FIFO created and destroyed by this process. The "shmem"
                transport only supports a single writer process, so
                `n_processes` must be 1.
            shmem_capacity:
                The capacity in bytes of the shared-memory FIFO when
                `transport="shmem"`. Ignored for other transports.
        """

        self._check_health()
        n_processes = max(1, n_processes)
        n_processes = min(n_processes, n_shots)

        if transport == "shmem" and n_processes > 1:
            raise ValueError(
                "The 'shmem' transport is single-writer/single-reader and "
                f"only supports a single process, but n_processes={n_processes} "
                "was requested. Use transport='tcp' for multi-process runs."
            )

        timeout = Timeout.resolve_input(timeout)

        processes = SeleneProcessList()
        library_search_dirs = self.library_search_dirs.copy()
        for component in (simulator, error_model, runtime):
            library_search_dirs.extend(component.library_search_dirs)
        global_configuration = {
            "event_hooks": {flag: True for flag in event_hook.get_selene_flags()},
            "n_qubits": n_qubits,
            "simulator": self._get_component_config(simulator, random_seed),
            "error_model": self._get_component_config(error_model, random_seed),
            "runtime": self._get_component_config(runtime, random_seed),
        }
        with self._make_data_stream(
            transport=transport,
            timeout=timeout,
            logfile=results_logfile,
            shot_offset=shot_offset,
            shot_increment=shot_increment,
            shmem_capacity=shmem_capacity,
        ) as data_stream:
            global_configuration["output_stream"] = data_stream.get_uri()

            for i in range(n_processes):
                shot_spec = ShotSpec(
                    offset=shot_offset + i * shot_increment,
                    increment=shot_increment * n_processes,
                    count=n_shots // n_processes + (n_shots % n_processes > i),
                )
                run_directory = self._create_new_run_directory()
                artifact_directory = run_directory / "artifacts"
                artifact_directory.mkdir(parents=True, exist_ok=True)
                configuration = global_configuration | {
                    "shots": shot_spec,
                    "artifact_dir": artifact_directory,
                }
                processes.add(
                    SeleneProcess(
                        executable=self.executable,
                        library_search_dirs=library_search_dirs,
                        configuration=configuration,
                        run_directory=run_directory,
                    )
                )

            processes.spawn()
            result_stream = ResultStream(data_stream)
            for i in range(n_shots):
                shot_idx = shot_offset + (i * shot_increment)
                if verbose:
                    print(f"Processing shot {shot_idx}")
                if data_stream.done:
                    raise Exception(
                        "Results stream has ended before all shots are processed"
                    )
                event_hook.on_new_shot()
                relevant_process = processes.find(shot_idx)
                assert relevant_process is not None
                yield parse_shot(
                    stream=result_stream,
                    event_hook=event_hook,
                    full=parse_results,
                    process=relevant_process,
                )

        processes.wait(check_return_code=not result_stream.tainted)

    def run(
        self,
        simulator: Simulator,
        n_qubits: int,
        runtime: Runtime = SimpleRuntime(),
        error_model: ErrorModel = IdealErrorModel(),
        event_hook: EventHook = NoEventHook(),
        verbose: bool = False,
        timeout: TimeoutInput = None,
        results_logfile=None,
        random_seed: int | None = None,
        shot_offset: int = 0,
        parse_results: bool = True,
        transport: str = "tcp",
        shmem_capacity: int = DEFAULT_CAPACITY,
    ) -> Iterator[TaggedResult]:
        """
        Run the compiled program through a single selene shot.

        Args:
            simulator: The simulator plugin to use
            n_qubits: The maximum number of qubits to simulate
            runtime: The runtime plugin to use
            error_model: The error model plugin to use (if any)
            event_hook: Event hook that configures Selene to output
                        additional information to the results stream,
                        and handles the output.
            verbose: Whether to print verbose output for diagnostics
            timeout: The maximum time to wait for the program to complete
            results_logfile: The file to write the results to (if any)
            random_seed: The random seed to use for the simulator, error model,
                         and runtime if they have not been set explicitly
        """
        shot_generator = self.run_shots(
            simulator=simulator,
            runtime=runtime,
            error_model=error_model,
            n_qubits=n_qubits,
            n_shots=1,
            event_hook=event_hook,
            verbose=verbose,
            timeout=timeout,
            results_logfile=results_logfile,
            random_seed=random_seed,
            shot_offset=shot_offset,
            parse_results=parse_results,
            transport=transport,
            shmem_capacity=shmem_capacity,
        )
        # We cannot simply yield from the shot generator, as this can
        # cause lifetime issues with the run_shots generator.
        # Keep it in scope with a context manager.
        from contextlib import contextmanager

        @contextmanager
        def one_shot_context():
            shot = next(shot_generator)
            try:
                yield shot
            finally:
                try:
                    next(shot_generator)
                except StopIteration:
                    pass

        with one_shot_context() as context:
            yield from context

    def profile(
        self,
        simulator: Simulator,
        n_qubits: int,
        n_shots: int = 1,
        error_model: ErrorModel = IdealErrorModel(),
        runtime: Runtime = SimpleRuntime(),
        event_hook: EventHook = NoEventHook(),
        verbose: bool = False,
        timeout: TimeoutInput = None,
        results_logfile: Path | None = None,
        random_seed: int | None = None,
        shot_offset: int = 0,
        shot_increment: int = 1,
        parse_results: bool = True,
        output_file: Path | None = None,
        transport: str = "tcp",
        shmem_capacity: int = DEFAULT_CAPACITY,
    ) -> Iterator[Iterator[TaggedResult]]:
        """
        Run the compiled program under ``samply record`` for CPU profiling.

        By default samply opens the Firefox Profiler in the browser once the
        process finishes. Pass ``output_file`` to instead save the profile to
        disk without opening the browser (uses ``samply record --save-only``).

        Note: profiling always uses a single process regardless of shot count.
        For useful profiling data, build the program with ``emit_debug=True``.

        Args:
            simulator: The simulator plugin to use.
            n_qubits: The maximum number of qubits to simulate.
            n_shots: The number of shots to run.
            error_model: The error model plugin to use.
            runtime: The runtime plugin to use.
            event_hook: Event hook for additional output.
            verbose: Whether to print verbose output.
            timeout: Timeout configuration for the overall run.
            results_logfile: File to write the raw results stream to.
            random_seed: Random seed for the simulator, error model, and runtime.
            shot_offset: Shot number of the first shot.
            shot_increment: Increment between successive shot numbers.
            parse_results: Whether to interpret tags in the result stream.
            output_file: If provided, save the samply profile to this path
                         (``--save-only``) instead of opening the browser.
            transport: The results-stream transport to use, either "tcp"
                       (default) or "shmem". Profiling always uses a single
                       process, so both transports are supported.
            shmem_capacity: The capacity in bytes of the shared-memory FIFO
                            when ``transport="shmem"``. Ignored otherwise.

        Yields:
            One iterator of :class:`~selene_sim.result_handling.TaggedResult`
            per shot, in the same structure as :meth:`run_shots`.

        Raises:
            RuntimeError: If ``samply`` is not found on ``PATH``.
        """
        samply_path = shutil.which("samply")
        if samply_path is None:
            raise RuntimeError(
                "Could not find `samply` on PATH. "
                "Install it from https://github.com/mstange/samply and ensure "
                "it is available on your PATH before calling profile()."
            )

        self._check_health()

        command_prefix = [samply_path, "record"]
        if output_file is not None:
            command_prefix += ["--save-only", "--output", str(output_file)]

        timeout = Timeout.resolve_input(timeout)

        library_search_dirs = self.library_search_dirs.copy()
        for component in (simulator, error_model, runtime):
            library_search_dirs.extend(component.library_search_dirs)
        global_configuration = {
            "event_hooks": {flag: True for flag in event_hook.get_selene_flags()},
            "n_qubits": n_qubits,
            "simulator": self._get_component_config(simulator, random_seed),
            "error_model": self._get_component_config(error_model, random_seed),
            "runtime": self._get_component_config(runtime, random_seed),
        }

        # Profiling always uses a single process so that samply wraps exactly
        # one executable instance.
        shot_spec = ShotSpec(
            offset=shot_offset,
            increment=shot_increment,
            count=n_shots,
        )
        run_directory = self._create_new_run_directory()
        artifact_directory = run_directory / "artifacts"
        artifact_directory.mkdir(parents=True, exist_ok=True)

        with self._make_data_stream(
            transport=transport,
            timeout=timeout,
            logfile=results_logfile,
            shot_offset=shot_offset,
            shot_increment=shot_increment,
            shmem_capacity=shmem_capacity,
        ) as data_stream:
            global_configuration["output_stream"] = data_stream.get_uri()
            configuration = global_configuration | {
                "shots": shot_spec,
                "artifact_dir": artifact_directory,
            }
            process = SeleneProcess(
                executable=self.executable,
                library_search_dirs=library_search_dirs,
                configuration=configuration,
                run_directory=run_directory,
                command_prefix=command_prefix,
            )
            processes = SeleneProcessList()
            processes.add(process)
            processes.spawn()

            result_stream = ResultStream(data_stream)
            for i in range(n_shots):
                shot_idx = shot_offset + (i * shot_increment)
                if verbose:
                    print(f"Processing shot {shot_idx}")
                if data_stream.done:
                    raise Exception(
                        "Results stream has ended before all shots are processed"
                    )
                event_hook.on_new_shot()
                yield parse_shot(
                    stream=result_stream,
                    event_hook=event_hook,
                    full=parse_results,
                    process=process,
                )

        processes.wait(check_return_code=not result_stream.tainted)
