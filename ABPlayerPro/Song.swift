//
//  Song.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 20.11.2023.
//


import Foundation
import SwiftUI
import Waveform




struct AudioTrack:  Identifiable {
	var id = UUID()
	var filePath: URL
	var title = ""
	var format = ""
	var duration: Float = 0.0
	var sections: [Section] = []
	var loudnessOffset: Float = 0.0
	var waveform: SampleBuffer = SampleBuffer(samples: [0])
//	var waveformR: [CGFloat] = []
	
	
	
	mutating func reName(name: String){
		title = name
		
	}
	mutating func startOfSection(index: Int, startTime: TimeInterval,  endTime: TimeInterval) {
		sections[index].startTime = startTime
		sections[index].endTime = endTime
	}
	
}
//struct EmptyAudioTrack: AudioTrackProtocol{
//	var title: String = ""
//	var format: String = ""
//	
//	
//}


struct Section: Identifiable {
	var title = ""
	var id = UUID()
	var sectionTitle = ""
	var startTime: TimeInterval = 0.0
	var endTime: TimeInterval = 0.0
	var color = Color(#colorLiteral(red: 0.5010726452, green: 0.5060470104, blue: 0.5231509209, alpha: 1))
	var loop = false
	mutating func loopToggle() {
		loop.toggle()
	}
	
}

//extension Color: Codable {
//	public func encode(to encoder: Encoder) throws {
//		<#code#>
//	}
//	
//	public init(from decoder: Decoder) throws {
//		<#code#>
//	}
//}