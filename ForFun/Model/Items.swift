//
//  Items.swift
//  ForFun
//
//  Created by Никита Раташнюк on 20.01.2021.
//

import Foundation
import UIKit

struct Item: Decodable {
    let barcode: String
    let name: String
    let price: Double
    let currency: String
    let img_name: String
    let byPiece: Bool
    
    var quantity: Int
    
    var image: UIImage {
        UIImage(named: img_name)!
    }
}

struct NotFoundItem {
    let barcode: String

    func showErrorAlert() {
        print("123")
    }
}

var items = [String: Item]()

func loadItems(filename: String) {
    do {
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("no file")
            return
        }
        let data = try Data(contentsOf: file)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let object = json as? [String: Dictionary<String, Any>] {
                
            for (key, obj) in object {
                let itemName = obj["name"] as! String
                let itemPrice = obj["price"] as! Double
                let itemCurrency = obj["currency"] as! String
                let itemImgName = obj["imgName"] as! String
                let itemByPiece = obj["byPiece"] as! Bool
                
                let item = Item(barcode: key, name: itemName, price: itemPrice, currency: itemCurrency, img_name: itemImgName, byPiece: itemByPiece, quantity: 1)
                items[key] = item
            }
            
        } else {
            print("JSON is invalid")
        }
    } catch {
        print(error.localizedDescription)
    }
}


func loadItemFromURL(link: String, barcode: String) -> Bool {
    do {
        let url = URL(string: link)!

        var content = try String(contentsOf: url)
        content = String(content.dropFirst(1).dropLast(1))
        
        let data = content.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let object = json as? [String: Any] {
            
            print(object)
            if (!object.values.isEmpty) {
                let itemBarcode = object["штрихкод"] as! String
                if let _ = items[itemBarcode] {
                    return true
                }
                
                let itemName = object["название"] as! String
                let itemPrice = (object["цена_розн"] as! NSString).doubleValue
                var itemCurrency = object["валюта_название"] as! String
                let itemImgName = "MilkaChocoGrain.jpg"
                let byWeight = object["весовой"] as! String
            
                var itemByPiece = true
                if (byWeight == "ДА") { itemByPiece = false }
                if ((itemCurrency == "Российский рубль") || (itemCurrency == "")) { itemCurrency = "RUB" }
                
                let item = Item(barcode: barcode, name: itemName, price: itemPrice, currency: itemCurrency, img_name: itemImgName, byPiece: itemByPiece, quantity: 0)
                items[itemBarcode] = item
                return true
            }
            else {
                print("Item not found")
            }
        } else {
            print("JSON is invalid")
        }
    } catch {
        print(error.localizedDescription)
    }
    return false
}
