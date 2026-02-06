//
//  QuestionListViewController.swift
//  QuizApp
//
//  Created by tanmayGoel on 2/1/26.
//

import UIKit

final class NumericQuestionTableCell: UITableViewCell {
	static let reuseIdentifier = "NumericalQuestionCell"
	private static let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 4
		return formatter
	}()
	
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
	
	// Added number formatter here to the answer label
	func configure(_ with: NumericQuestion) {
		questionLabel.text = with.prompt
		let formatted = Self.numberFormatter.string(from: NSNumber(value: with.answer)) ?? "\(with.answer)"
		answerLabel.text = "Answer: \(formatted)"
	}
}


final class QuestionListViewController: UITableViewController {
	private let headerNavBar = UINavigationBar()
	private var editBarButton: UIBarButtonItem?
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(NumericQuestionTableCell.self, forCellReuseIdentifier: NumericQuestionTableCell.reuseIdentifier)
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
		navigationController?.tabBarItem = UITabBarItem(title: "Questions", image: UIImage(systemName: "list.number"), tag: 3) // nav bar
		setupHeaderNavBar()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
		tableView.reloadData()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if let header = tableView.tableHeaderView {
			var frame = header.frame
			if frame.width != tableView.bounds.width {
				frame.size.width = tableView.bounds.width
				header.frame = frame
				tableView.tableHeaderView = header
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}

	private func setupHeaderNavBar() {
		let headerHeight: CGFloat = 50
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight))
		headerNavBar.frame = headerView.bounds
		headerNavBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		let navItem = UINavigationItem(title: "Questions")
		let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(toggleEditing))
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuestion))
		navItem.leftBarButtonItem = editButton
		navItem.rightBarButtonItem = addButton

		editBarButton = editButton
		headerNavBar.items = [navItem]

		headerView.addSubview(headerNavBar)
		tableView.tableHeaderView = headerView
	}
	
	@objc private func toggleEditing() {
		let newState = !tableView.isEditing
		tableView.setEditing(newState, animated: true)
		editBarButton?.title = newState ? "Done" : "Edit"
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		QuestionBank.shared.questions.count
	}
	

	@objc private func addQuestion() {
		let question = QuestionBank.shared.createQuestion()
		let detail = NumericDetailViewController(question: question)
		navigationController?.pushViewController(detail, animated: true)
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: NumericQuestionTableCell.reuseIdentifier, for: indexPath) as? NumericQuestionTableCell else {
			return UITableViewCell()
		}
		let item = QuestionBank.shared.getQuestion(indexPath)
		cell.configure(item)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard !tableView.isEditing else { return }
		tableView.deselectRow(at: indexPath, animated: true)
		let item = QuestionBank.shared.getQuestion(indexPath)
		let detail = NumericDetailViewController(question: item)
		navigationController?.pushViewController(detail, animated: true)
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
