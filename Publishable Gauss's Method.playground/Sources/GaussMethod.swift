import Foundation

/// Gauss's method of preliminary orbit determination.
///
/// - Parameters:
///   - tData: Time of observartions
///   - alpha: right ascension data, hours
///   - delta: declination data, degrees
///   - xHigh: high end of range to evaluate Laplace's equation
///   - xLow: low end of range to evaluate Laplace's equation
///   - xGuess: Value for starting Newton's method of solving  Laplace's equation
///   - rCenter: Position of observer at times in tData
///   - mu: dimensionless mass parameter; 1 + mass of seccondary / mass of primary
///   - k: gravitational parameter
///   - ab: factor for abberation corrections, 1/c, au per day
/// - Returns: position and velocity vectors of the body at the middle  of the three observations
public func gaussOrbit(tData: [Double], alpha: [Double], delta: [Double], xHigh: Double, xLow: Double, xGuess: Double, rCenter: [Vector3D], mu: Double, k: Double, ab: Double) -> (t: Double, r: Vector3D, v: Vector3D) {
    var L = Array(repeating: Vector3D(0.0, 0.0, 0.0), count: tData.count)
    
    for iLoop in 0...tData.count-1 {
        let a = alpha[iLoop]/12*pi // convert to radians, from hours
        let d = delta[iLoop]/180*pi // convert to radians, from degrees
        L[iLoop] = Vector3D(cos(d)*cos(a), cos(d)*sin(a), sin(d))
    }
    
    // Transform observation times
    var tau = [k*(tData[0]-tData[1]), k*(tData[2]-tData[0]), k*(tData[2]-tData[1])]
    
    var D = Array(repeating: [0.0, 0.0, 0.0], count: 3)
    for iLoop in 0...2 {
        D[0][iLoop] = dot(rCenter[iLoop], cross(L[1], L[2]))
        D[1][iLoop] = dot(L[0], cross(rCenter[iLoop], L[2]))
        D[2][iLoop] = dot(L[0], cross(L[1], rCenter[iLoop]))
    }
    let D0 = dot(L[0], cross(L[1], L[2]))
    let EE = -2*dot(L[1], rCenter[1])
    let FF = dot(rCenter[1], rCenter[1])
    let A1 = tau[2]/tau[1]
    let B1 = A1*(tau[1]*tau[1] - tau[2]*tau[2])/6
    let A3 = -tau[0]/tau[1]
    let B3 = A3*(tau[1]*tau[1] - tau[0]*tau[0])/6
    let AA = -(A1*D[1][0] - D[1][1] + A3*D[1][2])/D0
    //let AA = 1.1292240  // for Rebek-Jewel example
    let BB = -(B1*D[1][0] + B3*D[1][2])/D0
    //let BB = -1.0828889 // for Rebek-Jewel example
    
    let A = -(AA*AA + AA*EE + FF)
    let B = -mu*(2*AA*BB + BB*EE)
    let C = -mu*mu*BB*BB
    
    print(String(format: "D0 = %10.7f", D0))
    print()
    print(String(format: "AA = %10.7f", AA))
    print(String(format: "BB = %10.7f", BB))
    print()
    print(String(format: "EE = %10.7f", EE))
    print(String(format: "FF = %10.7f", FF))
    print()
    print(String(format: " A = %10.7f", A))
    print(String(format: " B = %10.7f", B))
    print(String(format: " C = %10.7f", C))
    print()
    
    let nX = 10
    let xSpacing = (xHigh - xLow)/Double(nX)
    
    var x = xLow
    for _ in 0...nX {
        let p = AA + mu*BB/(x*x*x)
        let fr = C + x*x*x*(B + x*x*x*(A + x*x))
        print(String(format:"%3.1f   %7.5f   %10.5f", x, p, fr))
        x = x + xSpacing
    }
    print()
    
    x = xGuess // 2.25 would be a better choice
    
    var dx = 1.0 // bogus value that makes the first check of dx true
    while abs(dx) > 1e-7 {
        dx = (C + x*x*x*(B + x*x*x*(A + x*x)))/(x*x*(3*B + x*x*x*(6*A + 8*x*x)))
        x = x - dx
    }
    print(String(format: "x converges to %10.6f\n", x))
    
    // First guess solution for f and g; next tries will use f and g function
    let u2 = mu/(x*x*x)
    var F = [1-u2*tau[0]*tau[0]/2, 0, 1-u2*tau[2]*tau[2]/2]
    var G = [tau[0]*(1-u2*tau[0]*tau[0]/6), 0.0, tau[2]*(1-u2*tau[2]*tau[2]/6)]
    
    var FG = F[0]*G[2] - F[2]*G[0]
    var C_array = [G[2]/FG, -1, -G[0]/FG]
    var D_array = [-F[2]/FG, 0, F[0]/FG]
    
    var P = [0.0, 0.0, 0.0]
    var P_old = P
    var dpMag: Double
    var nIterations = 0
    
    var t = [0.0, 0.0, 0.0]
    var r: [Vector3D]
    var v: Vector3D
    
    repeat {
        nIterations += 1
        print("Iteration #\(nIterations)")
        for i in 0...2 {
            let v1 = C_array[0]*D[i][0]
            let v2 = C_array[1]*D[i][1]
            let v3 = C_array[2]*D[i][2]
            P[i] = (v1 + v2 + v3)/(C_array[i]*D0)
            print(String(format:"P(%d)    %9.7f", i, P[i]))
        }
        print()
        r = [P[0]*L[0] - rCenter[0]]
        r.append(P[1]*L[1] - rCenter[1])
        r.append(P[2]*L[2] - rCenter[2])
        
        v = D_array[0]*r[0] + D_array[2]*r[2]
        
        var dp = [0.0, 0.0, 0.0]
        for i in 0...2 {
            dp[i] = P[i] - P_old[i]
        }
        P_old = P
        t = tData
        for i in 0...2 {
            t[i] = tData[i] - ab*P[i]
        }
        tau[0] = k*(t[0] - t[1])
        tau[2] = k*(t[2] - t[1])
        tau[1] = tau[2] - tau[0]
        
        print(String(format: "t = %12.7f", t[1]))
        print()
        print(String(format: "r[1] = (%10.7f, %10.7f, %10.7f)", r[1].x, r[1].y, r[1].z))
        print(String(format: "v[1] = (%10.7f, %10.7f, %10.7f)", v.x, v.y, v.z))
        print()
        dpMag = sqrt(dp[0]*dp[0] + dp[1]*dp[1] + dp[2]*dp[2])
        print(String(format: "dp = %10.7f  %10.7f %10.7f; %10.5e", dp[0], dp[1], dp[2], dpMag))
        print()
        let coeffs0 = fgUniversal(r: r[1], v: v, h: tau[0], mu: mu)
        F[0] = (coeffs0.f + F[0])/2
        G[0] = (coeffs0.g + G[0])/2
        let coeffs2 = fgUniversal(r: r[1], v: v, h: tau[2], mu: mu)
        F[2] = (coeffs2.f + F[2])/2
        G[2] = (coeffs2.g + G[2])/2
        FG = F[0]*G[2] - F[2]*G[0]
        C_array = [+G[2]/FG, C_array[1], -G[0]/FG]
        D_array = [-F[2]/FG, D_array[1], +F[0]/FG]
    } while dpMag > 1.0e-7
    return (t[1], r[1], v)
}
