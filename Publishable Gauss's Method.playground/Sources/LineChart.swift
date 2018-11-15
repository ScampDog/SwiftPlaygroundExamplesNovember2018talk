import UIKit

public extension String {
    public func size(withSystemFontSize pointSize: CGFloat) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: pointSize)])
    }
}

public extension CGPoint {
    public func adding(x: CGFloat) -> CGPoint { return CGPoint(x: self.x + x, y: self.y) }
    public func adding(y: CGFloat) -> CGPoint { return CGPoint(x: self.x, y: self.y + y) }
}

public class LineChart: UIView {
    let lineLayer = CAShapeLayer()
    let circlesLayer = CAShapeLayer()
    
    var chartTransform: CGAffineTransform?
    
    @IBInspectable public var lineColor: UIColor = UIColor.green {
        didSet {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }
    
    @IBInspectable public var lineWidth: CGFloat = 1
    
    @IBInspectable public var circleColor: UIColor = UIColor.green {
        didSet {
            circlesLayer.fillColor = circleColor.cgColor
        }
    }
    
    @IBInspectable public var circleSizeMultiplier: CGFloat = 3
    
    @IBInspectable public var axisColor: UIColor = UIColor.white
    @IBInspectable public var showInnerLines: Bool = true
    @IBInspectable public var showPoints = true
    @IBInspectable public var labelFontSize: CGFloat = 10
    
    public var nXticks = 5
    public var nYticks = 6
    var xAxisData = AxisData(dataMax: 80, dataMin: 0, nTicks: 5)
    var yAxisData = AxisData(dataMax: 100, dataMin: 0, nTicks: 6)
    
    public var axisLineWidth: CGFloat = 1
    public var deltaX: CGFloat = 10
    public var deltaY: CGFloat = 10
    public var xMax: CGFloat = 100
    public var yMax: CGFloat = 100
    public var xMin: CGFloat = 0
    public var yMin: CGFloat = 0
    var xNumberFormatter = NumberFormatter()
    var yNumberFormatter = NumberFormatter()

    public var data: [CGPoint]?
    
    public var xTitle: String?
    public var yTitle: String?
    public var chartTitle: String?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        combinedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        combinedInit()
    }
    
    public func combinedInit() {
        layer.addSublayer(lineLayer)
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineColor.cgColor
        
        layer.addSublayer(circlesLayer)
        circlesLayer.fillColor = circleColor.cgColor
        
        layer.borderWidth = 1
        layer.borderColor = axisColor.cgColor
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = bounds
        circlesLayer.frame = bounds
        
        if let d = data {
            setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
            plot(d)
        }
    }
    
    public override func draw(_ rect: CGRect) {
        // draw rect comes with a drawing context, so let's grab it.
        // Also, if there is not yet a chart transform, we will bail on performing any other drawing.
        // I like guard statements for this because it's kind of like a bouncer to a bar.
        // If you don't have your transform yet, you can't enter drawAxes.
        guard let context = UIGraphicsGetCurrentContext(), let t = chartTransform else { return }
        drawAxes(in: context, usingTransform: t)
    }
    
