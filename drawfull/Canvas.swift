//
//  Canvas.swift
//  drawfull
//
//  Created by Cambrian on 2023-07-24.
//

import UIKit

class Canvas: UIView {
    
    var currentLines = [NSValue: Line]()
    var finishedLines = [Line]()
    var selectedLine: Line?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTab(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapGestureRecognizer)
        
        let longTouchGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longTouchGestureRecognizer.minimumPressDuration = 1
        longTouchGestureRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(longTouchGestureRecognizer)
    }
    
    @objc func doubleTab(_ gestureRecognizer: UIGestureRecognizer){
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()
    }
    
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer){
        let position = gestureRecognizer.location(in: self)
        
        let index = indexOfLine(at: position)
        
        if let index = index {
            selectedLine = finishedLines[index]
        } else {
            selectedLine = nil
        }
        
        setNeedsDisplay()
    }
    
    func stroke(line: Line){
        let path = UIBezierPath()
        path.lineWidth = 10
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
        
    }
    
    override func draw(_ rect: CGRect){
        UIColor.black.setStroke()
        for finishedLine in finishedLines {
            stroke(line: finishedLine)
        }
        
        UIColor.red.setStroke()
        for (_, currentLine) in currentLines {
            stroke(line: currentLine)
        }
        
        UIColor.green.setStroke()
        if let selectedLine = selectedLine {
            stroke(line: selectedLine)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let position = touch.location(in: self)
            
            let newLine = Line(begin: position, end: position)
            
            let key = NSValue(nonretainedObject: touch)
            
            currentLines[key] = newLine
            
        }
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let position = touch.location(in: self)
            
            let key = NSValue(nonretainedObject: touch)
            
            currentLines[key]!.end = position
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let position = touch.location(in: self)
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = position
            finishedLines.append(currentLines[key]!)
            
            currentLines.removeValue(forKey: key)
        }
        
        setNeedsDisplay()
    }
    
    func indexOfLine(at point: CGPoint) -> Int? {
        // Find a line close to point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
            // Check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                // If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0 {
                    return index
                }
            }
            // If nothing is close enough to the tapped point, then we did not select a line
        }
        
        return nil
    }
}
