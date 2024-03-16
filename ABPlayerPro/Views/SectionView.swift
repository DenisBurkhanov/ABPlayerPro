//
//  SectionView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 03.02.2024.
//

import SwiftUI

struct sectionView: View {
	@ObservedObject var vm: ViewModel
	var engineNumber: Int
	var engine: AudioEngine {
		switch engineNumber {
		case 1:  return vm.audioEngineA
		case 2:  return vm.audioEngineB
		default: return vm.selectedForEditing
		}
		
	}
	
	var section: Section
	
	var body: some View {
		ZStack {
			
			
			if section.loop {
				Rectangle()
				.foregroundColor(section.color)
				.opacity(0.85)
					.shadow(radius: 5)
					.ignoresSafeArea()
					.overlay {
						RoundedRectangle(cornerRadius: 2)
							
							.stroke(lineWidth: 2)
							.foregroundColor(.white)
					}
			} else {
				Rectangle()
					.foregroundColor(section.color)
					.opacity(0.7)
					.ignoresSafeArea()
			}
			VStack {
				
				Spacer()
				
				HStack {

					if section.loop {

						Image(systemName: "arrow.triangle.2.circlepath.circle.fill")

							.foregroundColor(.white)
							.opacity(0.7)
							
					}
				}
				
				Spacer()
			}
			
		}
		.ignoresSafeArea()
	}
	
	init(vm: ViewModel, engineNumber: Int, section: Section) {
		self.vm = vm
		self.engineNumber = engineNumber
		self.section = section
	}
}
