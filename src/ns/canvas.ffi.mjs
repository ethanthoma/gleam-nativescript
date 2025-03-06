import * as $color from "../../gleam_community_colour/gleam_community/colour.mjs";
import * as $canvas from "./canvas.mjs";

let ctx;
let width;
let height;

export function setWidth(width_l) {
	width = width_l;
}

export function setHeight(height_l) {
	height = height_l;
}

export function setContext(ctx_l) {
	ctx = ctx_l;
}

export function getContext() {
	return ctx;
}

export function clearCanvas() {
	if (ctx) {
		ctx.clearRect(0, 0, width, height);
	} else {
		console.error("canvas context not available");
	}
	return ctx;
}

export function renderAction(action) {
	if (!ctx) {
		console.error("Canvas context not available");
		return;
	}

	if (!action) {
		return;
	}

	ctx.save();

	try {
		$canvas.render(action);
	} finally {
		ctx.restore();
	}
}

export function drawPolygon(points, closed) {
	ctx.beginPath();
	ctx.moveTo(0, 0);
	let started = false;
	for (const point of points) {
		if (started) {
			ctx.lineTo(point.x, point.y);
		} else {
			ctx.moveTo(point.x, point.y);
			started = true;
		}
	}

	if (closed) {
		ctx.closePath();

		if (fill) {
			ctx.fill();
		} else {
			ctx.stroke();
		}
	}
}

export function fill(color) {
	ctx.fillStyle = $color.to_css_rgba_string(color);
}

export function translate(x, y) {
	ctx.translate(x, y);
}
