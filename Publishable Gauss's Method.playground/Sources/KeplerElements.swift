import Foundation

public enum OrbitType {
    case elliptical, parabolic, hyperbolic
}

public struct KeplerElements {
    public var type: OrbitType // elliptical, parabolic or hyperbolic
    public var tp: Double      // time of perifocal passage
    public var aq: Double      // semimajor axis or perifocal distance
    public var e: Double       // eccentricity
    public var i: Double       // inclination of orbital plane
    public var node: Double    // longitude of ascending node
    public var omega: Double   // argument of perifocus
    public init(type: OrbitType, tp: Double, aq: Double, e: Double, i: Double, node: Double, omega: Double) {
        self.type = type
        self.tp = tp
        self.aq = aq
        self.e = e
        self.i = i
        self.node = node
        self.omega = omega
    }
    public var description: String {
        var desc: String
        if type == .elliptical {
            desc = "Elliptical orbit\n   semi-major axis:"
        } else if type == .parabolic{
            desc = "Parabolic orbit\n     semi-parameter:"
        } else {
            desc = "Hyperbolic orbit\n   semi-major axis:"
        }
        let aqLine = String(format: "  % 6.4f\n", aq)
        let eLine = String(format: "      eccentricity:   %6.4f\n", e)
        let iLine = String(format: "       inclination: %8.4f\n", i*180/pi)
        let nodeLine = String(format: "    ascending node: %8.4f\n", node*180/pi)
        let pfLine = String(format: "         perifocus: %8.4f\n", omega*180/pi)
        let tpLine = String(format: "perihelion passage: %12.4f\n ", tp)
        return desc+aqLine+eLine+iLine+nodeLine+pfLine+tpLine
    }
}

public func classicalElements(t0: Double, r0: Vector3D, v0: Vector3D, ec: Double, k: Double, mu: Double, e_eps:Double) -> KeplerElements {
    // Reduce to ecliptic coordinates
    let r = Vector3D(r0.x, r0.y*cos(ec)+r0.z*sin(ec), r0.z*cos(ec)-r0.y*sin(ec))
    let v = Vector3D(v0.x, v0.y*cos(ec)+v0.z*sin(ec), v0.z*cos(ec)-v0.y*sin(ec))
    
    let r_mag = sqrt(dot(r, r))
    let v_sq = dot(v, v)
    let rDotV = dot(r, v)
    
    // Eccentricity vector
    let e_vec = (v_sq/mu - 1/r_mag)*r - rDotV*v
    
    // angular momentum vector
    let h_vec = cross(r, v)
    // print(dot(h_vec, r)) // verify that h_vec is perpendicular to r
    // print(dot(h_vec, v)) // verify that h_vec is perpendicular to v
    
    // ascending node vector
    let N_vec = Vector3D(-h_vec.y, +h_vec.x, 0.0)
    
    // Find 1/a, e, and q
    let ai = 2.0/r_mag - v_sq/mu
    let e = hypot(e_vec.x, hypot(e_vec.y, e_vec.z))
    let sp = dot(h_vec, h_vec)/mu
    let q = sp/(1.0+e)
    
    // Find i, oo, omega
    let h_mag = sqrt(dot(h_vec, h_vec))
    let i = acos(h_vec.z/h_mag)
    let N = sqrt(dot(N_vec, N_vec))
    var oo = acos(N_vec.x/N)
    if N_vec.y < 0.0 {
        oo = 2.0*pi - oo
    }
    var omega: Double
    let cosOmega = dot(N_vec, e_vec)/N/e
    if cosOmega > 1 - 1e-6 {
        // cosOmega roughly 1
        omega = 0.0
    } else {
        omega = acos(dot(N_vec, e_vec)/N/e)
        if e_vec.z < 0.0 {
            omega = 2*pi - omega
        }
    }
    
    let xb = (sp-r_mag)/e
    let yb = rDotV*sqrt(sp/mu)/e
    var aq: Double // a or q, depending on type of orbit
    var mm: Double
    var mt: Double
    
    var orbitType: OrbitType
    if abs(1.0-e) < e_eps { // it's a parabolic orbit
        orbitType = .parabolic
        aq = q
        let dd = rDotV/sqrt(mu)
        mm = q*dd+dd*dd*dd/6
        mt = t0 - mm/(k*sqrt(mu))
    } else if e < 1 { // it's an elliptical orbit
        orbitType = .elliptical
        aq = 1/ai
        let b = aq*sqrt(1-e*e)
        let cos_x = xb*ai+e
        let sin_x = yb/b
        let x = atan2(sin_x, cos_x)
        mm = x - e*sin_x
        let n = k/aq*sqrt(mu/aq)
        mt = t0 - mm/n
    } else { // it's a hyperbolic orbit
        orbitType = .hyperbolic
        aq = 1/ai
        let b = -aq*sqrt(e*e-1)
        let sinh_x = yb/b
        let x = asinh(sinh_x)
        mm = e*sinh_x - x
        let n = -k*ai*sqrt(-mu*ai)
        mt = t0 - mm/n
    }
    
    let elements = KeplerElements(type: orbitType, tp: mt, aq: aq, e: e, i: i, node: oo, omega: omega)
    
    return elements
}

