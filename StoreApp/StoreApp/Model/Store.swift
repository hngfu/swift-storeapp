//
//  Store.swift
//  StoreApp
//
//  Created by oingbong on 11/12/2018.
//  Copyright © 2018 oingbong. All rights reserved.
//

import Foundation

class Store {
    static let key = Notification.Name(Key.notiError)
    
    private var storeItemGroup = [StoreItemGroup]() {
        didSet {
            let key = Notification.Name(Key.notiUpdateItem)
            NotificationCenter.default.post(name: key, object: nil)
        }
    }
    private var topic = [Topic]()
    
    var storeItemGroupCount: Int {
        return storeItemGroup.count
    }
    
    init() {
        appendTopic()
        appendItem()
    }
    
    private func appendTopic() {
        let main = Topic(englihsName: "main", koreanName: "메인반찬", desc: "한그릇 뚝딱 메인 요리")
        let soup = Topic(englihsName: "soup", koreanName: "국.찌게", desc: "김이 모락모락 국.찌게")
        let side = Topic(englihsName: "side", koreanName: "밑반찬", desc: "언제 먹어도 든든한 밑반찬")
        topic.append(main)
        topic.append(soup)
        topic.append(side)
    }
    
    private func appendItem() {
        for item in topic {
            parseUrl(topic: item.englihsName)
        }
    }
    
    // for file
    private func parse(topic: String) -> [StoreItem]? {
        guard let jsonData = Parser.json(fileName: topic) else {
            NotificationCenter.default.post(name: Store.key, object: nil)
            return nil
        }
        guard let items = Parser.storeItems(from: jsonData) else {
            NotificationCenter.default.post(name: Store.key, object: nil)
            return nil
        }
        return items
    }
    
    // for url
    private func parseUrl(topic: String) {
        Parser.jsonUrl(fileName: topic) { (storeItems) in
            guard let items = storeItems, let storeItems = Parser.storeItems(from: items) else {
                NotificationCenter.default.post(name: Store.key, object: nil)
                return
            }
            self.storeItemGroup.append(StoreItemGroup.init(sectionName: topic, sectionObjects: storeItems))
            
        }
    }
    
    subscript(index: Int) -> StoreItemGroup {
        return storeItemGroup[index]
    }
    
    subscript(index: Int) -> Topic {
        return topic[index]
    }
}
