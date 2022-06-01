import UIKit
import GoogleMaps
import CoreLocation

final class RoomPositionMapViewController: UIViewController, CLLocationManagerDelegate {
    
    private let mapBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: 37.490864, longitude: 127.033406, zoom: 16)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    typealias Cell = RoomPositionMapCollectionViewCell
    typealias Item = RoomPositionInfo
    private let collectionViewDataSource = CustomCollectionViewDataSource<Cell, Item>(identifier: Cell.identifier,
                                                                                      items: []) { cell , item in
        cell.updateInfo(title: item.roomName,
                        price: String(item.price),
                        starCount: String(item.averageOfStar),
                        reviewCount: String(item.numberOfReviews))
    }
    private lazy var roomPositionInfoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: 15)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.register(RoomPositionMapCollectionViewCell.self,
                                forCellWithReuseIdentifier: RoomPositionMapCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self.collectionViewDataSource
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private var roomPositionMapUseCase: RoomPositionMapUseCase?
    
    convenience init(roomPositionMapUseCase useCase: RoomPositionMapUseCase) {
        self.init()
        self.roomPositionMapUseCase = useCase
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roomPositionMapUseCase?.initialize()
        self.view.backgroundColor = .systemBackground
        
        addComponentViews()
        setComponentLayout()
        bindView()
        configureMap()
    }
    
    private func bindView() {
        self.roomPositionMapUseCase?.roomPositionInfoList.bind { [weak self] _ in
            guard let items = self?.roomPositionMapUseCase?.roomPositionInfoList.value else { return }
            self?.collectionViewDataSource.updateNewItems(items: items)
            self?.roomPositionInfoCollectionView.reloadData()
            self?.addMarkers(roomPositionInfoList: items)
        }
    }
    
    private func addComponentViews() {
        view.addSubview(mapBackgroundView)
        mapBackgroundView.addSubview(mapView)
        mapView.addSubview(roomPositionInfoCollectionView)
    }
    
    private func setComponentLayout() {
        NSLayoutConstraint.activate([
            mapBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            mapBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mapView.topAnchor.constraint(equalTo: mapBackgroundView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapBackgroundView.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: mapBackgroundView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mapBackgroundView.trailingAnchor),
            
            roomPositionInfoCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            roomPositionInfoCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            roomPositionInfoCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            roomPositionInfoCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
    }
    
    private func configureMap() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func addMarkers(roomPositionInfoList items: [RoomPositionInfo]) {
        for (index,item) in items.enumerated() {
            let latitude = Double(item.latitude) ?? 0.0
            let longitude = Double(item.longitude) ?? 0.0
            let coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)

            addMarker(coordinate: coordinate, title: String(item.price), snippet: "가격표시")
            if index == 0 { moveToTargetPosition(coordinate: coordinate)}
        }
        
        func addMarker(coordinate: CLLocationCoordinate2D, title: String, snippet: String) {
            let marker = GMSMarker()
            marker.position = coordinate
            marker.title = title
            marker.snippet = snippet
            marker.map = mapView
        }
    }
    
    private func moveToTargetPosition(coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition(target: coordinate, zoom: 16)
        self.mapView.camera = camera
    }
}

extension RoomPositionMapViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.9, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let items = self.roomPositionMapUseCase?.roomPositionInfoList.value else { return }
        let itemCount = items.count
        let fullWidth = self.roomPositionInfoCollectionView.frame.width
        let contentOffsetX = targetContentOffset.pointee.x
        
        let targetItem = lround(Double(contentOffsetX/fullWidth))
        let targetIndex = targetItem % itemCount
        
        let latitude = Double(items[targetIndex].latitude) ?? 0.0
        let longitude = Double(items[targetIndex].longitude) ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        
        self.moveToTargetPosition(coordinate: coordinate)
    }
}