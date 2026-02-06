//
//  Score.swift
//  QuizApp
//
//  Created by Tanmay Goel on 2/4/26.
//
import Foundation

final class Score {
	static let shared = Score()

	private let correctKey = "score.correct"
	private let incorrectKey = "score.incorrect"

	private(set) var correct: Int = 0
	private(set) var incorrect: Int = 0

	private init() {
		let defaults = UserDefaults.standard
		correct = defaults.integer(forKey: correctKey)
		incorrect = defaults.integer(forKey: incorrectKey)
	}

	func record(isCorrect: Bool) {
		if isCorrect {
			correct += 1
		} else {
			incorrect += 1
		}
		save()
	}

	func reset() {
		correct = 0
		incorrect = 0
		save()
	}

	private func save() {
		let defaults = UserDefaults.standard
		defaults.set(correct, forKey: correctKey)
		defaults.set(incorrect, forKey: incorrectKey)
	}
}
