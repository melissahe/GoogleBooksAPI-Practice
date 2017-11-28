//
//  BooksViewController.swift
//  GoogleBooksAPI-Practice
//
//  Created by C4Q on 11/28/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import UIKit

class BookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //Table View Variables
    @IBOutlet weak var tableView: UITableView!
    var books = [Book]()
    
    //Search Bar Variables
    @IBOutlet weak var searchBar: UISearchBar!
    var filteringIsOn: Bool = false
    var searchTerm: String = "" {
        didSet {
            if searchTerm == "" {
                filteringIsOn = false
            } else {
                filteringIsOn = true
            }
            
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func loadData() {
        let urlString = (!filteringIsOn) ? ("https://www.googleapis.com/books/v1/volumes?q=Pratchett") : ("https://www.googleapis.com/books/v1/volumes?q=\(searchTerm)&maxResults=40")
        
        BookAPIClient.manager.getBooks(
            from: urlString,
            completionHandler: { (onlineBooks) in
                DispatchQueue.main.async {
                    self.books = onlineBooks
                    self.tableView.reloadData()
                }
        },
            errorHandler: { (error: AppError) -> Void in
                DispatchQueue.main.async {
                    switch error {
                    case .couldNotParseJSON(rawError: let error):
                        self.searchBar.text = "JSONError: \(error)"
                    case .noInternetConnection:
                        self.searchBar.text = "No internet connection"
                    default:
                        self.searchBar.text = "Other error"
                    }
                }
        })
    }
    
    //Table View Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "detailedSegue", sender: selectedCell)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        let currentBook = books[indexPath.row]
        
        cell.textLabel?.text = currentBook.volumeInfo.title
        cell.detailTextLabel?.text = currentBook.volumeInfo.subtitle
        //resets the image before you set it to the next one - should help with flickering
        cell.imageView?.image = nil
        
        guard let imageURLString = currentBook.volumeInfo.imageLinks.thumbnail else {
            return cell
        }
        
        ImageAPIClient.manager.getImage(
            from: imageURLString,
            completionHandler: { (onlineImage) in
                DispatchQueue.main.async {
                    cell.imageView?.image = onlineImage
                    cell.setNeedsLayout()
                }
        },
            errorHandler: { (error) in
                switch error {
                case .badURL:
                    print("bad url")
                default:
                    print("other error")
                }
        })
        
        return cell
    }
    
    //Search Bar Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        
        searchTerm = searchText
    }
    
    //Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? BookDetailViewController, let cell = sender as? UITableViewCell, let currentIndexPath = tableView.indexPath(for: cell) {
            let currentBook = books[currentIndexPath.row]
            
            destinationVC.book = currentBook
        }
    }
}
