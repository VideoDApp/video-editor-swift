import Foundation
import AVKit
import Photos

enum MontageError: Error {
    case sourceIsEmpty
    case backgroundPartIsEmpty
    case mainPartIsEmpty
    case some
}

class VideoPart {
    var track: AVMutableCompositionTrack?
    var layerInstruction: AVMutableVideoCompositionLayerInstruction?
}

class Montage {
    let preferredTimescale: Int32 = 600
    
    var sourceVideo: AVAsset?
    var sourceTrack: AVAssetTrack?
    var sourcePart = VideoPart()
    var topPart = VideoPart()
    var bottomPart = VideoPart()
    var overlayPart = VideoPart()
    var mixComposition = AVMutableComposition()
    var videoComposition = AVMutableVideoComposition()

    init() {

    }

    func overlayTwoVideos(urlBottom: URL, urlTop: URL) throws {
        let bottomVideo = AVAsset(url: urlBottom)
        //let topVideo = AVAsset(url: urlTop)

        let startTime: Float64 = 3
        let endTime: Float64 = 8

        let overlayMixComposition = AVMutableComposition()
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: bottomVideo.duration)

        //        self.sourcePart.layerInstruction = compositionLayerInstruction(for: self.sourcePart.track!, asset: self.sourceVideo!)
        let track = overlayMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        let bottomInstructions = compositionLayerInstruction(for: track!, asset: bottomVideo)

        try track!.insertTimeRange(
                CMTimeRangeMake(
                        start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                        duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
                ),
                of: track!,
                at: CMTime.zero)
        bottomPart.layerInstruction = compositionLayerInstruction(for: track!, asset: bottomVideo)

        // 2.3
        // SECOND LAYER DRAWS BEFORE FIRST
        // here I can reorder drawing. drawing here from end to start
        mainInstruction.layerInstructions = [
            bottomInstructions
        ]

        let overlayVideoComposition = AVMutableVideoComposition()
        overlayVideoComposition.instructions = [mainInstruction]
        overlayVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

        let videoInfo = orientation(from: track!.preferredTransform)
        print("track!.naturalSize", track!.naturalSize)
        print("videoInfo", videoInfo)
        let videoSize: CGSize
        if videoInfo.isPortrait {
            videoSize = CGSize(width: track!.naturalSize.height, height: track!.naturalSize.width)
        } else {
            videoSize = track!.naturalSize
        }

        print("videoSize", videoSize)
        overlayVideoComposition.renderSize = videoSize

