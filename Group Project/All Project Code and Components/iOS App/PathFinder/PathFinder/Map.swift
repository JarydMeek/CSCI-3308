//
//  Map.swift
//  PathFinder
//
//  Created by Jaryd Meek on 10/30/20.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocation
import CryptoKit

struct Map: View {
    
    //Create instance of the locationFetcher
    let locationFetcher = LocationFetcher()
    //current location
    @State var userLatitude: String = "";
    @State var userLongitude: String = "";
    @State var tracking:Bool = false;
    @State var localDistance:Double = 0.0;
    
    //pulls the users lattitude and longitude
    func getLocation() {
        userLongitude = "\(locationFetcher.lastKnownLocation?.longitude ?? 0)"
        userLatitude = "\(locationFetcher.lastKnownLocation?.latitude ?? 0)"
    }
    
    //Create the Map View object
    struct MapView: UIViewRepresentable {
        //Coordinator for Polyline
        func makeCoordinator() -> Coordinator {
            return Coordinator()
        }
        
        //Create and setup the locationManager
        var locationManager = CLLocationManager()
        
        //Send user alert requesting location
        func setupManager() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
       
        //UI view that shows user's location, and doesn't let them change the view
        func makeUIView(context: Context) -> MKMapView {
            setupManager()
            let mapView = MKMapView(frame: UIScreen.main.bounds)
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
            mapView.isUserInteractionEnabled = false
            mapView.delegate = context.coordinator
            return mapView
        }
        
        //What happens when the user's location updates, which adds the polyline if there are more than 2 points that have been saved.
        func updateUIView(_ uiView: MKMapView, context: Context) {
            
            let polyline = MKGeodesicPolyline(coordinates: &coords, count: pins.count)
            
            if (pins.count > 1) {
                uiView.addOverlay(polyline)
            }
            
            if (stop == true) {
                uiView.removeOverlays(uiView.overlays)
            }
            
        }
        
        //Coordinator that draws the map overlay of the polyline
        class Coordinator: NSObject,MKMapViewDelegate{
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                // Make sure we are rendering a polyline.
                guard let polyline = overlay as? MKPolyline else {
                    return MKOverlayRenderer()
                }

                // Create a specialized polyline renderer and set the polyline properties.
                let polylineRenderer = MKPolylineRenderer(overlay: polyline)
                polylineRenderer.strokeColor = UIColor(red: 0.232, green: 0.089, blue: 0.517, alpha: 255)
                polylineRenderer.lineWidth = 5
                return polylineRenderer
            }
        }
    }
    
    //adds a location point at the users location when called (both a pin and coords)
    func addPin() {
        getLocation()
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationFetcher.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        pins.append(annotation)
        let temp = locationFetcher.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        coords.append(temp)
    }
    //actually tracks the user while the stop variable is false
    func track() {
        addPin()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){timer in
            if stop {
                timer.invalidate()
            } else {
                addPin()
                localDistance = getDistance()
            }
        }
    }
    
    //calculates the distance of all the saved coordinates and saves it to the totalDistance variable
    func getDistance () -> Double {
        var count = 0
        var totalDistance = 0.0
        if (pins.count > 1) {
            for _ in pins {
                if count < (pins.count - 1){
                    let location1 = CLLocation(latitude: pins[count].coordinate.latitude, longitude: pins[count].coordinate.longitude)
                    let location2 = CLLocation(latitude: pins[count+1].coordinate.latitude, longitude: pins[count+1].coordinate.longitude)
                    let distance = location2.distance(from: location1)
                    count += 1
                    totalDistance += distance
                }
            }
            
        }
        localDistance = totalDistance/1609.34
        return totalDistance/1609.34
    }
    
    //starts the location tracker when the view loads
    init() {
        self.locationFetcher.start()
    }
    //swap to change views based on custom button
    @State private var swap: Int? = 0
    
    //Main view for map.
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: endTrack(tracking: $tracking, localDistance: $localDistance), tag: 1, selection: $swap) {
                    EmptyView()
                }
                ZStack(alignment: .bottom){
                    MapView()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    if (!tracking) {
                        
                        Button(action: {
                            stop = false
                            tracking = !tracking
                            track()
                            
                        }, label: {
                            Text("Start Tracking Location")
                        })
                        .padding(10)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(height: 75)
                    } else {
                        
                        VStack {
                            Text(String(format: "Distance: %.2f Miles", localDistance))
                                .padding(10)
                                .background(Color.primary.opacity(0.75))
                                .foregroundColor(Color("darkLight"))
                                .cornerRadius(10)
                            Button(action: {
                                addPin()
                                savedDistance = getDistance()
                                savedCoords = coords
                                self.swap = 1
                            }, label: {
                                Text("Stop Tracking Location")
                            })
                            .padding(10)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .frame(height: 75)
                        }
                    }
                }
            }
        }.navigationBarHidden(true)
        .navigationBarTitle("")
    }
}


