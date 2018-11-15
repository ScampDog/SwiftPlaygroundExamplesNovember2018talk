//: Playground - Julian Date Algorithms
//: Found at https://gist.github.com/TheDarkCode/1b02cd5b91392d7650a9cd08eed3dc6a
//: on August 7, 2017.  Page was titled "Fliegal and Van Flandern Algorithm in Swift."
//
//  Created by Mark Hamilton on 4/16/16.
//  Copyright © 2016 dryverless. All rights reserved.
//
import Foundation

public func fliegalAndVanFlandernAlgorithm(julianDate: Int) -> (month: Int, day: Int, year: Int) {
    var l = julianDate + 68569
    let n = (4 * l) / 146097
    l -= ((146097 * n) + 3)/4
    let i = (4000 * (l + 1)) / 1461001
    l -= (1461 * i) / 4 + 31
    let j = (80 * l) / 2447
    let d = l - (2447 * j) / 80 + 1
    l = j / 11
    let m = j + 4 - (12 * l)
    let y = 100 * (n - 49) + i + l
    return (m, d, y)
}

public func getJulianDate(month m: Int, day d: Int, year y: Int) -> Int {
    return ( 1461 * ( y + 4800 + ( m - 14 ) / 12 ) ) / 4 + ( 367 * ( m - 2 - 12 * ( ( m - 14 ) / 12 ) ) ) / 12 - ( 3 * ( ( y + 4900 + ( m - 14 ) / 12 ) / 100 ) ) / 4 + d - 32075
}

// Everything below is my own code

public func siderialTime(julianDate: Int, ut: Double, longitude: Double) -> Double {
    let J = (Double(julianDate) - 2451545)/36525 // julian centuries
    // 2451545 is January 1, 2000
    var s0 = 100.4606184 + 36000.77004*J + 0.000387933*J*J
    print(s0)
    s0 = s0.truncatingRemainder(dividingBy: 360)
    print(s0)
    while s0 < 0 {
        s0 += 360
    }
    print(s0)
    let sg = s0 + 360.98564724*ut/24
    print(sg)
    var st = sg + longitude
    st = st - Double(360*Int(st/360))
    print(st)
    return st
}

public func adjustAngle(_ a: Double) -> Double {
    var angle = a
    while angle >= 360.0 {
        angle -= 360
    }
    while angle < 0 {
        angle += 360
    }
    return angle
}

