//
//  PurchaseDetailsVC.swift
//  ForFun
//
//  Created by Никита Раташнюк on 19.02.2021.
//

import UIKit

class PurchaseDetailsVC: UIViewController {
    
    @IBOutlet var itemsTableView: UITableView!
    @IBOutlet var operationDateLabel: UILabel!
    @IBOutlet var totalAmountLabel: UILabel!
    @IBOutlet var purchaseIDLabel: UILabel!
    var purchase: Purchase!
    
    private let drawAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 15.0),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationController?.isNavigationBarHidden = false
        
        let userDefaults = UserDefaults.standard
        do { purchase = try userDefaults.getObject(forKey: defaultsKeys.purchaces, castTo: [Purchase].self)[0] }
        catch { print(error.localizedDescription) }
        
        purchase.writeToJSON(completion: {data in
            self.setPurchaseID(id: data)
        })
        
        operationDateLabel.text = purchase.getDay() + "." + purchase.getMonthNumber() + "." + purchase.getYear()
        totalAmountLabel.text = String(format: "%.02f", purchase.totalAmount) + " ₽"
        purchaseIDLabel.clipsToBounds = true
        purchaseIDLabel.layer.cornerRadius = 10
        
        self.itemsTableView.delegate = self
        self.itemsTableView.dataSource = self
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func setPurchaseID(id: String?) {
        if (id != nil) {
            DispatchQueue.main.async {
                self.purchaseIDLabel.text = " Покупка №" + String(id!) + " "
            }
        }
    }
}


extension PurchaseDetailsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchase.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? DetailsCellVC else {
            return UITableViewCell()
        }
        let item = purchase.items[indexPath.row]
        
        itemCell.itemNameLabel.text = item.name
        itemCell.quantityLabel.text = String(format: "%.02f", item.price * Double(item.quantity)) + " ₽ (" + String(item.quantity) + " шт.)"
        
        return itemCell
    }
}
