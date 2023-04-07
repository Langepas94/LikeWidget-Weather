//
//  WeatherCell.swift
//  WidgetLike Weather
//
//  Created by Artem on 28.02.2023.
//

/// сделать вью добавить все в нее и у этого вью делать настройки

import Foundation
import UIKit
import SnapKit

class WeatherCell: UICollectionViewCell {
    
    var cityItemModel: CellCityViewModel? {
        didSet {
            setupCells()
        }
    }
    
    static let cellId = "WeatherCell"
    
    var timer: Timer?
    
    var timezone: TimeZone?
    
    private let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.08
        view.layer.masksToBounds = false
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cityNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 21)
        
        return label
    }()
    
    private let degreesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 43)
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
        let config = UIImage.SymbolConfiguration(pointSize: 15)
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
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    override func prepareForReuse() {
        cityNameLabel.text = ""
        degreesLabel.text = ""
        mainView.backgroundColor = .white
    }
    
    
    func setupCells() {
        guard let cityItemModel = cityItemModel else { return }
        
        self.cityNameLabel.text = cityItemModel.cityName
        self.degreesLabel.text = cityItemModel.degrees
        self.descriptionWeatherLabel.text = cityItemModel.description
        self.weatherImage.image = UIImage(named: cityItemModel.icon)
//        self.timezone = TimeZone(secondsFromGMT: cityItemModel.timezone)
        NotificationCenter.default.addObserver(forName: Notification.Name("timeChange"), object: nil, queue: .some(.current ?? .main)) { notification in
            self.timeLabel.text = cityItemModel.timeLabels
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc func updateTime() {
//        let date = Date()
//
//        let dateFormatterHour = DateFormatter()
//        dateFormatterHour.timeZone = self.timezone
//        dateFormatterHour.dateFormat = "HH"
//        let hourString = dateFormatterHour.string(from: date)
//        let formattedHourString = String(format: "%02d", Int(hourString)!)
//
//        let dateFormatterMinute = DateFormatter()
//        dateFormatterMinute.timeZone = self.timezone
//        dateFormatterMinute.dateFormat = "mm"
//        let minuteString = dateFormatterMinute.string(from: date)
//        let formattedMinuteString = String(format: "%02d", Int(minuteString)!)
//
//        self.timeLabel.text = "\(formattedHourString): \(formattedMinuteString)"
//
//        if Int(hourString)! >= 18 || Int(hourString)! <= 5  {
//            self.mainView.backgroundColor = .systemFill
//        } else {
//            self.mainView.backgroundColor = .white
//        }
//    }
}

// MARK: - setupView
extension WeatherCell {
    func setupView() {
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 20
        
        contentView.addSubview(mainView)
        mainView.addSubview(cityNameLabel)
        mainView.addSubview(degreesLabel)
        mainView.addSubview(weatherImage)
        mainView.addSubview(descriptionWeatherLabel)
        mainView.addSubview(descriptionDegreesLabel)
        mainView.addSubview(timeLabel)
        mainView.addSubview(clockImage)
        
        // добаволю жест и во вьюмодель добавить кложер (nullable)
        
        
        // MARK: - Constraints
        
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        cityNameLabel.snp.makeConstraints { make in
            make.left.equalTo(mainView.snp.left).offset(10)
            make.right.equalTo(mainView.snp.right).offset(-15)
            make.top.equalTo(mainView.snp.top).offset(15)
        }
        
        degreesLabel.snp.makeConstraints { make in
            make.left.equalTo(mainView.snp.left).offset(10)
            make.right.equalTo(mainView.snp.right).offset(-15)
            make.top.equalTo(cityNameLabel.snp.bottom).offset(5)
        }
        
        weatherImage.snp.makeConstraints { make in
            make.left.equalTo(mainView.snp.left).offset(10)
            make.top.equalTo(degreesLabel.snp.bottom).offset(5)
        }
        
        descriptionWeatherLabel.snp.makeConstraints { make in
            make.left.equalTo(mainView.snp.left).offset(10)
            make.top.equalTo(weatherImage.snp.bottom).offset(5)
        }
        descriptionDegreesLabel.snp.makeConstraints { make in
            make.left.equalTo(mainView.snp.left).offset(10)
            make.top.equalTo(descriptionWeatherLabel.snp.bottom).offset(5)
            make.bottom.equalTo(mainView.snp.bottom).offset(-5)
        }
        
        
        
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(mainView.snp.right).offset(-10)
            make.bottom.equalTo(mainView.snp.bottom).offset(-10)
        }
        
        clockImage.snp.makeConstraints { make in
            
            make.centerY.equalTo(timeLabel.snp.centerY)
            make.right.equalTo(timeLabel.snp.left).offset(-5)
        }
    }
}
