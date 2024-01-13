//
//  AdvancedViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 09/11/2023.
//

import Combine
import Foundation

/// `AdvancedViewModel` is a type responsible for loading and storing advanced lessons.
///
/// This class handles the fetching of JSON data from a specified URL and decoding it into an array of `Lesson` objects.
/// It uses `@Published` properties to allow SwiftUI views to react to changes in data, loading state, or error messages.
//class AdvancedViewModel: ObservableObject {
//    
//    /// The array of `Lesson` objects that has been fetched.
//    /// The view will update when this property changes due to the `@Published` wrapper.
//    @Published var advancedLessons: [Lesson] = []
//    
//    /// A boolean value indicating whether the view model is currently fetching data.
//    /// Views can observe this property to show or hide loading indicators.
//    @Published var isLoading: Bool = false
//    
//    /// An optional string that stores an error message if an error occurs during the fetching process.
//    /// Views can observe and react to this property to present any errors to the user.
//    @Published var errorMessage: String?
//    
//    let language = Bundle.main.preferredLocalizations.first!
//    
//    /// Fetches advanced lessons from a remote source.
//    ///
//    /// This method starts a network request to fetch lesson data. It sets `isLoading` to `true` while fetching and updates the `advancedLessons`
//    /// array on success or sets `errorMessage` on failure. It ensures UI updates are performed on the main queue.
//    func fetchJSON() {
//        // The URL string of the remote JSON file containing advanced lesson data.
//        guard let url = URL(string: "https://raw.githubusercontent.com/cilippofilia/drinko-advanced-knowledge/main/advanced/advanced-\(language)/advanced.json") else {
//            errorMessage = "Invalid URL"
//            return
//        }
//        
//        isLoading = true
//        // Create a data task to fetch the data.
//        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            defer { self?.isLoading = false }
//            // Handle any errors that occurred during the network request.
//            if let error = error {
//                self?.errorMessage = error.localizedDescription
//                return
//            }
//            
//            // Check if data was received.
//            guard let data = data else {
//                self?.errorMessage = "No data received"
//                return
//            }
//            
//            // Attempt to decode the JSON into an array of `Lesson` objects.
//            do {
//                let decodedLessons = try JSONDecoder().decode([Lesson].self, from: data)
//                // Update `advancedLessons` on the main queue.
//                DispatchQueue.main.async {
//                    self?.advancedLessons = decodedLessons
//                }
//            } catch {
//                self?.errorMessage = error.localizedDescription
//            }
//        }.resume()
//    }
//}
