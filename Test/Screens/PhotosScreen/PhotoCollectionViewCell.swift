//
//  PhotoCollectionViewCell.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    static var identifier: String = "photoCell"
    var height: CGFloat = 0.0
    private lazy var mainImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImageView.image = nil
    }
    
    func configurateCellWithImage(url: URL) {
        mainImageView.downloaded(from: url, contentMode: .scaleAspectFill)
        setupMainImageView()
        height = mainImageView.image?.size.height ?? 250
    }
    
    func selectCell() {
        contentView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        contentView.layer.borderWidth = 3
        contentView.layer.cornerRadius = 10
        
        CustomImageView.animate(withDuration: 0.15, animations: {
            self.mainImageView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        })
    }
    
    func deselectCell() {
        contentView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor
        
        CustomImageView.animate(withDuration: 0.15, animations: {
            self.mainImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    private func setupMainImageView() {
        contentView.addSubview(mainImageView)
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            mainImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
    }
    
}
