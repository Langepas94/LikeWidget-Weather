//
//  HeaderView.swift
//  WidgetLike Weather
//
//  Created by Artem on 02.03.2023.
//

import Foundation
import UIKit
import SnapKit


final class HeaderView: UICollectionReusableView {
    
    static let reuseId = "Header"
    
    private let searchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.barTintColor = .backColor
        searchbar.tintColor = .black
        searchbar.layer.borderWidth = 1
        searchbar.layer.borderColor = UIColor.backColor?.cgColor
        return searchbar
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.actions.withRenderingMode(.alwaysOriginal).withTintColor(.black), for: .normal)
       
        return button
    }()
    
    private let stackForSearchAndSettings: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
//    private let stackForSearchAndSettings: UIAlertController = {
//        let alert = UIAlertController()
//        alert
//        return alert
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        settingsButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
    }
    
    @objc func settingButtonTapped() {

    }
    
    private func setupUI() {
        
        // MARK: - setup stackView
        addSubview(settingsButton)
        addSubview(searchBar)

        addSubview(stackForSearchAndSettings)
        stackForSearchAndSettings.addArrangedSubview(searchBar)
        stackForSearchAndSettings.addArrangedSubview(settingsButton)
       
        stackForSearchAndSettings.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HeaderView: UISearchBarDelegate {
    
}
