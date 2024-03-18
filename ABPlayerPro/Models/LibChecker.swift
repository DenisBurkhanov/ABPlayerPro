//
//  LibChecker.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 13.03.2024.
//


import SwiftUI
import AVFoundation
import Waveform

struct LibChecker {
	var bufferForAllTRacks: [ AudioTrack ] = []
	var waveformModel = WaveformModel(url: emptyTrack.filePath)
	mutating func checkIfFilesExist(){
		
		do {
			
			let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let destinationURL = documentsURL.appendingPathComponent("ABPro").appendingPathComponent("Tracks")
			let files = try FileManager.default.contentsOfDirectory(atPath: destinationURL.path)
			
			
			for file in files {
				
				let fileURL = destinationURL.appendingPathComponent(file)
				
				if FileManager.default.fileExists(atPath: fileURL.path) {
					print("File exists at: \(fileURL)")
					
					
					if fileURL.pathExtension.lowercased() == "mp3" ||
						fileURL.pathExtension.lowercased() == "wav" ||
						fileURL.pathExtension.lowercased() == "m4a" ||
						fileURL.pathExtension.lowercased() == "aac" {
						print("It's audio: \(fileURL.lastPathComponent)")
						
						
						addNewTrackInBG(fileURL: fileURL)
						
					} else {
						print("File is not an audio file: \(fileURL)")
					}
					
					
				} else {
					print("File does not exist at: \(fileURL)")
				}
			}
		} catch {
			// Handle errors
			print("Error: \(error.localizedDescription)")
		}

	}
	mutating func addNewTrackInBG(fileURL: URL){
		
		
//		let fileURL = destinationURL.appendingPathComponent(file)
		let fileName = fileURL.lastPathComponent
		let title = fileName.replacingOccurrences(of: ".\(fileURL.pathExtension)", with: "")
		let format = fileURL.pathExtension
//		waveformModel = WaveformModel(url: fileURL)
//		let wave = waveformModel.samples
		
		
		let audioTrack = AudioTrack(filePath: fileURL, title: title, format: format)
		
		self.bufferForAllTRacks.append(audioTrack)
		
		
		
	}
}
