//
//  DatePickerView.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/20.
//

import SwiftUI

struct DatePickerView: View {
    @State private var budget: Double = 5000
    
    var body: some View {
        NavigationStack {
            ZStack {
                /// Background
                LinearGradient(
                    colors: [Color(red: 12/255, green: 12/255, blue: 14/255),
                             Color(red: 22/255, green: 22/255, blue: 26/255)],
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
                .offset(x: 50   )
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
                
                /// Main view
                VStack (alignment: .leading){
                    
                    /// Title view
                    HStack {
                        Text("Create your date")
                            .font(.largeTitle)
                            .bold()
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    HStack {
                        Text("What are you in the mood for? ")
                        Image(systemName: "smallcircle.circle.fill")
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    
                    /// Budget view
                    VStack {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundStyle(Color.yellow.opacity(0.8))
                            Text("Budget")
                                .font(.title)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("¥\(Int(budget))")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.6))
                        
                        CustomSlider(value: $budget, range: 2000...10000)
                        
                        HStack {
                            Text("2000¥")
                            Spacer()
                            Text("10000¥")
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
                    )
                    
                    
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        OptionsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title)
                    }
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
    }
}

#Preview {
    DatePickerView()
}
