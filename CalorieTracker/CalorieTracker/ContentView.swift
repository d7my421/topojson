import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: MealStore

    @State private var selectedDay = Date()
    @State private var showingAdd = false
    @State private var editingMeal: Meal?
    @State private var showingGoals = false

    private var isToday: Bool { Calendar.current.isDateInToday(selectedDay) }

    var body: some View {
        let totals = store.totals(on: selectedDay)
        let meals = store.meals(on: selectedDay)

        NavigationStack {
            List {
                Section {
                    daySelector
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())

                    CaloriesCard(consumed: totals.calories, goal: store.goals.calories)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))

                    HStack(spacing: 10) {
                        ForEach([Macro.protein, .carbs, .fat]) { macro in
                            MacroCard(
                                macro: macro,
                                consumed: macro.value(in: totals),
                                goal: macro.value(in: store.goals)
                            )
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                }
                .listRowSeparator(.hidden)

                Section {
                    if meals.isEmpty {
                        emptyState
                    } else {
                        ForEach(meals) { meal in
                            Button { editingMeal = meal } label: {
                                MealRow(meal: meal)
                            }
                            .buttonStyle(.plain)
                            .swipeActions {
                                Button(role: .destructive) {
                                    withAnimation { store.delete(meal) }
                                } label: {
                                    Label("حذف", systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("الوجبات")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Spacer()
                        if !meals.isEmpty {
                            Text("\(meals.count) وجبة")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .textCase(nil)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("سعراتي")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingGoals = true } label: {
                        Image(systemName: "target")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) { addButton }
            .sheet(isPresented: $showingAdd) {
                MealFormView(day: selectedDay)
            }
            .sheet(item: $editingMeal) { meal in
                MealFormView(day: selectedDay, existing: meal)
            }
            .sheet(isPresented: $showingGoals) {
                GoalsView()
            }
        }
    }

    // MARK: - Subviews

    private var daySelector: some View {
        HStack {
            Button { shiftDay(-1) } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.title2)
            }
            Spacer()
            VStack(spacing: 2) {
                Group {
                    if isToday {
                        Text("اليوم")
                    } else {
                        Text(selectedDay, format: .dateTime.weekday(.wide))
                    }
                }
                .font(.headline)
                Text(selectedDay, format: .dateTime.day().month(.wide))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .onTapGesture { selectedDay = Date() }
            Spacer()
            Button { shiftDay(1) } label: {
                Image(systemName: "chevron.forward.circle.fill")
                    .font(.title2)
            }
            .disabled(isToday)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Macro.calories.color)
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Macro.calories.color.opacity(0.7))
            Text("لا توجد وجبات بعد")
                .font(.headline)
            Text("اضغط على زر ＋ لإضافة وجبتك الأولى")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var addButton: some View {
        Button { showingAdd = true } label: {
            Label("إضافة وجبة", systemImage: "plus")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Macro.calories.color, Macro.protein.color],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .shadow(color: Macro.calories.color.opacity(0.4), radius: 10, y: 5)
        }
        .padding(.bottom, 8)
    }

    private func shiftDay(_ days: Int) {
        if let d = Calendar.current.date(byAdding: .day, value: days, to: selectedDay) {
            withAnimation { selectedDay = d }
        }
    }
}

struct MealRow: View {
    var meal: Meal

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Macro.calories.color.opacity(0.15))
                Image(systemName: "fork.knife")
                    .foregroundStyle(Macro.calories.color)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(meal.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(meal.date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 10) {
                    chip(.calories, meal.calories)
                    chip(.protein, meal.protein)
                    chip(.carbs, meal.carbs)
                    chip(.fat, meal.fat)
                }
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private func chip(_ macro: Macro, _ value: Double) -> some View {
        HStack(spacing: 3) {
            Image(systemName: macro.icon)
                .font(.caption2)
            Text(NumberText.format(value))
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(macro.color)
    }
}

#Preview {
    ContentView()
        .environmentObject(MealStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
