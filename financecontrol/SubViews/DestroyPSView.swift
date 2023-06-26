//
//  DestroyPSView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/07/14.
//
//
//import SwiftUI
//
//struct DestroyPSView: View {
//    @StateObject var vm = OperationsCoreDataViewModel()
//    
//    @State var alertIsShowing: Bool = false
//    
//    var body: some View {
//        List {
//            Text("This button will delete all CoreData without connecting to storage")
//            
//            Button {
//                alertIsShowing.toggle()
//            } label: {
//                Text("Destroy Persistance Store")
//                    .font(Font.body.weight(.bold))
//                    .foregroundColor(Color.red)
//                    .alert("Are you sure?", isPresented: $alertIsShowing) {
//                        Button {
//                            vm.deleteAllData()
//                        } label: {
//                            Text("Yes")
//                        }
//                        
//                        Button(role: .cancel) {
//                            
//                        } label: {
//                            Text("Cancel")
//                        }
//                    } message: {
//                        Text("This will delete whole database")
//                    }
//            }
//        }
//        .navigationTitle("Confirmation")
//    }
//}
//
//struct DestroyPSView_Previews: PreviewProvider {
//    static var previews: some View {
//        DestroyPSView()
//    }
//}
