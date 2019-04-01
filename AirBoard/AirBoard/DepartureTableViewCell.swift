//
//  FlightTableViewCell.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 3/25/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

class DepartureTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var departureTimeLabel: UILabel!
    @IBOutlet weak var arrivalCityLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
