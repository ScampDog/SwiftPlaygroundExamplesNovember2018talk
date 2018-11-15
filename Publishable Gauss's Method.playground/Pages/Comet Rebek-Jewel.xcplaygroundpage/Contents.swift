//: [Previous: Pallas](@previous)

import Foundation

print("Determining the orbit of comet Rebek-Jewel")
print()
print("Observations:")
let t = [6370.57744, 6374.57284, 6378.56789]
let alpha = [5.41652, 5.12686, 4.75436]
let delta = [21.85272, 22.14104, 22.32127]
let rCenter = [Vector3D(-0.7735829, -0.5704494, -0.2473703), Vector3D(-0.7275905, -0.6179560, -0.2679668), Vector3D(-0.6780640, -0.6624821, -0.2872733)]

for i in 0...(t.count-1) {
    print(String(format: "t(\(i))   %12.7f", t[i]))
    print(String(format: "alpha  %12.7f hours", alpha[i]))
    print(String(format: "delta  %12.7f degrees", delta[i]))
    print(String(format: "r      %12.7f, %12.7f, %12.7f", rCenter[i].x, rCenter[i].y, rCenter[i].z))
    print()
}
let elements = gaussOrbit(tData: t, alpha: alpha, delta: delta, xHigh: 3.0, xLow: 1.0, xGuess: 1.8, rCenter: rCenter, mu: mu, k: k, ab: ab)
print("Final vector orbital elements:")
let r = elements.r
let v = elements.v
let t_elements = elements.t
print(String(format: "Time of epoch: %12.7f (truncated Julian date)", t_elements))
print(String(format: "r = (%10.7f, %10.7f, %10.7f)", r.x, r.y, r.z))
print(String(format: "v = (%10.7f, %10.7f, %10.7f)", v.x, v.y, v.z))
print()

let kepler = classicalElements(t0: elements.t, r0: elements.r, v0: elements.v, ec: ec, k: k, mu: mu, e_eps: 1e-7)
print("Equivalent Keplerian elements:")
let a = kepler.aq
let e = kepler.e
let i = kepler.i*180/pi
let node = kepler.node*180/pi
let omega = kepler.omega*180/pi
let tp = kepler.tp
print(String(format: "   semi-major axis: %12.7f  au", a))
print(String(format: "      eccentricity: %12.7f (dimensionless)", e))
print(String(format: "       inclination: %12.7f  degrees", i))
print(String(format: "    ascending node: %12.7f  degrees", node))
print(String(format: "  perihelion angle: %12.7f  degrees", omega))
print(String(format: "time of perihelion: %12.7f (truncated Julian date)", tp))

//: [Next](@next)
