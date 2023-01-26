extern crate pretty_env_logger;
#[macro_use]
extern crate log;
use anyhow::Result;

fn main() -> Result<()> {
    pretty_env_logger::init();
    debug!("hello debug!");
    Ok(())
}
