//
//  ProLessonsViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 18/10/2023.
//

import Combine
import Foundation

class ProLessonsViewModel: ObservableObject {
    // Published property to store fetched data
    @Published var lessons: [ProLesson] = []

    // fetch data from GitHub
    func fetchData(from url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                        // decode the data
                    let decodedData = try JSONDecoder().decode([ProLesson].self, from: data)
                    DispatchQueue.main.async {
                        self.lessons = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        .resume()
    }
}
