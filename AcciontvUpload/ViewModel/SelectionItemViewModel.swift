//
//  SelectionItemViewModel.swift
//  AcciontvUpload
//
//  Created by 525 on 31/8/17.
//  Copyright © 2017 525. All rights reserved.
//

import Foundation
import UIKit


var isSearching = false

class SelectionItemViewModel {
    private var item: SelectionItemModel
    
    var isSelected = false
    
    var title: String {
        return item.title
    }
    
    init(item: SelectionItemModel) {
        self.item = item
    }
}

class SelectionViewModel: NSObject {
    var array: [SelectionItemModel] = []
    
    var items = [SelectionItemViewModel]()
    var filteredItems = [SelectionItemViewModel]()
    var table = UITableView()
    var selector: SelectionItemViewController.Selector = .category
    
    var didToggleSelection: ((_ hasSelection: Bool) -> ())? {
        didSet {
            didToggleSelection?(!selectedItems.isEmpty)
        }
    }
    
    var selectedItems: [SelectionItemViewModel] {
        return items.filter { return $0.isSelected }
    }
    
    override init() {
        super.init()
        //items = array.map { SelectionItemViewModel(item: $0) }
    }
    init(withItems items: [String]) {
        self.array = items.map({SelectionItemModel(title: $0)})
        self.items = array.map { SelectionItemViewModel(item: $0) }
    }
}

extension SelectionViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            print("numberOfRowsInSection is searching")
            return filteredItems.count
        }
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SelectionItemTableViewCell.identifier, for: indexPath) as? SelectionItemTableViewCell {
            if isSearching {
                print("is searching")
                cell.item = filteredItems[indexPath.row]
                // select/deselect the cell
                if filteredItems[indexPath.row].isSelected {
                    if !cell.isSelected {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                } else {
                    if cell.isSelected {
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                }
            } else {
                cell.item = items[indexPath.row]
                if items[indexPath.row].isSelected {
                    print("items[indexPath.row].isSelected")
                    if !cell.isSelected {
                        print("this cell us selected")
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        cell.item?.isSelected = true
                        //cell.setSelected(false, animated: false)
                    }
                } else {
                    print("\(cell.item?.title) items[indexPath.row].isSelected IS NOT SELECTED")
                    if cell.isSelected {
                        tableView.deselectRow(at: indexPath, animated: true)
                        cell.item?.isSelected = false
                        print("cell us selected, tableview deselectrow, is selectd FALSE")
                        //cell.setSelected(true, animated: false)
                    }
                }
            }

            didToggleSelection?(!selectedItems.isEmpty)
            return cell
        }
        return UITableViewCell()
    }
}

extension SelectionViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? SelectionItemTableViewCell {
            print("let cell SelectionItemTableViewCell")
            if isSearching {
                print("if isSearching ddiSelectRow is searching")
                if filteredItems[indexPath.row].isSelected {
                    filteredItems[indexPath.row].isSelected = false
                    
                } else {
                    filteredItems[indexPath.row].isSelected = true
                }
            } else {
                print("\n indexesss:")
                
                if selector == .category {
                    
                    for i in 0 ..< items.count{
                        
                        //let row = tableView.cellForRow(at: i) as? SelectionItemTableViewCell
                        items[i].isSelected = false
                        //tableView.deselectRow(at: indexPath, animated: false)
                        //row?.setSelected(false, animated: false)
                    }
                    /*for (i, item) in self.items as SelectionItemViewModel{
                            print(i)
                            let row = tableView.cellForRow(at: i) as? SelectionItemTableViewCell
                            items[i.row].isSelected = false
                            //tableView.deselectRow(at: indexPath, animated: false)
                            row?.setSelected(false, animated: false)
                        }
                       }*/

                }
                print("INDEX PAT:")
                print(indexPath.row)
                dump(items[indexPath.row])
                print(tableView.indexPathsForSelectedRows)
                if items[indexPath.row].isSelected {
                    print("didSelectRow \(cell.item?.title) Is Selected")
                    items[indexPath.row].isSelected = false
                    //tableView.deselectRow(at: indexPath, animated: false)
                    cell.setSelected(false, animated: false)
                } else {
                    print("didSelectRow \(cell.item?.title) Is NOT Selected")
                    items[indexPath.row].isSelected = true
                    //tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    cell.setSelected(true, animated: false)
                }
            }
            
