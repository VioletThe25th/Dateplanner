//
//  OptionsView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/20.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    headerSection
                    languageSection
                    currencySection
                    launchSection
                }
                .frame(maxWidth: 620)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.text("options.title"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(localization.text("options.subtitle"))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.62))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: localization.text("options.language.title"),
                subtitle: localization.text("options.language.subtitle")
            )

            VStack(spacing: 12) {
                currentLanguageCard

                ForEach(AppLanguage.allCases) { language in
                    languageCard(for: language)
                }
            }
        }
        .cardBackground()
    }

    private var currentLanguageCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(localization.text("options.language.current"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.48))

                Text(localization.language.nativeName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)

            Text(localization.language.languageCodeLabel)
                .font(.caption.weight(.bold))
                .foregroundStyle(.black.opacity(0.90))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white)
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func languageCard(for language: AppLanguage) -> some View {
        let isSelected = localization.language == language

        return Button {
            localization.setLanguage(language)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.08))
                        .frame(width: 38, height: 38)

                    Image(systemName: isSelected ? "checkmark" : "globe")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.92) : Color.white.opacity(0.88))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(language.nativeName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(language.languageCodeLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.14) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(isSelected ? 0.16 : 0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var launchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: localization.text("options.launch.title"),
                subtitle: localization.text("options.launch.subtitle")
            )
        }
        .cardBackground()
    }

    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: localization.text("options.currency.title"),
                subtitle: localization.text("options.currency.subtitle")
            )

            VStack(spacing: 12) {
                currentCurrencyCard

                ForEach(CurrencyOption.allCases) { currency in
                    currencyCard(for: currency)
                }
            }
        }
        .cardBackground()
    }

    private var currentCurrencyCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "banknote")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(localization.text("options.currency.current"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.48))

                Text(currencyManager.currency.displayName(localeIdentifier: localization.language.localeIdentifier))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)

            Text("\(currencyManager.currency.symbol) \(currencyManager.currency.code)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.black.opacity(0.90))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white)
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func currencyCard(for currency: CurrencyOption) -> some View {
        let isSelected = currencyManager.currency == currency

        return Button {
            currencyManager.setCurrency(currency)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.08))
                        .frame(width: 38, height: 38)

                    Text(currency.symbol)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isSelected ? Color.black.opacity(0.92) : Color.white.opacity(0.88))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(currency.displayName(localeIdentifier: localization.language.localeIdentifier))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(currency.code)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.14) : Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(isSelected ? 0.16 : 0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.60))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        OptionsView()
            .environmentObject(LocalizationManager.preview)
            .environmentObject(CurrencyManager.preview)
    }
}
