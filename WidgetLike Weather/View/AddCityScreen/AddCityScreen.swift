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
    
    let mainCityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Push me", for: .normal)
        button.setTitleColor(.black, for: .normal)
       
        return button
    }()
    
    var callCity: ((String?) -> ())?
    var titleCity: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        actionButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        mainCityLabel.text = titleCity ?? ""
        
    }
    
    @objc func buttonAction() {
        callCity?(titleCity)
        self.dismiss(animated: true)

    }
}

extension AddCityScreen {
    func setupUI() {
        view.addSubview(mainCityLabel)
        view.addSubview(actionButton)
        
        view.backgroundColor = .yellow
        mainCityLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(100)
            make.top.equalTo(mainCityLabel.snp.bottom).offset(10)
        }
    }
}
