//
//  PostsViewModel.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol PostsViewModeling {
    // View States
    var cellModels: Property<[PostCellModeling]> { get }

    // View -> View Model
    func didSelectRow(index: Int)
}

enum PostsViewRoute {
    case postDetail(postIdentifier: Int64)
}

protocol PostsViewRouting {
    var routeSelected: Signal<PostsViewRoute, NoError> { get }
}

final class PostsViewModel {
    private let mutableCellModels = MutableProperty<[PostCellModeling]>([])
    private let routeSelectedPipe = Signal<PostsViewRoute, NoError>.pipe()
    private let didSelectRowPipe = Signal<Int, NoError>.pipe()

    init(dataProvider: DataProviding) {
        cellModels.signal
            .sample(with: didSelectRowPipe.output)
            .map { (cellModels, row) -> PostsViewRoute in
                return .postDetail(postIdentifier: cellModels[row].postIdentifier)
            }
            .observe(routeSelectedPipe.input)

        mutableCellModels <~ dataProvider.posts
            .map { posts -> [PostCellModeling] in
                return posts.map(PostCellModel.init)
        }

        dataProvider.fetchPosts() // current implementation
    }
}

// MARK: - PostsViewModeling
extension PostsViewModel: PostsViewModeling {
    var cellModels: Property<[PostCellModeling]> {
        return Property(mutableCellModels)
    }
}

// MARK: - PostsViewRouting
extension PostsViewModel: PostsViewRouting {
    var routeSelected: Signal<PostsViewRoute, NoError> {
        return routeSelectedPipe.output
    }
    func didSelectRow(index: Int) {
        didSelectRowPipe.input.send(value: index)
    }
}
