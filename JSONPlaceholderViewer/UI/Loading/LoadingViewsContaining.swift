//
//  LoadingViewsContaining.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 7/6/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol LoadingViewsContaining {
    var loadingErrorView: LoadingErrorView! { get }
    var loadingIndicatorView: LoadingIndicatorView! { get }
}

extension LoadingViewsContaining {
    func configureLoadingViews(with controllable: LoadingViewsControllable) {
        loadingErrorView.configure(with: controllable.loadingErrorViewModel)
        loadingErrorView.reactive.isHidden <~ controllable.isLoadingErrorHidden

        loadingIndicatorView.configure(with: controllable.loadingIndicatorViewModel)
        loadingIndicatorView.reactive.isHidden <~ controllable.isLoadingIndicatorHidden
    }
}

protocol LoadingAndEmptyViewsContaining: LoadingViewsContaining {
    var emptyDataView: EmptyDataView! { get }
}

extension LoadingAndEmptyViewsContaining {
    func configureLoadingAndEmptyViews(with controllable: LoadingAndEmptyViewsControllable) {
        emptyDataView.configure(with: controllable.emptyDataViewModel)
        emptyDataView.reactive.isHidden <~ controllable.isEmptyDataViewHidden
        self.configureLoadingViews(with: controllable)
    }
}
