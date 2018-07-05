//
//  LoadingIndicatorViewModel.swift
//  PagingManagerSample
//
//  Created by Yoshikuni Kato on 2016/09/20.
//  Copyright © 2016年 Ohako Inc. All rights reserved.
//

import UIKit

protocol LoadingIndicatorViewModeling {
    var loadingMessage: String { get }
}

struct LoadingIndicatorViewModel: LoadingIndicatorViewModeling {
    let loadingMessage: String
}
