Instruction for testing

Test video stored in Document/test-files directory of app. To get Document directory call method DownloadTestContent.getDocumentsDirectory()

test-files possibly to connect with symlink

ZOOMEROK_PATH=/Users/sdancer/Library/Developer/CoreSimulator/Devices/ABB4F505-506D-4C39-AE6C-216BDFDFCC7B/data/Containers/Data/Application/56110246-E1B6-481A-811C-CE4AD1D45346/Documents/ &&
ZOOMEROK_PATH_FROM="${ZOOMEROK_PATH}ZoomerokContent" &&
ZOOMEROK_PATH_DEST="${ZOOMEROK_PATH}test-files" &&
ln -s /Users/sdancer/ZoomerokContent/ $ZOOMEROK_PATH &&
mv $ZOOMEROK_PATH_FROM $ZOOMEROK_PATH_DEST

Instruction for video creation for app

...
