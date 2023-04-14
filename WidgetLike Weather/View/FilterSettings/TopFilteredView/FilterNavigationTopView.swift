//
//  TopFilteredView.swift
//  WidgetLike Weather
//
//  Created by Artem on 20.03.2023.
//

import Foundation
import UIKit

class FilterNavigationTopView: UIView {
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let closeButton: UIButton = {
        let butt = UIButton()
        butt.setTitle("Закрыть", for: .normal)
        butt.setTitleColor(.gray, for: .normal)
        butt.titleLabel?.font = .systemFont(ofSize: 10, weight: .bold)
        butt.setTitleColor(.white, for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.setTitleColor(.lightGray, for: .highlighted)
        return butt
    }()
    
    let clearFilterButton: UIButton = {
        let butt = UIButton()
        butt.setTitle("Сбросить все", for: .normal)
        butt.setTitleColor(.gray, for: .normal)
        butt.titleLabel?.font = .systemFont(ofSize: 10, weight: .bold)
        butt.setTitleColor(.white, for: .normal)
        butt.setTitleColor(.lightGray, for: .disabled)
        butt.translatesAutoresizingMaskIntoConstraints = false
        return butt
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
        self.addSubview(filterLabel)
        self.addSubview(closeButton)
        self.addSubview(clearFilterButton)
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
            make.width.equalTo(70)
        }
        
        clearFilterButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-7)
            make.width.equalTo(100)
        }
        
        filterLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
