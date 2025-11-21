import SwiftUI
import SwiftData

struct CardFrontView: View {
    let card: Card
    let appLanguage: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.front)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
                .accessibilityLabel(card.front)
                .dynamicTypeSize(.medium ... .xxLarge)
            Text(card.isKnown ? "known".localized(for: appLanguage) : "new".localized(for: appLanguage))
                .font(.caption)
                .foregroundColor(card.isKnown ? .green : .red)
                .accessibilityLabel(card.isKnown ? "known".localized(for: appLanguage) : "new".localized(for: appLanguage))
                .dynamicTypeSize(.medium ... .xxLarge)
            Text(String(format: "created_format".localized(for: appLanguage), DateFormatter.flashcard.string(from: card.createdAt)))
                .font(.caption2)
                .foregroundColor(.secondary)
                .accessibilityLabel(String(format: "created_format".localized(for: appLanguage), DateFormatter.flashcard.string(from: card.createdAt)))
                .dynamicTypeSize(.medium ... .xxLarge)
            Text(String(format: "modified_format".localized(for: appLanguage), DateFormatter.flashcard.string(from: card.modifiedAt)))
                .font(.caption2)
                .foregroundColor(.secondary)
                .accessibilityLabel(String(format: "modified_format".localized(for: appLanguage), DateFormatter.flashcard.string(from: card.modifiedAt)))
                .dynamicTypeSize(.medium ... .xxLarge)
        }
    }
}

#Preview {
    CardFrontView(card: Card(front: "Front", back: "Back", isKnown: false), appLanguage: "en")
}
