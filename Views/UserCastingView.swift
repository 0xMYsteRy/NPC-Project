//
//  UserCastingView.swift
//  NPC
//
//  Created by Nguyen Huynh Phuong Anh on 13/09/2022.
//

import SwiftUI

struct UserCastingView: View {
    
    @ObservedObject var uploadViewModel = UploadViewModel()
    @ObservedObject var userSettings = UserSettings()
    @State private var episode = Episodes(audio: "", audio_length: 0, description: "", episode_uuid: "", podcast_uuid: "", pub_date: "", title: "", image: "", user_id: "", isLiked: false)
    @State private var upload = Uploads(title: "", description: "", audioPath: "", author: "", pub_date: "", image: "", userID: "", numOfLikes: 0, audio_length: 0, userImage: "", likes: [], comments: [])
    @State var download = Downloads(audio: "", title: "", isProcessing: false)
    @State var isTapped = false
    
    var body: some View {
        
        ScrollView {
            VStack {
                ForEach(self.$uploadViewModel.uploads, id: \.id) { $upload in
                    UserUploadComponent(upload: $upload)
                        .onTapGesture {
                            upload.isTapped.toggle()
                        }
                        .onChange(of: upload.isTapped) { value in
                            if value {
                                self.upload = upload
                                self.isTapped.toggle()
                            }
                        }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                self.uploadViewModel.fetchUploadsByUserId()
            }
        }
        .sheet(isPresented: self.$isTapped) {
            StreamingView(episode: self.$episode, upload: self.$upload, download: self.$download, state: 1)
        }
    }
}

struct UserCastingView_Previews: PreviewProvider {
    static var previews: some View {
        UserCastingView()
    }
}
