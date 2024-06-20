//
//  DBFile.swift
//  ch12-leejaemoon-sharedPlan
//
//  Created by Mac on 2023/05/23.
//

import Foundation
import Firebase

class DBFirebase: Database {
  
    var reference: CollectionReference
    var parentNotification: ((Plan?, DbAction?) -> Void)?
    var existQuery: ListenerRegistration?
    
    required init(parentNotification: ((Plan?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        reference = Firestore.firestore().collection("plans")
    }
}



extension DBFirebase {
    func saveChange(plan: Plan, action: DbAction) {
        if action == .Delete {
            reference.document(plan.key).delete()
            return
        }
    
        let data = plan.toDict()
        
        let storeDate: [String : Any] = ["date": plan.date, "data": data]
        reference.document(plan.key).setData(storeDate)
    }
}

extension DBFirebase {
    func queryPlan(fromDate: Date, toDate: Date) {
        
        if let existQuery = existQuery {
            existQuery.remove()
        }
        let queryReference = reference.whereField("date", isGreaterThanOrEqualTo: fromDate).whereField("date", isLessThanOrEqualTo: toDate)
        
        existQuery = queryReference.addSnapshotListener(onChangingData)
        
    }
}

extension DBFirebase {
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnapshot = querySnapshot else {return}
        if(querySnapshot.documentChanges.count <= 0) {
            if let parentNotification = parentNotification { parentNotification(nil, nil) }
        }
        
        for documentChange in querySnapshot.documentChanges {
            let data = documentChange.document.data()
            
            let fieldName = data["data"]
            
            let plan = Plan.toPlan(from: fieldName as! [String : Any?])
            
            var action: DbAction?
            switch (documentChange.type) {
                case .added: action = .Add
                case .modified: action = .Modify
                case .removed: action = .Delete
            }
            if let parentNotification = parentNotification {parentNotification(plan, action)}
        }
    }
}


