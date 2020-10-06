import Foundation
import AVKit
import Photos

public enum MontageError: Error {
    case sourceIsEmpty
    case backgroundPartIsEmpty
    case mainPartIsEmpty
    case some
    case fileNotFound
    case exporterError
}

public class VideoPart {
    var videoMutableCompositionTrack: AVMutableCompositionTrack?
    var audioMutableCompositionTrack: AVMutableCompositionTrack?
    var layerInstruction: AVMutableVideoCompositionLayerInstruction?
}

public class Montage {
    let preferredTimescale: Int32 = 600

    var bottomVideoSource: AVAsset?
    var bottomVideoTrack: AVAssetTrack?
    var bottomAudioTrack: AVAssetTrack?

    var overlayVideoSource: AVAsset?
    var overlayVideoTrack: AVAssetTrack?
    var overlayAudioTrack: AVAssetTrack?

    var sourcePart = VideoPart()
    var topPart = VideoPart()
    var bottomPart = VideoPart()
    var overlayPart = VideoPart()
    var mutableMixComposition = AVMutableComposition()
    var videoComposition = AVMutableVideoComposition()

//    init() {
//
//    }

//    func overlayTwoVideos(urlBottom: URL, urlTop: URL) throws {
//        let bottomVideo = AVAsset(url: urlBottom)
//        //let topVideo = AVAsset(url: urlTop)
//
//        let startTime: Float64 = 3
//        let endTime: Float64 = 8
//
//        let overlayMixComposition = AVMutableComposition()
//        let mainInstruction = AVMutableVideoCompositionInstruction()
//        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: bottomVideo.duration)
//
//        //        self.sourcePart.layerInstruction = compositionLayerInstruction(for: self.sourcePart.track!, asset: self.sourceVideo!)
//        let track = overlayMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//        let bottomInstructions = compositionLayerInstruction(for: track!, asset: bottomVideo)
//
//        try track!.insertTimeRange(
//            CMTimeRangeMake(
//                start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
//                duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
//            ),
//            of: track!,
//            at: CMTime.zero)
//        bottomPart.layerInstruction = compositionLayerInstruction(for: track!, asset: bottomVideo)
//
//        // 2.3
//        // SECOND LAYER DRAWS BEFORE FIRST
//        // here I can reorder drawing. drawing here from end to start
//        mainInstruction.layerInstructions = [
//            bottomInstructions
//        ]
//
//        let overlayVideoComposition = AVMutableVideoComposition()
//        overlayVideoComposition.instructions = [mainInstruction]
//        overlayVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//
//        let videoInfo = orientation(from: track!.preferredTransform)
//        print("track!.naturalSize", track!.naturalSize)
//        print("videoInfo", videoInfo)
//        let videoSize: CGSize
//        if videoInfo.isPortrait {
//            videoSize = CGSize(width: track!.naturalSize.height, height: track!.naturalSize.width)
//        } else {
//            videoSize = track!.naturalSize
//        }
//
//        print("videoSize", videoSize)
//        overlayVideoComposition.renderSize = videoSize
//
//        try self.saveAnyToFile(mixComposition: overlayMixComposition, completion: { result in
//            print("overlayTwoVideos complete \(result)")
//        }, error: { result in
//                print("overlayTwoVideos error \(result)")
//            })
//    }

    func reset() {
        bottomVideoSource = nil
        bottomVideoTrack = nil
        bottomAudioTrack = nil
        overlayVideoTrack = nil
        overlayAudioTrack = nil
        topPart = VideoPart()
        bottomPart = VideoPart()
        mutableMixComposition = AVMutableComposition()
    }

    func setBottomVideoSource(url: URL) throws -> Montage {
        if !FileManager.default.fileExists(atPath: url.path) {
            throw MontageError.fileNotFound
        }

        self.reset()
        self.bottomVideoSource = AVAsset(url: url)
        self.bottomVideoTrack = self.bottomVideoSource!.tracks(withMediaType: .video)[0]
        self.bottomAudioTrack = self.bottomVideoSource!.tracks(withMediaType: .audio)[0]
        self.sourcePart.videoMutableCompositionTrack = mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        self.sourcePart.layerInstruction = compositionLayerInstruction(for: self.sourcePart.videoMutableCompositionTrack!, asset: self.bottomVideoSource!)

        return self
    }

