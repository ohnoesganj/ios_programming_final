//
//  DBFirebase_SignUp.swift
//  ch12-jangseonho-sharedPlan
//
//  Created by Mac on 2023/06/17.
//

import Foundation
import Firebase

class DBFirebase_SignUp: Database {
    
    func updatePlan(plan: Plan) {
        print("SDF")
    }

    
    func saveChange(plan: Plan, action: DbAction) {
        print("saveChange")
    }

    
    var reference: CollectionReference
    var parentNotification: ((Plan?, DbAction?) -> Void)?
    var existQuery: ListenerRegistration?
    
    required init(parentNotification: ((Plan?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        reference = Firestore.firestore().collection("User")
        
    }
}

extension DBFirebase_SignUp {
    func signUp(id: UITextField, passwd: UITextField) {
        let data: [String: Any] = ["id": id.text, "passwd": passwd.text]
        reference.document(id.text!).setData(data)
    }
}

extension DBFirebase_SignUp {
    func queryPlan(fromDate: Date, toDate: Date) {

        if let existQuery = existQuery {
            existQuery.remove()
        }
        let queryReference = reference.whereField("date", isGreaterThanOrEqualTo: fromDate).whereField("date", isLessThanOrEqualTo: toDate)

        existQuery = queryReference.addSnapshotListener(onChangingData)
        

    }
}

extension DBFirebase_SignUp {
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

