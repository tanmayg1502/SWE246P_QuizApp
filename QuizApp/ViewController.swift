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

final class MCQViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	private let questions: [MCQQuestion] = [
		MCQQuestion(prompt: "Which ocean is the largest on Earth?", choices: ["Atlantic", "Pacific", "Indian", "Arctic"], correctIndex: 1),
		MCQQuestion(prompt: "Which planet is closest to the Sun?", choices: ["Venus", "Earth", "Mars", "Mercury"], correctIndex: 3),
		MCQQuestion(prompt: "Which element has the chemical symbol O?", choices: ["Gold", "Oxygen", "Osmium", "Zinc"], correctIndex: 1)
	]

	private var currentIndex = 0
	private var answered: Set<Int> = []
	private var selectedIndex = 0
	private let questionLabel = UILabel()
	private let pickerView = UIPickerView()
	private let resultLabel = UILabel()
	private let submitButton = UIButton(type: .system)
	private let nextButton = UIButton(type: .system)
	private let stackView = UIStackView()
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		tabBarItem = UITabBarItem(title: "MCQs", image: UIImage(systemName: "list.bullet"), tag: 0)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground

		questionLabel.font = UIFont.preferredFont(forTextStyle: .title2)
		questionLabel.numberOfLines = 0
		questionLabel.textAlignment = .center

		pickerView.dataSource = self
		pickerView.delegate = self

		resultLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
		resultLabel.textAlignment = .center
		resultLabel.isHidden = true

		submitButton.setTitle("Submit Answer", for: .normal)
		submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

		nextButton.setTitle("Next Question", for: .normal)
		nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 16
		stackView.translatesAutoresizingMaskIntoConstraints = false

		stackView.addArrangedSubview(questionLabel)
		stackView.addArrangedSubview(pickerView)
		stackView.addArrangedSubview(resultLabel)
		stackView.addArrangedSubview(submitButton)
		stackView.addArrangedSubview(nextButton)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

			questionLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
			resultLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
			pickerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
			pickerView.heightAnchor.constraint(equalToConstant: 120),
			submitButton.widthAnchor.constraint(equalToConstant: 200),
			nextButton.widthAnchor.constraint(equalToConstant: 200)
		])

		updateUI()
	}

	private func updateUI() {
		let question = questions[currentIndex]
		questionLabel.text = question.prompt
		pickerView.reloadAllComponents()
		pickerView.selectRow(0, inComponent: 0, animated: false)
		selectedIndex = 0
		resultLabel.text = ""
		resultLabel.isHidden = true
		submitButton.isEnabled = !answered.contains(currentIndex)
		updateNextButton()
	}

	private func updateNextButton() {
		nextButton.isEnabled = answered.count < questions.count
	}

	private func nextAvailableIndex(from index: Int) -> Int? {
		guard answered.count < questions.count else { return nil }
		for offset in 1...questions.count {
			let candidate = (index + offset) % questions.count
			if !answered.contains(candidate) {
				return candidate
			}
		}
		return nil
	}

	@objc private func submitTapped() {
		guard !answered.contains(currentIndex) else { return }
		let question = questions[currentIndex]
		let isCorrect = selectedIndex == question.correctIndex
		Score.shared.record(isCorrect: isCorrect)
		answered.insert(currentIndex)

		resultLabel.text = isCorrect ? "CORRECT" : "INCORRECT"
		resultLabel.textColor = isCorrect ? .systemGreen : .systemRed
		resultLabel.isHidden = false
		submitButton.isEnabled = false
		updateNextButton()
	}

	@objc private func nextTapped() {
		if let nextIndex = nextAvailableIndex(from: currentIndex) {
			currentIndex = nextIndex
			updateUI()
		} else {
			nextButton.isEnabled = false
		}
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		questions[currentIndex].choices.count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		questions[currentIndex].choices[row]
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedIndex = row
	}
}

final class NumericViewController: UIViewController, UITextFieldDelegate {
	private let questions: [NumericQuestion] = [
		NumericQuestion(prompt: "How many sides does a hexagon have?", answer: 6),
		NumericQuestion(prompt: "What is 9 × 7?", answer: 63),
		NumericQuestion(prompt: "How many minutes are in 2.5 hours?", answer: 150)
	]

	private var currentIndex = 0
	private var answered: Set<Int> = []

	private let questionLabel = UILabel()
	private let answerField = UITextField()
	private let resultLabel = UILabel()
	private let submitButton = UIButton(type: .system)
	private let nextButton = UIButton(type: .system)
	private let stackView = UIStackView()
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		tabBarItem = UITabBarItem(title: "Numeric", image: UIImage(systemName: "123.rectangle"), tag: 1)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground

		questionLabel.font = UIFont.preferredFont(forTextStyle: .title2)
		questionLabel.numberOfLines = 0
		questionLabel.textAlignment = .center

