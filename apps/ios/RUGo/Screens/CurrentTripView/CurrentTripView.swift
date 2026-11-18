// ==============================
//  Current2.swift
//  RUGo
//  Lightweight + lag-reduced version
//  - Uses .sheet(item:) so first tap never shows "No bus selected"
//  - Defers Map creation (showMap) to let sheet animation finish
//  - Forces non-zero map size (minHeight) to avoid CAMetalLayer 0x0 issues
//  - Uses elevation: .flat for lighter rendering
// ==============================

import SwiftUI
import MapKit
import CoreLocation
import Combine
import UIKit

struct CurrentTripView: View {
    
    private let mainVStackSpacing : CGFloat = 15

    @State private var selectedBusID: UUID? = nil
    @State private var selectedBusForMap: UpcomingBusesCard.Bus? = nil

    var body: some View {
        ZStack {
            
            MainAppBackgroundView()

            VStack(spacing: mainVStackSpacing) {
               
                MainHeaderView(headerTitle: "Your Current Trip", headerSubtitle: "View live bus updates and information")

                TripDetailsView(
                    buildingName: "Trip to Lucy Stone Hall",
                    campusName: "Livingston",
                    tripName: "Intro to Linear Algebra",
                    from: "College Avenue Student Center",
                    to: "Livingston Student Center",
                    timeWindowText: "10:20 AM – 11:40 AM"
                )

                UpcomingBusesCard(
                    count: 4,
                    buses: [
                        .init(route: "LX", arrivesIn: "15 mins", destETA: "12:45 AM", busNumber: "1005", load: 0.60),
                        .init(route: "LX", arrivesIn: "22 mins", destETA: "12:52 AM", busNumber: "1011", load: 0.30),
                        .init(route: "B", arrivesIn: "28 mins", destETA: "1:02 AM", busNumber: "982", load: 0.80),
                        .init(route: "REXL", arrivesIn: "34 mins", destETA: "1:10 AM", busNumber: "773", load: 0.55)
                    ],
                    selectedBusID: $selectedBusID
                ) { tappedBus in
                    selectedBusID = tappedBus.id
                    selectedBusForMap = tappedBus
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.top, 14)
            .padding(.bottom, 72)
        }
        .overlay(alignment: .bottom) { bottomBar }
        .sheet(item: $selectedBusForMap) { bus in
            BusMapSheet(
                bus: bus,
                routeColor: routeColor(for: bus.route)
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack(spacing: 10) {
            Spacer(minLength: 0)
            PillButton(title: "Details", systemImage: "info.circle") { }
            PillButton(title: "Add", systemImage: "plus") { }
            PillButton(title: "Edit", systemImage: "pencil") { }
            PillButton(title: "Delete", systemImage: "trash") { }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
        }
    }

    

    private func routeColor(for route: String) -> Color {
        switch route {
        case "LX": return .red
        case "B": return .orange
        case "REXL": return .purple
        default: return .blue
        }
    }
}

struct MainHeaderView : View {
    
    let headerTitle : String
    let headerSubtitle : String
    var mainVStackSpacing : CGFloat = 2.5
    var leadingPadding: CGFloat = 3
    
    var body : some View {
        
        HStack {
            
            VStack(alignment: .leading, spacing: mainVStackSpacing) {
              
                TitleTextView(text: headerTitle)
                
                NormalTextView(text: headerSubtitle, color: .gray2)

            }
            .padding(.leading, leadingPadding)
            
            Spacer()
        }
    }
}

struct TripDetailsView: View {
    
    private let mainVStackSpacing: CGFloat = 12
    private let tripInfoVStackSpacing: CGFloat = 6

    let buildingName: String
    let campusName: String
    let tripName : String
    let from: String
    let to: String
    let timeWindowText: String
    let showsLocationChevrons: Bool
    let footerView: AnyView?
    let trailingHeaderView: AnyView?
    let cardBackgroundColor: Color
    let infoPillBackgroundColor: Color
    let infoPillBorderOpacity: Double
    let infoPillBorderWidth: CGFloat
    let locationRowBorderOpacity: Double
    let locationRowBorderWidth: CGFloat

    init(
        buildingName: String,
        campusName: String,
        tripName: String,
        from: String,
        to: String,
        timeWindowText: String,
        showsLocationChevrons: Bool = true,
        footerView: AnyView? = nil,
        trailingHeaderView: AnyView? = nil,
        cardBackgroundColor: Color = .gray6,
        infoPillBackgroundColor: Color = .gray7,
        infoPillBorderOpacity: Double = 0.08,
        infoPillBorderWidth: CGFloat = 1.2,
        locationRowBorderOpacity: Double = 0.0,
        locationRowBorderWidth: CGFloat = 1.0
    ) {
        self.buildingName = buildingName
        self.campusName = campusName
        self.tripName = tripName
        self.from = from
        self.to = to
        self.timeWindowText = timeWindowText
        self.showsLocationChevrons = showsLocationChevrons
        self.footerView = footerView
        self.trailingHeaderView = trailingHeaderView
        self.cardBackgroundColor = cardBackgroundColor
        self.infoPillBackgroundColor = infoPillBackgroundColor
        self.infoPillBorderOpacity = infoPillBorderOpacity
        self.infoPillBorderWidth = infoPillBorderWidth
        self.locationRowBorderOpacity = locationRowBorderOpacity
        self.locationRowBorderWidth = locationRowBorderWidth
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: mainVStackSpacing) {

            VStack(alignment: .leading, spacing: tripInfoVStackSpacing) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    SubtitleTextView(text: buildingName)
                    Spacer(minLength: 0)
                }
                .padding(.bottom, 5)
                    
                HStack(spacing: 8) {
                    TripMetaPill(
                        text: tripName,
                        backgroundColor: infoPillBackgroundColor,
                        borderOpacity: infoPillBorderOpacity,
                        borderWidth: infoPillBorderWidth
                    )
                    TripTimePill(
                        text: timeWindowText,
                        backgroundColor: infoPillBackgroundColor,
                        borderOpacity: infoPillBorderOpacity,
                        borderWidth: infoPillBorderWidth
                    )
                }
                    
            }

            VStack(spacing: mainVStackSpacing) {
                LocationRow(
                    label: "From",
                    value: from,
                    systemImage: "mappin.and.ellipse",
                    backgroundColor: infoPillBackgroundColor,
                    showsChevron: showsLocationChevrons,
                    borderOpacity: locationRowBorderOpacity,
                    borderWidth: locationRowBorderWidth
                )
                LocationRow(
                    label: "To",
                    value: to,
                    systemImage: "building.2",
                    backgroundColor: infoPillBackgroundColor,
                    showsChevron: showsLocationChevrons,
                    borderOpacity: locationRowBorderOpacity,
                    borderWidth: locationRowBorderWidth
                )
            }

            if let footerView {
                footerView
            }
        }
        .padding()
        .background {
            BackgroundCardView(color: cardBackgroundColor, cornerRadius: 20)
        }
    }

