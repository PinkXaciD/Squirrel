//
//  EditPlaceView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/08/24.
//

import SwiftUI

struct EditPlaceView: View {
    @Binding var newPlace: String
    @FocusState var placeIsFocused: Bool
    var body: some View {
        Form {
            TextField("Place name", text: $newPlace)
        }
        .navigationTitle("Place")
        .focused($placeIsFocused)
        .onAppear {
            placeIsFocused = true
        }
    }
}

struct EditPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        @State var newPlace: String = "Test"
        EditPlaceView(newPlace: $newPlace)
    }
}
