//
//  DetailViewController.swift
//  JPHacks_Hackamon_Brothers
//
//  Created by 藤山裕輝 on 2019/10/19.
//  Copyright © 2019 藤山裕輝. All rights reserved.
//

import UIKit

// 何を認識して画面遷移したのかを管理する変数
var currentJudge: Int!

class DetailViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    // 説明画像をひ管理する配列
    var dangerImage = ["fire_danger.png", "desk_danger.png"]
    // 説明文を管理する配列
    var dangerText = ["これはガスコンロ！\n火がつくととってもあつくなるから気をつけよう！", "つくえの角はとてもとがっていてあぶないよ！\n気をつけようね！"]
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(named: dangerImage[currentJudge])
        label.text = dangerText[currentJudge]
        // Do any additional setup after loading the view.
    }
    
    @IBAction func screenTapped(_ sender: Any) {
        switch currentJudge {
        case 0:
            stamp0 = true
            userDefaults.set(stamp0, forKey: "STAMP0")
        case 1:
            stamp1 = true
            userDefaults.set(stamp1, forKey: "STAMP1")
        case 2:
            stamp2 = true
            userDefaults.set(stamp2, forKey: "STAMP2")
        case 3:
            stamp3 = true
            userDefaults.set(stamp3, forKey: "STAMP3")
        default:
            break
        }
        performSegue(withIdentifier: "toHomeViewController", sender: nil)
    }
    
    
}