    private var campusBadgeColor: Color {
        switch campusName {
        case "Livingston": return .red1
        case "Busch": return .blue
        case "College Ave": return .orange
        case "Douglass": return .purple
        default: return .gray2
        }
    }
}

struct TripMetaPill: View {
    let text: String
    var backgroundColor: Color = .gray7
    var borderOpacity: Double = 0.08
    var borderWidth: CGFloat = 1.2

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white.opacity(0.9))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: borderWidth)
            )
    }
}

struct TripTimePill: View {
    let text: String
    var backgroundColor: Color = .gray7
    var borderOpacity: Double = 0.08
    var borderWidth: CGFloat = 1.2

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: SF.clock)
                .font(.caption2)
                .foregroundStyle(.gray2)

            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray1)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(backgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(borderOpacity), lineWidth: borderWidth)
        )
    }
}

struct LocationRow: View {
    
    private let mainHStackSpacing : CGFloat = 10
    private let labelWidth : CGFloat = 30
    private let verticalPadding : CGFloat = 6
    
    let label: String
    let value: String
    let systemImage: String
    var backgroundColor: Color = .gray7
    var showsChevron: Bool = true
    var borderOpacity: Double = 0.0
    var borderWidth: CGFloat = 1.0

    var body: some View {
        
        HStack(spacing: mainHStackSpacing) {
            
            Image(systemName: systemImage)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.gray2)

            CaptionTextView(text: label, color: .gray2)
                .frame(width: labelWidth, alignment: .leading)
            
            CaptionTextView(text: value, color: .white)

            Spacer()

            if showsChevron {
                Image(systemName: SF.chevronDown)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, verticalPadding)
        .background(backgroundColor)
        .clipShape(.capsule)
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(borderOpacity), lineWidth: borderWidth)
        )
    }
}

