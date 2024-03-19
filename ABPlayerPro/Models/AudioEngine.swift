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
	
//	func getPeaks() {
//		track.waveformL.append(CGFloat(leftChannel))
//		track.waveformR.append(CGFloat(rightChannel))
//	}
	func meterValues() {
		audioPlayer?.updateMeters()
		 leftChannel = CGFloat((audioPlayer?.averagePower(forChannel: 0)) ?? 0)
		rightChannel = CGFloat((audioPlayer?.averagePower(forChannel: 1)) ?? 0)
		
	}
	
//	func getSectionLabel(forPlaybackPosition: TimeInterval) {
//		
//		for section in track.sections {
//			if section.startTime <= forPlaybackPosition && forPlaybackPosition < section.endTime {
//				currentSectionLabel = section.title
//			}
//		}
//	}
	
	
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
//	func calcMaxBuffer() {
//
//		var maxL = peakVolumeOffsetBufferL.max() ?? -166
//		var maxR = peakVolumeOffsetBufferR.max() ?? -166
//	}
	func defaultVolumeOffset() {
		
		volumeOffset = 1
	}
	func adjustVolume( by decibels: Float) {
		let linearVolume = 1 * pow(10.0, -decibels / 20.0)
		// Ensure the volume remains within the valid range (0...1)
		audioPlayer?.volume = max(0.0, min(1.0, linearVolume))
		print("\(track.title) volume is \(audioPlayer?.volume ?? 00)")
		volumeOffset = linearVolume
		print(volumeOffset)
		
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

//let mocksong: [Section] = [
//	Section(title: "intro",   startTime: 0,     endTime: 26.6,   color: dCS.pastelPurple),
//	Section(title: "verse 1", startTime: 26.6,  endTime: 53,     color: dCS.pastelGreen),
//	Section(title: "chorus 1",startTime: 53,    endTime: 79.7,   color: dCS.pastelYellow),
//	Section(title: "verse 2", startTime: 79.7,  endTime: 106.3,  color: dCS.pastelGreen),
//	Section(title: "chorus 2",startTime: 106.3, endTime: 136.5,  color: dCS.pastelYellow)
//   ]
//let defaultTrackMock = AudioTrack(title: "mocksong", format: "mp3",sections: mocksong, waveformL: waves, waveformR: waves)
//
//let dontsong: [Section] = [
//	Section(title: "intro",      startTime: 0,   endTime: 17,    color: dCS.pastelPurple),
//	Section(title: "verse 1",    startTime: 17,  endTime: 51,    color: dCS.pastelGreen),
//	Section(title: "theme",      startTime: 51,  endTime: 68,    color: dCS.pastelYellow),
//	Section(title: "verse 2",    startTime: 68,  endTime: 103,   color: dCS.pastelGreen),
//	Section(title: "chorus 1",   startTime: 103, endTime: 122,   color: dCS.pastelRed),
//	Section(title: "theme",      startTime: 122, endTime: 139,   color: dCS.pastelYellow),
//	Section(title: "quiet part", startTime: 139, endTime: 173,   color: dCS.pastelBlue),
//	Section(title: "verse 3",    startTime: 173, endTime: 190,   color: dCS.pastelGreen),
//	Section(title: "chorus 2",   startTime: 190, endTime: 229,   color: dCS.pastelRed)
//   ]
//let defaultTrackDont = AudioTrack(title: "Dont", format: "mp3", sections: dontsong)
//
//let anubissong: [Section] = [
//	Section(title: "intro",       startTime: 0,    endTime: 24,    color: dCS.pastelPurple),
//	Section(title: "verse 1",     startTime: 24,   endTime: 71,    color: dCS.pastelGreen),
//	Section(title: "chorus 1",    startTime: 71,   endTime: 103,    color: dCS.pastelRed),
//	Section(title: "verse 2",     startTime: 103,  endTime: 150,   color: dCS.pastelGreen),
//	Section(title: "chorus 2",    startTime: 150,  endTime: 176,   color: dCS.pastelRed),
//	Section(title: "solo",        startTime: 176,  endTime: 199,   color: dCS.pastelBlue),
//	Section(title: "double-time", startTime: 199,  endTime: 215,   color: dCS.pastelYellow),
//	Section(title: "chorus 3",    startTime: 215,  endTime: 256,   color: dCS.pastelRed)
//   ]
//let defaultTrackAnubis = AudioTrack(title: "Anubis", format: "wav", sections: anubissong)
//
//let anubisEngine: AudioEngine = AudioEngine(track: defaultTrackAnubis)
//
//let moon4 = AudioTrack(title: "Enakei Moon Mix 4", format: "mp3", sections: moonSections)
//let moon5 = AudioTrack(title: "Enakei Moon Mix 5", format: "mp3")
//let moonSections: [Section] = [
//	Section(title: "intro",       startTime: 0,    endTime: 36,    color: dCS.pastelPurple),
//	Section(title: "verse 1",       startTime: 36,    endTime: 53,    color: dCS.pastelGreen),
//	Section(title: "chorus 1",       startTime: 53,    endTime: 72,    color: dCS.pastelYellow),
//	Section(title: "verse 2",       startTime: 72,    endTime: 88,    color: dCS.pastelGreen),
//	Section(title: "chorus 2",       startTime: 88,    endTime: 105,    color: dCS.pastelYellow),
//	Section(title: "otmuzovochka",       startTime: 105,    endTime: 123,    color: dCS.pastelBlue),
//	Section(title: "verse 3",       startTime: 123,    endTime: 140,    color: dCS.pastelGreen),
//	Section(title: "doble chorus",       startTime: 140,    endTime: 175,    color: dCS.pastelYellow),
//	Section(title: "outro",       startTime: 175,    endTime: 197,    color: dCS.pastelPurple)
//	]
//
//let dm1 = AudioTrack(title: "FZBD DM Mix 1", format: "wav")
//let dm2 = AudioTrack(title: "FZBD DM Mix 2", format: "wav")
//
//let minus20 = AudioTrack(title: "minus20", format: "wav")
//let minus18 = AudioTrack(title: "minus18", format: "wav")
//let minus14 = AudioTrack(title: "minus14", format: "wav")
//let minus12 = AudioTrack(title: "minus12", format: "wav")
//let minus10 = AudioTrack(title: "minus10", format: "wav")
//let minus7  = AudioTrack(title: "minus7",  format: "wav")
//let minus5  = AudioTrack(title: "minus5",  format: "wav")
//let minus3  = AudioTrack(title: "minus3",  format: "wav")
//let minus2  = AudioTrack(title: "minus2",  format: "wav")
//let minus1  = AudioTrack(title: "minus1",  format: "wav")
//let minus0 =  AudioTrack(title: "minus0",  format: "wav")
