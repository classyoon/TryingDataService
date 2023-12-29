//
//  ContentView.swift
//  TryingDataService
//
//  Created by Conner Yoon on 12/28/23.
//

import SwiftUI
import Combine
struct ContentView: View {
    @StateObject var vm = QuestionListVM()
    var body: some View {
        
        QuestionListView(vm: vm)
    }
}
struct QuestionModel : Identifiable & Codable {
    var id : String = UUID().uuidString
    var text : String = ""
    var choices  = [String]()
    var correctIndex = 0
    
    static let example : QuestionModel = QuestionModel(text: "who you are?", choices: ["Tim", "Conner", "Chris"], correctIndex: 1)
}

class QuestionListVM : ObservableObject {
    @Published private(set) var questions  : [QuestionModel] = []//Private mandates we use the function we set
    private let ds = UserDefaultDS<QuestionModel>(key: "question store")
    private var cancellables = Set<AnyCancellable>()
    init() {
        ds.getData().sink { error in
            fatalError("Errorr \(error)")
        } receiveValue: { [weak self] questions in
            self?.questions = questions
        }.store(in: &cancellables)
    }
    func add(_ question : QuestionModel) {
        ds.add(question)
    }
    func update(_ question : QuestionModel){
        ds.update(question)
    }
    func delete(_ quesiton : QuestionModel){
        ds.delete(quesiton)
    }
}

struct QuestionListView : View {
    @ObservedObject var vm : QuestionListVM
    @State private var questionText = ""
    @State private var isShowingSheet = false
    
    var body: some View {
        NavigationStack {
            List {
             
                ForEach(vm.questions) {  question in
                    NavigationLink{
                        QuestionEditView(question: question, save: vm.update, delete: vm.delete)
                            .navigationTitle("Question edit")
                    } label: {
                        Text("\(question.text)")
                    }
                    
                }
                
            }.navigationTitle("Question maker")
                .toolbar{
                    ToolbarItem{
                        Button {
                            isShowingSheet = true
                        } label: {
                            Label("Add question", systemImage: "plus.circle")
                        }
                        
                    }
                }
                .sheet(isPresented: $isShowingSheet, content: {
                    NavigationStack {
                        QuestionEditView(question: QuestionModel.example, save: vm.add, delete: vm.delete)
                            .navigationTitle("Question add")
                    }
                })
        }
    }
}
struct QuestionEditView : View {
    let question : QuestionModel
    @State private var vm = QuestionModel()
    @State private var questionText = ""
    @State private var choiceText = ""
    @Environment(\.dismiss) var dismiss
    
    var save : (QuestionModel) -> ()
    var delete : (QuestionModel) -> ()
    var body: some View {
        Form{
            TextField("\(question.text)", text: $vm.text)
            Section("Choices") {
                HStack {
                    TextField("Choice", text: $choiceText).onSubmit {
                        addChoice(choiceText)
                    }
                    Button {
                        addChoice(choiceText)
                    } label: {
                        Text("Add Choice")
                    }

                }
                ForEach($vm.choices, id: \.self){ $choice in
                    TextField("choice", text: $choice)
                }.onDelete(perform: { indexSet in
                    vm.choices.remove(atOffsets: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    vm.choices.move(fromOffsets: indices, toOffset: newOffset)
                })
                
            }
            Section("Control buttons"){
                HStack{
                    Button(action: {
                        save(vm)
                        dismiss()
                    }, label: {
                        Text("Save")
                    })
                    Button(action: {
                        delete(vm)
                        dismiss()
                    }, label: {
                        Text("Delete")
                    })
                }
            }
        }.onAppear{
            vm = question
        }
        
    }
    private func addChoice(_ text : String) {
        vm.choices.append(text)
    }
}


#Preview {
    ContentView()
}
