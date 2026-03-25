//
//  CustomSlider.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/20.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let knobX = max(0, min(width, progress * width))
            
            ZStack (alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 8)
                
                Capsule()
                    .fill(
                        LinearGradient(colors: [Color.mint, Color.cyan],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: knobX, height: 8)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(colors: [Color.mint, Color.cyan],
                                                   startPoint: .leading, endPoint: .trailing),
                            lineWidth: 3)
                    )
                    .shadow(color: Color.mint.opacity(0.5), radius: 8)
                    .offset(x: knobX - 12, y: -8)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let x = max(0, min(width, gesture.location.x))
                                let percent = x / width
                                let newValue = range.lowerBound + Double(percent) * (range.upperBound - range.lowerBound)
                                let snapped = (((newValue - range.lowerBound) / step).rounded() * step) + range.lowerBound
                                let clamped = min(max(snapped, range.lowerBound), range.upperBound)
                                value = clamped
                            }
                    )
            }
        }
        .frame(height: 24)
    }
}

#Preview {
    CustomSlider(value: .constant(5000), range: 2000...10000, step: 100)
}
