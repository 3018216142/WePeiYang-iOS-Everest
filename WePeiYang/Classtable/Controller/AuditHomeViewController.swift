//
//  AuditHomeViewController.swift
//  WePeiYang
//
//  Created by JasonEWNL on 2018/11/14.
//  Copyright © 2018年 twtstudio. All rights reserved.
//

import UIKit
import PopupDialog

class AuditHomeViewController: UIViewController {
    private var tableView: UITableView!
    private var popularList: [PopularClassModel] = []
    private var personalCourseList: [AuditDetailCourseItem] = []
    private var dayTitles = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    private var isFold: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.register(AuditDetailCourseTableViewCell.self, forCellReuseIdentifier: "AuditDetailCourseTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        let group = DispatchGroup()
        group.enter()
        ClasstableDataManager.getPopularList(success: { model in
            self.popularList = model.data
            
            group.leave()
        }, failure: { errStr in
            group.leave()
        })
        group.enter()
        ClasstableDataManager.getPersonalAuditList(success: { model in 
            self.personalCourseList = []
            model.data.forEach { list in
                list.infos.forEach { item in
                    self.personalCourseList.append(item)
                }

            }
            group.leave()
        }, failure: { errStr in
            group.leave()
        })
        group.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
        }
        
        AuditUser.shared.load()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAuditList(_:)), name: NotificationName.NotificationAuditListWillRefresh.name, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.navigationBar.tintColor = UIColor(red: 0.14, green: 0.69, blue: 0.93, alpha: 1.00)
//        navigationController?.navigationBar.setBackgroundImage(UIImage(color: .white), for: UIBarMetrics.default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//        self.navigationController?.navigationBar.barStyle = .default
  //      self.navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = "蹭课"
        
        let auditBack = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = auditBack
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search(_:)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension AuditHomeViewController {
    @objc func search(_ sender: UIBarButtonItem) {
        let searchVC = AuditSearchViewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func refreshAuditList(_ notification: Notification) {
        ClasstableDataManager.getPersonalAuditList(success: { model in
            self.personalCourseList = []
            model.data.forEach { list in
                list.infos.forEach { item in
                    self.personalCourseList.append(item)
                }
                
            }
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }, failure: { errStr in
            
        })
    }
}

extension AuditHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 45
        } else {
            return 130
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "热门课程"
        } else {
            return "我的蹭课"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        } else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isFold == true, indexPath.section == 0, indexPath.row == 3 {
            self.isFold = false
            self.tableView.reloadData()
            return
        }
        
        if indexPath.section == 0 {
            let courseID = String(self.popularList[indexPath.row].courseID)
            let detailVC = AuditDetailViewController(courseID: courseID)
            self.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            let item = self.personalCourseList[indexPath.row]
            let popupVC = PopupDialog(title: "确定要取消蹭课吗？亲～", message: "取消蹭课：" + item.courseName, buttonAlignment: .horizontal, transitionStyle: .zoomIn)
            let cancelButton = CancelButton(title: "我再想想", action: nil)
            let deleteButton = DestructiveButton(title: "不想蹭了") {
//                ClasstableDataManager.deleteAuditCourse(schoolID: TwTUser.shared.schoolID, infoIDs: [item.courseID], success: {
//                    SwiftMessages.showSuccessMessage(body: "删除成功")
//
//                    ClasstableDataManager.getPersonalAuditList(success: { model in
//                        var items: [AuditDetailCourseItem] = []
//                        model.data.forEach { list in
//                            items += list.infos
//                        }
//                        AuditUser.shared.update(auditCourses: items)
//                        self.personalCourseList = items
//                        self.tableView.reloadData()
//                    }, failure: { errStr in
//
//                    })
//                }, failure: { errStr in
//
//                })
                
                AuditUser.shared.deleteCourse(infoIDs: [item.courseID], success: { items in
                    SwiftMessages.showSuccessMessage(body: "删除成功")
                    
                    self.personalCourseList = items
                    self.tableView.reloadData()
                }, failure: { errStr in
                    
                })
            }
            popupVC.addButtons([cancelButton, deleteButton])
            self.present(popupVC, animated: true)
        }
    }
}

extension AuditHomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.isFold == true {
                return self.popularList.count == 0 ? 0 : 3 + 1
            } else {
                return self.popularList.count
            }
        } else {
            return self.personalCourseList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if isFold == true {
                if indexPath.row < 3 {
                    let cell = UITableViewCell(style: .default, reuseIdentifier: "CELL_default")
                    cell.textLabel?.text = self.popularList[indexPath.row].course.name
                    return cell
                } else {
                    let cell = UITableViewCell(style: .default, reuseIdentifier: "CELL_default")
                    cell.textLabel?.text = "展开热门课程"
                    cell.textLabel?.textColor = .red
                    return cell
                }
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "CELL_default")
                cell.textLabel?.text = self.popularList[indexPath.row].course.name
                cell.imageView?.image = UIImage.resizedImage(image: UIImage(named: "readerAvatar0")!, scaledToSize: CGSize(width: 12, height: 12))
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AuditDetailCourseTableViewCell") as! AuditDetailCourseTableViewCell
            
            let item = self.personalCourseList[indexPath.row]
            
//            if let conflictCourse = AuditUser.shared.checkConflict(item: item) {
//                cell.flagLabel.text = "冲突课程：" + conflictCourse
//                cell.isConflict = true
//            } else {
//                cell.flagLabel.text = "没有冲突"
//                cell.isConflict = false
//            }
            cell.flagLabel.isHidden = true
            
            cell.nameLabel.text = item.courseName
            cell.teacherLabel.text = item.teacher + " " + item.teacherType
            let startWeek = item.startWeek
            let endWeek = item.endWeek
            var weekType = ""
            
            if item.weekType == 1 {
                weekType = "单周"
            } else if item.weekType == 2 {
                weekType = "双周"
            } else if item.weekType == 3 {
                weekType = "单双周"
            }
            
            cell.weekTimeLabel.text = "第 " + String(startWeek) + "-" + String(endWeek) + " 周  " + weekType
            let dayTime = self.dayTitles[item.weekDay - 1]
            let startTime = item.startTime
            let endTime = item.startTime + item.courseLength - 1
            cell.dayTimeLabel.text = dayTime + " " + String(startTime) + "-" + String(endTime) + " 节"
            cell.locationLabel.text = item.building + "楼" + item.room
            cell.collegeLabel.text = item.courseCollege
            
            return cell
        }
    }
}
