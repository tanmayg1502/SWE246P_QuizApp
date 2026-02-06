//
//  DrawingCanvasView.swift
//  QuizApp
//
//  Created by tanmayGoel on 2/6/26.
//

import UIKit

final class DrawingCanvasView: UIView {
	var lines: [Line] = [] { // all finished lines
		// redraw whenever lines change
		didSet { setNeedsDisplay() }
	}
	private var currentLine: Line? { // the line being drawn during touch
		// redraw while the user is drawing a line
		didSet { setNeedsDisplay() }
	}

	var selectedLineIndex: Int? { // highlights a tapped line
		// highlight the selected line
		didSet { setNeedsDisplay() }
	}

	var movingLineIndex: Int? // which line is being currently dragged
	// block drawing while menus/long-press are active
	var isDrawingSuppressed = false // blocks drawing while menus/longpress are active
	// default pen color
	var currentColor: DrawingColor = .black // pen color for new lines

	override init(frame: CGRect) {
		super.init(frame: frame)
		isMultipleTouchEnabled = false
		backgroundColor = .secondarySystemBackground
		layer.cornerRadius = 12
		layer.borderWidth = 1
		layer.borderColor = UIColor.tertiaryLabel.cgColor
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// Manage drawing state
	func setDrawing(_ drawing: Drawing) {
		// load stored lines into the canvas
		lines = drawing.lines
	}

	func drawing() -> Drawing {
		// export current lines as a Drawing
		Drawing(lines: lines)
	}

	func clearLines() {
		// remove all lines and selection
		lines.removeAll()
		currentLine = nil
		selectedLineIndex = nil
	}

	func cancelCurrentLine() {
		// discard the in-progress line
		currentLine = nil
	}

	// hit tests a tap against lines( distance to segment)
	func lineIndex(at point: CGPoint) -> Int? {
		// allow a slightly larger hit target than the line width
		let threshold: CGFloat = 22
		for (index, line) in lines.enumerated().reversed() {
			if distanceFromPoint(point, toLineSegment: line) < threshold {
				return index
			}
		}
		return nil
	}

	// Used when dragging a line
	func moveLine(at index: Int, by translation: CGPoint) {
		guard lines.indices.contains(index) else { return }
		// move both endpoints by the pan translation
		lines[index].start.x += translation.x
		lines[index].start.y += translation.y
		lines[index].end.x += translation.x
		lines[index].end.y += translation.y
	}

	// starts a line
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard !isDrawingSuppressed, movingLineIndex == nil else { return }
		guard let touch = touches.first else { return }
		let point = touch.location(in: self)
		// start a new line at the touch point
		currentLine = Line(start: point, end: point, color: currentColor)
	}

	// updates the line's end
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard !isDrawingSuppressed, movingLineIndex == nil else { return }
		guard let touch = touches.first, var line = currentLine else { return }
		let point = touch.location(in: self)
		// update the end of the current line as the finger moves
		line.end = point
		currentLine = line
	}

	// saves the line to lines
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard !isDrawingSuppressed, movingLineIndex == nil else { return }
		if let line = currentLine {
			// finish the line and store it
			lines.append(line)
		}
		currentLine = nil
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		currentLine = nil
	}

	override func draw(_ rect: CGRect) {
		super.draw(rect)
		guard let context = UIGraphicsGetCurrentContext() else { return }
		// draw stored lines first
		drawLines(in: context)
		if let line = currentLine {
			stroke(line: line, in: context, isHighlighted: false)
		}
		if let selectedIndex = selectedLineIndex,
		   lines.indices.contains(selectedIndex) {
			stroke(line: lines[selectedIndex], in: context, isHighlighted: true)
		}
	}
	
	// creates a UIImage snapshot for ImageStore
	func renderImage() -> UIImage {
		// render a static image for saving to the ImageStore
		let format = UIGraphicsImageRendererFormat()
		format.scale = UIScreen.main.scale
		let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
		return renderer.image { context in
			UIColor.systemBackground.setFill()
			context.fill(bounds)
			drawLines(in: context.cgContext)
		}
	}

	private func drawLines(in context: CGContext) {
		// draw every stored line
		for line in lines {
			stroke(line: line, in: context, isHighlighted: false)
		}
	}

	private func stroke(line: Line, in context: CGContext, isHighlighted: Bool) {
		context.saveGState()
		// thicker + translucent when highlighted
		context.setLineWidth(isHighlighted ? 7 : 4)
		context.setLineCap(.round)
		let color = line.color.uiColor.withAlphaComponent(isHighlighted ? 0.6 : 1.0)
		context.setStrokeColor(color.cgColor)
		context.move(to: line.start)
		context.addLine(to: line.end)
		context.strokePath()
		context.restoreGState()
	}

	private func distanceFromPoint(_ point: CGPoint, toLineSegment line: Line) -> CGFloat {
		// compute distance from a point to a line segment
		let start = line.start
		let end = line.end
		let dx = end.x - start.x
		let dy = end.y - start.y
		if dx == 0 && dy == 0 {
			return hypot(point.x - start.x, point.y - start.y)
		}
		let t = ((point.x - start.x) * dx + (point.y - start.y) * dy) / (dx * dx + dy * dy)
		if t < 0 {
			return hypot(point.x - start.x, point.y - start.y)
		} else if t > 1 {
			return hypot(point.x - end.x, point.y - end.y)
		} else {
			let projection = CGPoint(x: start.x + t * dx, y: start.y + t * dy)
			return hypot(point.x - projection.x, point.y - projection.y)
		}
	}
}
