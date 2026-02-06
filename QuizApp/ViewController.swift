//
//  ViewController.swift
//  QuizApp
//
//  Created by Tanmay Goel on 1/29/26.
//

import UIKit

struct MCQQuestion {
	let prompt: String
	let choices: [String]
	let correctIndex: Int
}


extension Notification.Name {
	static let quizShouldReset = Notification.Name("quizShouldReset")
}
