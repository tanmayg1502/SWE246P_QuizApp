//
//  DrawingModels.swift
//  QuizApp
//
//  Created by tanmayGoel on 2/6/26.
//

import UIKit

enum DrawingColor: String, CaseIterable, Codable {
	case black
	case red
	case green
	case blue

	var uiColor: UIColor {
		// map enum to actual UI colors
		switch self {
		case .black:
			return .black
		case .red:
			return .systemRed
		case .green:
			return .systemGreen
		case .blue:
			return .systemBlue
		}
	}

	var displayName: String {
		// names used in the action sheet
		switch self {
		case .black:
			return "Black"
		case .red:
			return "Red"
		case .green:
			return "Green"
		case .blue:
			return "Blue"
		}
	}
}

struct Line: Codable {
	var start: CGPoint
	var end: CGPoint
	var color: DrawingColor

	init(start: CGPoint, end: CGPoint, color: DrawingColor) {
		self.start = start
		self.end = end
		self.color = color
	}

	enum CodingKeys: String, CodingKey {
		// store CGPoint as primitive values for Codable
		case startX
		case startY
		case endX
		case endY
		case color
	}

	init(from decoder: Decoder) throws {
		// decode the point values and rebuild CGPoints
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let startX = try container.decode(CGFloat.self, forKey: .startX)
		let startY = try container.decode(CGFloat.self, forKey: .startY)
		let endX = try container.decode(CGFloat.self, forKey: .endX)
		let endY = try container.decode(CGFloat.self, forKey: .endY)
		let color = try container.decode(DrawingColor.self, forKey: .color)
		self.start = CGPoint(x: startX, y: startY)
		self.end = CGPoint(x: endX, y: endY)
		self.color = color
	}

	func encode(to encoder: Encoder) throws {
		// encode points as primitive values
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(start.x, forKey: .startX)
		try container.encode(start.y, forKey: .startY)
		try container.encode(end.x, forKey: .endX)
		try container.encode(end.y, forKey: .endY)
		try container.encode(color, forKey: .color)
	}
}

struct Drawing: Codable {
	// container for all drawn lines
	var lines: [Line]
}
