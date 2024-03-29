//
//  ModifiedScheduleViewController.swift
//  GovsConnect
//
//  Created by Jeffrey Wang on 2019/1/22.
//  Copyright © 2019 Eagersoft. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftyGif

class ModifiedScheduleViewController: UIViewController {
    @IBOutlet var notifyMeButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    var alertRequest: UNNotificationRequest? = nil
    var timeStrokeView = UIView()
    var timeLabel = UILabel()
    var lastCurrentMinute: Int = -1
    var startingYBound: CGFloat = 0
    var events = Array<UIView>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notifyMeButton.layer.cornerRadius = 5
        self.notifyMeButton.layer.borderWidth = 1
        self.notifyMeButton.layer.borderColor = APP_THEME_COLOR.cgColor
        self.notifyMeButton.clipsToBounds = true
        self.notifyMeButton.backgroundColor = UIColor.white
        self.notifyMeButton.setTitleColor(APP_THEME_COLOR, for: .normal)
        switch PHONE_TYPE{
        case .ipodtouch:
            self.notifyMeButton.titleLabel!.font = UIFont.systemFont(ofSize: 11)
            self.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        case .iphone8, .iphone11pro, .iphone11:
            self.notifyMeButton.titleLabel!.font = UIFont.systemFont(ofSize: 13)
            self.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        default:
            self.notifyMeButton.titleLabel!.font = UIFont.systemFont(ofSize: 15)
            self.titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        }
        self.navigationItem.title = "Modified Schedule"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "system_reload"), style: .plain, target: self, action: #selector(self.didClickOnReload))
        self.tableView.register(UINib(nibName: "NewTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NEW_TABLE_VIEW_CELL")
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimeStroke), userInfo: nil, repeats: true)
        self.initTimeStroke()
        self.loadScheduleToView(animated: true)
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.text = AppDataManager.shared.discoverModifiedScheduleTitle
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventFromView(animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.events.count == 0{
            self.loadScheduleToView(animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print(self.tableView.contentSize.height)
        let timeStrokePoint = CGPoint(x: self.timeStrokeView.left, y: min(self.tableView.contentSize.height - 20, self.timeStrokeView.top + screenHeight / 3))
        let indexPath = self.tableView.indexPathForRow(at: timeStrokePoint)
        guard indexPath != nil else{
            return
        }
        self.tableView.scrollToRow(at: indexPath!, at: .middle, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            let predicate = NSPredicate(format: "key == %@", "did see widget")
            let res = AppPersistenceManager.shared.filterObject(of: .setting, with: predicate) as! Array<Setting>
            if res.count == 0{
                //did see widget not created yet
                self.displayDidSeeWidget()
                AppPersistenceManager.shared.saveObject(to: .setting, with: ["did see widget", "true"])
            }else if res[0].value! == "false"{
                //did see widget created, but didn't see
                self.displayDidSeeWidget()
                AppPersistenceManager.shared.updateObject(of: .setting, with: predicate, newVal: "true", forKey: "value")
            }
        }
    }
    
    func displayDidSeeWidget(){
        let askWidgetAlertController = UIAlertController(title: "Do you know Govs Connect also has a widget?", message: "Without unlocking your phone, the widget allows you check the modified schedule even faster.", preferredStyle: .alert)
        let gif = UIImage.init(gifName: "govs-connect-widget-tutorial.gif")
        let gifView = UIImageView.init(gifImage: gif, loopCount: -1)
        gifView.frame = CGRect(x: 48, y: 135, width: 150, height: 270)
        askWidgetAlertController.view.addSubview(gifView)
        let height = NSLayoutConstraint(item: askWidgetAlertController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500)
        let width = NSLayoutConstraint(item: askWidgetAlertController.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        askWidgetAlertController.view.addConstraint(height)
        askWidgetAlertController.view.addConstraint(width)
        askWidgetAlertController.addAction(UIAlertAction(title: "Tell me how to enable it", style: .default, handler: { (alert) in
            //completion handler
            let url = URL(string: "https://support.apple.com/en-us/HT207122")!
            let vc = UIViewController()
            vc.view.frame = self.view.bounds
            let webv = UIWebView()
            vc.view.addSubview(webv)
            webv.frame = vc.view.bounds
            self.navigationController!.pushViewController(vc, animated: true)
            vc.navigationItem.title = "How to enable widget"
            webv.loadRequest(URLRequest(url: url))
        }))
        askWidgetAlertController.addAction(UIAlertAction(title: "Okay, Thank you", style: .cancel, handler: { (alert) in
            //completion handler
        }))
        self.navigationController!.present(askWidgetAlertController, animated: true, completion: {
            //completion handler
        })
    }
    
    @objc func didClickOnReload(){
        guard AppIOManager.shared.connectionStatus != .none else{
            makeMessageViaAlert(title: "Cannot reload on offline mode", message: "Your device is not connecting to the Internet.")
            return
        }
        AppIOManager.shared.loadModifiedScheduleData({ (isSucceed) in
            self.refreashEvents(animated: true)
        }) { (errStr) in
            makeMessageViaAlert(title: "Error when reloading modified schedule data", message: errStr)
        }
    }
    
    func getCurrentTime() -> (hour: Int, minute: Int){
        let currentTime = Date(timeIntervalSinceNow: 0)
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: currentTime)
        return (comp.hour!, comp.minute!)
    }
    
    func getHeightUnit(hour: Int, minute: Int) -> CGFloat{
        var hour = hour
        if hour == 0{
            hour = 24
        }
        var heightUnit: CGFloat = CGFloat(hour) - 1.0 + 0.5 + CGFloat(minute) / 60.0
        if hour == 24 && minute >= 30{
            heightUnit = (CGFloat(minute) - 30.0) / 60.0
        }
        return heightUnit
    }
    
    func initTimeStroke(){
        let currentTime = getCurrentTime()
        self.lastCurrentMinute = currentTime.minute
        self.startingYBound = self.tableView.bounds.origin.y
        let heightUnit = self.getHeightUnit(hour: currentTime.hour, minute: currentTime.minute)
        let yStart = self.startingYBound + heightUnit * 72.5
        self.timeStrokeView.frame = CGRect(x: 57, y: yStart, width: UIScreen.main.bounds.size.width - 57, height: 15)
        let redStrokeView = UIView(frame: CGRect(x: 0, y: 0, width: self.timeStrokeView.frame.size.width, height: 1))
        redStrokeView.backgroundColor = UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1)
        self.timeLabel = UILabel(frame: CGRect(x: self.timeStrokeView.frame.size.width - 83, y: 3, width: 80, height: 11))
        self.timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        self.timeLabel.textColor = UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1)
        self.timeLabel.textAlignment = .right
        if let s = AppDataManager.shared.deviceSetting["time_display_preference"], s == "us"{
            var hour = currentTime.hour
            var modifier = "AM"
            if hour > 12{
                hour -= 12
                modifier = "PM"
            }
            self.timeLabel.text = "\(hour):\(currentTime.minute < 10 ? "0\(currentTime.minute)" : "\(currentTime.minute)") \(modifier)"
        }else{
            self.timeLabel.text = "\(currentTime.hour):\(currentTime.minute < 10 ? "0\(currentTime.minute)" : "\(currentTime.minute)")"
        }
        self.timeStrokeView.addSubview(redStrokeView)
        self.timeStrokeView.addSubview(self.timeLabel)
        self.tableView.addSubview(self.timeStrokeView)
    }
    
    @objc func updateTimeStroke(){
        let currentTime = getCurrentTime()
        guard self.lastCurrentMinute != currentTime.minute else{
            return
        }
        self.lastCurrentMinute = currentTime.minute
        if let s = AppDataManager.shared.deviceSetting["time_display_preference"], s == "us"{
            var hour = currentTime.hour
            var modifier = "AM"
            if hour > 12{
                hour -= 12
                modifier = "PM"
            }
            self.timeLabel.text = "\(hour):\(currentTime.minute < 10 ? "0\(currentTime.minute)" : "\(currentTime.minute)") \(modifier)"
        }else{
            self.timeLabel.text = "\(currentTime.hour):\(currentTime.minute < 10 ? "0\(currentTime.minute)" : "\(currentTime.minute)")"
        }
        let heightUnit = self.getHeightUnit(hour: currentTime.hour, minute: currentTime.minute)
        let yStart = self.startingYBound + heightUnit * 72.5
        UIView.animate(withDuration: 0.3){
            self.timeStrokeView.frame = CGRect(x: 57, y: yStart, width: UIScreen.main.bounds.size.width - 57, height: 15)
        }
    }
    
    func loadScheduleToView(animated: Bool){
        let currentDayData = AppDataManager.shared.discoverModifiedScheduleData
        for i in (0..<currentDayData.count){
            let calender = Calendar.current
            let startTime = calender.dateComponents([.hour, .minute], from: currentDayData[i].startTime)
            let endTime = calender.dateComponents([.hour, .minute], from: currentDayData[i].endTime)
            let startY = self.startingYBound + self.getHeightUnit(hour: startTime.hour!, minute: startTime.minute!) * 72.5
            let endY = self.startingYBound + self.getHeightUnit(hour: endTime.hour!, minute: endTime.minute!) * 72.5
            assert(endY > startY)
            let v = UIView(frame: CGRect(x: 57, y: startY, width: UIScreen.main.bounds.size.width - 107, height: endY - startY))
            v.backgroundColor = UIColor.init(red: 0.000, green: 0.624, blue: 0.949, alpha: 0.2)
            v.layer.cornerRadius = 5
            v.layer.borderWidth = 1
            v.layer.borderColor =  UIColor.init(red: 0.216, green: 0.282, blue: 0.675, alpha: 0.5).cgColor
            let startTimeLabel = UILabel(frame: CGRect(x: 5, y: 5, width:v.frame.size.width - 10, height: 13))
            startTimeLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            
            var timeString = ""
            
            if let s = AppDataManager.shared.deviceSetting["time_display_preference"], s == "us"{
                var hour = startTime.hour!
                var modifier = "AM"
                if hour > 12{
                    hour -= 12
                    modifier = "PM"
                }
                timeString += "@ \(hour):\(startTime.minute! < 10 ? "0\(startTime.minute!)" : "\(startTime.minute!)") \(modifier)"
                timeString += " - "
                var hour2 = endTime.hour!
                var modifier2 = "AM"
                if hour2 > 12{
                    hour2 -= 12
                    modifier2 = "PM"
                }
                timeString += "\(hour2):\(endTime.minute! < 10 ? "0\(endTime.minute!)" : "\(endTime.minute!)") \(modifier2)"
            }else{
                timeString += "@ \(startTime.hour!):\(startTime.minute! < 10 ? "0\(startTime.minute!)" : "\(startTime.minute!)")"
                timeString += " - "
                timeString += "\(endTime.hour!):\(endTime.minute! < 10 ? "0\(endTime.minute!)" : "\(endTime.minute!)")"
            }
            
            startTimeLabel.text = timeString
            startTimeLabel.textColor = UIColor.init(red: 0.216, green: 0.282, blue: 0.675, alpha: 1.0)
            let titleLabel = UILabel(frame: CGRect(x: 5, y: 17, width: v.frame.size.width - 10, height: 15))
            titleLabel.contentMode = .top
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.text = "\(currentDayData[i].title)"
            titleLabel.clipsToBounds = true
            titleLabel.numberOfLines = 0
            titleLabel.sizeToFit()
            titleLabel.textColor = UIColor.init(red: 0.216, green: 0.282, blue: 0.675, alpha: 1.0)
            v.addSubview(startTimeLabel)
            v.addSubview(titleLabel)
            v.alpha = animated ? 0 : 1
            self.events.append(v)
            self.tableView.addSubview(v)
        }
        if animated{
            UIView.animate(withDuration: 0.25){
                for event in self.events{
                    event.alpha = 1
                }
            }
        }
    }
    
    func removeEventFromView(animated: Bool){
        if animated{
            UIView.animate(withDuration: 0.25, animations: {
                for event in self.events{
                    event.alpha = 0
                }
            }) { (response) in
                for event in self.events{
                    event.removeFromSuperview()
                }
            }
        }else{
            for event in self.events{
                event.alpha = 0
                event.removeFromSuperview()
            }
        }
        self.events = []
    }
    
    func refreashEvents(animated: Bool){
        self.removeEventFromView(animated: animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            self.loadScheduleToView(animated: animated)
        }
    }
}

