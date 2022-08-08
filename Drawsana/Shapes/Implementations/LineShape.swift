//
//  Shape_Ellipse_Rect_Line.swift
//  Drawsana
//
//  Created by Steve Landey on 8/2/18.
//  Copyright © 2018 Asana. All rights reserved.
//
//  Modifications by Mikolaj Dawidowski on 5th-8th August 2022
//  Copyright © 2022 Mikolaj Dawidowski. All rights reserved.

import UIKit

public class LineShape:
  ShapeWithTwoPoints,
  ShapeWithStrokeState,
  ShapeSelectable
{
  private enum CodingKeys: String, CodingKey {
    case id, a, b, strokeColor, strokeWidth, capStyle, joinStyle,
    dashPhase, dashLengths, transform, type, arrowStyle, a_percent, b_percent,stroke_width_percent
  }

  public enum ArrowStyle: String, Codable {
    /// Plain old triangle
    case standard
  }

  public static let type: String = "Line"

  public var id: String = UUID().uuidString
  public var a: CGPoint = .zero { didSet { a_percent = .zero } }
  public var b: CGPoint = .zero { didSet { b_percent = .zero } }
  var a_percent : CGPoint = .zero
  var b_percent : CGPoint = .zero
  public var strokeColor: UIColor = .black
  public var strokeWidth: CGFloat = 10 { didSet { stroke_width_percent = 0.0 } }
  var stroke_width_percent : CGFloat = 0.0
  public var capStyle: CGLineCap = .round
  public var joinStyle: CGLineJoin = .round
  public var dashPhase: CGFloat?
  public var dashLengths: [CGFloat]?
  public var arrowStyle: ArrowStyle?
  public var transform: ShapeTransform = .identity

  public func compute_percents_if_necessary( ContextWidth: Int , ContextHeight: Int){
    let context_width = CGFloat(ContextWidth)
    let context_height = CGFloat(ContextHeight)
    if(a_percent == .zero){ self.a_percent = CGPoint(x: a.x/context_width, y: a.y/context_height ) }
    if(b_percent == .zero){ b_percent = CGPoint(x: b.x/context_width, y: b.y/context_height ) }
    if(stroke_width_percent == 0.0 ){ stroke_width_percent = strokeWidth/context_width }
    
    let local_a = a_percent
    let local_b = b_percent
    a = CGPoint(x:a_percent.x * context_width, y: a_percent.y * context_height)
    a_percent = local_a
    
    b = CGPoint(x:b_percent.x * context_width, y: b_percent.y * context_height)
    b_percent = local_b
    
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
    strokeColor = UIColor(hexString: try values.decode(String.self, forKey: .strokeColor))
    strokeWidth = try values.decode(CGFloat.self, forKey: .strokeWidth)
    arrowStyle = try values.decodeIfPresent(ArrowStyle.self, forKey: .arrowStyle)
    transform = try values.decodeIfPresent(ShapeTransform.self, forKey: .transform) ?? .identity

    capStyle = CGLineCap(rawValue: try values.decodeIfPresent(Int32.self, forKey: .capStyle) ?? CGLineCap.round.rawValue)!
    joinStyle = CGLineJoin(rawValue: try values.decodeIfPresent(Int32.self, forKey: .joinStyle) ?? CGLineJoin.round.rawValue)!
    dashPhase = try values.decodeIfPresent(CGFloat.self, forKey: .dashPhase)
    dashLengths = try values.decodeIfPresent([CGFloat].self, forKey: .dashLengths)

    a_percent = try values.decode(CGPoint.self, forKey: .a_percent)
    b_percent = try values.decode(CGPoint.self, forKey: .b_percent)
    stroke_width_percent = try values.decode(CGFloat.self, forKey: .stroke_width_percent)

  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(LineShape.type, forKey: .type)
    try container.encode(id, forKey: .id)
    try container.encode(a, forKey: .a)
    try container.encode(b, forKey: .b)
    try container.encode(strokeColor.hexString, forKey: .strokeColor)
    try container.encode(strokeWidth, forKey: .strokeWidth)
    try container.encodeIfPresent(arrowStyle, forKey: .arrowStyle)
    try container.encode(a_percent, forKey: .a_percent)
    try container.encode(b_percent, forKey: .b_percent)
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
    context.strokePath()

    if case .some(.standard) = arrowStyle {
      renderArrow(in: context)
    }
    transform.end(context: context)
  }

  private func renderArrow(in context: CGContext) {
    let angle = atan2(b.y - a.y, b.x - a.x)
    let arcAmount: CGFloat = CGFloat.pi / 4
    let radius = strokeWidth * 4

    // Nudge arrow out past end of line a little so it doesn't let the line below show through when it's thick
    let arrowOffset = CGPoint(angle: angle, radius: strokeWidth * 2)

    let startPoint = b + arrowOffset
    let point1 = b + CGPoint(angle: angle + arcAmount / 2 + CGFloat.pi, radius: radius) + arrowOffset
    let point2 = b + CGPoint(angle: angle - arcAmount / 2 + CGFloat.pi, radius: radius) + arrowOffset

    context.setLineWidth(0)
    context.setFillColor(strokeColor.cgColor)
    context.move(to: startPoint)
    context.addLine(to: point1)
    context.addLine(to: point2)
    context.fillPath()
  }
}
