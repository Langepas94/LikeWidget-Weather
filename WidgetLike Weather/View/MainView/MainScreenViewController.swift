//
//  ViewController.swift
//  WidgetLike Weather
//
//  Created by Artem on 28.02.2023.
//

import UIKit
import SnapKit
import CoreLocation

class MainScreenViewController: UIViewController {
    
    // MARK: - elements of view
    private let searchController = UISearchController(searchResultsController: ResultVc())
    
    private lazy var mainCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collection.dataSource = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(WeatherCell.self, forCellWithReuseIdentifier: WeatherCell.cellId)
        collection.register(GeoWeatherCell.self, forCellWithReuseIdentifier: GeoWeatherCell.cellId)
        collection.showsVerticalScrollIndicator = false
        
        return collection
    }()
    
    var testMassiv = ["Vrdy", "Vrbovec", "Lagoa", "Ahtanum", "Anacortes", "Belfast"]
    
    private var network = NetworkManager()
    
    private var locationManaging: CLLocationManager = {
        let location = CLLocationManager()
        location.desiredAccuracy = kCLLocationAccuracyKilometer
        location.distanceFilter = 100.0
        return location
    }()
    
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    
    private var addCityVC: AddCityScreen!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManaging.delegate = self
        locationManaging.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManaging.requestLocation()
                self.locationManaging.startUpdatingLocation()
            }
        }

        setupUI()

    }
    
    // второй раз не отрабатывает
    // поиграться сделать делегаты
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addCityVC = AddCityScreen()
        addCityVC.callCity = {[weak self] data in
            print(data)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addCityVC = AddCityScreen()
        addCityVC.callCity = {[weak self] data in
            print(data)
        }
        
    }
    
    // MARK: - createCompositionalLayout()
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout(section: mainLayoutSection())
    }
    // MARK: - mainLayoutSection()
    private func mainLayoutSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.5))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    
}
// MARK: - setupUI func
extension MainScreenViewController {
    func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Widget Weather"
        
        searchController.searchBar.placeholder = "add your city"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        mainCollection.backgroundColor = .systemBackground
        view.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource()
extension MainScreenViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (testMassiv.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let geoCell = mainCollection.dequeueReusableCell(withReuseIdentifier: GeoWeatherCell.cellId, for: indexPath) as! GeoWeatherCell
            
            if let location = locationManaging.location {
                self.lat = location.coordinate.latitude
                self.lon = location.coordinate.longitude
            }
            self.network.fetchData(requestType: .location(latitude: lat ?? 00.00, longitude: lon ?? 00.00)) { [weak self] result in
                
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        
                        geoCell.configure(city: data.city?.name ?? "no city", degrees: String( (data.list![0].main?.temp) ?? 00))
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            return geoCell
        }
        
        let cell = mainCollection.dequeueReusableCell(withReuseIdentifier: WeatherCell.cellId, for: indexPath) as! WeatherCell
        

        
        
        
        self.network.fetchData(requestType: .city(city: testMassiv[indexPath.row - 1])) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    cell.configure(city: data.city?.name ?? "no city", degrees: String( (data.list![0].main?.temp) ?? 00))
                    
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return cell
    }
}
// MARK: Search Updating
extension MainScreenViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let vc = searchController.searchResultsController as? ResultVc
        guard let text = searchController.searchBar.text else { return }
        
        filteredMassiv = mockMasiv.filter {
            $0.contains(text)
        }
        vc?.tableView.reloadData()
    }
}
// MARK: - location Setup

extension MainScreenViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let index = IndexPath(item: 0, section: 0)
        self.mainCollection.reloadItems(at: [index])
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
