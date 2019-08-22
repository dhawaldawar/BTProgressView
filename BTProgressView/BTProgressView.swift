import UIKit

fileprivate enum State {
  case idle
  case progress
}

enum Color {
  static var bg = UIColor.init(red: 222.0/255.0, green: 97.0/255.0, blue: 79.0/255.0, alpha: 1.0)
  static var iconBg = UIColor.init(red: 68.0/255.0, green: 30.0/255.0, blue: 28.0/255.0, alpha: 1.0)
  static var icon = UIColor.white
  static var progress = UIColor.white
  static var bar = UIColor.init(red: 68.0/255.0, green: 30.0/255.0, blue: 28.0/255.0, alpha: 1.0)
  static var done = UIColor.init(red: 0.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
  static var failed = UIColor.red
}

struct Dimension {
  static let IconLineWidth: CGFloat = 4
  static let padding: CGFloat = 40
  static let progressWidth: CGFloat = 5
}

public class BTProgressView: UIView {
  
  public var iconColor: UIColor {
    set {
      Color.icon = newValue
    }
    
    get {
      return Color.icon
    }
  }
  
  public var iconBgColor: UIColor {
    set {
      Color.iconBg = newValue
    }
    
    get {
      return Color.iconBg
    }
  }
  
  public var progressColor: UIColor {
    set {
      Color.progress = newValue
    }
    
    get {
      return Color.progress
    }
  }
  
  public var barColor: UIColor {
    set {
      Color.bar = newValue
    }
    
    get {
      return Color.bar
    }
  }
  
  public var doneTitleColor: UIColor {
    set {
      Color.done = newValue
    }
    
    get {
      return Color.done
    }
  }
  
  public var failedTitleColor: UIColor {
    set {
      Color.failed = newValue
    }
    
    get {
      return Color.failed
    }
  }

  private var state = State.idle
  private var radius : CGFloat = 50
  private lazy var progressBarAnimation = ProgressBarAnimation(radius: radius, frame: frame, superLayer: self.layer)
  private lazy var progressIconAnimation = ProgressIconAnimation(radius: radius, frame: frame, superLayer: layer, progressWidth: 5)
  private var progressComputation : ProgressComputation?
  
  public func setProgress(_ progress: Int) {
    if state == .progress {
      progressComputation?.setProgress(progress)
    }
  }
  
  public func failed() {
    progressComputation?.failed()
  }
  
  public func load(){
    progressIconAnimation.showInitialState()
  }
}

//Animations
extension BTProgressView{
  private func goIntoProgressState(){
    state = .progress
    progressIconAnimation.start { [weak self] in
      self?.progressBarAnimation.createBar(){[weak self] in
        self?.progressComputation = ProgressComputation(superView: self!, radius: self!.radius, delegate: self!)
        self?.progressComputation?.showInitialState()
      }
    }
    
  }
}

// Touches
extension BTProgressView{
  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if(state == .idle){
      goIntoProgressState()
    }
  }
}

extension BTProgressView: ProgressComputationDelegate {
  func doneIconReachedAtCenter() {
    progressIconAnimation.bringButtonIconToInitialState()
    state = .idle
  }
  
  func willAnimateFailedIconToCenterPosition() {
    progressBarAnimation.animateFailedProgress()
    progressIconAnimation.bringButtonIconToInitialState()
    state = .idle
  }
}
