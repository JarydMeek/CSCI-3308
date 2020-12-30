//
//  Profile.swift
//  PathFinder
//
//  Created by Jaryd Meek on 10/30/20.
//

import SwiftUI
import CryptoKit




struct Profile: View {
    @Binding var logOut:Bool
    /* ROUTE STUFF TO GET TOTAL DISTANCE */
    @State var routeData:[routeItem] = []
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        do {
            let newData = try decoder.decode([routeItem].self, from: json)
            routeData = newData
        } catch {
            print(error)
        }
    }
    
    
    func loadData() {
        
        let url = URL(string: "\(mainUrl)/mobile/routes")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        
        
        let postString = "username=" + userName
        request.httpBody = postString.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data {
                parse(json: data)
                
            }
        }
        task.resume()
        
    }
    
    
    func getTotalDistance() -> Double {
        var totalDistance = 0.0
        for route in routeData {
            totalDistance += route.distance
        }
        return totalDistance
    }
    func getTotalRoutes() -> Int {
        return routeData.count
    }
    
    var body: some View {
        ZStack{
            Image("background")
                .resizable()
                .opacity(0.5)
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                VStack{
                Text("Welcome Back,")
                Text("\(userName)")
                }
                    .padding(10)
                    .font(Font.custom("Inter", size: 44))
                    .background(Color("mainColor"))
                    .cornerRadius(5)
                    .foregroundColor(.white)
                Spacer()
                VStack{
                    Text("Total Distance")
                    Text("\(getTotalDistance())")

                }
                .padding(10)
                .font(Font.custom("Inter", size: 36))
                .background(Color("lightDark").opacity(0.25))
                .cornerRadius(5)
                .foregroundColor(.white)

                Spacer()
                VStack{
                Text("Total Routes")
                Text("\(getTotalRoutes())")
                    
                }
                .padding(10)
                .font(Font.custom("Inter", size: 36))
                .background(Color("lightDark").opacity(0.25))
                .cornerRadius(5)
                .foregroundColor(.white)
                Spacer()
                Spacer()
                Button(action: {
                    userID = -1
                    userName = "null"
                    save()
                    logOut = false
                }, label: {
                    Text("Log Out")
                    
                })
                .padding(10)
                .font(Font.custom("Inter", size: 28))
                .background(Color("mainColor"))
                .cornerRadius(5)
                .foregroundColor(.white)
                Spacer()
            }
        }.onAppear {
            loadData()
        }
    }
}
