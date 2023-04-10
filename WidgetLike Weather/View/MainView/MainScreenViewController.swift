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

class MainScreenViewController: UIViewController {
    
    // MARK: - elements of view
    private lazy var searchController: UISearchController = {
        let vc = ResultVc()
        return UISearchController(searchResultsController: vc)
    }()
    
    private lazy var mainCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collection.dataSource = self
        collection.delegate = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(WeatherCell.self, forCellWithReuseIdentifier: WeatherCell.cellId)
        collection.register(GeoWeatherCell.self, forCellWithReuseIdentifier: GeoWeatherCell.cellId)
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    var isCitiesLoaded = false
    var isFiltering = false
    var cancellables: Set<AnyCancellable> = []
    //    var favoriteCities: [FavoriteCity] = []
    //    var filteredCities: [FavoriteCity] = []
    
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
    
    private var addCityVC: AddCityScreen!
    
    let dataService = DataService()
    
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
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        //        print(path)
        setupNavigationItem()
        locationManaging.delegate = self
        let ac = Database.shared.filteringFavorites(degree: "230")
        print("items \(ac)")
        
        //        locationManaging.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManaging.requestLocation()
                self.locationManaging.startUpdatingLocation()
            }
        }
        
        setupUI()
        let longPress = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(longDeleteItem))
        self.mainCollection.addGestureRecognizer(longPress)
        
        
        searchPublisher
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap({ $0 })
            .sink(receiveValue: {[weak self] (searchString: String) in
                guard let self = self else { return }
                let cities = Database.shared.getCityFromDBtoStringArray(chars: searchString)
                let vc = self.searchController.searchResultsController as? ResultVc
                vc?.filteredNames = cities
                vc?.tableView.reloadData()
                
            })
            .store(in: &cancellables)
        Database.shared.favoriteWorker
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
        
        DataService.shared.preload {  closure in
            DispatchQueue.main.async {
                self.cellModel = closure
                print("memm \(closure)")
                self.mainCollection.reloadData()
            }
        }
    }
    
}
// MARK: - setupUI func
extension MainScreenViewController {
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
extension MainScreenViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //        if isFiltering == false {
        //            return favoriteCities.count + 1
        //        } else {
        //            return (filteredCities.count + 1)
        //        }
        //        let result = Database.shared.favoriteCount() + 1
        //        return result
        cellModel.count + 1
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // MARK: - geoCell
        
        if indexPath.row == 0 {
            let geoCell = mainCollection.dequeueReusableCell(withReuseIdentifier: GeoWeatherCell.cellId, for: indexPath) as! GeoWeatherCell
            
            if let location = locationManaging.location {
                self.lat = location.coordinate.latitude
                self.lon = location.coordinate.longitude
            }
            
            geoCell.configureDefault(city: "Loading", degrees: "loading", descriptionWeather: "", descrptionDegrees: "", icon: "")
            
            self.network.fetchData(requestType: .location(latitude: lat ?? 00.00, longitude: lon ?? 00.00)) { [weak self] result in
                
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        
                        guard let currentData = WeatherCellModel(currentData: data) else { return }
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
        
        let cell = mainCollection.dequeueReusableCell(withReuseIdentifier: WeatherCell.cellId, for: indexPath) as! WeatherCell
        
        cell.cityItemModel = cellModel[indexPath.row - 1]
        return cell
    }
}
// MARK: - UICollectionViewDataDelegate()
extension MainScreenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = PageViewController()
        vc.currentPageNumber = indexPath.row - 1
        vc.cityItemModel = cellModel
        present(vc, animated: true)
        
    }
}


// MARK: Search Updating
extension MainScreenViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        
        searchPublisher.send(text)
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

//struct DataCacheService {
//
//    var connection: Connection?
//    static private(set) var shared = DataCacheService()
//    
//    private init() {
//        do {
//            guard var userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//            userDirectory.appendPathComponent("DataCache")
//            userDirectory.appendPathExtension("sqlite3")
//            connection = try SQLite.Connection(userDirectory.path)
////            connection.run
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    public func clear() {
//        guard var userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        userDirectory.appendPathComponent("DataCache")
//        userDirectory.appendPathExtension("sqlite3")
//        try? FileManager.default.removeItem(at: userDirectory)
//        DataCacheService.shared = DataCacheService()
//    }
//}
// MARK: - Right bar item (settings)
extension MainScreenViewController {
    func setupNavigationItem() {
        self.setNavigationItem(bool: false)
    }
    
    @objc func rightBarSettingsAction() {
        let vc = FilterSettingsViewController()
        vc.completion = {[weak self] bool, int in
            guard let self = self else { return }
            //            self.filteredCities = self.favoriteCities.filter { favorite in
            //                favorite.degrees ?? 0 > Double(int)
            //            }
            //            self.isFiltering = bool
            //
            //            self.setNavigationItem(bool: bool)
            //
            //            self.mainCollection.reloadData()
            //        }
            //        present(vc, animated: true)
        }
    }
}
// MARK: - actions
extension MainScreenViewController {
    @objc func longDeleteItem(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        let point = sender.location(in: self.mainCollection)
        let indexPath = self.mainCollection.indexPathForItem(at: point)
        let item = indexPath!.item
        let section = indexPath!.section
        let names = Database.shared.allFavorites()
        let indexNames = names[indexPath!.item - 1]
        
        let alert = UIAlertController(title: "Deleting city", message: "City was remove from favorites", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            //                                  CitiesService.shared.deleteFavorite(indexPath)
            //
            print("kuka \(indexNames)")
            Database.shared.removeFromFavorite(city: indexNames)
            
            //            self.mainCollection.performBatchUpdates {
            //                self.mainCollection.deleteItems(at: [IndexPath(item: item, section: section)] )
            //
            //            }
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
extension MainScreenViewController {
    func setupRefresh() {
        self.mainCollection.refreshControl = UIRefreshControl()
        self.mainCollection.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        
        DispatchQueue.main.async {
            DataService.shared.updatingData { closure in
                DispatchQueue.main.async {
                    print("memm \(closure)")
                }
            }
            self.configureViewModels()
        }
        self.mainCollection.refreshControl?.endRefreshing()
    }
}
