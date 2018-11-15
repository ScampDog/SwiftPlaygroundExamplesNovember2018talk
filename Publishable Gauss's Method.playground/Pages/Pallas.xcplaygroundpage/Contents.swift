/*:
 ### Gauss's Method
 Gauss's method for determining the orbit of a celestial body from three observations.
 From _Methods of Orbit Determination for the Microcomputer_, Boulet, 1991.
 Based on program GAUSS, chapter 10.

 Each page implements one of the chapter's examples. This page determines the
 orbit of Pallas, and the next page determines the orbit of a hypothetical
 comet, Rebek-Jewel.
 
 The support files contain the shared parts of this playground. Constants are defined
 in AstronomicalConstants.swift, and Vector3D.swift defines the Vector3D struct, along
 with several vector operations, including overrides of the addition, subtraction, 
 multiplication, division and equality operators. 
 
 The file FGUniversal.swift implements a function to compute the Laplace coefficients, 
 _f_ and _g_. This version of the _f_ and _g_ solution doesn't depend on knowing 
 what kind of orbit it is (elliptical, parabolic or hyperbolic). It uses position
 and velocity vectors at a given time to determine position and velocity at another time.
 
 The file GaussMethod.swift supplies a function that determines a preliminary orbit 
 from three observations of right ascension and declination. It uses the _f_ and 
 _g_ solution given in FGUniversal.swift. It finds the position and velocity vectors 
 of the object at the time of the middle observation.
 
 The file KeplerElements.swift takes position and velocity vectors at a given time 
 and determines the classical Keplerian elements of the orbit found by Gauss's 
 method. It's there to convert the position and velocity elements to a more
 understandable format that gives the orientation, size and shape of
 the orbit, along with the time of perihelion passage.
 */

import UIKit

// Data for Pallas, page 435-6: times of the observations, right ascension and declination
let tData = [6370.57744, 6378.56789, 6390.65113] // truncated Julian date
let alpha = [  6.38029,   6.40793,   6.38762] // right ascension, hours
let delta = [-24.25104, -26.48060, -29.48400] // declination, degrees
let rCenter = [Vector3D(-0.7735829, -0.5704494, -0.2473703), Vector3D(-0.6780640, -0.6624821, -0.2872733), Vector3D(-0.5091536, -0.7766740, -0.3367798)] // position of Earth at observations

print("Observations for Pallas\n")
for i in 0...(tData.count-1) {
    print(String(format: "t(\(i))   %12.7f", tData[i]))
    print(String(format: "alpha  %12.7f hours", alpha[i]))
    print(String(format: "delta  %12.7f degrees", delta[i]))
    print(String(format: "r      %12.7f, %12.7f, %12.7f", rCenter[i].x, rCenter[i].y, rCenter[i].z))
    print()
}

let vectorElements = gaussOrbit(tData: tData, alpha: alpha, delta: delta, xHigh: 3.0, xLow: 2.0, xGuess: 2.3, rCenter: rCenter, mu: mu, k: k, ab: ab)

print("Vector orbital elements are...")
print(String(format: "t: %0.5f", vectorElements.t))
let r = vectorElements.r
let v = vectorElements.v

print(String(format: "r: (%10.7f, %10.7f, %10.7f)", r.x, r.y, r.z))
print(String(format: "v: (%10.7f, %10.7f, %10.7f)", v.x, v.y, v.z))
print()
print("Corresponding Keplerian elements are...")
let keplerElements = classicalElements(t0: vectorElements.t, r0: r, v0: v, ec: ec, k: k, mu: mu, e_eps: 1e-5)
print(keplerElements.description)
 

print()

//: [Next: Comet Rebek-Jewel](@next)
