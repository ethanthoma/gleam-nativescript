import { Screen } from "@nativescript/core";

import * as $event from "./event.mjs";
import { Tap } from "./gesture.mjs";
import { Vec2 } from "./vec2.mjs";

export function eventFromTap(evt) {
	const x = evt.getX() * Screen.mainScreen.scale;
	const y = evt.getY() * Screen.mainScreen.scale;

	return new $event.Gesture(new Tap(new Vec2(x, y)));
}
