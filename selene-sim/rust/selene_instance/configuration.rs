use anyhow::{Result, bail};
use rand::{Rng, SeedableRng};
use rand_pcg::Pcg64Mcg;
use selene_core::encoder::{InternalBuffer, OutputWriter};
use serde::Deserialize;
use std::io::Write;
use std::path::PathBuf;
use url::Url;

fn disable_by_default() -> bool {
    false
}

fn random_by_default() -> u64 {
    rand::random()
}

/// Configuration for plugins, e.g. the simulator, error model, and runtime.
#[derive(Deserialize, Debug)]
pub struct PluginConfig {
    pub name: String,
    #[serde(default = "random_by_default")]
    pub seed: u64,
    pub file: PathBuf,
    pub args: Vec<String>,
}

#[derive(Deserialize, Debug)]
pub struct EventHookConfig {
    #[serde(default = "disable_by_default")]
    pub provide_instruction_log: bool,
    #[serde(default = "disable_by_default")]
    pub provide_metrics: bool,
    #[serde(default = "disable_by_default")]
    pub provide_measurement_log: bool,
}

#[derive(Deserialize, Debug)]
pub struct ShotConfig {
    pub count: u64,
    pub offset: u64,
    pub increment: u64,
}

#[derive(Deserialize, Debug)]
pub struct Configuration {
    pub n_qubits: u64,
    pub output_stream: String,
    pub artifact_dir: PathBuf,
    pub simulator: PluginConfig,
    pub error_model: PluginConfig,
    pub runtime: PluginConfig,
    pub event_hooks: EventHookConfig,
    pub shots: ShotConfig,
    pub seed_mode: String,
}

impl Configuration {
    /// Get writer based on output arg (can be a file or a tcp address
    /// at the moment)
    pub fn get_output_writer(&self) -> OutputWriter {
        match self.output_stream.as_str() {
            "stdout" => OutputWriter::Stdout(std::io::stdout()),
            "stderr" => OutputWriter::Stderr(std::io::stderr()),
            "internal" => OutputWriter::Internal(InternalBuffer::default()),
            uri => {
                let url = Url::parse(uri).unwrap();
                match url.scheme() {
                    "file" => {
                        let path = url.path();
                        let file = std::fs::OpenOptions::new()
                            .write(true)
                            .create(true)
                            .truncate(true)
                            .open(path)
                            .unwrap();
                        OutputWriter::File(file)
                    }
                    "tcp" => {
                        let host = url.host_str().unwrap();
                        let port = url.port().unwrap();
                        let mut stream = std::net::TcpStream::connect((host, port)).unwrap();
                        // Communicate the shot configuration to the client
                        stream
                            .write_all(self.shots.offset.to_le_bytes().as_slice())
                            .unwrap();
                        stream
                            .write_all(self.shots.increment.to_le_bytes().as_slice())
                            .unwrap();
                        stream
                            .write_all(self.shots.count.to_le_bytes().as_slice())
                            .unwrap();
                        OutputWriter::Tcp(stream)
                    }
                    _ => panic!("Unsupported output scheme: {}", url.scheme()),
                }
            }
        }
    }
    pub fn get_seed_for_shot(&self, start_seed: u64, shot_id: u64) -> Result<u64> {
        match self.seed_mode.as_str() {
            "default" => {
                let mut rng = Pcg64Mcg::seed_from_u64(start_seed);
                rng.advance(shot_id.into());
                Ok(rng.random::<u64>())
            }
            "legacy" => Ok(start_seed + shot_id),
            _ => {
                bail!(
                    "Unsupported seed mode: {}. Supported modes are 'default' and 'legacy'.",
                    self.seed_mode
                )
            }
        }
    }
}
