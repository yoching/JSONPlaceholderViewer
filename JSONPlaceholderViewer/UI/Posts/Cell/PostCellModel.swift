//
//  PostCellModel.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation

protocol PostCellModeling {
    var postIdentifier: Int64 { get }
    var title: String { get }
}

final class PostCellModel {
    let postIdentifier: Int64
    let title: String
    init(post: PostProtocol) {
        postIdentifier = post.identifier
        title = post.title
    }
}

// MARK: - PostCellModeling
extension PostCellModel: PostCellModeling {

}
