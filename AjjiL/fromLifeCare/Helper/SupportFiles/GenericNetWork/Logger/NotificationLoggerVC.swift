//
//  NotificationLoggerVC.swift
//  Taakad
//
//  Created by Mohamed on 1/26/21.
//  Copyright © 2021 AppsSquare.com. All rights reserved.
//

import UIKit

class NotificationLoggerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notificationLoggerTabelV: UITableView!
    
    var logerData = [LocalNotificationsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelViewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
        self.logerData = LocalNotificationsModel.getData()
        notificationLoggerTabelV.reloadData()
    }
    
    func tabelViewSetup() {
        notificationLoggerTabelV.delegate = self
        notificationLoggerTabelV.dataSource = self
        notificationLoggerTabelV.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationLoggerCell") as! NotificationLoggerCell
        cell.fetchData(data: logerData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
