//
//  ProductCell.swift
//  FlowBox
//
//  Created by Ulysses Rocha on 08/05/2018.
//  Copyright © 2018 Ulysses Rocha. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    
    
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var count: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setCell(name:String, count:Int, cents:Double) {
        var out = "R$ "
        out.append(String(format: "$%.02f", cents))
        price.text = out
        
        self.name.text = name
        self.count.text = String(count)
    }

}
