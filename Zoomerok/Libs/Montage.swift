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
    case requiredBottomPart
    case failedLoadTrack
}

public class VideoPart {
    var videoMutableCompositionTrack: AVMutableCompositionTrack?
    var audioMutableCompositionTrack: AVMutableCompositionTrack?
    var layerInstruction: AVMutableVideoCompositionLayerInstruction?
    var tracks: [AVMutableCompositionTrack]?
}

public class Montage {
    let preferredTimescale: Int32 = 600

    var realBottomVideoDuration: Float64 = 0

    var bottomVideoSource: AVAsset?
    var bottomVideoTrack: AVAssetTrack?
    var bottomAudioTrack: AVAssetTrack?

    var overlayVideoSource: AVAsset?
    var overlayVideoTrack: AVAssetTrack?
    var overlayAudioTrack: AVAssetTrack?

    var watermarkVideoSource: AVAsset?
    var watermarkVideoTrack: AVAssetTrack?

    var sourcePart = VideoPart()
    var topPart = VideoPart()
    var bottomPart = VideoPart()
    var overlayPart = VideoPart()
    var watermarkPart = VideoPart()
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
        self.bottomVideoSource = nil
        self.bottomVideoTrack = nil
        self.bottomAudioTrack = nil

        self.overlayVideoSource = nil
        self.overlayVideoTrack = nil
        self.overlayAudioTrack = nil

        self.watermarkVideoSource = nil
        self.watermarkVideoTrack = nil

