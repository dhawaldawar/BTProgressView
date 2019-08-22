import Foundation
import UIKit


struct Icon {
  
  static func updateProperties(layer: CAShapeLayer) {
    layer.lineJoin = .round
    layer.lineCap = .round
    layer.fillColor = Color.icon.cgColor
    layer.strokeColor = Color.icon.cgColor
    layer.lineWidth = Dimension.IconLineWidth
  }

}

struct Path {
  
  static var progressLabel: UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: 50, y: 0))
    path.addLine(to: CGPoint(x: 50, y: 20))
    path.addLine(to: CGPoint(x: 30, y: 20))
    path.addLine(to: CGPoint(x: 25, y: 30))
    path.addLine(to: CGPoint(x: 20, y: 20))
    path.addLine(to: CGPoint(x: 0, y: 20))
    path.addLine(to: CGPoint(x: 0, y: 0))
    return path
  }
  
  static var failedProgressLabel: UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 10))
    path.addLine(to: CGPoint(x: 20, y: 10))
    path.addLine(to: CGPoint(x: 25, y: 0))
    path.addLine(to: CGPoint(x: 30, y: 10))
    path.addLine(to: CGPoint(x: 50, y: 10))
    path.addLine(to: CGPoint(x: 50, y: 30))
    path.addLine(to: CGPoint(x: 0, y: 30))
    path.addLine(to: CGPoint(x: 0, y: 10))
    return path
  }
  
  static var downloadIcon: UIBezierPath {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 10, y: 0))
    path.addLine(to: CGPoint(x: 30, y: 0))
    path.addLine(to: CGPoint(x: 30, y: 20))
    path.addLine(to: CGPoint(x: 40, y: 20))
    path.addLine(to: CGPoint(x: 20, y: 40))
    path.addLine(to: CGPoint(x: 00, y: 20))
    path.addLine(to: CGPoint(x: 10, y: 20))
    path.addLine(to: CGPoint(x: 10, y: 0))
    return path
  }
  
}