            if selector == .schedule {
                let indexWeekdays = IndexPath(row: 0, section: 0)
                let indexWeekends = IndexPath(row: 1, section: 0)
                let indexAll = IndexPath(row: 2, section: 0)
                let indexCustom = IndexPath(row: 3, section: 0)
                let indexMonday = IndexPath(row: 4, section: 0)
                let indexTuesday = IndexPath(row: 5, section: 0)
                let indexWednesday = IndexPath(row: 6, section: 0)
                let indexThursday = IndexPath(row: 7, section: 0)
                let indexFriday = IndexPath(row: 8, section: 0)
                let indexSaturday = IndexPath(row: 9, section: 0)
                let indexSunday = IndexPath(row: 10, section: 0)
                
                switch indexPath.row {
                case 0:
                    // Weekdays
                    self.table.selectRow(at: indexMonday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexTuesday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexWednesday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexThursday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexFriday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.deselectRow(at: indexWeekends, animated: true)
                    self.table.deselectRow(at: indexAll, animated: true)
                    self.table.deselectRow(at: indexCustom, animated: true)
                case 1:
                    self.table.selectRow(at: indexSaturday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexSunday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.deselectRow(at: indexWeekdays, animated: true)
                    self.table.deselectRow(at: indexAll, animated: true)
                    self.table.deselectRow(at: indexCustom, animated: true)
                    self.table.deselectRow(at: indexMonday, animated: true)
                    self.table.deselectRow(at: indexTuesday, animated: true)
                    self.table.deselectRow(at: indexWednesday, animated: true)
                    self.table.deselectRow(at: indexThursday, animated: true)
                    self.table.deselectRow(at: indexFriday, animated: true)
                case 2:
                    self.table.selectRow(at: indexMonday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexTuesday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexWednesday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexThursday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexFriday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexSaturday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.selectRow(at: indexSunday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.deselectRow(at: indexWeekends, animated: true)
                    self.table.deselectRow(at: indexWeekdays, animated: true)
                    self.table.deselectRow(at: indexAll, animated: true)
                    self.table.deselectRow(at: indexCustom, animated: true)
                case 3:
                    self.table.selectRow(at: indexMonday, animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.table.deselectRow(at: indexWeekdays, animated: true)
                    self.table.deselectRow(at: indexWeekdays, animated: true)
                    self.table.deselectRow(at: indexAll, animated: true)
                    self.table.deselectRow(at: indexCustom, animated: true)
                    self.table.deselectRow(at: indexMonday, animated: true)
                    self.table.deselectRow(at: indexTuesday, animated: true)
                    self.table.deselectRow(at: indexWednesday, animated: true)
                    self.table.deselectRow(at: indexThursday, animated: true)
                    self.table.deselectRow(at: indexFriday, animated: true)
                    
                default:
                    break
                }
            }
            
            print(selectedItems)
            
            didToggleSelection?(!selectedItems.isEmpty)
        }
        
        // update ViewModel item
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SelectionItemTableViewCell {
            print("cell DESELECT SelectionItemTableViewCell")
            if isSearching {
                print("if isSearching ddidesedlectSelectRow is searching")
                if filteredItems[indexPath.row].isSelected {
                    filteredItems[indexPath.row].isSelected = false
                    
                } else {
                    filteredItems[indexPath.row].isSelected = true
                }
            } else {
                print("\n Deselect indexesss: \(indexPath.row)")
                dump(items[indexPath.row])
                if items[indexPath.row].isSelected {
                    print("deselect didSelectRow \(cell.item?.title) Is Selected")
                    items[indexPath.row].isSelected = false
                    //tableView.deselectRow(at: indexPath, animated: false)
                    cell.setSelected(false, animated: false)
                } else {
                    print("deselect didSelectRow \(cell.item?.title) Is NOT Selected")
                    items[indexPath.row].isSelected = true
                    //tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    cell.setSelected(true, animated: false)
                }
            }
            
            didToggleSelection?(!selectedItems.isEmpty)
        }
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //let customColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        //var cellColors = [UIColor.white , customColor]
        //cell.contentView.backgroundColor = cellColors[indexPath.row % cellColors.count]
        cell.layoutIfNeeded()
        cell.addCleanBorderRight(size: 1.0, color: UIColor.lightGray)
        cell.addCleanBorderBottom(size: 1.0, color: UIColor.lightGray)
    }
}

extension SelectionViewModel: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            searchBar.resignFirstResponder()
            table.reloadData()
        } else {
            isSearching = true
            
            filteredItems = items.filter({$0.title.range(of: searchBar.text!, options: .caseInsensitive) != nil})
            print(filteredItems)
            table.reloadData()
        }
    }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        isSearching = false
//        print("\nsearchBarTextDidEndEditing")
//    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
