//
//  DrawingViewController.swift
//  QuizApp
//
//  Created by tanmayGoel on 2/6/26.
//

import UIKit
/*
 TAP -> selects a line and shows action sheet
 Double-tap -> confirmation alert -> clears all lines
 long-press -> on a line: begins move mode; on blank: shows pen color menu
 Pan-> moves the selected line
 */

final class DrawingViewController: UIViewController {
	private let canvas = DrawingCanvasView()
	private let existingDrawing: Drawing? // existing drawing is passed so previous reappear
	private let onSave: (Drawing, UIImage?) -> Void // closure return the drawing + redered image when leaving

	init(existingDrawing: Drawing?, onSave: @escaping (Drawing, UIImage?) -> Void) {
		self.existingDrawing = existingDrawing
		self.onSave = onSave
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		title = "Draw"
		// layout the drawing canvas
		canvas.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(canvas)
		NSLayoutConstraint.activate([
			canvas.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			canvas.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
			canvas.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
		])

		if let drawing = existingDrawing {
			// load any saved drawing
			canvas.setDrawing(drawing)
		}

		// gestures for select, clear, move, and pen color
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
		doubleTapGesture.numberOfTapsRequired = 2
		tapGesture.require(toFail: doubleTapGesture)
		tapGesture.cancelsTouchesInView = true
		doubleTapGesture.cancelsTouchesInView = true

		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
		longPressGesture.cancelsTouchesInView = true
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		panGesture.cancelsTouchesInView = false

		canvas.addGestureRecognizer(tapGesture)
		canvas.addGestureRecognizer(doubleTapGesture)
		canvas.addGestureRecognizer(longPressGesture)
		canvas.addGestureRecognizer(panGesture)
	}

	// collects the drawing and snapshot image and calls onSave
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		// detect wether the view controller was removed by popping from nav controller or modally dismiss
		guard isMovingFromParent || isBeingDismissed else { return }
		// save the drawing when leaving the screen
		let drawing = canvas.drawing()
		let image = drawing.lines.isEmpty ? nil : canvas.renderImage()
		onSave(drawing, image)
	}

	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		let point = gesture.location(in: canvas)
		// tap a line to show options
		guard let index = canvas.lineIndex(at: point) else {
			canvas.selectedLineIndex = nil
			return
		}
		canvas.selectedLineIndex = index
		showLineMenu(at: point, lineIndex: index)
	}

	@objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
		// confirm before clearing all lines
		let alert = UIAlertController(title: "Clear Drawing?", message: "Delete all lines?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
			self?.canvas.clearLines()
		})
		present(alert, animated: true)
	}

	@objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
		let point = gesture.location(in: canvas)
		switch gesture.state {
		case .began:
			// long-press on a line to move it, otherwise pick pen color
			canvas.isDrawingSuppressed = true
			canvas.cancelCurrentLine()
			if let index = canvas.lineIndex(at: point) {
				canvas.selectedLineIndex = index
				canvas.movingLineIndex = index
			} else {
				showPenColorMenu(at: point)
			}
		case .ended, .cancelled, .failed:
			canvas.movingLineIndex = nil
			canvas.isDrawingSuppressed = false
		default:
			break
		}
	}

	@objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
		guard let index = canvas.movingLineIndex else { return }
		// move the selected line by the pan translation
		let translation = gesture.translation(in: canvas)
		canvas.moveLine(at: index, by: translation)
		gesture.setTranslation(.zero, in: canvas)
		if gesture.state == .ended || gesture.state == .cancelled {
			canvas.movingLineIndex = nil
		}
	}

	// shows the alert
	private func showLineMenu(at point: CGPoint, lineIndex: Int) {
		// options for the selected line
		let alert = UIAlertController(title: "Line", message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Delete Line", style: .destructive) { [weak self] _ in
			self?.deleteLine(at: lineIndex)
		})
		for color in DrawingColor.allCases {
			alert.addAction(UIAlertAction(title: color.displayName, style: .default) { [weak self] _ in
				self?.updateLine(at: lineIndex, color: color)
			})
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		configurePopover(alert, at: point)
		present(alert, animated: true)
	}

	private func showPenColorMenu(at point: CGPoint) {
		// choose the pen color for new lines
		let alert = UIAlertController(title: "Pen Color", message: nil, preferredStyle: .actionSheet)
		for color in DrawingColor.allCases {
			alert.addAction(UIAlertAction(title: color.displayName, style: .default) { [weak self] _ in
				self?.canvas.currentColor = color
			})
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		configurePopover(alert, at: point)
		present(alert, animated: true)
	}

	private func configurePopover(_ alert: UIAlertController, at point: CGPoint) {
		// anchor for iPad action sheet
		if let popover = alert.popoverPresentationController {
			popover.sourceView = canvas
			popover.sourceRect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
		}
	}

	private func deleteLine(at index: Int) {
		guard canvas.lines.indices.contains(index) else { return }
		canvas.lines.remove(at: index)
		canvas.selectedLineIndex = nil
	}

	private func updateLine(at index: Int, color: DrawingColor) {
		guard canvas.lines.indices.contains(index) else { return }
		canvas.lines[index].color = color
	}
}