// MARK: - Upcoming Buses Section

struct UpcomingBusesCard: View {
    
    private let mainVStackSpacing : CGFloat = 15

    struct Bus: Identifiable {
        let id = UUID()
        let route: String
        let arrivesIn: String
        let destETA: String
        let busNumber: String
        let load: Double
    }

    let count: Int
    let buses: [Bus]

    @Binding var selectedBusID: UUID?
    let onTapBus: (Bus) -> Void

    var body: some View {
        
        VStack(alignment: .leading, spacing: mainVStackSpacing) {

            HStack {
                
                SubtitleTextView(text: "Upcoming Buses")
                
                NormalTextView(text: "(\(count))", color: .gray2)

            }

            ScrollView(showsIndicators: true) {
                
                LazyVStack(spacing: mainVStackSpacing) {
                    
                    ForEach(buses) { bus in
                        BusRow2(bus: bus, isSelected: selectedBusID == bus.id)
                            .onTapGesture {
                                onTapBus(bus)
                        }
                        
                    }
                }
                .padding(.vertical, 2)
            }
            
        }
        .padding()
        .background {
            BackgroundCardView(color: .gray6, cornerRadius: 20)
        }
    }
}

// MARK: - Bus Row

struct BusRow2: View {
    let bus: UpcomingBusesCard.Bus
    let isSelected: Bool
    var rowBackgroundColor: Color = .gray7

    private var accent: Color {
        switch bus.route {
        case "LX": return .red
        case "B": return .orange
        case "REXL": return .purple
        default: return .blue
        }
    }

    private var delayPillText: String {
        switch bus.route {
        case "LX": return "Delay +5m"
        case "B": return "Delay +3m"
        case "REXL": return "Delay risk"
        default: return "Minor delay"
        }
    }

    private var capacityPillText: String {
        "Capacity \(Int((bus.load * 100).rounded()))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                BusRoutePill(route: bus.route, accent: accent)

                Text("Arrives in \(bus.arrivesIn)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 11)
                    .frame(height: 32)
                    .background(accent.opacity(0.16))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(accent.opacity(0.35), lineWidth: 1)
                    )

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                BusCombinedMetaPill(
                    leftIcon: SF.bus,
                    leftText: "Bus #\(bus.busNumber)",
                    rightIcon: SF.clock,
                    rightText: "Dest ETA \(bus.destETA)"
                )

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.22))
            }

            HStack(spacing: 10) {
                BusCapacityPill(
                    text: capacityPillText
                )

                BusInfoPill(icon: "clock.badge.exclamationmark", text: delayPillText)

                Spacer(minLength: 0)
            }

        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background {
            BackgroundCardView(color: rowBackgroundColor, cornerRadius: 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? accent.opacity(0.45) : Color.white.opacity(0.06),
                        lineWidth: isSelected ? 1.5 : 1)
        )
        .animation(.easeInOut(duration: 0.16), value: isSelected)
    }
}

private struct BusCombinedMetaPill: View {
    let leftIcon: String
    let leftText: String
    let rightIcon: String
    let rightText: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: leftIcon)
                .font(.caption2)
                .foregroundStyle(.gray2)

            Text(leftText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text("•")
                .font(.caption2)
                .foregroundStyle(.gray3)

            Image(systemName: rightIcon)
                .font(.caption2)
                .foregroundStyle(.gray2)

            Text(rightText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.gray7)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.08), lineWidth: 1.35)
        )
    }
}

private struct BusRoutePill: View {
    let route: String
    let accent: Color

    var body: some View {
        Text("\(route) Route")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 11)
            .frame(height: 32)
            .background(accent.opacity(0.78))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

private struct BusCapacityPill: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "person.2.fill")
                .font(.caption2)
                .foregroundStyle(.gray2)

            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.gray7)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.08), lineWidth: 1.35)
        }
    }
}

private struct BusInfoPill: View {
    let icon: String
    let text: String
    var tint: Color? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(tint ?? .gray2)

            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(tint?.opacity(0.10) ?? Color.gray7)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(tint?.opacity(0.22) ?? Color.white.opacity(0.08), lineWidth: tint == nil ? 1.35 : 1)
        )
    }
}

// MARK: - Bus Map Sheet (lag-reduced)

