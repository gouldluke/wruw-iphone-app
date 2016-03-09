import UIKit
import AVFoundation
import MediaPlayer

@objc class StreamPlayView: UIView  {
    // previous stream url = "http://wruw-stream.wruw.org:443/stream.mp3"
    // current stream url = "http://wruw-stream2.wruw.org:8000/stream256.mp3"
    let urlAddress = "http://wruw-stream2.wruw.org:8000/stream256.mp3"

    var viewModel: StreamPlayViewModel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        viewModel = StreamPlayViewModel(streamPath: urlAddress)
        addSubview(animatedPlayPauseButton) { make in
            make.edges.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private lazy var animatedPlayPauseButton: AnimatedButton = {
        return AnimatedButton(viewModel: self.viewModel)
            .onTap(target: self, selector: "didTapPlayer")
    }()

    func didTapPlayer() {
        viewModel.changePlayerStatus()
    }

    @objc func didAppear() {
        animatedPlayPauseButton.didAppear()
    }
}
