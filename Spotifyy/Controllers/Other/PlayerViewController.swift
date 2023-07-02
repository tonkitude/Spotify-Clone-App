//
//  PlayerViewController.swift
//  Spotifyy
//
//  Created by Yashika Tonk on 07/04/23.
//

import UIKit
import SDWebImage
import AVFoundation

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didSlideSlider(_ value: Float)
    func didMoveSlider(_ value: Float)
    
}

class PlayerViewController: UIViewController {
    
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //private
    let ControlsView = PlayerControlsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view .backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(ControlsView)
        ControlsView.delegate =  self
        configureBarButton()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        ControlsView.frame = CGRect(x: 10, y: imageView.bottom + 10, width: view.width - 20,
                height: view.height - imageView.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 15)
        
    }
    
    private func configure() {
        imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        ControlsView.configure(with: PlayerControlsViewViewModel(title: dataSource?.songName, subtitle: dataSource?.subtitle))
    }
    
    private func configureBarButton(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    @objc func didTapAction(){
        //Action
        guard let url = URL(string: dataSource?.trackNow?.external_urls["spotify"] ?? "") else {
            return
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem // App doesn't crash on i pad
        present(vc, animated: true)
    }
    func refreshUI() {
        configure()
    }

}

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlViewDidSeekSliderChange(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didMoveSlider(value)
    }
    
    func playerControlViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlViewDidTapBackButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
    func playerControlViewDidTapNextButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    func playerControlViewDidSlideSlider(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
    
}
