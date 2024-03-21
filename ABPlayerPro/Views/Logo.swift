//
//  Logo.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 04.02.2024.
//

import SwiftUI

struct Logo: View {
    var body: some View {
		ZStack {
			Rectangle()
				.foregroundColor(dCS.bgColor)
			ZStack {
				Capsule()
				
					.foregroundColor(dCS.pastelBlue)
					.scaleEffect(0.9)
					.blur(radius: 300)
					.opacity(0.5)
				Capsule()
				
					.foregroundColor(dCS.darkerGray)
					.scaleEffect(1.05)
				HStack {
					
					
					Circle()
						.padding(8)
						.foregroundColor(dCS.pastelBlue)
						.shadow(radius: 10)
					
					
						Spacer()
					
					
					
				}
				
				
				HStack {
					Spacer()
						.frame(width: 70)
					Text("A")
						.bold()
						.font(.system(size: 160))
						.foregroundColor(dCS.darkerGray)
						.padding(50)
						.padding(.horizontal)
						
					Spacer()
						.frame(width: 90)
					
					Text("B")
						.bold()
						.font(.system(size: 160))
						.foregroundColor(dCS.dmlighterGray)
						.padding(30)
						.padding(.horizontal)
						
					
					Spacer()
				}
			}
			
			.frame( width: 650, height: 400)
		}
		
    }
}

#Preview {
    Logo()
}
