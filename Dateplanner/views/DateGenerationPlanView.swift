//
//  DateGenerationPlanView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import SwiftUI

struct DateGenerationPlanView: View {
    let plan: GeneratedDatePlan
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    private var orderedStops: [GeneratedDateStop] {
        plan.stops.sorted { $0.order < $1.order }
    }

    private var totalEstimatedPrice: Int {
        orderedStops.compactMap { $0.estimatedPrice }.reduce(0, +)
    }

    private var estimatedDurationMinutes: Int {
        let stopsMinutes = orderedStops.reduce(0) { partialResult, stop in
            partialResult + estimatedMinutes(for: stop.category)
        }
        let transferMinutes = max(orderedStops.count - 1, 0) * 12
        return stopsMinutes + transferMinutes
    }

    private var estimatedDurationText: String {
        let totalMinutes = estimatedDurationMinutes
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 && minutes > 0 {
            return localization.text("plan.duration.hoursMinutes", hours, minutes)
        } else if hours > 0 {
            return localization.text("plan.duration.hoursOnly", hours)
        } else {
            return localization.text("plan.duration.minutesOnly", minutes)
        }
    }

    private var totalBudgetText: String {
        totalEstimatedPrice > 0 ? "¥\(totalEstimatedPrice)" : localization.text("common.flexible")
    }

    private var bodyContent: some View {
        GeometryReader { proxy in
            let horizontalPadding = proxy.size.width >= 768 ? 32.0 : 20.0

            ZStack {
                BackgroundView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        heroSection
                        statsSection
                        itinerarySection
                    }
                    .frame(maxWidth: 620)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            bodyContent
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.88))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .toolbarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.text("plan.title"))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.80))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(plan.title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(plan.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? localization.text("plan.defaultSummary") : plan.summary)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(title: localization.text("plan.stats.budget"), value: totalBudgetText, icon: "banknote.fill")
            statCard(title: localization.text("plan.stats.stops"), value: "\(orderedStops.count)", icon: "mappin.circle.fill")
            statCard(title: localization.text("plan.stats.duration"), value: estimatedDurationText, icon: "clock.fill")
        }
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.86))
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.10))
                )

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.54))

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var itinerarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(localization.text("plan.itinerary.title"))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                Text(localization.text("plan.itinerary.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.56))
            }

            VStack(spacing: 0) {
                ForEach(Array(orderedStops.enumerated()), id: \.offset) { index, stop in
                    VStack(spacing: 0) {
                        NavigationLink {
                            GeneratedStopDetailView(stop: stop)
                        } label: {
                            stopCard(for: stop, index: index)
                        }
                        .buttonStyle(StopCardPressStyle())

                        if index < orderedStops.count - 1 {
                            timelineConnector
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stopCard(for stop: GeneratedDateStop, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            stopImage(for: stop, index: index)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(stop.name)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        if let address = stop.address, !address.isEmpty {
                            Label(address, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.60))
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 8)

                    Text(localization.text("plan.stopFormat", index + 1))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.86))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.10))
                        )
                }

                Text(stop.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.80))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    if let estimatedPrice = stop.estimatedPrice {
                        infoPill(icon: "yensign.circle.fill", text: "\(estimatedPrice)")
                    }

                    if let category = stop.category {
                        infoPill(icon: iconName(for: category), text: displayName(for: category))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(localization.text("plan.whyThisStop"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.52))

                    Text(stop.reason)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.66))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )

                HStack(spacing: 8) {
                    Text(localization.text("plan.viewDetails"))
                        .font(.caption.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.white.opacity(0.62))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
    }

    private var timelineConnector: some View {
        HStack(spacing: 12) {
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.80), Color.blue.opacity(0.36)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 34)
                .overlay(
                    Circle()
                        .fill(Color.cyan.opacity(0.95))
                        .frame(width: 8, height: 8)
                        .blur(radius: 0.3)
                        .offset(y: 17)
                )

            Text(localization.text("plan.nextStop"))
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.42))

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.leading, 18)
    }

    private func stopImage(for stop: GeneratedDateStop, index: Int) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .topLeading) {
                stopImageContent(for: stop, width: width, height: height)

                HStack(spacing: 8) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.black.opacity(0.92))
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Color.white)
                        )

                    if let estimatedPrice = stop.estimatedPrice {
                        HStack(spacing: 4) {
                            Image(systemName: "yensign.circle.fill")
                            Text("\(estimatedPrice)")
                        }
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                    }
                }
                .padding(12)
            }
            .frame(width: width, height: height)
        }
        .frame(height: 194)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func stopImageContent(for stop: GeneratedDateStop, width: CGFloat, height: CGFloat) -> some View {
        Group {
            if let imageURL = stop.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage(for: stop, width: width, height: height)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                    case .failure:
                        placeholderImage(for: stop, width: width, height: height)
                    @unknown default:
                        placeholderImage(for: stop, width: width, height: height)
                    }
                }
            } else {
                placeholderImage(for: stop, width: width, height: height)
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }

    @ViewBuilder
    private func placeholderImage(for stop: GeneratedDateStop, width: CGFloat, height: CGFloat) -> some View {
        let category = stop.category?.lowercased() ?? ""
        let icon = iconName(for: category)
        let gradient = gradientColors(for: category)

        ZStack {
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 64, height: 64)
                .blur(radius: 0.4)

            Image(systemName: icon)
                .font(.title.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))
        }
        .frame(width: width, height: height)
    }

    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.72))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }

    private func estimatedMinutes(for category: String?) -> Int {
        let value = category?.lowercased() ?? ""

        if value.contains("aquarium") || value.contains("zoo") || value.contains("museum") || value.contains("amusement park") {
            return 80
        } else if value.contains("cinema") {
            return 120
        } else if value.contains("restaurant") || value.contains("romantic restaurant") || value.contains("izakaya") || value.contains("sushi") || value.contains("ramen") {
            return 75
        } else if value.contains("bar") || value.contains("wine") || value.contains("pub") || value.contains("casino") {
            return 70
        } else if value.contains("cafe") || value.contains("coffee") || value.contains("ice cream") || value.contains("bookstore") {
            return 50
        } else if value.contains("park") || value.contains("hiking") {
            return 45
        } else if value.contains("karaoke") || value.contains("bowling") || value.contains("arcade") || value.contains("activity") {
            return 70
        } else {
            return 60
        }
    }

    private func displayName(for category: String) -> String {
        category
            .split(separator: " ")
            .map { word in
                word.prefix(1).uppercased() + word.dropFirst().lowercased()
            }
            .joined(separator: " ")
    }

    private func iconName(for category: String) -> String {
        let value = category.lowercased()

        if value.contains("aquarium") {
            return "fish.fill"
        } else if value.contains("romantic restaurant") || value.contains("restaurant") || value.contains("izakaya") || value.contains("ramen") || value.contains("sushi") {
            return "fork.knife"
        } else if value.contains("cafe") || value.contains("coffee") {
            return "cup.and.saucer.fill"
        } else if value.contains("bar") || value.contains("wine") || value.contains("pub") {
            return "wineglass.fill"
        } else if value.contains("museum") {
            return "building.columns.fill"
        } else if value.contains("karaoke") {
            return "music.mic"
        } else if value.contains("park") || value.contains("hiking") {
            return "leaf.fill"
        } else if value.contains("bookstore") {
            return "book.fill"
        } else if value.contains("ice cream") {
            return "snowflake"
        } else if value.contains("cinema") {
            return "film.fill"
        } else if value.contains("arcade") || value.contains("bowling") || value.contains("activity") {
            return "sparkles"
        } else if value.contains("amusement park") {
            return "ferris.wheel"
        } else if value.contains("zoo") {
            return "tortoise.fill"
        } else if value.contains("casino") {
            return "suit.spade.fill"
        } else {
            return "mappin.circle.fill"
        }
    }

    private func gradientColors(for category: String) -> [Color] {
        let value = category.lowercased()

        if value.contains("aquarium") {
            return [Color.cyan.opacity(0.95), Color.blue.opacity(0.75)]
        } else if value.contains("romantic restaurant") || value.contains("restaurant") || value.contains("izakaya") || value.contains("sushi") || value.contains("ramen") {
            return [Color.orange.opacity(0.95), Color.red.opacity(0.70)]
        } else if value.contains("cafe") || value.contains("coffee") {
            return [Color.brown.opacity(0.85), Color.orange.opacity(0.55)]
        } else if value.contains("bar") || value.contains("wine") || value.contains("pub") {
            return [Color.purple.opacity(0.85), Color.pink.opacity(0.65)]
        } else if value.contains("museum") {
            return [Color.indigo.opacity(0.85), Color.blue.opacity(0.62)]
        } else if value.contains("park") || value.contains("hiking") {
            return [Color.green.opacity(0.85), Color.mint.opacity(0.62)]
        } else if value.contains("bookstore") {
            return [Color.teal.opacity(0.78), Color.indigo.opacity(0.58)]
        } else if value.contains("ice cream") {
            return [Color.pink.opacity(0.88), Color.orange.opacity(0.58)]
        } else if value.contains("cinema") {
            return [Color.indigo.opacity(0.90), Color.purple.opacity(0.68)]
        } else if value.contains("arcade") || value.contains("bowling") || value.contains("activity") {
            return [Color.blue.opacity(0.78), Color.purple.opacity(0.58)]
        } else if value.contains("amusement park") {
            return [Color.pink.opacity(0.90), Color.purple.opacity(0.66)]
        } else if value.contains("zoo") {
            return [Color.green.opacity(0.82), Color.yellow.opacity(0.52)]
        } else if value.contains("casino") {
            return [Color.red.opacity(0.82), Color.black.opacity(0.72)]
        } else {
            return [Color.blue.opacity(0.78), Color.purple.opacity(0.58)]
        }
    }
}

