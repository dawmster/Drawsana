//
//  TextShape.swift
//  Drawsana
//
//  Created by Steve Landey on 8/3/18.
//  Copyright © 2018 Asana. All rights reserved.
//
//  Modifications by Mikolaj Dawidowski on 5th-8th August 2022
//  Copyright © 2022 Mikolaj Dawidowski. All rights reserved.

import UIKit

public class TextShape: Shape, ShapeSelectable {
  private enum CodingKeys: String, CodingKey {
    case id, transform, text, fontName, fontSize, fillColor, type,
      explicitWidth, boundingRect,
      offset_percentage,
      offset_transform_orig,
      scale_percentage,
      scale_transform_orig

    
    
  }

  public static let type = "Text"

  public var id: String = UUID().uuidString
  /// This shape is positioned entirely with `TextShape.transform.translate`,
  /// rather than storing an explicit position.
  public var transform: ShapeTransform = .identity
  var offset_percentage: CGPoint = .zero
  var offset_transform_orig: CGPoint = .zero
  var scale_percentage: CGFloat = 0.0
  var scale_transform_orig: CGFloat = 0.0

  public var text = ""
  public var fontName: String = "Helvetica Neue"
  public var fontSize: CGFloat = 24
  public var fillColor: UIColor = .black
  /// If user drags the text box to an exact width, we need to respect it instead
  /// of automatically sizing the text box to fit the text.
  public var explicitWidth: CGFloat?

  /// Set to true if this text is being shown in some other way, i.e. in a
  /// `UITextView` that the user is editing.
  public var isBeingEdited: Bool = false

  public var boundingRect: CGRect = .zero

  var font: UIFont {
    return UIFont(name: fontName, size: fontSize)!
  }

  public func compute_percents_if_necessary( ContextWidth: Int , ContextHeight: Int){
    let context_width = CGFloat(ContextWidth)
    let context_height = CGFloat(ContextHeight)
    if( transform.translation != offset_transform_orig ){
      offset_percentage.x = transform.translation.x / context_width
      offset_percentage.y = transform.translation.y / context_height
      offset_transform_orig = transform.translation
    }
    
    transform.translation = CGPoint(x: offset_percentage.x * context_width, y: offset_percentage.y * context_height)

    if( transform.scale != scale_transform_orig ){
      scale_transform_orig = transform.scale
      
      scale_percentage = transform.scale / context_width
    }
    transform.scale = scale_percentage * context_width
  }
  public init() {
  }

  public required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    let type = try values.decode(String.self, forKey: .type)
    if type != TextShape.type {
      throw DrawsanaDecodingError.wrongShapeTypeError
    }

    id = try values.decode(String.self, forKey: .id)
    text = try values.decode(String.self, forKey: .text)
    fontName = try values.decode(String.self, forKey: .fontName)
    fontSize = try values.decode(CGFloat.self, forKey: .fontSize)
    fillColor = UIColor(hexString: try values.decode(String.self, forKey: .fillColor))
    explicitWidth = try values.decodeIfPresent(CGFloat.self, forKey: .explicitWidth)
    boundingRect = try values.decodeIfPresent(CGRect.self, forKey: .boundingRect) ?? .zero
    transform = try values.decode(ShapeTransform.self, forKey: .transform)
    offset_percentage = try values.decode(CGPoint.self, forKey: .offset_percentage)
    offset_transform_orig = try values.decode(CGPoint.self, forKey: .offset_transform_orig)
    scale_percentage = try values.decode(CGFloat.self, forKey: .scale_percentage)
    scale_transform_orig = try values.decode(CGFloat.self, forKey: .scale_transform_orig)

    if boundingRect == .zero {
      print("Text bounding rect not present. This shape will not render correctly because of a bug in Drawsana <0.10.0.")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(TextShape.type, forKey: .type)
    try container.encode(id, forKey: .id)
    try container.encode(text, forKey: .text)
    try container.encode(fontName, forKey: .fontName)
    try container.encode(fillColor.hexString, forKey: .fillColor)
    try container.encode(fontSize, forKey: .fontSize)
    try container.encodeIfPresent(explicitWidth, forKey: .explicitWidth)
    try container.encode(transform, forKey: .transform)
    try container.encode(boundingRect, forKey: .boundingRect)
    try container.encode(offset_percentage, forKey: .offset_percentage)
    try container.encode(offset_transform_orig, forKey: .offset_transform_orig)
    try container.encode(scale_percentage, forKey: .scale_percentage)
    try container.encode(scale_transform_orig, forKey: .scale_transform_orig)

    
  }

  public func render(in context: CGContext) {
    self.compute_percents_if_necessary(ContextWidth: context.width, ContextHeight: context.height)

    if isBeingEdited { return }
    transform.begin(context: context)
    (self.text as NSString).draw(
      in: CGRect(origin: boundingRect.origin, size: self.boundingRect.size),
      withAttributes: [
        .font: self.font,
        .foregroundColor: self.fillColor,
      ])
    transform.end(context: context)
  }

  public func apply(userSettings: UserSettings) {
    fillColor = userSettings.strokeColor ?? .black
    fontName = userSettings.fontName
    fontSize = userSettings.fontSize
  }
}
