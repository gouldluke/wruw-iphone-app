import UIKit
import MediaPlayer
import RxSwift
import RxCocoa
import NSObject_Rx

class StreamPlayViewModel: NSObject {
    var urlAddress: NSURL?

    lazy var audioStreamPlayer: AVPlayer = {
        guard let urlStream = self.urlAddress else {
            return AVPlayer()
        }

        return AVPlayer(URL: urlStream)
    }()

    init(streamPath: String) {
        urlAddress = NSURL(string: streamPath)
    }

    func changePlayerStatus() {
        _audioPlayerIsActive.value = !_audioPlayerIsActive.value
        statusChange()
    }

    private func startPlayer() {
        guard urlAddress != nil else {
            pausePlayer()
            return
        }

        if audioStreamPlayer.status == .ReadyToPlay {
            streamIsReadyToPlay()
            return
        }

        audioStreamPlayer
            .rx_observe(
                AVPlayerStatus.self,
                "status",
                options: .New,
                retainSelf: true
            )
            .filter { $0 == .ReadyToPlay }
            .subscribeNext { [unowned self] _ in self.streamIsReadyToPlay() }
            .addDisposableTo(rx_disposeBag)
    }

    private var audioDisposable: Disposable?

    private func streamIsReadyToPlay() {
        audioStreamPlayer.play()

        setNowPlayingInfo(nowPlayingInfoPlaying)
    }

    private func pausePlayer() {
        audioStreamPlayer.pause()

        setNowPlayingInfo(nowPlayingInfoPaused)
    }

    func setNowPlayingInfo(info: [String: AnyObject]) {
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
    }

    func remoteControlReceivedWithEvent(event: UIEvent?) {
        print(event!.subtype, terminator: "")
        let eventSubtype = event!.subtype
        print("received remote control \(eventSubtype.rawValue)", terminator: "") // 101 = pause, 100 = play

        guard eventSubtype == .RemoteControlTogglePlayPause ||
            eventSubtype == .RemoteControlPlay ||
            eventSubtype == .RemoteControlPause else {
            return
        }

        _audioPlayerIsActive.value = _audioPlayerIsActive.value
    }

    func statusChange() {
        audioStreamPlayer.rate == 1.0 ? pausePlayer() : startPlayer()
    }

    private lazy var _audioPlayerIsActive = Variable(false)
    private lazy var _buttonIsAnimated: Observable<Bool> = {
        let buttonIsAnimated = self._audioPlayerIsActive.asObservable()
        buttonIsAnimated
            .skip(1)
            .subscribeNext { [unowned self] _ in self.statusChange() }
            .addDisposableTo(self.rx_disposeBag)
        return buttonIsAnimated
    }()

    private lazy var artworkImage: UIImage = {
        let bundle = NSBundle.mainBundle()
        if let path = bundle.pathForResource("Default", ofType: "png"),
            imageView = UIImage(contentsOfFile: path) {
            return imageView
        }

        return UIImage()
    }()

    private lazy var mediaItemArtwork: MPMediaItemArtwork = {
        MPMediaItemArtwork(image: self.artworkImage)
    }()

    private lazy var nowPlayingInfoPaused: [String: AnyObject] = {
        return self.nowPlayingInfo +
            [MPNowPlayingInfoPropertyPlaybackRate: NSNumber(double: 0.0)]
    }()

    private lazy var nowPlayingInfoPlaying: [String: AnyObject] = {
        return self.nowPlayingInfo +
            [MPNowPlayingInfoPropertyPlaybackRate: NSNumber(double: 1.0)]
    }()

    private lazy var nowPlayingInfo: [String : AnyObject] = {
        return [
            MPMediaItemPropertyTitle: "Listening Live",
            MPMediaItemPropertyArtist: "WRUW - 91.1 FM",
            MPMediaItemPropertyArtwork: self.mediaItemArtwork
        ]
    }()
}

extension StreamPlayViewModel: AnimatedButtonProtocol {
    var buttonIsAnimated: Observable<Bool> { return _buttonIsAnimated }
}
