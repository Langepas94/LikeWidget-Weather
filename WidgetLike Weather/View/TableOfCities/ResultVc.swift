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
    
    private var localeNetwork = LocaleNetworkManager()
    var massa: [WelcomeElement]?
    let testMassov = ["1", "2", "3","1", "2", "3","1", "2", "3","1", "2", "3"]
    
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
        100
    }
    
 // MARK: - Setup Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableView", for: indexPath)
        var config = cell.defaultContentConfiguration()
        
      
            
            self.localeNetwork.fetchData { [weak self ] result in
                
                switch result {
                case .success(let data):
                    
                    DispatchQueue.main.async {
                        
                        config.text = data[indexPath.row].name
                        cell.contentConfiguration = config
                        print()
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
            
        
        
        
        
        
//        config.text = testMassov[indexPath.row]
        
        
        cell.backgroundColor = .backColor?.withAlphaComponent(0.3)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AddCityScreen()
        
        self.modalPresentationStyle = .popover
        
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
