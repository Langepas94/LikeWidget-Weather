//
//  WeatherCell.swift
//  WidgetLike Weather
//
//  Created by Artem on 28.02.2023.
//

import Foundation
import UIKit

class WeatherCell: UICollectionViewCell {
    
    static let cellId = "WeatherCell"
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
    }
    
    func configure() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
