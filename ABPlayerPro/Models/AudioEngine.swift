//
//  AudioEngine.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 20.11.2023.
//

import AVFoundation
import Waveform



class AudioEngine: ObservableObject {
	
	var track: AudioTrack = emptyTrack
	var audioPlayer: AVAudioPlayer?
	private var scrubScaleFactor: Double = 500
	
	//VolumeOffsets
	var volumeOffset: Float = 1
	var avgVolumeOffsetBufferL: [CGFloat] = []
	var avgVolumeOffsetBufferR: [CGFloat] = []
	var peakVolumeOffsetBufferL: [CGFloat] = []
	var peakVolumeOffsetBufferR: [CGFloat] = []
	var resultAvgBuffer: CGFloat = 0
	var maxPeakBuffer: CGFloat = 0
	
	
	//player state
	var isPlaying = false
	let formatter = DateComponentsFormatter()
	var duration: TimeInterval {
		return audioPlayer?.duration ?? 0.0
	}
	var durationInSeconds: String {
		formatter.allowedUnits = [.minute, .second]
		formatter.zeroFormattingBehavior = .pad
		let formattedDuration = formatter.string(from: duration)
		return formattedDuration ?? ""
	}
	var playbackPosition: TimeInterval {
		return  audioPlayer?.currentTime ?? 0.0
	}
	var positionInSeconds: String {
		formatter.allowedUnits = [.minute, .second]
		formatter.zeroFormattingBehavior = .pad
		let formattedPosition = formatter.string(from: playbackPosition)
		return formattedPosition ?? ""
	}
	var currentSectionLabel: String {
		var title = ""
		for section in track.sections {
			if section.startTime <= playbackPosition && playbackPosition < section.endTime {
				title = section.title
			}
		}
		return title
	}
	
	
	//Metering
	var leftChannel: CGFloat = 0.0
	var rightChannel: CGFloat = 0.0
	var correlation: CGFloat = 0.0
	var logPowerL: CGFloat {
		pow(10, leftChannel / 20.0)
		
	}
	var logPowerR: CGFloat {
		pow(10, rightChannel / 20.0)
		
	}
	var peakL: CGFloat {
		let peak = audioPlayer?.peakPower(forChannel: 0) ?? 0
		let logPeak = pow(10, peak / 20.0)
		return CGFloat(logPeak)
	}
	var peakR: CGFloat {
		let peak = audioPlayer?.peakPower(forChannel: 1) ?? 0
		let logPeak = pow(10, peak / 20.0)
		return CGFloat(logPeak)
	}
	func meterValues() {
		audioPlayer?.updateMeters()
		 leftChannel = CGFloat((audioPlayer?.averagePower(forChannel: 0)) ?? 0)
		rightChannel = CGFloat((audioPlayer?.averagePower(forChannel: 1)) ?? 0)
		
	}
	
	
	//Volume offset
	func clearBuffer() {
		avgVolumeOffsetBufferL = []
		avgVolumeOffsetBufferR = []
		peakVolumeOffsetBufferL = []
		peakVolumeOffsetBufferR = []
	}
	func collectBuffer() {
		
		avgVolumeOffsetBufferL.append(leftChannel)
		avgVolumeOffsetBufferR.append(rightChannel)
		peakVolumeOffsetBufferL.append(peakL)
		peakVolumeOffsetBufferR.append(peakR)
		
	}
	func calcResultAvgBuffer() {
		let allSumL = avgVolumeOffsetBufferL.reduce(0, +)
		let allSumR = avgVolumeOffsetBufferR.reduce(0, +)
		let resultL = allSumL / CGFloat(avgVolumeOffsetBufferL.count)
		let resultR = allSumR / CGFloat(avgVolumeOffsetBufferR.count)
		let resultSum = (resultL + resultR) / 2
		
		resultAvgBuffer = resultSum
	}
	func defaultVolumeOffset() {
		volumeOffset = 1
	}
	func adjustVolume( by decibels: Float) {
		
		let linearVolume = 1 * pow(10.0, -decibels / 20.0)
		
		audioPlayer?.volume = max(0.0, min(1.0, linearVolume))

		volumeOffset = linearVolume
		
		
	}
	func playFrom(time: TimeInterval) {
		audioPlayer?.currentTime = time
	}
	func scrub(offsetTime: TimeInterval) {
		audioPlayer?.currentTime = audioPlayer!.currentTime + ( offsetTime / scrubScaleFactor)
	}
	func removeSection(number: Int) {
		self.track.sections.remove(at: number)
	}
	
	
	func setupAudioPlayer() {
		let url = track.filePath
		print("url = \(url.absoluteString)")

		if FileManager.default.fileExists(atPath: url.path) {
		
			
			
			do {
				audioPlayer = try AVAudioPlayer(contentsOf: url)
				audioPlayer?.enableRate = true
				audioPlayer?.rate = 1
				audioPlayer?.isMeteringEnabled = true
				audioPlayer?.prepareToPlay()

				
			} catch {
				print("Error loading audio file: \(error.localizedDescription)")
			}
		} else {
			print("Audio file not found")
		}
		
	}

	
	init(track: AudioTrack ) {
		self.track = track
		
	}
	init(){}
}

let emptyTrack = AudioTrack(filePath: Bundle.main.url(forResource: "Empty track", withExtension: "mp3")!, title: "Empty track", format: "mp3", isWaveformRetrieved: false)

