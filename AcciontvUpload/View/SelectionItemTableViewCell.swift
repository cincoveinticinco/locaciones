//
//  SelectionItemTableViewCell.swift
//  AcciontvUpload
//
//  Created by 525 on 31/8/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit

class SelectionItemTableViewCell: UITableViewCell {

    var item: SelectionItemViewModel? {
        didSet {
            titleLabel?.text = NSLocalizedString((item?.title)!, comment: "")
//            isSelected ? checkedButton.setImage(UIImage.init(named: "Checked Icon"), for: .normal) : checkedButton.setImage(UIImage.init(named: "Unchecked Icon"), for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
//        isSelected ? checkedButton.setImage(UIImage.init(named: "Checked Icon"), for: .normal) : checkedButton.setImage(UIImage.init(named: "Unchecked Icon"), for: .normal)
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var checkedButton: UIButton!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selected ? checkedButton.setImage(UIImage.init(named: "Checked Icon"), for: .normal) : checkedButton.setImage(UIImage.init(named: "Unchecked Icon"), for: .normal)
        print("\(item!.title) Item is SelecteD::    \(selected)")
    }

}
