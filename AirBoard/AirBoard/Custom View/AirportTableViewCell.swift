//
//  AirportTableViewCell.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/27/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class AirportTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var airportLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var icaoLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
