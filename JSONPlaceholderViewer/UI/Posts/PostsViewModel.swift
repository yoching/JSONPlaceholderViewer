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
    var cellModels: Property<[PostCellModeling]> { get }
}

enum PostsViewRoute {
    case postDetail
}

protocol PostsViewRouting {
    var routeSelected: Signal<PostsViewRoute, NoError> { get }
}

final class PostsViewModel {
    private let mutableCellModels = MutableProperty<[PostCellModeling]>([])
    private let routeSelectedPipe = Signal<PostsViewRoute, NoError>.pipe()
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
}
