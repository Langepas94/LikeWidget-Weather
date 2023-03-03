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
    
    private let searchBar = UISearchBar()
    
    private let settingsButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupSearchBar()
        
       
    }
    
    private func setupSearchBar() {
        addSubview(searchBar)
        searchBar.delegate = self
        searchBar.barTintColor = .backColor
        searchBar.tintColor = .black
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.backColor?.cgColor
        searchBar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
       
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HeaderView: UISearchBarDelegate {
    
}
