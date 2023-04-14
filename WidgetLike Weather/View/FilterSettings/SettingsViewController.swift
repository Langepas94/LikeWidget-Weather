//
//  FilterSettingsViewController.swift
//  WidgetLike Weather
//
//  Created by Artem on 15.03.2023.
//

import Foundation
import UIKit
import SnapKit

class SettingsViewController: UIViewController {
    
    //MARK: - elements
    private lazy var mainVerticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var degreesFilteringStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topView = FilterNavigationTopView()
    
    private lazy var minusButton: UIButton = {
        let butt = UIButton()
        
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        butt.setImage(UIImage(
            systemName: "minus.circle",
            withConfiguration: config)?
            .withTintColor(.black, renderingMode: .alwaysOriginal),
                      for: .normal)
        
        butt.addTarget(self, action: #selector(minusButtonHolded), for: .touchDown)
        butt.addTarget(self, action: #selector(minusButtonUp), for: [.touchUpInside, .touchUpOutside])
        butt.translatesAutoresizingMaskIntoConstraints = false
        return butt
    }()
    // cadisplaylink
    private lazy var plusButton: UIButton = {
        let butt = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        butt.setImage(UIImage(systemName: "plus.circle",
                              withConfiguration: config)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.black), for: .normal)
        
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.addTarget(self, action: #selector(plusButtonHolded), for: .touchDown)
        butt.addTarget(self, action: #selector(plusButtonUp), for: [.touchUpInside, .touchUpOutside])
        return butt
    }()
    
    private lazy var degreesTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = FilterDegreesService.shared.getFromFilteredNum()
        textField.font = .systemFont(ofSize: 25, weight: .bold)
        textField.minimumFontSize = 1
        textField.textAlignment = .center
        textField.keyboardType = .numbersAndPunctuation
        textField.clearButtonMode = .never
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        textField.clearsOnBeginEditing = true
        return textField
    }()
    
    var timerForHoldingButton: Timer?
    
    private lazy var degreesFilterLabel: UILabel = {
        let label = UILabel()
        label.text = "От какой температуры фильтровать города?"
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var applyChangesButton: UIButton = {
        let butt = UIButton()
        butt.setTitle("Применить", for: .normal)
        butt.setTitleColor(.gray, for: .normal)
        butt.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        butt.backgroundColor = .backColor
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.addTarget(self, action: #selector(applyChanges), for: .touchUpInside)
        butt.layer.cornerRadius = 10
        return butt
    }()
    
    var isFiltering: Bool = false
    
    var completion: ((Bool, Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        degreesTextField.delegate = self
        if degreesTextField.text == "0" {
            disablingButton()
        } else {
            enablingButton()
        }
    }
}

// MARK: - setupUI
extension SettingsViewController {
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(degreesFilteringStackView)
        view.addSubview(degreesFilterLabel)
        degreesFilteringStackView.addArrangedSubview(minusButton)
        degreesFilteringStackView.addArrangedSubview(degreesTextField)
        degreesFilteringStackView.addArrangedSubview(plusButton)
        view.addSubview(applyChangesButton)
        view.addSubview(topView)
        
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        degreesFilteringStackView.snp.makeConstraints { make in
            make.width.equalTo(150)
            make.height.equalTo(50)
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        degreesFilterLabel.snp.makeConstraints { make in
            make.centerY.equalTo(degreesFilteringStackView.snp.centerY)
            make.trailing.equalTo(degreesFilteringStackView.snp.leading).offset(-15)
            make.leading.equalToSuperview().offset(15)
        }
        
        applyChangesButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-15)
            make.trailing.equalToSuperview().offset(-15)
            make.leading.equalToSuperview().offset(15)
        }
        topView.closeButton.addTarget(self, action: #selector(easyDismiss), for: .touchUpInside)
        topView.clearFilterButton.addTarget(self, action: #selector(clearFilters), for: .touchUpInside)
    }
    
    func disablingButton() {
        topView.clearFilterButton.isEnabled = false
    }
    func enablingButton() {
        topView.clearFilterButton.isEnabled = true
    }
    
    //MARK: - Actions
    
    @objc func applyChanges() {
        FilterDegreesService.shared.pasteToFilteredNum(num: degreesTextField.text ?? "0")
        let result = FilterDegreesService.shared.getFromFilteredNum()
        
        if FilterDegreesService.shared.getFromFilteredNum() == "0" {
            completion?(false, Int(result) ?? 0)
        } else {
            completion?(true, Int(result) ?? 0)
        }
        enablingButton()
        self.dismiss(animated: true)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        degreesTextField.resignFirstResponder()
        if degreesTextField.text == "" {
            degreesTextField.text = "0"
        }
    }
    
    @objc func plusButtonHolded(_ sender: UIButton) {
        plusButtonSingleTap()
        timerForHoldingButton = Timer.scheduledTimer(timeInterval: 0.12, target: self, selector: #selector(plusButtonHoldAction), userInfo: nil, repeats: true)
    }
    
    @objc func plusButtonUp(_ sender: UIButton) {
        timerForHoldingButton?.invalidate()
    }
    
    func plusButtonSingleTap() {
        let increasing =  FilterDegreesService.shared.increaseOne()
        degreesTextField.text = increasing
        enablingButton()
    }
    
    @objc func plusButtonHoldAction() {
        plusButtonSingleTap()
    }
    
    @objc func minusButtonHolded(_ sender: UIButton) {
        minusButtonSingleTap()
        timerForHoldingButton = Timer.scheduledTimer(timeInterval: 0.12, target: self, selector: #selector(minusButtonHoldAction), userInfo: nil, repeats: true)
    }
    
    @objc func minusButtonUp(_ sender: UIButton) {
        timerForHoldingButton?.invalidate()
    }
    
    func minusButtonSingleTap() {
        let decreasing =  FilterDegreesService.shared.decreaseOne()
        degreesTextField.text = decreasing
        enablingButton()
    }
    
    @objc func minusButtonHoldAction() {
        minusButtonSingleTap()
    }
    
    @objc func easyDismiss() {
        self.dismiss(animated: true)
    }
    
    @objc func clearFilters() {
        completion?(false, 0)
        self.degreesTextField.text = FilterDegreesService.shared.clearFilter()
        disablingButton()
    }
}

// MARK: - textField delegate

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        degreesTextField.resignFirstResponder()
        
        if degreesTextField.text == "" {
            degreesTextField.text = "0"
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if degreesTextField.text == "0" {
            topView.clearFilterButton.isEnabled = false
        } else {
            topView.clearFilterButton.isEnabled = true
        }
    }
}
