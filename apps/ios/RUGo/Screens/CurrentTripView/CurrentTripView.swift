//
//  CurrentTripView.swift
//  RUGo
//
//  Created by Gokulraj Kumarassamy on 11/27/25.
//

import SwiftUI

struct CurrentTripView: View {

    private let mainVStackSpacing: CGFloat = 20

    var body: some View {
        
            ZStack {
        
                Color.black.ignoresSafeArea()

                VStack(spacing: mainVStackSpacing) {
                
                    Text("Your Current Trip")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                

                    TripInfoView()
                
                    UpcomingBusesView()
                    
                }
                .padding()
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
        
    }
}

struct TripInfoView: View {
    var body: some View {

        VStack(spacing: 20) {
            HStack(spacing: 15) {
                Text("Intro to Linear Algebra")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .bold()

                Text("Tillet Hall")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            HStack(spacing: 8) {
                Text("From")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.trailing, 3)

                Text("Livingston Student Center")
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.white.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))

            HStack(spacing: 8) {
                Text("To     ")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.trailing, 3)

                Text("College Avenue Student Center")
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.white.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))

            HStack(spacing: 30) {

                Circle()
                    .fill(Color.darkRed)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "map")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    )

                Circle()
                    .fill(Color.darkRed)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    )

                Circle()
                    .fill(Color.darkRed)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    )

                Circle()
                    .fill(Color.darkRed)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding()
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}



struct UpcomingBusesView: View {

    var body: some View {
        VStack {
            
            Text("Upcoming Buses (6)")
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)

            ScrollView(.vertical, showsIndicators: true) {
                ForEach(0..<6) { _ in
                    BusInfoView()
                }
            }
        }
        .padding()
        .background(.darkGray)
        .clipShape(RoundedRectangle(cornerRadius: K.backgroundTileCornerRadius, style: .continuous))
    }
}


struct BusInfoView: View {

    var body: some View {

        HStack {

            Circle()
                .fill(.darkRed)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("LX")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading) {

                Text("Arrives in 6 mins")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)

                Text("Dest. ETA: 12:45 AM")
                    .foregroundColor(.white.opacity(0.75))
                    .font(.caption)
            }

            Spacer()

            ZStack {

                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 5)

                Circle().trim(from: 0, to: 0.60)
                    .stroke(.darkRed,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("60%")
                    .foregroundColor(.white)
                    .font(.caption2)

            }
            .frame(width: 35, height: 35)
         
        }
        .padding(10)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: K.backgroundTileCornerRadius, style: .continuous))
        .padding(.vertical, 5)
    }
}

#Preview {
    CurrentTripView()
}
