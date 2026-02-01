//
//  QuestionListViewController.swift
//  QuizApp
//
//  Created by tanmayGoel on 2/1/26.
//

import UIKit

final class NumericQuestionTableCell: UITableViewCell {
	static let reuseIdentifier = "NumericalQuestionCell"
	
	private let questionLabel = UILabel()
	private let answerLabel = UILabel()
	private let stackView = UIStackView()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) { super.init(coder: coder) }
	
	func setupUI(){
		questionLabel.font = UIFont.preferredFont(forTextStyle: .body)
		questionLabel.numberOfLines = 0
		
		answerLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		answerLabel.numberOfLines = 0
		answerLabel.textColor = .secondaryLabel
		
		stackView.axis = .vertical
		stackView.spacing = 4
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.addArrangedSubview(questionLabel)
		stackView.addArrangedSubview(answerLabel)
		
		contentView.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
		])
	}
	
	func configure(_ with: NumericQuestion) {
		questionLabel.text = with.prompt
		answerLabel.text = "Answer: \(with.answer)"
	}
}


final class QuestionListViewController: UITableViewController {
	private let editButton = UIButton(type: .system)
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		tabBarItem = UITabBarItem(title: "Questions", image: UIImage(systemName: "list.number"), tag: 3)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(NumericQuestionTableCell.self, forCellReuseIdentifier: NumericQuestionTableCell.reuseIdentifier)
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
		setupEditHeader()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
	private func setupEditHeader() {
		let headerHeight: CGFloat = 56
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
		
		editButton.setTitle("Edit", for: .normal)
		editButton.frame = CGRect(x: 16, y:8, width: headerView.bounds.width - 32, height: 40)
		editButton.autoresizingMask = [.flexibleWidth]
		editButton.backgroundColor = .systemBlue
		editButton.setTitleColor(.white, for: .normal)
		editButton.layer.cornerRadius = 8
		editButton.addTarget(self, action: #selector(toggleEditing), for: .touchUpInside)
		
		headerView.addSubview(editButton)
		tableView.tableHeaderView = headerView
	}
	
	@objc private func toggleEditing() {
		let newState = !tableView.isEditing
		tableView.setEditing(newState, animated: true)
		editButton.setTitle(newState ? "Done" : "Edit", for: .normal)
		if !newState {
			Score.shared.reset()
			NotificationCenter.default.post(name: .quizShouldReset, object: nil)
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		QuestionBank.shared.questions.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: NumericQuestionTableCell.reuseIdentifier, for: indexPath) as? NumericQuestionTableCell else {
			return UITableViewCell()
		}
		let item = QuestionBank.shared.getQuestion(indexPath)
		cell.configure(item)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		QuestionBank.shared.moveQuestion(from: sourceIndexPath, to: destinationIndexPath)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			QuestionBank.shared.deleteQuestion(at: indexPath)
			tableView.deleteRows(at: [indexPath], with: .automatic)
		}
	}
}
