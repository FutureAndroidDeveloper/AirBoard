//
//  ListIndexBacklightView.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/1/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import UIKit

@IBDesignable class ListIndexBacklightView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var letterLabel: UILabel!
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Private Methods
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ListIndexBackLightView", owner: self, options: nil)
        addSubview(contentView)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
