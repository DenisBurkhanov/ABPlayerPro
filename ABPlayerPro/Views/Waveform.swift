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

struct WaveformView: View {
	var samples: SampleBuffer
	var body: some View {
		GeometryReader { geo in
			
			if samples.count > 0 {
				Waveform(samples: samples)
					.foregroundColor(.white)
					.frame(width: geo.size.width, height: (geo.size.height * 2))
				
					.mask(
						Rectangle()
							.frame(height: geo.size.height)
							.offset(x: 0, y: -(geo.size.height / 2))
					)
			}
		}
		
	}
	init(samples: SampleBuffer) {
		self.samples = samples
	}
}


