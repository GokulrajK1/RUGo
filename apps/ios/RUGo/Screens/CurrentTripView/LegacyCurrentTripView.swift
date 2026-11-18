//
//  CurrentTripView.swift
//  RUGo
//
//  Created by Gokulraj Kumarassamy on 11/27/25.
//

import SwiftUI
import MapKit

struct LegacyCurrentTripView: View {

    private let titleViewText : String = "Your Current Trip"
    
    private let mainVStackSpacing: CGFloat = 20
    
    var body: some View {
        
        ZStack {
    
            MainAppBackgroundView()
            
            VStack(spacing: mainVStackSpacing) {
                
                TitleTextView(text: titleViewText)
                
                TripInfoView()
            
                UpcomingBusesView()
                
            }
            .padding()
        }
        
    }
}

struct TripInfoView: View {
    
    private let mainVStackSpacing: CGFloat = 15
    private let actionPillButtonHStackSpacing : CGFloat = 20
    private let topPaddingBetweenDropdownsAndActionButtons : CGFloat = 5
    
    var body: some View {

        VStack(spacing: mainVStackSpacing) {
            
            SubtitleTextView(text: "Trip to Lucy Stone Hall")
            
            TripLocationDropDown(label: "From", value: "College Avenue Student Center")
            
            TripLocationDropDown(label: "To", value: "Livingston Student Center")
            
            HStack(spacing: actionPillButtonHStackSpacing){
                
                ActionPillButton(title: "Add", systemImage: SF.plus) {
                    
                }
                
                ActionPillButton(title: "Edit", systemImage: SF.pencil) {
                    
                }
                
                ActionPillButton(title: "Delete", systemImage: SF.trash) {
                    
                }
                
            }
            .padding(.top, topPaddingBetweenDropdownsAndActionButtons)
           
        }
        .padding()
        .background {
            BackgroundCardView()
        }
    }
}



struct UpcomingBusesView : View {
    
    private let mainVStackSpacing : CGFloat = 15
    private let busListSpacing : CGFloat = 20
    private let busListAndActionPillButtonTopSpacing : CGFloat = 5
    private let actionPillButtonHStackSpacing : CGFloat = 20

    var body: some View {
        
        VStack(spacing: mainVStackSpacing) {

            SubtitleTextView(text: "Upcoming Buses (4)")
             

            ScrollView {
                
                VStack(spacing: busListSpacing) {
                    
                    ForEach(0..<4) { _ in
                        BusInfoView()
                            
                    }
                }
                
            }
            
            HStack (spacing: actionPillButtonHStackSpacing){
                
                ActionPillButton(title: "View Details", systemImage: SF.infoCircle) {
                    
                }
                
                ActionPillButton(title: "View Stops", systemImage: SF.route) {
                    
                }
                
            }
            .padding(.top, busListAndActionPillButtonTopSpacing)
            
        }
        .padding()
        .background {
            BackgroundCardView()
        }
    }
}


struct BusInfoView: View {
    
    private let verticalPadding : CGFloat = 8
    private let horizontalPadding : CGFloat = 10
    
    var accentColor : Color = .red1
    var backgroundColor : Color = .gray3
    

    var body: some View {

        HStack {
            
            RouteCircleView(text: "LX", foregroundColor: .white, backgroundColor: accentColor)
                .padding(.trailing, 5)

            VStack(alignment: .leading) {
                
                NormalTextView(text: "Arrives in 15 mins", color: .white, fontWeight: .semibold)

                NormalTextView(text: "Destination ETA: 12:45 AM", color: .white, fontWeight: .light)

                NormalTextView(text: "Bus #1005", color: .gray1, fontWeight: .thin)
            }

            Spacer()
            
            PaxLoadRingView(accentColor: accentColor, backgroundColor: .gray2)
         
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .background {
            BackgroundCardView(color: backgroundColor)
        }

    }
}

struct TripLocationDropDown: View {
    
    private let labelWidth : CGFloat = 40
    private let verticalPadding : CGFloat = 7
    private let horizontalPadding : CGFloat = 10

    let label: String
    let value: String
    
    var labelForegroundColor : Color = .gray1
    var valueForegroundColor : Color = .white
    var backgroundColor : Color = .gray3

    var body: some View {
        
        HStack() {
            
            NormalTextView(text: label, color: labelForegroundColor, fontWeight: .none)
                .frame(width: labelWidth, alignment: .leading)
            
            NormalTextView(text: value, color: valueForegroundColor)

            Spacer()

            Image(systemName: SF.chevronDown)
                .foregroundColor(labelForegroundColor)
                .font(.footnote)
                .bold()
            
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .background(backgroundColor)
        .clipShape(.capsule)
    }
}

struct ActionPillButton : View {
    
    private let spacing : CGFloat = 7
    private let verticalPadding : CGFloat = 5
    private let horizontalPadding : CGFloat = 10
    
    let title: String
    let systemImage: String
    
    var foregroundColor : Color = .white
    var backgroundColor : Color = .red1
    var action: () -> Void
    
    var body : some View {
        
        Button(action: action) {
            
            HStack (spacing: spacing) {
                
                Image(systemName: systemImage)
                    .foregroundStyle(foregroundColor)
                    .font(.caption)
                    .bold()
                
                NormalTextView(text: title, color: foregroundColor, fontWeight: .bold)
                
                
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundColor)
            .clipShape(Capsule())
            
        }
        
    }
    
}

struct RouteCircleView : View {
    
    var text : String
    var foregroundColor : Color
    var backgroundColor : Color
    
    var radius : CGFloat = 45
    
    var body : some View {
        
        ZStack {
            
            Circle()
                .fill(backgroundColor)
            
            SubtitleTextView(text: text, foregroundColor: foregroundColor, fontWeight: .bold)
                
            
        }
        .frame(width: radius, height: radius)
        
    }
}

struct PaxLoadRingView : View {
    
    var accentColor : Color
    var backgroundColor : Color
    
    var foregroundColor : Color = .white
    var ringWidth : CGFloat = 5
    var radius : CGFloat = 45
    
    var body : some View {
        
        ZStack {

            Circle()
                .stroke(backgroundColor, lineWidth: ringWidth)

            Circle().trim(from: 0, to: 0.60)
                .stroke(accentColor, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            NormalTextView(text: "60%", color: foregroundColor)

        }
        .frame(width: radius, height: radius)
        
    }
    
}








#Preview {
    LegacyCurrentTripView()
}
