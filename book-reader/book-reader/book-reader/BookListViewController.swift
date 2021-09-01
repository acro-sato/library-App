//
//  Next2ViewController.swift
//  book-reader
//
//  Created by 佐藤史也 on 2021/07/28.
//

import UIKit

class BookListViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    // 書籍情報を入れる配列
    var books = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getBooks()
    }
    
    func getBooks() {
        let getBooksService = GetBookListService()
        
        getBooksService.getBooks { bookList in
            guard let newBooks = bookList else {
                
                DispatchQueue.main.async {
                    // UIAlertControllerの生成
                    let alert = UIAlertController(title: "読み込みエラー", message: "もう一度やり直してください", preferredStyle: .alert)
                    
                    // アクションの生成
                    let okAction = UIAlertAction(title: "OK", style: .default) { action in
                        
                        // エラーの場合は前画面に戻る
                        self.navigationController?.popViewController(animated: true)
                    }
                    // アクションの追加
                    alert.addAction(okAction)
                    
                    // UIAlertControllerの表示
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            // 書籍のtitle情報のみを全て取得して配列に追加
            newBooks.bookList.forEach { book in
                self.books.append(book.title)
            }
            
            // mainスレッドに移動してrelode開始
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // リストに表示する文字列を決定し表示する
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        // 文字を表示するセルの取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // 表示したい文字の設定
        // indexPath.row行の数字を持っています。
        cell.textLabel?.text = books[indexPath.row]
        // 文字を設定した行を返す
        return cell
    }
    
    // 行数を決める
    func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int{
        return books.count
    }
}
