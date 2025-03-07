import * as $event from "./event.mjs";
import { Tap } from "./gesture.mjs";
import { Vec2 } from "./vec2.mjs";

export function eventFromTap(x, y) {
	return new $event.Gesture(new Tap(new Vec2(x, y)));
}
