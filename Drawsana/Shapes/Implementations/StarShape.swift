//
//  StarShape.swift
//  Drawsana
//
//  Created by Madan Gupta on 24/12/18.
//  Copyright © 2018 Asana. All rights reserved.
//
//  Modifications by Mikolaj Dawidowski on 5th-8th August 2022
//  Copyright © 2022 Mikolaj Dawidowski. All rights reserved.

import UIKit

public class StarShape:
    ShapeWithTwoPoints,
    ShapeWithStandardState,
    ShapeSelectable
{
    private enum CodingKeys: String, CodingKey {
        case id, a, b, strokeColor, fillColor, strokeWidth, capStyle, joinStyle,
        dashPhase, dashLengths, transform, type, a_percent, b_percent, stroke_width_percent
    }
    
    public static let type: String = "Star"
    
    public var id: String = UUID().uuidString
    public var a: CGPoint = .zero { didSet { a_percent = .zero } }
    var a_percent : CGPoint = .zero
    public var b: CGPoint = .zero { didSet { b_percent = .zero  } }
    var b_percent : CGPoint = .zero
    public var strokeWidth: CGFloat = 10 { didSet { stroke_width_percent = 0.0 } }
    var stroke_width_percent: CGFloat = 0.0
    public var strokeColor: UIColor? = .black
    public var fillColor: UIColor? = .clear
    
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
  
    public var boundingRect: CGRect {
        return squareRect
    }
    
    public init() {
        
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try values.decode(String.self, forKey: .type)
        if type != StarShape.type {
            throw DrawsanaDecodingError.wrongShapeTypeError
        }
        
        id = try values.decode(String.self, forKey: .id)
        a = try values.decode(CGPoint.self, forKey: .a)
        b = try values.decode(CGPoint.self, forKey: .b)
        
        strokeColor = try values.decodeColorIfPresent(forKey: .strokeColor)
        fillColor = try values.decodeColorIfPresent(forKey: .fillColor)
        
        strokeWidth = try values.decode(CGFloat.self, forKey: .strokeWidth)
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
        try container.encode(StarShape.type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(a, forKey: .a)
        try container.encode(b, forKey: .b)
        try container.encode(strokeColor?.hexString, forKey: .strokeColor)
        try container.encode(fillColor?.hexString, forKey: .fillColor)
        try container.encode(strokeWidth, forKey: .strokeWidth)
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
        
        if let fillColor = fillColor {
            context.setFillColor(fillColor.cgColor)
            context.addPath(starPath(x: squareRect.midX, y: squareRect.midY, radius: (squareRect.width - strokeWidth)/4, sides: 5, pointyness: 2.5,startAngle: 54))    // star
            context.fillPath()
        }
        
        context.setLineCap(capStyle)
        context.setLineJoin(joinStyle)
        context.setLineWidth(strokeWidth)
        
        if let strokeColor = strokeColor {
            context.setStrokeColor(strokeColor.cgColor)
            if let dashPhase = dashPhase, let dashLengths = dashLengths {
                context.setLineDash(phase: dashPhase, lengths: dashLengths)
            } else {
                context.setLineDash(phase: 0, lengths: [])
            }
            context.addPath(starPath(x: squareRect.midX, y: squareRect.midY, radius: (squareRect.width - strokeWidth)/4, sides: 5, pointyness: 2.5,startAngle: 54))    // star
            context.strokePath()
        }
        
        transform.end(context: context)
    }
    
    func starPointArray(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,adjustment:CGFloat=0)->[CGPoint] {
        let angle = (360/CGFloat(sides)).radians
        let cx = x // x origin
        let cy = y // y origin
        let r  = radius // radius of circle
        var i = sides
        var points = [CGPoint]()
        while points.count <= sides {
            let xpo = cx - r * cos(angle * CGFloat(i)+adjustment.radians)
            let ypo = cy - r * sin(angle * CGFloat(i)+adjustment.radians)
            points.append(CGPoint(x: xpo, y: ypo))
            i -= 1;
        }
        return points
    }
    
    func starPath(x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, pointyness:CGFloat, startAngle:CGFloat=0) -> CGPath {
        let adjustment = startAngle + CGFloat(360/sides/2)
        let path = CGMutablePath.init()
        let points = starPointArray(sides: sides,x: x,y: y,radius: radius, adjustment: startAngle)
        let cpg = points[0]
        let points2 = starPointArray(sides: sides,x: x,y: y,radius: radius*pointyness,adjustment:CGFloat(adjustment))
        var i = 0
        path.move(to: CGPoint(x:cpg.x,y:cpg.y))
        for p in points {
            path.addLine(to: CGPoint(x:points2[i].x, y:points2[i].y))
            path.addLine(to: CGPoint(x:p.x, y:p.y))
            i += 1
        }
        path.closeSubpath()
        return path
    }
    
    func polygonPointArray(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,offset:CGFloat)->[CGPoint] {
        let angle = (360/CGFloat(sides)).radians
        let cx = x // x origin
        let cy = y // y origin
        let r = radius // radius of circle
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpo = cx + r * cos(angle * CGFloat(i) - offset.radians)
            let ypo = cy + r * sin(angle * CGFloat(i) - offset.radians)
            points.append(CGPoint(x: xpo, y: ypo))
            i += 1
        }
        return points
    }
    
    func polygonPath(x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, offset: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let points = polygonPointArray(sides: sides,x: x,y: y,radius: radius, offset: offset)
        let cpg = points[0]
        path.move(to: cpg)
        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
}