        try self.saveAnyToFile(mixComposition: overlayMixComposition) {
            print("overlayTwoVideos complete")
        }
    }

    func reset() {
        sourceVideo = nil
        sourceTrack = nil
        topPart = VideoPart()
        bottomPart = VideoPart()
        mixComposition = AVMutableComposition()
    }

    func setVideoSource(url: URL) -> Montage {
        reset()
        self.sourceVideo = AVAsset(url: url)
        self.sourceTrack = self.sourceVideo!.tracks(withMediaType: .video)[0]
        self.sourcePart.track = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        self.sourcePart.layerInstruction = compositionLayerInstruction(for: self.sourcePart.track!, asset: self.sourceVideo!)

        return self
    }

    func setTopPart(startTime: Float64, endTime: Float64) throws -> Montage {
        topPart.track = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try
            topPart.track?.insertTimeRange(
                    CMTimeRangeMake(
                            start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                            duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
                    ),
                    of: sourceTrack!,
                    at: CMTime.zero)
            topPart.layerInstruction = compositionLayerInstruction(for: topPart.track!, asset: sourceVideo!)
        } catch {
            print("Failed to load top track")
            //return
        }

        return self
    }

    func setBottomPart(startTime: Float64, endTime: Float64) throws -> Montage {
        bottomPart.track = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try
            bottomPart.track?.insertTimeRange(
                    CMTimeRangeMake(
                            start: CMTimeMakeWithSeconds(startTime, preferredTimescale: preferredTimescale),
                            duration: CMTimeMakeWithSeconds(endTime - startTime, preferredTimescale: preferredTimescale)
                    ),
                    of: sourceTrack!,
                    at: CMTime.zero)
            bottomPart.layerInstruction = compositionLayerInstruction(for: bottomPart.track!, asset: sourceVideo!)
        } catch {
            print("Failed to load main track")
            //return
        }

        return self
    }

    /*func setOverlayVideo(url: URL) -> Montage {
        let video: AVAsset = AVAsset(url: url)
        //sourceTrack = video!.tracks(withMediaType: .video)[0]
        let overlayMixComposition = AVMutableComposition()
        self.overlayPart.track = overlayMixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        self.overlayPart.layerInstruction = self.compositionLayerInstruction(for: overlayPart.track!, asset: video)

        return self
    }*/

    func calcCorrectRect(rect: CGRect, screenSize: CGSize) -> CGRect {
        let secondDot = CGPoint(x: rect.minX + rect.width, y: rect.minY)
        //print("second dot", secondDot)

        return CGRect(x: secondDot.y, y: screenSize.width - secondDot.x, width: rect.height, height: rect.width)
    }

    func getCorrectSourceSize() -> CGSize {
        var size = sourceTrack!.naturalSize
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
        if correctSize.width != sourceTrack!.naturalSize.width {
            correctRect = calcCorrectRect(rect: rect, screenSize: correctSize)
        }

        bottomPart.layerInstruction!.setCropRectangle(correctRect, at: .zero)

        return self
    }

    func prepareComposition() -> Montage {
        let mainInstruction = AVMutableVideoCompositionInstruction()
        //mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeAdd(sourceVideo!.duration, sourceVideo!.duration))
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: sourceVideo!.duration)

        // 2.3
        // SECOND LAYER DRAWS BEFORE FIRST
        // here I can reorder drawing. drawing here from end to start
        mainInstruction.layerInstructions = [
            /*bottomPart.layerInstruction!,
            topPart.layerInstruction!*/
        ]

        if (bottomPart.layerInstruction !== nil) {
            mainInstruction.layerInstructions.append(bottomPart.layerInstruction!)
        }

        if (topPart.layerInstruction !== nil) {
            mainInstruction.layerInstructions.append(topPart.layerInstruction!)
        }

        /*if (self.overlayPart.layerInstruction !== nil) {
            mainInstruction.layerInstructions.append(self.overlayPart.layerInstruction!)
        }*/
        /*if (bottomPart.layerInstruction !== nil) {
            mainInstruction.layerInstructions.append(bottomPart.layerInstruction!)
        }*/

        self.videoComposition = AVMutableVideoComposition()
        self.videoComposition.instructions = [mainInstruction]
        self.videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

        let videoInfo = orientation(from: sourceTrack!.preferredTransform)
        let videoSize: CGSize
        if videoInfo.isPortrait {
            videoSize = CGSize(width: sourceTrack!.naturalSize.height, height: sourceTrack!.naturalSize.width)
        } else {
            videoSize = sourceTrack!.naturalSize
        }

        self.videoComposition.renderSize = videoSize

        return self
    }

    func getAVPlayerItem() -> AVPlayerItem {
        _ = self.prepareComposition()
        let item = AVPlayerItem(asset: self.mixComposition)
        item.videoComposition = self.videoComposition

        return item
    }

    func saveToFile(completion: @escaping () -> Void) throws {
        _ = prepareComposition()
/*
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
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("merged-video-\(date)-\(Int.random(in: 1...100000)).mov")

        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        exporter.outputURL = url
        print("output", url)
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComposition

        // 6 - Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                //self.exportDidFinish(exporter)
                completion()
            }
        }*/
        do {
            try self.saveAnyToFile(mixComposition: self.mixComposition) {
                completion()
            }
        } catch {
            // todo call error callback
        }
    }

    func saveAnyToFile(mixComposition: AVAsset, completion: @escaping () -> Void) throws {
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
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("merged-video-\(date)-\(Int.random(in: 1...100000)).mov")

        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        exporter.outputURL = url
        print("output", url)
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComposition

        // 6 - Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                //self.exportDidFinish(exporter)
                completion()
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
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
        instruction.setTransform(assetTrack.preferredTransform, at: .zero)

        return instruction
    }
}
