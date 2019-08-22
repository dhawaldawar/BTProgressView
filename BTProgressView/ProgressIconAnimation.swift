import Foundation
import UIKit

class ProgressIconAnimation : NSObject{
  
  private var radius : CGFloat
  private var progressWidth : CGFloat
  private var frame : CGRect
  
  private var superLayer : CALayer
  private var layerDownIcon: CAShapeLayer!
  private var layerBtn = CALayer()
  
  private var animationCompleted : (() -> (Void))!
  
  init(radius : CGFloat, frame : CGRect, superLayer : CALayer, progressWidth : CGFloat) {
    self.radius = radius
    self.frame = frame
    self.superLayer = superLayer
    self.progressWidth = progressWidth / 2
  }
  
  func showInitialState(){
    setupButton()
    setupIcon()
  }
  
  func start(completed: @escaping ()->(Void)){
    animationCompleted = completed
    
    let animationGroup = CAAnimationGroup()
    
    let animateBtnScale = CAKeyframeAnimation(keyPath: "transform")
    animateBtnScale.keyTimes = [0.0,0.3,1.0]
    animateBtnScale.values = [CATransform3DMakeScale(1.0, 1.0, 1.0),CATransform3DMakeScale(0.8, 0.8, 1.0),CATransform3DMakeScale(1.0, 1.0, 1.0)]
    animateBtnScale.timingFunction = CAMediaTimingFunction(name: .easeIn)
    animateBtnScale.duration = 0.5
    
    let animateIconScale = CAKeyframeAnimation(keyPath: "transform")
    animateIconScale.keyTimes = [0.0,0.3,1.0]
    animateIconScale.values = [CATransform3DMakeScale(1.0, 1.0, 1.0),CATransform3DMakeScale(0.8, 0.8, 1.0),CATransform3DMakeScale(1.0, 1.0, 1.0)]
    animateIconScale.timingFunction = CAMediaTimingFunction(name: .easeIn)
    animateIconScale.duration = 0.5
    
    let animateBorderWidth = CABasicAnimation(keyPath: "borderWidth")
    animateBorderWidth.beginTime = 0.25
    animateBorderWidth.fromValue = radius
    animateBorderWidth.toValue = 5
    animateBorderWidth.timingFunction = CAMediaTimingFunction(name: .easeIn)
    animateBorderWidth.duration = 0.25
    
    animationGroup.duration = 0.5
    animationGroup.isRemovedOnCompletion = false
    animationGroup.fillMode = .forwards
    
    animationGroup.animations = [animateBtnScale,animateBorderWidth]
    animationGroup.delegate = self
    layerBtn.add(animationGroup , forKey: "AnimateButton")
    
    animateIconToIntialPosition()
  }
  
  func bringButtonIconToInitialState() {
    layerBtn.isHidden = false
    let animateBtnScale = CAKeyframeAnimation(keyPath: "transform")
    animateBtnScale.keyTimes = [0.0,0.6,1.0]
    animateBtnScale.values = [CATransform3DMakeScale(0.0, 0.0, 1.0),CATransform3DMakeScale(1.3, 1.3, 1.0),CATransform3DMakeScale(1.0, 1.0, 1.0)]
    animateBtnScale.timingFunction = CAMediaTimingFunction(name: .easeIn)
    animateBtnScale.duration = 0.5
    animateBtnScale.delegate = self
    layerBtn.add(animateBtnScale, forKey: "BringBackgroundAnimation")
  }
  
