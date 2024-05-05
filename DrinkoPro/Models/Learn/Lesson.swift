//
//  Lesson.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct Lesson: Codable, Equatable, Identifiable {
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

struct LessonContent: Codable, Equatable, Identifiable {
    var id: String { heading }
    let heading: String
    let content: String
}

@Observable
class AdvancedLesson {
    var advancedLessons: [Lesson] = []
    var barPreps: [Lesson] = []
    var advancedSpirits: [Lesson] = []
    var liqueurs: [Lesson] = []

    var basicLessons = Bundle.main.decode([Lesson].self, from: "basics.json")
    var spirits = Bundle.main.decode([Lesson].self, from: "spirits.json")
    var syrups = Bundle.main.decode([Lesson].self, from: "syrups.json")
    var books = Bundle.main.decode([Book].self, from: "books.json")
    
    let baseURL = "https://raw.githubusercontent.com/cilippofilia/drinko-learn/main"
    let topics = ["advanced-lessons", "bar-preps", "advanced-spirits", "liqueurs"]
    var language = "\(Bundle.main.preferredLocalizations.first!)/"

    init() { }

    func fetchAdvancedLessons() {
        for topic in topics {
            if let url = URL(string: "\(baseURL)/\(topic)/\(language)/\(topic).json") {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        do {
                            let decodedData = try JSONDecoder().decode([Lesson].self, from: data)
                            DispatchQueue.main.async {
                                if topic == "advanced-lessons" {
                                    self.advancedLessons.append(contentsOf: decodedData)
                                } else if topic == "bar-preps" {
                                    self.barPreps.append(contentsOf: decodedData)
                                } else if topic == "advanced-spirits" {
                                    self.advancedSpirits.append(contentsOf: decodedData)
                                } else if topic == "liqueurs" {
                                    self.liqueurs.append(contentsOf: decodedData)
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
}
