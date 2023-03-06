//
//  AddCityScreen.swift
//  WidgetLike Weather
//
//  Created by Artem on 06.03.2023.
//

import Foundation
import UIKit
import SnapKit

class AddCityScreen: UIViewController {
    
    private let mainCityLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension AddCityScreen {
    func setupUI() {
        view.addSubview(mainCityLabel)
        
        mainCityLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
