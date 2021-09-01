//
//  GetBookInfoService.swift
//  book-reader
//
//  Created by 福嶋一希(業務用) on 2021/08/19.
//

import Foundation

// JSONのデータ構造
struct ResultJson: Codable {
    var kind: String
    var totalItems: Int
    var items:[Item]
    struct Item: Codable {
        var volumeInfo: VolumeInfoJson
        
        struct VolumeInfoJson: Codable {
            var title: String
            var authors: [String]
            var description: String
            var imageLinks: ImageLinkJson
            
            struct ImageLinkJson: Codable {
                var smallThumbnail: URL?
            }
        }
    }
}

class GetBookInfoService {
    func getBookInfo(isbn: String, completion: @escaping (ResultJson?) -> Void) {
        // GASのAPIのURL
        let urlStr = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        
        guard let urlComponents = URLComponents(string: urlStr),
                    let url = urlComponents.url else {
                    completion(nil)
                    return
                }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    
                    guard let d = data else {
                        completion(nil)
                        return
                    }

                    do {
                        let decodeResponse = try JSONDecoder().decode(ResultJson.self, from: d)

                        completion(decodeResponse)
                    } catch {
                        completion(nil)
                        print(completion)
                        return
                    }
                }
            task.resume()
        }
    }
