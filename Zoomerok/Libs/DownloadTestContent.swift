//
//  DownloadTestContent.swift
//  Zoomerok
//
//  Created by sdancer on 9/6/20.
//  Copyright © 2020 Shadurin Organization. All rights reserved.
//

import Foundation
import Photos

class TestContentInfo {
    public var url: String = ""
    public var targetName: String = ""

    init(_ url: String, _ targetName: String) {
        self.url = url
        self.targetName = targetName
    }
}

class DownloadTestContent {
    /*static var urls = [
        TestContentInfo("https://localhost:1030/TestVideo.mov", "TestVideo.mov"),
        TestContentInfo("https://localhost:1030/TestVideo2.mov", "TestVideo2.mov")
    ]*/

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
}
