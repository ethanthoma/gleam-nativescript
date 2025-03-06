import gleam/io
import gleam/option.{type Option, None, Some}
import gleam_community/colour

import ns
import ns/canvas.{type RenderAction}
import ns/event.{type Event}
import ns/gesture
import ns/vec2

pub type Model {
  Model(pos: Option(vec2.Vec2))
}

pub type Msg

pub type Error

fn init(_) -> #(Model, Event(Msg)) {
  let model = Model(None)

  #(model, event.none())
}

fn update(model: Model, event: Event(msg)) -> #(Model, Event(Msg)) {
  case event {
    event.Gesture(gesture.Tap(pos:)) -> {
      io.debug(pos)
      #(Model(pos: Some(pos)), event.none())
    }
    _ -> #(model, event.none())
  }
}

fn render(model: Model) -> RenderAction {
  case model.pos {
    Some(pos) ->
      canvas.rect(50.0, 50.0)
      |> canvas.fill(colour.red)
      |> canvas.translate(pos.x, pos.y)
    None -> canvas.blank()
  }
}

pub fn main() {
  let app = ns.application(init, update, render)

  ns.start(app, Nil)
}
