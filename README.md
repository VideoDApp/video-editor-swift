Instruction for testing

Test video stored in Document/test-files directory of app. To get Document directory call method DownloadTestContent.getDocumentsDirectory()

test-files possibly to connect with symlink

ZOOMEROK_PATH=/Users/sdancer/Library/Developer/CoreSimulator/Devices/D222939F-76CB-4F6D-A244-6EAE367D74C1/data/Containers/Data/Application/5A6000D1-1AB3-4DFB-A296-8548189DF38F/Documents/ &&
ZOOMEROK_PATH_FROM="${ZOOMEROK_PATH}ZoomerokContent" &&
ZOOMEROK_PATH_DEST="${ZOOMEROK_PATH}test-files" &&
ln -s /Users/sdancer/ZoomerokContent/ $ZOOMEROK_PATH &&
mv $ZOOMEROK_PATH_FROM $ZOOMEROK_PATH_DEST

Instruction for app effect creation

Create video effects with Adobe After Effects and save ProRes 4444, then encode with default mac encoder (mouse right click by file and select Services->Encode Selected Video Files), then select HEVC 1080p (or H.264 720p), check Preserve Transparency

Effect size: 720x1280
Codec: HEVC 1080p (with or without alpha), in some cases H.264 720p
