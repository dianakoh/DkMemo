//
//  MemoListTableViewController.swift
//  DkMemo
//
//  Created by Gayoung on 2020/02/18.
//  Copyright © 2020 Diana Koh. All rights reserved.
//

import UIKit

class MemoListTableViewController: UITableViewController {
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataManager.shared.fetchMemo()
        tableView.reloadData()
        //        tableView.reloadData()
        //        print(#function)
        
    }
    
    var token: NSObjectProtocol?
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if let vc = segue.destination as? DetailViewController {
                vc.memo = DataManager.shared.memoList[indexPath.row]
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        token = NotificationCenter.default.addObserver(forName: ComposeViewController.newMemoDidInsert, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            
            self?.tableView.reloadData()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.shared.memoList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let target = DataManager.shared.memoList[indexPath.row]
        cell.textLabel?.text = target.title
        cell.detailTextLabel?.text = target.content
        //formatter.string(for:target.insertDate)

        if target.thumbnail != nil {
            let thumbnail = imageFromAttributedString(from: target.thumbnail?.toAttributedString())
            let scaled = thumbnail?.resized(toWidth: 70.0)
            //cell.imageView?.image = scaled
        
            //  Converted to Swift 5 by Swiftify v5.0.40498 - https://objectivec2swift.com/
            let thumbnailView = UIImageView(frame: CGRect(x: 260, y: 0, width: 70, height: 70))

            thumbnailView.image = scaled
        
            cell.contentView.addSubview(thumbnailView) //add the imageView as a subview
        }
        
//        let dateLabel = UILabel(frame: CGRect(x: 120, y: 38, width: 103, height: 44))
//        dateLabel.text = formatter.string(for: target.content)
//        dateLabel.textColor = UIColor.lightGray
//        dateLabel.textAlignment = .center
//        dateLabel.font = UIFont(name: dateLabel.font.fontName, size: 12)
//
//        cell.contentView.addSubview(dateLabel)
        
        
        
        if #available(iOS 11.0, *) {
            cell.detailTextLabel?.textColor = UIColor(named: "MyLabelColor")
        } else {
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }

        return cell
    }
    
    //  Converted to Swift 5 by Swiftify v5.0.40498 - https://objectivec2swift.com/
    func imageFromAttributedString(from text: NSAttributedString?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(text?.size() ?? CGSize.zero, _: false, _: 0.0)

        // draw in context
        text?.draw(at: CGPoint(x: 0.0, y: 0.0))

        // transfer image
        let image = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()

        return image
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let target = DataManager.shared.memoList[indexPath.row]
            DataManager.shared.deleteMemo(target)
            DataManager.shared.memoList.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
