//
//  DeleteAllTableViewCell.swift
//  AcciontvUpload
//
//  Created by 525 on 28/3/18.
//  Copyright © 2018 525. All rights reserved.
//

import UIKit

class DeleteAllTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteAllButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deleteAllButton.setTitle(NSLocalizedString("DELETE ALL UPLOADED LOCATIONS", comment: ""), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
