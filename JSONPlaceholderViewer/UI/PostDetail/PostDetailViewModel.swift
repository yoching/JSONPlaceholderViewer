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

    var isLoadingIndicatorHidden: Property<Bool> { get }
    var loadingIndicatorViewModel: LoadingIndicatorViewModeling { get }

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

    private let mutableIsLoadingIndicatorHidden: MutableProperty<Bool>
    let loadingIndicatorViewModel: LoadingIndicatorViewModeling

    private let viewWillAppearPipe = Signal<Void, NoError>.pipe()

    private let routeSelectedPipe = Signal<PostDetailViewRoute, NoError>.pipe()

    init(of post: PostProtocol, dataProvider: DataProviding, loadingIndicatorViewModel: LoadingIndicatorViewModeling) {
        self.post = post
        self.dataProvider = dataProvider
        self.loadingIndicatorViewModel = loadingIndicatorViewModel

        mutableUserName = MutableProperty<String?>(post.userProtocol.name)
        mutableBody = MutableProperty<String>(post.body)
        mutableNumberOfComments = MutableProperty<Int>(post.commentArray.count)

        mutableIsLoadingIndicatorHidden = MutableProperty<Bool>(true)

        isPostPopulated.producer
            .sample(on: viewWillAppearPipe.output)
            .on { [weak self] isPostPopulated in
                self?.mutableIsLoadingIndicatorHidden.value = isPostPopulated
            }
            .flatMap(.latest) { [weak self] _ -> SignalProducer<Result<Void, DataProviderError>, NoError> in
                guard let strongSelf = self else {
                    return .empty
                }
                return strongSelf.dataProvider.populate(strongSelf.post)
                    .resultWrapped()
            }
            .on { [weak self] result in
                switch result {
                case .failure(let error):
                    // TODO: show error
                    break
                case .success:
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.mutableUserName.value = strongSelf.post.userProtocol.name
                    strongSelf.mutableNumberOfComments.value = strongSelf.post.commentArray.count
                }
            }
            .on { [weak self] _ in
                self?.mutableIsLoadingIndicatorHidden.value = true
            }
            .start()
    }
}

private extension PostDetailViewModel {
    var isPostPopulated: Property<Bool> {
        return userName.map { $0 != nil }
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

    var isLoadingIndicatorHidden: Property<Bool> {
        return Property(mutableIsLoadingIndicatorHidden).skipRepeats()
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
