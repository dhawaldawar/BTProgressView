import Foundation
import UIKit

protocol ProgressComputationDelegate: class {
  func doneIconReachedAtCenter()
  func willAnimateFailedIconToCenterPosition()
}

class ProgressComputation : NSObject{
  
  private var iconPath : UIBezierPath
  private var superView : UIView
  private var padding : CGFloat
  private var progressWidth : CGFloat
  private var progressColor : UIColor
  private var unProgressColor : UIColor
  private var lblTitle : UILabel!
  private var progressLayer : CAShapeLayer!
  private var barLayer : CAShapeLayer!
  private var radius : CGFloat!
  private var timer : Timer?
  private var viewProgress : UIView!
  private var viewProgressInner : UIView!
  private var labelIconShapeLayer : CAShapeLayer!
  private var isBendAnimationPlayingOrPlayed = false
  private weak var delegate: ProgressComputationDelegate?
  private var isFailed = false
  
  var progress: Int = 0
  
  init(superView : UIView, radius : CGFloat, delegate: ProgressComputationDelegate) {
    self.iconPath = Path.progressLabel
    self.superView = superView
    self.padding = Dimension.padding
    self.progressWidth = Dimension.progressWidth
    self.progressColor = Color.progress
    self.unProgressColor = Color.bar
    self.radius = radius
    self.delegate = delegate
  }
  
