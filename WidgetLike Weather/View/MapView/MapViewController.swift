//
//  MapViewController.swift
//  WidgetLike Weather
//
//  Created by Artem on 22.03.2023.
//

import Foundation
import UIKit
import MapKit
import Combine

class MapViewController: UIViewController {
    var network = NetworkManager()
    let map = MKMapView()
    var pointAnnotationsArray: [MKPointAnnotation] = []
    let button: UIButton = {
        let butt = UIButton()
        butt.setTitle("refresh", for: .normal)
        return butt
    }()
    
    var favoriteList: [String] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("add favorite"), object: nil)
        view.backgroundColor = .green
        setupUI()
        map.delegate = self
        button.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        annotationsCreator()
    }
    
    @objc func refresh() {
        self.map.removeAnnotations(map.annotations)
        annotationsCreator()
    }
    
    func annotationsCreator() {
        self.favoriteList = Database.shared.allFavorites()
        Database.shared.allFavorites().forEach { city in
            self.network.fetchData(requestType: .city(city: city)) { result in
                switch result {
                case .success(let data ):
                    DispatchQueue.main.async {
                        let annotationsLat = data.city?.coord?.lat
                        let annotationsLon = data.city?.coord?.lon
                        let point = MKPointAnnotation()
                        point.title = "\(data.city?.name ?? "") : \(Int(data.list?[0].main?.temp ?? 0.0)) " + "°"
                        point.coordinate = CLLocationCoordinate2D(latitude: annotationsLat ?? 0.0, longitude: annotationsLon ?? 0.0)
                        self.pointAnnotationsArray.append(point)
                        self.map.addAnnotation(point)
                       
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        
    }
}

extension MapViewController {
    func setupUI() {
        view.addSubview(map)
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(150)
            make.leading.equalToSuperview().offset(16)
        }
        map.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
extension MapViewController: MKMapViewDelegate {
    
}


