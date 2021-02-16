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

    let alert = UIAlertController(title: "Товар не найден", message: "", preferredStyle: .alert)
    
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
        
        self.alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.cameraView.captureSession.startRunning()
        }))
        
        loadItems(filename: "ItemsData.json")
        
        // tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        self.tableView.rowHeight = 75;
        
        barcodesScrollView.frame = CGRect(x: 10, y: self.barcodesLabel.frame.maxY + self.barcodesLabel.frame.height + 30, width: self.view.frame.width - 20, height: self.view.frame.height - 10 - self.barcodesLabel.frame.maxY + 10)
        
        // self.view.addSubview(alert.view)
        // alert.view.isHidden = true
        
        // self.myAlert.setup(superview: self.view)
        
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
