//
//  SectionsBlock.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 15.03.2024.
//

import SwiftUI

struct SectionsBlock: View {
	@ObservedObject var vm: ViewModel
	var engineNumber: Int
	var engine: AudioEngine {
		switch engineNumber {
		case 1:  return vm.audioEngineA
		case 2:  return vm.audioEngineB
		default: return vm.selectedForEditing
		}
		
	}
	var ab: Bool {
		if engineNumber > 0 {
			return true
		} else {
			return false
		}
	}
	var body: some View {
		GeometryReader { geometry in
			let padding: CGFloat = 0.0000001
			let blockWidth = (geometry.size.width)
			let duration = (engine.duration)
			
			ZStack {




				HStack(spacing: 0) {
					let track = engine.track

					
						ForEach(track.sections.sorted(by: { $0.startTime < $1.startTime } )) { section in
							let sectionStart = section.startTime
							let sectionEnd = ((blockWidth / (duration - padding) ) * (section.endTime - sectionStart ))
//							let sectionDuration = sectionEnd - sectionStart



							sectionView(section: section)
								.frame(width: (sectionEnd >= 0 ? sectionEnd : 0 ))

								.onTapGesture {
									vm.playFrom(time: section.startTime, ab: ab)
//									dullTap()
								}
								
							
								
						}
				}
			}
			.frame(width: blockWidth)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
	}
	init(vm: ViewModel, engineNumber: Int) {
		self.vm = vm
		self.engineNumber = engineNumber
	}
}

//#Preview {
//    SectionsBlock()
//}
