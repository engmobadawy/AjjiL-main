//
//  ImagePickerView.swift
//  
//
//  Created by M.Magdy on 06/04/2023.
//  Copyright © 2023  Nura. All rights reserved.
//
import SwiftUI
import MobileCoreServices // For handling file types
import UniformTypeIdentifiers // For handling images
import PhotosUI
import AVFoundation

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var selectedImageURL: String?
    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        imagePicker.modalPresentationStyle = .overFullScreen // This will respect the safe area
        checkPermissions()
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
        // Update the sourceType when it changes
        if uiViewController.sourceType != sourceType {
            uiViewController.sourceType = sourceType
        }
    }

    func checkPermissions() {
        switch sourceType {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    print("Camera access denied")
                }
            }
        case .photoLibrary, .savedPhotosAlbum:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized, .limited:
                    break
                case .denied, .restricted, .notDetermined:
                    print("Photo library access denied or restricted")
                @unknown default:
                    fatalError("Unknown status for photo library access")
                }
            }
        default:
            break
        }
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView

        init(_ imagePicker: ImagePickerView) {
            self.parent = imagePicker
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.selectedImage = selectedImage
            }
            // Get the URL (works for .photoLibrary and .savedPhotosAlbum)
                       if let imageURL = info[.imageURL] as? URL {
                           parent.selectedImageURL = imageURL.path()
                       } else if let referenceURL = info[.phAsset] as? PHAsset {
                           // Handle PHAsset (Photos framework asset)
                           self.getURLFromPHAsset(asset: referenceURL) { url in
                               self.parent.selectedImageURL = url?.path()
                           }
                       }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        // Helper to get URL from PHAsset
               private func getURLFromPHAsset(asset: PHAsset, completion: @escaping (URL?) -> Void) {
                   asset.requestContentEditingInput(with: nil) { input, _ in
                       completion(input?.fullSizeImageURL)
                   }
               
           }
    }
}


struct ImagePickerMultiSelection: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController

    let sourceType: UIImagePickerController.SourceType
    let isMultiSelection: Bool
    @Binding var selectedImages: [UIImage]
    @State var selectionNumber: Int

    func makeUIViewController(context: Context) -> PHPickerViewController {
        checkPermissions()
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = isMultiSelection ? selectionNumber : 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func checkPermissions() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                break
            case .denied, .restricted, .notDetermined:
                print("Photo library access denied or restricted")
            @unknown default:
                fatalError("Unknown status for photo library access")
            }
        }
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerMultiSelection

        init(_ parent: ImagePickerMultiSelection) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self?.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }
}

struct ImageProfilePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImageProfilePickerView>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        imagePicker.modalPresentationStyle = .automatic // This will respect the safe area
        checkPermissions()
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImageProfilePickerView>) {
        // Update the sourceType when it changes
        if uiViewController.sourceType != sourceType {
            uiViewController.sourceType = sourceType
        }
    }

    func checkPermissions() {
        switch sourceType {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    print("Camera access denied")
                }
            }
        case .photoLibrary, .savedPhotosAlbum:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized, .limited:
                    break
                case .denied, .restricted, .notDetermined:
                    print("Photo library access denied or restricted")
                @unknown default:
                    fatalError("Unknown status for photo library access")
                }
            }
        default:
            break
        }
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImageProfilePickerView

        init(_ imagePicker: ImageProfilePickerView) {
            self.parent = imagePicker
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.selectedImage = selectedImage
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
