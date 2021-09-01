//
//  GetBookListService.swift
//  book-reader
//
//  Created by Mai Kishima on 2021/08/17.
//

import Foundation

// 書籍情報の構造体
struct Books: Codable {
    var bookList: [Book]
}
struct Book: Codable {
    var barcode: Int
    var title: String
    var thumbnail: String
    var description: String
    var status: Int
}

class GetBookListService {
    /// 書籍情報の取得API
    /// - Parameter completion: 本のデータを引数にしたクロージャ
    func getBooks(completion: @escaping (Books?) -> Void ) {
        
        // スプレッドシートの情報取得
        let urlStr = "https://script.google.com/macros/s/AKfycbyUepCA_BV5FI0HcBet3AclxkQv3n2XBjLvik9e9P7piR-QI9wL/exec?kind=all"
        
        guard let urlComponents = URLComponents(string: urlStr),
              let url = urlComponents.url else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // optional型を安全に外してdata型として変数jsonDataに代入
            guard let jsonData = data else {
                
                completion(nil)
                return
            }
            do {
                // JSONDecoderのインスタンス化
                // jsonのスネークケースをキャメルケースに自動変更
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                // jsonデータをSwiftが扱いやすい形に変更
                let decodeResponse = try decoder.decode(Books.self, from: jsonData)
                completion(decodeResponse)
                
            } catch {
                
                completion(nil)
            }
        }
        task.resume()
    }
}