public func rvFromElements(t: Double, elements: KeplerElements, ec: Double, k: Double, mu: Double) -> (r: Vector3D, v: Vector3D) {
    
    let e = elements.e // this gets used many times
    
    var xb, yb, xp, yp: Double
    switch elements.type { // find position in orbital plane, three ways
    case .parabolic:
        let n = k*sqrt(mu)
        let mm = n*(t - elements.tp)
        var dd = mm
        var f: Double // fake value to start
        let q = elements.aq
        repeat {
            f = q*dd + dd*dd*dd/6 - mm
            let df = q + dd*dd/2
            dd = dd - f/df
        } while abs(f) > 1e-7
        let r = q + dd*dd/2
        let dp = sqrt(mu)/r
        xb = q - dd*dd/2
        yb = dd*sqrt(2*q)
        xp = -dd*dp
        yp = dp*sqrt(2*q)
    case .elliptical:
        let a = elements.aq
        let n = k/a*sqrt(mu/a)
        let mm = (t - elements.tp)*n // mean anomaly
        var f, df: Double
        var ee = mm // starting estimate of eccentric anomaly
        repeat {
            f = ee - e*sin(ee) - mm
            df = 1 - e*cos(ee)
            ee = ee - f/df
        } while abs(f) > 1e-6
        let r = a*(1 - e*cos(ee))
        let ep = sqrt(mu/a)/r
        let b = a*sqrt(1-e*e)
        xb = a*(cos(ee) - e)
        yb = b*sin(ee)
        xp = -a*ep*sin(ee)
        yp = +b*ep*cos(ee)
    case .hyperbolic:
        let a = elements.aq
        let n = -k/a*sqrt(-mu/a)
        let mm = n*(t - elements.tp)
        var hh = mm
        var f: Double
        repeat {
            f = e*sinh(hh) - hh - mm
            let df = e*cosh(hh) - 1
            hh = hh - f/df
        } while abs(f) > 1e-6
        let r = a*(1-e*cosh(hh))
        let hp = sqrt(-mu/a)/r
        let b = -a*sqrt(e*e - 1)
        xb = a*(cosh(hh) - e)
        yb = b*sinh(hh)
        xp = a*hp*sinh(hh)
        yp = b*hp*cosh(hh)
    }
    
    // find unit vectors in orbital plane
    let omega = elements.omega
    let node = elements.node
    let i = elements.i
    var pp = Vector3D(1.0, 0.0, 0.0) // from primary to pericenter
    pp.x = cos(omega)*cos(node) - sin(omega)*sin(node)*cos(i)
    pp.y = cos(omega)*sin(node) + sin(omega)*cos(node)*cos(i)
    pp.z = sin(omega)*sin(i)
    var qq = Vector3D(0.0, 1.0, 0.0) // along velocity at pericenter
    qq.x = -sin(omega)*cos(node) - cos(omega)*sin(node)*cos(i)
    qq.y = -sin(omega)*sin(node) + cos(omega)*cos(node)*cos(i)
    qq.z = +cos(omega)*sin(i)
    
    let r = xb*pp + yb*qq
    let v = xp*pp + yp*qq
    let r0 = Vector3D(r.x, r.y*cos(ec)-r.z*sin(ec), r.z*cos(ec)+r.y*sin(ec))
    let v0 = Vector3D(v.x, v.y*cos(ec)-v.z*sin(ec), v.z*cos(ec)+v.y*sin(ec))
    
    return (r0, v0)
}
