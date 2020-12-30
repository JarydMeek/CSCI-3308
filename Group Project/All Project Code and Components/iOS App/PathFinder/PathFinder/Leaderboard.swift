//
//  Leaderboard.swift
//  PathFinder
//
//  Created by Jaryd Meek on 10/30/20.
//

import SwiftUI
import UIKit

struct leaderboardItem: Codable {
    var distance:Double
    var username:String
    var id = UUID()
    
    private enum CodingKeys : String, CodingKey { case distance, username }
}



struct Leaderboard: View {
    
    @State var leaderboardData:[leaderboardItem] = []
    @State var dataIsLoaded:Bool = false
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        do {
            let newData = try decoder.decode([leaderboardItem].self, from: json)
            leaderboardData = newData
        } catch {
            print(error)
        }
    }
    func loadData() {
        let url = URL(string: "\(mainUrl)/mobile/leaderboard")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            // Convert HTTP Response Data to a String
            if let data = data{
                parse(json: data)
                dataIsLoaded = true
            }
        }
        task.resume()
        
    }
    
    var body: some View {
        ZStack{
            Image("background")
                .resizable()
                .opacity(0.5)
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Top Distance")
                    .padding(10)
                    .font(Font.custom("Inter", size: 50))
                    .background(Color("mainColor"))
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    if (dataIsLoaded){
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(leaderboardData, id: \.self.id){item in
                                    HStack {
                                        Text(item.username)
                                        Spacer()
                                        VStack{
                                            Text("Distance")
                                            Text(String(format: "%.2f Miles", item.distance))
                                        }.font(Font.custom("Inter", size: 16))
                                    }
                                    .padding(10)
                                    .font(Font.custom("Inter", size: 28))
                                    .background(Color.gray)
                                    .cornerRadius(5)
                                    .foregroundColor(Color("darkLight"))
                                }
                            }.padding(30)
                        }
                    } else {
                        Text("Loading Data")
                    }
            }.onAppear {
                loadData()
            }
        }.navigationBarHidden(true)
        .navigationBarTitle("")
    }
}

struct Leaderboard_Previews: PreviewProvider {
    static var previews: some View {
        Leaderboard()
    }
}
