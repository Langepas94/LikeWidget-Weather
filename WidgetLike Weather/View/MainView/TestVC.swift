//
//  TestVC.swift
//  WidgetLike Weather
//
//  Created by Artem on 12.04.2023.
//

import Foundation
import UIKit


class TestVc: UIViewController {
    let button: UIButton = {
       let butt = UIButton()
        butt.setTitle("Back", for: .normal)
        butt.setTitleColor(.black, for: .normal)
        butt.frame = CGRect(x: 100, y: 100, width: 200, height: 100)
//        butt.alpha = 0
        return butt
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        view.backgroundColor = .yellow
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        dismiss(animated: true)
    }
}
