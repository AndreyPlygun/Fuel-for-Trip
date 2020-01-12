//
//  Extensions.swift
//  Fuel Way
//
//  Created by Andrey Plygun on 11/22/19.
//  Copyright © 2019 Andrey Plygun. All rights reserved.
//

import Foundation
import UIKit

// UIColor
public func RGBAColor(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float) -> UIColor {
    let color = UIColor(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: CGFloat(alpha))
    return color
}


// Storyboard
struct Storyboard {
    static let details = UIStoryboard(name: "Details", bundle: nil)
    static let about = UIStoryboard(name: "About", bundle: nil)
}

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self.self)
    }
}

extension UIStoryboard {
    func controller<T: UIViewController>(withClass: T.Type) -> T? {
        let identifier = withClass.identifier
        return instantiateViewController(withIdentifier: identifier) as? T
    }
    
    func instantiateViewController<T: StoryboardIdentifiable>() -> T? {
        return instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T
    }
}


// UIViewController
extension UIViewController {
    class var identifier: String {
        let separator = "."
        let fullName = String(describing: self)
        if fullName.contains(separator) {
            let items = fullName.components(separatedBy: separator)
            if let name = items.last {
                return name
            }
        }
        return fullName
    }
}

extension UIViewController: StoryboardIdentifiable {}


extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
