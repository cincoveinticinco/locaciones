//
//  SelectionCell.swift
//  AcciontvUpload
//
//  Created by 525 on 31/8/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import SwipeCellKit

class SelectionCell: SwipeTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    static var selectionTitles = ["SELECT","SELECT" ,"SELECT ATTRIBUTES"]
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        accessoryType = .disclosureIndicator
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        //self.superview?.frame = self.bounds
    }

}

extension UITableViewCell {
    func addBorderTop(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
    }
    func addBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
//        print("frame height: \(frame.height)")
//        print("frame width: \(frame.width)")
    }
    func addCleanBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 20, y: frame.height - size, width: frame.width - 30, height: size, color: color)
//        print("frame height: \(frame.height)")
//        print("frame width: \(frame.width)")
    }
    func addBorderLeft(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
    }
    func addBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(x: self.frame.width - size, y: 10, width: size, height: self.frame.height - 10, color: color)
        addBorderUtility(x: self.frame.width - size - 10, y: 15, width: size, height: self.frame.height - 20, color: color)
        addBorderUtility(x: self.frame.width - size - 15, y: 15, width: size, height: self.frame.height - 20, color: color)
        addBorderUtility(x: self.frame.width - size - 20, y: 15, width: size, height: self.frame.height - 20, color: color)
        //print("Add border right: x: \(self.frame.width) - \(size), y: 0, width: \(size), height: \(self.frame.height)")
    }
    
    func addCleanBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(x: frame.width - 10 - size, y: 10, width: size, height: frame.height - 10, color: color)
        //print("Add border right: x: \(frame.width) - \(size), y: 0, width: \(size), height: \(frame.height)")
    }
    private func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
}
