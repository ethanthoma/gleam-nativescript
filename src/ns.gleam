import ns/diagram.{type Diagram}
import ns/event.{type Event}

pub opaque type App(flags, model, msg) {
  App(
    init: fn(flags) -> #(model, Event(msg)),
    update: fn(model, Event(msg)) -> #(model, Event(msg)),
    render: fn(model) -> Diagram,
  )
}

pub type Error =
  String

pub fn application(
  init: fn(flags) -> #(model, Event(msg)),
  update: fn(model, Event(msg)) -> #(model, Event(msg)),
  render: fn(model) -> Diagram,
) -> App(flags, model, msg) {
  App(init, update, render)
}

pub fn start(app: App(flags, model, msg), with flags: flags) -> Nil {
  do_start(app, flags)
}

@external(javascript, "./ns.ffi.mjs", "start")
fn do_start(_app: App(flags, model, msg), _flags: flags) -> Nil

pub type Tick {
  Tick
}

@external(javascript, "./ns.ffi.mjs", "getDeltaTime")
pub fn get_delta_time() -> Float
