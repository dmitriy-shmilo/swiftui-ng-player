//
//  NGPlayerApp.swift
//  NGPlayer
//
//  Created by Dmitriy Shmilo on 17.09.2021.
//

import SwiftUI
import AVKit

@main
struct NGPlayerApp: App {

	init() {
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(.playback, mode: .default, options: [])
		} catch {
			print("Failed to set audio session category.")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			RootView()
		}
	}
}


extension UIApplication {
	var keyWindow: UIWindow? {
		connectedScenes
			.compactMap {
				$0 as? UIWindowScene
			}
			.flatMap {
				$0.windows
			}
			.first {
				$0.isKeyWindow
			}
	}
}