    func setOverlayVideoSource(url: URL) throws -> Montage {
        if !FileManager.default.fileExists(atPath: url.path) {
            throw MontageError.fileNotFound
        }

        self.overlayVideoSource = AVAsset(url: url)
        self.overlayVideoTrack = self.overlayVideoSource!.tracks(withMediaType: .video)[0]
        self.overlayAudioTrack = self.overlayVideoSource!.tracks(withMediaType: .audio)[0]
        let overlayMixComposition = AVMutableComposition()
        self.overlayPart.videoMutableCompositionTrack = overlayMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        self.overlayPart.audioMutableCompositionTrack = overlayMixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        self.overlayPart.layerInstruction = self.compositionLayerInstruction(for: overlayPart.videoMutableCompositionTrack!, asset: self.overlayVideoSource!)

        return self
    }

    func setTopPart(startTime: Float64, endTime: Float64) throws -> Montage {
        topPart.videoMutableCompositionTrack = mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try
            topPart.videoMutableCompositionTrack?.insertTimeRange(
                CMTimeRangeMake(
                    start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                    duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
                ),
                of: bottomVideoTrack!,
                at: CMTime.zero)
            topPart.layerInstruction = compositionLayerInstruction(for: topPart.videoMutableCompositionTrack!, asset: bottomVideoSource!)
        } catch {
            print("Failed to load top track")
            //return
        }

