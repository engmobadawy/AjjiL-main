////
////  DocumentPickerView.swift
////  
////
////  Created by M.Magdy on 06/04/2023.
////  Copyright © 2023  Nura. All rights reserved.
////
//
//import SwiftUI
//import MobileCoreServices // For handling file types
//import UniformTypeIdentifiers // For handling images
//
//struct DocumentPicker: UIViewControllerRepresentable {
//    @Binding var selectedFile: URL?
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
//        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
//        documentPicker.delegate = context.coordinator
//        return documentPicker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
//        // Update
//    }
//    
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        var parent: DocumentPicker
//        
//        init(_ documentPicker: DocumentPicker) {
//            self.parent = documentPicker
//        }
//        
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            if let fileURL = urls.first {
//                parent.selectedFile = fileURL
//            }
//        }
//        
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            // Handle cancellation if needed
//        }
//    }
//}
