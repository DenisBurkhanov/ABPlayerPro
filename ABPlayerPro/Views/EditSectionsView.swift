//
//  EditSectionsView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 16.02.2024.
//

import SwiftUI

struct editSectionsView: View {
	
	let allColors = [ dCS.lighterGray, dCS.pastelPurple, dCS.pastelBlue, dCS.pastelGreen, dCS.pastelYellow, dCS.pastelRed]
	var section: Section
	@State var colorEdit = false
	@State var selectedColor = dCS.bgColor
	
	let formatter = DateComponentsFormatter()
	
	var sectionStart: TimeInterval {
		section.startTime
	}
	var sectionEnd: TimeInterval {
		section.endTime
	}
	var sectionStartInSeconds: String {
		formatter.allowedUnits = [.minute, .second, .nanosecond]
		formatter.zeroFormattingBehavior = .pad
		let formattedStart = formatter.string(from: sectionStart)
		return formattedStart ?? ""
	}
	
	
	
    var body: some View {
        
		HStack {
			
			Button {
				if colorEdit {
					colorEdit = false
					
				} else {
					colorEdit = true
				}
				
				
			} label: {
				HStack {
					
					ZStack{
						Circle()
							.foregroundColor(dCS.darkerGray)
							.frame(height: 25)
							.scaleEffect(1.5)
						Circle()
							.foregroundColor(section.color)
							.frame(height: 30)
							.shadow(radius: 10)
					}
					
				}
			}
			

			if !colorEdit {
				
				
				Text(section.title)
					.foregroundColor(dCS.pastelPurpleLighter)
					.padding(.horizontal)
				Spacer()
				Text(sectionStartInSeconds)
					.foregroundColor(dCS.pastelPurpleLighter)
				
				
			} else {
				Spacer()
				
							
				
							ForEach(allColors, id: \.self) {  color in
								Button {
									selectedColor = color
									print(selectedColor)
//									track.sections.remove(at: index)
//									track.sections.append(color, index: index-1)
//									section.color = color
								} label: {
									ZStack{

										if color == selectedColor {
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
											.foregroundColor(color)
											.frame(height: 30)
											.shadow(radius: 10)
									}
									.padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 4))

								}
							}
			}
		}
		.padding()
		.background(.black)
		.clipShape(RoundedRectangle(cornerRadius: 10))
    }
	
	init(section: Section) {
		
		self.section = section
		
	}
	
}

//#Preview {
//	editSectionsView(section: Section(title: "iyiyv"), selectedColor: )
//		.padding()
//}
