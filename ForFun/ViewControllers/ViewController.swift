//
//  ViewController.swift
//  ForFun
//
//  Created by Никита Раташнюк on 16.01.2021.
//

import UIKit
import MapKit


protocol BarcodeDelegate {
    func onBarcodeRecieved(barcode code: String)
}

protocol QuantityDelegate {
    func modifyQuantity(barcode: String, value: Int)
}


class ViewController: UIViewController, BarcodeDelegate, QuantityDelegate {

    @IBOutlet weak var barcodesLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalAmountLabel: UILabel!
    @IBOutlet var paymentButton: UIButton!
    var cameraView: BarScannerView!
    var barcodesScrollView = UIScrollView()
    var barcode: Int?
    var itemsScanned = [Item]()
    var totalAmount = 0.00

    // let alert = UIAlertController(title: "Товар не найден", message: "", preferredStyle: .alert)
    
    lazy var container: UIView = {
        var view = UIView()
        view.backgroundColor = .gray
        view.frame.size = CGSize(width: barcodesScrollView.frame.width, height: barcodesScrollView.frame.height + 200)
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .red
        label.text = "HOORAY!!!"
        return label
    }()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems(filename: "ItemsData.json")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = 75;
        
        barcodesScrollView.frame = CGRect(x: 10, y: self.barcodesLabel.frame.maxY + self.barcodesLabel.frame.height + 30, width: self.view.frame.width - 20, height: self.view.frame.height - 10 - self.barcodesLabel.frame.maxY + 10)
        
        // self.alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // self.present(alert, animated: true, completion: nil)
        
//         self.view.addSubview(barcodesScrollView)
//
//         barcodesScrollView.addSubview(container)
//         barcodesScrollView.contentSize = container.bounds.size
//
//        container.addSubview(label)
//
//        label.frame = CGRect(x: container.frame.minX + 5, y: (container.frame.minY + container.frame.maxY) / 2, width: container.frame.width - 10, height: 50)
//        label.textAlignment = .center
//
//         label.widthAnchor.constraint(equalToConstant: 250).isActive = true
//         label.heightAnchor.constraint(equalToConstant: 100).isActive = true
//         label.centerXAnchor.constraint(equalTo: self.container.centerXAnchor).isActive = true
//         label.centerYAnchor.constraint(equalTo: self.container.centerYAnchor).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // get a reference to the embedded PageViewController on load

        if let vc = segue.destination as? BarScannerView,
            segue.identifier == "cameraViewEmbedSegue" {
            self.cameraView = vc
            self.cameraView.delegate = self
        }
    }
    
    @IBAction func goToScanner(_ sender: Any) {
        self.cameraView.captureSession.startRunning()
//        present(vc, animated: true, completion: nil)
    }
    
    func onBarcodeRecieved(barcode code: String) {
        print("Got a Barcode: \(code)")
        let success = loadItemFromURL(link: "http://82.162.63.210:25252/?cmd=getGoodsByBarcode&Barcode=\(code)&encode=UTF8", barcode: code)
        if success {
            var item: Item!
            
            if let index = itemsScanned.firstIndex(where: { $0.barcode == code }) {
                item = itemsScanned[index]
                itemsScanned.remove(at: index)
            }
            else {
                item = items[code]!
            }
            
            item.quantity += 1
            itemsScanned.insert(item, at: 0)
            self.tableView.reloadData()
            
            let index = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: index, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
            self.refreshTotal()
        } else {
            // self.alert.message = "Штрихкод \(code) не найден!\nПопробуйте отсканировать еще раз, (или введите штрихкод вручную)"
            // self.present(alert, animated: true, completion: nil)
            
            
            // let noItem = NotFoundItem(barcode: code)
            // noItem.showErrorAlert()
        }
    }
    
    func modifyQuantity(barcode: String, value: Int) {
        for i in 0..<itemsScanned.count {
            if itemsScanned[i].barcode == barcode {
                if itemsScanned[i].quantity + value > 0 { itemsScanned[i].quantity += value }
                else { itemsScanned.remove(at: i) }
                break
            }
        }
        self.tableView.reloadData()
        self.refreshTotal()
        // items[barcode]!.quantity += value
    }
    
    func refreshTotal() {
        totalAmount = 0.00
        for i in 0..<itemsScanned.count {
            totalAmount += itemsScanned[i].price * Double(itemsScanned[i].quantity)
        }
        totalAmountLabel.text = String(totalAmount) + "RUB"
    }
}


extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}


extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped..")
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsScanned.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let itemCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ItemCellVC else {
            return UITableViewCell()
        }
        
        let item = itemsScanned[indexPath.row]
        
        itemCell.delegate = self
        itemCell.barcode = item.barcode
        itemCell.nameLabel.text = item.name
        itemCell.priceLabel.text = String(format: "%.02f", (item.price * Double(item.quantity))) + " \(item.currency)"
        itemCell.imgView.image = item.image
        itemCell.quantityLabel.text = String(item.quantity) + " шт"
        
        return itemCell
    }
    
}
