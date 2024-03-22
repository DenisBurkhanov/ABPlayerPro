//
//  SectionCardView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 16.03.2024.
//

import SwiftUI

struct SectionCardView: View {
//	@ObservedObject var vm: ViewModel
	@State var colorEdit = false
	@State var isDeleteButtonShown: Bool = false
	@State var slideValue: CGFloat = 0
	
	@Binding var engine: AudioEngine
	@Binding var selectedColor: Color
	@Binding var selectedText: String
	@Binding var sectionStartTime: TimeInterval
	@Binding var sectionIndex: Int
	var removeSection: (Int) -> ()
	
	let allColors = [ dCS.dmlighterGray, dCS.pastelPurple, dCS.pastelBlue, dCS.pastelGreen, dCS.pastelYellow, dCS.pastelRed ]
	

	
	
	var body: some View {
		HStack {
			Button {
				Haptix.shared.sharpTap()
				colorEdit.toggle()
			} label: {
				HStack {
					
					ZStack{
						Circle()
							.foregroundColor(dCS.darkerGray)
							.frame(height: 25)
							.scaleEffect(1.5)
						Circle()
							.foregroundColor(selectedColor)
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
			
			TextField("Section", text: $selectedText)
				.foregroundColor(dCS.pastelPurpleLighter)
				.padding(.horizontal)
			Spacer()
			
			Image(systemName: "equal")
				.fontWeight(.ultraLight)
				.rotationEffect(Angle(degrees: 90))
				.font(.system(size: 25))
				.foregroundColor(isDeleteButtonShown ? .white : dCS.pastelPurpleLighter)
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
						.frame(height: 20)
						.padding(10)
						.background( dCS.dmlighterGray)
						.clipShape(Circle())
						.offset(x: slideValue)
						.gesture(
							DragGesture(minimumDistance: 0)
								.onChanged{ _ in
									Haptix.shared.sharpTap()
									engine.playFrom(time: sectionStartTime)
									engine.audioPlayer?.play()
								}
							
								.onEnded { _ in
									Haptix.shared.dullTap()
									engine.audioPlayer?.pause()
									
								}
						)
				} else {
					Button {
						Haptix.shared.doubleTap()
						removeSection(sectionIndex)
						isDeleteButtonShown = false
						engine.track.fillMarkUpSections()
					} label: {
						
						
						Image(systemName: "xmark")
							.foregroundColor(.white)
							.font(.system(size: 20))
							.opacity(0.7)
							.frame(height: 20)
							.padding(10)
							
							.background(.red)
							.clipShape(Circle())
							.padding(.leading, 20)
							
					}
					.offset(x: slideValue)
				}
			}
				.clipShape(Rectangle())
				.frame(height: 30)
			
		}
	}
	var colorEditView: some View {
		HStack {
		
			Spacer()
			//MARK: ALL CHOOSABLE COLORS
			ForEach(allColors.indices, id: \.self) {  index in
				
				//MARK: COLOR SELECT BUTTON
				Button {
					Haptix.shared.doubleTap()
					selectedColor = allColors[index]
					colorEdit = false

				} label: {
					ZStack{

						if allColors[index] == selectedColor {
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
}