  private func animateIconToIntialPosition(){
    let progressIconSize = CGSize(width: per(50), height: per(30))
    
    var path = UIBezierPath()
    path.move(to: CGPoint(x: frame.size.width/2, y: frame.size.height/2))
    path.addQuadCurve(to: CGPoint(x: 10+per(5), y: frame.size.height/2-(progressIconSize.height/2)-progressWidth), controlPoint: CGPoint(x: frame.size.width/4+10, y: 0))
    
    let animatonGroup = CAAnimationGroup()
    
    let animatePosition = CAKeyframeAnimation(keyPath: "position")
    animatePosition.path = path.cgPath
    animatePosition.duration = 0.2
    
    let animateFrame = CABasicAnimation(keyPath: "bounds")
    animateFrame.toValue = CGRect(x: 0, y: 0, width: progressIconSize.width, height: progressIconSize.height)
    
    let animateRotation = CAKeyframeAnimation(keyPath: "transform")
    animateRotation.keyTimes = [0.0,0.2,0.5,0.7,1.0]
    animateRotation.values = [rotation(0),rotation(-5),rotation(-10),rotation(5),rotation(10)]
    animateRotation.duration = 0.2
    
    let animatePath = CABasicAnimation(keyPath: "path")
    animatePath.toValue = Path.progressLabel.cgPath
    animatePath.duration = 0.2
    animatePath.isRemovedOnCompletion = false
    animatePath.fillMode = .forwards
    
    animatonGroup.beginTime =  CACurrentMediaTime() + 0.5
    animatonGroup.fillMode = .forwards
    animatonGroup.duration = 0.2
    animatonGroup.isRemovedOnCompletion = false
    animatonGroup.animations = [animatePosition,animateRotation,animatePath,animateFrame]
    layerDownIcon.add(animatonGroup, forKey: "AnimateIconToIntialPosition")
    
    let animationBounceGroup = CAAnimationGroup()
    
    path = UIBezierPath()
    path.move(to: CGPoint(x: Dimension.padding, y: frame.size.height/2-(progressIconSize.height/2)-progressWidth))
    path.addLine(to: CGPoint(x: Dimension.padding, y: frame.size.height/2-(progressIconSize.height/2)-10-progressWidth))
    path.addLine(to: CGPoint(x: Dimension.padding, y: frame.size.height/2-(progressIconSize.height/2)-progressWidth))
    path.addLine(to: CGPoint(x: Dimension.padding, y: frame.size.height/2-(progressIconSize.height/2)-5-progressWidth))
    path.addLine(to: CGPoint(x: Dimension.padding, y: frame.size.height/2-(progressIconSize.height/2)-progressWidth))
    
    let animationBouncePosition = CAKeyframeAnimation(keyPath: "position")
    animationBouncePosition.path = path.cgPath
    
    let animationBounceRotation = CAKeyframeAnimation(keyPath: "transform")
    animationBounceRotation.keyTimes = [0.0,0.5,1.0]
    animationBounceRotation.values = [rotation(10),rotation(-10),rotation(0)]
    
    animationBounceGroup.beginTime =  animatonGroup.beginTime + animatonGroup.duration
    animationBounceGroup.fillMode = .forwards
    animationBounceGroup.duration = 0.4
    animationBounceGroup.isRemovedOnCompletion = false
    animationBounceGroup.animations = [animationBouncePosition,animationBounceRotation]
    animationBounceGroup.delegate = self
    layerDownIcon.add(animationBounceGroup, forKey: "AnimateBounceIcon")
  }
  
  private func rotation(_ angle : CGFloat) -> CATransform3D{
    return CATransform3DMakeRotation(angle*CGFloat((Double.pi/180.0)),0,0,1)
  }
  
  private func scale(_ x : CGFloat, _ y : CGFloat) -> CATransform3D{
    return CATransform3DMakeScale(x, y, 1.0)
  }
  
  private func setupButton(){
    layerBtn.bounds = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
    layerBtn.borderWidth = radius
    layerBtn.borderColor  = Color.iconBg.cgColor
    layerBtn.cornerRadius = radius
    layerBtn.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    superLayer.addSublayer(layerBtn)
  }
  
  private func setupIcon(){
    layerDownIcon = CAShapeLayer()
    layerDownIcon.path = Path.downloadIcon.cgPath
    Icon.updateProperties(layer: layerDownIcon)
    superLayer.addSublayer(layerDownIcon)
    layerDownIcon.frame = CGRect(x: 0, y: 0, width: per(40), height: per(40))
    layerDownIcon.position = CGPoint(x: (frame.width/2), y: frame.height/2)
  }
  
  private func per(_ per : Int) -> CGFloat{
    return CGFloat((2 * radius * CGFloat(per))/100)
  }
}

extension ProgressIconAnimation : CAAnimationDelegate{
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if (layerBtn.animation(forKey: "AnimateButton") == anim){
      layerBtn.removeAllAnimations()
      layerBtn.isHidden = true
      animationCompleted()
    } else if (layerDownIcon.animation(forKey: "AnimateBounceIcon") == anim) {
      layerDownIcon.removeFromSuperlayer()
    } else {
      setupIcon()
    }
  }
}

