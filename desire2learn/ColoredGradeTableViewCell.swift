//
//  ColoredGradeTableViewCell.swift
//  desire2learn
//
//  Created by John Keller on 12/8/16.
//  Copyright © 2016 John Keller. All rights reserved.
//

import UIKit

class ColoredGradeTableViewCell: UITableViewCell {
    @IBOutlet weak var ClassName: UILabel!
    @IBOutlet weak var Percent: UILabel!
    @IBOutlet weak var DisplayLetter: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
