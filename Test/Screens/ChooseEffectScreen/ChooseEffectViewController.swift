//
//  ChooseEffectViewController.swift
//  Test
//
//  Created by Владислав Ковальский on 25.01.2023.
//

import UIKit

enum AlertType {
    case inProgress
    case success
    case error
}

enum EffectType {
    case leftToRight
    case bottomToTop
}

class ChooseEffectViewController: UIViewController {
    private var alert: UIAlertController?
    private var imagesURLsArray: [URL] = []
    private var currentEffectType: EffectType = .leftToRight
    private var continueButton = CustomNextButton()
    private var leftToRight = UIButton()
    private var bottomToTop = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func getImagesURLs(urls: [URL]) {
        guard imagesURLsArray.isEmpty else {
            imagesURLsArray.removeAll()
            return
        }
        
        guard urls.count == 2 else { return }
        
        imagesURLsArray.append(contentsOf: urls)
    }
}

private extension ChooseEffectViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        setupNavigationBar()
        setupButtons()
    }
    
    func setupNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        let backButton: UIBarButtonItem = .init(image: #imageLiteral(resourceName: "backButton").withRenderingMode(.alwaysOriginal),
                                                style: .done,
                                                target: self,
                                                action: #selector(backAction))
        navigationItem.title = "Select 1 effect"
        navigationItem.setLeftBarButton(backButton, animated: true)
        navigationBar?.layer.cornerRadius = 5
        navigationBar?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        //        navigationBar?.layer.shadowColor = UIColor.black.cgColor
        //        navigationBar?.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        //        navigationBar?.layer.shadowRadius = 4.0
        //        navigationBar?.layer.shadowOpacity = 1.0
        
    }
    
    func createButtons(label: String, image: UIImage, action: Selector) -> UIButton {
        let attributedButtonTitle = NSMutableAttributedString(string: label, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        
        var configuration = UIButton.Configuration.bordered()
        configuration.image = image
        configuration.imagePlacement = .top
        configuration.imagePadding = 12
        
        let button = UIButton(configuration: configuration)
        button.setAttributedTitle(attributedButtonTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        
        return button
    }
    
    func createVerticalStackView() -> UIStackView {
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.contentMode = .scaleAspectFill
        verticalStackView.spacing = 8
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.distribution = .fillEqually
        return verticalStackView
    }
    
    func setupButtons() {
        leftToRight = createButtons(label: "Screwing",
                                           image: #imageLiteral(resourceName: "screwing").withRenderingMode(.alwaysOriginal),
                                           action: #selector(leftToRightButtonAction))
        
        bottomToTop = createButtons(label: "From right to left",
                                              image: #imageLiteral(resourceName: "rightToLeft").withRenderingMode(.alwaysOriginal),
                                              action: #selector(bottomToTopButtonAction))
        
        continueButton.configurateSelf(color: #colorLiteral(red: 0.6000000834, green: 0.6000000834,
                                                            blue: 0.6000000834, alpha: 1),
                                       action: #selector(continueButtonAction),
                                       target: self)
        
        continueButton.isEnabled = false
        
        let verticalStackView = createVerticalStackView()
        
        [verticalStackView, continueButton].forEach({
            view.addSubview($0)
        })
        
        [leftToRight, bottomToTop].forEach({
            verticalStackView.addArrangedSubview($0)
        })
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            verticalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 52),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -56)
        ])
    }
    
    func createAlert(type: AlertType) {
        alert?.dismiss(animated: true)
        switch type {
        case .inProgress:
            alert = UIAlertController(title: "",
                                      message: "Wait a little bit",
                                      preferredStyle: .alert)
            guard let alert = alert else { return }
            let attributedTitle = NSAttributedString(string: "Video Processing", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .bold)
            ])
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            
            let loadingIndicator = UIActivityIndicatorView(frame: alert.view.bounds)
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator.center = alert.view.center
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .large
            loadingIndicator.color = .black
            
            alert.view.addSubview(loadingIndicator)
            loadingIndicator.isUserInteractionEnabled = false
            loadingIndicator.startAnimating()
            
            NSLayoutConstraint.activate([
                loadingIndicator.topAnchor.constraint(equalTo: alert.view.safeAreaLayoutGuide.topAnchor, constant: 100),
                loadingIndicator.centerXAnchor.constraint(equalTo: alert.view.safeAreaLayoutGuide.centerXAnchor),
                loadingIndicator.bottomAnchor.constraint(equalTo: alert.view.safeAreaLayoutGuide.bottomAnchor, constant:  -33)
            ])
        case .success:
            alert = UIAlertController(title: "",
                                      message: "Video successfully saved to your gallery",
                                      preferredStyle: .alert)
            
            guard let alert = alert else { return }
            
            let attributedTitle = NSAttributedString(string: "It's done", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .bold)
            ])
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            
            let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.navigationController?.popToRootViewController(animated: true)
            })
            alert.addAction(action)
        case .error:
            alert = UIAlertController(title: "",
                                      message: "Failed to save video",
                                      preferredStyle: .alert)
            
            guard let alert = alert else { return }
            
            let attributedTitle = NSAttributedString(string: "Error", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .bold),
                NSAttributedString.Key.foregroundColor : UIColor.red
            ])
            alert.setValue(attributedTitle, forKey: "attributedTitle")
            
            let action = UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.navigationController?.popToRootViewController(animated: true)
            })
            alert.addAction(action)
        }
        
        guard let alert = alert else { return }
        
        self.present(alert, animated: true)
        
    }
    
    func selectOrDeselectButton(isSelected: Bool, button: UIButton) {
        switch isSelected {
        case true:
            continueButton.isEnabled = true
            continueButton.backgroundColor = .black
            
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 3
        case false:
            button.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
}

private extension ChooseEffectViewController {
    @objc
    func backAction() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    func continueButtonAction() {
        guard imagesURLsArray.count == 2 else {
            createAlert(type: .error)
            return
        }
    
        var imagesArray = [UIImage]()
        
        imagesURLsArray.forEach({ url in
            ImageFromNet.getImageFromNet(url: url, completion: { image in
                guard let unwImage = image else { return }
                imagesArray.append(unwImage)
            })
        })
        
        createAlert(type: .inProgress)
        
        let settings = RenderSettings(size: CGSize(width: 1920, height: 1080), fps: 1)
        let imageAnimator = ImageAnimator(renderSettings: settings, images: imagesArray)
        imageAnimator.render(effectType: currentEffectType) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.createAlert(type: .success)
            })
        }
    }
    
    @objc
    func leftToRightButtonAction() {
        currentEffectType = .leftToRight
        selectOrDeselectButton(isSelected: false, button: bottomToTop)
        selectOrDeselectButton(isSelected: true, button: leftToRight)
    }
    
    @objc
    func bottomToTopButtonAction() {
        currentEffectType = .bottomToTop
        selectOrDeselectButton(isSelected: false, button: leftToRight)
        selectOrDeselectButton(isSelected: true, button: bottomToTop)
    }
}
