
import UIKit
import AVFoundation
import Foundation

class BarcodeReaderViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    // カメラビュー
    @IBOutlet weak var captureView: UIView!
    // バーコードテーブルビュー
    @IBOutlet weak var barcodeTableview: UITableView! {
        willSet {
            newValue.delegate = self
            newValue.dataSource = self
            
        }
    }
    // タイムスタンプとbarcodeのdictionaryの配列
    var barcodeInfoList = [[String: String]]()
    
    // キャプチャのセッション
    private lazy var captureSession: AVCaptureSession = AVCaptureSession()
    
    private lazy var captureDevice: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
    
    private lazy var capturePreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        return layer
    }()
    
    private var captureInput: AVCaptureInput? = nil
    
    private lazy var Output: AVCaptureMetadataOutput = {
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: .main)
        return output
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // カメラのセットアップ
        setupBarcodeCapture()
        
    }
    //カメラのレイアウト
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        capturePreviewLayer.frame = self.captureView?.bounds ?? CGRect.zero
    }
    
    @IBAction func bookListRegisterButton(_ sender: Any) {
        
        // GASのAPIにbarcodeInfoListの詳細を送る
        self.sendPostAPI()
    }
    
    private func sendPostAPI() {
        let service = PostBarcodeListService()
        
        service.postBarcodeList(barcodeInfoList: barcodeInfoList, completion:{ [self] result in
            
            if result && barcodeInfoList != [[String: String]]() {
                // time,barcodeList brank(空にする)
                self.barcodeInfoList.removeAll()
                
                DispatchQueue.main.sync {
                    displayAlert(status: .success)
                    
                    self.barcodeTableview.reloadData()
                }
            } else {
                DispatchQueue.main.sync {
                    displayAlert(status: .failure)
                }
            }
        })
    }
}
// MARK: - テーブルビュー
extension BarcodeReaderViewController: UITableViewDelegate,UITableViewDataSource {
    // textArrayの個数分行を追加します
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barcodeInfoList.count
    }
    // テーブルビューの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // 読み込んだバーコードの表示
        cell.textLabel?.text = barcodeInfoList[indexPath.row]["barcode"]
        
        return cell
    }
}

// MARK: - カメラ系
extension BarcodeReaderViewController {
    private func setupBarcodeCapture() {
        // バーコード読み取りのセットアップ
        do {
            captureInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureInput!)
            captureSession.addOutput(Output)
            Output.metadataObjectTypes = Output.availableMetadataObjectTypes
            capturePreviewLayer.frame = self.captureView?.bounds ?? CGRect.zero
            capturePreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            captureView?.layer.addSublayer(capturePreviewLayer)
            captureSession.startRunning()
        } catch let error as NSError {
        }
    }
    /// カメラでバーコードを読み込んだら呼ばれる
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // カメラ一時停止
        self.captureSession.stopRunning()
        let objects = metadataObjects
        
        var detectionString: String? = nil
        let barcodeTypes = [AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13]
        // オブジェクト入手後、また入手できる状態にする
        for metadataObject in objects {
            loop: for type in barcodeTypes {
                guard metadataObject.type == type else { continue }
                guard self.capturePreviewLayer.transformedMetadataObject(for: metadataObject) is AVMetadataMachineReadableCodeObject else { continue }
                if let object = metadataObject as? AVMetadataMachineReadableCodeObject {
                    // 読み込んだオブジェクトを格納する
                    detectionString = object.stringValue
                    break loop
                }
            }
            // 時間の値
            let f = DateFormatter()
            f.timeStyle = .medium
            f.dateStyle = .medium
            f.locale = Locale(identifier: "ja_JP")
            let now = Date()
            // バーコードリストの値
            guard let value = detectionString else { continue }
            
            let dict = ["time": f.string(from: now),
                        "barcode": value]
            
            barcodeInfoList.append(dict)
            
        }
        // バーコード追加　再読み込み
        self.barcodeTableview.reloadData()
        // カメラ再開
        self.captureSession.startRunning()
    }
}

// MARK: - アラートをreturnするfunc
enum bool {
    case success
    case failure
}
extension UIViewController {
    func displayAlert(status: bool) {
        let alert: UIAlertController 
        
        //（enum型の場合defaultはいらない）
        switch status {
        case .success:
            alert = UIAlertController(title: "完了", message: "登録が完了しました", preferredStyle: .alert)
            break
            
        case .failure:
            alert = UIAlertController(title: "登録に失敗しました", message: "もう一度やり直してください", preferredStyle: .alert)
            break
        }
        // アクションの生成
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        // アクション追加
        alert.addAction(okAction)
        
        // アラートの表示
        self.present(alert, animated: true, completion: nil)
    }
}

