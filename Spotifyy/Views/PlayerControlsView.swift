//
//  PlayerControlsView.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 09/06/23.
//

import Foundation
import AVFoundation
import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlViewDidTapBackButton(_ playerControlsView: PlayerControlsView)
    func playerControlViewDidTapNextButton(_ playerControlsView: PlayerControlsView)
    func playerControlViewDidSlideSlider(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
    func playerControlViewDidSeekSliderChange(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}

struct PlayerControlsViewViewModel {
    let title: String?
    let subtitle:String?
}

final class PlayerControlsView: UIView {
    
    private var isPlaying = true
    
    weak var delegate: PlayerControlsViewDelegate?
    
    private let volumeButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34 , weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        slider.tintColor = .white
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.isHidden = true;
        return slider
    }()
    
    public var playedLabel : UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    public var seekSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.0
        slider.tintColor = .white
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        return slider
    }()
    
    public var remainingLabel : UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34 , weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let playPauseButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "pause.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45 , weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let nextButton : UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34 , weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        
        addSubview(volumeButton)
        volumeButton.addTarget(self, action: #selector(didTapVolume), for: .touchUpInside)
        addSubview(volumeSlider)
        volumeSlider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        
        addSubview(playedLabel)
        addSubview(seekSlider)
        seekSlider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        addSubview(remainingLabel)
        
        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)
        
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        
        
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func handleSliderChange(_ slider: UISlider) {
        let value = slider.value
        delegate?.playerControlViewDidSeekSliderChange(self, didSlideSlider: value)
    }
    
    @objc func didTapVolume() {
        volumeSlider.isHidden = !volumeSlider.isHidden
    }
    
    @objc func didSlideSlider(_ slider: UISlider) {
        let value = slider.value
        delegate?.playerControlViewDidSlideSlider(self, didSlideSlider: value)
        
    }
    
    @objc func didTapBack() {
        delegate?.playerControlViewDidTapBackButton(self)
        
        isPlaying = true
        
        playPauseButton.setImage(UIImage(systemName: "pause.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45 , weight: .regular)), for: .normal)
    }
    
    @objc func didTapNext() {
        delegate?.playerControlViewDidTapNextButton(self)
        
        isPlaying = true
        
        playPauseButton.setImage(UIImage(systemName: "pause.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45 , weight: .regular)), for: .normal)
    }
    
    @objc func didTapPlayPause() {
        self.isPlaying = !isPlaying
        delegate?.playerControlViewDidTapPlayPauseButton(self)
        
        // update the icon
        let pause = UIImage(systemName: "pause.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45 , weight: .regular))
        let play = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45 , weight: .regular))
        playPauseButton.setImage(isPlaying ? pause : play, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 40)
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.bottom + 10, width: width, height: 20)
        
        volumeButton.frame = CGRect(x: 5, y: subtitleLabel.bottom + 20, width: 20, height: 20)
        volumeSlider.frame = CGRect(x: volumeButton.right + 5, y: subtitleLabel.bottom + 14.5, width: width / 2, height: 30)
        
        
        seekSlider.frame = CGRect(x: 10, y: volumeButton.bottom + 20, width: width - 20, height: 40)
        playedLabel.frame = CGRect(x: 0, y: seekSlider.bottom, width: 40, height: 10)
        remainingLabel.frame = CGRect(x: width - 40, y: seekSlider.bottom, width: 40, height: 10)
        
        let buttonSize: CGFloat = 60
        playPauseButton.frame = CGRect(x: (width - buttonSize) / 2, y: seekSlider.bottom + 30, width: buttonSize, height: buttonSize)
        
        backButton.frame = CGRect(x: playPauseButton.left - 80 - buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        
        nextButton.frame = CGRect(x: playPauseButton.right + 80, y: playPauseButton.top, width: buttonSize, height: buttonSize)
    }
    
    func configure(with viewModel: PlayerControlsViewViewModel) {
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}
