//
//  AngleShape.swift
//  Drawsana
//
//  Created by Thanh Vu on 5/3/19.
//  Copyright © 2019 Asana. All rights reserved.
//
//  Modifications by Mikolaj Dawidowski on 5th-8th August 2022
//  Copyright © 2022 Mikolaj Dawidowski. All rights reserved.

import UIKit

public class AngleShape:
  ShapeWithThreePoints,
  ShapeWithStrokeState,
  ShapeSelectable
{
  private enum CodingKeys: String, CodingKey {
    case id, a, b, c, strokeColor, strokeWidth, capStyle, joinStyle,
    dashPhase, dashLengths, transform, type, a_percent, b_percent, c_percent, stroke_width_percent
  }
  
  public static let type: String = "Angle"
  
  public var id: String = UUID().uuidString
  public var a: CGPoint = .zero { didSet { a_percent = .zero } }
  var a_percent : CGPoint = .zero
  public var b: CGPoint = .zero { didSet { b_percent = .zero  } }
  var b_percent : CGPoint = .zero
  public var c: CGPoint = .zero { didSet { c_percent = .zero  } }
  var c_percent : CGPoint = .zero
  public var strokeColor: UIColor = .black
  public var strokeWidth: CGFloat = 10 { didSet { stroke_width_percent = 0.0 } }
  var stroke_width_percent: CGFloat = 0.0
  public var capStyle: CGLineCap = .round
  public var joinStyle: CGLineJoin = .round
  public var dashPhase: CGFloat?
  public var dashLengths: [CGFloat]?
  public var transform: ShapeTransform = .identity
  
  public func compute_percents_if_necessary( ContextWidth: Int , ContextHeight: Int){
    let context_width = CGFloat(ContextWidth)
    let context_height = CGFloat(ContextHeight)
    if(a_percent == .zero){ self.a_percent = CGPoint(x: a.x/context_width, y: a.y/context_height ) }
    if(b_percent == .zero){ b_percent = CGPoint(x: b.x/context_width, y: b.y/context_height ) }
    if(c_percent == .zero){ c_percent = CGPoint(x: c.x/context_width, y: c.y/context_height ) }
    if(stroke_width_percent == 0.0 ){ stroke_width_percent = strokeWidth/context_width }
    
    let local_a = a_percent
    let local_b = b_percent
    let local_c = c_percent
    a = CGPoint(x:a_percent.x * context_width, y: a_percent.y * context_height)
    a_percent = local_a
    
    b = CGPoint(x:b_percent.x * context_width, y: b_percent.y * context_height)
    b_percent = local_b

    c = CGPoint(x:c_percent.x * context_width, y: c_percent.y * context_height)
    c_percent = local_c
    
    let local_w_perc = stroke_width_percent
    strokeWidth = local_w_perc * context_width
    stroke_width_percent = local_w_perc
    
  }
  
  public init() {
  }
  
  public required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    let type = try values.decode(String.self, forKey: .type)
    if type != LineShape.type {
      throw DrawsanaDecodingError.wrongShapeTypeError
    }
    
    id = try values.decode(String.self, forKey: .id)
    a = try values.decode(CGPoint.self, forKey: .a)
    b = try values.decode(CGPoint.self, forKey: .b)
    c = try values.decode(CGPoint.self, forKey: .c)
    strokeColor = UIColor(hexString: try values.decode(String.self, forKey: .strokeColor))
    strokeWidth = try values.decode(CGFloat.self, forKey: .strokeWidth)
    transform = try values.decodeIfPresent(ShapeTransform.self, forKey: .transform) ?? .identity
    
    capStyle = CGLineCap(rawValue: try values.decodeIfPresent(Int32.self, forKey: .capStyle) ?? CGLineCap.round.rawValue)!
    joinStyle = CGLineJoin(rawValue: try values.decodeIfPresent(Int32.self, forKey: .joinStyle) ?? CGLineJoin.round.rawValue)!
    dashPhase = try values.decodeIfPresent(CGFloat.self, forKey: .dashPhase)
    dashLengths = try values.decodeIfPresent([CGFloat].self, forKey: .dashLengths)
    
    a_percent = try values.decode(CGPoint.self, forKey: .a_percent)
    b_percent = try values.decode(CGPoint.self, forKey: .b_percent)
    c_percent = try values.decode(CGPoint.self, forKey: .c_percent)
    stroke_width_percent = try values.decode(CGFloat.self, forKey: .stroke_width_percent)

  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(LineShape.type, forKey: .type)
    try container.encode(id, forKey: .id)
    try container.encode(a, forKey: .a)
    try container.encode(b, forKey: .b)
    try container.encode(c, forKey: .c)
    try container.encode(strokeColor.hexString, forKey: .strokeColor)
    try container.encode(strokeWidth, forKey: .strokeWidth)
    try container.encode(a_percent, forKey: .a_percent)
    try container.encode(b_percent, forKey: .b_percent)
    try container.encode(c_percent, forKey: .c_percent)
    try container.encode(stroke_width_percent, forKey: .stroke_width_percent)

    if !transform.isIdentity {
      try container.encode(transform, forKey: .transform)
    }
    
    if capStyle != .round {
      try container.encode(capStyle.rawValue, forKey: .capStyle)
    }
    if joinStyle != .round {
      try container.encode(joinStyle.rawValue, forKey: .joinStyle)
    }
    try container.encodeIfPresent(dashPhase, forKey: .dashPhase)
    try container.encodeIfPresent(dashLengths, forKey: .dashLengths)
  }
  
  public func render(in context: CGContext) {
    self.compute_percents_if_necessary(ContextWidth: context.width, ContextHeight: context.height)
    transform.begin(context: context)
    context.setLineCap(capStyle)
    context.setLineJoin(joinStyle)
    context.setLineWidth(strokeWidth)
    context.setStrokeColor(strokeColor.cgColor)
    if let dashPhase = dashPhase, let dashLengths = dashLengths {
      context.setLineDash(phase: dashPhase, lengths: dashLengths)
    } else {
      context.setLineDash(phase: 0, lengths: [])
    }
    context.move(to: a)
    context.addLine(to: b)
    context.move(to: b)
    context.addLine(to: c)
    context.strokePath()
    renderInfo(in: context)
    transform.end(context: context)
  }
  
  private func renderInfo(in context: CGContext) {
    if a == c {
      return
    }
    let center     = b
    var startAngle = atan2(a.y - b.y, a.x - b.x)
    var endAngle   = atan2(c.y - b.y, c.x - b.x)
    
    if 0 < endAngle - startAngle
      && endAngle - startAngle < CGFloat.pi { // swap startAngle & endAngle
      startAngle = startAngle + endAngle
      endAngle = startAngle - endAngle
      startAngle = startAngle - endAngle
    }
    
    context.setLineWidth(strokeWidth / 2)
    context.addArc(center: center, radius: 24, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    context.strokePath()
    context.setLineWidth(strokeWidth)
    
    renderDegreesInfo(in: context, startAngle: startAngle, endAngle: endAngle)
  }
  
  private func renderDegreesInfo(in context: CGContext, startAngle: CGFloat, endAngle: CGFloat) {
    let radius: CGFloat = 44
    let fontSize: CGFloat = 14
    let font = UIFont.systemFont(ofSize: fontSize)
    let string = NSAttributedString(string: "\(degreesBetweenThreePoints(pointA: a, pointB: b, pointC: c))°", attributes: [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.foregroundColor: strokeColor
      ])
    
    let normalEnd = startAngle < endAngle ? endAngle + 2 * CGFloat.pi : endAngle
    let centerAngle = startAngle + (normalEnd - startAngle) / 2
    let arcCenterX = b.x + cos(centerAngle) * radius - fontSize / 2
    let arcCenterY = b.y + sin(centerAngle) * radius - fontSize / 2
    string.draw(at: CGPoint(x: arcCenterX, y: arcCenterY))
  }
  
  private func degreesBetweenThreePoints(pointA: CGPoint, pointB: CGPoint, pointC: CGPoint) -> Int {
    let a = pow((pointB.x - pointA.x), 2) + pow((pointB.y - pointA.y), 2)
    let b = pow((pointB.x - pointC.x), 2) + pow((pointB.y - pointC.y), 2)
    let c = pow((pointC.x - pointA.x), 2) + pow((pointC.y - pointA.y), 2)
    if a == 0 || b == 0 {
      return 0
    }
    return Int(acos((a + b - c) / sqrt(4 * a * b) ) * 180 / CGFloat.pi)
  }
  
}
