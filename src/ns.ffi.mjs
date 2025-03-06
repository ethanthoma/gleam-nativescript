// NS Framework FFI for Gleam
// This provides an API for NativeScript + Canvas compatible with the effect library
import { Screen } from "@nativescript/core";

import * as $event from "./ns/event.mjs";
import { Tap } from "./ns/gesture.mjs";
import { Vec2 } from "./ns/vec2.mjs";

import { renderAction, clearCanvas } from "./ns/canvas.ffi.mjs";

// Global state
let currentModel = null;
let updateFn = null;
let renderFn = null;
let lastTime = 0;
let deltaTime = 0;
let queue = [];
let animationFrameId = null;
let dispatchFn = null;

// Start a NS application
export function start({ init, update, render }, flags) {
	try {
		console.log("Starting app...");

		updateFn = update;
		renderFn = render;

		console.log("Initializing model...");
		const [initialModel, initialEvent] = init(flags);
		console.log("Initialized model.");

		currentModel = initialModel;

		dispatchFn = (event) => {
			queue.push(event);
		};

		if (initialEvent) {
			handleEvent(initialEvent);
		}

		startGameLoop();

		console.log("App started successfully.");
		return null;
	} catch (error) {
		console.error("Error starting application:", error);
		return null;
	}
}

////////// Game Loop //////////

function startGameLoop() {
	console.log("Starting animation loop");

	renderFrame();

	animationFrameId = requestAnimationFrame(gameLoop);
}

function gameLoop(timestamp) {
	const now = timestamp;
	deltaTime = now - lastTime || 16.6;

	try {
		if (deltaTime > 16.6) {
			flush();

			lastTime = now;
		}

		renderFrame();

		animationFrameId = requestAnimationFrame(gameLoop);
	} catch (error) {
		console.error("Error in animation loop:", error, "continuing anyway");
		animationFrameId = requestAnimationFrame(gameLoop);
	}
}

export function getDeltaTime() {
	return (deltaTime * 60) / 1000;
}

////////// Render //////////

function renderFrame() {
	try {
		clearCanvas();

		const renderActions = renderFn(currentModel);

		renderAction(renderActions);
	} catch (error) {
		console.error("Error rendering frame:", error);
	}
}

////////// Event //////////
function flush() {
	while (queue.length > 0) {
		const event = queue.shift();
		processEvent(event);
	}
}

function processEvent(event) {
	try {
		if (!currentModel || !updateFn) return;

		const [nextModel, nextEvent] = updateFn(currentModel, event);

		currentModel = nextModel;

		handleEvent(nextEvent);
	} catch (error) {
		console.error("Error processing event:", error);
	}
}

function handleEvent(event) {
	if (!event) return;

	if (event instanceof $event.NoOp) {
	} else if (event instanceof $event.Quit) {
		if (animationFrameId) {
			cancelAnimationFrame(animationFrameId);
		}
		console.log("Application quit requested");
	} else if (event instanceof $event.Sequence) {
		event.Sequence.forEach((e) => handleEvent(e));
	} else if (event instanceof $event.Effect) {
		event.Effect(dispatchFn);
	} else {
		console.log(event);
		dispatchFn(event);
	}
}

export function handleTap(evt) {
	if (!dispatchFn) return;

	const x = evt.getX() * Screen.mainScreen.scale;
	const y = evt.getY() * Screen.mainScreen.scale;

	dispatchFn(new $event.Gesture(new Tap(new Vec2(x, y))));
}
