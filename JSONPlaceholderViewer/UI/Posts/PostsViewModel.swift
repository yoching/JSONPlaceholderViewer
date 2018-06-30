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
    func viewWillAppear()
}

enum PostsViewRoute {
    case postDetail(postIdentifier: Int64)
}

protocol PostsViewRouting {
    var routeSelected: Signal<PostsViewRoute, NoError> { get }
}

final class PostsViewModel {

    private let dataProvider: DataProviding

    private let mutableCellModels = MutableProperty<[PostCellModeling]>([])
    private let routeSelectedPipe = Signal<PostsViewRoute, NoError>.pipe()
    private let didSelectRowPipe = Signal<Int, NoError>.pipe()
    private let viewWillAppearPipe = Signal<Void, NoError>.pipe()

    private let shouldReloadWhenAppear = MutableProperty<Bool>(true)

    init(dataProvider: DataProviding) {
        self.dataProvider = dataProvider

        cellModels.signal
            .sample(with: didSelectRowPipe.output)
            .map { (cellModels, row) -> PostsViewRoute in
                return .postDetail(postIdentifier: cellModels[row].postIdentifier)
            }
            .observe(routeSelectedPipe.input)

        mutableCellModels <~ dataProvider.posts
            .map { posts -> [PostCellModeling] in
                return posts?.map(PostCellModel.init) ?? []
        }

        shouldReloadWhenAppear.producer
            .sample(on: viewWillAppearPipe.output)
            .filter { $0 }
            .on(value: { [weak self] _ in
                self?.shouldReloadWhenAppear.value = false
            })
            .flatMap(.latest) { _ -> SignalProducer<Result<Void, DataProviderError>, NoError> in
                return self.dataProvider.fetchPosts().resultWrapped()
            }
            .startWithValues { result in
                print(result)
        }
    }
}

// MARK: - PostsViewModeling
extension PostsViewModel: PostsViewModeling {
    var cellModels: Property<[PostCellModeling]> {
        return Property(mutableCellModels)
    }

    func viewWillAppear() {
        viewWillAppearPipe.input.send(value: ())
    }

    func didSelectRow(index: Int) {
        didSelectRowPipe.input.send(value: index)
    }
}

// MARK: - PostsViewRouting
extension PostsViewModel: PostsViewRouting {
    var routeSelected: Signal<PostsViewRoute, NoError> {
        return routeSelectedPipe.output
    }
}
