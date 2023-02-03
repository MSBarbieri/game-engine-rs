#[macro_use]
extern crate log;

use anyhow::Result;
use winit::{
    event::WindowEvent,
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};

#[tokio::main]
async fn main() -> Result<()> {
    pretty_env_logger::init();
    debug!("hello debug!");
    let event_loop = EventLoop::new();

    let window = WindowBuilder::new().build(&event_loop)?;
    let mut state = core::State::new(window).await?;
    let _window_id = state.window().id();

    event_loop.run(move |event, _something, control_flow| match event {
        winit::event::Event::RedrawRequested(window_id) if window_id == _window_id => {
            state.update();
            match state.render() {
                Ok(_) => {}
                // Reconfigure the surface if lost
                Err(wgpu::SurfaceError::Lost) => state.resize(state.size),
                // The system is out of memory, we should probably quit
                Err(wgpu::SurfaceError::OutOfMemory) => *control_flow = ControlFlow::Exit,
                // All other errors (Outdated, Timeout) should be resolved by the next frame
                Err(e) => eprintln!("{:?}", e),
            }
        }
        winit::event::Event::MainEventsCleared => {
            state.window().request_redraw();
        }
        winit::event::Event::WindowEvent { window_id, event } if window_id == _window_id => {
            match event {
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                WindowEvent::Resized(physical_size) => {
                    state.resize(physical_size);
                }
                WindowEvent::ScaleFactorChanged { new_inner_size, .. } => {
                    state.resize(*new_inner_size);
                }
                window_event => match state.input(&window_event) {
                    true => (),
                    false => (),
                },
            };
        }
        _ => (),
    });
}
