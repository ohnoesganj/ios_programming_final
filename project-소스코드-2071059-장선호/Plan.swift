//
//  Plan.swift
//  ch09-leejaemoon-tableView
//
//  Created by jmlee on 2023/04/26.
//

import Foundation
import Firebase

class Plan: NSObject, NSCoding {
    enum Kind: Int {
        case Todo = 0, Meeting, Study, Etc
        func toString() -> String{
            switch self {
                case .Todo: return "할일";     case .Meeting: return "약속"
                case .Study: return "공부";    case .Etc: return "기타"
            }
        }
        static var count: Int { return Kind.Etc.rawValue + 1}
    }
    var key: String;        var date: Date
    var owner: String?;     var kind: Kind
    var content: String;    var isChecked: String?
    
    init(date: Date, owner: String?, kind: Kind, content: String){
        self.key = UUID().uuidString   // 거의 unique한 id를 만들어 낸다.
        self.date = Date(timeInterval: 0, since: date)
        self.owner = Owner.getOwner()
        self.kind = kind; self.content = content
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: "key")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(owner, forKey: "owner")
        aCoder.encode(kind.rawValue, forKey: "kind")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(isChecked, forKey: "isChecked")
    }
    
    required init(coder aDecoder: NSCoder) {
        key = aDecoder.decodeObject(forKey: "key") as! String? ?? ""
        date = aDecoder.decodeObject(forKey: "date") as! Date
        owner = aDecoder.decodeObject(forKey: "owner") as? String
        let rawValue = aDecoder.decodeInteger(forKey: "kind")
        kind = Kind(rawValue: rawValue)!
        content = aDecoder.decodeObject(forKey: "content") as! String? ?? ""
        isChecked = aDecoder.decodeObject(forKey: "isChecked") as! String? ?? ""
        super.init()
    }
}

extension Plan{
    convenience init(date: Date? = nil, withData: Bool = false){
        if withData == true{
            var index = Int(arc4random_uniform(UInt32(Kind.count)))
            let kind = Kind(rawValue: index)! // 이것의 타입은 옵셔널이다. Option+click해보라

            let contents = ["토익 공부", "자격증 공부", "아르바이트", "데이트", "자기 개발"]
            index = Int(arc4random_uniform(UInt32(contents.count)))
            let content = contents[index]
            
            self.init(date: date ?? Date(), owner: "me", kind: kind, content: content)
        }else{
            self.init(date: date ?? Date(), owner: "me", kind: .Etc, content: "")

        }
    }
}

extension Plan{        // Plan.swift
    func clone() -> Plan {
        let clonee = Plan()

        clonee.key = self.key    // key는 String이고 String은 struct이다. 따라서 복제가 된다
        clonee.date = Date(timeInterval: 0, since: self.date) // Date는 struct가 아니라 class이기 때문
        clonee.owner = self.owner
        clonee.kind = self.kind    // enum도 struct처럼 복제가 된다
        clonee.content = self.content
        clonee.isChecked = self.isChecked
        return clonee
    }
}

extension Plan {
    func toDict() -> [String: Any?] {
        var dict: [String: Any?] = [:]
        
        dict["key"] = key
        dict["date"] = Timestamp(date: date)
        dict["owner"] = owner
        dict["kind"] = kind.rawValue
        dict["content"] = content
        dict["isChecked"] = isChecked
        
        return dict
    }
    
    static func toPlan(from dict: [String: Any?]) -> Plan {
        let plan = Plan()
        
        plan.key = dict["key"] as! String
        plan.date = Date()
        if let timestamp = dict["date"] as? Timestamp {
            plan.date = timestamp.dateValue()
        }
        plan.owner = dict["owner"] as? String
        let rawValue = dict["kind"] as! Int
        plan.kind = Plan.Kind(rawValue: rawValue)!
        plan.content = dict["content"] as! String
        plan.isChecked = dict["isChecked"] as? String

        return plan
    }
}
