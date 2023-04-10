//
//  WeekWeatherTable.swift
//  WidgetLike Weather
//
//  Created by Artem on 10.04.2023.
//

import Foundation
import UIKit

class WeekWeatherTable: UIView {
    
    private var table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupUI()
//    }
}
extension WeekWeatherTable {
    func setupUI() {
        addSubview(table)
       
        table.dataSource = self
        
        table.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(200)
        }
        
    }
}

extension WeekWeatherTable: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        17
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "kuksdfsdfsdfsdsf"
        cell.tintColor = .black
        return cell
    }
    
    
}
