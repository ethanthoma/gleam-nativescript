import gleam/list
import gleam_community/colour.{type Color}

import ns/vec2.{type Vec2, Vec2}

pub type RenderAction {
  Blank
  Picture(picture: Picture)
  Fill(action: RenderAction, color: Color)
  Translate(action: RenderAction, x: Float, y: Float)
  Combine(actions: List(RenderAction))
}

pub type Picture {
  Polygon(points: List(Vec2), closed: Bool)
}

pub fn polygon(points points: List(Vec2)) -> RenderAction {
  Polygon(points: points, closed: True) |> Picture
}

pub fn rect(width width: Float, height height: Float) -> RenderAction {
  polygon(points: [
    Vec2(0.0, 0.0),
    Vec2(width, 0.0),
    Vec2(width, height),
    Vec2(0.0, height),
  ])
}

pub fn fill(action action: RenderAction, color color: Color) -> RenderAction {
  Fill(action:, color:)
}

pub fn translate(
  action action: RenderAction,
  x x: Float,
  y y: Float,
) -> RenderAction {
  Translate(action:, x:, y:)
}

pub fn combine(actions actions: List(RenderAction)) -> RenderAction {
  Combine(actions:)
}

pub fn blank() -> RenderAction {
  Blank
}

pub fn render(action action: RenderAction) {
  case action {
    Blank -> Nil

    Picture(picture:) -> draw(picture:)

    Fill(action:, color:) -> {
      do_save()
      do_fill(color)
      render(action)
      do_restore()
    }

    Translate(action:, x:, y:) -> {
      do_save()
      do_translate(x, y)
      render(action)
      do_restore()
    }

    Combine(actions:) -> list.each(actions, render)
  }
}

fn draw(picture picture: Picture) {
  case picture {
    Polygon(points:, closed:) -> do_draw_polygon(points:, closed:)
  }
}

@external(javascript, "./canvas.ffi.mjs", "drawPolygon")
fn do_draw_polygon(points points: List(Vec2), closed closed: Bool) -> Nil

@external(javascript, "./canvas.ffi.mjs", "fill")
fn do_fill(color color: Color) -> Nil

@external(javascript, "./canvas.ffi.mjs", "translate")
fn do_translate(x x: Float, y y: Float) -> Nil

@external(javascript, "./canvas.ffi.mjs", "save")
fn do_save() -> Nil

@external(javascript, "./canvas.ffi.mjs", "restore")
fn do_restore() -> Nil
