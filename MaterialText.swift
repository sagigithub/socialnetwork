//
//  MaterialText.swift
//  socialnetwork
//
//  Created by Sagi Herman on 18/05/2016.
//  Copyright © 2016 sagi. All rights reserved.
//

import UIKit

class MaterialText: UITextField {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.borderWidth = 1.0
    }
        //For place holder
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
        //For edit mode
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
        
}
