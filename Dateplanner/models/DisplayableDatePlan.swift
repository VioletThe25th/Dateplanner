//
//  DisplayableDatePlan.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/22.
//

import UIKit

struct DisplayableDateStop: Identifiable {
    let id = UUID()
    let stop: GeneratedDateStop
    let image: UIImage?
}

struct DisplayableDatePlan: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let stops: [DisplayableDateStop]
}
