//
//  ModuleBuider.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 7/12/23.
//

import UIKit

protocol ModuleBuilderProtocol {
    static func createMainModule() -> UIViewController
    static func createDetailModule(result: ResultForDisplay) -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    static func createMainModule() -> UIViewController {
        let view = MainViewController()
        let networkService = NetworkService()
        let presenter = MainPresenter(view: view, networkService: networkService)
        view.presenter = presenter
        return view
    }
    
    static func createDetailModule(result: ResultForDisplay) -> UIViewController {
        let view = DetailViewController()
        let networkService = NetworkService()
        let presenter = DetailPresenter(view: view, networkService: networkService, result: result)
        view.presenter = presenter
        return view
    }
}
