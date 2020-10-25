import Foundation
import SwiftUI
import MobileCoreServices

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var isShown: Bool
    var onPicked: (URL) -> ()

    init(
        isShown: Binding<Bool>,
        @ViewBuilder onPicked: @escaping (URL) -> ()) {
        _isShown = isShown
        self.onPicked = onPicked
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        print("imagePickerController picked \(String(describing: url))")
        picker.dismiss(animated: true, completion: {
            self.isShown = false
            self.onPicked(url!)
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
        print("cancel")
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator

    @Binding var isShown: Bool
    var sourceType: UIImagePickerController.SourceType = .camera
    var onPicked: (URL) -> ()

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePickerCoordinator(
            isShown: $isShown,
            onPicked: onPicked)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = [kUTTypeMovie as String]
//        picker.videoQuality = .typeIFrame1280x720
        picker.videoQuality = .typeHigh
        picker.allowsEditing = true
        picker.delegate = context.coordinator

        return picker
    }
}
