//
//  RoundBlueButtonView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 21.03.2024.
//

import SwiftUI

struct RoundBlueButtonView: View {
	var buttonState: Bool = true
	var isImage: Bool = false
	var ifName: String
	var elseName: String = ""
    var body: some View {
		ZStack {
			Circle()
				.foregroundColor(dCS.pastelBlue)
				.shadow(radius: 10)
			
			if  isImage {
				Image(systemName: buttonState ? ifName : elseName)
					.scaleEffect(1.8)
					.foregroundColor(dCS.bgColor)
			} else {
				Text("\(buttonState ? ifName : elseName )")
					.font(.system(size: 13))
					.foregroundColor(dCS.bgColor)
			}
		}
		.frame(height: 50)
    }
	init(buttonState: Bool, isImage: Bool, ifName: String, elseName: String) {
		self.buttonState = buttonState
		self.isImage = isImage
		self.ifName = ifName
		self.elseName = elseName
	}
	init(isImage: Bool, name: String) {
		
		self.isImage = isImage
		self.ifName = name
		
	}
}
