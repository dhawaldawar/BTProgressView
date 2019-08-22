import UIKit

extension CALayer {
  
  /// Pauses animations in layer tree.
  func pause() {
    let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
    speed = 0.0;
    timeOffset = pausedTime;
  }
  
  /// Resumes animations in layer tree.
  func resume() {
    let pausedTime = timeOffset;
    speed = 1.0;
    timeOffset = 0.0;
    beginTime = 0.0;
    let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime;
    beginTime = timeSincePause;
  }
  
  func resetSpeed() {
    speed = 1.0
  }
}
