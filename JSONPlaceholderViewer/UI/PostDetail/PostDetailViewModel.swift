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

protocol PostDetailViewModeling: LoadingViewsControllable {
    // View States
    var title: String { get }
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

    private var populatePost: Action<Void, Void, DataProviderError>!

    // LoadingViewsControllable
    let loadingErrorViewModel: LoadingErrorViewModeling
    let loadingIndicatorViewModel: LoadingIndicatorViewModeling
    private let mutableIsLoadingErrorHidden = MutableProperty<Bool>(true)
    private let mutableIsLoadingIndicatorHidden = MutableProperty<Bool>(true)

    init(
        of post: PostProtocol,
        dataProvider: DataProviding,
        loadingErrorViewModel: LoadingErrorViewModeling,
        loadingIndicatorViewModel: LoadingIndicatorViewModeling
        ) {
        self.post = post
        self.dataProvider = dataProvider

        mutableUserName = MutableProperty<String?>(post.userProtocol.name)
        mutableBody = MutableProperty<String>(post.body)
        mutableNumberOfComments = MutableProperty<Int>(post.commentArray.count)

        self.loadingErrorViewModel = loadingErrorViewModel
        self.loadingIndicatorViewModel = loadingIndicatorViewModel

        // fetch
        populatePost = Action<Void, Void, DataProviderError> { [weak self] _
            -> SignalProducer<Void, DataProviderError> in
            guard let strongSelf = self else {
                return .empty
            }
            return strongSelf.dataProvider.populate(strongSelf.post)
        }

        populatePost <~ Signal<Void, NoError>.merge(
            viewWillAppearPipe.output,
            loadingErrorViewModel.retryTappedOutput
        )

        // update view after populate succeeded
        populatePost.values
            .observeValues { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.mutableUserName.value = strongSelf.post.userProtocol.name
                strongSelf.mutableNumberOfComments.value = strongSelf.post.commentArray.count
        }

        // error description
        populatePost.errors
            .observeValues { [weak self] error in
                self?.loadingErrorViewModel.updateErrorMessage(to: error.localizedDescription)
        }

        // loading indicator view state
        mutableIsLoadingIndicatorHidden <~ SignalProducer.combineLatest(
            isPostPopulated.producer,
            populatePost.isExecuting.producer
            )
            .map { isPostPopulated, isExecuting -> Bool in
                return !(!isPostPopulated && isExecuting)
        }

        // loading error view state
        mutableIsLoadingErrorHidden <~ SignalProducer.combineLatest(
            isPostPopulated.producer,
            populatePost.isExecuting,
            populatePost.events.producer.map { $0.error != nil }
            )
            .map { isPostPopulated, isExecuting, isLastEventError -> Bool in
                // display when "not populated" & "not executing" & "last event error"
                return !(!isPostPopulated && !isExecuting && isLastEventError)
        }

    }
}

private extension PostDetailViewModel {
    var isPostPopulated: Property<Bool> {
        return userName.map { $0 != nil }
    }
}

// MARK: - PostDetailViewModeling
extension PostDetailViewModel: PostDetailViewModeling {
    var title: String {
        return post.title
    }
    var userName: Property<String?> {
        return Property(mutableUserName)
    }
    var body: Property<String> {
        return Property(mutableBody)
    }
    var numberOfComments: Property<String> {
        return Property(mutableNumberOfComments.map { "\($0)" })
    }

    func viewWillAppear() {
        viewWillAppearPipe.input.send(value: ())
    }

    // LoadingViewsControllable
    var isLoadingErrorHidden: Property<Bool> {
        return Property(mutableIsLoadingErrorHidden).skipRepeats()
    }
    var isLoadingIndicatorHidden: Property<Bool> {
        return Property(mutableIsLoadingIndicatorHidden).skipRepeats()
    }
}

// MARK: - PostDetailViewRouting
extension PostDetailViewModel: PostDetailViewRouting {
    var routeSelected: Signal<PostDetailViewRoute, NoError> {
        return routeSelectedPipe.output
    }
}
