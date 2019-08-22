import UIKit
import BTProgressView

class ViewController: UIViewController {

  @IBOutlet weak var progressView: BTProgressView!
  @IBOutlet weak var slider: UISlider!
  var lastValue: Float = 0.0
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    progressView.load()
  }
  
  @IBAction func sliderChanged(_ sender: Any) {
    if slider.value > lastValue {
      lastValue = slider.value
      progressView.setProgress(Int(lastValue))
      
      if slider.value == 100 {
        reset()
      }
    } else {
      slider.value = lastValue
    }
  }

  @IBAction func btnFailed(_ sender: Any) {
    progressView.failed()
    reset()
  }
  
  func reset() {
    lastValue = 0
    slider.value = 0
  }
  
}

