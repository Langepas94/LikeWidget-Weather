//
//  GeoWeatherCell.swift
//  WidgetLike Weather
//
//  Created by Artem on 07.03.2023.
//

import Foundation
import UIKit
import SnapKit

class GeoWeatherCell: UICollectionViewCell {
    
    static let cellId = "GeoWeatherCell"
    
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
    
    private let geoImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
        return image
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
extension GeoWeatherCell {
    func setupView() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        
        contentView.addSubview(cityNameLabel)
        contentView.addSubview(degreesLabel)
        contentView.addSubview(weatherImage)
        contentView.addSubview(descriptionWeatherLabel)
        contentView.addSubview(descriptionDegreesLabel)
        contentView.addSubview(geoImageView)
        // MARK: - Constraints
        
        cityNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
        }
        
        degreesLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(cityNameLabel.snp.bottom).offset(5)
        }
        
        weatherImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(degreesLabel.snp.bottom).offset(5)
        }
        
        descriptionWeatherLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(weatherImage.snp.bottom).offset(5)
        }
        descriptionDegreesLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalTo(descriptionWeatherLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        geoImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(5)
        }
    }
}
