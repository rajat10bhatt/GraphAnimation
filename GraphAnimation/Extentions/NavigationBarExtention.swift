//
//  NavigationBarExtention.swift
//  GraphAnimation
//
//  Created by Rajat Bhatt on 11/05/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit

extension UINavigationBar {
    //Remove navigation bar shadow
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}
