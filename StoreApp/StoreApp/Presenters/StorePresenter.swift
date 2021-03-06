//
//  StorePresenter.swift
//  StoreApp
//
//  Created by 조재흥 on 19. 4. 19..
//  Copyright © 2019 hngfu. All rights reserved.
//

import UIKit
import Toaster

class StorePresenter: NSObject {

    //MARK: - Properties
    //MARK: Views
    private weak var storeTableViewController: StoreTableViewController?
    private weak var borderColorView: BorderColorView?
    
    //MARK: Models
    private let storeItems: StoreItemManager
    
    //MARK: Routers
    private var detailRouter: DetailRouter?
    
    //MARK: Helpers
    private let sectionTaskGroup = DispatchGroup()
    
    //MARK: - Methods
    //MARK: Initialization
    override init() {
        let variousSectionInfo = [SectionInfo(fileName: "main", title: "메인반찬", description: "한그릇 뚝딱 메인 요리"),
                                  SectionInfo(fileName: "soup", title: "국.찌게", description: "김이 모락모락 국.찌게"),
                                  SectionInfo(fileName: "side", title: "밑반찬", description: "언제 먹어도 든든한 밑반찬"),]
        
        if NetworkStatus.shared.isConnected() {
            self.storeItems = StoreItemManager(variousSectionInfo: variousSectionInfo)
        } else {
            self.storeItems = StoreItemManager(variousDefaultSectionInfo: variousSectionInfo)
        }
        super.init()
        self.detailRouter = DetailRouter(navigationController: self)
        changeBorderColor()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTableSection),
                                               name: .storeItemsWillUpdate,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTableRow),
                                               name: .rowWillReload,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateStatus(_:)),
                                               name: .reachabilityChanged,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTableView(_:)),
                                               name: .storeItemsDidRemove,
                                               object: nil)
    }
    
    //MARK: Objc
    @objc func reloadTableSection(_ noti: Notification) {
        guard let object = noti.object as? StoreItems,
            let index = storeItems.index(of: object),
            let userInfo = noti.userInfo,
            let appendItems = userInfo[UserInfoKey.appendItems] as? () -> Void else { return }
        sectionTaskGroup.wait()
        sectionTaskGroup.enter()
        appendItems()
        DispatchQueue.main.async {
            self.storeTableViewController?.reload(section: index)
            self.sectionTaskGroup.leave()
        }
    }
    
    @objc func reloadTableRow(_ noti: Notification) {
        guard let userInfo = noti.userInfo,
            let indexPath = userInfo[UserInfoKey.indexPathWillReload] as? IndexPath else { return }
        DispatchQueue.main.async {
            self.storeTableViewController?.reload(indexPath: indexPath)
        }
    }
    
    @objc func updateStatus(_ noti: Notification) {
        changeBorderColor()
        if NetworkStatus.shared.isConnected() {
            updateStoreItems()
        }
    }
    
    @objc func reloadTableView(_ noti: Notification) {
        DispatchQueue.main.async {
            self.storeTableViewController?.reload()
        }
    }
    
    private func changeBorderColor() {
        let color: CGColor = NetworkStatus.shared.isConnected() ? #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        DispatchQueue.main.async {
            self.borderColorView?.change(borderColor: color)
        }
    }
    
    private func updateStoreItems() {
        let variousSectionInfo = [SectionInfo(fileName: "main", title: "메인반찬", description: "한그릇 뚝딱 메인 요리"),
                                  SectionInfo(fileName: "soup", title: "국.찌게", description: "김이 모락모락 국.찌게"),
                                  SectionInfo(fileName: "side", title: "밑반찬", description: "언제 먹어도 든든한 밑반찬"),]
        self.storeItems.update(with: variousSectionInfo)
    }
    
    //MARK: Presenter
    func attach(storeTableViewCotroller: StoreTableViewController) {
        self.storeTableViewController = storeTableViewCotroller
    }
    
    func detachStoreTableView() {
        self.storeTableViewController = nil
    }
    
    func attach(netStatusView: BorderColorView) {
        self.borderColorView = netStatusView
    }
    
    func detachNetStatusView() {
        self.borderColorView = nil
    }
}

extension StorePresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeItems[section]?.count() ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return storeItems.itemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoreTableViewCell.identifier,
                                                 for: indexPath)
        guard let storeTableViewCell = cell as? StoreTableViewCell,
            let storeItems = storeItems[indexPath.section],
            let storeItem = storeItems[indexPath.row] else { return cell }
        
        storeTableViewCell.show(with: storeItem)
        return storeTableViewCell
    }
}

extension StorePresenter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: StoreTableViewHeaderView.identifier)
        guard let sectionInfo = storeItems[section]?.sectionInfo,
            let storeTableViewHeaderView = cell as? StoreTableViewHeaderView else { return nil }
        storeTableViewHeaderView.show(with: sectionInfo)
        return storeTableViewHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items = storeItems[indexPath.section],
            let item = items[indexPath.row] else { return }
        if let toast = ToastCenter.default.currentToast {
            toast.cancel()
        }
        Toast(text: "타이틀 메뉴: \(item.title)\n가격: \(item.s_price)",
              delay: 0,
              duration: Delay.short).show()
        guard let detailHash = storeItems[indexPath.section]?[indexPath.row]?.detail_hash,
            let cell = tableView.cellForRow(at: indexPath) as? StoreTableViewCell else { return }
        detailRouter?.presentViewController(detailHash: detailHash, title: cell.titleLabel.text, delegate: self)
    }
}

extension StorePresenter: DetailViewControllerDelegate {
    
    func post(orderMessage: String) {
        let poster = WebHookPoster()
        poster.post(message: orderMessage)
    }
}

extension StorePresenter: Navigation {
    func push(viewController: UIViewController) {
        self.storeTableViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
