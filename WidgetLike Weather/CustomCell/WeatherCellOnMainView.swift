//
//  WeatherCell.swift
//  WidgetLike Weather
//
//  Created by Artem on 28.02.2023.
//

import Foundation
import UIKit
import SnapKit

class WeatherCellOnMainView: UICollectionViewCell {
    
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
        return view
    }()
    
    private let cityNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 21)
        label.textAlignment = .left
        return label
    }()
    
    private let degreesLabel: UILabel = {
        let label = UILabel()
        //        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 43)
        return label
    }()
    
    private let weatherImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "01n")
        image.contentMode = .center
        return image
    }()
    
    private let descriptionWeatherLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 13)
        return label
    }()
    
    private let descriptionDegreesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 13)
        return label
    }()
    
    private let clockImage: UIImageView = {
        let image = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 15)
        image.image = UIImage(systemName: "clock", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        image.contentMode = .center
        return image
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 2
        label.font = UIFont(name: "AppleSDGothicNeo-Light", size: 15)
        return label
    }()
    
    private let longPress = UILongPressGestureRecognizer()
    var isDeletable = false
    var longPressClosure: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        //        setupView()
        contentView.addSubview(mainView)
        mainView.addSubview(cityNameLabel)
        mainView.addSubview(degreesLabel)
        mainView.addSubview(weatherImage)
        mainView.addSubview(descriptionWeatherLabel)
        mainView.addSubview(timeLabel)
        mainView.addSubview(clockImage)
        mainView.layer.cornerRadius = 20
        
        contentView.addGestureRecognizer(longPress)
        longPress.addTarget(self, action: #selector(longTap))
//        longPress.isEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0))
        
        cityNameLabel.frame = CGRect(x: 10, y: 15, width: mainView.frame.width, height: 22)
        
        degreesLabel.frame = CGRect(x: 10, y: cityNameLabel.frame.height + 20, width: mainView.frame.width, height: 50)
        
        weatherImage.frame = CGRect(x: 10, y: degreesLabel.frame.maxY + 15, width: 30, height: 30)
        
        let frameDescriptionLabelSize = CGSize(width: mainView.frame.width / 1.5, height: 20)
        
        descriptionWeatherLabel.frame = CGRect(x: mainView.frame.maxX - frameDescriptionLabelSize.width, y: weatherImage.frame.origin.y, width: frameDescriptionLabelSize.width, height: frameDescriptionLabelSize.height)
        
        let frameTimelabelSize = CGSize(width: mainView.frame.width / 3, height: 30)
        clockImage.frame = CGRect(x: 10, y: mainView.frame.maxY - frameTimelabelSize.height, width: 20, height: mainView.frame.height / 7)
        
        timeLabel.frame = CGRect(x: clockImage.frame.maxX + 5, y: clockImage.frame.origin.y, width: mainView.frame.width / 3, height: mainView.frame.height / 7)
    }
    
    func setupCells() {
        
        guard let cityItemModel = cityItemModel else { return }
        
        self.cityNameLabel.text = cityItemModel.cityName
        self.degreesLabel.text = String(cityItemModel.degrees) + "°"
        self.descriptionWeatherLabel.text = cityItemModel.description
        self.weatherImage.image = UIImage(named: cityItemModel.icon)
        self.timezone = TimeZone(secondsFromGMT: cityItemModel.timezone)
        self.longPress.isEnabled = isDeletable
        NotificationCenter.default.addObserver(self, selector: #selector(updateTime), name: Notification.Name("time"), object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func longTap(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        self.longPressClosure?()
    }
    
    @objc func updateTime() {
        let date = Date()
        
        let dateFormatterHour = DateFormatter()
        dateFormatterHour.timeZone = self.timezone
        dateFormatterHour.dateFormat = "HH"
        let hourString = dateFormatterHour.string(from: date)
        let formattedHourString = String(format: "%02d", Int(hourString)!)
        
        let dateFormatterMinute = DateFormatter()
        dateFormatterMinute.timeZone = self.timezone
        dateFormatterMinute.dateFormat = "mm"
        let minuteString = dateFormatterMinute.string(from: date)
        let formattedMinuteString = String(format: "%02d", Int(minuteString)!)
        
        self.timeLabel.text = "\(formattedHourString): \(formattedMinuteString)"
        
        if Int(hourString)! >= 18 || Int(hourString)! <= 5  {
            self.mainView.backgroundColor = .systemFill
        } else {
            self.mainView.backgroundColor = .white
        }
    }
}

