//
//  Vector3D.swift
//
//  Vectors and vector operations for 3-D positions, velocities, etc.
//
//  Created by Norm Hecht on 6/28/17.
//
//

import Foundation

// MARK: Definition of the struct

/// Three dimensional vector, for positions, velocities, forces, etc.
public struct Vector3D: Equatable {
    public var x = 0.0, y = 0.0, z = 0.0
    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    // I found these convenience initializers at Github's VectorMath repository,
    // https://github.com/nicklockwood/VectorMath/blob/master/VectorMath/VectorMath.swift
    public static let i = Vector3D(1.0, 0.0, 0.0)
    public static let j = Vector3D(0.0, 1.0, 0.0)
    public static let k = Vector3D(0.0, 0.0, 1.0)
    public static let zero = Vector3D(0.0, 0.0, 0.0)
    /// Exact equality
    ///
    /// - Parameters:
    ///   - lhs: vector
    ///   - rhs: vector
    /// - Returns: Boolean that's true if they're exactly equal
    public static func ==(lhs: Vector3D, rhs: Vector3D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    /// Not equal
    ///
    /// - Parameters:
    ///   - lhs: vector
    ///   - rhs: vector
    /// - Returns: Boolean that's true if they're not exactly equal
    public static func !=(lhs: Vector3D, rhs: Vector3D) -> Bool {
        return !(lhs == rhs)
    }
}

// MARK: Vector operations
infix operator + : AdditionPrecedence

/// Vector addition
///
/// - Parameters:
///   - left: Vector3D
///   - right: Vector3D
/// - Returns: Sum of left and right
public func + (left: Vector3D, right: Vector3D) -> Vector3D {
    return Vector3D(left.x+right.x, left.y+right.y, left.z+right.z)
}

/// Vector subtraction
///
/// - Parameters:
///   - left: Vector3D
///   - right: Vector3D
/// - Returns: Difference of input vectors
public func - (left: Vector3D, right: Vector3D) -> Vector3D {
    return Vector3D(left.x-right.x, left.y-right.y, left.z-right.z)
}


infix operator / : MultiplicationPrecedence

/// Vector and scalar division
///
/// - Parameters:
///   - left: Double
///   - right: Vector3D
/// - Returns: vector with magnitude of input vector divided by the scalar
/*public func / (left: Double, right: Vector3D) -> Vector3D { // divide a scalar by a 3-vector, giving a 3-vector
 return Vector3D(left/right.x, left/right.y, left/right.z)
 }*/

/// Vector and scalar division
///
/// - Parameters:
///   - left: Vector3D
///   - right: Double
/// - Returns: vector with magnitude of input vector divided by the scalar
public func / (left: Vector3D, right: Double) -> Vector3D { // divide a 3-vector by a scalar, giving a 3-vector
    return Vector3D(left.x/right, left.y/right, left.z/right)
}

infix operator * : MultiplicationPrecedence

/// Multiply a scalar times a vector
///
/// - Parameters:
///   - left: scalar
///   - right: vector
/// - Returns: their product
public func * (left: Double, right: Vector3D) -> Vector3D {
    return Vector3D(left*right.x, left*right.y, left*right.z)
}

/// Multiply a vector times a scalar
///
/// - Parameters:
///   - left: vector
///   - right: scalar
/// - Returns: their product
public func * (left: Vector3D, right: Double) -> Vector3D {
    return Vector3D(right*left.x, right*left.y, right*left.z)
}

/// Dot product
///
/// - Parameters:
///   - a: vector
///   - b: vector
/// - Returns: scalar product of the two vectors
public func dot(_ a: Vector3D, _ b: Vector3D) -> Double {
    return a.x*b.x + a.y*b.y + a.z*b.z
}

extension Vector3D {
    /// Unary -
    ///
    /// - Parameter vector: a Vector3D
    /// - Returns: the negative of the input vector
    public static prefix func -(vector: Vector3D) -> Vector3D {
        return Vector3D(-vector.x, -vector.y, -vector.z)
    }
}

/// Cross product
///
/// - Parameters:
///   - a: vector
///   - b: vector
/// - Returns: vector perpendicular to the inputs,
///   with magnitude equal to the product of their
///   magnitudes times sine of the angle between them.
public func cross(_ a: Vector3D, _ b: Vector3D) -> Vector3D {
    return Vector3D(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x)
}

// MARK: printing
extension Vector3D: TextOutputStreamable { // for describing a Vector3D
    /// Create a formatted string for printing the vector
    ///
    /// - Parameter target: TextOutputStream, used by print and similar functions
    public func  write<Target>(to target: inout Target) where Target : TextOutputStream {
        print(String(format: "[%10.7f, %10.7f, %10.7f]", x, y, z), terminator: "", to: &target)
    }
}

// MARK: Equality and approximate equality

// https://github.com/nicklockwood/VectorMath/blob/master/VectorMath/VectorMath.swift
// I changed the tolerance to match the problems I think I'll be looking at.

public extension Double {
    public static let epsilon = 1.0e-8
    /// Approximate equality
    ///
    /// - Parameters:
    ///   - lhs: Double
    ///   - rhs: Double
    /// - Returns: Boolan that's true if they're roughly equal
    public static func ~=(lhs: Double, rhs: Double) -> Bool {
        return Swift.abs(lhs - rhs) < .epsilon
    }
}

public extension Vector3D {
    /// Approximate equality
    ///
    /// - Parameters:
    ///   - lhs: Vector3D
    ///   - rhs: Vector3D
    /// - Returns: Boolean that's true if they're roughly equal
    public static func ~=(lhs: Vector3D, rhs: Vector3D) -> Bool {
        return lhs.x ~= rhs.x && lhs.y ~= rhs.y && lhs.z ~= rhs.z
    }
}
