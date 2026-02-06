//
//  QuestionBank.swift
//  QuizApp
//
//  Created by Tanmay Goel on 2/4/26.
//
import UIKit

final class QuestionBank {
	static let shared = QuestionBank()

	private(set) var questions: [NumericQuestion] = []
	private let saveURL: URL

	private init() {
		let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		saveURL = baseURL.appendingPathComponent("numeric_questions.json")
		load()
	}

	func getQuestion(_ at: IndexPath) -> NumericQuestion { questions[at.row] }

	func index(for id: UUID) -> Int? { questions.firstIndex { $0.id == id } }

	func createQuestion() -> NumericQuestion {
		let question = NumericQuestion(prompt: "", answer: 0)
		questions.append(question)
		didChange()
		return question
	}

	func updateQuestion(_ updated: NumericQuestion) {
		guard let index = index(for: updated.id) else { return }
		if questions[index] == updated { return }
		questions[index] = updated
		didChange()
	}

	func moveQuestion(from: IndexPath, to: IndexPath) {
		let question = questions[from.row]
		questions.remove(at: from.row)
		questions.insert(question, at: to.row)
		didChange()
	}

	func deleteQuestion(at: IndexPath) {
		let question = questions.remove(at: at.row)
		if let key = question.imageKey {
			ImageStore.shared.deleteImage(forKey: key)
		}
		DrawingStore.shared.deleteDrawing(forKey: question.id.uuidString)
		didChange()
	}

	func resetAll() {
		questions.removeAll()
		didChange()
	}

	private func didChange() {
		save()
		Score.shared.reset()
		NotificationCenter.default.post(name: .quizShouldReset, object: nil)
	}

	private func save() {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		if let data = try? encoder.encode(questions) {
			try? data.write(to: saveURL, options: [.atomic])
		}
	}

	private func load() {
		guard let data = try? Data(contentsOf: saveURL) else {
			questions = []
			return
		}
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		if let decoded = try? decoder.decode([NumericQuestion].self, from: data) {
			questions = decoded
		} else {
			questions = []
		}
	}
}
