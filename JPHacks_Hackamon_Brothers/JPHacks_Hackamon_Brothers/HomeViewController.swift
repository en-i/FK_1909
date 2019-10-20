//
//  HomeViewController.swift
//  JPHacks_Hackamon_Brothers
//
//  Created by 藤山裕輝 on 2019/10/19.
//  Copyright © 2019 藤山裕輝. All rights reserved.
//

import UIKit

// 現在のViewを管理するグルーバル変数
var nowView = 0

// 獲得したスタンプを管理する変数
var stamp0 = false
var stamp1 = false
var stamp2 = false
var stamp3 = false

class HomeViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var stampImage0: UIImageView!
    @IBOutlet weak var stampImage1: UIImageView!
    @IBOutlet weak var stampImage2: UIImageView!
    @IBOutlet weak var stampImage3: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(stamp0)
        if userDefaults.bool(forKey: "STAMP0") == true {
            stampImage0.image = UIImage(named: "clear.png")
        }
        if userDefaults.bool(forKey: "STAMP1") == true {
            stampImage1.image = UIImage(named: "clear.png")
        }
        if userDefaults.bool(forKey: "STAMP2") == true {
            stampImage2.image = UIImage(named: "clear.png")
        }
        if userDefaults.bool(forKey: "STAMP3") == true {
            stampImage3.image = UIImage(named: "clear.png")
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toViewController", sender: nowView = 1)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
