//
//  MCQViewController.swift
//  QuizApp
//
//  Created by Tanmay Goel on 1/31/26.
//
import UIKit

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
