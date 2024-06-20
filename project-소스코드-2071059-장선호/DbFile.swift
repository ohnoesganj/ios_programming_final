//
//  DbFile.swift
//  ch12-jangseonho-sharedPlan
//
//  Created by Mac on 2023/05/23.
//

import Foundation
import Firebase

class DbFile: Database {
    
    var dbDir: URL
    var parentNotification: ((Plan?, DbAction?) -> Void)?
    
    required init(parentNotification: ((Plan?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        
        dbDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(dbDir.path)
    }
    
    func updatePlan(plan: Plan) {
        print("!")
    }
}

extension DbFile {
    func saveChange(plan: Plan, action: DbAction) {
        let fileName = plan.date.toStringDateTime() + ".archive"
        if action == .Delete {
            if let _ = try? FileManager.default.removeItem(at: dbDir.appendingPathComponent(fileName)) {
                if let parentNotification = parentNotification {
                    parentNotification(plan, action)
                }
            }
            return
        }
        let archivedPlan = try? NSKeyedArchiver.archivedData(withRootObject: plan, requiringSecureCoding: false)
        
        if let _ = try? archivedPlan?.write(to: dbDir.appendingPathComponent(fileName)) {
            if let parentNotification = parentNotification {
                parentNotification(plan, action)
            }
        }
    }
}

extension DbFile {
    func queryPlan(fromDate: Date, toDate: Date) {
        guard var fileList = try? FileManager.default.contentsOfDirectory(atPath: dbDir.path) else {return}
        fileList.sort(by: {$0<$1})
        
        let fromStr = fromDate.toStringDateTime()
        let toStr = toDate.toStringDateTime()
        
        for i in 0..<fileList.count {
            if fileList[i] < fromStr { continue }
            if fileList[i] > toStr { break }
            guard let archived = try? Data(contentsOf: dbDir.appendingPathComponent(fileList[i])) else {
                continue
            }
            guard let plan = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archived) as? Plan else {
                continue
            }
            
            if let parentNotification = parentNotification {
                parentNotification(plan, .Add)
            }
        }
    }
}
