import Foundation

public class AxisData {
    public var scaleMax: Double // right or top end of the scale
    public var scaleMin: Double // left or bottom end of the scale
    public var step: Double // size of the step between tick marks
    public var labelNumberFormatter = NumberFormatter() //
    public var nTicks: Int // number of tick marks on the scale (nTicks-1 steps)
    
    public init(dataMax: Double, dataMin: Double, nTicks: Int) {
        self.nTicks = nTicks
        scaleMax = dataMax
        scaleMin = dataMin
        
        let nSteps = nTicks - 1
        let niceSteps = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 1]
        
        let dataRange = dataMax - dataMin
        step = dataRange/Double(nSteps)
        let exponent = ceil(log10(step))
        let powerOfTen = pow(10.0, exponent)
        let qualifiedSteps = niceSteps.filter() { $0 >= step/powerOfTen }
        step = qualifiedSteps.min()!*powerOfTen
        print("step is \(step)")
        let fractionDigits = floor(log10(step))
        labelNumberFormatter.maximumFractionDigits = Int(-fractionDigits)
        print("Formatter is using \(labelNumberFormatter.maximumFractionDigits) digits after the decimal point")
        
        if dataMin < 0 && dataMax > 0 { // zero needs to be one of the ticks
            scaleMin = floor(dataMin/step)*step
            scaleMax = ceil(dataMax/step)*step
            step = (scaleMax - scaleMin)/Double(nSteps)
            scaleMin = floor(dataMin/step)*step
            scaleMax = ceil(dataMax/step)*step
        } else {
            scaleMin = floor(dataMin/(powerOfTen))*powerOfTen
            scaleMax = scaleMin + Double(nSteps)*step
        }
    }
}

