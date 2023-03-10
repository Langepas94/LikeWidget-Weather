//
//  ResultVc.swift
//  WidgetLike Weather
//
//  Created by Artem on 06.03.2023.
//

import Foundation
import UIKit
import SnapKit

class ResultVc: UIViewController {
    // MARK: - elements
    let tableView: UITableView = {
       let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "TableView")
        table.separatorStyle = .none
        table.backgroundColor = .backColor?.withAlphaComponent(0.1)
        return table
    }()
    
	public var filteredNames: [String] = []
    private var localeNetwork = LocaleNetworkManager()
	var callCity: ((String?) -> ())?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
}

// MARK: extension Datasource
extension ResultVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		filteredNames.count
    }
    
 // MARK: - Setup Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableView", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = filteredNames[indexPath.row]

            

        cell.contentConfiguration = config
        cell.textLabel?.text = filteredNames[indexPath.row]
        
        cell.backgroundColor = .backColor?.withAlphaComponent(0.3)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = AddCityScreen()
        
		vc.callCity = self.callCity
        vc.titleCity = filteredNames[indexPath.row]
        self.present(vc, animated: true)
    }
    
}

// MARK: SetupUi
extension ResultVc {
    func setupUi() {
        
        view.backgroundColor = .backColor?.withAlphaComponent(0.96)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
