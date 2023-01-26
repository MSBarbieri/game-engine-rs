extern crate pretty_env_logger;
#[macro_use]
extern crate log;

use anyhow::Result;
use winit::{
    event::{ElementState, KeyboardInput, VirtualKeyCode, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::{Window, WindowBuilder},
};

fn window_hander(_window: &mut Window, event: WindowEvent, control_flow: &mut ControlFlow) {
    match event {
        WindowEvent::CloseRequested
        | WindowEvent::KeyboardInput {
            input:
                KeyboardInput {
                    state: ElementState::Pressed,
                    virtual_keycode: Some(VirtualKeyCode::Escape),
                    ..
                },
            ..
        } => *control_flow = ControlFlow::Exit,
        _ => debug!("something else on window"),
    };
}

fn main() -> Result<()> {
    pretty_env_logger::init();
    debug!("hello debug!");
    let event_loop = EventLoop::new();
    let mut window = WindowBuilder::new().build(&event_loop)?;

    event_loop.run(move |event, _something, control_flow| match event {
        winit::event::Event::WindowEvent { window_id, event } if window_id == window.id() => {
            window_hander(&mut window, event, control_flow);
        }
        _ => (),
    });
}
