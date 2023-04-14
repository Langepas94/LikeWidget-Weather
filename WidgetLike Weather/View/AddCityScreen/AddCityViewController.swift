//
//  AddCityScreen.swift
//  WidgetLike Weather
//
//  Created by Artem on 06.03.2023.
//

import Foundation
import UIKit
import SnapKit
import Combine

class AddCityViewController: UIViewController {
    
    let mainCityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
//        label.textAlignment = .center
        return label
    }()
    
    let actionButton: UIButton = {
		let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add city", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let degreesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.text = ""
        label.font = .systemFont(ofSize: 37)
        return label
    }()
    
    private let weatherImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let descriptionWeatherLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        label.text = ""
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let descriptionDegreesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
	var cancellables: Set<AnyCancellable> = []
    var callCity: ((String?) -> ())?
    var titleCity: String?
    var network = NetworkManager()
    var dataArray: CellDataModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        actionButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        mainCityLabel.text = titleCity ?? ""
        getData()
        
    }
    
    @objc func buttonAction() {
		let name = titleCity!
        DatabaseService.shared.addToFavorite(city: dataArray!)
        DatabaseService.shared.favoriteWorker.send(name)
        NotificationCenter.default.post(name: Notification.Name("add favorite"), object: nil)
        self.dismiss(animated: true)
    }
    
    func getData() {
        self.network.fetchData(requestType: .city(city: titleCity ?? "")) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.degreesLabel.text = String(data.list![0].main?.temp ?? 0.0)
                    self.weatherImage.image = UIImage(named: data.list?[0].weather?[0].icon ?? "")
                    self.descriptionWeatherLabel.text = data.list?[0].weather?[0].description ?? ""
                    self.dataArray = CellDataModel(currentData: data)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension AddCityViewController {
    func setupUI() {
        view.addSubview(mainCityLabel)
        view.addSubview(actionButton)
        view.addSubview(degreesLabel)
        view.addSubview(weatherImage)
        view.addSubview(descriptionWeatherLabel)
        view.addSubview(descriptionDegreesLabel)
        view.backgroundColor = .white
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.trailing.equalToSuperview().offset(-6)
        }
        mainCityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        weatherImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
        }
        degreesLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(weatherImage.snp.trailing).offset(12)
        }
        
        descriptionWeatherLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalTo(weatherImage.snp.leading)
        }
        
    }
}
