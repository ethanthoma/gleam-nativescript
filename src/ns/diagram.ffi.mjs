import * as $color from "../../gleam_community_colour/gleam_community/colour.mjs";

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
	if (!ctx) {
		console.error("Canvas context not available");
		return;
	}

	ctx.clearRect(0, 0, width, height);
	ctx.resetTransform();
}

// Drawing primitives
export function drawCircle(radius) {
	if (!ctx) return;

	ctx.beginPath();
	ctx.arc(0, 0, radius, 0, Math.PI * 2, false);
	applyDrawing();
}

export function drawRect(width, height) {
	if (!ctx) return;

	ctx.beginPath();
	ctx.rect(0, 0, width, height);
	applyDrawing();
}

export function drawPolygon(points, closed) {
	if (!ctx) return;

	ctx.beginPath();

	let started = false;
	for (const point of points) {
		if (!started) {
			ctx.moveTo(point.x, point.y);
			started = true;
		} else {
			ctx.lineTo(point.x, point.y);
		}
	}

	if (closed) {
		ctx.closePath();
	}

	applyDrawing();
}

export function drawText(content, fontSize) {
	if (!ctx) return;

	ctx.font = `${fontSize}px sans-serif`;

	if (ctx.fillStyle !== "rgba(0,0,0,0)") {
		ctx.fillText(content, 0, fontSize);
	}

	if (ctx.strokeStyle !== "rgba(0,0,0,0)") {
		ctx.strokeText(content, 0, fontSize);
	}
}

function applyDrawing() {
	if (ctx.fillStyle !== "rgba(0,0,0,0)") {
		ctx.fill();
	}

	if (ctx.strokeStyle !== "rgba(0,0,0,0)") {
		ctx.stroke();
	}
}

// Transformations
export function translate(x, y) {
	if (!ctx) return;

	ctx.translate(x, y);
}

export function rotate(angle) {
	if (!ctx) return;
	ctx.rotate(angle);
}

export function scale(x, y) {
	if (!ctx) return;
	ctx.scale(x, y);
}

// Styling
export function setFillStyle(color) {
	if (!ctx) return;
	ctx.fillStyle = $color.to_css_rgba_string(color);
}

export function setStrokeStyle(color) {
	if (!ctx) return;
	ctx.strokeStyle = $color.to_css_rgba_string(color);
}

export function setLineWidth(width) {
	if (!ctx) return;
	ctx.lineWidth = width;
}

// Context stack
export function save() {
	if (!ctx) return;
	ctx.save();
}

export function restore() {
	if (!ctx) return;
	ctx.restore();
}
