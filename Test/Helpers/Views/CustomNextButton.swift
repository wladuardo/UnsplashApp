//
//  CustomNextButton.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import UIKit

class CustomNextButton: UIButton {
    func configurateSelf(color: UIColor, action: Selector, target: Any?) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = color
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        self.setTitle("Next", for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.addTarget(target, action: action, for: .touchUpInside)
    }
}
