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
    
    func getTopThreeItems() -> [Item] {
        var res = self.items.sorted(by: { (Int($0.price) * $0.quantity) > (Int($1.price) * $1.quantity) })
        if res.count >= 3 { return Array(res[0 ..< 3]) }
        else {
            while (res.count < 3) { res.append(Item(barcode: "0", name: "", price: 0.00, currency: "", img_name: "error_icon.png", byPiece: false, quantity: 0)) }
        }
        return res
    }
}
