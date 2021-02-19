//
//  ViewController.swift
//  ForFun
//
//  Created by Никита Раташнюк on 16.01.2021.
//

import UIKit


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
    var barcode: Int?
    var itemsScanned = [Item]()
    var totalAmount = 0.00

    let alert = UIAlertController(title: "Товар не найден", message: "", preferredStyle: .alert)
    
    lazy var container: UIView = {
        var view = UIView()
        view.backgroundColor = .gray
        // view.frame.size = CGSize(width: barcodesScrollView.frame.width, height: barcodesScrollView.frame.height + 200)
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
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.cameraView.captureSession.startRunning()
        }))
        
        loadItems(filename: "ItemsData.json")
        
        // tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        self.tableView.rowHeight = 75
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
    
    @IBAction func goToHistoryVC(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let historyVC = storyboard.instantiateViewController(identifier: "HistoryVC")
        
        _ = navigationController?.pushVCFromLeft(vc: historyVC)
        
        // self.present(historyVC, animated:true, completion:nil)
    }
    
    @IBAction func payBtnClicked(_ sender: Any) {
        if itemsScanned.count == 0 { return }
        
        let success = true // TODO: Change when adding ApplePay
        
        if success {
            let now = Date()
            
            var total = 0
            for item in itemsScanned { total += (item.quantity * Int(item.price)) }
            
            let purchase = Purchase(items: itemsScanned, totalAmount: Double(total), date: now, paymentMethod: "card")
            purchase.saveGlobally()
            
            let doneAlert = UIAlertController(title: "Покупка добавлена в историю", message: "Спасибо за покупку!", preferredStyle: .alert)
            doneAlert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {_ in
                self.itemsScanned.removeAll()
                self.tableView.reloadData()
                self.refreshTotal()
                self.cameraView.captureSession.startRunning()
            }))
            self.presentViewController(alertController: doneAlert)
            self.cameraView.captureSession.stopRunning()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveBill(items: [Item]) {
        let str = items[0].name
        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")

        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Error occured")
        }
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
            
            // let index = IndexPath(row: 0, section: 0)
            // self.tableView.selectRow(at: index, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
            self.refreshTotal()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.cameraView.captureSession.startRunning()
            }
        } else {
            self.alert.message = "Штрихкод \(code) не найден!\nПопробуйте отсканировать еще раз, (или введите штрихкод вручную)"
            
            self.presentViewController(alertController: alert)
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
        totalAmountLabel.text = String(format: "%.02f", totalAmount) + " RUB"
    }
    
    func presentViewController(alertController: UIAlertController, completion: (() -> Void)? = nil) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            DispatchQueue.main.async {
                topController.present(alertController, animated: true, completion: completion)
            }
        }
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


//class CustomAlert {
//    var vc: UIViewController?
//    var title: UILabel
//    var message: UILabel
//    var view: UIView
//    // var image:
//
//    init(title: String, message: String) {
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
//        // label.center = CGPoint(160, 284)
//        label.textAlignment = .center
//        label.text = title
//        self.title = label
//        self.message = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        self.view = UIView()
//    }
//
//    func setup(vc: UIViewController) {
//        self.vc = vc
//        self.view = UIView(frame: CGRect(x: 100, y: 100, width: superview.frame.width / 2, height: superview.frame.height / 2))
//        self.view.backgroundColor = .red
//        self.view.addSubview(self.title)
//        // self.view.isHidden = true
//        self.vc!.addSubview(self.view)
//        // self.superview!.bringSubviewToFront(self.view)
//    }
//
//    func show() {
//        // self.view.isHidden = false
//        if let vc = self.vc {
//            vc.present(self, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//        }
//    }
//}
