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
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(WeatherCell.self, forCellWithReuseIdentifier: WeatherCell.cellId)
        collection.register(GeoWeatherCell.self, forCellWithReuseIdentifier: GeoWeatherCell.cellId)
        collection.showsVerticalScrollIndicator = false
        
        return collection
    }()
    
	var isCitiesLoaded = false
	var cancellables: Set<AnyCancellable> = []
	var testMassiv: [String] {
		CitiesService.shared.favorites
	}
    
    private var network = NetworkManager()
	private var searchPublisher = PassthroughSubject<String, Never>()
    
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

		CitiesService.shared.loadCities()
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .finished: break
				case .failure(let error):
					print(error.localizedDescription)
				}
			} receiveValue: {[weak self] names in
				guard let self = self else { return }
				self.isCitiesLoaded = true
			}
			.store(in: &cancellables)
		
		searchPublisher
			.debounce(for: 0.5, scheduler: DispatchQueue.main)
			.removeDuplicates()
			.compactMap({ $0 })
			.sink(receiveValue: {[weak self] (searchString: String) in
				guard let self = self else { return }
				CitiesService.shared.searchCities(query: searchString)
					.receive(on: DispatchQueue.main)
					.sink { filteredNames in
						let vc = self.searchController.searchResultsController as? ResultVc
						vc?.filteredNames = filteredNames
						vc?.tableView.reloadData()
					}
					.store(in: &self.cancellables)
			})
			.store(in: &cancellables)
		
		CitiesService.shared.favoritesAppender
			.receive(on: DispatchQueue.main)
			.sink {[weak self] _ in
				guard let self = self else { return }
				self.mainCollection.reloadData()
			}
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
        return (testMassiv.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let geoCell = mainCollection.dequeueReusableCell(withReuseIdentifier: GeoWeatherCell.cellId, for: indexPath) as! GeoWeatherCell
            
            if let location = locationManaging.location {
                self.lat = location.coordinate.latitude
                self.lon = location.coordinate.longitude
            }
			
			geoCell.configure(city: "GeoCell", degrees: "Load")
			
            self.network.fetchData(requestType: .location(latitude: lat ?? 00.00, longitude: lon ?? 00.00)) { [weak self] result in
                
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        
                        geoCell.configure(city: data.city?.name ?? "no city", degrees: String( (data.list![0].main?.temp) ?? 00))
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
					DispatchQueue.main.async {
						geoCell.configure(city: "GeoCell", degrees: "Fail")
					}
                }
            }
            
            return geoCell
        }
        
        let cell = mainCollection.dequeueReusableCell(withReuseIdentifier: WeatherCell.cellId, for: indexPath) as! WeatherCell
        

        
        
		cell.configure(city: testMassiv[indexPath.row - 1], degrees: "Load")
        self.network.fetchData(requestType: .city(city: testMassiv[indexPath.row - 1])) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    cell.configure(city: data.city?.name ?? "no city", degrees: String( (data.list![0].main?.temp) ?? 00))
                    
                }
            case .failure(let error):
                print(error.localizedDescription)
				DispatchQueue.main.async {
					cell.configure(city: self!.testMassiv[indexPath.row - 1], degrees: "Fail")
					
				}
            }
        }
        return cell
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

struct DataCacheService {
	
	var connection: Connection?
	static private(set) var shared = DataCacheService()
	
	private init() {
		do {
			guard var userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
			userDirectory.appendPathComponent("DataCache")
			userDirectory.appendPathExtension("sqlite3")
			connection = try SQLite.Connection(userDirectory.path)
		} catch {
			print(error.localizedDescription)
		}
	}
	
	public func clear() {
		guard var userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
		userDirectory.appendPathComponent("DataCache")
		userDirectory.appendPathExtension("sqlite3")
		try? FileManager.default.removeItem(at: userDirectory)
		DataCacheService.shared = DataCacheService()
	}
}
