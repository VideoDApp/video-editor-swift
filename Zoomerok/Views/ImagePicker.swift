import Foundation
import SwiftUI
import MobileCoreServices

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var isShown: Bool
    var onPicked: (URL) -> ()
    var onPickedImage: (UIImage) -> ()
    var isVideo: Bool

    init(
        isShown: Binding<Bool>,
        isVideo: Bool,
        @ViewBuilder onPicked: @escaping (URL) -> (),
        @ViewBuilder onPickedImage: @escaping (UIImage) -> ()) {
        _isShown = isShown
        self.onPicked = onPicked
        self.onPickedImage = onPickedImage
        self.isVideo = isVideo
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let url: URL?
        if self.isVideo {
            url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            print("imagePickerController video picked \(String(describing: url))")

            picker.dismiss(animated: true, completion: {
                self.isShown = false
                self.onPicked(url!)
            })
        } else {
            let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage

            picker.dismiss(animated: true, completion: {
                self.isShown = false
                self.onPickedImage(chosenImage!)
            })

        }
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
    var isVideo: Bool = true
    var onPicked: (URL) -> ()
    var onPickedImage: (UIImage) -> ()

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePickerCoordinator(
            isShown: self.$isShown,
            isVideo: self.isVideo,
            onPicked: self.onPicked,
            onPickedImage: self.onPickedImage
        )
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        if self.isVideo {
            //        picker.videoQuality = .typeIFrame1280x720
            picker.videoQuality = .typeHigh
            picker.mediaTypes = [kUTTypeMovie as String]
        } else {
            picker.mediaTypes = [kUTTypeImage as String]
        }

        picker.allowsEditing = true
        picker.delegate = context.coordinator

        return picker
    }
}
