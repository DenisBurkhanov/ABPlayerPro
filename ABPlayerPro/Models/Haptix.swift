//
//  Haptix.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 02.02.2024.
//


import SwiftUI
import CoreHaptics

final class Haptix {
	@State var haptixEngine: CHHapticEngine?
	func prepareHaptix() {
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
		else { return }
		
		do {
			haptixEngine = try CHHapticEngine()
			try haptixEngine?.start()
		} catch {
			print("Haptix creating error: \(error.localizedDescription)")
		}
			
	}
	func sharpTap() {
		prepareHaptix()
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
		else { return }
		
		var events: [CHHapticEvent] = []
		let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
		let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
		let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
		events.append(event)
		
		do {
			let pattern = try CHHapticPattern(events: events, parameters: [])
			let player = try haptixEngine?.makePlayer(with: pattern)
			try player?.start(atTime: 0)
		} catch {
			print("Failed to play pattern \(error.localizedDescription)")
		}
	}
	func dullTap() {
		prepareHaptix()
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
		else { return }
		
		var events: [CHHapticEvent] = []
		let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
		let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
		let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
		events.append(event)
		
		do {
			let pattern = try CHHapticPattern(events: events, parameters: [])
			let player = try haptixEngine?.makePlayer(with: pattern)
			try player?.start(atTime: 0)
		} catch {
			print("Failed to play pattern \(error.localizedDescription)")
		}
	}
	func doubleTap() {
		prepareHaptix()
		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
		else { return }
		
		var events: [CHHapticEvent] = []
		let intensity1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
		let sharpness1 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
		let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
		let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
		let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity1, sharpness1], relativeTime: 0)
		let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity2, sharpness2], relativeTime: 0.2)
		events.append(event1)
		events.append(event2)
		do {
			let pattern = try CHHapticPattern(events: events, parameters: [])
			let player = try haptixEngine?.makePlayer(with: pattern)
			try player?.start(atTime: 0)
		} catch {
			print("Failed to play pattern \(error.localizedDescription)")
		}
	}
}



//extension ABPlayerView {
//	func prepareHaptix() {
//		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
//		else { return }
//		
//		do {
//			haptixEngine = try CHHapticEngine()
//			try haptixEngine?.start()
//		} catch {
//			print("Haptix creating error: \(error.localizedDescription)")
//		}
//			
//	}
//	func sharpTap() {
//		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
//		else { return }
//		
//		var events: [CHHapticEvent] = []
//		let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
//		let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
//		let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
//		events.append(event)
//		
//		do {
//			let pattern = try CHHapticPattern(events: events, parameters: [])
//			let player = try haptixEngine?.makePlayer(with: pattern)
//			try player?.start(atTime: 0)
//		} catch {
//			print("Failed to play pattern \(error.localizedDescription)")
//		}
//	}
//	func dullTap() {
//		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
//		else { return }
//		
//		var events: [CHHapticEvent] = []
//		let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
//		let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
//		let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
//		events.append(event)
//		
//		do {
//			let pattern = try CHHapticPattern(events: events, parameters: [])
//			let player = try haptixEngine?.makePlayer(with: pattern)
//			try player?.start(atTime: 0)
//		} catch {
//			print("Failed to play pattern \(error.localizedDescription)")
//		}
//	}
//	func doubleTap() {
//		guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
//		else { return }
//		
//		var events: [CHHapticEvent] = []
//		let intensity1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
//		let sharpness1 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
//		let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
//		let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
//		let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity1, sharpness1], relativeTime: 0)
//		let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity2, sharpness2], relativeTime: 0.2)
//		events.append(event1)
//		events.append(event2)
//		do {
//			let pattern = try CHHapticPattern(events: events, parameters: [])
//			let player = try haptixEngine?.makePlayer(with: pattern)
//			try player?.start(atTime: 0)
//		} catch {
//			print("Failed to play pattern \(error.localizedDescription)")
//		}
//	}
//}



