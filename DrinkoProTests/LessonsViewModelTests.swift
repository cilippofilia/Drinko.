//
//  LessonsViewModelTests.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/01/2026.
//

import Testing
@testable import DrinkoPro

@Suite("LessonsViewModel basic routing")
@MainActor
struct LessonsViewModelTests {
    private func makeViewModel() -> LessonsViewModel {
        let vm = LessonsViewModel()
        // Inject deterministic data to avoid bundle file dependency
        let lessonA = Lesson(id: "basic-1", title: "Basic A", description: "desc", body: [])
        let lessonB = Lesson(id: "advanced-1", title: "Advanced A", description: "desc", body: [])
        let prep = Lesson(id: "prep-1", title: "Prep A", description: "desc", body: [])
        let spirit = Lesson(id: "spirit-1", title: "Spirit A", description: "desc", body: [])
        let advSpirit = Lesson(id: "adv-spirit-1", title: "Adv Spirit A", description: "desc", body: [])
        let liqueur = Lesson(id: "liqueur-1", title: "Liqueur A", description: "desc", body: [])
        let syrup = Lesson(id: "syrup-1", title: "Syrup A", description: "desc", body: [])
        vm.basicLessons = [lessonA]
        vm.advancedLessons = [lessonB]
        vm.barPreps = [prep]
        vm.basicSpirits = [spirit]
        vm.advancedSpirits = [advSpirit]
        vm.liqueurs = [liqueur]
        vm.syrups = [syrup]
        return vm
    }

    @Test("Topics enumeration")
    func topicsList() async throws {
        let vm = makeViewModel()
        #expect(vm.topics.contains("basic-lessons"))
        #expect(vm.topics.contains("syrups"))
    }

    @Test("Get lessons per topic")
    func getLessonsForTopic() async throws {
        let vm = makeViewModel()
        #expect(vm.getLessons(for: "basic-lessons").map { $0.id } == ["basic-1"]) 
        #expect(vm.getLessons(for: "advanced-lessons").map { $0.id } == ["advanced-1"]) 
        #expect(vm.getLessons(for: "bar-preps").map { $0.id } == ["prep-1"]) 
        #expect(vm.getLessons(for: "basic-spirits").map { $0.id } == ["spirit-1"]) 
        #expect(vm.getLessons(for: "advanced-spirits").map { $0.id } == ["adv-spirit-1"]) 
        #expect(vm.getLessons(for: "liqueurs").map { $0.id } == ["liqueur-1"]) 
        #expect(vm.getLessons(for: "syrups").map { $0.id } == ["syrup-1"]) 
        #expect(vm.getLessons(for: "unknown").isEmpty)
    }

    @Test("All lessons aggregation")
    func allLessons() async throws {
        let vm = makeViewModel()
        #expect(vm.allLessons.count == 7)
    }
}
