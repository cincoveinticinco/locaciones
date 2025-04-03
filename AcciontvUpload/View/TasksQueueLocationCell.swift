//
//  TasksQueueLocationCell.swift
//  AcciontvUpload
//
//  Created by 525 on 13/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import SwipeCellKit

class TasksQueueLocationCell: SwipeTableViewCell {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDescriptionLabel: UILabel!
    @IBOutlet weak var locationStateButton: UIButton!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var detailPhotosLabel: UILabel!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var numberOfPicsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberView.layer.cornerRadius = 10
        //LocationData.data
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