extension ModifiedScheduleViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NEW_TABLE_VIEW_CELL", for: indexPath) as! NewTableViewCell
        if indexPath.item >= 12{
            cell.ampmLabel.text = "PM"
            cell.hourLabel.text = "\(indexPath.item - 11)"
        }else{
            cell.ampmLabel.text = "AM"
            cell.hourLabel.text = "\(indexPath.item + 1)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.5
    }
    
    private func setupNotification(){
        for event in AppDataManager.shared.discoverModifiedScheduleData{
             let content = UNMutableNotificationContent()
            content.body = ""
            content.badge = 1
            let fireDate = Date.init(timeInterval: -60 * 5, since: event.startTime)
            content.title = "\(event.title) begins in 5 minutes."
            let dateCompenents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompenents, repeats: false)
            self.alertRequest = UNNotificationRequest(identifier: "MODIFIED_SCHEDULE_\(event.title)_ALERT_ID", content: content, trigger: trigger)
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["MODIFIED_SCHEDULE_\(event.title)_ALERT_ID"])
            UNUserNotificationCenter.current().add(self.alertRequest!, withCompletionHandler: nil)
        }
        makeMessageViaAlert(title: "success", message: "I will notify you 5 minutes early before any event starts")
    }
    
    @IBAction func didClickOnNotifyMeButton(_ sender: UIButton){
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else {
                makeMessageViaAlert(title: "Setup notification failed", message: "Please enable the app notification")
                return
            }
            self.setupNotification()
        }
    }
}
