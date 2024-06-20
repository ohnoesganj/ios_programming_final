//
//  TabPlanGroupViewController.swift
//  ch12-jangseonho-sharedPlan
//
//  Created by Mac on 2023/06/18.
//

import Foundation
import UIKit

class TabPlanGroupViewController: UIViewController {
    
    var planGroup: PlanGroup!
    var plan: Plan!
    var selectedDate: Date? = Date()
    @IBOutlet weak var TableView: UITableView!   override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self
    }
}

extension TabPlanGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let planGroup = planGroup{
            return planGroup.getPlans(date:selectedDate).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .value1, reuseIdentifier: "") // TableViewCell을 생성한다
        let cell = tableView.dequeueReusableCell(withIdentifier: "TabPlanTableViewCell")!

        // planGroup는 대략 1개월의 플랜을 가지고 있다.
        let plan = planGroup.getPlans(date:selectedDate)[indexPath.row] // Date를 주지않으면 전체 plan을 가지고 온다

        // 적절히 cell에 데이터를 채움
        //cell.textLabel!.text = plan.date.toStringDateTime()
        //cell.detailTextLabel?.text = plan.content
        (cell.contentView.subviews[0] as! UILabel).text = plan.date.toStringDateTime()
        (cell.contentView.subviews[2] as! UILabel).text = plan.owner
        (cell.contentView.subviews[1] as! UILabel).text = plan.content
        if plan.isChecked == "false" {
            (cell.contentView.subviews[3] as! UILabel).text = "Undone"
            (cell.contentView.subviews[3] as! UILabel).textColor = UIColor.red
        } else {
            (cell.contentView.subviews[3] as! UILabel).text = "Done"
            (cell.contentView.subviews[3] as! UILabel).textColor = UIColor.blue
        }

        return cell
    }
    
}

extension TabPlanGroupViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let plan = self.planGroup.getPlans(date:selectedDate)[indexPath.row]
            let title = "Delete \(plan.content)"
            let message = "Are you sure you want to delete this item?"

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action:UIAlertAction) -> Void in
                
                // 선택된 row의 플랜을 가져온다
                let plan = self.planGroup.getPlans(date:self.selectedDate)[indexPath.row]
                // 단순히 데이터베이스에 지우기만 하면된다. 그러면 꺼꾸로 데이터베이스에서 지워졌음을 알려준다
                self.planGroup.saveChange(plan: plan, action: .Delete)
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            present(alertController, animated: true, completion: nil) //여기서 waiting 하지 않는다
        }

    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // 이것은 데이터베이스에 까지 영향을 미치지 않는다. 그래서 planGroup에서만 위치 변경
        let from = planGroup.getPlans(date:selectedDate)[sourceIndexPath.row]
        let to = planGroup.getPlans(date:selectedDate)[destinationIndexPath.row]
        planGroup.changePlan(from: from, to: to)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }

}