private struct BusMapSheet: View {

    let bus: UpcomingBusesCard.Bus
    let routeColor: Color

    @StateObject private var locationManager = SimpleLocationManager()

    @State private var position: MapCameraPosition = .automatic
    @State private var showUser = false

    // ✅ delay creating Map until after sheet animation starts
    @State private var showMap = false

    // Static demo geometry only
    @State private var routeLine: [CLLocationCoordinate2D] = RutgersDemoGeometry.routeLX
    @State private var busMarkers: [StaticBusMarker] = RutgersDemoGeometry.staticBuses

    private var accent: Color { routeColor }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {

                headerBar

                ZStack(alignment: .bottomTrailing) {

                    Group {
                        if showMap {
                            MKBusMapView(
                                    routeLine: routeLine,
                                    busMarkers: busMarkers,
                                    routeColor: UIColor(accent),
                                    showUser: showUser
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.06))
                                .overlay(ProgressView().tint(.white))
                        }
                    }
                    .frame(minHeight: 280) // critical: avoid 0x0 drawable
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                    VStack(spacing: 10) {
                        CircleIconButton(
                            systemImage: showUser ? "location.fill" : "location",
                            title: "My Location",
                            isOn: showUser
                        ) {
                            toggleUserLocation()
                        }

                        CircleIconButton(systemImage: "scope", title: "Center") {
                            centerOnRoute()
                        }
                    }
                    .padding(12)
                }
                .padding(.horizontal)

