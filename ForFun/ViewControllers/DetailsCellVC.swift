//
//  DetailsCellVC.swift
//  ForFun
//
//  Created by Никита Раташнюк on 21.02.2021.
//

import UIKit

class DetailsCellVC: UITableViewCell {
    
    @IBOutlet var itemNameLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
