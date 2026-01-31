//
//  ScoreViewController.swift
//  QuizApp
//
//  Created by Tanmay Goel on 1/31/26.
//

import UIKit

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
