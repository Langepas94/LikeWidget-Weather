//
//  ViewPage.swift
//  WidgetLike Weather
//
//  Created by Artem on 07.04.2023.
//

import Foundation
import UIKit

class ViewPage: UIView {
    
     let cityNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "City"
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 32)
        label.textAlignment = .center
        return label
    }()
    
    private let degreesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 63)
        label.textAlignment = .center
        return label
    }()
    
    private let weatherImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "01n")
        
        image.contentMode = .center
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let descriptionWeatherLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 13)
        return label
    }()
    
    private let descriptionDegreesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 13)
        return label
    }()
    
    private let clockImage: UIImageView = {
        let image = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        image.image = UIImage(systemName: "clock", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        image.contentMode = .center
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont(name: "AppleSDGothicNeo-Light", size: 15)
        return label
    }()
    let network = NetworkManager()
    private let weekTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(WeekWeatherCell.self, forCellReuseIdentifier: WeekWeatherCell.id)
        table.separatorStyle = .none
        return table
    }()
    
    private var dataModels: [List] = []
      
  
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupUI()
//    }
        
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        weekTable.dataSource = self
        weekTable.delegate = self

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(item: CellCityViewModel) {
        self.cityNameLabel.text = item.cityName
        self.degreesLabel.text = String(item.degrees) + "°"
        self.descriptionWeatherLabel.text = item.description
        self.weatherImage.image = UIImage(named: item.icon)

    }
    
  
}

extension ViewPage {
    func setupUI() {
        addSubview(cityNameLabel)
        addSubview(degreesLabel)
        addSubview(weatherImage)
        addSubview(descriptionWeatherLabel)
        addSubview(weekTable)
        
        
        cityNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }
        
        
        
        degreesLabel.snp.makeConstraints { make in
            make.top.equalTo(cityNameLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
        }
        
        descriptionWeatherLabel.snp.makeConstraints { make in
            make.top.equalTo(degreesLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
        }
        weatherImage.snp.makeConstraints { make in
            make.top.equalTo(descriptionWeatherLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
        }
        
        weekTable.snp.makeConstraints { make in
            make.top.equalTo(weatherImage.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
            make.height.equalTo(350)
        }
    }
    
    
}

extension ViewPage: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = weekTable.dequeueReusableCell(withIdentifier: WeekWeatherCell.id, for: indexPath) as! WeekWeatherCell

            cell.alpha = 0
        
        self.network.fetchData(requestType: .city(city: cityNameLabel.text ?? "")) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
//                    print("mif \(data)")
                    var abb = data.list
                    self?.dataModels = data.list!
                    cell.configure(item: (self?.dataModels[indexPath.row])!)
                    
                    
                    UIView.animate(withDuration: 3) {
                        
                        cell.alpha = 1
                    }
                    
                    
//                    let date = data.list?[0].dt
//                    let convertDate = Date(timeIntervalSince1970: TimeInterval(date!))
//                    let aa = convertDate.formatted(.dateTime.hour().minute())
//                    print(aa)
//                    cell.textLabel?.text = result.dtTxt ?? ""
                    
                    
                }
                
            case .failure(let error):
                print("table fail \(error)")
            }
        }
//        cell.configure(item: dataModels[indexPath.row])
//        print(dataModels.count)
//        cell.timeLabel.text = "Mem"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}
