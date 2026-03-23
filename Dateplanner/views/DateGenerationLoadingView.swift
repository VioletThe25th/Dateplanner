//
//  DateGenerationLoadingView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import SwiftUI

struct DateGenerationLoadingView: View {
    
    @State private var animateGradient = false
    @State private var animateDots = 0
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            
            // Animated background
            LinearGradient(
                colors: [
                    Color.black,
                    Color.purple.opacity(0.7),
                    Color.blue.opacity(0.6),
                    Color.black
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateGradient)
            
            // Floating blur circles
            Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 120)
                .offset(x: animateGradient ? -150 : 150, y: -200)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateGradient)
            
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 250, height: 250)
                .blur(radius: 120)
                .offset(x: animateGradient ? 150 : -150, y: 200)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateGradient)
            
            VStack(spacing: 24) {
                
                Spacer()
                
                // Title
                Text("Planning your perfect date")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 10)
                    .animation(.easeOut(duration: 0.8), value: showContent)
                
                // Animated dots
                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundColor(.white.opacity(0.8))
                            .scaleEffect(animateDots == index ? 1.4 : 1)
                            .opacity(animateDots == index ? 1 : 0.4)
                            .animation(.easeInOut(duration: 0.4), value: animateDots)
                    }
                }
                
                // Subtitle
                Text("Finding the best places around you")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 1.2), value: showContent)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            animateGradient = true
            showContent = true
            
            // Dot animation loop
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                animateDots = (animateDots + 1) % 3
            }
        }
    }
}

#Preview {
    DateGenerationLoadingView()
}