                Spacer(minLength: 0)
            }
            .padding(.top, 8)
        }
        .onAppear {
            applyHighlight()
            centerOnRoute()

            // ✅ create the heavy map a beat later so sheet animation is smooth
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                showMap = true
            }
        }
        .onDisappear {
            showMap = false
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            RouteBadge(text: bus.route, color: accent)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("Bus \(bus.busNumber)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("Route + bus positions")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.65))
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    private func toggleUserLocation() {
        showUser.toggle()
        if showUser {
            locationManager.request()
        } else {
            locationManager.stop()
        }
    }

    private func centerOnRoute() {
        position = .region(RutgersDemoGeometry.boundingRegion(for: routeLine))
    }

    private func applyHighlight() {
        for i in busMarkers.indices {
            busMarkers[i].route = bus.route
            busMarkers[i].isHighlighted = (i == 0)
        }
    }
}

private struct MKBusMapView: UIViewRepresentable {
    let routeLine: [CLLocationCoordinate2D]
    let busMarkers: [StaticBusMarker]
    let routeColor: UIColor
    let showUser: Bool

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator

        // Performance-friendly defaults
        map.isPitchEnabled = false
        map.isRotateEnabled = false
        map.showsCompass = false
        map.showsScale = false
        map.pointOfInterestFilter = .excludingAll
        map.preferredConfiguration = {
            let config = MKStandardMapConfiguration(elevationStyle: .flat)
            config.pointOfInterestFilter = .excludingAll
            config.showsTraffic = false
            return config
        }()

        // Annotation reuse (huge for “bus app” scaling)
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: BusAnnoView.reuseID)

        // Initial content
        context.coordinator.applyInitialContent(to: map, routeLine: routeLine, markers: busMarkers)

        map.showsUserLocation = showUser
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        // Toggle blue dot without rebuilding map
        if map.showsUserLocation != showUser {
            map.showsUserLocation = showUser
        }

        // Update overlays/annotations incrementally
        context.coordinator.update(map: map, routeLine: routeLine, markers: busMarkers, routeColor: routeColor)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        private var lastRouteHash: Int = 0
        private var lastMarkersHash: Int = 0
        private var didSetInitialRegion = false

        // Keep references so we can diff / update cheaply
        private var polyline: MKPolyline?
        private var markerByID: [UUID: BusAnno] = [:]

        func applyInitialContent(to map: MKMapView, routeLine: [CLLocationCoordinate2D], markers: [StaticBusMarker]) {
            // Overlays
            let pl = MKPolyline(coordinates: routeLine, count: routeLine.count)
            polyline = pl
            map.addOverlay(pl)

            // Annotations
            let annos = markers.map { BusAnno(id: $0.id, route: $0.route, coordinate: $0.coordinate, isHighlighted: $0.isHighlighted) }
            annos.forEach { markerByID[$0.id] = $0 }
            map.addAnnotations(annos)

            // Initial region
            if !routeLine.isEmpty {
                let region = RutgersDemoGeometry.boundingRegion(for: routeLine)
                map.setRegion(region, animated: false)
                didSetInitialRegion = true
            }

            lastRouteHash = hashRoute(routeLine)
            lastMarkersHash = hashMarkers(markers)
        }

        func update(map: MKMapView, routeLine: [CLLocationCoordinate2D], markers: [StaticBusMarker], routeColor: UIColor) {
            // 1) Route: replace overlay only if changed
            let newRouteHash = hashRoute(routeLine)
            if newRouteHash != lastRouteHash {
                if let old = polyline {
                    map.removeOverlay(old)
                }
                let pl = MKPolyline(coordinates: routeLine, count: routeLine.count)
                polyline = pl
                map.addOverlay(pl)

                // If we haven’t set region yet (or route changed a lot), set it once.
                if !didSetInitialRegion, !routeLine.isEmpty {
                    map.setRegion(RutgersDemoGeometry.boundingRegion(for: routeLine), animated: false)
                    didSetInitialRegion = true
                }

                lastRouteHash = newRouteHash
            }

            // 2) Markers: if changed, do a lightweight diff update
            let newMarkersHash = hashMarkers(markers)
            if newMarkersHash != lastMarkersHash {
                updateMarkers(map: map, markers: markers)
                lastMarkersHash = newMarkersHash
            }

            // Store color for renderer/view (delegate reads from mapView via associated state)
            map.tintColor = routeColor
        }

        private func updateMarkers(map: MKMapView, markers: [StaticBusMarker]) {
            // Add/update existing
            var seen = Set<UUID>()

            for m in markers {
                seen.insert(m.id)
                if let existing = markerByID[m.id] {
                    // Update coordinate without full remove/add
                    if existing.coordinate.latitude != m.coordinate.latitude || existing.coordinate.longitude != m.coordinate.longitude {
                        existing.coordinate = m.coordinate
                    }
                    existing.route = m.route
                    existing.isHighlighted = m.isHighlighted

                    // Refresh view if visible
                    if let view = map.view(for: existing) as? MKMarkerAnnotationView {
                        configure(view, for: existing)
                    }
                } else {
                    let anno = BusAnno(id: m.id, route: m.route, coordinate: m.coordinate, isHighlighted: m.isHighlighted)
                    markerByID[m.id] = anno
                    map.addAnnotation(anno)
                }
            }

            // Remove stale
            let toRemove = markerByID.keys.filter { !seen.contains($0) }
            for id in toRemove {
                if let anno = markerByID[id] {
                    map.removeAnnotation(anno)
                    markerByID[id] = nil
                }
            }
        }

        // MARK: MKMapViewDelegate

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let pl = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: pl)
                // Use mapView.tintColor set in update(), fallback if nil
                r.strokeColor = mapView.tintColor ?? UIColor.systemRed
                r.lineWidth = 5
                r.lineJoin = .round
                r.lineCap = .round
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Keep default blue dot
            if annotation is MKUserLocation { return nil }

            guard let busAnno = annotation as? BusAnno else { return nil }

            let view = mapView.dequeueReusableAnnotationView(withIdentifier: BusAnnoView.reuseID, for: busAnno) as! MKMarkerAnnotationView
            view.annotation = busAnno
            configure(view, for: busAnno)
            return view
        }

        private func configure(_ view: MKMarkerAnnotationView, for anno: BusAnno) {
            // Lightweight, system marker (fast) — later you can switch to custom images if needed
            view.markerTintColor = (view.superview as? MKMapView)?.tintColor ?? UIColor.systemRed
            view.glyphText = anno.route
            view.glyphTintColor = .white
            view.displayPriority = anno.isHighlighted ? .required : .defaultHigh
            view.canShowCallout = false
        }

        // MARK: Hashing helpers (cheap change detection)

        private func hashRoute(_ coords: [CLLocationCoordinate2D]) -> Int {
            var hasher = Hasher()
            hasher.combine(coords.count)
            // Sample points to avoid hashing every point if big
            let step = max(1, coords.count / 12)
            for i in stride(from: 0, to: coords.count, by: step) {
                hasher.combine(coords[i].latitude)
                hasher.combine(coords[i].longitude)
            }
            return hasher.finalize()
        }

        private func hashMarkers(_ markers: [StaticBusMarker]) -> Int {
            var hasher = Hasher()
            hasher.combine(markers.count)
            for m in markers {
                hasher.combine(m.id)
                hasher.combine(m.route)
                // Rounded to reduce “noise” when you later do frequent updates
                hasher.combine((m.coordinate.latitude * 1e5).rounded())
                hasher.combine((m.coordinate.longitude * 1e5).rounded())
                hasher.combine(m.isHighlighted)
            }
            return hasher.finalize()
        }
    }
}

