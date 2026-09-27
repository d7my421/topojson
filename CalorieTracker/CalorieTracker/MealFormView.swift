import SwiftUI

/// Add or edit a meal.
struct MealFormView: View {
    @EnvironmentObject private var store: MealStore
    @Environment(\.dismiss) private var dismiss

    var day: Date
    var existing: Meal?

    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && NumberText.parse(calories) != nil
    }

    /// Calories estimated from macros (4/4/9 kcal per gram).
    private var estimatedCalories: Double? {
        let p = NumberText.parse(protein) ?? 0
        let c = NumberText.parse(carbs) ?? 0
        let f = NumberText.parse(fat) ?? 0
        let total = p * 4 + c * 4 + f * 9
        return total > 0 ? total : nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("اسم الوجبة") {
                    TextField("مثال: صدر دجاج مع رز", text: $name)
                }

                Section {
                    field(.calories, text: $calories)
                    field(.protein, text: $protein)
                    field(.carbs, text: $carbs)
                    field(.fat, text: $fat)
                } header: {
                    Text("القيم الغذائية")
                } footer: {
                    if let est = estimatedCalories, NumberText.parse(calories) == nil {
                        Button("احسب السعرات من الماكروز (\(NumberText.format(est.rounded())))") {
                            calories = NumberText.format(est.rounded())
                        }
                        .font(.footnote)
                    }
                }

                if existing != nil {
                    Section {
                        Button("حذف الوجبة", role: .destructive) {
                            if let existing { store.delete(existing) }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(existing == nil ? "وجبة جديدة" : "تعديل الوجبة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") { save() }
                        .fontWeight(.bold)
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func field(_ macro: Macro, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: macro.icon)
                .foregroundStyle(macro.color)
                .frame(width: 24)
            Text(macro.title)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
            Text(macro.unit)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)
        }
    }

    private func load() {
        guard let m = existing else { return }
        name = m.name
        calories = NumberText.format(m.calories)
        protein = NumberText.format(m.protein)
        carbs = NumberText.format(m.carbs)
        fat = NumberText.format(m.fat)
    }

    private func save() {
        var meal = existing ?? Meal(name: "", calories: 0, protein: 0, carbs: 0, fat: 0, date: mealDate())
        meal.name = name.trimmingCharacters(in: .whitespaces)
        meal.calories = NumberText.parse(calories) ?? 0
        meal.protein = NumberText.parse(protein) ?? 0
        meal.carbs = NumberText.parse(carbs) ?? 0
        meal.fat = NumberText.parse(fat) ?? 0
        store.upsert(meal)
        dismiss()
    }

    /// The selected day combined with the current time of day.
    private func mealDate() -> Date {
        let cal = Calendar.current
        if cal.isDateInToday(day) { return Date() }
        let time = cal.dateComponents([.hour, .minute], from: Date())
        return cal.date(bySettingHour: time.hour ?? 12, minute: time.minute ?? 0, second: 0, of: day) ?? day
    }
}
