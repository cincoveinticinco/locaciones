//
//  TasksQueueViewController.swift
//  AcciontvUpload
//
//  Created by 525 on 13/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import SwipeCellKit

class TasksQueueViewController: UIViewController {
    
    @IBOutlet weak var tasksTableView: UITableView!
    
    // MARK: - Life Cycle
    
    var locations = LocationData.data.getLocations() {
        didSet {
            tasksTableView.reloadData()
        }
    }
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationIcons()
        
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        tasksTableView.rowHeight = 90
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func openMenu(_ sender: UIButton?) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "User Menu") as! UserMenuTableViewController
        popoverContent.user = self.user
        popoverContent.tableView.reloadData()
        popoverContent.modalPresentationStyle = .popover

        if let popover = popoverContent.popoverPresentationController {
            let viewForSource = sender! as UIView
            popover.sourceView = viewForSource
            popover.sourceRect = viewForSource.bounds
            popoverContent.preferredContentSize = CGSize(width: 270, height: 90)
            popover.delegate = self
        }
        
        self.present(popoverContent, animated: true, completion: nil)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            self.presentedViewController?.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
        }
    }
    
}

// MARK: - TableView Delegate

extension TasksQueueViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let rows: Int = LocationData.data.locations.count
        if locations.count > 0 {
            return locations.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Delete") as? DeleteAllTableViewCell {
                cell.deleteAllButton.titleLabel?.text = NSLocalizedString("DELETE ALL UPLOADED LOCATIONS", comment: "")
                cell.deleteAllButton.addTarget(self, action: #selector(TasksQueueViewController.deleteAll), for: .touchUpInside)
                return cell
            }
        } else {
            if (locations[indexPath.row-1].thumbnail != nil) {
                if locations.count > 0 {
                    if indexPath.row == 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "Delete") as? DeleteAllTableViewCell {
                            cell.deleteAllButton.titleLabel?.text = NSLocalizedString("DELETE ALL UPLOADED LOCATIONS", comment: "")
                            cell.deleteAllButton.addTarget(self, action: #selector(TasksQueueViewController.deleteAll), for: .touchUpInside)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "Location Image", for: indexPath) as? TasksQueueLocationCell {
                            cell.delegate = self
                            print("entering task vew controller with image")
                            print(locations[indexPath.row - 1])
                            print(indexPath.row)
                            var descriptonString = locations[indexPath.row-1].address! + ", " +  locations[indexPath.row-1].city! + ", " +  locations[indexPath.row-1].postalCode!
                            if locations[indexPath.row - 1].unit != nil {
                                if locations[indexPath.row - 1].unit != "" || locations[indexPath.row - 1].unit != " " {
                                    descriptonString = locations[indexPath.row-1].address! + ", \(locations[indexPath.row - 1].unit!)" + ", " +  locations[indexPath.row-1].city! + ", " +  locations[indexPath.row-1].postalCode!
                                }
                            }
                            cell.locationNameLabel.text = locations[indexPath.row-1].name!
                            cell.locationDescriptionLabel.text = descriptonString
                            cell.locationImage.image = locations[indexPath.row-1].thumbnail
                            if locations[indexPath.row-1].status == .Offline {
                                cell.locationStateButton.backgroundColor = #colorLiteral(red: 0.9538540244, green: 0.2200518847, blue: 0.3077117205, alpha: 1)
                            } else {
                                cell.locationStateButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                            }
                            cell.detailPhotosLabel.text = "Photos: uploaded"
                            cell.numberOfPicsLabel.text = "\(locations[indexPath.row-1].numberOfPics!)"
                            return cell
                        }
                        
                    }
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Location Image", for: indexPath) as? TasksQueueLocationCell {
                    if locations.count > 0 {
                        if indexPath.row == 0 {
                            if let cell = tableView.dequeueReusableCell(withIdentifier: "Delete") {
                                return cell
                            }
                        } else {
                            cell.delegate = self
                            print("entering task vew controller")
                            print(locations[indexPath.row - 1])
                            print(indexPath.row)
                            cell.locationImage.image = #imageLiteral(resourceName: "LocationImageNone")
                            var descriptonString = locations[indexPath.row - 1].address! + ", " +  locations[indexPath.row - 1].city! + ", " +  locations[indexPath.row - 1].postalCode!
                            if locations[indexPath.row - 1].unit != nil {
                                if locations[indexPath.row - 1].unit != "" || locations[indexPath.row - 1].unit != " " {
                                    descriptonString = locations[indexPath.row-1].address! + ", \(locations[indexPath.row - 1].unit!)" + ", " +  locations[indexPath.row-1].city! + ", " +  locations[indexPath.row-1].postalCode!
                                }
                                
                            }
                            cell.locationNameLabel.text = locations[indexPath.row - 1].name!
                            cell.locationDescriptionLabel.text = descriptonString
                            if locations[indexPath.row - 1].status == .Offline {
                                cell.locationStateButton.backgroundColor = #colorLiteral(red: 0.9538540244, green: 0.2200518847, blue: 0.3077117205, alpha: 1)
                            } else {
                                cell.locationStateButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                            }
                            cell.numberOfPicsLabel.text = "\(locations[indexPath.row-1].numberOfPics!)"
                            // cell.locationStateButton.backgroundColor = UIColor.red
                            return cell
                        }
                    }
                    
                }
            }
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: NSLocalizedString("DELETE ALL UPLOADED CONTENT", comment: ""), message: NSLocalizedString("Do you want to delete all locations from this list?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: {
                action in

                for (_, _) in self.locations.enumerated() {
                    if LocationData.data.deleteLocation(locationId: self.locations[0].rowId!) != false {
                        self.locations.remove(at: 0)
                        self.tasksTableView.reloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("UPLOADED SUCCESSFULLY", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete from List", comment: ""), style: UIAlertActionStyle.default, handler: {
                action in
                if LocationData.data.deleteLocation(locationId: self.locations[indexPath.row - 1].rowId!) != false {
                    self.locations.remove(at: indexPath.row - 1)
                    self.tasksTableView.reloadData()
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in

            let alert = UIAlertController(title: NSLocalizedString("DELETE LOCATION", comment: ""), message: NSLocalizedString("This location will be only deleted from the list, would you like to proceed?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                action in
                
                if LocationData.data.deleteLocation(locationId: self.locations[indexPath.row - 1].rowId!) != false {
                    self.locations.remove(at: indexPath.row - 1)
                    self.tasksTableView.reloadData()
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.default, handler: { action in
                tableView.setEditing(false, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        deleteAction.backgroundColor = UIColor(red: 259/250, green: 109/250, blue: 118/250, alpha: 1.0)
        deleteAction.image = #imageLiteral(resourceName: "Trash Icon").imageResize(sizeChange: CGSize(width: 18, height: 24))
        
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .border
        return options
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50
        } else {
            return 90
        }
    }
    
    @objc func deleteAll() {
        let alert = UIAlertController(title: NSLocalizedString("DELETE ALL UPLOADED CONTENT", comment: ""), message: NSLocalizedString("Do you want to delete all locations from this list?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: {
            action in
            
            for (_, _) in self.locations.enumerated() {
                if LocationData.data.deleteLocation(locationId: self.locations[0].rowId!) != false {
                    self.locations.remove(at: 0)
                    self.tasksTableView.reloadData()
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
