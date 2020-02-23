//
//  ComposeViewController.swift
//  DkMemo
//
//  Created by Gayoung on 2020/02/18.
//  Copyright © 2020 Diana Koh. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    
    var editTarget: Memo?
    var originalMemoTitle: String?
    var originalMemoContent: String?
    var originalMemoNSData: NSData?
    
    var thumbNailNSData: NSData?
    
    let picker = UIImagePickerController()

    @IBAction func addImage(_ sender: Any) {
        let alert = UIAlertController(title: "이미지 가져오기", message: "", preferredStyle: .actionSheet)
        
        let library = UIAlertAction(title: "사진앨범", style: .default) { (action) in
            self.picker.delegate = self
            self.openLibrary()
        }
        
        let camera = UIAlertAction(title: "카메라", style: .default) { (action) in
            self.picker.delegate = self
            self.openCamera()
        }
        
        let externalLink = UIAlertAction(title: "url", style: .default) { (action) in
            let alert2 = UIAlertController(title: "url 입력", message: "", preferredStyle: .alert)
            
            alert2.addTextField { (urlTextField) in
                urlTextField.placeholder = "url 을 입력해주세요"
            }
            let ok = UIAlertAction(title: "확인", style: .default) { (ok) in
                self.addImageFromURL((alert2.textFields?[0].text)!)
                
            }
            let cancel2 = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert2.addAction(cancel2)
            alert2.addAction(ok)
            self.present(alert2, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(externalLink)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func addImageFromURL(_ urlString: String) {
        let url = URL(string: urlString)
        do {
            if let url = url {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                let scaledImage = image?.resized(toWidth: self.imageTextView.frame.size.width)
                let attachment = NSTextAttachment()
                attachment.image = scaledImage
                let newImageWidth = (imageTextView.bounds.size.width - 20)
                let scale = newImageWidth/(image?.size.width)!
                let newImageHeight = (image?.size.height)! * scale
                
                attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
                
                let attString = NSAttributedString(attachment: attachment)
                //imageTextView.textStorage.insert(attString, at: imageTextView.selectedRange.location)
                //picker.dismiss(animated: true, completion: nil)
                imageTextView.textStorage.append(attString)
            }
        } catch let error {
            debugPrint("Error ::\(error)")
            let alert = UIAlertController(title: "alert", message: "이미지를 가져올 수 없습니다.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
            let cancel2 = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(cancel2)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }

        
    }
    
    func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
    
    func openCamera() {
        picker.sourceType = .camera
        present(picker, animated: false, completion: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var imageTextView: UITextView!
    
    @IBAction func save(_ sender: Any) {
        var thumbNailCheck = false
        guard let memo = memoTextView.text,
            memo.count > 0 else {
                alert(message: "텍스트를 입력해주세요")
            return
        }
        
        if let target = editTarget {
            target.title = titleTextView.text
            target.content = memo
            let memoNSData = imageTextView.attributedText.toNSData()!
            target.nsData = memoNSData
            
            let memoAtt = memoNSData.toAttributedString()
            
            memoAtt?.enumerateAttribute(.attachment, in: NSRange(location: 0, length: memoAtt!.length)) { value, range, stop in
                if let att = value as? NSTextAttachment {
                    let attstr = NSAttributedString(attachment: att)
                    let attstrtodata = attstr.toNSData()
                    
                    if thumbNailCheck == false {
                        thumbNailNSData = attstrtodata
                        thumbNailCheck = true
                    }
                    
                    
                }
            }
            target.thumbnail = thumbNailNSData
            
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name:ComposeViewController.memoDidChange, object:nil)
        } else {
            print("메모 저장")
            let memoTitle = titleTextView.text!
            let memoNSData = imageTextView.attributedText.toNSData()!
            
            let memoAtt = memoNSData.toAttributedString()
            
            memoAtt?.enumerateAttribute(.attachment, in: NSRange(location: 0, length: memoAtt!.length)) { value, range, stop in
                if let att = value as? NSTextAttachment {
                    let attstr = NSAttributedString(attachment: att)
                    let attstrtodata = attstr.toNSData()
                    
                    if thumbNailCheck == false {
                        thumbNailNSData = attstrtodata
                        thumbNailCheck = true
                    }
                    
                    
                }
            }
            
            DataManager.shared.addNewMemo(memoTitle, memo, memoNSData, thumbNailNSData!)
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        }
        
 
        dismiss(animated: true, completion: nil)
    }
    
   // var willShowToken: NSObjectProtocol?
   // var willHideToken: NSObjectProtocol?
    
    
    
    deinit {
       /* if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        
        if let token = willHideToken {
            NotificationCenter.default.removeObserver(token)
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            
            titleTextView.text = memo.title
            titleTextView.textColor = UIColor.black
            memoTextView.text = memo.content
            memoTextView.textColor = UIColor.black
            imageTextView.textStorage.insert((memo.nsData?.toAttributedString())!, at: 0)
            
            originalMemoTitle = memo.title
            originalMemoContent = memo.content
            originalMemoNSData = memo.nsData
        } else {
            navigationItem.title = "새 메모"
            //memoTextView.text = ""
//            titleTextView.text = "Title"
//            titleTextView.textColor = UIColor.lightGray
//            memoTextView.text = "Content"
//            memoTextView.textColor = UIColor.lightGray
        }
        
        titleTextView.delegate = self
        memoTextView.delegate = self
        imageTextView.delegate = self
        
        /*willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: {[weak self] (noti) in
            guard let strongSelf = self else { return }
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                NSValue {
                let height = frame.cgRectValue.height
                var inset = strongSelf.memoTextView.contentInset
                inset.bottom = height
                strongSelf.memoTextView.contentInset = inset
                
                inset = strongSelf.memoTextView.scrollIndicatorInsets
                inset.bottom = height
                strongSelf.memoTextView.scrollIndicatorInsets = inset
                /*let keybaordRectangle = frame.cgRectValue
                let keyboardHeight = keybaordRectangle.height
                self?.imageTextView.frame.origin.y -= keyboardHeight*/
                
            }
        })
        
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: OperationQueue.main, using: {[weak self] (noti) in
            guard let strongSelf = self else { return }
            
            var inset = strongSelf.memoTextView.contentInset
            inset.bottom = 0
            strongSelf.memoTextView.contentInset = inset
            
            inset = strongSelf.memoTextView.scrollIndicatorInsets
            inset.bottom = 0
            strongSelf.memoTextView.scrollIndicatorInsets = inset
            /*if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                NSValue {
                /*let keybaordRectangle = frame.cgRectValue
                let keyboardHeight = keybaordRectangle.height
                self?.imageTextView.frame.origin.y += keyboardHeight*/
            }*/
        })*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //titleTextView.becomeFirstResponder()
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //titleTextView.resignFirstResponder()
        navigationController?.presentationController?.delegate = nil
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

extension ComposeViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if let original = originalMemoContent, let edited = textView.text {
            if #available(iOS 13.0, *) {
                isModalInPresentation = original != edited
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if titleTextView.text == "제목을 입력해주세요" && memoTextView.text != "" {
            titleTextView.text = ""
            titleTextView.textColor = UIColor.black
        } else if titleTextView.text == "" {
            titleTextView.text = "제목을 입력해주세요"
            titleTextView.textColor = UIColor.lightGray
        }
        
        if memoTextView.text == "내용을 입력해주세요" && titleTextView.text != "" {
            memoTextView.text = ""
            memoTextView.textColor = UIColor.black
        } else if memoTextView.text == "" {
            memoTextView.text = "내용을 입력해주세요"
            memoTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if titleTextView.text == "" {
            titleTextView.text = "제목을 입력해주세요"
            titleTextView.textColor = UIColor.lightGray
        }
        if memoTextView.text == "" {
            memoTextView.text = "내용을 입력해주세요"
            memoTextView.textColor = UIColor.lightGray
        }
    }
}

extension ComposeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] (action) in self?.save(action)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] (action) in self?.close(action)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue:"memoDidChange")
}

