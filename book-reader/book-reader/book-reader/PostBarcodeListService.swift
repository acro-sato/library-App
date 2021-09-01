//
//  PostBarcodeListService.swift
//  book-reader
//
//  Created by 佐藤史也 on 2021/08/18.
//
import Foundation


struct Response: Codable {
    var status: Int
    var message: String
}

class PostBarcodeListService {
    
    func postBarcodeList(barcodeInfoList: [[String: String]], completion: @escaping (Bool) -> Void) {
        // GASのAPIのURL
        let urlString = "https://script.google.com/macros/s/AKfycbyUepCA_BV5FI0HcBet3AclxkQv3n2XBjLvik9e9P7piR-QI9wL/exec"
        
        // URLをリクエストする
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params:[String: [[String:String]]] = ["barcode_list":barcodeInfoList]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            completion(false)
            return
        }
        
        
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
            
            
            guard let jsonData = data else {
                completion(false)
                return
            }
            
            do {
                
                let response = try JSONDecoder().decode(Response.self, from: jsonData)
               
                response.status == 200 ? completion(true) : completion(false)
                
            } catch {
                completion(false)
                return
            }
            
        })
        task.resume()
    }
}

