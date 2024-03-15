//
//  JogBlock.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 15.03.2024.
//

import SwiftUI

struct Jog: View {
	
	@ObservedObject var vm: ViewModel
	@State private var jogOffset: CGFloat = 0.0
	
	var isItABPage: Bool
	
	
	
	var engineA: AudioEngine {
		vm.audioEngineA
	}
	var engineB: AudioEngine {
		vm.audioEngineB
	}
	var engineC: AudioEngine {
		vm.selectedForEditing
	}
	
	var body: some View {
		HStack {
			
			ZStack {
				
				HStack(spacing: 40) {
					ForEach((0 ..< 9), id: \.self) { _ in
						Rectangle()
							.frame(width: 2)
							.foregroundColor(dCS.pastelPurpleLighter)
							.opacity(0.5)
							.shadow(radius: 3)
					}
				}
				.offset(x: jogOffset, y: 0)
				Rectangle().opacity(0.000001)
			}
			.gesture(
				DragGesture()
					.onChanged { value in
						if isItABPage {
							if vm.isPlaying {
								engineA.audioPlayer?.pause()
								engineB.audioPlayer?.pause()
								

							}
							engineA.scrub(offsetTime: value.translation.width)
							engineB.scrub(offsetTime: value.translation.width)
						} else {
							if engineC.isPlaying  {
								engineC.audioPlayer?.pause()
							}
							
							engineC.scrub(offsetTime: value.translation.width)
							
						}

						jogOffset = value.translation.width
						
						
						
					}
					.onEnded({ value in
						jogOffset = 0
						if isItABPage {
							if vm.isPlaying {
								engineA.audioPlayer?.play()
								engineB.audioPlayer?.play()
							}
						} else {
							if engineC.audioPlayer?.isPlaying ?? true {
								engineC.audioPlayer?.play()
							}
						}
					})
				
			)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
		
	}
		
	
	init(vm: ViewModel, isItABPage: Bool){
		self.vm = vm
		self.isItABPage = isItABPage
	}
		
}
