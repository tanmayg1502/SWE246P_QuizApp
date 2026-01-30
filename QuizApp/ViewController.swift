//
//  ViewController.swift
//  QuizApp
//
//  Created by Tanmay Goel on 1/29/26.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet var questionLabel: UILabel!
	@IBOutlet var answerLabel: UILabel!
	
	let questions: [String] = [
		"What is DRS",
		"Who won WDC more than 5 times",
		"Even if you are not fan of this team, you are a fan of this team"
	]
	
	let answer: [String] = [
		"Drag Reduction System",
		"Lewis Hamilton",
		"Ferrari"
	]
	
	var currentQuestionIndex: Int = 0
	
	@IBAction func showNextQuestion(_ sender: Any) {
		currentQuestionIndex += 1
		if currentQuestionIndex == questions.count {
			currentQuestionIndex = 0
		}
		
		let question: String = questions[currentQuestionIndex]
		questionLabel.text = question
		answerLabel.text = "???"
	}
	
	@IBAction func showAnswer(_ sender: Any) {
		let answer: String = answer[currentQuestionIndex]
		answerLabel.text = answer
		
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		questionLabel.textAlignment = .center
		questionLabel.numberOfLines = 0
		questionLabel.text = questions[currentQuestionIndex]
	}


}

