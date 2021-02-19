//
//  PurchaseCellVC.swift
//  ForFun
//
//  Created by Никита Раташнюк on 16.02.2021.
//

import UIKit

class PurchaseCellVC: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    
    @IBOutlet var itemOneLabel: UILabel!
    @IBOutlet var itemTwoLabel: UILabel!
    @IBOutlet var itemThreeLabel: UILabel!
    @IBOutlet var totalAmountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