    public func drawAxes(in context: CGContext, usingTransform t: CGAffineTransform) {
        context.saveGState()
        
        // make two paths, one for thick lines, one for thin
        let thickerLines = CGMutablePath()
        let thinnerLines = CGMutablePath()
        
        if let data = data {
            print("Data limits are \(data[0]), \(data[data.count-1])")
        } else {
            print("No data yet")
        }
        
        // the two line chart axes
        let xAxisLocation = (yMin < 0 && yMax > 0) ? 0.0 : yMin
        let xAxisPoints = [CGPoint(x: xMin, y: xAxisLocation), CGPoint(x: xMax, y: xAxisLocation)]
        let yAxisLocation = (xMin < 0 && xMax > 0) ? 0.0 : xMin
        let yAxisPoints = [CGPoint(x: yAxisLocation, y: yMin), CGPoint(x: yAxisLocation, y: yMax)]
        
        // add each to thicker lines but apply our transform too.
        thickerLines.addLines(between: xAxisPoints, transform: t)
        thickerLines.addLines(between: yAxisPoints, transform: t)
        
        let axisLabelAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: labelFontSize), NSAttributedString.Key.foregroundColor: axisColor]
       
        print("xLabelFormatter has \(xAxisData.labelNumberFormatter.maximumFractionDigits) digits after the decimal point")
        // next we go from xMin to xMax by deltaX using stride
        for x in stride(from: xAxisData.scaleMin, through: xAxisData.scaleMax, by: xAxisData.step) {
            
            // tick points are the points for the ticks on each axis
            // we check showInnerLines first to see if we are drawing small ticks or full lines
            // tip for new guys: `let a = someBool ? b : c`  is called a ternary operator
            // in english it means "let a = b if somebool is true, or c if it is false."
            
            print("drawing x = \(x) gridline")
            
            let tickPoints = showInnerLines ?
                [CGPoint(x: x, y: yAxisData.scaleMin).applying(t), CGPoint(x: x, y: yAxisData.scaleMax).applying(t)] :
                [CGPoint(x: x, y: 0).applying(t), CGPoint(x: x, y: 0).applying(t).adding(y: -5)]
            
            
            thinnerLines.addLines(between: tickPoints)
            if x != 0 {  // draw the tick label (it is too busy if you draw it at the origin for both x & y
                // let factor = pow(10.0, ceil(log10(deltaX))-1)
                let label = xAxisData.labelNumberFormatter.string(for: x)! as NSString
                // let label = "\(floor(x/factor)*factor)" as NSString
                let labelSize = label.size(withAttributes: axisLabelAttributes)
                let labelDrawPoint = CGPoint(x: x, y: yAxisData.scaleMin).applying(t)
                    .adding(x: -labelSize.width/2)
                    .adding(y: 1)
                
                label.draw(at: labelDrawPoint,
                           withAttributes:
                    [NSAttributedString.Key.font: UIFont.systemFont(ofSize: labelFontSize),
                     NSAttributedString.Key.foregroundColor: axisColor])
            }
        }
        
        // repeat for y
        for y in stride(from: yAxisData.scaleMin, through: yAxisData.scaleMax, by: yAxisData.step) {
            
            let tickPoints = showInnerLines ?
                [CGPoint(x: xAxisData.scaleMin, y: y).applying(t), CGPoint(x: xAxisData.scaleMax, y: y).applying(t)] :
                [CGPoint(x: 0, y: y).applying(t), CGPoint(x: 0, y: y).applying(t).adding(x: 5)]
            
            print("drawing y = \(y) gridline")
            
            thinnerLines.addLines(between: tickPoints)
            
            if y != 2*yAxisData.scaleMax {
                // let label = "\(Int(y))" as NSString
                let label = yAxisData.labelNumberFormatter.string(for: y)! as NSString
                let labelSize = label.size(withAttributes: axisLabelAttributes)
                let labelDrawPoint = CGPoint(x: xAxisData.scaleMin, y: y).applying(t)
                    .adding(x: -labelSize.width - 2)
                    .adding(y: -labelSize.height/2)
                
                label.draw(at: labelDrawPoint,
                           withAttributes:
                    [NSAttributedString.Key.font: UIFont.systemFont(ofSize: labelFontSize),
                     NSAttributedString.Key.foregroundColor: axisColor])
            }
        }
        // finally set stroke color & line width then stroke thick lines, repeat for thin
        context.setStrokeColor(axisColor.cgColor)
        context.setLineWidth(axisLineWidth)
        context.addPath(thickerLines)
        context.strokePath()
        
        let axisTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 1.2*labelFontSize), NSAttributedString.Key.foregroundColor: axisColor]
        if let xTitle = xTitle {
            let title = xTitle as NSString
            let titleSize = title.size(withAttributes: axisTitleAttributes)
            let xOffset = titleSize.width/2
            let yOffset = titleSize.height
            title.draw(at: CGPoint(x: (xMin+xMax)/2, y: yMin).applying(t).adding(x: -xOffset).adding(y: yOffset), withAttributes: axisTitleAttributes)
        }
        
        if let yTitle = yTitle {
            let title = yTitle as NSString
            let titleSize = title.size(withAttributes: axisTitleAttributes)
            let xOffset = -titleSize.width
            let yOffset = -titleSize.height/2
            var titleLocation = CGPoint(x: xMin, y: (yMin+yMax)/2).applying(t).adding(x: xOffset).adding(y: yOffset)
            titleLocation.x = 3
            title.draw(at: titleLocation, withAttributes: axisTitleAttributes)
        }
        
        if let chartTitle = chartTitle {
            let title = chartTitle as NSString
            let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 1.5*labelFontSize), NSAttributedString.Key.foregroundColor: axisColor]
            let titleSize = title.size(withAttributes: titleAttributes)
            let xOffset = -titleSize.width/2
            let yOffset = titleSize.height
            title.draw(at: CGPoint(x: (xMax+xMin)/2, y: yMax).applying(t).adding(x: xOffset).adding(y: -1.5*yOffset), withAttributes: titleAttributes)
        }
        
        context.setStrokeColor(axisColor.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(axisLineWidth/2)
        context.addPath(thinnerLines)
        context.strokePath()
        
        context.restoreGState()
        // whenever you change a graphics context you should save it prior and restore it after
        // if we were using a context other than draw(rect) we would have to also end the graphics context
    }
    
    public func plot(_ points: [CGPoint]) {
        lineLayer.path = nil
        circlesLayer.path = nil
        data = nil
        
        guard !points.isEmpty else { return }
        
        self.data = points
        
        if self.chartTransform == nil {
            setAxisRange(forPoints: points)
        }
        
        let linePath = CGMutablePath()
        linePath.addLines(between: points, transform: chartTransform!)
        
        lineLayer.path = linePath
        
        if showPoints {
            circlesLayer.path = circles(atPoints: points, withTransform: chartTransform!)
        }
        
        
    }
    
    public func circles(atPoints points: [CGPoint], withTransform t: CGAffineTransform) -> CGPath {
        
        let path = CGMutablePath()
        let radius = lineLayer.lineWidth * circleSizeMultiplier/2
        for i in points {
            let p = i.applying(t)
            let rect = CGRect(x: p.x - radius, y: p.y - radius, width: radius * 2, height: radius * 2)
            path.addEllipse(in: rect)
            
        }
        
        return path
    }
    
    public func setAxisRange(forPoints points: [CGPoint]) {
        guard !points.isEmpty else { return }
        
        print("setAxisRange(forPoints:)")
        
        let xs = points.map() { $0.x }
        let ys = points.map() { $0.y }
        
        xMax = xs.max()!
        xMin = xs.min()!
        yMax = ys.max()!
        yMin = ys.min()!
        xAxisData = AxisData(dataMax: Double(xMax), dataMin: Double(xMin), nTicks: nXticks)
        yAxisData = AxisData(dataMax: Double(yMax), dataMin: Double(yMin), nTicks: nYticks)
        xMax = CGFloat(xAxisData.scaleMax)
        xMin = CGFloat(xAxisData.scaleMin)
        deltaX = CGFloat(xAxisData.step)
        xNumberFormatter = xAxisData.labelNumberFormatter
        yMax = CGFloat(yAxisData.scaleMax)
        yMin = CGFloat(yAxisData.scaleMin)
        deltaY = CGFloat(yAxisData.step)
        yNumberFormatter = yAxisData.labelNumberFormatter
        
        print("xMin = \(xMin), xMax = \(xMax), \(nXticks) ticks, yMin = \(yMin), yMax = \(yMax), \(nYticks)")
        setTransform(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
    }
    
    public func setTransform(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        
        var xGap: CGFloat = 0.0
        var yGap: CGFloat = 0.0
        var xOffset: CGFloat = 0.0
        var yOffset: CGFloat = 0.0
        
        if let title = xTitle {
            let titleSize = title.size(withSystemFontSize: 1.2*labelFontSize)
            yGap += titleSize.height + 2
            yOffset += titleSize.height + 2
        }
        
        if let title = yTitle {
            let titleSize = title.size(withSystemFontSize: 1.2*labelFontSize)
            xGap += titleSize.height + 2
            xOffset += titleSize.height + 2
        }
        
        if let title = chartTitle {
            let titleSize = title.size(withSystemFontSize: 1.5*labelFontSize)
            yGap += titleSize.height + 2
        }
        
        let xLabelSize = "\(floor(maxX*10)/10)".size(withSystemFontSize: labelFontSize)
        
        let yLabelSize = "\(floor(maxY*10)/10)".size(withSystemFontSize: labelFontSize)
        
        xOffset += xLabelSize.height + 2
        yOffset += yLabelSize.width + 2
        
        let xScale = (bounds.width - yOffset - xLabelSize.width/2 - 2)/(maxX - minX)
        let yScale = (bounds.height - xOffset - 2 - yGap)/(maxY - minY)
        
        chartTransform = CGAffineTransform(a: xScale, b: 0, c: 0, d: -yScale, tx: yOffset - minX*xScale, ty: bounds.height - xOffset + minY*yScale)
        
        setNeedsDisplay()
    }
}
