import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam_community/colour.{type Color}

import ns/vec2.{type Vec2, Vec2}

pub opaque type Diagram {
  // Primitives
  Blank
  Circle(radius: Float)
  Rect(width: Float, height: Float)
  Polygon(points: List(Vec2), closed: Bool)
  Text(content: String, font_size: Float)

  // Transformations
  Translate(diagram: Diagram, vec: Vec2)
  Rotate(diagram: Diagram, angle: Float)
  Scale(diagram: Diagram, factor: Float)

  // Styling
  FillColor(diagram: Diagram, color: Color)
  StrokeColor(diagram: Diagram, color: Color)
  LineWidth(diagram: Diagram, width: Float)

  // Composition
  Beside(left: Diagram, right: Diagram)
  Above(top: Diagram, bottom: Diagram)
  Atop(background: Diagram, foreground: Diagram)
  Group(diagrams: List(Diagram))
}

pub type Anchor {
  Center
  TopLeft
  TopRight
  BottomLeft
  BottomRight
  MidLeft
  MidRight
  MidTop
  MidBottom
}

pub type Bounds {
  Bounds(min_x: Float, min_y: Float, max_x: Float, max_y: Float)
}

// --------- PRIMITIVES ---------

pub fn blank() -> Diagram {
  Blank
}

pub fn circle(radius radius: Float) -> Diagram {
  Circle(radius: radius)
}

pub fn rect(width width: Float, height height: Float) -> Diagram {
  Rect(width: width, height: height)
}

pub fn polygon(points points: List(Vec2), closed closed: Bool) -> Diagram {
  Polygon(points: points, closed: closed)
}

pub fn text(content content: String, font_size font_size: Float) -> Diagram {
  Text(content: content, font_size: font_size)
}

// --------- TRANSFORMATIONS ---------

pub fn translate(diagram diagram: Diagram, x x: Float, y y: Float) -> Diagram {
  Translate(diagram: diagram, vec: Vec2(x: x, y: y))
}

pub fn rotate(diagram diagram: Diagram, angle angle: Float) -> Diagram {
  Rotate(diagram: diagram, angle: angle)
}

pub fn scale(diagram diagram: Diagram, factor factor: Float) -> Diagram {
  Scale(diagram: diagram, factor: factor)
}

// --------- STYLING ---------

pub fn fill(diagram diagram: Diagram, color color: Color) -> Diagram {
  FillColor(diagram: diagram, color: color)
}

pub fn stroke(diagram diagram: Diagram, color color: Color) -> Diagram {
  StrokeColor(diagram: diagram, color: color)
}

pub fn line_width(diagram diagram: Diagram, width width: Float) -> Diagram {
  LineWidth(diagram: diagram, width: width)
}

// --------- COMPOSITION ---------

pub fn beside(left left: Diagram, right right: Diagram) -> Diagram {
  Beside(left: left, right: right)
}

pub fn above(top top: Diagram, bottom bottom: Diagram) -> Diagram {
  Above(top: top, bottom: bottom)
}

pub fn atop(
  background background: Diagram,
  foreground foreground: Diagram,
) -> Diagram {
  Atop(background: background, foreground: foreground)
}

pub fn group(diagrams diagrams: List(Diagram)) -> Diagram {
  Group(diagrams: diagrams)
}

// --------- RENDERING ---------