// MARK: - Annotation Model

private enum BusAnnoView {
    static let reuseID = "BusAnnoView"
}

private final class BusAnno: NSObject, MKAnnotation {
    let id: UUID
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var route: String
    var isHighlighted: Bool

    init(id: UUID, route: String, coordinate: CLLocationCoordinate2D, isHighlighted: Bool) {
        self.id = id
        self.route = route
        self.coordinate = coordinate
        self.isHighlighted = isHighlighted
        super.init()
    }
}

// MARK: - Map Pins

private struct BusPin: View {
    let route: String
    let isHighlighted: Bool
    let accent: Color

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(accent.opacity(isHighlighted ? 1.0 : 0.85))
                    .frame(width: isHighlighted ? 34 : 30, height: isHighlighted ? 34 : 30)
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))

                Text(route)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 4)
            }

            Image(systemName: "triangle.fill")
                .font(.caption2)
                .foregroundStyle(accent.opacity(isHighlighted ? 1.0 : 0.85))
                .rotationEffect(.degrees(180))
                .offset(y: -4)
        }
        .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
    }
}

// MARK: - Buttons / Components

private struct CircleIconButton: View {
    let systemImage: String
    let title: String
    var isOn: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(isOn ? 1.0 : 0.85))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(isOn ? 0.18 : 0.12))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))
                .accessibilityLabel(Text(title))
        }
        .buttonStyle(.plain)
    }
}

private struct RouteBadge: View {
    let text: String
    var color: Color = .red

    var body: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 46, height: 46)
            .background(color.opacity(0.95))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 1)
    }
}

private struct LoadRing2: View {
    let progress: Double
    let accent: Color

    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.10), lineWidth: 4)

            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int((progress * 100).rounded()))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(width: 45, height: 45)
    }
}

private struct PillButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.caption)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.14))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Static Demo Data

private struct StaticBusMarker: Identifiable {
    let id = UUID()
    var route: String
    var coordinate: CLLocationCoordinate2D
    var isHighlighted: Bool = false
}

private enum RutgersDemoGeometry {

    static let routeLX: [CLLocationCoordinate2D] = [
        .init(latitude: 40.5009, longitude: -74.4474),
        .init(latitude: 40.5034, longitude: -74.4519),
        .init(latitude: 40.5065, longitude: -74.4556),
        .init(latitude: 40.5101, longitude: -74.4587),
        .init(latitude: 40.5135, longitude: -74.4605),
        .init(latitude: 40.5161, longitude: -74.4590),
        .init(latitude: 40.5182, longitude: -74.4554),
        .init(latitude: 40.5187, longitude: -74.4510),
        .init(latitude: 40.5168, longitude: -74.4476),
        .init(latitude: 40.5138, longitude: -74.4458),
        .init(latitude: 40.5102, longitude: -74.4456),
        .init(latitude: 40.5069, longitude: -74.4461),
        .init(latitude: 40.5036, longitude: -74.4468),
        .init(latitude: 40.5009, longitude: -74.4474)
    ]

    static let staticBuses: [StaticBusMarker] = [
        .init(route: "LX", coordinate: routeLX[1], isHighlighted: true),
        .init(route: "LX", coordinate: routeLX[5]),
        .init(route: "LX", coordinate: routeLX[9]),
        .init(route: "LX", coordinate: routeLX[12])
    ]

    static func boundingRegion(for coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard let first = coords.first else {
            return MKCoordinateRegion(
                center: .init(latitude: 40.5, longitude: -74.45),
                span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }

        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude

        for c in coords {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max(0.01, (maxLat - minLat) * 1.6),
            longitudeDelta: max(0.01, (maxLon - minLon) * 1.6)
        )

        return MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Location Manager

final class SimpleLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var lastCoordinate: CLLocationCoordinate2D? = nil

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func request() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastCoordinate = locations.last?.coordinate
    }
}

#Preview {
    CurrentTripView()
}
