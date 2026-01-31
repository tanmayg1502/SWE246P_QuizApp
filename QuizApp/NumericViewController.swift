//
//  NumericViewController.swift
//  QuizApp
//
//  Created by Tanmay Goel on 1/31/26.
//
import UIKit

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
