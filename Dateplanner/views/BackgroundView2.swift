//
//  BackgroundView2.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/22.
//

import SwiftUI

struct BackgroundView2: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 10/255, green: 14/255, blue: 24/255),
                Color(red: 20/255, green: 22/255, blue: 35/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        RadialGradient(
            colors: [
                Color.gray.opacity(0.1),
                Color.clear
            ],
            center: .top,
            startRadius: 0,
            endRadius: 400
        )
        .ignoresSafeArea()

        RadialGradient(
            colors: [
                Color.purple.opacity(0.1),
                Color.clear
            ],
            center: .top,
            startRadius: 0,
            endRadius: 200
        )
        .blur(radius: 35)
        .offset(x: 50)
        .ignoresSafeArea()

        RadialGradient(
            colors: [
                Color.red.opacity(0.1),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: 200
        )
        .blur(radius: 35)
        .offset(x: -50)
        .ignoresSafeArea()

        RadialGradient(
            colors: [
                Color.blue.opacity(0.1),
                Color.clear
            ],
            center: .bottom,
            startRadius: 0,
            endRadius: 200
        )
        .blur(radius: 35)
        .offset(x: 50)
        .ignoresSafeArea()
    }
}