		answerField.borderStyle = .roundedRect
		answerField.attributedPlaceholder = NSAttributedString(
			string: "Enter numeric answer",
			attributes: [.foregroundColor: UIColor.secondaryLabel]
		)
		answerField.textColor = .systemBlue
		answerField.keyboardType = .numbersAndPunctuation
		answerField.delegate = self
		answerField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tapGesture)

		resultLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
		resultLabel.textAlignment = .center
		resultLabel.isHidden = true

		submitButton.setTitle("Submit Answer", for: .normal)
		submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

		nextButton.setTitle("Next Question", for: .normal)
		nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 16
		stackView.translatesAutoresizingMaskIntoConstraints = false

		stackView.addArrangedSubview(questionLabel)
		stackView.addArrangedSubview(answerField)
		stackView.addArrangedSubview(resultLabel)
		stackView.addArrangedSubview(submitButton)
		stackView.addArrangedSubview(nextButton)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

			questionLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
			resultLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
			answerField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
			submitButton.widthAnchor.constraint(equalToConstant: 200),
			nextButton.widthAnchor.constraint(equalToConstant: 200)
		])

		updateUI()
	}

	private func updateUI() {
		let question = questions[currentIndex]
		questionLabel.text = question.prompt
		answerField.text = ""
		resultLabel.text = ""
		resultLabel.isHidden = true
		submitButton.isEnabled = false
		updateNextButton()
	}

	private func updateNextButton() {
		nextButton.isEnabled = answered.count < questions.count
	}

	private func nextAvailableIndex(from index: Int) -> Int? {
		guard answered.count < questions.count else { return nil }
		for offset in 1...questions.count {
			let candidate = (index + offset) % questions.count
			if !answered.contains(candidate) {
				return candidate
			}
		}
		return nil
	}

	@objc private func submitTapped() {
		guard !answered.contains(currentIndex) else { return }
		guard let text = answerField.text, let value = Double(text) else { return }
		let question = questions[currentIndex]
		let isCorrect = abs(value - question.answer) < 0.0001
		Score.shared.record(isCorrect: isCorrect)
		answered.insert(currentIndex)

		resultLabel.text = isCorrect ? "CORRECT" : "INCORRECT"
		resultLabel.textColor = isCorrect ? .systemGreen : .systemRed
		resultLabel.isHidden = false
		submitButton.isEnabled = false
		updateNextButton()
	}

	@objc private func nextTapped() {
		dismissKeyboard()
		if let nextIndex = nextAvailableIndex(from: currentIndex) {
			currentIndex = nextIndex
			updateUI()
		} else {
			nextButton.isEnabled = false
		}
	}

	@objc private func textDidChange() {
		let text = answerField.text ?? ""
		submitButton.isEnabled = !answered.contains(currentIndex) && Double(text) != nil
	}

	@objc private func dismissKeyboard() {
		view.endEditing(true)
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let allowed = CharacterSet(charactersIn: "0123456789.-")
		if string.rangeOfCharacter(from: allowed.inverted) != nil {
			return false
		}

		let current = textField.text ?? ""
		guard let range = Range(range, in: current) else { return false }
		let updated = current.replacingCharacters(in: range, with: string)

		if updated.isEmpty { return true }

		let dotCount = updated.filter { $0 == "." }.count
		if dotCount > 1 { return false }

		let minusCount = updated.filter { $0 == "-" }.count
		if minusCount > 1 { return false }
		if minusCount == 1 && !updated.hasPrefix("-") { return false }

		return true
	}
}

final class ScoreViewController: UIViewController {
	private let titleLabel = UILabel()
	private let correctLabel = UILabel()
	private let incorrectLabel = UILabel()
	private let stackView = UIStackView()
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		tabBarItem = UITabBarItem(title: "Score", image: UIImage(systemName: "checkmark.circle"), tag: 2)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
		titleLabel.textAlignment = .center
		titleLabel.text = "Your Score"

		correctLabel.font = UIFont.preferredFont(forTextStyle: .title2)
		correctLabel.textAlignment = .center

		incorrectLabel.font = UIFont.preferredFont(forTextStyle: .title2)
		incorrectLabel.textAlignment = .center

		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 16
		stackView.translatesAutoresizingMaskIntoConstraints = false

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(correctLabel)
		stackView.addArrangedSubview(incorrectLabel)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
			stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
		])
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let correct = Score.shared.correct
		let incorrect = Score.shared.incorrect
		correctLabel.text = "Correct: \(correct)"
		incorrectLabel.text = "Incorrect: \(incorrect)"

		if correct > incorrect {
			view.backgroundColor = .systemGreen
		} else if incorrect > correct {
			view.backgroundColor = .systemRed
		} else {
			view.backgroundColor = .white
		}
	}
}
