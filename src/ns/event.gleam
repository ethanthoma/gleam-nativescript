import ns/gesture.{type Gesture}

pub type Event(msg) {
  // Basic events
  NoOp
  Quit

  // Game Loop events
  Tick(delta: Float)
  Gesture(Gesture)

  // Msg Events
  Custom(msg)
  Effect(fn(fn(Event(msg)) -> Nil) -> Nil)
  Sequence(List(Event(msg)))
}

pub fn none() -> Event(msg) {
  NoOp
}

pub fn tick(delta: Float) -> Event(msg) {
  Tick(delta: delta)
}

pub fn effect(handler: fn(fn(Event(msg)) -> Nil) -> Nil) -> Event(msg) {
  Effect(handler)
}
