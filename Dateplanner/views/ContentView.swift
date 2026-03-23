//
//  ContentView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/19.
//

import SwiftUI

struct ContentView: View {
    private let highlights: [(icon: String, title: String, subtitle: String)] = [
        ("sparkles", "AI-crafted", "A date flow built around your vibe."),
        ("mappin.circle.fill", "Nearby places", "Smart location picks around your area."),
        ("heart.circle.fill", "Personal touch", "Budget, mood, and your own ideas included.")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        heroHeaderSection
                        heroCard
                        highlightsSection
                        calloutSection
                    }
                    .frame(maxWidth: 560)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .padding(.bottom, 132)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomCTA
                    .frame(maxWidth: 560)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }

    private var heroHeaderSection: some View {
        VStack(spacing: 16) {
            Text("AI Date Planner")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.80))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            VStack(spacing: 10) {
                Text("Plan a date that")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("actually feels right")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .multilineTextAlignment(.center)

            Text("Tell us your mood, budget, and area. We’ll turn that into a smooth, personalized date plan in seconds.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.66))
                .frame(maxWidth: 340)
        }
        .frame(maxWidth: .infinity)
    }

    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .background(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.ultraThinMaterial)
                )

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)

            ZStack {
                Image("96AEDA19-ED5D-4732-B56E-81037AFBF7EB")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.12),
                        Color.black.opacity(0.30),
                        Color.black.opacity(0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RadialGradient(
                    colors: [
                        Color.cyan.opacity(0.24),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 180
                )

                RadialGradient(
                    colors: [
                        Color.pink.opacity(0.18),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: 170
                )

                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top) {
                        floatingBadge(icon: "sparkles", text: "AI suggestions")

                        Spacer()

                        floatingBadge(icon: "clock.fill", text: "Ready in seconds")
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("From mood to route")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.92))

                        Text("Find nearby spots, balance the vibe, and build a date plan with a natural rhythm.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.68))
                            .frame(maxWidth: 260, alignment: .leading)

                        HStack(spacing: 8) {
                            featurePill(icon: "mappin.and.ellipse", text: "Local picks")
                            featurePill(icon: "heart.text.square.fill", text: "Personalized")
                        }
                    }
                }
                .padding(22)
            }
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        }
        .aspectRatio(1.18, contentMode: .fit)
        .shadow(color: .black.opacity(0.22), radius: 24, x: 0, y: 16)
    }

    private var highlightsSection: some View {
        VStack(spacing: 14) {
            ForEach(Array(highlights.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 46, height: 46)

                        Image(systemName: item.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.90))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)

                        Text(item.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Circle()
                        .fill(index == 0 ? Color.cyan.opacity(0.90) : index == 1 ? Color.pink.opacity(0.82) : Color.orange.opacity(0.82))
                        .frame(width: 8, height: 8)
                        .shadow(color: .white.opacity(0.18), radius: 5, x: 0, y: 0)
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
                .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 8)
            }
        }
    }

    private var calloutSection: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.92), Color.blue.opacity(0.74)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)

                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Built for smooth date flow")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("Not just random places. The app tries to create a route that feels easy and coherent.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var bottomCTA: some View {
        VStack(spacing: 10) {
            NavigationLink {
                DatePickerView()
            } label: {
                HStack(spacing: 12) {
                    Text("Start planning")
                        .font(.headline.weight(.semibold))

                    Image(systemName: "arrow.right")
                        .font(.headline.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .foregroundStyle(.black.opacity(0.92))
                .background(
                    Color.white,
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(PressScaleStyle())

            Text("Mood, budget, location. We handle the rest.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.52))
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func floatingBadge(icon: String, text: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white.opacity(0.88))
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func featurePill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white.opacity(0.76))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
