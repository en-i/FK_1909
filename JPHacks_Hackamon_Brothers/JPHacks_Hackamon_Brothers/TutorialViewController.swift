//
//  TutorialViewController.swift
//  JPHacks_Hackamon_Brothers
//
//  Created by 寺田縁 on 2019/10/19.
//  Copyright © 2019 藤山裕輝. All rights reserved.
//

import UIKit


class TutorialViewController: UIViewController {
    //pageLabelのための変数
   var pageNumber = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //UIScrollViewのサイズを指定（widthでUIImageViewの数だけ掛ける）
        tutorialScroll.contentSize = CGSize(width: tutorialScroll.frame.size.width * 4, height: tutorialScroll.frame.size.height)
        tutorialScroll.delegate = self
        //選択されていないページのpage controlの色を指定
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        //選択されているページのpage controlの色を指定
        pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    @IBOutlet weak var tutorialScroll: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    @IBAction func tapAction(_ sender: Any) {
        performSegue(withIdentifier: "finTutorial", sender: nil)
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
//スワイプでpage controlも一緒に移動する
extension TutorialViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(tutorialScroll.contentOffset.x / tutorialScroll.frame.size.width)
        //現在のページ数を代入
        pageNumber = pageControl.currentPage
        }
}
