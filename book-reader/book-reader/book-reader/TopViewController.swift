//
//  ViewController.swift
//  book-reader
//
//  Created by Tatsumi.Yoshizaki on 2021/07/28.
//

import UIKit

class TopViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // ボタンのデザイン設定
    @IBOutlet weak var readingButton: UIButton! {
        willSet {
            self.layoutButton(button: newValue)
        }
    }
    
    @IBOutlet weak var listButton: UIButton! {
        willSet {
            self.layoutButton(button: newValue)
        }
    }
    
    @IBOutlet weak var bookSearchButton: UIButton!{
    willSet {
        self.layoutButton(button: newValue)
        }
    }
    
    @IBAction func readingButton(_ sender: Any) {
        //バーコード読み込み画面へ遷移
            performSegue(withIdentifier: "BarcodeReader", sender: nil)
    }
    
    @IBAction func listButton(_ sender: Any) {
        //書籍一覧画面へ遷移
        performSegue(withIdentifier: "BookList", sender: nil)
    }
    
    
    @IBAction func bookSearchButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toSearch", sender: self)
    }
}

// ボタンのデザイン設定を共通化
extension TopViewController {
    func layoutButton(button: UIButton) {
        button.layer.cornerRadius = 8.0
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 2.0
    
    }
}
