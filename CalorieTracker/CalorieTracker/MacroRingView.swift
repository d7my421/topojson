import SwiftUI

/// A circular progress ring.
struct RingView: View {
    var progress: Double
    var color: Color
    var lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.7), color],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
    }
}

/// Large card for the calories target.
struct CaloriesCard: View {
    var consumed: Double
    var goal: Double

    private var progress: Double { goal > 0 ? consumed / goal : 0 }
    private var remaining: Double { goal - consumed }

    var body: some View {
        let macro = Macro.calories
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Label(macro.title, systemImage: macro.icon)
                    .font(.headline)
                    .foregroundStyle(macro.color)
                Text(NumberText.format(consumed))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("من \(NumberText.format(goal)) \(macro.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(remaining >= 0
                     ? "متبقي \(NumberText.format(remaining))"
                     : "تجاوزت بـ \(NumberText.format(-remaining))")
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(macro.color.opacity(0.15), in: Capsule())
                    .foregroundStyle(remaining >= 0 ? macro.color : .red)
            }
            Spacer()
            ZStack {
                RingView(progress: progress, color: macro.color, lineWidth: 14)
                VStack(spacing: 0) {
                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Image(systemName: macro.icon)
                        .foregroundStyle(macro.color)
                }
            }
            .frame(width: 120, height: 120)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [macro.color.opacity(0.12), Color(.secondarySystemGroupedBackground)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }
}

/// Small card for protein / carbs / fat.
struct MacroCard: View {
    var macro: Macro
    var consumed: Double
    var goal: Double

    private var progress: Double { goal > 0 ? consumed / goal : 0 }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RingView(progress: progress, color: macro.color, lineWidth: 9)
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .frame(width: 76, height: 76)

            Label(macro.title, systemImage: macro.icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(macro.color)
                .labelStyle(.titleAndIcon)

            Text("\(NumberText.format(consumed)) / \(NumberText.format(goal)) \(macro.unit)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 6)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}
