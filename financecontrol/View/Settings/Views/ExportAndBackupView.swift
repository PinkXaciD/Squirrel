//
//  ExportAndBackupView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/18.
//

import SwiftUI

struct ExportAndBackupView: View {
    @EnvironmentObject private var cdm: CoreDataModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @AppStorage(UDKey.color.rawValue) private var tint: String = "Orange"
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\SpendingEntity.date)])
    private var spendings: FetchedResults<SpendingEntity>
    
    @State private var shareURL: URL = .init(string: "https://apple.com")!
    @State private var presentExportSheet: Bool = false
    @State private var presentExportCSVSheet: Bool = false
    @State private var presentImportSheet: Bool = false
    
    var body: some View {
        VStack {
            if spendings.isEmpty {
                CustomContentUnavailableView("No Expenses", imageName: "list.bullet", description: "You can add expenses from home screen.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Spacer()
            }
            
            csvButton
            
            jsonButtons
        }
        .padding(.vertical)
        .padding(.horizontal, dynamicTypeSize > .xLarge ? 0 : nil)
        .background {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $presentExportSheet, onDismiss: deleteTempFile) {
            CustomShareSheet(url: $shareURL)
        }
        .fileImporter(isPresented: $presentImportSheet, allowedContentTypes: [.json]) { result in
            importJSON(result)
        }
        .sheet(isPresented: $presentExportCSVSheet) {
            ExportCSVView(cdm: cdm)
        }
        .navigationTitle("Export and Backup")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var csvButton: some View {
        Button {
            presentExportCSVSheet.toggle()
        } label: {
            buttonLabel(title: "Export to spreadsheet", subtitle: "Export to CSV", systemImage: "arrow.up.doc.fill")
                .clipShape(RoundedRectangle(cornerRadius: dynamicTypeSize > .xLarge ? 0 : 15))
                .overlay {
                    if dynamicTypeSize > .xLarge {
                        VStack {
                            Divider()
                            
                            Spacer()
                            
                            Divider()
                        }
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(spendings.isEmpty)
    }
    
    private var jsonButtons: some View {
        VStack(spacing: 0) {
            Button {
                exportJSON()
            } label: {
                buttonLabel(title: "Create local backup", subtitle: "Export to JSON", systemImage: "arrow.up.doc.fill")
            }
            .buttonStyle(.plain)
            .overlay {
                if presentExportSheet {
                    ZStack {
                        Rectangle()
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        
                        ProgressView()
                            .tint(.primary)
                    }
                }
            }
            .animation(.default, value: presentExportSheet)
            .disabled(spendings.isEmpty)
            
            Divider()
            
            Button {
                presentImportSheet.toggle()
            } label: {
                buttonLabel(title: "Import local backup", subtitle: "Import from JSON", systemImage: "arrow.down.doc.fill")
            }
            .buttonStyle(.plain)
        }
        .clipShape(RoundedRectangle(cornerRadius: dynamicTypeSize > .xLarge ? 0 : 15))
        .overlay {
            if dynamicTypeSize > .xLarge {
                VStack {
                    Divider()
                    
                    Spacer()
                    
                    Divider()
                }
            }
        }
    }
    
    private func buttonLabel(title: LocalizedStringKey, subtitle: LocalizedStringKey, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body.bold())
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .foregroundStyle(.primary)
        .padding()
        .background {
            ZStack {
                Rectangle()
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            }
        }
        
        // dynamicTypeSize > .xLarge, horizontalSizeClass == .compact
    }
}

extension ExportAndBackupView {
    private func exportJSON() {
        do {
            presentExportSheet.toggle()
            
            if let url = try cdm.exportJSON() {
                shareURL = url
            } else {
                presentExportSheet.toggle()
            }
        } catch {
            ErrorType(error: error).publish()
        }
    }
    
    private func importJSON(_ result: Result<URL, Error>) {
        do {
            if let imported = cdm.importJSON(try result.get()) {
                switch imported {
                case 0:
                    CustomAlertManager.shared.addAlert(.init(type: .warning, title: "Nothing to import", systemImage: "exclamationmark.circle"))
                default:
                    CustomAlertManager.shared.addAlert(.init(type: .success, title: "Success", description: "Imported \(imported) expenses", systemImage: "checkmark.circle"))
                }
            }
        } catch {
            ErrorType(error: error).publish()
        }
    }
    
    private func deleteTempFile() {
        do {
            try FileManager.default.removeItem(at: shareURL)
        } catch {
            ErrorType(error: error).publish()
        }
    }
}

#Preview {
    ExportAndBackupView()
        .environmentObject(CoreDataModel())
}
