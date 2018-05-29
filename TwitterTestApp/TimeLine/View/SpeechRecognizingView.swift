//
//  SpeechingView.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/29.
//  Copyright © 2018年 椎名陽介. All rights reserved.
//

import UIKit
import WebKit

@IBDesignable
class SpeechRecognizingView: UIView {

    @IBOutlet weak var webView: WKWebView!
    
    var pushedFinishButton: ((_ sender: Any) -> Void)?
    
    // コードから初期化はここから
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadXib()
    }
    
    // Storyboard/xib から初期化はここから
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadXib()
    }
    
    // xibからカスタムViewを読み込んで準備する
    private func loadXib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
            
            // webviewでローカルhtmlを読み込む
            let htmlPath = Bundle.main.path(forResource: "ai", ofType: "html")
            let request = URL(fileURLWithPath: htmlPath!)
            let req = URLRequest(url: request)
            self.webView.load(req)
            self.webView.scrollView.isScrollEnabled = false
            self.webView.scrollView.bounces = false
        }
    }
    
    
    func show(_ isShown:Bool) {
        
        if isShown {
            self.isHidden = false
            self.alpha = 0.01
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                                self?.alpha = 1.0
                            },
                           completion:nil)
        }
        else {
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                                self?.alpha = 0.01
                            },
                           completion: {  [weak self] result in
                                self?.isHidden = true
                            })
        }
    }

    @IBAction func pushFinishButton(_ sender: Any) {
        self.pushedFinishButton?(sender)
    }
}
