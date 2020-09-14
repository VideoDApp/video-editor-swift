Instruction for testing

Test video stored in Document/test-files directory of app. To get Document directory call method DownloadTestContent.getDocumentsDirectory()

test-files possibly to connect with symlink

ZOOMEROK_PATH=/Users/sdancer/Library/Developer/CoreSimulator/Devices/63A810EF-ED84-4CCE-9733-9D9E953B890E/data/Containers/Data/Application/664D478A-CB16-4B92-A953-1331000DE4CF/Documents/ &&
ZOOMEROK_PATH_FROM="${ZOOMEROK_PATH}ZoomerokContent" &&
ZOOMEROK_PATH_DEST="${ZOOMEROK_PATH}test-files" &&
ln -s /Users/sdancer/ZoomerokContent/ $ZOOMEROK_PATH &&
mv $ZOOMEROK_PATH_FROM $ZOOMEROK_PATH_DEST

Instruction for video creation for app

...
