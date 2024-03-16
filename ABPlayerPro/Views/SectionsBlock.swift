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
			let sections = engine.track.sections
			let padding: CGFloat = 0.0000001
			let blockWidth = (geometry.size.width)
			let duration = (engine.duration)
			
			
			HStack(spacing: 0) {
				if !sections.isEmpty {
					
					ForEach(Array(sections.enumerated()), id: \.offset) { index, value in

						let sectionStart = engine.track.sections[index].startTime
						let sectionEnd = ((blockWidth / (duration - padding) ) * (engine.track.sections[index].endTime - sectionStart ))

						sectionView(vm: vm, engineNumber: engineNumber, section: engine.track.sections[index])
							.frame(width: (sectionEnd >= 0 ? sectionEnd : 0 ))
						
							.onTapGesture {
								vm.playFrom(time: engine.track.sections[index].startTime, ab: ab)
//									haptixEngine.dullTap()
							}
//							.onLongPressGesture {
//								for (index, value) in engine.track.sections.enumerated() {
//									if engine.track.sections[index].loop {
//										engine.track.sections[index].loop = false
//									} else {
//										engine.track.sections[index].loop = true
//									}
//									
//								}
//								
//							}
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
