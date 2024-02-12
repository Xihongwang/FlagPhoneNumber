//
//  FPNCountryListViewController.swift
//  FlagPhoneNumber
//
//  Created by Aurélien Grifasi on 06/08/2017.
//  Copyright (c) 2017 Aurélien Grifasi. All rights reserved.
//

import UIKit

open class FPNCountryListViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {

	open var repository: FPNCountryRepository?
	open var showCountryPhoneCode: Bool = true
	open var searchController: UISearchController = UISearchController(searchResultsController: nil)
	open var didSelect: ((FPNCountry) -> Void)?

	var results: [FPNCountry]?

    var countrySections: [String] = []
    var countryDictionaries: [String:[FPNCountry]] = [:]
    
	override open func viewDidLoad() {
		super.viewDidLoad()

		tableView.tableFooterView = UIView()
        
        self.sortCountry()
		initSearchBarController()
	}

	open func setup(repository: FPNCountryRepository) {
		self.repository = repository
	}

	private func initSearchBarController() {
		searchController.searchResultsUpdater = self
		searchController.delegate = self

		if #available(iOS 9.1, *) {
			searchController.obscuresBackgroundDuringPresentation = false
		} else {
			// Fallback on earlier versions
		}

		if #available(iOS 11.0, *) {
			navigationItem.searchController = searchController
			navigationItem.hidesSearchBarWhenScrolling = false
		} else {
			searchController.dimsBackgroundDuringPresentation = false
			searchController.hidesNavigationBarDuringPresentation = true
			searchController.definesPresentationContext = true

			//				searchController.searchBar.sizeToFit()
			tableView.tableHeaderView = searchController.searchBar
		}
		definesPresentationContext = true
	}

	private func getItem(at indexPath: IndexPath) -> FPNCountry {
		if searchController.isActive && results != nil && results!.count > 0 {
			return results![indexPath.row]
		} else {
			return repository!.countries[indexPath.row]
		}
	}

    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
	override open func numberOfSections(in tableView: UITableView) -> Int {
        return countrySections.count
	}
    
    override open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var sections : [String] = []
        for title in countrySections {
            if(title.count == 1){
                sections.append(title)
            }
        }
        return sections
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return countrySections[section].uppercased()
    }
    
    override open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.lightGray
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .light)
        header.textLabel?.textColor = UIColor.black
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 3
        }
        let countryKey = countrySections[section]
        if let countries = countryDictionaries[countryKey] {
            return countries.count
        }
        return 0
    }

//	override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		if searchController.isActive {
//			if let count = searchController.searchBar.text?.count, count > 0 {
//				return results?.count ?? 0
//			}
//		}
//		return repository?.countries.count ?? 0
//	}

	override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        let countryKey = countrySections[indexPath.section]
        if let countries = countryDictionaries[countryKey.uppercased()] {
            let country = countries[indexPath.row]
            cell.imageView?.image = country.flag
            cell.textLabel?.text = country.name

            if showCountryPhoneCode {
                cell.detailTextLabel?.text = country.phoneCode
            }
        }else if let countries = countryDictionaries["Common countries"] {
            let country = countries[indexPath.row]
            cell.imageView?.image = country.flag
            cell.textLabel?.text = country.name

            if showCountryPhoneCode {
                cell.detailTextLabel?.text = country.phoneCode
            }
        }
//		let country = getItem(at: indexPath)
//
//		cell.imageView?.image = country.flag
//		cell.textLabel?.text = country.name
//
//		if showCountryPhoneCode {
//			cell.detailTextLabel?.text = country.phoneCode
//		}

		return cell
	}

	override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//let country = getItem(at: indexPath)

		tableView.deselectRow(at: indexPath, animated: true)

        let countryKey = countrySections[indexPath.section]
        if let countries = countryDictionaries[countryKey.uppercased()] {
            let country = countries[indexPath.row]
            didSelect?(country)
        }else if let countries = countryDictionaries["Common countries"] {
            let country = countries[indexPath.row]
            didSelect?(country)
        }
//		didSelect?(country)

		searchController.isActive = false
		searchController.searchBar.resignFirstResponder()
		dismiss(animated: true, completion: nil)
	}

	// UISearchResultsUpdating

	open func updateSearchResults(for searchController: UISearchController) {
		guard let countries = repository?.countries else { return }

		if countries.isEmpty {
			results?.removeAll()
			return
		} else if searchController.searchBar.text == "" {
			results?.removeAll()
			tableView.reloadData()
			return
		}

		if let searchText = searchController.searchBar.text, searchText.count > 0 {
			results = countries.filter({(item: FPNCountry) -> Bool in
				if item.name.lowercased().range(of: searchText.lowercased()) != nil {
					return true
				} else if item.code.rawValue.lowercased().range(of: searchText.lowercased()) != nil {
					return true
				} else if item.phoneCode.lowercased().range(of: searchText.lowercased()) != nil {
					return true
				}
				return false
			})
            self.sortCountry()
		}
		tableView.reloadData()
	}

	// UISearchControllerDelegate

	open func willDismissSearchController(_ searchController: UISearchController) {
		results?.removeAll()
	}
    
    private func sortCountry() {
        if let countries = self.results{
            for country in countries {
                if(country.code.rawValue == "AW" || country.code.rawValue == "CW" || country.code.rawValue == "BQ"){
                    
                }else{
                    let key = "\(country.name[country.name.startIndex])".uppercased()
                    if var countryValue = self.countryDictionaries[key] {
                        countryValue.append(country)
                        self.countryDictionaries[key] = countryValue
                    } else {
                        self.countryDictionaries[key] = [country]
                    }
                    self.countrySections = [String](self.countryDictionaries.keys).sorted()
                }
            }
            
            self.countrySections.insert("Common countries", at: 0)
            for country in countries {
                if(country.code.rawValue == "AW" || country.code.rawValue == "CW" || country.code.rawValue == "BQ"){
                    if var countryValue = self.countryDictionaries["Common countries"] {
                        countryValue.append(country)
                        self.countryDictionaries["Common countries"] = countryValue
                    } else {
                        self.countryDictionaries["Common countries"] = [country]
                    }
                }
            }
            self.tableView.reloadData()
        }else{
            if let countries = self.repository?.countries{
                for country in countries {
                    if(country.code.rawValue == "AW" || country.code.rawValue == "CW" || country.code.rawValue == "BQ"){
                        
                    }else{
                        let key = "\(country.name[country.name.startIndex])".uppercased()
                        if var countryValue = self.countryDictionaries[key] {
                            countryValue.append(country)
                            self.countryDictionaries[key] = countryValue
                        } else {
                            self.countryDictionaries[key] = [country]
                        }
                        self.countrySections = [String](self.countryDictionaries.keys).sorted()
                    }
                }
                
                self.countrySections.insert("Common countries", at: 0)
                for country in countries {
                    if(country.code.rawValue == "AW" || country.code.rawValue == "CW" || country.code.rawValue == "BQ"){
                        if var countryValue = self.countryDictionaries["Common countries"] {
                            countryValue.append(country)
                            self.countryDictionaries["Common countries"] = countryValue
                        } else {
                            self.countryDictionaries["Common countries"] = [country]
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
}
