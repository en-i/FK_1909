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

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
