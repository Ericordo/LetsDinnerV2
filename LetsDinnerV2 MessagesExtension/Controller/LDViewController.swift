//
//  LDViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 10/11/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class LDViewController: UIViewController {

    private var offlineVC: NoNetworkViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.shared.reachability.whenUnreachable = { reachability in
            self.showOfflinePage()
        }
        NetworkManager.shared.reachability.whenReachable = { reachability in
            self.removeOfflinePage()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NetworkManager.isReachable(completed: { [weak self] _ in
            guard let self = self else { return }
            self.removeOfflinePage()
        })
        NetworkManager.isUnreachable(completed: { [weak self] _ in
            guard let self = self else { return }
            guard self.offlineVC == nil else { return }
            self.showOfflinePage()
        })
        self.showLandscapeViewControllerIfNeeded()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        switch newCollection.verticalSizeClass {
        case .compact:
            self.addLandscapeViewController()
        case .regular, .unspecified:
            self.removeLandscapeViewController()
        @unknown default:
            fatalError()
        }
    }
    
    private func showLandscapeViewControllerIfNeeded() {
        if self.isPhoneLandscape {
            self.addLandscapeViewController()
        } else {
            removeLandscapeViewController()
        }
    }
    
    private func addLandscapeViewController() {
        if !children.contains(where: { $0.isKind(of: LandscapeViewController.self) }) {
            let controller = LandscapeViewController()
            self.addChildViewController(controller: controller)
        }
    }
    
    private func removeLandscapeViewController() {
        children.forEach { child in
            if child.isKind(of: LandscapeViewController.self) {
                    child.willMove(toParent: nil)
                    child.view.removeFromSuperview()
                    child.removeFromParent()
            }
        }
    }

    private func addChildViewController(controller: UIViewController) {
         addChild(controller)
         controller.view.frame = view.bounds
         view.addSubview(controller.view)
        controller.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
         controller.didMove(toParent: self)
     }
    
    private func showOfflinePage() {
        self.offlineVC = NoNetworkViewController()
        guard let offlineVC = self.offlineVC else { return }
        self.addChildViewController(controller: offlineVC)
    }
    
    private func removeOfflinePage() {
        if let offlineVC = self.offlineVC {
            DispatchQueue.main.async {
                offlineVC.view.removeFromSuperview()
                offlineVC.removeFromParent()
            }
        }
        self.offlineVC = nil
    }
}
