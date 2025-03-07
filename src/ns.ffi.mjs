import * as $event from "./ns/event.mjs";
import * as $diagram from "./ns/diagram.mjs";
import { clearCanvas } from "./ns/diagram.ffi.mjs";

////////// Global state //////////

let currentModel = null;
let updateFn = null;
let renderFn = null;
let queue = [];
let dispatchFn = null;

const FIXED_DELTA = 1000 / 60;
let lastTime = 0;
let deltaTime = 0;
let accumulator = 0;
let animationFrameId = null;

let counterUps = 0;
let counterFps = 0;
let currentFps = 0;
let currentUps = 0;
let lastDisplayTime = 0;

////////// Start //////////

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

let started = false;
let cancelled = false;

function startGameLoop() {
	console.log("Starting animation loop");

	started = true;
	renderFrame();

	animationFrameId = requestAnimationFrame(gameLoop);
}

function gameLoop(timestamp) {
	if (!started || cancelled) {
		return;
	}

	const now = timestamp;
	const frameTime = now - (lastTime || now);
	lastTime = now;

	const maxFrameTime = 250;
	const clampedFrameTime = Math.min(frameTime, maxFrameTime);

	accumulator += clampedFrameTime;

	try {
		while (accumulator >= FIXED_DELTA) {
			dispatchFn(new $event.Tick(FIXED_DELTA));

			flush();

			accumulator -= FIXED_DELTA;
			counterUps++;
		}

		const alpha = accumulator / FIXED_DELTA;

		counterFps++;
		renderFrame(alpha);

		if (now - lastDisplayTime >= 1000) {
			currentFps = counterFps;
			currentUps = counterUps;

			console.log(`FPS: ${currentFps}, UPS: ${currentUps}`);

			counterFps = 0;
			counterUps = 0;
			lastDisplayTime = now;
		}

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

		const diagram = renderFn(currentModel);

		$diagram.render(diagram);
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
		event[0].forEach((e) => handleEvent(e));
	} else if (event instanceof $event.Effect) {
		event[0](dispatchFn);
	} else {
		dispatchFn(event);
	}
}

export function getDispatch() {
	return dispatchFn;
}