pub fn bounds(diagram diagram: Diagram) -> Bounds {
  case diagram {
    Blank -> Bounds(min_x: 0.0, min_y: 0.0, max_x: 0.0, max_y: 0.0)

    Circle(radius) ->
      Bounds(
        min_x: -1.0 *. radius,
        min_y: -1.0 *. radius,
        max_x: radius,
        max_y: radius,
      )

    Rect(width, height) ->
      Bounds(min_x: 0.0, min_y: 0.0, max_x: width, max_y: height)

    Polygon(points, _) -> calculate_polygon_bounds(points)

    Text(content, font_size) -> {
      let width = int.to_float(string.length(content)) *. font_size *. 0.6
      Bounds(min_x: 0.0, min_y: 0.0, max_x: width, max_y: font_size)
    }

    Translate(diagram, vec) -> {
      let Bounds(min_x, min_y, max_x, max_y) = bounds(diagram)
      Bounds(
        min_x: min_x +. vec.x,
        min_y: min_y +. vec.y,
        max_x: max_x +. vec.x,
        max_y: max_y +. vec.y,
      )
    }

    Rotate(diagram, _) -> {
      // This is an approximation; proper rotation would require transforming each corner
      let Bounds(min_x, min_y, max_x, max_y) = bounds(diagram)
      let width = max_x -. min_x
      let height = max_y -. min_y
      let assert Ok(radius) =
        float.square_root(width *. width +. height *. height)
      let radius = radius /. 2.0
      Bounds(
        min_x: -1.0 *. radius,
        min_y: -1.0 *. radius,
        max_x: radius,
        max_y: radius,
      )
    }

    Scale(diagram, factor) -> {
      let Bounds(min_x, min_y, max_x, max_y) = bounds(diagram)
      Bounds(
        min_x: min_x *. factor,
        min_y: min_y *. factor,
        max_x: max_x *. factor,
        max_y: max_y *. factor,
      )
    }

    FillColor(diagram, _) -> bounds(diagram)
    StrokeColor(diagram, _) -> bounds(diagram)
    LineWidth(diagram, _) -> bounds(diagram)

    Beside(left, right) -> {
      let left_bounds = bounds(left)
      let right_bounds = bounds(right)
      let left_width = left_bounds.max_x -. left_bounds.min_x

      Bounds(
        min_x: left_bounds.min_x,
        min_y: float.min(left_bounds.min_y, right_bounds.min_y),
        max_x: left_bounds.min_x
          +. left_width
          +. { right_bounds.max_x -. right_bounds.min_x },
        max_y: float.max(left_bounds.max_y, right_bounds.max_y),
      )
    }

    Above(top, bottom) -> {
      let top_bounds = bounds(top)
      let bottom_bounds = bounds(bottom)
      let top_height = top_bounds.max_y -. top_bounds.min_y

      Bounds(
        min_x: float.min(top_bounds.min_x, bottom_bounds.min_x),
        min_y: top_bounds.min_y,
        max_x: float.max(top_bounds.max_x, bottom_bounds.max_x),
        max_y: top_bounds.min_y
          +. top_height
          +. { bottom_bounds.max_y -. bottom_bounds.min_y },
      )
    }

    Atop(background, foreground) -> {
      let bg_bounds = bounds(background)
      let fg_bounds = bounds(foreground)

      Bounds(
        min_x: float.min(bg_bounds.min_x, fg_bounds.min_x),
        min_y: float.min(bg_bounds.min_y, fg_bounds.min_y),
        max_x: float.max(bg_bounds.max_x, fg_bounds.max_x),
        max_y: float.max(bg_bounds.max_y, fg_bounds.max_y),
      )
    }

    Group(diagrams) ->
      case diagrams {
        [] -> Bounds(min_x: 0.0, min_y: 0.0, max_x: 0.0, max_y: 0.0)
        [first, ..rest] -> {
          list.fold(rest, bounds(first), fn(acc, d) {
            let Bounds(min_x, min_y, max_x, max_y) = acc
            let Bounds(d_min_x, d_min_y, d_max_x, d_max_y) = bounds(d)

            Bounds(
              min_x: float.min(min_x, d_min_x),
              min_y: float.min(min_y, d_min_y),
              max_x: float.max(max_x, d_max_x),
              max_y: float.max(max_y, d_max_y),
            )
          })
        }
      }
  }
}

fn calculate_polygon_bounds(points points: List(Vec2)) -> Bounds {
  case points {
    [] -> Bounds(min_x: 0.0, min_y: 0.0, max_x: 0.0, max_y: 0.0)
    [first, ..rest] -> {
      list.fold(
        rest,
        Bounds(min_x: first.x, min_y: first.y, max_x: first.x, max_y: first.y),
        fn(acc, point) {
          Bounds(
            min_x: float.min(acc.min_x, point.x),
            min_y: float.min(acc.min_y, point.y),
            max_x: float.max(acc.max_x, point.x),
            max_y: float.max(acc.max_y, point.y),
          )
        },
      )
    }
  }
}

pub fn render(diagram diagram: Diagram) {
  render_with_context(
    diagram,
    RenderContext(fill_color: None, stroke_color: None, line_width: 1.0),
  )
}

type RenderContext {
  RenderContext(
    fill_color: Option(Color),
    stroke_color: Option(Color),
    line_width: Float,
  )
}

