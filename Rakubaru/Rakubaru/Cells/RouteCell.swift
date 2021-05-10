//
//  RouteCell.swift
//  Rakubaru
//
//  Created by Andre on 11/26/20.
//

import UIKit

class RouteCell: UITableViewCell {
    
    @IBOutlet weak var nameBox: UILabel!
    @IBOutlet weak var timeBox: UILabel!
    @IBOutlet weak var durationBox: UILabel!
    @IBOutlet weak var distanceBox: UILabel!
    @IBOutlet weak var speedBox: UILabel!
    @IBOutlet weak var descBox: UITextView!
    @IBOutlet weak var statusBox: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var areaNameBox: UILabel!
    @IBOutlet weak var assignTitleBox: UILabel!    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