  func showInitialState(){
    viewProgress = UIView(frame: CGRect(x: padding-(iconPath.bounds.size.width/2), y: superView.frame.size.height/2-progressWidth-iconPath.bounds.size.height, width: iconPath.bounds.size.width, height: iconPath.bounds.size.height+2))
    superView.addSubview(viewProgress)
    viewProgressInner = UIView(frame: viewProgress.bounds)
    viewProgress.addSubview(viewProgressInner)
    viewProgressInner.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
    
    labelIconShapeLayer = CAShapeLayer()
    labelIconShapeLayer.fillColor = Color.icon.cgColor
    labelIconShapeLayer.strokeColor = Color.icon.cgColor
    labelIconShapeLayer.path = iconPath.cgPath
    labelIconShapeLayer.lineJoin = .round
    labelIconShapeLayer.lineCap = .round
    labelIconShapeLayer.lineWidth = Dimension.IconLineWidth
    viewProgressInner.layer.addSublayer(labelIconShapeLayer)
    
    lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: iconPath.bounds.width, height: iconPath.bounds.height - 10))
    lblTitle.textAlignment = .center
    lblTitle.text = "0%"
    lblTitle.font = UIFont.systemFont(ofSize: 15.0)
    viewProgressInner.addSubview(lblTitle)
    
    showInitialProgress()
    self.setProgress(0)
  }
  
  func failed() {
    lblTitle.text = "Failed"
    lblTitle.textColor = Color.failed
    isFailed = true
    updateProgressBars()
  }
  
  private func showInitialProgress(){
    let path = UIBezierPath()
    path.move(to: CGPoint(x: padding, y: superView.frame.size.height/2))
    path.addLine(to: CGPoint(x: superView.frame.size.width-padding, y: superView.frame.size.height/2))
    
    barLayer = CAShapeLayer()
    barLayer.lineWidth = progressWidth
    barLayer.lineCap = .round
    barLayer.fillColor = UIColor.clear.cgColor
    barLayer.strokeColor = unProgressColor.cgColor
    barLayer.path = path.cgPath
    superView.layer.addSublayer(barLayer)
    
    progressLayer = CAShapeLayer()
    progressLayer.lineWidth = progressWidth
    progressLayer.lineCap = .round
    progressLayer.fillColor = UIColor.clear.cgColor
    progressLayer.strokeColor = progressColor.cgColor
    superView.layer.addSublayer(progressLayer)
  }
  
  func setProgress(_ progress : Int){
    self.progress = progress
    lblTitle.text = "\(Int(progress))%"
    updateProgressBars()
  }
  
  private func updateProgressBars() {
    let progress = CGFloat(self.progress)
    progressLayer.removeAllAnimations()
    
    if let timer = timer{
      timer.invalidate()
      self.timer = nil
    }
    
    let totalLineWidth = superView.frame.width-(padding*2)
    let progressLineWidth = (totalLineWidth*progress)/100
    
    var temp : CGFloat!
    
    if(progress<=50){
      temp = progress
    }else{
      temp = 100 - progress
    }
    
    let depth = (temp/50)*(radius/2)
    
    
    //Progress path
    var path = UIBezierPath()
    path.move(to: CGPoint(x: padding, y: superView.frame.size.height/2))
    path.addLine(to: CGPoint(x: progressLineWidth+padding, y: superView.frame.size.height/2+depth))
    progressLayer.path = path.cgPath
    
    //Bar path
    path = UIBezierPath()
    path.move(to: CGPoint(x: progressLineWidth+padding, y: superView.frame.size.height/2+depth))
    path.addLine(to: CGPoint(x: superView.frame.width-padding, y: superView.frame.size.height/2))
    barLayer.path = path.cgPath
    
    if progress == 100 {
      doneAnimation()
    } else if progress != 0 {
      stopBounceAnimation()
      bendAnimation()
      timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { [weak self] (_) in
        if let self = self{
          self.progressUpdateBounceAnimation(self.superView.frame.size.height/2+depth, progressDistanceX: progressLineWidth+self.padding, unprogressStartX: progressLineWidth+self.padding)
          self.timer = nil
        }
      })
    }
    // Set progress view position
    viewProgress.frame.origin.x = progressLineWidth + padding - (viewProgress.frame.size.width / 2)
    viewProgress.frame.origin.y = superView.frame.size.height/2+depth - viewProgress.frame.size.height/2 - Dimension.IconLineWidth

  }
  
  private func stopBounceAnimation() {
    progressLayer.removeAllAnimations()
    barLayer.removeAllAnimations()
    viewProgress.layer.removeAnimation(forKey: "BounceAnimationTitleView")
  }
  
  private func cleanUp() {
    viewProgress.removeFromSuperview()
    barLayer.removeFromSuperlayer()
    progressLayer.removeFromSuperlayer()
  }
  
  private func progressUpdateBounceAnimation(
    _ currentDepth : CGFloat,
    progressDistanceX : CGFloat,
    unprogressStartX : CGFloat
  ){
    
    if isFailed {
      labelIconShapeLayer.path = Path.failedProgressLabel.cgPath
      viewProgressInner.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
      var frame = lblTitle.frame
      frame.origin.y += 10
      lblTitle.frame = frame
    }
    
    let arrDepth = [currentDepth,currentDepth+3,currentDepth-2,currentDepth+1,currentDepth]
    let duration = 1.0
    let keyTimes = [0.0,0.25,0.50,0.75,1.0]
    
    let animationProgress = CAKeyframeAnimation(keyPath: "path")
    animationProgress.keyTimes = keyTimes as [NSNumber]
    animationProgress.values = arrDepth.map({ (depth) -> CGPath in
      let path = UIBezierPath()
      path.move(to: CGPoint(x: padding, y: superView.frame.size.height/2))
      path.addLine(to: CGPoint(x: progressDistanceX, y: depth))
      return path.cgPath
    })
    animationProgress.duration = duration
    
    let animationUnProgress = CAKeyframeAnimation(keyPath: "path")
    animationUnProgress.keyTimes = keyTimes as [NSNumber]
    animationUnProgress.values = arrDepth.map({ (depth) -> CGPath in
      let path = UIBezierPath()
      path.move(to: CGPoint(x: unprogressStartX, y: depth))
      path.addLine(to: CGPoint(x: superView.frame.width-padding, y: superView.frame.size.height/2))
      return path.cgPath
    })
    animationUnProgress.duration = duration
    
    viewProgress.layer.pause()
    viewProgress.layer.resetSpeed()
    let animationGroup = CAAnimationGroup()
    let animationTitleView = CAKeyframeAnimation(keyPath: "position.y")
    animationTitleView.keyTimes = keyTimes as [NSNumber]
    animationTitleView.values = arrDepth.map({ (depth) -> CGFloat in
      if isFailed {
        return depth + Dimension.IconLineWidth
      } else {
        return depth - Dimension.IconLineWidth
      }
    })
    animationTitleView.duration = duration
    
    let animationRotationTitleView = CAKeyframeAnimation(keyPath: "transform")
    animationRotationTitleView.keyTimes = keyTimes as [NSNumber]
    animationRotationTitleView.values = [
      viewProgress.layer.presentation()!.transform,
      rotation(0),
      rotation(10),
      rotation(-10),
      rotation(0)
    ]
    
    animationGroup.duration = duration
    animationGroup.isRemovedOnCompletion = false
    animationGroup.fillMode = .forwards
    animationGroup.delegate = self
    animationGroup.animations = [animationTitleView,  animationRotationTitleView]
    progressLayer.add(animationProgress, forKey: "AnimationProgress")
    barLayer.add(animationUnProgress, forKey: "AnimationUnProgress")
    viewProgress.layer.add(animationGroup , forKey: "BounceAnimationTitleView")
  }
  
  private func doneAnimation() {
    viewProgress.layer.pause()
    viewProgress.layer.resetSpeed()
    let animation = CABasicAnimation(keyPath: "transform")
    animation.fromValue = viewProgress.layer.presentation()!.transform
    animation.toValue = rotation(0.0)
    animation.duration = 0.1
    viewProgress.layer.add(animation, forKey: "BendAnimation")
    
    let keyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
    keyframeAnimation.keyTimes = [0.0,0.2,0.5,0.8,1.0]
    keyframeAnimation.values = [
      rotationY(0.0),
      rotationY(-45.0),
      rotationY(90.0),
      rotationY(-45.0),
      rotationY(0.0)
    ]
    keyframeAnimation.duration = 1.0
    keyframeAnimation.isRemovedOnCompletion = false
    keyframeAnimation.fillMode = .forwards
    viewProgress.layer.add(keyframeAnimation, forKey: "DoneRotationAnimation")
    
    UIView.animate(withDuration: keyframeAnimation.duration / 2.0, animations: { [weak self] in
      self?.lblTitle.alpha = 0.0
      }, completion: { [weak self] (isFinished) in
        if isFinished {
          self?.lblTitle.textColor = Color.done
          self?.lblTitle.font = UIFont.boldSystemFont(ofSize: 15.0)
          self?.lblTitle.text = "Done"
          
          UIView.animate(withDuration: keyframeAnimation.duration/2.0, animations: { [weak self] in
            self?.lblTitle.alpha = 1.0
            }, completion: { [weak self] (isFinished) in
              if isFinished {
                self?.animateDoneStateToInitialState()
              }
          })
        }
    })
  }
  
  private func animateFailedStateToInitialState() {
    lblTitle.isHidden = true
    progressLayer.isHidden = true
    barLayer.isHidden = true
    delegate?.willAnimateFailedIconToCenterPosition()
    
    var path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: 50, y: 0))
    path.addLine(to: CGPoint(x: 50, y: 20))
    path.addLine(to: CGPoint(x: 30, y: 20))
    path.addLine(to: CGPoint(x: 25, y: 20))
    path.addLine(to: CGPoint(x: 20, y: 20))
    path.addLine(to: CGPoint(x: 0, y: 20))
    path.addLine(to: CGPoint(x: 0, y: 0))
    
    let animationShapeChange = CABasicAnimation(keyPath: "path")
    animationShapeChange.fromValue = path.cgPath
    animationShapeChange.toValue = Path.downloadIcon.cgPath
    animationShapeChange.duration = 0.5
    animationShapeChange.fillMode = .forwards
    animationShapeChange.isRemovedOnCompletion = false
    labelIconShapeLayer.add(animationShapeChange, forKey: nil)
    
    labelIconShapeLayer.frame = Path.downloadIcon.bounds
    let animationIconPosition = CABasicAnimation(keyPath: "position")
    animationIconPosition.toValue = viewProgress.convert(CGPoint(x: viewProgress.frame.width/2, y: (viewProgress.frame.size.height/2) + Dimension.IconLineWidth), to: viewProgressInner)
    animationIconPosition.duration = 0.5
    animationIconPosition.fillMode = .forwards
    animationIconPosition.isRemovedOnCompletion = false
    labelIconShapeLayer.add(animationIconPosition, forKey: nil)

    path = UIBezierPath()
    var controlX: CGFloat = 0.0
    let diff = viewProgress.center.x - superView.frame.size.width/2
    if diff > 0 {
      controlX = superView.frame.size.width/2 + diff/2
    } else {
      controlX = viewProgress.center.x + abs(diff/2)
    }
    
    path.move(to: viewProgress.center)
    path.addQuadCurve(to: CGPoint(x: superView.frame.size.width/2, y: superView.frame.size.height/2), controlPoint: CGPoint(x: controlX, y: 0))
    let animationIconToCenter = CAKeyframeAnimation(keyPath: "position")
    animationIconToCenter.path = path.cgPath
    animationIconToCenter.duration = 0.5
    animationIconToCenter.fillMode = .forwards
    animationIconToCenter.isRemovedOnCompletion = false
    animationIconToCenter.delegate = self
    viewProgress.layer.add(animationIconToCenter, forKey: "FailedAnimation")
    
  }
  
  private func animateDoneStateToInitialState() {
    barLayer.removeFromSuperlayer()
    let path1 = UIBezierPath()
    let y = superView.frame.size.height/2
    path1.move(to: CGPoint(x: (Dimension.padding / 2), y: y))
    path1.addLine(to: CGPoint(x: superView.frame.size.width - (Dimension.padding / 2), y: y))

    let path2 = UIBezierPath()
    path2.move(to: CGPoint(x: superView.frame.size.width / 2, y: y))
    path2.addLine(to: CGPoint(x: superView.frame.size.width / 2, y: y))

    let animationProgressPath = CAKeyframeAnimation(keyPath: "path")
    animationProgressPath.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    animationProgressPath.keyTimes = [0.0, 0.4, 1.0]
    animationProgressPath.values = [progressLayer.path!, path1.cgPath, path2.cgPath]
    animationProgressPath.duration = 0.6
    animationProgressPath.fillMode = .forwards
    animationProgressPath.isRemovedOnCompletion = false
    progressLayer.add(animationProgressPath, forKey: nil)

    let animationRotation = CAKeyframeAnimation(keyPath: "transform")
    animationRotation.keyTimes = [0.0, 0.3, 0.5, 1.0]
    animationRotation.values = [rotation(0.0), rotation(-10), rotation(10.0), rotation(0)]

    let animationPosition = CAKeyframeAnimation(keyPath: "position.x")
    animationPosition.keyTimes = [0.0, 0.4, 1.0]
    animationPosition.values = [viewProgress.layer.position.x, superView.frame.size.width - (Dimension.padding / 2), superView.frame.size.width / 2]

    let animationGroup = CAAnimationGroup()
    animationGroup.delegate = self
    animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    animationGroup.animations = [animationRotation, animationPosition]
    animationGroup.duration = 0.6
    animationGroup.fillMode = .forwards
    animationGroup.isRemovedOnCompletion = false
    viewProgress.layer.add(animationGroup, forKey: "DoneIconToCenterAnimation")

    let animationOpacity = CAKeyframeAnimation(keyPath: "opacity")
    animationOpacity.keyTimes = [0.0, 0.4, 1.0]
    animationOpacity.values = [1.0, 1.0, 0.0]
    animationOpacity.duration = 0.6
    animationOpacity.fillMode = .forwards
    animationOpacity.isRemovedOnCompletion = false
    lblTitle.layer.add(animationOpacity, forKey: nil)
    
    let animationShapeChange = CABasicAnimation(keyPath: "path")
    animationShapeChange.beginTime = labelIconShapeLayer.convertTime(CACurrentMediaTime(), from: nil) + 0.6
    animationShapeChange.toValue = Path.downloadIcon.cgPath
    animationShapeChange.duration = 0.3
    animationShapeChange.fillMode = .forwards
    animationShapeChange.isRemovedOnCompletion = false
    labelIconShapeLayer.add(animationShapeChange, forKey: nil)
    
    labelIconShapeLayer.frame = Path.downloadIcon.bounds
    let animationIconPosition = CABasicAnimation(keyPath: "position")
    animationIconPosition.beginTime = labelIconShapeLayer.convertTime(CACurrentMediaTime(), from: nil) + 0.6
    animationIconPosition.toValue = viewProgress.convert(CGPoint(x: viewProgress.frame.width/2, y: (viewProgress.frame.size.height/2) + Dimension.IconLineWidth), to: viewProgressInner)
    animationIconPosition.duration = 0.5
    animationIconPosition.fillMode = .forwards
    animationIconPosition.isRemovedOnCompletion = false
    animationIconPosition.delegate = self
    labelIconShapeLayer.add(animationIconPosition, forKey: "DoneAnimation")
  }
  
  private func bendAnimation(){
    if !isBendAnimationPlayingOrPlayed {
      isBendAnimationPlayingOrPlayed = true
      let animation = CABasicAnimation(keyPath: "transform")
      if let layer = viewProgress.layer.presentation() {
        viewProgress.layer.pause()
        viewProgress.layer.resetSpeed()
        animation.fromValue = layer.transform
      }
      animation.toValue = rotation(-10.0)
      animation.duration = 0.3
      animation.isRemovedOnCompletion = false
      animation.fillMode = .forwards
      animation.delegate = self
      viewProgress.layer.add(animation, forKey: "BendAnimation")
    }
  }
  
  private func rotation(_ angle: CGFloat) -> CATransform3D {
    return CATransform3DMakeRotation(angle*CGFloat((Double.pi/180.0)),0,0,1)
  }
  
  private func rotationY(_ angle: CGFloat) -> CATransform3D {
    var transform = CATransform3DMakeRotation(angle*CGFloat((Double.pi/180.0)),0,1,0)
    transform.m34 = 1.0 / -500;
    return transform
  }
}

extension ProgressComputation: CAAnimationDelegate {
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if(viewProgress.layer.animation(forKey: "DoneIconToCenterAnimation") == anim){
      delegate?.doneIconReachedAtCenter()
    } else if (labelIconShapeLayer.animation(forKey: "DoneAnimation") == anim || viewProgress.layer.animation(forKey: "FailedAnimation") == anim) {
      cleanUp()
    } else if (viewProgress.layer.animation(forKey: "BounceAnimationTitleView") == anim && isFailed) {
      animateFailedStateToInitialState()
    }
  }
}

