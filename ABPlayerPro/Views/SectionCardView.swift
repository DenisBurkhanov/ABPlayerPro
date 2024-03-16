//
//  SectionCardView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 16.03.2024.
//

import SwiftUI

struct SectionCardView: View {
	@ObservedObject var vm: ViewModel
	@State var colorEdit = false
	@State var isDeleteButtonShown: Bool = false
	@State var slideValue: CGFloat = 0
	
	let allColors = [ dCS.lighterGray, dCS.pastelPurple, dCS.pastelBlue, dCS.pastelGreen, dCS.pastelYellow, dCS.pastelRed]
	
	var sectionIndex: Int
	
	
	var body: some View {
		HStack {
			Button {
				colorEdit.toggle()
			} label: {
				HStack {
					
					ZStack{
						Circle()
							.foregroundColor(dCS.darkerGray)
							.frame(height: 25)
							.scaleEffect(1.5)
						Circle()
							.foregroundColor(vm.selectedForEditing.track.sections[sectionIndex].color)
							.frame(height: 30)
							.shadow(radius: 10)
					}
					
				}
			}
			
			if !colorEdit {
				textEditView
			} else {
				colorEditView
			}
		}
			.padding()
			.background(.black)
			.clipShape(RoundedRectangle(cornerRadius: 10))
			
	}
	var textEditView: some View {
		HStack {
			
			TextField("Section", text: $vm.selectedForEditing.track.sections[sectionIndex].title)
				.foregroundColor(dCS.pastelPurpleLighter)
				.padding(.horizontal)
			Spacer()
			
			Image(systemName: "equal")
				.rotationEffect(Angle(degrees: 90))
				.font(.system(size: 20))
				.foregroundColor(dCS.pastelPurpleLighter)
				.padding(.horizontal)
				.padding(.horizontal)
				.gesture(
					DragGesture(minimumDistance: 0)
						.onChanged({ gest in
							slideValue = gest.translation.width
							if gest.translation.width < -60 && isDeleteButtonShown == false {
								isDeleteButtonShown = true
							} else if gest.translation.width > 60 && isDeleteButtonShown == true {
								isDeleteButtonShown = false
							}
						})
						.onEnded({ _ in
							slideValue = 0
						})
					
				)
			Group{
				if !isDeleteButtonShown {
					Image(systemName: "play.fill")
						.foregroundColor(.white)
						.font(.system(size: 20))
						.opacity(0.7)
						.padding(.horizontal)
						.offset(x: slideValue)
						.gesture(
							DragGesture(minimumDistance: 0)
								.onChanged({ _ in
									vm.selectedForEditing.playFrom(time: vm.selectedForEditing.track.sections[sectionIndex].startTime)
									vm.selectedForEditing.audioPlayer?.play()
								})
							
								.onEnded { _ in
									vm.selectedForEditing.audioPlayer?.pause()
									
								}
						)
				} else {
					Button {
						vm.removeSection(number: sectionIndex)
					} label: {
						ZStack {
							Circle()
								.foregroundColor(.red)
								.frame(height: 25)
							Image(systemName: "xmark")
								.foregroundColor(.white)
								.font(.system(size: 20))
						}
						.padding(.horizontal)
					}
					.offset(x: slideValue)
				}
			}
				.clipShape(Rectangle())
			
		}
	}
	var colorEditView: some View {
		HStack {
		
			Spacer()
			//MARK: ALL CHOOSABLE COLORS
			ForEach(allColors.indices, id: \.self) {  index in
				
				//MARK: COLOR SELECT BUTTON
				Button {
					
					vm.selectedForEditing.track.sections[sectionIndex].color = allColors[index]
					colorEdit = false

				} label: {
					ZStack{

						if allColors[index] == vm.selectedForEditing.track.sections[sectionIndex].color {
							Circle()
								.foregroundColor(.white)
								.frame(height: 25)
								.scaleEffect(1.5)
						} else {
							Circle()
								.foregroundColor(dCS.darkerGray)
								.frame(height: 25)
								.scaleEffect(1.5)
						}

						Circle()
							.foregroundColor(allColors[index])
							.frame(height: 30)
							.shadow(radius: 10)
					}
					.padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 4))

				}
			}
		}
	}
	init(vm: ViewModel, sectionIndex: Int) {
		self.vm = vm
		self.sectionIndex = sectionIndex
	}
}
