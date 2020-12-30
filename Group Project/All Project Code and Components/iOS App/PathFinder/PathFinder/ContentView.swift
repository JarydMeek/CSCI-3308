//
//  ContentView.swift
//  PathFinder
//
//  Created by Jaryd Meek on 10/1/20.
//

import SwiftUI
import CoreData
import MapKit
import CoreLocation
import CryptoKit



/* GLOBAL VARIABLES */
//Tracks if user is logged in
 var userLoggedIn = false
 var userName: String = ""
 var userID: Int = -1

//Variables for route tracking
 var pins = [MKPointAnnotation]()
 var coords = [CLLocationCoordinate2D]()
 var stop = false

//Saved Coords to show the user when they hit stop tracking before they save or cancel
 var savedCoords = [CLLocationCoordinate2D]()
 var savedDistance = 0.0
 
//URL LOCATIONS
 var mainUrl = "http://44.236.210.48:5000"


struct ContentView: View {
    
    @State private var selection = 0
    @State private var sendToLogin:Bool? = true
    @State var login = false;
    
    init(){

    }
    @Environment(\.presentationMode) var presentationMode
    @State private var loginUsername = ""
    @State private var loginPassword = ""
    @State private var localUserID = userID
    
    var body: some View {
            if (login) {
            TabView(selection: $selection){
                Map().tabItem {
                    VStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Map")
                    }
                }.accentColor(Color("mainColor"))
                .tag(0)
                Routes().tabItem {
                    VStack {
                        Image(systemName: "map")
                        Text("Past Routes")
                    }
                }.accentColor(Color("mainColor"))
                .tag(1)
                Leaderboard().tabItem {
                    VStack {
                        Image("leaderboard")
                        Text("Leaderboard")
                    }
                }.accentColor(Color("mainColor"))
                .tag(2)
                Profile(logOut: $login).tabItem {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                }.accentColor(Color("mainColor"))
                .tag(3)
            }.accentColor(Color("tabbar"))
            }else {
                GeometryReader { metrics in
                    NavigationView {
                        ZStack{
                            Image("background")
                                .resizable()
                                .opacity(0.5)
                                .aspectRatio(contentMode: .fill)
                                .edgesIgnoringSafeArea(.all)
                        VStack {
                            if (login) {
                                Text("Welcome Back!")
                            } else {
                                Text("Welcome To Pathfinder!")
                                    .padding(10)
                                    .font(Font.custom("Inter", size: 28))
                                    .background(Color("lightDark").opacity(0.25))
                                    .cornerRadius(5)
                                    .foregroundColor(.white)
                                Spacer()
                                Image("RevisedShoe")
                                    .resizable()
                                    .frame(width:metrics.size.width * 0.7, height: metrics.size.width * 0.7)
                                    .cornerRadius(5)
                                Spacer()
                                NavigationLink(destination: loginPage(localUserId: $localUserID, login: $login)) {
                                    Text("Login")
                                }
                                .padding(10)
                                .font(Font.custom("Inter", size: 28))
                                .background(Color.accentColor)
                                .cornerRadius(5)
                                .foregroundColor(.white)
                                NavigationLink(destination: createAccount(localUserId: $localUserID, login: $login)) {
                                    Text("Create Account")
                                }
                                .padding(10)
                                .font(Font.custom("Inter", size: 28))
                                .background(Color.accentColor)
                                .cornerRadius(5)
                                .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }.accentColor(Color("mainColor"))
                    .onAppear{
                        load()
                        if (userID != -1) {
                            login = true
                        } else {
                            login = false
                        }
                    }
            }
            }
        }
}



//Location Fetcher that allows us to get the user's current location
class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}

//Date Fetcher
 func getSQLdate() -> String {
    let time = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy HH:mm:ss"
    return dateFormatter.string(from: time)
}


//Load/Save
func save() {
    let defaults = UserDefaults.standard
    defaults.set(userID, forKey: "id")
    defaults.set(userName, forKey: "username")
}

func load() {
    let defaults = UserDefaults.standard
    userID = defaults.integer(forKey: "id")
    if (userID == 0) {
        userID = -1
    }
    userName = defaults.string(forKey: "username") ?? "null"
}

//preview stuff for xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
