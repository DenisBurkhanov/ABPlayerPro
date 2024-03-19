//
//  LabelsBlock.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 15.03.2024.
//

import SwiftUI

struct LabelsBlock: View {
	
	@ObservedObject var vm: ViewModel
	var isItABPage: Bool
	var isSelectedA: Bool
	var engine: AudioEngine {
		if isItABPage {
			return splitEngine
		} else {
			return vm.selectedForEditing
		}
	}
	var splitEngine: AudioEngine {
		if isSelectedA {
			vm.audioEngineA
		} else {
			vm.audioEngineB
		}
	}
	
	
	var body: some View {
		HStack {
			@State var position = engine.positionInSeconds
			@State var currentLabel = engine.currentSectionLabel
			Text(position)
				.foregroundColor(dCS.pastelPurpleLighter)
			
			Spacer()
			
			
			if (engine.currentSectionLabel) != "" {
				Text(currentLabel)
					.foregroundColor(dCS.pastelPurpleLighter)
					.padding(.horizontal)
					.background(dCS.darkerGray)
					.clipShape(RoundedRectangle(cornerRadius: 10))
			}
			
			
			Spacer()
			
			Text(engine.durationInSeconds)
				.foregroundColor(dCS.pastelPurpleLighter)
		}
	}
	init(vm: ViewModel, isItABPage: Bool, isSelectedA: Bool) {
		self.vm = vm
		self.isItABPage = isItABPage
		self.isSelectedA = isSelectedA
	}
}
