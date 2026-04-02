//
//  NotificationLoggerCell.swift
//  Taakad
//
//  Created by Mohamed on 1/26/21.
//  Copyright © 2021 AppsSquare.com. All rights reserved.
//

import UIKit

class NotificationLoggerCell: UITableViewCell {

    @IBOutlet weak var bGView: UIView!
    @IBOutlet weak var urlText: UILabel!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var methodText: UILabel!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var parameterText: UILabel!
    @IBOutlet weak var responseText: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        bGView.layer.cornerRadius = 12
        bGView.layer.backgroundColor = #colorLiteral(red: 0.9832447652, green: 0.9832447652, blue: 0.9832447652, alpha: 1)
        bGView.layer.borderWidth = 1.5
    }
    
    func fetchData(data: LocalNotificationsModel){
        data.method != "POST" ? (parameterText.isHidden = true) : (parameterText.isHidden = false)
        data.response == "" ? (responseText.isHidden = true): (responseText.isHidden = false)
        if data.statusCode == 200 {
            bGView.layer.borderColor = #colorLiteral(red: 0.2164075077, green: 0.7454271913, blue: 0.4750220776, alpha: 1)
        }else if data.statusCode == 400 {
            bGView.layer.borderColor = #colorLiteral(red: 1, green: 0.4411764706, blue: 0.4411764706, alpha: 1)
        }else{
            bGView.layer.borderColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        }
        urlText.text = "End point: \(data.endPoint)"
        statusText.text = "Status: \(data.statusCode)"
        methodText.text = "Method: \(data.method)"
        headerText.text = "Header:  \(data.header)"
        parameterText.text = "params: \(data.params)"
        responseText.text = "response: \(data.response)"
    }
}
