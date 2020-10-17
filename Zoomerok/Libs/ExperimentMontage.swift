import AVKit

func testExport(documentsDirectoryURL: URL, url: URL, completion: @escaping (_ outputUrl: URL?, _ errorString: String?) -> ()) {
    let asset = AVAsset(url: url)
    print("URL IS \(url)")
    guard let avAssetTrack = asset.tracks(withMediaType: .video).first else {
        completion(nil, "Couldn't Create Asset Track")
        return
    }

    let mutableComposition = AVMutableComposition()
    
    guard let videoTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
    try? videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: avAssetTrack, at: .zero)
    videoTrack.preferredTransform = avAssetTrack.preferredTransform

    if let audioAssetTrack = asset.tracks(withMediaType: .audio).first {
        let audioTrack = mutableComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        try? audioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: audioAssetTrack, at: .zero)
    }

    let mainInstruction = AVMutableVideoCompositionInstruction()
    mainInstruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)

    let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

    // Fix video orientation
    var videoAssetOrientation = UIImage.Orientation.up
    var isVideoAssetPortrait = false
    let videoTransform = avAssetTrack.preferredTransform

    switch (videoTransform.a, videoTransform.b, videoTransform.c, videoTransform.c) {
    case (0, 1.0, -1.0, 0):
        videoAssetOrientation = .right
        isVideoAssetPortrait = true
    case(0, -1.0, 1.0, 0):
        videoAssetOrientation = .left
        isVideoAssetPortrait = true
    case(1.0, 0, 0, 1.0):
        videoAssetOrientation = .up
    case(-1.0, 0, 0, -1.0):
        videoAssetOrientation = .down
    default:
        break
    }

    var naturalSize = avAssetTrack.naturalSize
    switch (videoAssetOrientation, isVideoAssetPortrait) {
    case (.right, true):
        naturalSize = CGSize(width: avAssetTrack.naturalSize.height, height: avAssetTrack.naturalSize.width)
    case (.left, true):
        naturalSize = CGSize(width: avAssetTrack.naturalSize.height, height: avAssetTrack.naturalSize.width)
    case (.leftMirrored, true):
        naturalSize = CGSize(width: avAssetTrack.naturalSize.height, height: avAssetTrack.naturalSize.width)
    case (.rightMirrored, true):
        naturalSize = CGSize(width: avAssetTrack.naturalSize.height, height: avAssetTrack.naturalSize.width)
    default:
        break
    }

    videoLayerInstruction.setTransform(avAssetTrack.preferredTransform, at: .zero)
    videoLayerInstruction.setOpacity(0, at: asset.duration)
    print("asset.duration \(asset.duration)")

    mainInstruction.layerInstructions = [videoLayerInstruction]

    let mainCompositionInstruction = AVMutableVideoComposition()

    mainCompositionInstruction.renderSize = naturalSize
    mainCompositionInstruction.instructions = [mainInstruction]
    mainCompositionInstruction.frameDuration = CMTimeMake(value: 1, timescale: 30);

    //let documentsDirectoryURL = createPath()

    guard let exporter = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality) else {
        print("Couldnt create AVAssetExportSession")

        completion(nil, "Couldn't Create AVAssetExportSession")
        return
    }

    exporter.outputURL = documentsDirectoryURL
    exporter.outputFileType = .mov
    exporter.shouldOptimizeForNetworkUse = true
    exporter.videoComposition = mainCompositionInstruction

    exporter.exportAsynchronously {
        if let error = exporter.error {
            print(error)
            completion(nil, error.localizedDescription)
            return
        }

        completion(exporter.outputURL, nil)
        print("Finished Exporting")
    }
}
