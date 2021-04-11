//
//  Purchase.swift
//  ForFun
//
//  Created by Никита Раташнюк on 17.02.2021.
//

import Foundation


struct defaultsKeys {
    static let purchaces = "allPurchases"
}


struct Purchase: Codable {
    var items: [Item]
    var totalAmount: Double
    var date: Date
    var paymentMethod: String
    var email: String?
    
    internal init(items: [Item], totalAmount: Double, date: Date, paymentMethod: String, email: String? = nil) {
        self.items = items
        self.totalAmount = totalAmount
        self.date = date
        self.paymentMethod = paymentMethod
        self.email = email
    }
    
    func saveGlobally() {
        if UserDefaults.standard.object(forKey: defaultsKeys.purchaces) == nil {
            do {
                try UserDefaults.standard.setObject([self], forKey: defaultsKeys.purchaces)
            } catch { print(error.localizedDescription) }
        } else {
            do {
                if var purchases = try UserDefaults.standard.getObject(forKey: defaultsKeys.purchaces, castTo: [Purchase]?.self) {
                    purchases.insert(self, at: 0)
                
                    try UserDefaults.standard.setObject(purchases, forKey: defaultsKeys.purchaces)
                }
            } catch { print(error.localizedDescription) }
        }
    }
    
    func getDay() -> String {
        let calendar = Calendar.current
        return String(calendar.component(.day, from: self.date))
    }
    
    func getMonth() -> String {
        let Months = ["Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря"]
        
        let calendar = Calendar.current
        let monthNumber = calendar.component(.month, from: self.date)
        
        return Months[monthNumber - 1]
    }
    
    func getYear() -> String {
        let calendar = Calendar.current
        return String(calendar.component(.year, from: self.date))
    }
    
    func getMonthNumber() -> String {
        let calendar = Calendar.current
        var monthNumber = String(calendar.component(.month, from: self.date))
        
        if monthNumber.count == 1 { monthNumber = "0" + monthNumber }
        
        return monthNumber
    }
    
    func getTopThreeItems() -> [Item] {
        var res = self.items.sorted(by: { (Int($0.price) * $0.quantity) > (Int($1.price) * $1.quantity) })
        if res.count >= 3 { return Array(res[0 ..< 3]) }
        else {
            while (res.count < 3) { res.append(Item(barcode: "0", name: "", price: 0.00, currency: "", img_name: "error_icon.png", byPiece: false, quantity: 0)) }
        }
        return res
    }
    
    func getDateForJSON() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let res = dateFormatter.string(from: self.date)
        
        return res
    }
    
    func writeToJSON(completion: @escaping (String?) -> Void) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            var json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

            let readyDate = getDateForJSON()
            json["date"] = readyDate
            postRequest(to: "http://45.132.19.12:5000/upload", parameters: json, completion: completion)
        }
        catch { print(error.localizedDescription) }
    }
}

func postRequest(to link: String, parameters: [String: Any], completion: @escaping (String?) -> Void) {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 30
    let session = URLSession(configuration: configuration)
    
    let url = URL(string: link)!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    // let parameters = ["username": "foo", "password": "123456"]
    let parameters = parameters
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        print(request)
    } catch let error {
        print(error.localizedDescription)
    }
    
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        
        if error != nil || data == nil {
            print("Client error!")
            completion(nil)
            return
        }
        
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            print("Oops!! there is server error!")
            completion(nil)
            return
        }
        
        guard let mime = response.mimeType, mime == "application/json" else {
            print("response is not json")
            completion(nil)
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                print("The Response is :", json)
                let res = json["purchase_id"] as! String
                completion(res)
                return
            }
        } catch {
            print("JSON error: \(error.localizedDescription)")
        }
        
    })
    
    task.resume()
}
