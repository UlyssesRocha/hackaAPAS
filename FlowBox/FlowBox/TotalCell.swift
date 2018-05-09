//
//  TotalCell.swift
//  FlowBox
//
//  Created by Ulysses Rocha on 08/05/2018.
//  Copyright © 2018 Ulysses Rocha. All rights reserved.
//

import UIKit

class TotalCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setPrice(cents:Double) {
        var out = "R$ "
        out.append(String(format: "$%.02f", cents))
        label.text = out
    }
}
