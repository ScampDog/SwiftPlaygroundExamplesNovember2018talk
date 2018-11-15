import Foundation

/// Universal _f_ and _g_ solution from Boulet
///
/// - Parameters:
///   - r: postion vector
///   - v: velocity vector
///   - h: scaled time step
///   - mu: 1 + mass of secondary relative to primary
/// - Returns: f, g, f dot and g dot.
public func fgUniversal(r: Vector3D, v: Vector3D, h: Double, mu: Double) -> (f: Double, g: Double, fp: Double, gp: Double) {
    
    let r0 = sqrt(dot(r, r))
    let d0 = dot(r, v)/sqrt(mu)
    let ai = 2.0/r0 - dot(v, v)/mu
    let c0 = 1.0 - r0*ai
    let ww = h*sqrt(mu)
    var xx = ww/r0 // initial guess
    
    var result = getDelta(r0: r0, ai: ai, x: xx, ww: ww, c0: c0, d0: d0)
    while true {
        if abs(result.fx) < 1.0e-7 {
            break
        }
        result = getDelta(r0: r0, ai: ai, x: xx, ww: ww, c0: c0, d0: d0)
        xx = xx - result.dx
    }
    
    let f = 1.0 - result.cc/r0
    let g = (r0*result.ss + d0*result.cc)/sqrt(mu)
    let r_new = r0 + c0*result.cc + d0*result.ss
    let fp = -sqrt(mu)*result.ss/(r_new*r0)
    let gp = 1 - result.cc/r_new
    
    return (f, g, fp, gp)
}

func factorial(_ n: Int) -> Double {
    
    var value = 1
    for i in 1...n {
        value = value*i
    }
    
    return Double(value)
}

/// Helper function for Newton-Raphson method
///
/// - Parameters:
///   - r0: radius (magnitude, not vector)
///   - ai: inverse of semi-major axis
///   - x:  value to evaluate f(x) at
///   - ww: parameter
///   - c0: parameter
///   - d0: parametr
/// - Returns: value of function, and calculated change in x value; cc and ss are used to find f and g
func getDelta(r0: Double, ai: Double, x: Double, ww: Double, c0: Double, d0: Double ) -> (fx: Double, dx: Double, cc: Double, ss: Double) {
    let x2 = x*x
    let x3 = x2*x
    let xa = x2*ai
    
    // var c = x2/2.0
    // var cc = c
    /*    for i in 2...9 {
     c = -c*xa/Double(factorial(2*i))
     cc = cc + c
     } */
    let cc = x2*(0.5 - xa*(1.0/factorial(4) - xa*(1.0/factorial(6) - xa*(1.0/factorial(8)-xa*(1.0/factorial(10) - xa*(1.0/factorial(12) - xa*(1.0/factorial(14) - xa*(1.0/factorial(16) - xa*(1.0/factorial(18))))))))))
    
    /*var u = x3/6.0
     var uu = u
     for i in 2...8 {
     u = -u*xa/Double(factorial(2*i+1))
     uu = uu + u
     }*/
    let uu = x3*(1/factorial(3) - xa*(1.0/factorial(5) - xa*(1.0/factorial(7) - xa*(1.0/factorial(9) - xa*(1.0/factorial(11) - xa*(1.0/factorial(13) - xa*(1.0/factorial(15) - xa*(1.0/factorial(17) - xa*(1.0/factorial(19))))))))))
    
    let ss = x - uu*ai
    let fx = r0*x + c0*uu + d0*cc - ww
    let df = r0 + c0*cc + d0*ss
    let dx = fx/df
    
    return (fx, dx, cc, ss)
}
