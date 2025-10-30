import Foundation
import SwiftData

@Model
class Card {
    @Attribute(.unique) var id: UUID
    var front: String
    var back: String
    var isKnown: Bool
    let createdAt: Date
    var modifiedAt: Date
    
    init(front: String = "", back: String = "", isKnown: Bool = false) {
        self.id = UUID()
        self.front = front
        self.back = back
        self.isKnown = isKnown
        let now = Date()
        self.createdAt = now
        self.modifiedAt = now
    }
}
