//
//  BookAPIClient.swift
//  GoogleBooksAPI-Practice
//
//  Created by C4Q on 11/28/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import Foundation
import UIKit

class BookAPIClient {
    private init() {}
    static let manager = BookAPIClient()
    func getBooks(from urlString: String, completionHandler: @escaping ([Book]) -> Void, errorHandler: @escaping (AppError) -> Void) {
        guard let url = URL(string: urlString) else {
            print("url didn't work")
            //could not convert url
            errorHandler(.badURL)
            return
        }
        
        let request = URLRequest(url: url)
        let urlSession = URLSession(configuration: .default)
        DispatchQueue.main.async {
            urlSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                if let error = error {
                    print(error)
                    
                    //NSError - older type error, old version of what error used to be
                        //how to check if you are not connected to the internet
                    let error = error as NSError
                    if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet {
                        //if no internet connection
                        errorHandler(AppError.noInternetConnection)
                    } else {
                        //some other error
                        errorHandler(AppError.other(rawError: error))
                        return
                    }
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    //if it didn't get a good status code
                    errorHandler(AppError.badStatusCode)
                    return
                }
                
                guard let data = data else {
                    print("no data")
                    //if no data was received
                    errorHandler(AppError.noDataReceived)
                    return
                }
                
                do {
                    let bookInfoDict = try JSONDecoder().decode(BookInfo.self, from: data)
                    
                    let books = bookInfoDict.items
                    
                    completionHandler(books)
                } catch let error {
                    print(error)
                    //couldn't parse json
                    errorHandler(.couldNotParseJSON(rawError: error))
                }
                }.resume()
        }
    }
}