private struct StopCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .saturation(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

#Preview {
    DateGenerationPlanView(
        plan: GeneratedDatePlan(
            title: "Romantic night in Shibuya",
            summary: "A calm and romantic evening with soft transitions between each stop.",
            stops: [
                GeneratedDateStop(
                    name: "Aquarium Tokyo",
                    description: "Start with a calm visit to enjoy an enchanting underwater world.",
                    order: 1,
                    reason: "A gentle first stop that makes the date feel special right away",
                    imageURL: nil,
                    category: "aquarium",
                    address: "Shibuya",
                    latitude: 35.66,
                    longitude: 139.70,
                    estimatedPrice: 400
                ),
                GeneratedDateStop(
                    name: "Sushi Bar UMAI",
                    description: "Enjoy a relaxed dinner together in a cozy atmosphere.",
                    order: 2,
                    reason: "A warm dinner stop to keep the date intimate and memorable",
                    imageURL: nil,
                    category: "restaurant",
                    address: "Shibuya",
                    latitude: 35.65,
                    longitude: 139.71,
                    estimatedPrice: 4400
                ),
                GeneratedDateStop(
                    name: "Night Walk",
                    description: "Finish with a short walk and talk through the city lights.",
                    order: 3,
                    reason: "A smooth ending that feels romantic without rushing",
                    imageURL: nil,
                    category: "park",
                    address: "Shibuya",
                    latitude: 35.651,
                    longitude: 139.709,
                    estimatedPrice: 0
                )
            ]
        )
    )
    .environmentObject(LocalizationManager.preview)
}
