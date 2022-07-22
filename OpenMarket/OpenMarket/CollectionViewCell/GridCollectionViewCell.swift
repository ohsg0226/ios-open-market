//
//  GridCollectionViewCell.swift
//  OpenMarket
//
//  Created by unchain, hyeon2 on 2022/07/20.
//

import UIKit

class GridCollectionViewCell: ItemCollectionViewCell {
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(totalGridStackView)
        setGridStackView()
        setGridConstraints()
        
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.systemGray3.cgColor
    }
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    // MARK: Properties
    
    private let totalGridStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.axis = .vertical
    
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Method
    
    private func setGridStackView() {
        totalGridStackView.addArrangedSubview(productThumnail)
        totalGridStackView.addArrangedSubview(productName)
        totalGridStackView.addArrangedSubview(productPrice)
        totalGridStackView.addArrangedSubview(bargainPrice)
        totalGridStackView.addArrangedSubview(productStockQuntity)
    }
    
    private func setGridConstraints() {
        NSLayoutConstraint.activate([
            totalGridStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            totalGridStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            totalGridStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            totalGridStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        ])
    }
}