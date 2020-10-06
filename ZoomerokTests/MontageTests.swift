import Foundation
import XCTest
import AVKit

@testable import Zoomerok

class MontageTest: XCTestCase {
//    func testAddOverlayVideo() {
//        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            return
//        }
//
//        let expectation = self.expectation(description: "testAddOverlayVideo")
//        //let fileBottom = Bundle.main.url(forResource: "small1", withExtension: "mov")!
//        //let fileBottom = Bundle.main.url(forResource: "TestVideo", withExtension: "mov")!
//        let fileBottom = documentDirectory.appendingPathComponent("sources/forspider.mov")
//        //let fileTop = Bundle.main.url(forResource: "small1", withExtension: "mov")!
//        //let fileTop = Bundle.main.url(forResource: "puppets_with_alpha_hevc", withExtension: "mov")!
//        let fileTop = Bundle.main.url(forResource: "spider_t", withExtension: "mov")!
//
//        do {
//            let overlayInstance = OverlayVideo()
//            let data = OverlayData()
//            data.topVideoUrl = fileTop
//            data.bottomVideoUrl = fileBottom
//            data.bottomTimeStart = 1.5
//            data.bottomTimeEnd = overlayInstance.getAssetDuration(fileBottom).seconds - 0.5
//            data.topTimePosition = 3.8
//            data.topTimeStart = 0
//            data.topTimeEnd = overlayInstance.getAssetDuration(fileTop).seconds
//            try overlayInstance.overlayTwoVideos(data, completion: {
//                expectation.fulfill()
//            })
//        } catch {
//            print("Failed to run \(error)")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 100, handler: nil)
//    }

//    func testSaveOriginalVideos() {
//        let expectation = self.expectation(description: "testSaveOriginalVideos")
//        let montage = Montage()
//        let fileUrl1 = Bundle.main.url(forResource: "small1", withExtension: "mov")!
//
//        do {
//            _ = montage.setVideoSource(url: fileUrl1)
//
//            try montage
//                .setBottomPart(startTime: 3, endTime: 11)
//                .saveToFile(completion: {
//                    expectation.fulfill()
//                })
//        } catch {
//            print("Failed to run")
//        }
//
//        waitForExpectations(timeout: 100, handler: nil)
//    }

//    func testCutSmallVideos() {
//        let expectation = self.expectation(description: "Scaling")
//        let montage = Montage()
//
//        let fileUrl1 = Bundle.main.url(forResource: "small1", withExtension: "mov")!
//
//        do {
//            _ = montage.setVideoSource(url: fileUrl1)
//            let size = montage.getCorrectSourceSize()
//            let rect = CGRect(x: (size.width / 2) + 50, y: 0, width: (size.width / 2) - 50, height: size.height)
//            let rectHalf = CGRect(x: (size.width / 2), y: 0, width: (size.width / 2), height: size.height)
//            try montage.setTopPart(startTime: 1, endTime: 3)
//                .setBottomPart(startTime: 3, endTime: 11)
//                .cropTopPart(rect: rect)
//                .saveToFile(completion: {
//                    //expectation.fulfill()
//                    do {
//                        try montage.cropTopPart(rect: rectHalf)
//                            .saveToFile(completion: {
//                                expectation.fulfill()
//                            })
//                    } catch {
//                        print("Failed to run 11")
//                    }
//                })
//
//
//            //expectation.fulfill()
//        } catch {
//            print("Failed to run")
//        }
//
//        waitForExpectations(timeout: 100, handler: nil)
//    }

//    func testCutBigVideos() {
//        let expectation = self.expectation(description: "Scaling")
//        let montage = Montage()
//        let fileUrl1 = Bundle.main.url(forResource: "TestVideo", withExtension: "mov")!
//        do {
//            _ = montage.setVideoSource(url: fileUrl1)
//
//            let size = montage.getCorrectSourceSize()
//            //assert(size.width != 1920)
//            print("size montage", size)
//
//            let rect = CGRect(x: (size.width / 2) + 250, y: 0, width: (size.width / 2) - 250, height: size.height)
//
//            try montage.setTopPart(startTime: 1, endTime: 3)
//                .setBottomPart(startTime: 3, endTime: 11)
//                .prepareComposition()
//                .cropTopPart(rect: rect)
//                .saveToFile(completion: {
//                    expectation.fulfill()
//                    /*do {
//                            try montage.cropMainPart(rect: rectHalf)
//                                .saveToFile(completion: {
//                                    expectation.fulfill()
//                                })
//                        } catch {
//                            print("Failed to run 11")
//                        }*/
//                })
//
//
//            //expectation.fulfill()
//        } catch {
//            print("Failed to run")
//        }
//
//        waitForExpectations(timeout: 100, handler: nil)
//    }

    func testCutSmallBottomVideo() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let url = documentDirectory.appendingPathComponent("test-files/2VideoBig.mov")
        print("MontageTest documentDirectory \(documentDirectory)")
        print("MontageTest url \(url)")
        let montage = Montage()
        let expectation = self.expectation(description: "testCutSmallBottomVideo")
        do {
            _ = try montage.setBottomVideoSource(url: url)
            try montage
            //.setTopPart(startTime: 0, endTime: 2)
            .setBottomPart(startTime: 0, endTime: 2)
            //.cropTopPart(rect: rect)
            .saveToFile(completion: { result in
                print("saveToFile OUT file \(result)")
                expectation.fulfill()
            }, error: { error in
                    print("saveToFile error \(error)")
                    XCTAssertTrue(false, "Error on save")
                    expectation.fulfill()
                })
        } catch {
            print("Failed to run \(error)")
            expectation.fulfill()
            XCTAssertTrue(false, "Something wrong")
        }

        waitForExpectations(timeout: 100, handler: nil)
    }

    func testOverlayVideo() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let url = documentDirectory.appendingPathComponent("test-files/2VideoBig.mov")
        let overlayUrl = documentDirectory.appendingPathComponent("test-files/transparent-spider.mov")
        print("MontageTest documentDirectory \(documentDirectory)")
        print("MontageTest url \(url)")
        let montage = Montage()
        let expectation = self.expectation(description: "testOverlayVideo")
        do {
            _ = try montage
                .setBottomVideoSource(url: url)
                .setOverlayVideoSource(url: overlayUrl)
                .setBottomPart(startTime: 0, endTime: 2)
                .setOverlayPart(offsetTime: 0)
                .saveToFile(
                    completion: { result in
                        print("saveToFile OUT file \(result)")
                        expectation.fulfill()
                    },
                    error: { error in
                        print("saveToFile error \(error)")
                        XCTAssertTrue(false, "Error on save")
                        expectation.fulfill()
                    })
        } catch {
            print("Failed to run \(error)")
            expectation.fulfill()
            XCTAssertTrue(false, "Something wrong")
        }

        waitForExpectations(timeout: 100, handler: nil)
    }
}
