//
//  ViewController.swift
//  QuizApp
//
//  Created by Tanmay Goel on 1/29/26.
//

import UIKit

final class Score {
	static let shared = Score()

	private(set) var correct: Int = 0
	private(set) var incorrect: Int = 0

	private init() {}

	func record(isCorrect: Bool) {
		if isCorrect {
			correct += 1
		} else {
			incorrect += 1
		}
	}

	func reset() {
		correct = 0
		incorrect = 0
	}
}

struct MCQQuestion {
	let prompt: String
	let choices: [String]
	let correctIndex: Int
}

struct NumericQuestion {
	let prompt: String
	let answer: Double
}

extension Notification.Name {
	static let quizShouldReset = Notification.Name("quizShouldReset")
}
