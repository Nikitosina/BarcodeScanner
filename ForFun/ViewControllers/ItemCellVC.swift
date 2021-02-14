//
//  ItemCellVC.swift
//  ForFun
//
//  Created by Никита Раташнюк on 20.01.2021.
//

import UIKit

class ItemCellVC: UITableViewCell {
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var minusButton: UIButton!
    var barcode: String!
    var delegate: QuantityDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onPlusTapped(_ sender: Any) {
        delegate?.modifyQuantity(barcode: barcode, value: 1)
    }
    
    @IBAction func onMinusTapped(_ sender: Any) {
        delegate?.modifyQuantity(barcode: barcode, value: -1)
    }
}
