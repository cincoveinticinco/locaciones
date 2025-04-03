//
//  SelectionItemViewController.swift
//  AcciontvUpload
//
//  Created by 525 on 31/8/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit

protocol SelectionItemDelegate {
    func saveSelection(controller: SelectionItemViewController)
}


class SelectionItemViewController: UIViewController {
    
    var selectionItems: [String] = []
    var viewModel = SelectionViewModel()
    var checkedItems: [String] = []
    var selectionType: SelectionType = .single
    var selector: Selector = .category
    var delegate: SelectionItemDelegate?
    
    enum Selector {
        case category
        case subcategory
        case attribute
        case production
        case schedule
        case parking
    }
    
    enum SelectionType {
        case single
        case multiple
    }
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var addItemsButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func addItem(_ sender: UIButton) {
        checkedItems = viewModel.selectedItems.flatMap({$0.title})
        if selector == .schedule || selector == .attribute || selector == .parking {
            self.performSegue(withIdentifier: "unwindToViewSegueId", sender: self)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationIcons()
        viewModel = SelectionViewModel(withItems: selectionItems.map {$0.capitalized})

        itemsTableView?.register(SelectionItemTableViewCell.nib, forCellReuseIdentifier: SelectionItemTableViewCell.identifier)
        itemsTableView?.estimatedRowHeight = 50
        itemsTableView?.rowHeight = 50
        itemsTableView?.dataSource = viewModel
        itemsTableView?.delegate = viewModel
        itemsTableView?.separatorStyle = .none
        switch selectionType {
        case .single:
            itemsTableView?.allowsSelection = true
            itemsTableView.allowsMultipleSelection = false
        case .multiple:
            itemsTableView?.allowsMultipleSelection = true
        }
        viewModel.table = itemsTableView
        viewModel.selector = selector
        searchBar.delegate = viewModel
        searchBar.returnKeyType = .done
        viewModel.didToggleSelection = { [weak self] hasSelection in
            self?.addItemsButton?.isHidden = !hasSelection
            self?.addItemsButton.isEnabled = hasSelection
        }
        
        searchBar.searchBarStyle = UISearchBarStyle.prominent
        searchBar.isTranslucent = false
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.white
        searchBar.barTintColor = UIColor.white
        
        addItemsButton.layer.borderWidth = 1.0
        addItemsButton.layer.borderColor = UIColor.lightGray.cgColor
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\nitemsTableView indexes: ")
        switch selectionType {
        case .single:
            viewModel.table.allowsSelection = true
            viewModel.table.allowsMultipleSelection = false
        case .multiple:
            viewModel.table.allowsMultipleSelection = true
        }
        isSearching = false
        if checkedItems.count > 0 {
            if selectionType == .single {
                while checkedItems.count > 1 {
                    let newArray = checkedItems.filter { $0 == checkedItems.last }
                    checkedItems = newArray
                }
            }
            print(checkedItems)
            for item in checkedItems {
                let index = self.selectionItems.index(where: {$0.localizedCaseInsensitiveContains(item)})
                let indexPath = IndexPath(row: index!, section: 0)
                //self.itemsTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                self.viewModel.items[indexPath.row].isSelected = true
                print(" \(index!) is selected: \(self.viewModel.items[indexPath.row].isSelected)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if (!(parent?.isEqual(self.parent) ?? false)) {
            saveSelection()
            print("saving selection")
            if (delegate != nil && checkedItems.count > 0) {
                delegate!.saveSelection(controller: self)
                print(viewModel.selectedItems.flatMap({$0.title}))
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showSelectedItems(items: [String]) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }

}

extension SelectionItemViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Production" {
            let productionVC = segue.destination as! ProductionLocationViewController
            productionVC.production.title = checkedItems[0]
            
        }
    }
    
    func saveSelection() {
       checkedItems = viewModel.selectedItems.flatMap({$0.title})
       }
}

