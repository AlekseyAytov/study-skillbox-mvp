//
//  ModuleBuider.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 7/12/23.
//

import UIKit

protocol ModuleBuilderProtocol {
    static func createMainModule() -> UIViewController
//    static func createDetailModule(_ data: ResultForDisplay) -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    static func createMainModule() -> UIViewController {
        let view = MainModuleViewController()
        let networkService = NetworkService()
        let mainPresenter = MainModulePresenter(view: view, networkService: networkService)
        view.presenter = mainPresenter
        return view
    }
    
//    static func createDetailModule(_ data: ResultForDisplay) -> UIViewController {
//        let viewController = DetailViewController()
//        let detailVCPresenter = DetailViewPresenter(about: data)
//        viewController.presenter = detailVCPresenter
//        return viewController
//    }
}
