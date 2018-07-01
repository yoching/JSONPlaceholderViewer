//
//  PostCellModel.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

protocol PostCellModeling {
    var post: PostProtocol { get }
    var title: String { get }
}

final class PostCellModel {
    let post: PostProtocol
    let title: String
    init(post: PostProtocol) {
        self.post = post
        title = post.title
    }
}

// MARK: - PostCellModeling
extension PostCellModel: PostCellModeling {

}
