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
    
    static let cellId = "WeatherCell"
    
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
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 37)
        return label
    }()
    
    private let weatherImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "cloud")?.withTintColor(.black, renderingMode: .alwaysOriginal)
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
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
        
        
    }
    
    func configure(city: String, degrees: String) {
        self.cityNameLabel.text = city
        self.degreesLabel.text = degrees + "°"
        self.descriptionWeatherLabel.text = "Облачно"
        self.descriptionDegreesLabel.text = "-1° +6°"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
    }
}
