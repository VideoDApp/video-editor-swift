import Foundation
import SwiftUI
import MobileCoreServices

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //@Binding var image: UIImage?
    @Binding var isShown: Bool
    var onPicked: (URL) -> ()

    init(//image: Binding<UIImage?>,
        isShown: Binding<Bool>,
        @ViewBuilder onPicked: @escaping (URL) -> ()) {
        //_image = image
        _isShown = isShown
        self.onPicked = onPicked
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        print("imagePickerController picked \(String(describing: url))")

        self.onPicked(url!)
        isShown = false
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
        print("cancel")
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator

    //@Binding var image: UIImage?
    @Binding var isShown: Bool
    var sourceType: UIImagePickerController.SourceType = .camera
    var onPicked: (URL) -> ()

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePickerCoordinator(
            //image: $image,
            isShown: $isShown,
            onPicked: onPicked)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.videoQuality = .typeIFrame1280x720
        picker.delegate = context.coordinator

        return picker
    }
}
