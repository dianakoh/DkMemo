//
//  ComposeViewController.swift
//  DkMemo
//
//  Created by Gayoung on 2020/02/18.
//  Copyright © 2020 Diana Koh. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func save(_ sender: Any) {
        guard let memo = memoTextView.text,
            memo.count > 0 else {
                alert(message: "Please enter any text")
            return
        }
        
//        let newMemo = Memo(content: memo)
//        Memo.dummyMemoList.append(newMemo)
        
        NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
}
