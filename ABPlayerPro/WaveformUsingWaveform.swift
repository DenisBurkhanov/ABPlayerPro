//
//  WaveformUsingWaveform.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 12.03.2024.
//

import AVFoundation
import SwiftUI
import Waveform

class WaveformModel: ObservableObject {
	var samples: SampleBuffer
	
	
	
	var url: URL
	init(url: URL) {
		self.url = url
		let file = try? AVAudioFile(forReading: url)
		let stereo = file?.floatChannelData()!
	
		samples = SampleBuffer(samples: stereo?[0] ?? [0])
	}
}