extension ComposeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let scaledImage = image.resized(toWidth: self.imageTextView.frame.size.width - 20)
            let attachment = NSTextAttachment()
            attachment.image = scaledImage
            let newImageWidth = (imageTextView.bounds.size.width - 20)
            let scale = newImageWidth/image.size.width
            let newImageHeight = image.size.height * scale
            
            attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
            
            let attString = NSAttributedString(attachment: attachment)
            //imageTextView.textStorage.insert(attString, at: imageTextView.selectedRange.location)
            //picker.dismiss(animated: true, completion: nil)
            imageTextView.textStorage.append(attString)
            
        }
        dismiss(animated: true, completion: nil)
        titleTextView.delegate = self
        memoTextView.delegate = self
        //imageTextView.selectedTextRange = imageTextView.textRange(from: imageTextView.endOfDocument, to: imageTextView.endOfDocument)
    }
}

extension NSData {
    func toAttributedString() -> NSAttributedString? {
        let data = Data(referencing: self)
        let options : [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtfd,
            .characterEncoding: String.Encoding.utf8
        ]
        
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }
}

extension NSAttributedString {
    func toNSData() -> NSData? {
        let options : [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtfd,
            .characterEncoding: String.Encoding.utf8
        ]
        
        let range = NSRange(location: 0, length: length)
        guard let data = try? data(from: range, documentAttributes: options) else {
            return nil
        }
        return NSData(data: data)
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let height = CGFloat(ceil(width / size.width * size.height))
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
