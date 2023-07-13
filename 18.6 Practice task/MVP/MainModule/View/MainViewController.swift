//
//  ViewController.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 4/24/23.
//

import UIKit
import SnapKit

protocol MainViewProtocol: AnyObject {
    func seccess()
    func imageLoadingSecces(for indexParh: IndexPath)
    func failure()
}

class MainViewController: UIViewController {
    
    var presenter: MainPresenterProtocol!
        
    private var reuseCellIdentifier = "standartCell"
    
    private lazy var mainTableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    private lazy var mainSearchBar: UISearchBar  = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = Constants.Titles.placeholder
        return searchBar
    }()
    
    private lazy var aboutInfo: UILabel = {
        let label = UILabel()
        label.text = Constants.Titles.info
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        return view
    }()

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(mainTableView)
        view.addSubview(mainSearchBar)
        view.addSubview(aboutInfo)
        mainSearchBar.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        aboutInfo.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalTo(mainSearchBar.snp.top)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        mainSearchBar.snp.makeConstraints { make in
            make.bottom.equalTo(mainTableView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        mainTableView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.trailing.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(mainSearchBar.searchTextField.snp.leading).inset(17)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
}

// MARK: - TableView DataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getSearchResults().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseCell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier) ?? UITableViewCell()
        configure(cell: &reuseCell, for: indexPath)
        return reuseCell
    }
    
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        var configuration = cell.defaultContentConfiguration()
        
        var title = presenter.getSearchResults()[indexPath.row].title
        if let startYear = presenter.getSearchResults()[indexPath.row].start?.prefix(4) {
            title += " (\(startYear))"
        }
        configuration.text = "\(title)"
        
        let ganres = presenter.getSearchResults()[indexPath.row].genres.joined(separator: ", ")
        configuration.secondaryText = "\(ganres)"

        configuration.image = presenter.getImage(for: indexPath)
        
        // установка максимального размера картинки в ячейке
        var imageProperties = configuration.imageProperties
        imageProperties.maximumSize = CGSize(width: 100, height: 100)
        configuration.imageProperties = imageProperties
        
        cell.contentConfiguration = configuration
    }
}

// MARK: - TableView Delegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = ModuleBuilder.createDetailModule(result: presenter.getSearchResults()[indexPath.row])
        self.navigationController?.pushViewController(view, animated: true)
    }
}

// MARK: - SearchBar Delegate

extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        activityIndicator.startAnimating()
        // прячем левую вью searchTextField для отображения activityIndicator
        mainSearchBar.searchTextField.leftView?.isHidden = true
        // скрываем клавиатуру после нажатия
        searchBar.resignFirstResponder()
        presenter.doSearchResult(searchExpression: searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        activityIndicator.stopAnimating()
        mainSearchBar.searchTextField.leftView?.isHidden = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}

// MARK: - MainModuleViewProtocol

extension MainViewController: MainViewProtocol {
    func seccess() {
        // после успешного завершения запроса обновляем таблицу
        self.mainTableView.reloadData()
        self.activityIndicator.stopAnimating()
        self.mainSearchBar.searchTextField.leftView?.isHidden = false
    }
    
    func imageLoadingSecces(for indexParh: IndexPath) {
        // после загрузки картинки обновить ячейку
        self.mainTableView.reloadRows(at: [indexParh], with: .none)
    }
    
    func failure() {
        print("Error")
    }
    
}
