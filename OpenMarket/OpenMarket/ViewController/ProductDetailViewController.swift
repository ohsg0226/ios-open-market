//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/08/05.
//

import UIKit

final class ProductDetailViewController: UIViewController {

    private enum Section {
        case main
    }

    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, SaleInformation>

    // MARK: Initializtion
    
    init(product: SaleInformation) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.product = nil
        super.init(coder: coder)
    }
    
    // MARK: Properties
    
    let product: SaleInformation?
    private var productDetail: SaleInformation?
    private var dataSource: DiffableDataSource?
    private var snapshot = NSDiffableDataSourceSnapshot<Section, SaleInformation>()

    private let actionButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "square.and.arrow.up")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createDetailLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return collectionView
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = product?.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
        collectionView.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: "detail")
        dataSource = configureDataSource(id: "detail")
        self.snapshot.appendSections([.main])
        
        view.addSubview(collectionView)
        setCollectionViewConstraint()
        getProductDetail()
    }
    
    // MARK: Method
    
    private func getProductDetail() {
        guard let productId = product?.id else { return }
        guard let request = try? ProductRequest.item(productId).createURLRequest() else { return }
        
        NetworkManager().networkPerform(for: request) { result in
            switch result {
            case .success(let data):
                guard let productInfo = try? JSONDecoder().decode(SaleInformation.self, from: data) else { return }
                
                self.snapshot.appendItems([productInfo])
                self.dataSource?.apply(self.snapshot, animatingDifferences: false)
                
                self.productDetail = productInfo
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showCustomAlert(title: nil, message: error.localizedDescription)
                }
            }
        }
    }
    
    private func createDetailLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: Metric.padding, leading: Metric.padding, bottom: Metric.padding, trailing: Metric.padding)
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func setCollectionViewConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
    
    private func configureDataSource(id: String) -> DiffableDataSource? {
        dataSource = DiffableDataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, product: SaleInformation) -> UICollectionViewCell? in

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detail", for: indexPath) as? DetailCollectionViewCell else { return DetailCollectionViewCell() }

            cell.configureCell(product: product) { result in
                switch result {
                case .success(let images):
                    // 이미지 5개 다 들어와서 여기서 적용!
                    cell.pageControl.numberOfPages = images.count
                    
                    for index in 0..<images.count {
                        let imageView = UIImageView()
                        let positionX = self.view.frame.width * CGFloat(index)
                        imageView.frame = CGRect(x: positionX, y: 0, width: cell.imageScrollView.bounds.width, height: cell.imageScrollView.bounds.height)
                        imageView.image = cell.productImages[index]
                        cell.imageScrollView.contentSize.width = imageView.frame.width * CGFloat(index+1)
                    }
                return
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showCustomAlert(title: nil, message: error.localizedDescription)
                    }
                }
            }
            return cell
        }
        return dataSource
    }
}
