//
//  ContentView.swift
//  FlashcardsTrainer
//
//  Created by Caleb Tetteh on 10/26/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: [SortDescriptor(\Card.createdAt, order: .forward)]) var cards: [Card]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("showKnownOnly") private var showKnownOnly: Bool = false
    @AppStorage("appLanguage") private var appLanguage: String = "system"
    @State private var showAddSheet = false
    @State private var showDeleteAlert = false
    @State private var cardToDelete: Card?
    @State private var showEditSheet = false
    @State private var selectedCard: Card?
    
    var filteredCards: [Card] {
        showKnownOnly ? cards.filter { $0.isKnown } : cards
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text(localized("app_title", appLanguage))
                        .font(.largeTitle)
                        .bold()
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Toggle(isOn: $showKnownOnly) {
                        Text(localized("show_known_only", appLanguage))
                    }
                    .toggleStyle(.switch)
                    .accessibilityLabel(localized("show_known_only", appLanguage))
                }
                .padding([.top, .horizontal])
                List {
                    ForEach(filteredCards) { card in
                        Button {
                            selectedCard = card
                            showEditSheet = true
                        } label: {
                            CardRowView(card: card, appLanguage: appLanguage) {
                                // Mark as known only when flipping to back
                                if !card.isKnown {
                                    card.isKnown = true
                                    card.modifiedAt = Date()
                                    try? modelContext.save()
                                }
                            }
                        }
                        .listRowBackground(card.isKnown ? Color("KnownColor") : Color("NewColor"))
                        .accessibilityElement(children: .combine)
                        .swipeActions {
                            Button(role: .destructive) {
                                cardToDelete = card
                                showDeleteAlert = true
                            } label: {
                                Label(localized("delete_card", appLanguage), systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Label(localized("add_card", appLanguage), systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: markAllKnown) {
                            Text(localized("mark_all_known", appLanguage))
                        }
                
                        Button(action: resetAll) {
                            Text(localized("reset_all", appLanguage))
                        }
                        
                        Picker("Language", selection: $appLanguage) {
                            Text("System Default (Device Language)").tag("system")
                            Text("English").tag("en")
                            Text("Español").tag("es")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 115)
                        .accessibilityLabel(localized("language_picker", appLanguage))
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EditCardView(card: Card(), isNew: true) { newCard in
                    modelContext.insert(newCard)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let card = selectedCard {
                    EditCardView(card: card, isNew: false) { updatedCard in
                        card.front = updatedCard.front
                        card.back = updatedCard.back
                        card.isKnown = updatedCard.isKnown
                        card.modifiedAt = Date()
                        try? modelContext.save() // Persist changes
                    }
                }
            }
            .alert(localized("delete_card", appLanguage), isPresented: $showDeleteAlert, presenting: cardToDelete) { card in
                Button(role: .destructive) {
                    if let card = cardToDelete {
                        modelContext.delete(card)
                        cardToDelete = nil
                    }
                } label: {
                    Text(localized("delete_card", appLanguage))
                }
                Button(role: .cancel) {} label: {
                    Text("Cancel")
                }
            } message: { card in
                Text(localized("delete_confirm", appLanguage))
            }
        }
    }
    
    private func markAllKnown() {
        for card in cards where !card.isKnown {
            card.isKnown = true
            card.modifiedAt = Date()
        }
    }
    
    private func resetAll() {
        for card in cards where card.isKnown {
            card.isKnown = false
            card.modifiedAt = Date()
        }
    }
}

struct CardRowView: View {
    let card: Card
    let appLanguage: String
    var onFlip: () -> Void
    @State private var isFlipped: Bool = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
            // Card content with flip animation (only animates opacity, not rotation)
            HStack {
                Group {
                    VStack(alignment: .leading, spacing: 8) {
                        if isFlipped {
                            Text(localized("back_label", appLanguage))
                                .font(.caption)
                                .foregroundColor(.blue)
                                .accessibilityLabel(localized("back_label", appLanguage))
                                .dynamicTypeSize(.medium ... .xxLarge)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            Text(card.back)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                                .accessibilityLabel(card.back)
                                .dynamicTypeSize(.medium ... .xxLarge)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            
                        } else {
                            Text(card.front)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                                .accessibilityLabel(card.front)
                                .dynamicTypeSize(.medium ... .xxLarge)
                            Text(card.isKnown ? localized("known", appLanguage) : localized("new", appLanguage))
                                .font(.caption)
                                .foregroundColor(card.isKnown ? .green : .red)
                                .accessibilityLabel(card.isKnown ? localized("known", appLanguage) : localized("new", appLanguage))
                                .dynamicTypeSize(.medium ... .xxLarge)
                            Text(String(format: localized("created_format", appLanguage), dateFormatter.string(from: card.createdAt)))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .accessibilityLabel(String(format: localized("created_format", appLanguage), dateFormatter.string(from: card.createdAt)))
                                .dynamicTypeSize(.medium ... .xxLarge)
                            Text(String(format: localized("modified_format", appLanguage), dateFormatter.string(from: card.modifiedAt)))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .accessibilityLabel(String(format: localized("modified_format", appLanguage), dateFormatter.string(from: card.modifiedAt)))
                                .dynamicTypeSize(.medium ... .xxLarge)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
                    .animation(.easeInOut, value: isFlipped)
                }
                Spacer(minLength: 40) // Reserve space for the icon
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            // Flip icon overlay, always at trailing edge
            .overlay(
                Button(action: {
                    withAnimation {
                        let wasFlipped = isFlipped
                        isFlipped.toggle()
                        // Call onFlip only when flipping to back
                        if !wasFlipped {
                            onFlip()
                        }
                    }
                }) {
                    Image(systemName: "arrow.2.circlepath")
                        .imageScale(.large)
                        .accessibilityLabel(localized("flip_card", appLanguage))
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 16),
                alignment: .trailing
            )
        }
        .frame(height: 100)
    }
}

// Helper for localized strings
func localized(_ key: String, _ lang: String) -> String {
    let resolvedLang: String
    if lang == "system" {
        resolvedLang = Locale.current.languageCode ?? "en"
    } else {
        resolvedLang = lang
    }
    guard let path = Bundle.main.path(forResource: resolvedLang, ofType: "lproj"),
          let bundle = Bundle(path: path) else {
        return NSLocalizedString(key, comment: "")
    }
    return NSLocalizedString(key, bundle: bundle, comment: "")
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ContentView()
}
