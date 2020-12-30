//
//  Routes.swift
//  PathFinder
//
//  Created by Jaryd Meek on 10/30/20.
//

import SwiftUI

struct routeItem: Codable {
    var date:String
    var distance:Double
    var route_name:String
    var id = UUID()
    
    private enum CodingKeys : String, CodingKey { case date, distance, route_name }
}


struct Routes: View {
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
    
    func getDate(date: String) -> String {
        var newDate = date
        newDate.removeLast(min(newDate.count, 4))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")

        let dateObj = dateFormatter.date(from: newDate)

        dateFormatter.dateFormat = "h:mm a - MMM d, YYYY"
        let now = dateFormatter.string(from: dateObj!)
        return now
    }
    
    var body: some View {
        ZStack(alignment: .top){
            Image("background")
                .resizable()
                .opacity(0.5)
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Past Routes")
                    .padding(10)
                    .font(Font.custom("Inter", size: 50))
                    .background(Color("mainColor"))
                    .cornerRadius(5)
                    .foregroundColor(.white)
                if (routeData.count == 0) {
                    Spacer()
                    Text("No Past Routes :(")
                        .padding(10)
                        .background(Color.gray)
                        .cornerRadius(5)
                        .foregroundColor(Color("darkLight"))
                    Spacer()
                } else {
                ScrollView(showsIndicators: false) {
                    VStack {

                        ForEach(routeData.reversed(), id: \.self.id){item in
                            HStack{
                                VStack{
                                    Text(item.route_name)
                                        .font(Font.custom("Inter", size: 28))
                                    Text(String(getDate(date: item.date)))
                                }
                                Spacer()
                                VStack{
                                    Text("Distance - ")
                                    Text(String(format: "%.2f Miles", item.distance))
                                }
                            }.font(Font.custom("Inter", size: 16))
                        }
                        .padding(10)
                        .background(Color.gray)
                        .cornerRadius(5)
                        .foregroundColor(Color("darkLight"))
                        
                        
                    }.padding(30)
                }
            }
            }.onAppear {
                loadData()
            }
        }.navigationBarHidden(true)
        .navigationBarTitle("")
    }
}




struct Routes_Previews: PreviewProvider {
    static var previews: some View {
        Routes()
    }
}
