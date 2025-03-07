import { Screen } from "@nativescript/core";

import { main } from "./app.mjs";
import { setContext, setWidth, setHeight } from "./ns/diagram.ffi.mjs";
import { getDispatch } from "./ns.ffi.mjs";
import { eventFromTap } from "./ns/event.ffi.mjs";

let dispatch;

export function canvasReady(args) {
	console.log("Canvas Ready.");
	let canvas = args.object;

	const scale = Screen.mainScreen.scale;
	canvas.width = canvas.clientWidth * scale;
	canvas.height = canvas.clientHeight * scale;

	let ctx = canvas.getContext("2d");
	ctx.scale(scale, scale);

	canvas.addEventListener("touchstart", (args) => {
		if (!dispatch) {
			dispatch = getDispatch();
		}

		const touches = args.touches.item(0);
		const first = touches;

		const x = first.clientX * scale;
		const y = first.clientY * scale;

		let event = eventFromTap(x, y);

		dispatch(event);
	});

	canvas.addEventListener("touchmove", (args) => {
		if (!dispatch) {
			dispatch = getDispatch();
		}

		const touches = args.changedTouches;
		if (Array.isArray(touches)) {
			const first = touches[0];

			const x = first.clientX * scale;
			const y = first.clientY * scale;

			let event = eventFromTap(x, y);

			dispatch(event);
		}
	});

	console.log("Setting context...");
	setContext(ctx);
	console.log(`Screen is ${canvas.width} by ${canvas.height}.`);
	setWidth(canvas.width);
	setHeight(canvas.height);

	main();
}
