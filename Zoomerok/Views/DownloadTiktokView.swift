import SwiftUI
import Firebase

struct DownloadTiktokView: View {
    @State var url: String = ""
//    @State var error: String = ""
    @State var status: String = ""
    @State var isScreenLocked: Bool = false

    var onCancel: () -> Void

    var body: some View {
        VStack {
            Text("Paste TikTok video URL\r\nand click Download")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()

            if self.status.count > 0 {
                Text(self.status)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
            }

            TextField("Enter TikTok URL", text: $url)
                .foregroundColor(.black)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disabled(self.isScreenLocked)

            Button("Download") {
                print("Download here")
                if self.isScreenLocked {
                    print("Screen locked")
                    return ()
                }
                
                Analytics.logEvent("z_tt_download", parameters: nil)
                self.status = "Receiving download URL..."
                self.isScreenLocked = true

                DownloadTestContent.downloadTiktok(self.url,
                    onUrlSuccess: {
                        self.status = "Downloading video to gallery..."
                        Analytics.logEvent("z_tt_download_url_success", parameters: nil)
                    },
                    onSuccess: {
                        self.isScreenLocked = false
                        self.status = "Video downloaded!"
                        self.url = ""
                        Analytics.logEvent("z_tt_download_complete", parameters: nil)
                    },
                    onError: { (error: String) in
                        self.status = error
                        self.isScreenLocked = false
                        Analytics.logEvent("z_tt_download_error", parameters: nil)
                    })
            }
            .disabled(self.url.count <= 3 || self.isScreenLocked)
            .padding()
            .foregroundColor(.white)

            Color.black.edgesIgnoringSafeArea(.all)
            Spacer()

            Button("Close") {
                self.onCancel()
            }
                .padding()
                .foregroundColor(.white)
        }
            .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct DownloadTiktokView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadTiktokView(onCancel: {

        })
    }
}
