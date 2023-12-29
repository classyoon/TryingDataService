//
//  UserDefaultsDS.swift
//  CaseTracker
//
//  Created by Tim Yoon on 11/30/23.
//

import Foundation
import Combine

class UserDefaultDS<T: Identifiable & Codable>: DataService {
    let key: String
    
    @Published private var items:[T] {
        didSet {
            save(items: items, key: key)
        }
    }
    
    init(key: String = "UserDefault") {
        self.key = key
        items = []
        
        items = load(key: key)
    }
    
    func getData() -> AnyPublisher<[T], Error> {
        $items.tryMap{$0}.eraseToAnyPublisher()
    }
    
    func add(_ item: T) {
        items.append(item)
    }
    
    func update(_ item: T) {
        guard let index = items.firstIndex(where: {$0.id == item.id}) else { return }
        items[index] = item
    }
    func delete(_ item: T) {
        guard let index = items.firstIndex(where: {$0.id == item.id}) else { return }
        items.remove(at: index)
    }
    func delete(indexSet: IndexSet) {
        var itemsToDelete = [T]()
        indexSet.forEach{ itemsToDelete.append(items[$0])}
        itemsToDelete.forEach{ delete($0)}
    }
    
// MARK: Private Funcs
    
    private func save<Item: Identifiable & Codable>(items: [Item], key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    private func load<Item: Identifiable & Codable>(key: String) -> [Item] {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return [] }
        
        let decoder = JSONDecoder()
        if let dataArray = try? decoder.decode([Item].self, from: data) {
            return dataArray
        }
        
        return []
    }

}
