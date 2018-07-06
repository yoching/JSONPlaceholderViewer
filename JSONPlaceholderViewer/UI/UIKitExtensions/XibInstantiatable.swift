//
//  XibInstantiatable.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 7/5/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

public protocol XibInstantiatable {
    func instantiate()
}

public extension XibInstantiatable where Self: UIView {
    func instantiate() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.topAnchor.constraint(equalTo: self.topAnchor),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ]
        )
    }
}
