//
//  FilePicker.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 26.02.2024.
//

//import SwiftUI
//
//
//struct DocumentPicker: UIViewControllerRepresentable {
//
//	@Binding var fileContent: Data
//	
//	func makeCoordinator() -> DocumentPickerCoordinator {
//		return DocumentPickerCoordinator(fileContent: $fileContent)
//	}
//	
//	func makeUIViewController(context:
//		UIViewControllerRepresentableContext<DocumentPicker>) ->
//	UIDocumentPickerViewController {
//		//The file types like ".pkcs12" are listed here:
//		//https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers?changes=latest_minor
//		let controller: UIDocumentPickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.wav, .mp3, .aiff], asCopy: true)
//		controller.delegate = context.coordinator
//	return controller
//	}
//	
//	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
//		print("update")
//	}
//} //struct
//
//class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
//
//	@Binding var fileContent: Data
//	
//	init(fileContent: Binding<Data>) {
//		_fileContent = fileContent
//	}
//
//	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//		let fileURL = urls[0]
//		
//		let certData = try! Data(contentsOf: fileURL)
//		
//		if let documentsPathURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
//			let certURL = documentsPathURL.appendingPathComponent("certFile.pfx")
//			
//			try? certData.write(to: certURL)
//		}
//
//	}
//}
