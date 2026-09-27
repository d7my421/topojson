import SwiftUI

/// Edit the daily targets.
struct GoalsView: View {
    @EnvironmentObject private var store: MealStore
    @Environment(\.dismiss) private var dismiss

    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    private var macroCalories: Double {
        (NumberText.parse(protein) ?? 0) * 4
            + (NumberText.parse(carbs) ?? 0) * 4
            + (NumberText.parse(fat) ?? 0) * 9
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    field(.calories, text: $calories)
                    field(.protein, text: $protein)
                    field(.carbs, text: $carbs)
                    field(.fat, text: $fat)
                } header: {
                    Text("المستهدف اليومي")
                } footer: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("مجموع سعرات الماكروز: \(NumberText.format(macroCalories.rounded()))")
                        if macroCalories > 0 {
                            Button("استخدم هذا الرقم كمستهدف للسعرات") {
                                calories = NumberText.format(macroCalories.rounded())
                            }
                        }
                    }
                    .font(.footnote)
                }
            }
            .navigationTitle("الأهداف")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") { save() }.fontWeight(.bold)
                }
            }
            .onAppear {
                let g = store.goals
                calories = NumberText.format(g.calories)
                protein = NumberText.format(g.protein)
                carbs = NumberText.format(g.carbs)
                fat = NumberText.format(g.fat)
            }
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

    private func save() {
        var g = store.goals
        g.calories = NumberText.parse(calories) ?? g.calories
        g.protein = NumberText.parse(protein) ?? g.protein
        g.carbs = NumberText.parse(carbs) ?? g.carbs
        g.fat = NumberText.parse(fat) ?? g.fat
        store.goals = g
        dismiss()
    }
}
