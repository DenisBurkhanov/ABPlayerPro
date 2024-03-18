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
	var isWaveformRetrieved = false
	var waveform: SampleBuffer = SampleBuffer(samples: [0])
//	var waveformR: [CGFloat] = []
	

	
	mutating func fillMarkUpSections(){
		if sections[0].startTime > 0 {
			self.sections.append(Section(title: "Section", startTime: 0, endTime: TimeInterval(self.duration), color: dCS.bgColor))
		}
		
		
		
		let sectionsSortedByStart = sections.sorted(by: { $0.startTime < $1.startTime })
		var fixedArray: [Section] = []
		
		
		for (index, value) in sectionsSortedByStart.enumerated() {
		
		
			if index == (sectionsSortedByStart.count - 1) {
				print("Last Index")
				
			
				fixedArray.append(value)
			
			} else {
				print("Not last Index")
				var section = value
				section.endTime = sectionsSortedByStart[(index + 1)].startTime
				
				fixedArray.append(section)
			}
		}
		
		self.sections = fixedArray
	}
	
	
}



struct Section: Identifiable {
	var id = UUID()
	var title = ""
	var startTime: TimeInterval = 0.0
	var endTime: TimeInterval = 0.0
	var color = Color(#colorLiteral(red: 0.5010726452, green: 0.5060470104, blue: 0.5231509209, alpha: 1))
	var loop = false
	mutating func loopToggle() {
		loop.toggle()
	}
	
}


