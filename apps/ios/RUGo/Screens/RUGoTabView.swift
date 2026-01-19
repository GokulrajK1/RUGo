//
//  ContentView.swift
//  RUGo
//
//  Created by Gokulraj Kumarassamy on 11/25/25.
//

import SwiftUI

struct RUGoTabView: View {
    
    var body: some View {
        
        TabView {
            
            CurrentTripView()
                .tabItem {
                    Image(systemName: SF.bus)
                }
                
                
        }
        .tint(.white)
        .toolbarBackground(.black, for: .tabBar)
        .toolbarBackground(Color.black, for: .tabBar)
        
    }
}


#Preview {
    RUGoTabView()
}
