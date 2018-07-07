//
//  LoadingViewsControllable.swift
//  JSONPlaceholderViewer
//
//  Created by Yoshikuni Kato on 7/6/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol LoadingViewsControllable {
    var isLoadingErrorHidden: Property<Bool> { get }
    var loadingErrorViewModel: LoadingErrorViewModeling { get }

    var isLoadingIndicatorHidden: Property<Bool> { get }
    var loadingIndicatorViewModel: LoadingIndicatorViewModeling { get }
}

protocol LoadingAndEmptyViewsControllable: LoadingViewsControllable {
    var isEmptyDataViewHidden: Property<Bool> { get }
    var emptyDataViewModel: EmptyDataViewModeling { get }
}
