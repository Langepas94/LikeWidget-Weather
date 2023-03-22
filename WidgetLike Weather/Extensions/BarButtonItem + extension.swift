//
//  BarButtonItem + extension.swift
//  WidgetLike Weather
//
//  Created by Artem on 20.03.2023.
//

import Foundation
import UIKit

enum BarIcon {
    case empty
    case fill
}

extension MainScreenViewController {
    func setNavigationItem(bool: Bool)  {
        
        var item = UIBarButtonItem()
        
        if bool == true {
           item =  UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.black), style: .done, target: self, action: #selector(rightBarSettingsAction))
            self.navigationItem.rightBarButtonItem = item
        } else if bool != true {
           item =  UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.black), style: .done, target: self, action: #selector(rightBarSettingsAction))
            self.navigationItem.rightBarButtonItem = item
        }
        
    }
}
