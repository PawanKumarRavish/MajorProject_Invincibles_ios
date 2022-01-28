

import Foundation

extension Bundle {
    static func podBundle(forClass: AnyClass) -> Bundle? {
        
        let bundleForClass = Bundle(for: forClass)
        
        if let bundleURL = bundleForClass.url(forResource: "OpalImagePickerResources", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            } else {
                assertionFailure("Could  load the bundle")
            }
        } else {
            assertionFailure("Could not create a path to the bundle")
        }
        return nil
    }
}
