import Foundation
import SwiftUI

// MARK: - Models

struct Meal: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var date: Date = Date()
}

struct Goals: Codable, Equatable {
    var calories: Double = 2000
    var protein: Double = 150
    var carbs: Double = 200
    var fat: Double = 65
}

struct Totals {
    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
}

// MARK: - Macro metadata (colors, names, units)

enum Macro: CaseIterable, Identifiable {
    case calories, protein, carbs, fat

    var id: Self { self }

    var title: String {
        switch self {
        case .calories: return "السعرات"
        case .protein: return "البروتين"
        case .carbs: return "الكارب"
        case .fat: return "الدهون"
        }
    }

    var unit: String {
        self == .calories ? "سعرة" : "غ"
    }

    var icon: String {
        switch self {
        case .calories: return "flame.fill"
        case .protein: return "bolt.heart.fill"
        case .carbs: return "leaf.fill"
        case .fat: return "drop.fill"
        }
    }

    var color: Color {
        switch self {
        case .calories: return Color(red: 1.00, green: 0.48, blue: 0.30)
        case .protein: return Color(red: 0.94, green: 0.33, blue: 0.47)
        case .carbs: return Color(red: 0.98, green: 0.72, blue: 0.20)
        case .fat: return Color(red: 0.30, green: 0.62, blue: 0.98)
        }
    }

    func value(in totals: Totals) -> Double {
        switch self {
        case .calories: return totals.calories
        case .protein: return totals.protein
        case .carbs: return totals.carbs
        case .fat: return totals.fat
        }
    }

    func value(in goals: Goals) -> Double {
        switch self {
        case .calories: return goals.calories
        case .protein: return goals.protein
        case .carbs: return goals.carbs
        case .fat: return goals.fat
        }
    }
}

// MARK: - Store (persisted in UserDefaults)

@MainActor
final class MealStore: ObservableObject {
    @Published var meals: [Meal] = [] {
        didSet { save(meals, key: Self.mealsKey) }
    }
    @Published var goals = Goals() {
        didSet { save(goals, key: Self.goalsKey) }
    }

    private static let mealsKey = "meals.v1"
    private static let goalsKey = "goals.v1"

    init() {
        meals = Self.load([Meal].self, key: Self.mealsKey) ?? []
        goals = Self.load(Goals.self, key: Self.goalsKey) ?? Goals()
    }

    func meals(on day: Date) -> [Meal] {
        meals
            .filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date > $1.date }
    }

    func totals(on day: Date) -> Totals {
        meals(on: day).reduce(into: Totals()) { t, m in
            t.calories += m.calories
            t.protein += m.protein
            t.carbs += m.carbs
            t.fat += m.fat
        }
    }

    func upsert(_ meal: Meal) {
        if let i = meals.firstIndex(where: { $0.id == meal.id }) {
            meals[i] = meal
        } else {
            meals.append(meal)
        }
    }

    func delete(_ meal: Meal) {
        meals.removeAll { $0.id == meal.id }
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Number helpers

enum NumberText {
    /// Parses user input, accepting Arabic-Indic digits and either decimal separator.
    static func parse(_ text: String) -> Double? {
        let arabic = Array("٠١٢٣٤٥٦٧٨٩")
        var normalized = ""
        for ch in text.trimmingCharacters(in: .whitespaces) {
            if let i = arabic.firstIndex(of: ch) {
                normalized.append(String(i))
            } else if ch == "٫" || ch == "," {
                normalized.append(".")
            } else {
                normalized.append(ch)
            }
        }
        return Double(normalized)
    }

    static func format(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}
