//
//  DrawingStore.swift
//  QuizApp
//
//  Created by tanmayGoel on 2/6/26.
//

import Foundation

final class DrawingStore {
	static let shared = DrawingStore()

	private let directoryURL: URL

	private init() {
		let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		// create a folder for drawing JSON files
		directoryURL = baseURL.appendingPathComponent("DrawingStore", isDirectory: true)
		try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
	}

	func drawing(forKey key: String) -> Drawing? {
		// load drawing JSON from disk
		let url = fileURL(forKey: key)
		guard let data = try? Data(contentsOf: url) else { return nil }
		let decoder = JSONDecoder()
		return try? decoder.decode(Drawing.self, from: data)
	}

	func setDrawing(_ drawing: Drawing, forKey key: String) {
		// encode drawing as JSON and save it
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(drawing) else { return }
		let url = fileURL(forKey: key)
		try? data.write(to: url, options: [.atomic])
	}

	func deleteDrawing(forKey key: String) {
		// remove drawing JSON from disk
		let url = fileURL(forKey: key)
		try? FileManager.default.removeItem(at: url)
	}

	private func fileURL(forKey key: String) -> URL {
		directoryURL.appendingPathComponent("\(key).json")
	}
}
