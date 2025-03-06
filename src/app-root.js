import { main } from "./app.mjs";
import { setContext, setWidth, setHeight } from "./ns/canvas.ffi.mjs";
import { handleTap } from "./ns.ffi.mjs";

export function canvasReady(args) {
	console.log("Canvas Ready.");
	let canvas = args.object;
	let ctx = canvas.getContext("2d");

	console.log("Setting context...");
	setContext(ctx);
	setWidth(canvas.width);
	setHeight(canvas.height);

	main();
}

export function onTap(evt) {
	handleTap(evt);
}
