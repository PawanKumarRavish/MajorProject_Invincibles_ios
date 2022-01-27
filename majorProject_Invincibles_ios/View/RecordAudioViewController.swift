
import UIKit

class RecordAudioViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var recorder = AKAudioRecorder.shared
    var duration : CGFloat = 0.0
    var timer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCircle()
    }
    
    @IBAction func playStoppedAction(_ sender: UIButton) {
        if recorder.isRecording{
            animate(isRecording: true)
            recorder.stopRecording()
            NotificationCenter.default.post(name: .recordedAudio, object: recorder.getRecordings.last)
            self.navigationController?.popViewController(animated: true)
        } else{
            animate(isRecording: false)
            recorder.record()
            setTimer()
        }
    }
    
    func animate(isRecording : Bool){
        if isRecording{
        self.playButton.layer.cornerRadius = 4
        UIView.animate(withDuration: 0.1) {
            self.playButton.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.playButton.layer.cornerRadius = 15
        }
        }
        else{
            UIView.animate(withDuration: 0.1) {
                self.playButton.transform = .identity
                self.playButton.layer.cornerRadius = 4
            }
        }
    }
    
    func setCircle(){
       self.playButton.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.playButton.layer.cornerRadius = 15
    }
    
    func setTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)
    }

    @objc func updateDuration() {
        if recorder.isRecording && !recorder.isPlaying{
            duration += 1
            self.timeLabel.alpha = 1
            self.timeLabel.text = duration.timeStringFormatter
        }else{
            timer.invalidate()
            duration = 0
            self.timeLabel.alpha = 0
            self.timeLabel.text = "0:00"
        }
    }
}
//MARK:- Adding Attributes to UIView
extension UIView {

@IBInspectable
var cornerRadius: CGFloat {
    get {
        return layer.cornerRadius
    }
    set {
        layer.cornerRadius = newValue
    }
}

@IBInspectable
var borderWidth: CGFloat {
    get {
        return layer.borderWidth
    }
    set {
        layer.borderWidth = newValue
    }
}

@IBInspectable
var borderColor: UIColor? {
    get {
        if let color = layer.borderColor {
            return UIColor(cgColor: color)
        }
        return nil
    }
    set {
        if let color = newValue {
            layer.borderColor = color.cgColor
        } else {
            layer.borderColor = nil
        }
    }
}
}
