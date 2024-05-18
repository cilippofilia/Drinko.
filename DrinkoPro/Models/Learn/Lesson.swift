//
//  Lesson.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct Lesson: Codable, Equatable, Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var body: [LessonContent]
    
    var hasVideo: Bool?
    var videoURL: String?
    var videoID: String?

    var img: String {
        "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/\(id).jpg"
    }
}

struct LessonContent: Codable, Equatable, Identifiable, Hashable {
    var id: String { heading }
    let heading: String
    let content: String
}

@Observable
class LessonsViewModel {
    var basicLessons: [Lesson] = []
    var advancedLessons: [Lesson] = []
    var barPreps: [Lesson] = []
    var basicSpirits: [Lesson] = []
    var advancedSpirits: [Lesson] = []
    var liqueurs: [Lesson] = []
    var books: [Book] = []
    var syrups: [Lesson] = []

    let baseURL = "https://raw.githubusercontent.com/cilippofilia/drinko-learn/main"
    let topics = [
        "basic-lessons",
        "advanced-lessons",
        "bar-preps",
        "basic-spirits",
        "advanced-spirits",
        "liqueurs",
        "syrups"
    ]
    var language = "\(Bundle.main.preferredLocalizations.first!)/"

    init() { }

    func fetchBooks() {
        if let url = URL(string: "https://raw.githubusercontent.com/cilippofilia/drinko-learn/main/books/\(language)/books.json") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([Book].self, from: data)
                        DispatchQueue.main.async {
                            self.books = decodedData
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                } else if let error = error {
                    print("Error fetching data: \(error)")
                }
            }.resume()
        }
    }

    func fetchLessons() {
        for topic in topics {
            if let url = URL(string: "\(baseURL)/\(topic)/\(language)/\(topic).json") {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        do {
                            let decodedLessonData = try JSONDecoder().decode([Lesson].self, from: data)
                            DispatchQueue.main.async {
                                if topic == "basic-lessons" {
                                    self.basicLessons = decodedLessonData
                                } else if topic == "advanced-lessons" {
                                    self.advancedLessons = decodedLessonData
                                } else if topic == "bar-preps" {
                                    self.barPreps = decodedLessonData
                                } else if topic == "basic-spirits" {
                                    self.basicSpirits = decodedLessonData
                                } else if topic == "advanced-spirits" {
                                    self.advancedSpirits = decodedLessonData
                                } else if topic == "liqueurs" {
                                    self.liqueurs = decodedLessonData
                                } else if topic == "syrups" {
                                    self.syrups = decodedLessonData
                                }
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    } else if let error = error {
                        print("Error fetching data: \(error)")
                    }
                }.resume()
            }
        }
    }

    func refreshData() {
        fetchLessons()
        fetchBooks()
    }
}
