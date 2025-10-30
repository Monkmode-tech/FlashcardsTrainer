//
//  EditCardView.swift
//  FlashcardsTrainer
//
//  Created by Caleb Tetteh on 10/26/25.
//

import SwiftUI
import SwiftData

struct EditCardView: View {
    @Bindable var card: Card
    var isNew: Bool
    var onSave: (Card) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(LocalizedStringKey("edit_card"))) {
                    TextField(LocalizedStringKey("front"), text: $card.front)
                        .accessibilityLabel(LocalizedStringKey("front"))
                        .font(.body)
                        .dynamicTypeSize(.medium ... .xxLarge)
                    TextField(LocalizedStringKey("back"), text: $card.back)
                        .accessibilityLabel(LocalizedStringKey("back"))
                        .font(.body)
                        .dynamicTypeSize(.medium ... .xxLarge)
                    Toggle(LocalizedStringKey("known"), isOn: $card.isKnown)
                        .accessibilityLabel(LocalizedStringKey("known"))
                }
                Section {
                    Text(String(localized: "created") + ": " + dateFormatter.string(from: card.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel(String(localized: "created") + ": " + dateFormatter.string(from: card.createdAt))
                    Text(String(localized: "modified") + ": " + dateFormatter.string(from: card.modifiedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel(String(localized: "modified") + ": " + dateFormatter.string(from: card.modifiedAt))
                }
            }
            .navigationTitle(isNew ? LocalizedStringKey("add_card") : LocalizedStringKey("edit_card"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        Text("Save")
                    }
                    .accessibilityLabel("Save")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                    }
                    .accessibilityLabel("Cancel")
                }
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Front and Back cannot be empty.")
        }
    }
    
    private func save() {
        if card.front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || card.back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert = true
            return
        }
        // Only update modifiedAt, never set createdAt (it's immutable)
        card.modifiedAt = Date()
        onSave(card)
        dismiss()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
