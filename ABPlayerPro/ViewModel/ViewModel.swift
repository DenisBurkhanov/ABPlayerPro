//
//  ViewModel.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 14.03.2024.
//

import SwiftUI
import AVFoundation
import CoreHaptics
import Waveform

class ViewModel: ObservableObject {
	

	@Published var allTracks: [ AudioTrack ] = []
	
	@Published var audioEngineA = AudioEngine()
	@Published var audioEngineB = AudioEngine()
	@ObservedObject var selectedForEditing = AudioEngine()

	@Published var waveformModel = WaveformModel(url: emptyTrack.filePath)
	
	@Published var isPlaying = false
	@Published var isLooped = false
	@Published var playbackPosition: TimeInterval = 0.0
	@Published var normalized = false
	
	let allColors = [ dCS.lighterGray, dCS.pastelPurple, dCS.pastelBlue, dCS.pastelGreen, dCS.pastelYellow, dCS.pastelRed]
	var copySectionsBuffer: [Section] = []
	
	
	let formatter = DateComponentsFormatter()

	func switchTrackA(track: AudioTrack) {
		audioEngineA = AudioEngine(track: track)
	}
	func switchTrackB(track: AudioTrack) {
		audioEngineB = AudioEngine(track: track)
	}
	
	func playSong() {
		audioEngineA.audioPlayer?.play()
		audioEngineB.audioPlayer?.play()
		
		isPlaying = true
		audioEngineA.isPlaying = isPlaying
		audioEngineB.isPlaying = isPlaying
		

	}
	func pauseSong() {
		audioEngineA.audioPlayer?.pause()
		audioEngineB.audioPlayer?.pause()
		isPlaying = false
		audioEngineA.isPlaying = isPlaying
		audioEngineB.isPlaying = isPlaying
		
	}
	func playFrom(time: TimeInterval, ab: Bool) {
		if ab {
			audioEngineA.playFrom(time: time)
			audioEngineB.playFrom(time: time)
		} else {
			selectedForEditing.playFrom(time: time)
		}
		
	}

	func copySections() {
		
		copySectionsBuffer = selectedForEditing.track.sections
		
	}
	func pasteSections() {

		selectedForEditing.track.sections = copySectionsBuffer
		
	}
	func applyChanges() {
		

		let idValue = selectedForEditing.track.id
		for _ in allTracks {
			if let index = allTracks.firstIndex(where: { $0.id == idValue }) {
				
				allTracks.remove(at: index)
				
				allTracks.append(selectedForEditing.track)
				
			}
		}
		
	}

	
	func applyCompensation() {
		let avgA = audioEngineA.resultAvgBuffer
		let avgB = audioEngineB.resultAvgBuffer
		if avgA > avgB {
			print("A > B")
			let difference = avgA - avgB
						
			audioEngineA.adjustVolume( by: Float(difference))
			audioEngineB.defaultVolumeOffset()
		} else {
			print("B > A")
			let difference = avgB - avgA
			
			audioEngineB.adjustVolume( by: Float(difference))
			audioEngineA.defaultVolumeOffset()
		}
	}
	
	func addSection(track: AudioTrack) {
		
		if track.sections.isEmpty && selectedForEditing.playbackPosition != 0 {
			
			selectedForEditing.track.sections.append(Section(title: "Section", startTime: 0, endTime: selectedForEditing.playbackPosition, color: allColors.randomElement() ?? dCS.bgColor))
		}
		selectedForEditing.track.sections.append(Section(title: "Section", startTime: selectedForEditing.playbackPosition,endTime: selectedForEditing.duration, color: allColors.randomElement() ?? dCS.bgColor))
	}
	func removeSection(track: AudioTrack, id: UUID) {
		
	
	}

	
	
	//files management
	func addNewTrack(fileURL: URL){
		
		
//		let fileURL = destinationURL.appendingPathComponent(file)
		let fileName = fileURL.lastPathComponent
		let title = fileName.replacingOccurrences(of: ".\(fileURL.pathExtension)", with: "")
		let format = fileURL.pathExtension
		waveformModel = WaveformModel(url: fileURL)
		let wave = waveformModel.samples
		
		
		let audioTrack = AudioTrack(filePath: fileURL, title: title, format: format, waveform: wave)
		
		
		
		self.allTracks.append(audioTrack)
		
		
		
	}
	
	func deleteTrack(track: AudioTrack){
		do {
			try FileManager.default.removeItem(at: track.filePath)
			for (index, value) in allTracks.enumerated() {
				if value.id == track.id {
					allTracks.remove(at: index)
				}
			}
			
			print("\(track.title) gone")
		} catch {
			print("Some error")
		}
	}
	
	func createDataFolderIfNeeded() {
			
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let dataFolderURL = documentsDirectory.appendingPathComponent("ABPro").appendingPathComponent("Tracks")

			do {
				// Check if the folder already exists
				var isDirectory: ObjCBool = false
				if !FileManager.default.fileExists(atPath: dataFolderURL.path, isDirectory: &isDirectory) {
					// If not, create it
					try FileManager.default.createDirectory(at: dataFolderURL, withIntermediateDirectories: true, attributes: nil)
					print("Data folder created successfully")
					print(dataFolderURL)
					
				} else {
					print("Data folder already exists")
					print(dataFolderURL)
				}
			} catch {
				print("Error creating data folder: \(error.localizedDescription)")
			}
		}
	func analizeTrackWaves(track: AudioTrack) {
		waveformModel = WaveformModel(url: track.filePath)
		let wave = waveformModel.samples
		for (index, value) in allTracks.enumerated() {
			if value.id == track.id {
				allTracks.remove(at: index)
			}
			
		}
		let audioTrack = AudioTrack(filePath: track.filePath, title: track.title, format: track.format, waveform: wave)
		allTracks.append(audioTrack)
	}
	
}
