//
//  ExportImportView.swift
//  financecontrol
//
//  Created by PinkXaciD on R 5/10/18.
//

import SwiftUI

struct ExportImportView: View {
    @EnvironmentObject private var cdm: CoreDataModel
    
    @AppStorage(UDKeys.color.rawValue) private var tint: String = "Orange"
    
    @State private var shareURL: URL = .init(string: "https://apple.com")!
    @State private var presentExportSheet: Bool = false
    @State private var presentImportSheet: Bool = false
    
    var body: some View {
        List {
            jsonSection
        }
        .sheet(isPresented: $presentExportSheet, onDismiss: deleteTempFile) {
            CustomShareSheet(url: $shareURL)
        }
        .fileImporter(isPresented: $presentImportSheet, allowedContentTypes: [.json]) { result in
            importJSON(result)
        }
        .navigationTitle("Export and Import")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var jsonSection: some View {
        Section(header: header) {
            exportJSONButton
            
            importJSONButton
        }
    }
    
    private var header: some View {
        VStack {
            Image(systemName: "doc.text.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
            
            Text(verbatim: "SquirrelExport.json")
                .font(.body)
        }
        .foregroundColor(.secondary)
        .textCase(nil)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(30)
        .listRowInsets(.init(top: 15, leading: 20, bottom: 15, trailing: 20))
    }
    
    private var exportJSONButton: some View {
        Button("Export all data as JSON") {
            exportJSON()
        }
    }
    
    private var importJSONButton: some View {
        Button("Import data from JSON") {
            presentImportSheet.toggle()
        }
    }
}

extension ExportImportView {
    private func exportJSON() {
        do {
            if let url = try cdm.exportJSON() {
                shareURL = url
                presentExportSheet.toggle()
            }
        } catch {
            ErrorType(error: error).publish()
        }
    }
    
    private func importJSON(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            if let imported = cdm.importJSON(url) {
                switch imported {
                case 0:
                    CustomAlertManager.shared.addAlert(.init(type: .warning, title: "Nothing to import", systemImage: "exclamationmark.circle"))
                default:
                    CustomAlertManager.shared.addAlert(.init(type: .success, title: "Success", description: "Imported \(imported) expenses", systemImage: "checkmark.circle"))
                }
            } else {
                CustomAlertManager.shared.addAlert(.init(type: .error, title: "Import failed", systemImage: "xmark.circle"))
            }
        case .failure(let failure):
            ErrorType(error: failure).publish()
        }
    }
    
    private func deleteTempFile() {
        do {
            try FileManager.default.removeItem(at: shareURL)
            HapticManager.shared.notification(.success)
        } catch {
            ErrorType(error: error).publish()
        }
    }
}

//#Preview {
//    ExportImportView()
//        .environmentObject(CoreDataModel())
//}
