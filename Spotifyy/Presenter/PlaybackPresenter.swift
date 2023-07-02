//
//  PlaybackPresenter.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 09/06/23.
//
import AVFoundation  //Audio Video Foundation - which allows us to interact with AV components
import Foundation
import UIKit

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
    var trackNow: AudioTrack? { get }
}

// you can create a shared instance or create static function directly

final class PlaybackPresenter {
    
    static let shared = PlaybackPresenter()
    
    init() {
        
    }
    
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    var index = 0;
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }
        else if !tracks.isEmpty//let player = self.playerQueue, !tracks.isEmpty
        {
            return tracks[index]
        }
        return nil
    }
    
    var playerVC: PlayerViewController?
    
    //var player: AVPlayer?
    var player = AVPlayer()
    var playerQueue = [AVPlayerItem]()
    
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        guard let url = URL(string: track.preview_url ?? "") else { return }
        player = AVPlayer(url: url)
        player.volume = 0.5
        
        playerQueue = [AVPlayerItem]()
        
        self.track = track
        self.tracks = []
        
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        
        vc.ControlsView.seekSlider.value = 0.0
        
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player.play()
        }
        self.playerVC = vc
        
        progressBar()
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack], index: Int) {
        self.tracks = tracks
        self.track = nil
        
        playerQueue = [AVPlayerItem]()
        
        self.index = index
        
        self.playerQueue = self.tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else { return nil }
            return AVPlayerItem(url: url)
        })
        
        if(self.playerQueue.count > 0){
            player.replaceCurrentItem(with: self.playerQueue[index])
            
            self.player.volume = 0.5
            self.player.play()
        }
        
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        
        
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        self.playerVC = vc
        
        progressBar()
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func progressBar() {
        
        let interval = CMTime(value: 1, timescale: 2)
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { (progressTime) in
            
            let seconds = CMTimeGetSeconds(progressTime)
            
            let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
            let minutesString = String(format: "%02d", Int(seconds / 60))
            self.playerVC?.ControlsView.playedLabel.text = "\(minutesString):\(secondsString)"
            
            if let duration = self.player.currentItem?.asset.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                
                let remseconds: Int = Int(durationSeconds - seconds)
                let remsecondsString = String(format: "%02d", Int(remseconds % 60))
                let remminutesString = String(format: "%02d", Int(remseconds / 60))
                
                if remseconds == 0 {
                    
                    self.didMoveSlider(0.0)
                    self.playerVC?.ControlsView.seekSlider.value = 0.0
                    self.didTapForward()
                }
                
                self.playerVC?.ControlsView.remainingLabel.text = "\(remminutesString):\(remsecondsString)"
                
                self.playerVC?.ControlsView.seekSlider.value = Float(seconds / durationSeconds)
                
            }
            
            
        }
    }
    
    func didMoveSlider(_ value: Float) {
        
        if let duration = player.currentItem?.duration{
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let valuee = Float64(value) * totalSeconds
            
            let seekTime = CMTimeMakeWithSeconds(Double(valuee), preferredTimescale: 1)
            
            player.currentItem?.seek(to: seekTime)
        }
    }
    
    func didTapPlayPause() {
        if player.timeControlStatus == .playing {
            player.pause()
        }
        else if player.timeControlStatus == .paused {
            player.play()
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty{
            player.pause()
            guard let url = URL(string: track?.preview_url ?? "") else { return }
            player = AVPlayer(url: url)
            player.play()
            progressBar()

        }
        
        if(index < playerQueue.count - 1){
            index += 1
        }
        else { index = 0}
        
        if self.playerQueue.count > 0 {
            print((playerQueue.count))
            print(tracks.count)
            player.pause()
            player.replaceCurrentItem(with: self.playerQueue[index])
            player.play()
        }
        self.didMoveSlider(0.0)
        self.playerVC?.ControlsView.seekSlider.value = 0.0
        playerVC?.refreshUI()
        
    }
    
    func didTapBackward() {
        if tracks.isEmpty{
            guard let url = URL(string: track?.preview_url ?? "") else { return }
            player = AVPlayer(url: url)
            player.play()
            progressBar()

        }
        
        if(index > 0 ){
            index -= 1
        }
        else { index = playerQueue.count - 1}
        
        
        if self.playerQueue.count > 0 {
            player.replaceCurrentItem(with: self.playerQueue[index])
            player.play()
        }
        self.didMoveSlider(0.0)
        self.playerVC?.ControlsView.seekSlider.value = 0.0
        playerVC?.refreshUI()
        
    }
    func didSlideSlider(_ value: Float) {
        player.volume = value
    }
}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    var trackNow: AudioTrack? {
        return currentTrack
    }
}