        return self
    }

    func setBottomPart(startTime: Float64, endTime: Float64) throws -> Montage {
        bottomPart.audioMutableCompositionTrack = mutableMixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
        bottomPart.videoMutableCompositionTrack = mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

        do {
            try bottomPart.videoMutableCompositionTrack?.insertTimeRange(
                CMTimeRangeMake(
                    start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                    duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
                ),
                of: bottomVideoTrack!,
                at: CMTime.zero)

            try bottomPart.audioMutableCompositionTrack?.insertTimeRange(
                CMTimeRangeMake(
                    start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                    duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
                ),
                of: bottomAudioTrack!,
                at: CMTime.zero)

            bottomPart.layerInstruction = compositionLayerInstruction(for: bottomPart.videoMutableCompositionTrack!, asset: bottomVideoSource!)
        } catch {
            print("Failed to load main track")
        }

        return self
    }

    func setOverlayPart(offsetTime: Float64) throws -> Montage {
//        func setOverlayPart(startTime: Float64, endTime: Float64) throws -> Montage {
        let startTime: Float64 = 0
        let endTime: Float64 = CMTimeGetSeconds(overlayVideoTrack!.asset!.duration)
        overlayPart.audioMutableCompositionTrack = mutableMixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
        overlayPart.videoMutableCompositionTrack = mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//        let emptyFrames = mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

        do {
            let timeRange = CMTimeRangeMake(
                start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
            )
            let atTime = CMTimeMakeWithSeconds(offsetTime, preferredTimescale: preferredTimescale)

            try overlayPart.videoMutableCompositionTrack?.insertTimeRange(
                timeRange,
                of: overlayVideoTrack!,
                at: atTime)

            try overlayPart.audioMutableCompositionTrack?.insertTimeRange(
                timeRange,
                of: overlayAudioTrack!,
                at: atTime)


            overlayPart.layerInstruction = compositionLayerInstruction(for: overlayPart.videoMutableCompositionTrack!, asset: overlayVideoSource!)
            overlayPart.layerInstruction?.setOpacity(0, at: CMTimeMakeWithSeconds(offsetTime + endTime, preferredTimescale: self.preferredTimescale))
        } catch {
            print("Failed to load main track")
        }

        return self
    }

    func calcCorrectRect(rect: CGRect, screenSize: CGSize) -> CGRect {
        let secondDot = CGPoint(x: rect.minX + rect.width, y: rect.minY)
        //print("second dot", secondDot)

        return CGRect(x: secondDot.y, y: screenSize.width - secondDot.x, width: rect.height, height: rect.width)
    }

    func getCorrectSourceSize() -> CGSize {
        var size = bottomVideoTrack!.naturalSize
        //print("getCorrectSourceSize", size)
        if size.width > size.height {
            size = CGSize(width: size.height, height: size.width)
        }

        return size
    }

    func cropTopPart(rect: CGRect) -> Montage {
        // todo how to optimize it? here crop before transformation for iPhone recorded videos
        var correctRect = rect
        let correctSize = getCorrectSourceSize();
        if correctSize.width != bottomVideoTrack!.naturalSize.width {
            correctRect = calcCorrectRect(rect: rect, screenSize: correctSize)
        }

        bottomPart.layerInstruction!.setCropRectangle(correctRect, at: .zero)

        return self
    }

    func prepareComposition() -> Montage {
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: bottomVideoSource!.duration)

        // SECOND LAYER DRAWS BEFORE FIRST
        mainInstruction.layerInstructions = []

        if (self.overlayPart.layerInstruction !== nil) {
            mainInstruction.layerInstructions.append(self.overlayPart.layerInstruction!)
        }

        if (self.topPart.layerInstruction !== nil) {
            mainInstruction.layerInstructions.append(topPart.layerInstruction!)
        }

        if (self.bottomPart.layerInstruction !== nil) {
            mainInstruction.layerInstructions.append(bottomPart.layerInstruction!)
        }

        self.videoComposition = AVMutableVideoComposition()
        self.videoComposition.instructions = [mainInstruction]
        self.videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

        let videoInfo = orientation(from: bottomVideoTrack!.preferredTransform)
        let videoSize: CGSize
        if videoInfo.isPortrait {
            videoSize = CGSize(width: bottomVideoTrack!.naturalSize.height, height: bottomVideoTrack!.naturalSize.width)
        } else {
            videoSize = bottomVideoTrack!.naturalSize
        }

        self.videoComposition.renderSize = videoSize

        return self
    }

    func getAVPlayerItem() -> AVPlayerItem {
        _ = self.prepareComposition()
        let item = AVPlayerItem(asset: self.mutableMixComposition)
        item.videoComposition = self.videoComposition

        return item
    }

    func saveToFile(completion: @escaping (URL) -> Void, error: @escaping (String) -> Void) {
        _ = prepareComposition()

        // 3 - Audio track
        /*if let loadedAudioAsset = audioAsset {
         let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
         do {
         try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: CMTimeAdd(firstAsset.duration, secondAsset.duration)),
         of: loadedAudioAsset.tracks(withMediaType: .audio)[0] ,
         at: CMTime.zero)
         } catch {
         print("Failed to load Audio track")
         }
         }*/

        // 4 - Get path
//        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            return
//        }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .short
//        let date = dateFormatter.string(from: Date())
//        let url = documentDirectory.appendingPathComponent("merged-video-\(date)-\(Int.random(in: 1...100000)).mov")
//
//        // 5 - Create Exporter
//        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
//            return
//        }
//        exporter.outputURL = url
//        print("output", url)
//        exporter.outputFileType = AVFileType.mov
//        exporter.shouldOptimizeForNetworkUse = true
//        exporter.videoComposition = videoComposition
//
//        // 6 - Perform the Export
//        exporter.exportAsynchronously() {
//            DispatchQueue.main.async {
//                //self.exportDidFinish(exporter)
//                completion()
//            }
//        }
//      self.saveAnyToFile(mixComposition: self.mixComposition, completion: {result in
//        DispatchQueue.main.async {
//            completion(result)
//        }
//
//            }, error:{result in
//
//                DispatchQueue.main.async {
//                    error(result)
//                }
//            })
        self.saveAnyToFile(
            mixComposition: self.mutableMixComposition,
            completion: { result in
                completion(result)
            },
            error: { result in
                error(result)
            })

    }

    func saveAnyToFile(mixComposition: AVAsset, completion: @escaping (URL) -> Void, error: @escaping (String) -> Void) {
        // 4 - Get path
        //guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        //return}
        let documentDirectory = FileManager.default.temporaryDirectory

        print("Montage documentDirectory \(documentDirectory)")
        let name = DownloadTestContent.generateFileName(mainName: "Zoomerok", nameExtension: "mov")
        let url = documentDirectory.appendingPathComponent(name)

        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }

        exporter.outputURL = url
        print("Montage output url \(url)")
        exporter.outputFileType = .mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComposition

        // 6 - Perform the Export
        exporter.exportAsynchronously() {
            //print("Export error \(exporter.error)")
            if exporter.error != nil {
                DispatchQueue.main.async {
                    error(String(describing: exporter.error))
                }
            } else {
                DispatchQueue.main.async {
                    completion(url)
                }
            }
        }
    }

    private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }

        return (assetOrientation, isPortrait)
    }

    private func compositionLayerInstruction(for compositionTrack: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let assetTrack = asset.tracks(withMediaType: .video)[0]
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
        instruction.setTransform(assetTrack.preferredTransform, at: .zero)

        return instruction
    }
}
