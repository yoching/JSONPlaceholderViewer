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
}

enum PostsViewRoute {
    case postDetail(post: PostProtocol)
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

    // LoadingViewsControllable
    let emptyDataViewModel: EmptyDataViewModeling
    let loadingErrorViewModel: LoadingErrorViewModeling
    let loadingIndicatorViewModel: LoadingIndicatorViewModeling
    private let mutableIsEmptyDataViewHidden: MutableProperty<Bool>
    private let mutableIsLoadingErrorHidden: MutableProperty<Bool>
    private let mutableIsLoadingIndicatorHidden: MutableProperty<Bool>

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

        mutableIsEmptyDataViewHidden = MutableProperty<Bool>(true)
        mutableIsLoadingErrorHidden = MutableProperty<Bool>(true)
        mutableIsLoadingIndicatorHidden = MutableProperty<Bool>(true)

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
            emptyDataViewModel.retryTappedOutput.producer
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
            .flatMap(.latest) { _ -> SignalProducer<Result<Void, DataProviderError>, NoError> in
                return self.dataProvider.fetchPosts().resultWrapped() // TODO: change this to Action for multiple trigger restriction?
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
            })
            .start()
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
