//
//  AreaCell.swift
//  Rakubaru
//
//  Created by LGH on 3/18/21.
//

import UIKit

class AreaCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var areaNameBox: UILabel!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var copiesBox: UILabel!
    @IBOutlet weak var amountBox: UILabel!
    @IBOutlet weak var distanceBox: UILabel!
    @IBOutlet weak var timeBox: UILabel!
    @IBOutlet weak var durationBox: UILabel!
    @IBOutlet weak var distributionBox: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
