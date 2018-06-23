//
//  PostCell.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit

final class PostCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    func configure(with cellModel: PostCellModeling) {
        titleLabel.text = cellModel.title
    }

}
