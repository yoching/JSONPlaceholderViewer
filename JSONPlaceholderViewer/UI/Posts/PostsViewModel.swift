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

protocol PostsViewModeling: LoadingAndEmptyViewsControllable {
    // View States
    var cellModels: Property<[PostCellModeling]> { get }

    // View -> View Model
    func didSelectRow(index: Int)
    func viewWillAppear()
    func pullToRefreshTriggered()

    // ViewModel -> View
    var shouldStopRefreshControl: Signal<Void, NoError> { get }
}

enum PostsViewRoute {
    case postDetail(post: PostProtocol)
}

protocol PostsViewRouting {
    var routeSelected: Signal<PostsViewRoute, NoError> { get }
}

final class PostsViewModel {

    private let dataProvider: DataProviding
    private let shouldReloadWhenAppear = MutableProperty<Bool>(true)

    // ViewModeling
    private let mutableCellModels = MutableProperty<[PostCellModeling]>([])
    private let didSelectRowPipe = Signal<Int, NoError>.pipe()
    private let viewWillAppearPipe = Signal<Void, NoError>.pipe()
    private let pullToRefreshTriggeredPipe = Signal<Void, NoError>.pipe()
    private let shouldStopRefreshControlPipe = Signal<Void, NoError>.pipe()

    // ViewRouting
    private let routeSelectedPipe = Signal<PostsViewRoute, NoError>.pipe()

    // LoadingViewsControllable
    let emptyDataViewModel: EmptyDataViewModeling
    let loadingErrorViewModel: LoadingErrorViewModeling
    let loadingIndicatorViewModel: LoadingIndicatorViewModeling
    private let mutableIsEmptyDataViewHidden = MutableProperty<Bool>(true)
    private let mutableIsLoadingErrorHidden = MutableProperty<Bool>(true)
    private let mutableIsLoadingIndicatorHidden = MutableProperty<Bool>(true)

    private var fetchAction: Action<Void, Void, DataProviderError>!

    // swiftlint:disable:next function_body_length
    init(
        dataProvider: DataProviding,
        emptyDataViewModel: EmptyDataViewModeling,
        loadingErrorViewModel: LoadingErrorViewModeling,
        loadingIndicatorViewModel: LoadingIndicatorViewModeling
        ) {
        self.dataProvider = dataProvider

        self.emptyDataViewModel = emptyDataViewModel
        self.loadingErrorViewModel = loadingErrorViewModel
        self.loadingIndicatorViewModel = loadingIndicatorViewModel

        // cell selection -> route
        cellModels.producer
            .sample(with: didSelectRowPipe.output)
            .map { cellModels, row -> PostCellModeling in
                return cellModels[row]
            }
            .map { cellModel -> PostsViewRoute in
                return .postDetail(post: cellModel.post)
            }
            .start(routeSelectedPipe.input)

        // posts -> cellmodels conversion
        mutableCellModels <~ dataProvider.posts
            .map { posts -> [PostCellModeling] in
                return posts?.map(PostCellModel.init) ?? []
        }

        // EmptyDataView visibility
        mutableIsEmptyDataViewHidden <~ cellModels.map { !$0.isEmpty }

        // fetch
        fetchAction = Action<Void, Void, DataProviderError> { [weak self] _
            -> SignalProducer<Void, DataProviderError> in
            guard let strongSelf = self else {
                return .empty
            }
            return strongSelf.dataProvider.fetchPosts()
        }

        fetchAction <~ SignalProducer<Void, NoError>.merge(
            shouldReloadWhenAppear.producer
                .sample(on: viewWillAppearPipe.output)
                .filter { $0 }
                .map { _ in () },
            loadingErrorViewModel.retryTappedOutput.producer,
            emptyDataViewModel.retryTappedOutput.producer,
            pullToRefreshTriggeredPipe.output.producer
        )

        // disable shouldReloadWhenAppear flag when start
        fetchAction.isExecuting
            .producer
            .skipRepeats()
            .filter { $0 } // start
            .startWithValues { [weak self] _ in
                self?.shouldReloadWhenAppear.value = false
        }

        // stop refresh control when fetch end
        fetchAction.isExecuting
            .producer
            .skipRepeats()
            .filter { !$0 } // end
            .startWithValues { [weak self] _ in
                self?.shouldStopRefreshControlPipe.input.send(value: ())
        }

        // error description
        fetchAction.errors
            .observeValues { [weak self] error in
                self?.loadingErrorViewModel.updateErrorMessage(to: error.localizedDescription)
        }

        // loading indicator view state
        mutableIsLoadingIndicatorHidden <~ SignalProducer.combineLatest(
            cellModels.producer.map { $0.isEmpty },
            fetchAction.isExecuting.producer
            )
            .map { isCellModelsEmpty, isExecuting -> Bool in
                // display indicator when "no cells" & "fetching"
                return !(isCellModelsEmpty && isExecuting)
        }

        // loading error view state
        mutableIsLoadingErrorHidden <~ SignalProducer.combineLatest(
            cellModels.producer.map { $0.isEmpty },
            fetchAction.isExecuting.producer,
            fetchAction.events.producer.map { $0.error != nil }
            )
            .map { isCellModelsEmpty, isExecuting, isLastFetchError -> Bool in
                // display error only when "no cells" & "not fetching" & "last fetch error"
                return !(isCellModelsEmpty && !isExecuting && isLastFetchError)
        }

        // TODO: disable retry buttons in loading views when fetching
    }
}

// MARK: - PostsViewModeling
extension PostsViewModel: PostsViewModeling {
    var cellModels: Property<[PostCellModeling]> {
        return Property(mutableCellModels)
    }
    func didSelectRow(index: Int) {
        didSelectRowPipe.input.send(value: index)
    }
    func viewWillAppear() {
        viewWillAppearPipe.input.send(value: ())
    }
    func pullToRefreshTriggered() {
        pullToRefreshTriggeredPipe.input.send(value: ())
    }
    var shouldStopRefreshControl: Signal<Void, NoError> {
        return shouldStopRefreshControlPipe.output
    }

    // LoadingAndEmptyViewsControllable
    var isEmptyDataViewHidden: Property<Bool> {
        return Property(mutableIsEmptyDataViewHidden).skipRepeats()
    }
    var isLoadingErrorHidden: Property<Bool> {
        return Property(mutableIsLoadingErrorHidden).skipRepeats()
    }
    var isLoadingIndicatorHidden: Property<Bool> {
        return Property(mutableIsLoadingIndicatorHidden).skipRepeats()
    }
}

// MARK: - PostsViewRouting
extension PostsViewModel: PostsViewRouting {
    var routeSelected: Signal<PostsViewRoute, NoError> {
        return routeSelectedPipe.output
    }
}
