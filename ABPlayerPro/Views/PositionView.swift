//
//  PositionView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 15.03.2024.
//

import SwiftUI

struct PositionView: View {
	@ObservedObject var vm: ViewModel
	var engineNumber: Int
	var engine: AudioEngine {
		switch engineNumber {
		case 1:  return vm.audioEngineA
		case 2:  return vm.audioEngineB
		default: return vm.selectedForEditing
		}
		
	}
	
	
	var body: some View {
		GeometryReader { geometry in
			
			
			
			var position: TimeInterval {
				engine.playbackPosition
			}
			let blockWidth = (geometry.size.width)
			let duration = engine.duration
			let progressBarWidth = ((blockWidth /  duration ) * position)
			
			HStack {
				LinearGradient(colors: [ Color.black, Color.white], startPoint: .leading, endPoint: .trailing)
					.frame(width: (progressBarWidth > 0 ? progressBarWidth : 0 ))
				Spacer()
			}
			
			
			
			
		}
	}
	init(vm: ViewModel, engineNumber: Int) {
		self.vm = vm
		self.engineNumber = engineNumber
	}
}
