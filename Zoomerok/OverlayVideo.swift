import Foundation
import AVKit

enum OverlayError: Error {
    case runtimeError(String)
}

extension Float64 {
    func toCMTime() -> CMTime {
        // todo preferredTimescale is 600? default timescale in big bottom video is 600. or receive scale each video?
        //CMTimeMakeWithSeconds(self, preferredTimescale: 1000)
        CMTimeMakeWithSeconds(self, preferredTimescale: 600)
    }
}

class OverlayVideo {
    func overlayTwoVideos(_ data: OverlayData, completion: @escaping () -> Void) throws {
        let dataResult = data.isValid()
        if dataResult != .RESULT_OK {
            throw OverlayError.runtimeError("Invalid overlay data. \(dataResult)")
        }

        let bottomDuration = (data.bottomTimeEnd - data.bottomTimeStart).toCMTime()
        let topDuration = (data.topTimeEnd - data.topTimeStart).toCMTime()
        let topEndTime = (data.topTimePosition + data.topTimeEnd - data.topTimeStart).toCMTime()
        print("bottomDuration", bottomDuration)
        print("topDuration", topDuration)
        print("topEndTime", topEndTime)

        let bottomVideo = AVAsset(url: data.bottomVideoUrl!)
        let topVideo = AVAsset(url: data.topVideoUrl!)
        let mixComposition = AVMutableComposition()
        let mainInstruction = AVMutableVideoCompositionInstruction()
        // todo check this version. big video not saved with this configuration. How to catch and fix this error?
        print("duration", bottomDuration, bottomVideo.duration)
        mainInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: bottomDuration)

        let bottomAssetTrack = bottomVideo.tracks(withMediaType: AVMediaType.video)[0]
        let topAssetTrack = topVideo.tracks(withMediaType: AVMediaType.video)[0]
        let bottomFPS = bottomAssetTrack.nominalFrameRate
        print("fps", bottomFPS)

        let videoSize = getVideoSizeByAsset(assetTrack: bottomAssetTrack)
        let bottomMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let bottomInstructions = compositionLayerInstruction(for: bottomMutableCompositionTrack!, asset: bottomVideo)

        // todo video in the end - black screen. in original video - last frame (only for small video)
        try bottomMutableCompositionTrack!.insertTimeRange(
                CMTimeRangeMake(
                        start: data.bottomTimeStart.toCMTime(),
                        duration: bottomDuration
                ),
                of: bottomAssetTrack,
                at: .zero)

        let topMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let topInstructions = compositionLayerInstruction(for: topMutableCompositionTrack!, asset: topVideo)

        let coefficient: CGFloat = getScaleCoefficient(mainWidth: videoSize.width, scalableWidth: topAssetTrack.naturalSize.width)
        let transform = CGAffineTransform.init(scaleX: coefficient, y: coefficient)
        topInstructions.setTransform(transform, at: .zero)
        // hide video after play because last frame freeze
        topInstructions.setOpacity(0, at: topEndTime)

        try topMutableCompositionTrack!.insertTimeRange(
                CMTimeRangeMake(
                        start: data.topTimeStart.toCMTime(),
                        duration: topDuration
                ),
                of: topAssetTrack,
                at: data.topTimePosition.toCMTime())

        if data.isMuteBottom == false {
            insertAudio(video: bottomVideo, mixComposition: mixComposition, at: .zero, duration: bottomDuration)
        }

        insertAudio(video: topVideo, mixComposition: mixComposition, at: data.topTimePosition.toCMTime(), duration: topDuration)

        // SECOND LAYER DRAWS BEFORE FIRST
        // here I can reorder drawing. drawing here from end to start
        mainInstruction.layerInstructions = [
            topInstructions,
            bottomInstructions
        ]

        let overlayVideoComposition = AVMutableVideoComposition()
        overlayVideoComposition.instructions = [mainInstruction]
        overlayVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: Int32(bottomFPS))

        overlayVideoComposition.renderSize = videoSize
        try self.saveAnyToFile(
                mixComposition: mixComposition,
                mainInstruction: mainInstruction,
                videoComposition: overlayVideoComposition) {
            print("overlayTwoVideos complete")
            completion()
        }
    }

    private func getVideoSizeByAsset(assetTrack: AVAssetTrack) -> CGSize {
        let videoInfo = orientation(from: assetTrack.preferredTransform)
        let videoSize: CGSize
        if videoInfo.isPortrait {
            videoSize = CGSize(width: assetTrack.naturalSize.height, height: assetTrack.naturalSize.width)
        } else {
            videoSize = assetTrack.naturalSize
        }

        return videoSize
    }

    private func insertAudio(video: AVAsset, mixComposition: AVMutableComposition, at: CMTime, duration: CMTime) {
        if video.tracks(withMediaType: .audio).count == 0 {
            print("bottomVideo audio not found")
        } else {
            let audioTrackBottom = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
            do {
                try audioTrackBottom?.insertTimeRange(
                        CMTimeRangeMake(start: CMTime.zero, duration: duration),
                        of: video.tracks(withMediaType: .audio)[0],
                        at: at)
            } catch {
                print("Failed to load Audio track")
            }
        }
    }

    private func getScaleCoefficient(mainWidth: CGFloat, scalableWidth: CGFloat) -> CGFloat {
        mainWidth / scalableWidth
    }

    private func compositionLayerInstruction(for compositionTrack: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionTrack)
        instruction.setTransform(assetTrack.preferredTransform, at: .zero)

        return instruction
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

    func saveAnyToFile(mixComposition: AVAsset,
                       mainInstruction: AVMutableVideoCompositionInstruction,
                       videoComposition: AVMutableVideoComposition,
                       completion: @escaping () -> Void) throws {

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
            print("Can not export video")
            return
        }

        exporter.outputURL = url
        print("output", url)
        exporter.outputFileType = .mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComposition

        // 6 - Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                //self.exportDidFinish(exporter)
                print("exporter.status", exporter.status)
                print("exporter.error", exporter.error)
                completion()
            }
        }
    }

    func getAssetDuration(_ url: URL) -> CMTime {
        AVAsset(url: url).duration
    }
}
