//
//  silentMode.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 01.02.2024.
//
import AVFoundation

func configureAudioSession() {
	do {
		let audioSession = AVAudioSession.sharedInstance()
		try audioSession.setCategory(.playback)
		try audioSession.setActive(true)
	} catch {
		print("Error configuring audio session: \(error.localizedDescription)")
	}
}



