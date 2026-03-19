//
//  ContentView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/19.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Plan the")
                    .font(.largeTitle)
                    .frame(alignment: .center)
                    .bold()
                    .foregroundStyle(.white)
                Text("perfect date")
                    .font(.largeTitle)
                    .frame(alignment: .center)
                    .bold()
                    .foregroundStyle(.white)
                Text("AI Build it for you in second")
                    .font(.default)
                    .foregroundStyle(.gray)
                Spacer()
                
                NavigationLink {
                    DatePickerView()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                        .background(
                            .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                        )
                }
                .buttonStyle(PressScaleStyle())
                
            }
            .padding()
            .background() {
                Image("pexels-cottonbro-4691222")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
        }
    }
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
