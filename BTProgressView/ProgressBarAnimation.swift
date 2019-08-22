import UIKit

class ProgressBarAnimation : NSObject{
  
  private var radius : CGFloat
  private var frame : CGRect
  private var shapeLayer : CAShapeLayer!
  private var superLayer: CALayer!
  private var leftPoint : CGPoint!
  private var animationCompleted : (() -> (Void))!
  
  init(radius : CGFloat, frame : CGRect, superLayer: CALayer) {
    self.radius = radius
    self.frame = frame
    self.superLayer = superLayer
    leftPoint = CGPoint(x: frame.size.width/2 - radius, y: frame.size.height/2 - radius)
  }
  
  func createBar(completed: @escaping ()->(Void)){
    animationCompleted = completed
    createProgressLayer()
    
    DispatchQueue.main.async {[weak self] in
      self?.shapeLayer.path = self?.getPath(1)
      DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: { [weak self] in
        self?.shapeLayer.path = self?.getPath(2)
      })
    }
    
    let animation = CAKeyframeAnimation(keyPath: "path")
    animation.keyTimes = [0.0,0.25,0.50,0.75,1.0]
    animation.values = [getPath(3),getPath(4),getPath(5),getPath(6),getPath(7)]
    animation.beginTime = CACurrentMediaTime() + 0.1
    animation.duration = 0.5
    animation.fillMode = .forwards
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.isRemovedOnCompletion = false
    animation.delegate = self
    shapeLayer.add(animation, forKey: "ProgressCreation")
  }
  
  func animateFailedProgress() {
    createProgressLayer()
    
    let animationGroup = CAAnimationGroup()
    let animationPath = CAKeyframeAnimation(keyPath: "path")
    animationPath.keyTimes = [0.0,0.15,0.25,0.50,0.75,1.0]
    animationPath.values = [getPath(7),getPath(3),getPath(4),getPath(5),getPath(6),getPath(7)]
    
    let animationOpacity = CABasicAnimation(keyPath: "opacity")
    animationOpacity.toValue = 0.0
    
    animationGroup.duration = 0.5
    animationGroup.fillMode = .forwards
    animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animationGroup.isRemovedOnCompletion = false
    animationGroup.delegate = self
    animationGroup.animations = [animationPath, animationOpacity]

    shapeLayer.add(animationGroup, forKey: "FailedProgress")
  }
  
  private func createProgressLayer() {
    shapeLayer = CAShapeLayer()
    shapeLayer.strokeColor = Color.bar.cgColor
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineCap = .round
    shapeLayer.lineWidth = Dimension.progressWidth
    superLayer.addSublayer(shapeLayer)
  }
  
  private func getPath(_ no : Int) -> CGPath{
    switch no {
    case 1:
      return path1()
    case 2:
      return path2()
    case 3:
      return path3()
    case 4:
      return path4()
    case 5:
      return path5()
    case 6:
      return path6()
    case 7:
      return path7()
    default:
      return path2()
    }
  }
  
  private func path1() -> CGPath{
    let path = UIBezierPath()
    path.move(to: CGPoint(x: leftPoint.x-per(10), y: leftPoint.y+per(20)))
    path.addCurve(to: CGPoint(x: leftPoint.x, y: leftPoint.y+per(40)), controlPoint1: CGPoint(x: leftPoint.x-per(10), y: leftPoint.y+per(20)), controlPoint2: CGPoint(x: leftPoint.x, y: leftPoint.y+per(20)))
    path.addCurve(to: CGPoint(x: frame.size.width/2+radius, y: leftPoint.y+per(40)), controlPoint1: CGPoint(x: leftPoint.x, y: leftPoint.y+per(90)), controlPoint2: CGPoint(x: frame.size.width/2+radius, y: leftPoint.y+per(90)))
    path.addCurve(to: CGPoint(x: frame.size.width/2+radius+per(10), y: leftPoint.y+per(20)), controlPoint1: CGPoint(x: frame.size.width/2+radius, y: leftPoint.y+per(20)), controlPoint2: CGPoint(x: frame.size.width/2+radius+per(10), y: leftPoint.y+per(20)))
    return path.cgPath
  }
  
  private func path2() -> CGPath{
    let path = UIBezierPath()
    path.move(to: CGPoint(x: frame.size.width * 0.2, y: frame.size.height/2-per(15)))
    path.addQuadCurve(to: CGPoint(x: leftPoint.x, y: frame.size.height/2-per(5)), controlPoint: CGPoint(x: frame.size.width * 0.2+per(50), y: frame.size.height/2-per(30)))
    path.addCurve(to: CGPoint(x: leftPoint.x+(radius*2), y: frame.size.height/2-per(5)), controlPoint1: CGPoint(x: leftPoint.x+per(50), y: frame.size.height/2+per(30)), controlPoint2: CGPoint(x: leftPoint.x+(radius*2), y: frame.size.height/2-per(5)))
    path.addQuadCurve(to: CGPoint(x: frame.size.width-(frame.size.width * 0.2), y: frame.size.height/2-per(15)), controlPoint:CGPoint(x: frame.size.width-(frame.size.width * 0.2)-per(50), y: frame.size.height/2-per(30)))
    return path.cgPath
  }
  
  private func path3() -> CGPath{
    let path = UIBezierPath()
    path.move(to: CGPoint(x: Dimension.padding, y: frame.size.height/2))
    path.addQuadCurve(to: CGPoint(x: frame.size.width-Dimension.padding, y: frame.size.height/2), controlPoint: CGPoint(x: frame.size.width/2, y: frame.size.height/2 - radius))
    return path.cgPath
  }
  
  private func path4() -> CGPath{
    let path = UIBezierPath()
    path.move(to: CGPoint(x: Dimension.padding, y: frame.size.height/2))
    path.addQuadCurve(to: CGPoint(x: frame.size.width-Dimension.padding, y: frame.size.height/2), controlPoint: CGPoint(x: frame.size.width/2, y: frame.size.height/2 + radius))
    return path.cgPath
  }
  
  private func path5() -> CGPath{
    let path = UIBezierPath()
    path.move(to: CGPoint(x: Dimension.padding, y: frame.size.height/2))
    path.addQuadCurve(to: CGPoint(x: frame.size.width-Dimension.padding, y: frame.size.height/2), controlPoint: CGPoint(x: frame.size.width/2, y: frame.size.height/2 - radius + per(20)))
    return path.cgPath
  }
  
  private func path6() -> CGPath{
    let path = UIBezierPath()
    path.move(to: CGPoint(x: Dimension.padding, y: frame.size.height/2))
    path.addQuadCurve(to: CGPoint(x: frame.size.width-Dimension.padding, y: frame.size.height/2), controlPoint: CGPoint(x: frame.size.width/2, y: frame.size.height/2 + radius - per(20)))
    return path.cgPath
  }
  
  private func path7() -> CGPath{
    let path = UIBezierPath()
    path.move(to: CGPoint(x: Dimension.padding, y: frame.size.height/2))
    path.addQuadCurve(to: CGPoint(x: frame.size.width-Dimension.padding, y: frame.size.height/2), controlPoint: CGPoint(x: frame.size.width/2, y: frame.size.height/2))
    return path.cgPath
  }
  
  private func per(_ per : Int) -> CGFloat{
    return CGFloat((2 * radius * CGFloat(per))/100)
  }
}

extension ProgressBarAnimation : CAAnimationDelegate{
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    shapeLayer.removeFromSuperlayer()
    if shapeLayer.animation(forKey: "ProgressCreation") == anim {
      animationCompleted()
    }
  }
}

