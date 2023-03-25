//
//  ViewController.swift
//  WebSocketDemo
//
//  Created by Jay Prakash Sharma on 25/03/23.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var connectSocket: UIButton!
    @IBOutlet weak var closeSocket: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendMessageTextField: UITextField!
    
    private var webSocket:URLSessionWebSocketTask? = nil
    
    private let socketUrl : URL = {
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_123?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self")
        return url!
    }()
    
    private var recievedMessageData = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        sendMessageTextField.delegate = self
        
        webSocket?.delegate = self
        
        // Connect button acttion
        connectSocket.addAction(UIAction { [self] _ in
            self.establishConnection(socketUrl: socketUrl)
        }, for: .touchDown)
        
        // Close button action
        closeSocket.addAction(UIAction { _ in
            self.close()
        }, for: .touchDown)
        
        // Table view cell registered
        registerCell()
        
    }
    
    
    // Register table view cell
    func registerCell(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tag = 0
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SentMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "SentMessageTableViewCell")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ping()
        if let message = sendMessageTextField.text{
            send(message: message)
            recieve()
        }
        return true
    }
    
    // establish connection
    func establishConnection(socketUrl:URL){
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        webSocket = session.webSocketTask(with: socketUrl)
        webSocket?.resume()
    }
    
    func ping(){
        webSocket?.sendPing{ error in
            if let error = error{
                debugPrint("error \(error)")
            }
        }
    }
    
    // close connection
    func close(){
        webSocket?.cancel(with: .goingAway, reason: "Closed".data(using: .utf8))
    }
    
    // send message
    func send(message:String){
        self.webSocket?.send(.string(message), completionHandler: { error in
            if let error = error{
                debugPrint("error \(error)")
            }
        })
    }
    
    // recieve message
    func recieve(){
        webSocket?.receive(completionHandler: { [unowned self] result in
            switch result{
            case .success(let message):
                switch message{
                case .data(let data):
                    debugPrint(data)
                case .string(let string):
                    self.recievedMessageData.append(string)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    debugPrint(self.recievedMessageData as Any)
                default:
                    break
                }
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    // Web Socket Delegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        debugPrint("Socket connected")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        debugPrint("Socket not connected")
    }
}

// Extenting View Controller to Table View Controller
extension ViewController:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recievedMessageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SentMessageTableViewCell", for: indexPath) as! SentMessageTableViewCell
        cell.sentMessageLabel.text = recievedMessageData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
}
