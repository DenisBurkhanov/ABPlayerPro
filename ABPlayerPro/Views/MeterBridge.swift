//
//  MeterBridge.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 16.03.2024.
//

import SwiftUI

struct MeterBridge: View {
	@ObservedObject var vm: ViewModel
	var engineNumber: Int
	var engine: AudioEngine {
		switch engineNumber {
		case 1:  return vm.audioEngineA
		case 2:  return vm.audioEngineB
		default: return vm.selectedForEditing
		}
		
	}
	var dbNumbers: [Double] = [-30, -20, -14, -12, -10, -7, -5, -3, -2, -1, 0]
	
	var body: some View {
		GeometryReader(content: { geometry in
			
			let elementHeight = geometry.size.height / 4
			let elementWidth  = geometry.size.width - 0
			let leftChannel   = engine.logPowerL
			let rightChannel  = engine.logPowerR
			let leftPeak      = engine.peakL
			let rightPeak     = engine.peakR
			let correlation   = (leftChannel - rightChannel)
			
			let meterColor    = dCS.pastelBlue
			let meterBGOpacity: CGFloat = 0.5
			
			
			
			HStack {
				VStack(spacing: 1) {
					//MARK: Digits
					HStack{
						
						ZStack {
							ForEach(dbNumbers, id: \.self) { db in
								let log = pow(10, db / 20.0)
								let dbint = Int(db)
								
								Text("\(dbint)")
									.font(.system(size: 7))
									.foregroundColor(.white)
									.frame(height: elementHeight)
									.offset(x: (elementWidth * log) - 5)
								
							}
							
						}
						
						Spacer()
					}
					//MARK: BG
					Rectangle()
						.frame(width: elementWidth, height: elementHeight)
						.foregroundColor(dCS.darkerGray)
						.opacity(meterBGOpacity)
						.overlay(
							ZStack {
								//MARK: Marks
								HStack {
									ZStack{
										ForEach(dbNumbers, id: \.self) { db in
											let log = pow(10, db / 20.0)
											
											Rectangle()
												.foregroundColor(.white)
												.frame(width: 1, height: elementHeight)
												.offset(x: (elementWidth * log) )
												.opacity(0.4)
											
										}
									}
									Spacer()
								}
								
								//MARK: LEFT CHANNEL
								ZStack {
									//Average
									HStack {
										Rectangle()
										
											.foregroundColor(meterColor)
											.frame(width: leftChannel * elementWidth, height: elementHeight)
											.opacity(0.9)
										if leftChannel < 0.99 {
											Spacer()
										} else {
											Spacer()
												.frame(width: 0)
										}
										
									}
									//Peak
									HStack {
										Rectangle()
										
											.foregroundColor(meterColor)
											.frame(width: 2, height: elementHeight)
											.offset(x: leftPeak * elementWidth)
											.opacity(0.9)
										Spacer()
										
										
									}
								}
							}
						)
					//MARK: BG
					Rectangle()
						.frame(width: elementWidth, height: elementHeight)
						.foregroundColor(dCS.darkerGray)
						.opacity(meterBGOpacity)
						.overlay(
							ZStack {
								//MARK: Marks
								HStack {
									ZStack{
										ForEach(dbNumbers, id: \.self) { db in
											let log = pow(10, db / 20.0)
											
											Rectangle()
												.foregroundColor(.white)
												.frame(width: 1, height: elementHeight)
												.offset(x: (elementWidth * log) )
												.opacity(0.4)
											
										}
									}
									Spacer()
								}
								
								//MARK: RIGHT CHANNEL
								ZStack {
									//Average
									HStack {
										Rectangle()
											.frame(width: rightChannel * elementWidth, height: elementHeight)
											.foregroundColor(meterColor)
											.opacity(0.9)
										if leftChannel < 0.99 {
											Spacer()
										} else {
											Spacer()
												.frame(width: 0)
										}
										
									}
									//Peak
									HStack {
										Rectangle()
										
											.foregroundColor(meterColor)
											.frame(width: 2, height: elementHeight)
											.offset(x: rightPeak * elementWidth)
											.opacity(0.9)
										Spacer()
										
									}
								}
							}
						)
					//MARK: BG
					Rectangle()
						.frame(width: elementWidth, height: elementHeight)
						.foregroundColor(dCS.darkerGray)
						.opacity(meterBGOpacity)
						.overlay(
							HStack {
								ZStack {
									Rectangle()
										.frame(width: elementWidth / 100, height: elementHeight)
										.foregroundColor(.white)
									
									//MARK: CORRELATION
									Rectangle()
										.frame(width: 0.01 * elementWidth, height: elementHeight)
										.foregroundColor(meterColor)
										.offset(x: (-correlation * (elementWidth / 2)), y: 0)
									
								}
							}
						)
				}
			}
		})
	}
	init(vm: ViewModel, engineNumber: Int) {
		self.vm = vm
		self.engineNumber = engineNumber
	}
}
