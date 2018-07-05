//
//  PostDetailViewModel.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 6/25/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol PostDetailViewModeling {
    // View States
    var userName: Property<String?> { get }
    var body: Property<String> { get }
    var numberOfComments: Property<String> { get }

    // View -> View Model
    func viewWillAppear()

    // View Model -> View
}

enum PostDetailViewRoute {
    case pop
}

protocol PostDetailViewRouting {
    var routeSelected: Signal<PostDetailViewRoute, NoError> { get }
}

final class PostDetailViewModel {

    private let post: PostProtocol
    private let dataProvider: DataProviding

    private let mutableUserName: MutableProperty<String?>
    private let mutableBody: MutableProperty<String>
    private let mutableNumberOfComments: MutableProperty<Int>

    private let viewWillAppearPipe = Signal<Void, NoError>.pipe()

    private let routeSelectedPipe = Signal<PostDetailViewRoute, NoError>.pipe()

    init(of post: PostProtocol, dataProvider: DataProviding) {
        self.post = post
        self.dataProvider = dataProvider

        mutableUserName = MutableProperty<String?>(post.userProtocol.name)
        mutableBody = MutableProperty<String>(post.body)
        mutableNumberOfComments = MutableProperty<Int>(post.comments.count)

        viewWillAppearPipe.output
            .flatMap(.latest) { [weak self] _ -> SignalProducer<Result<Void, DataProviderError>, NoError> in
                guard let strongSelf = self else {
                    return .empty
                }
                return strongSelf.dataProvider.populate(strongSelf.post)
                    .resultWrapped()
            }
            .observeValues { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.mutableUserName.value = strongSelf.post.userProtocol.name
                strongSelf.mutableNumberOfComments.value = strongSelf.post.comments.count
        }
    }
}

// MARK: - PostDetailViewModeling
extension PostDetailViewModel: PostDetailViewModeling {
    var userName: Property<String?> {
        return Property(mutableUserName)
    }
    var body: Property<String> {
        return Property(mutableBody)
    }
    var numberOfComments: Property<String> {
        return Property(mutableNumberOfComments.map { "\($0)"  })
    }
    func viewWillAppear() {
        viewWillAppearPipe.input.send(value: ())
    }
}

// MARK: - PostDetailViewRouting
extension PostDetailViewModel: PostDetailViewRouting {
    var routeSelected: Signal<PostDetailViewRoute, NoError> {
        return routeSelectedPipe.output
    }
}
