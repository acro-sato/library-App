//
//  Next3ViewController.swift
//  book-reader
//
//  Created by 佐藤史也 on 2021/07/28.
//

import UIKit

class BookSearchViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    
    // 検索対象のISBN情報
    var isbn:String?
    
    // 著者情報の検索結果
    var authors = [String]()
    
    // アラートダイアログ
    var alertController: UIAlertController!
    
    
    @IBOutlet weak var alertText: UILabel!
    
    // 検索テキストフィールド
    @IBOutlet weak var search: UITextField!
    {
        willSet{
            newValue.delegate = self
        }
    }
    
    // 検索ボタン
    @IBOutlet weak var searchButton: UIButton!
    
    // タイトルテキストラベル
    @IBOutlet weak var titleInfo: UILabel!
    
    // 著者テキストラベル
    @IBOutlet weak var authorsTableView: UITableView!
    {
        willSet{
            newValue.delegate = self
            newValue.dataSource = self
        }
    }
   
    // 概要テキストラベル
    @IBOutlet weak var descriptionInfo: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITapGestureRecognizerの設定
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                tapGR.cancelsTouchesInView = false
                self.view.addGestureRecognizer(tapGR)
    }
    
    // キーボード以外の画面をタップしたらキーボードを閉じる処理
    @objc func dismissKeyboard() {
            self.view.endEditing(true)
        }
    
    @IBAction func pushSearch(_ sender: Any) {
        isbn = search.text
        self.sendGetAPI()
        titleInfo.adjustsFontSizeToFitWidth = true
        alertText.text = ""
    }
    
    // テキストフィールドのバリデーション設定
    // テキストフィールドに入力される度に呼ばれる
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // searchテキストフィールドのバリデーション
        if textField == search {
            // 入力可能な文字列
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789 ")
            let characterSet = CharacterSet(charactersIn: string)
            
            if allowedCharacters.isSuperset(of: characterSet) == false{
                alertText.text = "・半角数字で入力してください"
            }
            
            return allowedCharacters.isSuperset(of: characterSet)
        }
       
        return true
    }
    
    // APIを呼び出す関数
    func sendGetAPI() {
        // GetBookInfoServiceモデルのインスタンス
        let service = GetBookInfoService()
        service.getBookInfo(isbn: isbn!) { bookInfo in
            guard let infos = bookInfo else {
                DispatchQueue.main.sync {
                    // UIAlertConrtollerの生成
                    let alert = UIAlertController(title: "検索に失敗しました", message: "正しくISBNを入力してください", preferredStyle: .alert)
                    // アクションの生成
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    // アクション追加
                    alert.addAction(okAction)
                    
                    // アラートの表示
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            // APIから取得したタイトル情報
            let title = infos.items[0].volumeInfo.title
            
            // APIから取得した著者情報
            let authorsArray = infos.items[0].volumeInfo.authors
            
            // APIから取得した説明文情報
            let description = infos.items[0].volumeInfo.description
            
            // グローバル変数化
            self.authors = authorsArray
            
            DispatchQueue.main.sync {
                self.titleInfo.text = title
                self.authorsTableView.reloadData()
                self.descriptionInfo.text = description
            }
        }
    }
    
    // 以下テーブルビューの設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authors.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = authorsTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = authors[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
