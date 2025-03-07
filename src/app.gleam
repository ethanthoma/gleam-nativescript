import gleam/bool
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam_community/colour

import ns
import ns/diagram.{type Diagram}
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

fn render(model: Model) -> Diagram {
  use <- bool.guard(option.is_none(model.pos), diagram.blank())
  let assert Some(vec2.Vec2(x:, y:)) = model.pos

  let width = 50.0
  let height = 50.0
  let radius = 25.0

  let box =
    diagram.rect(width:, height:)
    |> diagram.fill(color: colour.red)
    |> diagram.translate(x: width /. -2.0, y: height /. -2.0)

  let circ =
    diagram.circle(radius:)
    |> diagram.fill(color: colour.blue)

  diagram.atop(box, circ)
  |> diagram.translate(x:, y:)
}

pub fn main() {
  let app = ns.application(init, update, render)

  ns.start(app, Nil)
}