fn render_with_context(diagram diagram: Diagram, context context: RenderContext) {
  case diagram {
    Blank -> Nil

    Circle(radius:) -> {
      do_save()
      apply_context(context:)
      do_draw_circle(radius:)
      do_restore()
    }

    Rect(width:, height:) -> {
      do_save()
      apply_context(context:)
      do_draw_rect(width:, height:)
      do_restore()
    }

    Polygon(points:, closed:) -> {
      do_save()
      apply_context(context:)
      do_draw_polygon(points:, closed:)
      do_restore()
    }

    Text(content:, font_size:) -> {
      do_save()
      apply_context(context:)
      do_draw_text(content:, font_size:)
      do_restore()
    }

    Translate(diagram:, vec:) -> {
      do_save()
      do_translate(vec.x, vec.y)
      render_with_context(diagram:, context:)
      do_restore()
    }

    Rotate(diagram:, angle:) -> {
      do_save()
      do_rotate(angle:)
      render_with_context(diagram:, context:)
      do_restore()
    }

    Scale(diagram:, factor:) -> {
      do_save()
      do_scale(factor, factor)
      render_with_context(diagram:, context:)
      do_restore()
    }

    FillColor(diagram:, color:) -> {
      render_with_context(
        diagram:,
        context: RenderContext(..context, fill_color: Some(color)),
      )
    }

    StrokeColor(diagram:, color:) -> {
      render_with_context(
        diagram:,
        context: RenderContext(..context, stroke_color: Some(color)),
      )
    }

    LineWidth(diagram:, width:) -> {
      render_with_context(
        diagram:,
        context: RenderContext(..context, line_width: width),
      )
    }

    Beside(left, right) -> {
      do_save()

      // Get bounds to position correctly
      let left_bounds = bounds(left)
      let left_width = left_bounds.max_x -. left_bounds.min_x

      // Render left diagram
      render_with_context(left, context)

      // Render right diagram translated by left's width
      do_translate(left_width, 0.0)
      render_with_context(right, context)

      do_restore()
    }

    Above(top, bottom) -> {
      do_save()

      // Get bounds to position correctly
      let top_bounds = bounds(top)
      let top_height = top_bounds.max_y -. top_bounds.min_y

      // Render top diagram
      render_with_context(top, context)

      // Render bottom diagram translated by top's height
      do_translate(0.0, top_height)
      render_with_context(bottom, context)

      do_restore()
    }

    Atop(background:, foreground:) -> {
      do_save()

      // Render background
      render_with_context(background, context:)

      // Render foreground on top
      render_with_context(foreground, context:)

      do_restore()
    }

    Group(diagrams) -> {
      do_save()
      list.each(diagrams, fn(d) { render_with_context(d, context) })
      do_restore()
    }
  }
}

fn apply_context(context context: RenderContext) {
  let RenderContext(fill_color:, stroke_color:, line_width:) = context

  case fill_color {
    Some(color) -> do_set_fill_style(color:)
    None -> Nil
  }

  case stroke_color {
    Some(color) -> do_set_stroke_style(color:)
    None -> Nil
  }

  do_set_line_width(line_width:)
}

@external(javascript, "./diagram.ffi.mjs", "drawCircle")
fn do_draw_circle(radius radius: Float) -> Nil

@external(javascript, "./diagram.ffi.mjs", "drawRect")
fn do_draw_rect(width width: Float, height height: Float) -> Nil

@external(javascript, "./diagram.ffi.mjs", "drawPolygon")
fn do_draw_polygon(points points: List(Vec2), closed closed: Bool) -> Nil

@external(javascript, "./diagram.ffi.mjs", "drawText")
fn do_draw_text(content content: String, font_size font_size: Float) -> Nil

@external(javascript, "./diagram.ffi.mjs", "translate")
fn do_translate(x x: Float, y y: Float) -> Nil

@external(javascript, "./diagram.ffi.mjs", "rotate")
fn do_rotate(angle angle: Float) -> Nil

@external(javascript, "./diagram.ffi.mjs", "scale")
fn do_scale(x x: Float, y y: Float) -> Nil

@external(javascript, "./diagram.ffi.mjs", "setFillStyle")
fn do_set_fill_style(color color: Color) -> Nil

@external(javascript, "./diagram.ffi.mjs", "setStrokeStyle")
fn do_set_stroke_style(color color: Color) -> Nil

@external(javascript, "./diagram.ffi.mjs", "setLineWidth")
fn do_set_line_width(line_width line_width: Float) -> Nil

@external(javascript, "./diagram.ffi.mjs", "save")
fn do_save() -> Nil

@external(javascript, "./diagram.ffi.mjs", "restore")
fn do_restore() -> Nil
