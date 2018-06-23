//
//  PostCellModel.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

protocol PostCellModeling {
    var title: String { get }
}

final class PostCellModel {
    let title: String
    init(post: PostProtocol) {
        title = post.title
    }
}

// MARK: - PostCellModeling
extension PostCellModel: PostCellModeling {

}
