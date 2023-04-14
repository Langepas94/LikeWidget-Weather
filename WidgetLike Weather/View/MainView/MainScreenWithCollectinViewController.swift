//
//  ViewController.swift
//  WidgetLike Weather
//
//  Created by Artem on 28.02.2023.
//

import UIKit
import SnapKit
import CoreLocation
import SQLite
import Combine

class MainScreenWithCollectinViewController: UIViewController {
    
    // MARK: - elements of view
    private lazy var searchController: UISearchController = {
        let vc = ResultTableCitiesViewController()
        return UISearchController(searchResultsController: vc)
    }()
    
    private lazy var mainCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(WeatherCellOnMainView.self, forCellWithReuseIdentifier: WeatherCellOnMainView.cellId)
        collection.register(GeoWeatherCellOnMainView.self, forCellWithReuseIdentifier: GeoWeatherCellOnMainView.cellId)
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    var isCitiesLoaded = false
    
    var isFiltering = false
  
    var cancellables: Set<AnyCancellable> = []
    var point: CGPoint?
    private var network = NetworkManager()
    private var searchPublisher = PassthroughSubject<String, Never>()
    
    private var locationManaging: CLLocationManager = {
        let location = CLLocationManager()
        location.desiredAccuracy = kCLLocationAccuracyBest
        location.distanceFilter = 10.0
        return location
    }()
    
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    
    private var addCityVC: AddCityViewController!
    
    let dataService = DataIterator()
    
    private var cellModel: [CellCityViewModel] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureViewModels()
        setupRefresh()
        switch locationManaging.authorizationStatus {
        case .notDetermined:
            locationManaging.requestWhenInUseAuthorization()
        case .restricted:
            locationManaging.requestWhenInUseAuthorization()
        case .denied:
            locationManaging.requestWhenInUseAuthorization()
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .authorized:
            break
        }
        setupNavigationItem()
        locationManaging.delegate = self
        
        //        locationManaging.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManaging.requestLocation()
                self.locationManaging.startUpdatingLocation()
            }
        }
        
        setupUI()
//        let longPress = UILongPressGestureRecognizer()
//        longPress.addTarget(self, action: #selector(longDeleteItem))
////        self.mainCollection.addGestureRecognizer(longPress)
        
        
        searchPublisher
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap({ $0 })
            .sink(receiveValue: {[weak self] (searchString: String) in
                guard let self = self else { return }
                let cities = DatabaseService.shared.getCityFromDBtoStringArray(chars: searchString)
                let vc = self.searchController.searchResultsController as? ResultTableCitiesViewController
                vc?.filteredNames = cities
                vc?.tableView.reloadData()
                
            })
            .store(in: &cancellables)
        DatabaseService.shared.favoriteWorker
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {_ in
                self.configureViewModels()
                self.mainCollection.reloadData()})
            .store(in: &cancellables)
        
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
    
    func configureViewModels() {
        
        DataIterator.shared.preload {  closure in
            DispatchQueue.main.async {
                self.cellModel = closure
                
                self.mainCollection.reloadData()
            }
        }
    }
    

    
    
}
// MARK: - setupUI func
extension MainScreenWithCollectinViewController {
    func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = "Favorites"
        
        searchController.searchBar.placeholder = "Search for your new favorite city"
        
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
extension MainScreenWithCollectinViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        cellModel.count + 1
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // MARK: - geoCell
        
        if indexPath.row == 0 {
            let geoCell = mainCollection.dequeueReusableCell(withReuseIdentifier: GeoWeatherCellOnMainView.cellId, for: indexPath) as! GeoWeatherCellOnMainView
            
            
            if let location = locationManaging.location {
                self.lat = location.coordinate.latitude
                self.lon = location.coordinate.longitude
            }
            
            geoCell.configureDefault(city: "Loading", degrees: "loading", descriptionWeather: "", descrptionDegrees: "", icon: "")
            
            self.network.fetchData(requestType: .location(latitude: lat ?? 00.00, longitude: lon ?? 00.00)) { [weak self] result in
                
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        
                        guard let currentData = CustomWeatherCellModel(currentData: data) else { return }
                        geoCell.configure(data: currentData)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        geoCell.configureDefault(city: "Fail load", degrees: "", descriptionWeather: "", descrptionDegrees: "", icon: "")
                    }
                }
            }
            
            return geoCell
        }
        
        let cell = mainCollection.dequeueReusableCell(withReuseIdentifier: WeatherCellOnMainView.cellId, for: indexPath) as! WeatherCellOnMainView
        
        cell.cityItemModel = cellModel[indexPath.row - 1]
        return cell
    }
}
// MARK: - UICollectionViewDataDelegate()
extension MainScreenWithCollectinViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = DetailCityViewController()

        vc.currentPageNumber = indexPath.row - 1

        vc.cityItemModel = cellModel
       
        self.present(vc, animated: true)
    }
}


// MARK: Search Updating
extension MainScreenWithCollectinViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        
        searchPublisher.send(text)
    }
}
// MARK: - location Setup

extension MainScreenWithCollectinViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let index = IndexPath(item: 0, section: 0)
        self.mainCollection.reloadItems(at: [index])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - Right bar item (settings)
extension MainScreenWithCollectinViewController {
    func setupNavigationItem() {
        self.setNavigationItem(bool: false)
    }
    
    @objc func rightBarSettingsAction() {
        let vc = SettingsViewController()
        vc.completion = {[weak self] bool, int in
            guard let self = self else { return }
            DataIterator.shared.filtering(degree: String(int)) {  closure in
                DispatchQueue.main.async {
                    self.cellModel = closure
                    
                    self.mainCollection.reloadData()
                }
            }
            self.isFiltering = bool
            
            self.setNavigationItem(bool: bool)
            
            self.mainCollection.reloadData()
            
        }
        self.present(vc, animated: true)
    }
    
}
// пробросить из ячейки лонгтап и обработать в контроллере
// привести в порядок

// MARK: - actions
extension MainScreenWithCollectinViewController {
    @objc func longDeleteItem(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        let point = sender.location(in: self.mainCollection)
        let indexPath = self.mainCollection.indexPathForItem(at: point)
        let item = indexPath!.item
        let section = indexPath!.section
        let names = DatabaseService.shared.allFavorites()
        let indexNames = names[indexPath!.item - 1]
        
        let alert = UIAlertController(title: "Deleting city", message: "City was remove from favorites", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            
            print("kuka \(indexNames)")
            DatabaseService.shared.removeFromFavorite(city: indexNames)
            
            self.configureViewModels()
            NotificationCenter.default.post(name: Notification.Name("add favorite"), object: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}

// MARK: - Refresh Controller
extension MainScreenWithCollectinViewController {
    func setupRefresh() {
        self.mainCollection.refreshControl = UIRefreshControl()
        self.mainCollection.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        
        DispatchQueue.main.async {
            DataIterator.shared.updatingData { closure in
                DispatchQueue.main.async {
                    
                }
            }
            self.configureViewModels()
        }
        self.mainCollection.refreshControl?.endRefreshing()
    }
}


