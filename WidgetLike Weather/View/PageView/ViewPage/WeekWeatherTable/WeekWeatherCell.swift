//
//  WeekWeatherCell.swift
//  WidgetLike Weather
//
//  Created by Artem on 10.04.2023.
//

import Foundation
import UIKit

class WeekWeatherCell: UITableViewCell {
    
    static let id = "WeekWeatherCellID"
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 20)
        return label
    }()
    
    let weatherImage: UIImageView = {
        let image = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 25)
//        image.image = UIImage(systemName: "clock", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        image.contentMode = .center
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let degreeLabel: UILabel = {
        let label = UILabel()
//        label.text = "Loading"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 20)
        return label
    }()
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUIs()
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
            setupUIs()
        
        
    }
    
  
    
    func configure(item: List) {
        
        let date = item.dt ?? 0
        let convertDate = Date(timeIntervalSince1970: TimeInterval(date))
        let formats = convertDate.formatted(.dateTime.hour().minute())
        self.timeLabel.text = String(formats)
        self.weatherImage.image = UIImage(named: item.weather?[0].icon ?? "")
        self.degreeLabel.text = String(item.main?.temp ?? 0.0) + "°"
        UIView.animate(withDuration: 0.6) {
            self.timeLabel.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(15)
                make.centerY.equalToSuperview()
                
            }
            self.degreeLabel.snp.remakeConstraints { (make) in
                make.trailing.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
            }
            
            self.weatherImage.snp.makeConstraints { make in
                make.center.equalToSuperview()
                
            }

            self.contentView.layoutIfNeeded()
        }
    }
}

extension WeekWeatherCell {
    func setupUIs() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(weatherImage)
        contentView.addSubview(degreeLabel)
       
        timeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(55)
//            make.width.equalTo(30)
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
            
        }
        UIView.animate(withDuration: 1) {
            self.timeLabel.alpha = 1
        }
        weatherImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        degreeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-55)
            make.height.equalTo(50)
            make.centerY.equalToSuperview()
//            make.width.equalTo(30)
        }
        
    }
}
