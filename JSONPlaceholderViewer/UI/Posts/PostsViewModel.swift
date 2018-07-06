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

protocol PostsViewModeling: LoadingViewsControllable {
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
    let loadingIndicatorViewModel: LoadingIndicatorViewModeling
    let loadingErrorViewModel: LoadingErrorViewModeling
    private let mutableIsLoadingIndicatorHidden: MutableProperty<Bool>
    private let mutableIsLoadingErrorHidden: MutableProperty<Bool>

    init(
        dataProvider: DataProviding,
        loadingIndicatorViewModel: LoadingIndicatorViewModeling,
        loadingErrorViewModel: LoadingErrorViewModeling
        ) {
        self.dataProvider = dataProvider
        self.loadingIndicatorViewModel = loadingIndicatorViewModel
        self.loadingErrorViewModel = loadingErrorViewModel
        mutableIsLoadingIndicatorHidden = MutableProperty<Bool>(true)
        mutableIsLoadingErrorHidden = MutableProperty<Bool>(true)

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

        let fetchTrigger = Signal<Void, NoError>.merge(
            viewWillAppearPipe.output,
            loadingErrorViewModel.retryTappedOutput
        )

        shouldReloadWhenAppear.producer
            .sample(on: fetchTrigger)
            .filter { $0 }
            .on(value: { [weak self] _ in
                self?.shouldReloadWhenAppear.value = false

                self?.mutableIsLoadingErrorHidden.value = true
                self?.mutableIsLoadingIndicatorHidden.value = false
            })
            .flatMap(.latest) { _ -> SignalProducer<Result<Void, DataProviderError>, NoError> in
                return self.dataProvider.fetchPosts().resultWrapped()
            }
            .on(value: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.loadingErrorViewModel.updateErrorMessage(to: error.localizedDescription)
                    self?.mutableIsLoadingErrorHidden.value = false
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

    // LoadingViewsControllable
    var isLoadingIndicatorHidden: Property<Bool> {
        return Property(mutableIsLoadingIndicatorHidden).skipRepeats()
    }

    var isLoadingErrorHidden: Property<Bool> {
        return Property(mutableIsLoadingErrorHidden).skipRepeats()
    }
}

// MARK: - PostsViewRouting
extension PostsViewModel: PostsViewRouting {
    var routeSelected: Signal<PostsViewRoute, NoError> {
        return routeSelectedPipe.output
    }
}
