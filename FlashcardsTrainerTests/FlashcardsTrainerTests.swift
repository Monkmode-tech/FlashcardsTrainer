//
//  FlashcardsTrainerTests.swift
//  FlashcardsTrainerTests
//
//  Created by Caleb Tetteh on 10/26/25.
//

import Foundation
import Testing
@testable import FlashcardsTrainer

struct FlashcardsTrainerTests {
    @Test func testCardCreation() async throws {
        let card = Card(front: "Front", back: "Back", isKnown: false)
        #expect(card.front == "Front")
        #expect(card.back == "Back")
        #expect(card.isKnown == false)
        #expect(card.createdAt == card.modifiedAt)
        #expect(card.createdAt.timeIntervalSinceNow < 1)
    }

    @Test func testCardEditUpdatesModifiedAt() async throws {
        let card = Card(front: "Front", back: "Back", isKnown: false)
        let originalCreated = card.createdAt
        let originalModified = card.modifiedAt
        // Simulate edit
        card.front = "Edited Front"
        card.modifiedAt = Date()
        #expect(card.front == "Edited Front")
        #expect(card.createdAt == originalCreated)
        #expect(card.modifiedAt > originalModified)
    }

    @Test func testCardDeletion() async throws {
        var cards = [Card(front: "A", back: "B"), Card(front: "C", back: "D")]
        let toDelete = cards[0]
        cards.removeAll { $0.id == toDelete.id }
        #expect(cards.count == 1)
        #expect(cards[0].front == "C")
    }

    @Test func testFilterKnownOnly() async throws {
        let card1 = Card(front: "A", back: "B", isKnown: true)
        let card2 = Card(front: "C", back: "D", isKnown: false)
        let cards = [card1, card2]
        let knownOnly = cards.filter { $0.isKnown }
        #expect(knownOnly.count == 1)
        #expect(knownOnly[0].front == "A")
    }

    @Test func testMarkAllKnownAndResetAll() async throws {
        var cards = [Card(front: "A", back: "B", isKnown: false), Card(front: "C", back: "D", isKnown: false)]
        // Mark all known
        for card in cards where !card.isKnown {
            card.isKnown = true
            card.modifiedAt = Date()
        }
        #expect(cards.allSatisfy { $0.isKnown })
        // Reset all
        for card in cards where card.isKnown {
            card.isKnown = false
            card.modifiedAt = Date()
        }
        #expect(cards.allSatisfy { !$0.isKnown })
    }
}
