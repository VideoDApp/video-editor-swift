import Foundation

enum OverlayDataResult {
    case RESULT_OK,
         ERROR_EMPTY_BOTTOM_URL,
         ERROR_EMPTY_TOP_URL,
         ERROR_BOTTOM_VIDEO_LENGTH,
         ERROR_TOP_VIDEO_POSITION,
         ERROR_TOP_VIDEO_LENGTH
}

class OverlayData {
    public var bottomVideoUrl: URL? = nil
    public var topVideoUrl: URL? = nil

    public var isMuteBottom: Bool = false

    // start and end from bottom video
    public var bottomTimeStart: Float64 = 0
    public var bottomTimeEnd: Float64 = 0

    // position from result video
    public var topTimePosition: Float64 = 0
    // start and end from top video
    public var topTimeStart: Float64 = 0
    public var topTimeEnd: Float64 = 0

    func isValid() -> OverlayDataResult {
        printAll()
        if bottomVideoUrl == nil {
            return .ERROR_EMPTY_BOTTOM_URL
        }

        if topVideoUrl == nil {
            return .ERROR_EMPTY_TOP_URL
        }

        if bottomTimeEnd - bottomTimeStart < 1 {
            return .ERROR_BOTTOM_VIDEO_LENGTH
        }

        if topTimePosition > (bottomTimeEnd - bottomTimeStart) {
            return .ERROR_TOP_VIDEO_POSITION
        }

        if topTimeEnd - topTimeStart <= 0 {
            return .ERROR_TOP_VIDEO_LENGTH
        }

        return .RESULT_OK
    }

    func printAll() {
        print("bottomVideoUrl", bottomVideoUrl!)
        print("bottomVideoUrl", topVideoUrl!)
        print("isMuteBottom", isMuteBottom)
        print("bottomTimeStart", bottomTimeStart)
        print("bottomTimeEnd", bottomTimeEnd)
        print("topTimePosition", topTimePosition)
        print("topTimeStart", topTimeStart)
        print("topTimeEnd", topTimeEnd)
    }
}
