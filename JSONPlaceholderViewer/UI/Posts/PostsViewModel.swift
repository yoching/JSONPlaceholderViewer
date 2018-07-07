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

        cellModels.producer
            .sample(with: didSelectRowPipe.output)
            .map { cellModels, row -> PostCellModeling in
                return cellModels[row]
            }
            .map { cellModel -> PostsViewRoute in
                return .postDetail(post: cellModel.post)
            }
            .start(routeSelectedPipe.input)

        mutableCellModels <~ dataProvider.posts
            .map { posts -> [PostCellModeling] in
                return posts?.map(PostCellModel.init) ?? []
        }

        mutableIsEmptyDataViewHidden <~ cellModels.map { !$0.isEmpty }

        let fetchTrigger = SignalProducer<Void, NoError>.merge(
            shouldReloadWhenAppear.producer
                .sample(on: viewWillAppearPipe.output)
                .filter { $0 }
                .map { _ in () },
            loadingErrorViewModel.retryTappedOutput.producer,
            emptyDataViewModel.retryTappedOutput.producer,
            pullToRefreshTriggeredPipe.output.producer
        )

        cellModels.producer
            .sample(on: fetchTrigger)
            .on(value: { [weak self] cellModels in
                self?.shouldReloadWhenAppear.value = false

                self?.mutableIsLoadingErrorHidden.value = true
                if cellModels.isEmpty {
                    self?.mutableIsLoadingIndicatorHidden.value = false
                }
            })
            .flatMap(.latest) { [weak self] _ -> SignalProducer<Result<Void, DataProviderError>, NoError> in
                guard let strongSelf = self else {
                    return .empty
                }
                return strongSelf.dataProvider.fetchPosts().resultWrapped() // TODO: change this to Action for multiple trigger restriction?
            }
            .on(value: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.loadingErrorViewModel.updateErrorMessage(to: error.localizedDescription)
                    if let strongSelf = self,
                        strongSelf.cellModels.value.isEmpty {
                        self?.mutableIsLoadingErrorHidden.value = false
                    }
                case .success:
                    break
                }

                self?.mutableIsLoadingIndicatorHidden.value = true
                self?.shouldStopRefreshControlPipe.input.send(value: ())
            })
            .start()
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
