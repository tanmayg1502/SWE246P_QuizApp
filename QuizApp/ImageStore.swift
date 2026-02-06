//
//  ImageStore.swift
//  QuizApp
//
//  Created by Tanmay Goel on 2/4/26.
//
import UIKit

final class ImageStore {
	static let shared = ImageStore()

	private let cache = NSCache<NSString, UIImage>()
	private let directoryURL: URL

	private init() {
		let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		directoryURL = baseURL.appendingPathComponent("ImageStore", isDirectory: true)
		try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
	}

	func image(forKey key: String) -> UIImage? {
		if let cached = cache.object(forKey: key as NSString) {
			return cached
		}

		let url = fileURL(forKey: key)
		guard let data = try? Data(contentsOf: url),
			  let image = UIImage(data: data) else {
			return nil
		}

		cache.setObject(image, forKey: key as NSString)
		return image
	}

	func setImage(_ image: UIImage, forKey key: String) {
		cache.setObject(image, forKey: key as NSString)
		let url = fileURL(forKey: key)
		if let data = image.jpegData(compressionQuality: 0.85) {
			try? data.write(to: url, options: [.atomic])
		}
	}

	func deleteImage(forKey key: String) {
		cache.removeObject(forKey: key as NSString)
		let url = fileURL(forKey: key)
		try? FileManager.default.removeItem(at: url)
	}

	private func fileURL(forKey key: String) -> URL {
		directoryURL.appendingPathComponent(key)
	}
}
