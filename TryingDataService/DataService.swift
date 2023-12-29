//
//  DataService.swift
//  CaseTracker
//
//  Created by Tim Yoon on 11/30/23.
//

import Foundation
import Combine

protocol DataService {
    associatedtype ItemType: Identifiable & Codable
    func getData()->AnyPublisher<[ItemType], Error>
    func add(_ item: ItemType)
    func delete(_ item: ItemType)
    func delete(indexSet: IndexSet)
    func update(_ item: ItemType)
}


class MockDataService<T: Identifiable & Codable> : DataService {
    @Published private var items : [T] = []
    func getData()->AnyPublisher<[T], Error> {
        $items.tryMap({$0}).eraseToAnyPublisher()
    }
    
    func add(_ item: T){
        items.append(item)
    }
    func delete(_ item: T){
        guard let index = items.firstIndex(where: {$0.id == item.id}) else { return }
        items.remove(at: index)
    }
    func delete(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
    func update(_ item: T){
        guard let index = items.firstIndex(where: {$0.id == item.id}) else { return }
        items[index] = item
    }
}