        self.topPart = VideoPart()
        self.bottomPart = VideoPart()
        self.overlayPart = VideoPart()
        self.watermarkPart = VideoPart()
        self.mutableMixComposition = AVMutableComposition()
    }

    func setBottomVideoSource(url: URL) throws -> Montage {
        if !FileManager.default.fileExists(atPath: url.path) {
            throw MontageError.fileNotFound
        }

        self.reset()
        self.bottomVideoSource = AVAsset(url: url)
        self.bottomVideoTrack = self.bottomVideoSource!.tracks(withMediaType: .video)[0]
        self.bottomAudioTrack = self.bottomVideoSource!.tracks(withMediaType: .audio)[0]
        //self.sourcePart.videoMutableCompositionTrack = mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        //self.sourcePart.layerInstruction = compositionLayerInstruction(for: self.sourcePart.videoMutableCompositionTrack!, asset: self.bottomVideoSource!)

        return self
    }

    func setOverlayVideoSource(url: URL) throws -> Montage {
        if self.bottomVideoSource == nil {
            throw MontageError.requiredBottomPart
        }

        if !FileManager.default.fileExists(atPath: url.path) {
            throw MontageError.fileNotFound
        }

        self.overlayVideoSource = AVAsset(url: url)
        self.overlayVideoTrack = self.overlayVideoSource!.tracks(withMediaType: .video)[0]
        self.overlayAudioTrack = self.overlayVideoSource!.tracks(withMediaType: .audio)[0]
        //let overlayMixComposition = AVMutableComposition()
        //self.overlayPart.videoMutableCompositionTrack = overlayMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        //self.overlayPart.audioMutableCompositionTrack = overlayMixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        //self.overlayPart.layerInstruction = self.compositionLayerInstruction(for: overlayPart.videoMutableCompositionTrack!, asset: self.overlayVideoSource!)

        return self
    }

    func setWatermark(url: URL) throws -> Montage {
        if !FileManager.default.fileExists(atPath: url.path) {
            throw MontageError.fileNotFound
        }

        self.watermarkVideoSource = AVAsset(url: url)
        self.watermarkVideoTrack = self.watermarkVideoSource!.tracks(withMediaType: .video)[0]

        if self.watermarkPart.tracks != nil {
            self.watermarkPart.tracks!.forEach { track in
                self.mutableMixComposition.removeTrack(track)
            }
        }

        let watermarkDuration = self.watermarkVideoTrack!.asset!.duration
        let videoMutableCompositionTrack = self.mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        self.watermarkPart.tracks = [videoMutableCompositionTrack!]

        do {
            // watermark length equal of real bottom video duration
            let timeRange = CMTimeRangeMake(
                start: .zero,
                //duration: CMTimeMakeWithSeconds(self.realBottomVideoDuration, preferredTimescale: preferredTimescale)
                duration: watermarkDuration
            )
            try videoMutableCompositionTrack?.insertTimeRange(
                timeRange,
                of: self.watermarkVideoTrack!,
                at: .zero)

//            try videoMutableCompositionTrack?.insertTimeRange(
//                timeRange,
//                of: self.watermarkVideoTrack!,
//                at: watermarkDuration)

            self.watermarkPart.layerInstruction = self.compositionLayerInstruction(for: videoMutableCompositionTrack!, asset: self.watermarkVideoSource!)
            let maxWidth = self.getVideoSize(self.bottomVideoTrack!).width / 3
            let margins = maxWidth / 9
            let coeff = maxWidth / self.getVideoSize(videoMutableCompositionTrack!).width
            var transform = videoMutableCompositionTrack!.preferredTransform.scaledBy(x: coeff, y: coeff)
            transform.tx = margins
            transform.ty = margins
            self.watermarkPart.layerInstruction!.setTransform(transform, at: .zero)

        } catch {
            throw MontageError.failedLoadTrack
        }

        return self
    }

    func removeWatermark() {
        self.watermarkVideoSource = nil
        self.watermarkVideoTrack = nil
        self.watermarkPart = VideoPart()
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
        // todo remove bottomPart.audioMutableCompositionTrack and bottomPart.videoMutableCompositionTrack everywhere?
        if self.bottomPart.tracks != nil {
            self.bottomPart.tracks!.forEach { track in
                self.mutableMixComposition.removeTrack(track)
            }
        }

        // Int32(kCMPersistentTrackID_Invalid)
        let videoMutableCompositionTrack = self.mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        let audioMutableCompositionTrack = self.mutableMixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        self.bottomPart.tracks = [videoMutableCompositionTrack!, audioMutableCompositionTrack!]

        do {
            let timeRange = CMTimeRangeMake(
                start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
            )
            self.realBottomVideoDuration = endTime - startTime
            try videoMutableCompositionTrack?.insertTimeRange(
                timeRange,
                of: self.bottomVideoTrack!,
                at: .zero)

            try audioMutableCompositionTrack?.insertTimeRange(
                timeRange,
                of: self.bottomAudioTrack!,
                at: .zero)

            self.bottomPart.layerInstruction = self.compositionLayerInstruction(for: videoMutableCompositionTrack!, asset: self.bottomVideoSource!)
        } catch {
            print("Failed to load main track")
        }

        return self
    }

    func setOverlayPart(offsetTime: Float64) throws -> Montage {
//        func setOverlayPart(startTime: Float64, endTime: Float64) throws -> Montage {
        let startTime: Float64 = 0
        let endTime: Float64 = CMTimeGetSeconds(overlayVideoTrack!.asset!.duration)

        if self.overlayPart.tracks != nil {
            self.overlayPart.tracks!.forEach { track in
                self.mutableMixComposition.removeTrack(track)
            }
        }

        let videoMutableCompositionTrack = self.mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        let audioMutableCompositionTrack = self.mutableMixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        self.overlayPart.tracks = [videoMutableCompositionTrack!, audioMutableCompositionTrack!]

        do {
            let timeRange = CMTimeRangeMake(
                start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
            )
            let atTime = CMTimeMakeWithSeconds(offsetTime, preferredTimescale: preferredTimescale)

//            try self.overlayPart.videoMutableCompositionTrack?.insertTimeRange(
            try videoMutableCompositionTrack?.insertTimeRange(
                timeRange,
                of: overlayVideoTrack!,
                at: atTime)

//            try self.overlayPart.audioMutableCompositionTrack?.insertTimeRange(
            try audioMutableCompositionTrack?.insertTimeRange(
                timeRange,
                of: overlayAudioTrack!,
                at: atTime)


            self.overlayPart.layerInstruction = self.compositionLayerInstruction(for: videoMutableCompositionTrack!, asset: self.overlayVideoSource!)
            // optmize overlay to bottom video
            let coeff = self.getVideoSize(self.bottomVideoTrack!).width / self.getVideoSize(videoMutableCompositionTrack!).width
            self.overlayPart.layerInstruction?.setTransform(videoMutableCompositionTrack!.preferredTransform.scaledBy(x: coeff, y: coeff), at: .zero)
            // hide last freezed frame
            self.overlayPart.layerInstruction?.setOpacity(0, at: CMTimeMakeWithSeconds(offsetTime + endTime, preferredTimescale: self.preferredTimescale))
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

    func showMixTracks(mix: AVMutableComposition) {
        print("Mix tracks: \(mix.tracks.count)")
        mix.tracks.forEach({ item in
            print("Mix track: \(item.description) \(item.timeRange)")
        })
    }

    func testInstruction() -> AVMutableVideoCompositionLayerInstruction {
//        let audioMutableCompositionTrack = self.mutableMixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
//        let videoMutableCompositionTrack = self.mutableMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//
//        //self.bottomPart.tracks = [audioMutableCompositionTrack!, videoMutableCompositionTrack!]
//        self.showMixTracks(mix: self.mutableMixComposition)
//        let assetDuration = self.bottomVideoSource!.duration.seconds
////        let assetDuration = CMTimeMakeWithSeconds(3, preferredTimescale: preferredTimescale)
//
//        do {
//            try videoMutableCompositionTrack?.insertTimeRange(
//                CMTimeRangeMake(
//                    start: .zero,
//                    duration: CMTimeMakeWithSeconds(assetDuration, preferredTimescale: preferredTimescale)
////                    duration: assetDuration
//                ),
//                of: self.bottomVideoTrack!,
//                at: CMTime.zero)
//
//            try audioMutableCompositionTrack?.insertTimeRange(
//                CMTimeRangeMake(
//                    start: .zero,
//                    duration: CMTimeMakeWithSeconds(assetDuration, preferredTimescale: preferredTimescale)
////                    duration: assetDuration
//                ),
//                of: self.bottomAudioTrack!,
//                at: CMTime.zero)
//        } catch {
//            print("testInstruction error \(error)")
//        }

//        let assetTrack = self.bottomVideoSource!.tracks(withMediaType: .video)[0]
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: self.bottomVideoTrack!)
//        instruction.setTransform(assetTrack.preferredTransform, at: .zero)

        //return self.compositionLayerInstruction(for: videoMutableCompositionTrack!, asset: self.bottomVideoSource!)
        return instruction
    }

//    func getWatermarkInstruction() throws -> AVMutableVideoCompositionLayerInstruction {
//        if self.watermarkVideoTrack == nil {
//            throw MontageError.fileNotFound
//        }
//
//        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: self.watermarkVideoTrack!)
//        instruction.setTransform(self.watermarkVideoTrack!.preferredTransform, at: .zero)
//        // todo calculate position and proportions
//
//        return instruction
//    }

    func prepareComposition() -> Montage {
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: self.bottomVideoSource!.duration)

        //self.showMixTracks(mix: self.mutableMixComposition)
        // SECOND LAYER DRAWS BEFORE FIRST
        //mainInstruction.layerInstructions = []

//        let testInstruction = self.testInstruction()
//        mainInstruction.layerInstructions.append(testInstruction)
//        self.showMixTracks(mix: self.mutableMixComposition)


        [
            self.bottomPart.layerInstruction,
            self.overlayPart.layerInstruction,
            self.watermarkPart.layerInstruction
        ].reversed().forEach({ (item) in
            if item == nil {
                return
            }

            mainInstruction.layerInstructions.append(item!)
            print("Instruction \(item!.trackID)")
        })

        /*if self.watermarkPart.layerInstruction !== nil {
//            try? mainInstruction.layerInstructions.append(self.getWatermarkInstruction())
        }

        if self.overlayPart.layerInstruction !== nil {
            mainInstruction.layerInstructions.append(self.overlayPart.layerInstruction!)
        }
//
//        if (self.topPart.layerInstruction !== nil) {
//            mainInstruction.layerInstructions.append(self.topPart.layerInstruction!)
//        }
//

        if self.bottomPart.layerInstruction !== nil {
            mainInstruction.layerInstructions.append(self.bottomPart.layerInstruction!)
        }*/

        self.videoComposition = AVMutableVideoComposition()
        self.videoComposition.instructions = [mainInstruction]
        self.videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        self.videoComposition.renderSize = self.getVideoSize(self.bottomVideoTrack!)

        return self
    }

    private func getVideoSize(_ track: AVAssetTrack) -> CGSize {
        let videoInfo = self.orientation(from: track.preferredTransform)
        let videoSize: CGSize
        if videoInfo.isPortrait {
            videoSize = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
        } else {
            videoSize = track.naturalSize
        }

        return videoSize
    }

    func getAVPlayerItem() -> AVPlayerItem {
        _ = self.prepareComposition()
        let item = AVPlayerItem(asset: self.mutableMixComposition)
        item.videoComposition = self.videoComposition

        return item
    }

    func getPreparedComposition() -> AVMutableVideoComposition {
        _ = self.prepareComposition()

        return self.videoComposition
    }

    func saveToFile(completion: @escaping (URL) -> Void, error: @escaping (String) -> Void) {
        // todo merge this method with saveAnyToFile
        _ = prepareComposition()
        self.saveAnyToFile(
            mixComposition: self.mutableMixComposition,
            completion: { result in
                completion(result)
            },
            error: { result in
                error(result)
            })
    }

    func saveAnyToFile(mixComposition: AVMutableComposition, completion: @escaping (URL) -> Void, error: @escaping (String) -> Void) {
        //func saveAnyToFile(mixComposition: AVAsset, completion: @escaping (URL) -> Void, error: @escaping (String) -> Void) {
        let documentDirectory = FileManager.default.temporaryDirectory

        print("Montage documentDirectory \(documentDirectory)")
        let name = DownloadTestContent.generateFileName(mainName: "Zoomerok", nameExtension: "mov")
        let url = documentDirectory.appendingPathComponent(name)

        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }

        exporter.outputURL = url
        print("Montage output url \(url)")
        exporter.outputFileType = .mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = self.videoComposition

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
