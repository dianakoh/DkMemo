//
//  DataManager.swift
//  DkMemo
//
//  Created by Gayoung on 2020/02/18.
//  Copyright © 2020 Diana Koh. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    private init() {
        
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var memoList = [Memo]()
    
    func fetchMemo() {
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        do {
            memoList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
            
    }
    
    func addNewMemo(_ memo: String) {
        let newMemo = Memo(context: mainContext)
        newMemo.content = memo
        newMemo.insertDate = Date()
        
        memoList.insert(newMemo, at: 0)
        
        saveContext()
    }
    
    func addNewMemo(_ memo: String, _ data: NSData) {
        let newMemo = Memo(context: mainContext)
        newMemo.content = memo
        newMemo.insertDate = Date()
        newMemo.nsData = data
        
        memoList.insert(newMemo, at: 0)
        
        saveContext()
    }
    
    func addNewMemo(_ title: String, _ memo: String, _ data: NSData) {
        let newMemo = Memo(context: mainContext)
        newMemo.title = title
        newMemo.content = memo
        newMemo.insertDate = Date()
        newMemo.nsData = data
        
        memoList.insert(newMemo, at: 0)
        
        saveContext()
    }
    
    func addNewMemo(_ title: String, _ memo: String, _ data: NSData, _ thumbnail: NSData) {
        let newMemo = Memo(context: mainContext)
        newMemo.title = title
        newMemo.content = memo
        newMemo.insertDate = Date()
        newMemo.nsData = data
        newMemo.thumbnail = thumbnail
        
        memoList.insert(newMemo, at: 0)
        
        saveContext()
    }
    
    
    func deleteMemo(_ memo: Memo?) {
        if let memo = memo {
            mainContext.delete(memo)
            saveContext()
        }
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "DkMemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
