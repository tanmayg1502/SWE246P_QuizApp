//
//  NumericQuestion.swift
//  QuizApp
//
//  Created by Tanmay Goel on 2/4/26.
//
import Foundation

struct NumericQuestion: Codable, Equatable {
	let id: UUID
	var prompt: String
	var answer: Double
	let createdAt: Date
	var imageKey: String?

	init(prompt: String, answer: Double, createdAt: Date = Date(), id: UUID = UUID(), imageKey: String? = nil) {
		self.id = id
		self.prompt = prompt
		self.answer = answer
		self.createdAt = createdAt
		self.imageKey = imageKey
	}
}
