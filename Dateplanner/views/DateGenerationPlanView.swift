//
//  DateGenerationPlanView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import SwiftUI

struct DateGenerationPlanView: View {
    let plan: GeneratedDatePlan
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
            return "\(hours) h \(minutes) min"
        } else if hours > 0 {
            return "\(hours) h"
        } else {
            return "\(minutes) min"
        }
    }
    
    private var metadataSummary: String {
        let priceText = totalEstimatedPrice > 0 ? "¥\(totalEstimatedPrice)" : "Flexible budget"
        return "\(priceText) · \(orderedStops.count) stops · \(estimatedDurationText)"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView2()
                    .ignoresSafeArea()
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        headerSection
                        stopsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 32)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.92))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Spacer(minLength: 8)
            
            Text(plan.title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 4)
            
            Text(metadataSummary)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.80))
                .padding(.horizontal, 8)
            
            if !plan.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               plan.summary != metadataSummary {
                Text(plan.summary)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.66))
                    .padding(.horizontal, 14)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var stopsSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(orderedStops.enumerated()), id: \.offset) { index, stop in
                VStack(spacing: 0) {
                    stopCard(for: stop, index: index)
                    
                    if index < orderedStops.count - 1 {
                        timelineConnector
                    }
                }
            }
        }
    }
    
    private func stopCard(for stop: GeneratedDateStop, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                stopImage(for: stop)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(stop.name)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            
                            if let address = stop.address {
                                Label(address, systemImage: "mappin.and.ellipse")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.62))
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer(minLength: 8)
                        
                        Text("#\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.88))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.white.opacity(0.10))
                            )
                    }
                    
                    Text(stop.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(3)
                    
                    HStack(spacing: 10) {
                        if let estimatedPrice = stop.estimatedPrice {
                            infoPill(icon: "yensign.circle.fill", text: "\(estimatedPrice)")
                        }
                        
                        if let category = stop.category {
                            infoPill(icon: iconName(for: category), text: displayName(for: category))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
            }
            
            Text(stop.reason)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.62))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
    }
    
    private var timelineConnector: some View {
        VStack(spacing: 0) {
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.75), Color.blue.opacity(0.38)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 34)
                .overlay(
                    Circle()
                        .fill(Color.cyan.opacity(0.95))
                        .frame(width: 8, height: 8)
                        .blur(radius: 0.4)
                        .offset(y: 17)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private func stopImage(for stop: GeneratedDateStop) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let imageURL = stop.imageURL,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage(for: stop)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderImage(for: stop)
                    @unknown default:
                        placeholderImage(for: stop)
                    }
                }
            } else {
                placeholderImage(for: stop)
            }
            
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
                .padding(8)
            }
        }
        .frame(width: 102, height: 118)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func placeholderImage(for stop: GeneratedDateStop) -> some View {
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
                .frame(width: 54, height: 54)
                .blur(radius: 0.4)
            
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))
        }
    }
    
    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.72))
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
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
}
