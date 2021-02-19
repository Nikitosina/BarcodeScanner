//
//  HistoryVC.swift
//  ForFun
//
//  Created by Никита Раташнюк on 16.02.2021.
//

import UIKit

class HistoryVC: UIViewController {
    @IBOutlet var historyTableView: UITableView!
    var purchases: [Purchase]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults.standard
        do { purchases = try userDefaults.getObject(forKey: defaultsKeys.purchaces, castTo: [Purchase].self) }
        catch { print(error.localizedDescription) }
        
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        self.historyTableView.rowHeight = 100
    }
    
    
    @IBAction func goToMainScreen(_ sender: Any) {
        _ = navigationController?.popVCToLeft()
    }
    
}


extension HistoryVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let purchaseCell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as? PurchaseCellVC else {
            return UITableViewCell()
        }
        
        let purchase = purchases[indexPath.row]
        
        purchaseCell.dateLabel.text = purchase.getDay()
        purchaseCell.monthLabel.text = purchase.getMonth()
        purchaseCell.yearLabel.text = purchase.getYear()
        
        let topThreeItems = purchase.getTopThreeItems()
        purchaseCell.itemOneLabel.text = "\u{2022} " + topThreeItems[0].name
        purchaseCell.itemTwoLabel.text = "\u{2022} " + topThreeItems[1].name
        purchaseCell.itemThreeLabel.text = "\u{2022} " + topThreeItems[2].name
        
        purchaseCell.totalAmountLabel.text = String(format: "%.02f", purchase.totalAmount) + "\nRUB"
        
        return purchaseCell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Вы уверены, что хотите удалить покупку?", message: "Покупка пропадет из истории чеков навсегда", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Отменить", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Продолжить", style: .destructive, handler: {_ in
                tableView.beginUpdates()
                
                self.purchases.remove(at: indexPath.row)
                // remove globally!!!
                do { try UserDefaults.standard.setObject(self.purchases, forKey: defaultsKeys.purchaces) }
                catch { print(error.localizedDescription) }
                tableView.deleteRows(at: [indexPath], with: .left)
                
                tableView.endUpdates()
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
}
