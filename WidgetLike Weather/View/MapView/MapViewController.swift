//
//  MapViewController.swift
//  WidgetLike Weather
//
//  Created by Artem on 22.03.2023.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {
    var network = NetworkManager()
    let map = MKMapView()
    var pointAnnotationsArray: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        setupUI()
        map.delegate = self
        
//        let abc = MKPointAnnotation()
//        abc.coordinate = CLLocationCoordinate2D(latitude: 61.254399999999997, longitude: 55.212400000000002)
//        abc.title = "mem"
//        let abb = MKPointAnnotation()
//        abb.coordinate = CLLocationCoordinate2D(latitude: 41.254399999999997, longitude: 25.212400000000002)
//        let abq = MKPointAnnotation()
//        abq.coordinate = CLLocationCoordinate2D(latitude: 11.254399999999997, longitude: 65.212400000000002)
//
//        pointAnnotationsArray.append(abc)
//        pointAnnotationsArray.append(abq)
//        pointAnnotationsArray.append(abb)
        
        annotationsCreator()
        
    }
    
    func annotationsCreator() {
        var favoriteList = CitiesService.shared.favorites
        DispatchQueue.main.async {
            favoriteList.forEach { city in
                self.network.fetchData(requestType: .city(city: city)) { result in
                    switch result {
                    case .success(let data ):
                        let annotationsLat = data.city?.coord?.lat
                        let annotationsLon = data.city?.coord?.lon
                        let point = MKPointAnnotation()
                        point.title = "\(data.city?.name ?? "") : \(Int(data.list?[0].main?.temp ?? 0.0)) " + "°" 
                        point.coordinate = CLLocationCoordinate2D(latitude: annotationsLat ?? 0.0, longitude: annotationsLon ?? 0.0)
                        self.pointAnnotationsArray.append(point)
                        self.map.addAnnotations(self.pointAnnotationsArray)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
}

extension MapViewController {
    func setupUI() {
        view.addSubview(map)
        
        map.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
extension MapViewController: MKMapViewDelegate {
    
}
