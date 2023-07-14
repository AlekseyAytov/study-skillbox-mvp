//
//  SceneDelegate.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 4/24/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let mainVC = ModuleBuilder.createMainModule()

        let naaavi = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = naaavi
        window?.makeKeyAndVisible()
    }
}
