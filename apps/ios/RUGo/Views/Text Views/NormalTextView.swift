//
//  NormalTextView.swift
//  RUGo
//
//  Created by Gokulraj Kumarassamy on 2/2/26.
//

import SwiftUI


struct NormalTextView : View {
        
    let text : String
    let color : Color
    var fontWeight : Font.Weight? = nil
    
    var body : some View {
        
        Text(text)
            .font(.subheadline)
            .fontWeight(fontWeight)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
}