//view for showing the user's route after they are done tracking
struct endTrack: View {
    
    @Binding var tracking: Bool
    @Binding var localDistance: Double
    
    struct MapView: UIViewRepresentable {
        
        let polyline = MKGeodesicPolyline(coordinates: &savedCoords, count: savedCoords.count)
        
        func makeCoordinator() -> Coordinator {
            return Coordinator()
        }
        
        var locationManager = CLLocationManager()
        func setupManager() {
        }
       
        func makeUIView(context: Context) -> MKMapView {
            setupManager()
            let mapView = MKMapView(frame: UIScreen.main.bounds)
            mapView.showsUserLocation = true
            mapView.isUserInteractionEnabled = false
            mapView.delegate = context.coordinator
            mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 0, left: 20, bottom: 40, right: 20), animated: true)
            if (pins.count > 1) {
                mapView.addOverlay(polyline)
            }
            return mapView
        }
        func updateUIView(_ uiView: MKMapView, context: Context) {
            uiView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 0, left: 20, bottom: 40, right: 20), animated: true)
        }
        
        class Coordinator: NSObject,MKMapViewDelegate{
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                // Make sure we are rendering a polyline.
                guard let polyline = overlay as? MKPolyline else {
                    return MKOverlayRenderer()
                }

                // Create a specialized polyline renderer and set the polyline properties.
                let polylineRenderer = MKPolylineRenderer(overlay: polyline)
                polylineRenderer.strokeColor = UIColor(red: 0.232, green: 0.089, blue: 0.517, alpha: 255)
                polylineRenderer.lineWidth = 5
                return polylineRenderer
            }
        }
    }
    
    @State private var newUser = false
    @State private var alert = false
    @State private var rating:String = ""
    @State private var routeName:String = ""
    
    func passwordHash(email: String, password: String) -> String {
        let salt = "6MgRphZeod2dbGpiRGmhroEmkj66oQVf"
        let toHash = password + "." + salt
        
        let hashed = SHA256.hash(data: Data(toHash.utf8))
        let hashString = hashed.compactMap { String(format: "%02hhx", $0) }.joined()
        return hashString
    }
    
    
    func sendData() {
        
        let url = URL(string: "\(mainUrl)/mobile/addroute")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        let postString = "username=\(userName)&distance=\(savedDistance)&routeInfo=\(routeName)&radiob=-1&date=\(getSQLdate())"
        request.httpBody = postString.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                if dataString == "Success" {
                    newUser = true
                    return
                }
                alert = true
            }
        }
        task.resume()
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    
    //Actual view
    var body: some View {
        NavigationView{
            VStack() {
                MapView()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text(String(format: "Distance: %.2f Miles", savedDistance))
                        .padding(10)
                        .background(Color.primary.opacity(0.75))
                        .foregroundColor(Color("darkLight"))
                        .cornerRadius(10)
                    TextField("Enter Name", text: $routeName)
                        .padding(20)
                        .background(Color.black.opacity(0.25))
                        .padding(20)
                    Button(action: {
                        sendData()
                        pins = []
                        coords = []
                        savedCoords = []
                        localDistance = 0.0
                        savedDistance = 0.0
                        tracking = false
                        stop = true
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Save Route")
                    })
                    .padding(10)
                    .background(Color.accentColor)
                    .foregroundColor(Color("darkLight"))
                    .cornerRadius(10)
                    .frame(height: 75)
                }
                
            }
        }.navigationBarTitle (Text("Save Route"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        // Add your custom back button here
        .navigationBarItems(leading:
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.left.circle")
                    Text("Cancel")
                }
        }, trailing:
            Button(action: {
                pins = []
                coords = []
                savedCoords = []
                savedDistance = 0.0
                localDistance = 0.0
                tracking = false
                stop = true
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Text("Delete")
                    Image(systemName: "trash.circle")
                }
        })
    }
}

//xcode previews
struct Map_Previews: PreviewProvider {
    static var previews: some View {
        Map()
    }
}
