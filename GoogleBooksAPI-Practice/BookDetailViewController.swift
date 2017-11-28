//
//  BookDetailViewController.swift
//  GoogleBooksAPI-Practice
//
//  Created by C4Q on 11/28/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var book: Book!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI() {
        titleLabel.text = book.volumeInfo.title
        subtitleLabel.text = book.volumeInfo.subtitle ?? "No Subtitle Available"
        authorLabel.text = book.volumeInfo.authors?.joined(separator: ", ") ?? "No authors available"
        descriptionTextView.text = book.volumeInfo.description ?? "No description available"
        setUpImages()
    }
    
    func setUpImages() {
        guard let imageURLString = book.volumeInfo.imageLinks.thumbnail else {
            return
        }
        
        ImageAPIClient.manager.getImage(
            from: imageURLString,
            completionHandler: { (onlineImage) in
                DispatchQueue.main.async {
                    self.bookImageView.image = onlineImage
                }
        },
            errorHandler: { (error) in
                print(error)
                })
    }
}
