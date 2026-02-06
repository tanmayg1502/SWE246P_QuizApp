//
//  NumericDetailViewController.swift
//  QuizApp
//
//  Created by Tanmay Goel on 2/4/26.
//
import UIKit

final class NumericDetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	private var question: NumericQuestion

	private let contentStack = UIStackView()
	private let textStack = UIStackView()
	private let imageContainer = UIView()
	private let imageView = UIImageView()
	private let promptField = UITextField()
	private let answerField = UITextField()
	private let dateLabel = UILabel()
	private let toolbar = UIToolbar()

	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}()

	init(question: NumericQuestion) {
		self.question = question
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		title = question.prompt.isEmpty ? "New Question" : "Edit Question"

		promptField.borderStyle = .roundedRect
		promptField.placeholder = "Enter question"
		promptField.text = question.prompt
		promptField.returnKeyType = .done
		promptField.delegate = self

		answerField.borderStyle = .roundedRect
		answerField.placeholder = "Enter numeric answer"
		answerField.keyboardType = .numbersAndPunctuation
		answerField.returnKeyType = .done
		answerField.text = "\(question.answer)"
		answerField.delegate = self

		dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		dateLabel.textColor = .secondaryLabel
		dateLabel.text = "Created: \(Self.dateFormatter.string(from: question.createdAt))"

		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		imageView.backgroundColor = .secondarySystemBackground
		if let key = question.imageKey, let image = ImageStore.shared.image(forKey: key) {
			imageView.image = image
		}

		textStack.axis = .vertical
		textStack.spacing = 12
		textStack.translatesAutoresizingMaskIntoConstraints = false
		textStack.addArrangedSubview(promptField)
		textStack.addArrangedSubview(answerField)
		textStack.addArrangedSubview(dateLabel)

		imageContainer.translatesAutoresizingMaskIntoConstraints = false
		imageContainer.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
			imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
			imageView.heightAnchor.constraint(equalToConstant: 220)
		])

		contentStack.axis = .vertical
		contentStack.alignment = .fill
		contentStack.spacing = 16
		contentStack.translatesAutoresizingMaskIntoConstraints = false
		contentStack.addArrangedSubview(textStack)
		contentStack.addArrangedSubview(imageContainer)

		view.addSubview(contentStack)
		view.addSubview(toolbar)

		toolbar.translatesAutoresizingMaskIntoConstraints = false
		// toolbar actions for photo, drawing, and clearing
		let cameraItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraTapped))
		let drawItem = UIBarButtonItem(title: "Draw", style: .plain, target: self, action: #selector(drawTapped))
		let clearItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearImage))
		let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		toolbar.items = [cameraItem, drawItem, flexible, clearItem]

		NSLayoutConstraint.activate([
			contentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			contentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
			contentStack.bottomAnchor.constraint(lessThanOrEqualTo: toolbar.topAnchor, constant: -16),

			toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])

		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
		updateLayoutForSize()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		saveChanges()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}

	// delegate method for when the device orientation changes
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateLayoutForSize()
	}

	private func updateLayoutForSize() {
		let isLandscape = view.bounds.width > view.bounds.height
		contentStack.axis = isLandscape ? .horizontal : .vertical
		contentStack.distribution = isLandscape ? .fillEqually : .fill
	}

	private func saveChanges() {
		let prompt = promptField.text ?? ""
		question.prompt = prompt

		if let text = answerField.text, let value = Double(text) {
			question.answer = value
		}

		QuestionBank.shared.updateQuestion(question)
		title = question.prompt.isEmpty ? "New Question" : "Edit Question"
	}

	@objc private func dismissKeyboard() {
		view.endEditing(true)
	}

	// dismiss the keyboard on press of return button
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// delegate method to control the input coming into the text field
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		// only allow valid numeric input in answerField
		guard textField == answerField else { return true }
		let allowed = CharacterSet(charactersIn: "0123456789.-")
		if string.rangeOfCharacter(from: allowed.inverted) != nil {
			return false
		}

		// at most one dot, one minus, minus should be the first char
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

	// Update the mdoel when editing finishes
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField == answerField {
			if let text = textField.text, let value = Double(text) { // Convert value to double
				question.answer = value // store it
			} else {
				textField.text = "\(question.answer)" // if invalid, restore to last valid value
			}
		} else if textField == promptField {
			question.prompt = textField.text ?? "" // save question to the question obj
		}
		QuestionBank.shared.updateQuestion(question) // update the question bank
		title = question.prompt.isEmpty ? "New Question" : "Edit Question"
	}

	// Open image picker
	@objc private func cameraTapped() {
		// uses camera if available, otherwise falls back to photo library
		let picker = UIImagePickerController()
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			picker.sourceType = .camera
		} else {
			picker.sourceType = .photoLibrary
		}
		picker.delegate = self
		picker.allowsEditing = true // allows cropping
		present(picker, animated: true)// presents picker
	}

	// remove the image from the question
	@objc private func clearImage() {
		// Delete from Image Store if it exists
		if let key = question.imageKey {
			ImageStore.shared.deleteImage(forKey: key)
		}
		// Delete drawing data if it exists
		DrawingStore.shared.deleteDrawing(forKey: question.id.uuidString)
		// clear question image key and imageView image
		question.imageKey = nil
		imageView.image = nil
		// clears image key
		QuestionBank.shared.updateQuestion(question)
	}

	// save selected image
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		// uses edited iamge first, else original
		let selected = (info[.editedImage] ?? info[.originalImage]) as? UIImage
		if let image = selected {
			// remove any existing drawing for this question
			DrawingStore.shared.deleteDrawing(forKey: question.id.uuidString)
			// generates key from imageKey or question ID
			let key = question.imageKey ?? question.id.uuidString
			// Store in Image store
			ImageStore.shared.setImage(image, forKey: key)
			// update question, imageview
			question.imageKey = key
			imageView.image = image
			// update the question in the bank
			QuestionBank.shared.updateQuestion(question)
		}
		dismiss(animated: true)
	}
	
	// user cancelled, just dismiss picker
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true)
	}

	@objc private func drawTapped() {
		// open drawing canvas for this question
		let drawingKey = question.id.uuidString
		let existingDrawing = DrawingStore.shared.drawing(forKey: drawingKey)
		let hadExistingDrawing = existingDrawing != nil

		let controller = DrawingViewController(existingDrawing: existingDrawing) { [weak self] drawing, image in
			guard let self = self else { return }
			// if the user cleared everything, remove the stored image/drawing
			if drawing.lines.isEmpty {
				if hadExistingDrawing {
					DrawingStore.shared.deleteDrawing(forKey: drawingKey)
					if let oldKey = self.question.imageKey {
						ImageStore.shared.deleteImage(forKey: oldKey)
					}
					self.question.imageKey = nil
					self.imageView.image = nil
					QuestionBank.shared.updateQuestion(self.question)
				}
				return
			}

			// persist both the drawing data and the rendered image
			let newKey = self.question.id.uuidString
			if let oldKey = self.question.imageKey, oldKey != newKey {
				ImageStore.shared.deleteImage(forKey: oldKey)
			}

			DrawingStore.shared.setDrawing(drawing, forKey: drawingKey)
			if let image = image {
				ImageStore.shared.setImage(image, forKey: newKey)
				self.question.imageKey = newKey
				self.imageView.image = image
				QuestionBank.shared.updateQuestion(self.question)
			}
		}
		// push the drawing screen
		navigationController?.pushViewController(controller, animated: true)
	}
}
