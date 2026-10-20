use anyhow::Result;
use parking_lot::Mutex;
use selene_core::runtime::RuntimeInstruction;
use std::sync::Arc;

pub mod configuration;
pub mod metadata;
pub mod print;
pub mod quantum;
pub mod rng;
pub mod state_dump;
use configuration::Configuration;

use crate::emulator::Emulator;
use rand_pcg::Pcg32;
use selene_core::encoder::OutputStream;

pub struct SeleneInstance {
    pub config: Configuration,
    pub emulator: Emulator,
    pub out_encoder: Arc<Mutex<OutputStream>>,
    pub shot_number: u64,
    pub prng: Mutex<Option<Pcg32>>,
    pub(crate) state_dump_lock: Mutex<()>,
}

impl SeleneInstance {
    pub fn time_cursor(&self) -> Result<u64> {
        self.emulator
            .runtime
            .handle_instruction(RuntimeInstruction::GetTimeCursor)?
            .into_u64()?
            .ok_or_else(|| anyhow::anyhow!("Runtime returned an unavailable time cursor"))
    }
    pub fn set_time_cursor(&self, value: u64) -> Result<()> {
        self.emulator
            .runtime
            .handle_instruction(RuntimeInstruction::SetTimeCursor { time_cursor: value })?
            .into_unit()
    }

    /// Create a new Selene simulator instance from the provided configuration,
    /// e.g. loaded from a config file.
    pub fn new(config: Configuration) -> Result<Self> {
        let out_encoder = OutputStream::new(config.get_output_writer());
        let out_encoder = Arc::new(Mutex::new(out_encoder));
        let output = selene_core::runtime::output::OutputSinkHandle {
            context: Arc::as_ptr(&out_encoder).cast_mut().cast(),
            write_fn: Some(print::write_output),
            flush_fn: Some(print::flush_output),
        };
        let emulator = match Emulator::from_configuration(&config, output) {
            Ok(emulator) => emulator,
            Err(e) => {
                // Note: with the current API design, the out_encoder is locally scoped and owned
                // by self, so if we simply return an error here there is no way to communicate that
                // error through the OutputStream. This can lead to to frontends having to
                // guess what went wrong during initialization.
                //
                // A future API design should consider allowing the output stream to be configured
                // outside of the config file and passed in.
                //
                // Avoiding an API break for now, we write the error to the stream here before returning.
                eprintln!("Failed to initialize SeleneInstance: {:?}", e);
                print::print_directly_to_stream(
                    &mut out_encoder.lock(),
                    0,
                    "EXIT:INT:Failed during initialization of emulator components",
                    190000u64,
                )?;
                return Err(e);
            }
        };
        let shot_offset = config.shots.offset;
        Ok(Self {
            config,
            emulator,
            out_encoder,
            shot_number: shot_offset,
            prng: Mutex::new(None),
            state_dump_lock: Mutex::new(()),
        })
    }

    /// Upon termination of the simulator instance, we signal to the output stream
    /// that we are closing out gracefully, and flush all remaining data.
    pub fn exit(&mut self) -> Result<()> {
        let emulator = self.emulator.exit();
        let output = self.out_encoder.lock().end_of_stream();
        let flushed = self.flush_output();
        emulator?;
        output?;
        flushed
    }

    /// Start a new shot, with a monatonically increasing shot index.
    /// This sets up the runtime and error model for the new shot and
    /// prepares the emulator to process operations for the shot.
    ///
    /// Although we operate on ranges of shots with an offset and increment,
    /// this is handled inside this function. As such, the shot_index parameter
    /// should start at 0 and increment by 1 for each new shot.
    pub fn shot_start(&mut self, shot_index: u64) -> Result<()> {
        // Establish the internal shot ID based on the offset and increment,
        // and use it for seeding the various components.
        let shot_id = self.config.shots.offset + self.config.shots.increment * shot_index;
        self.shot_number = shot_id;
        self.print_shot_start()?;
        let runtime_seed = self
            .config
            .get_seed_for_shot(self.config.runtime.seed, shot_id)?;
        let error_model_seed = self
            .config
            .get_seed_for_shot(self.config.error_model.seed, shot_id)?;
        let simulator_seed = self
            .config
            .get_seed_for_shot(self.config.simulator.seed, shot_id)?;

        // Now we fire off any shot start event hooks and prepare the
        // runtime and error model for the new shot.
        self.emulator
            .shot_start(shot_id, runtime_seed, simulator_seed, error_model_seed)?;
        Ok(())
    }

    /// End the current shot, flushing any remaining operations
    /// through the runtime and error model, writing out any
    /// stored metadata, and informing event hooks that the shot
    /// has ended.
    pub fn shot_end(&mut self) -> Result<()> {
        // The emulator collects plugin metrics after the runtime hands back
        // the endpoint, before ending the simulator and error-model shots.
        let ended = self.emulator.shot_end();
        let metrics = if self.config.event_hooks.provide_metrics {
            self.write_metrics()
        } else {
            Ok(())
        };
        ended?;
        metrics?;
        self.write_metadata()?;
        self.print_shot_end()?;
        Ok(())
    }
}
