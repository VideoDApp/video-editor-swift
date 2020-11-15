import Foundation
import Photos
import Just

class TestContentInfo {
    public var url: String = ""
    public var targetName: String = ""

    init(_ url: String, _ targetName: String) {
        self.url = url
        self.targetName = targetName
    }
}

class DownloadTestContent {
    static let tiktokDownalodUrl = "https://zoomerok.app/tt-down/index.php"
    /*static var urls = [
        TestContentInfo("https://localhost:1030/TestVideo.mov", "TestVideo.mov"),
        TestContentInfo("https://localhost:1030/TestVideo2.mov", "TestVideo2.mov")
    ]*/

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func getCacheDirectoryPath() -> URL {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        return cacheDirectoryPath
    }

    static func downloadVideoLinkAndCreateAsset(_ videoLink: String, _ targetName: String) {
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else { return }

        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        // check if the file already exist at the destination folder if you don't want to download it twice
        //if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(targetName).path) {

            // set up your download task
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in

                // use guard to unwrap your optional url
                guard let location = location else { return }

                // create a deatination url with the server response suggested file name
                //let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                let destinationURL = documentsDirectoryURL.appendingPathComponent(targetName)

                do {
                    try FileManager.default.moveItem(at: location, to: destinationURL)

                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in

                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL) }) { completed, error in
                                if completed {
                                    print("Video asset created")
                                } else {
                                    print(error!)
                                }
                            }
                        }
                    })

                } catch { print(error) }

            }.resume()

        } else {
            print("File already exists at destination url")
        }

    }

    static func clearAllLocalContent() {

    }

    /*static func downloadAll() {
        urls.forEach { item in
            downloadVideoLinkAndCreateAsset(item.url, item.targetName)
        }
    }*/

    static func getFilePath(_ fileName: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }

    static func isFileExists(_ fileName: String) -> Bool {
        return FileManager.default.fileExists(atPath: getFilePath(fileName).path)
    }

    static func generateFileName(mainName: String = "merged", nameExtension: String = "mov") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let date = dateFormatter.string(from: Date())

        return "\(mainName)-\(date)-\(Int.random(in: 1...100000)).\(nameExtension)"
    }

//    static func downloadString(_ urlString: String, onSuccess:()->(), onError:()->()) -> String {
//         let url = URL(string: urlString)!
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
//
//
//        components.queryItems = [
//            URLQueryItem(name: "url", value: videoUrl)
//        ]
//        let query = components.url!.query
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = Data(query!.utf8)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                let response = response as? HTTPURLResponse,
//                error == nil else {                                              // check for fundamental networking error
//                print("error", error ?? "Unknown error")
////                onError(error!.localizedDescription)
//                return
//            }
//
//            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
//                print("statusCode should be 2xx, but is \(response.statusCode)")
//                print("response = \(response)")
//                onError("Incorrect answer code \(response.statusCode)")
//                return
//            }
//
//            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(responseString)")
//            onSuccess()
//        }
//
//        task.resume()
//    }

    static func saveBinaryToGallery(_ data: Data) {
//        var resultUrl = self.getDocumentsDirectory()
        var resultUrl = self.getCacheDirectoryPath()
        resultUrl.appendPathComponent("tt-down.mp4")
        do {
            if FileManager.default.fileExists(atPath: resultUrl.path) {
                try FileManager.default.removeItem(at: resultUrl)
            }

            try data.write(to: resultUrl)
            PHPhotoLibrary.shared().performChanges({
//                let req =
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: resultUrl)

            }) { (saved, error) in
                print("PHPhotoLibrary saved \(saved), error \(String(describing: error))")

                if error != nil {
//                            self.saveError = "PHPhotoLibrary error - \(error!)"
                    return ()
                }

//                        print("local placeholder \(placeholder!)")
                //                        self.onOpenTiktok(localIdentifier: placeholder!.localIdentifier)
//                        self.activeSheet = .none
//                        if isTiktok {
//                            self.openTiktokDescription()
//                        }
            }
        } catch {

        }
    }

    static func downloadTiktok(_ videoUrl: String, onUrlSuccess: @escaping () -> (), onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        let url = URL(string: self.tiktokDownalodUrl)!

        func downloadFile(_ videoUrl: String) {
            print("Call downloadTiktok->downloadFile")
            let url = URL(string: videoUrl)!
            Just.get(url, asyncCompletionHandler: { r in
                if r.ok {
                    print("total result \(r.content)")
                    self.saveBinaryToGallery(r.content!)
                    onSuccess()
                } else {
                    onError(r.error!)
                }
            })
        }

        Just.post(
            url,
            data: ["url": videoUrl],
            asyncCompletionHandler: { r in
                if r.ok {
//                    print("conten \(r.content)")
//                    print("json \(json)")
                    let json = r.json as! [String: Any]
                    let isError = json["is_error"] as! Int
                    let resultUrl = json["text"] as! String
                    if isError == 0 && resultUrl.count > 0 {
                        onUrlSuccess()
                        print("Video url \(resultUrl)")
                        downloadFile(resultUrl)
                    }
                } else {
                    onError(r.error!)
                }
            })
    }
}
