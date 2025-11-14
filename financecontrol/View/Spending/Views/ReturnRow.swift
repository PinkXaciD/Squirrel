//
//  ReturnRow.swift
//  Squirrel
//
//  Created by PinkXaciD on R 6/06/20.
//

import SwiftUI

struct ReturnRow: View {
    @EnvironmentObject private var cdm: CoreDataModel
    @Binding var returnToEdit: ReturnEntity?
    let returnEntity: ReturnEntity
    let spendingCurrency: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                dateFormat(returnEntity.date ?? .distantPast)
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(returnEntity.amount.formatted(.currency(code: returnEntity.currency ?? spendingCurrency)))
                    .font(.system(.title3, design: .rounded).bold())
            }
                
            if let name = returnEntity.name, !name.isEmpty {
                Spacer()
                
                Text(name)
                    .lineLimit(3)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                    }
            }
        }
        .padding(.vertical, 1)
        .normalizePadding()
        .foregroundColor(.primary)
        .swipeActions(edge: .leading) {
            getEditButton(returnEntity)
                .labelStyle(.iconOnly)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            getDeleteButton(returnEntity)
                .labelStyle(.iconOnly)
        }
        .contextMenu {
            getEditButton(returnEntity)
            
            getDeleteButton(returnEntity)
        }
        .onTapGesture {
            returnToEdit = returnEntity
        }
    }
    
    private func getEditButton(_ entity: ReturnEntity) -> some View {
        Button {
            returnToEdit = entity
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.yellow)
    }
    
    private func getDeleteButton(_ entity: ReturnEntity) -> some View {
        Button(role: .destructive) {
            withAnimation {
                cdm.deleteReturn(spendingReturn: entity)
            }
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
        .tint(.red)
    }
    
    private func dateFormat(_ date: Date) -> Text {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        dateFormatter.doesRelativeDateFormatting = true
        
        return Text(dateFormatter.string(from: date))
    }
}
