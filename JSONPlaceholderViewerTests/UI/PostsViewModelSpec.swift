//
//  PostsViewModelSpec.swift
//  JSONPlaceholderViewerTests
//
//  Created by Yoshikuni Kato on 6/23/18.
//  Copyright © 2018 Yoshikuni Kato. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift

@testable import JSONPlaceholderViewer

class PostsViewModelSpec: QuickSpec {
    override func spec() {

        var dataProviderMock: DataProviderMock!

        var postsViewModel: PostsViewModel!

        beforeEach {
            dataProviderMock = DataProviderMock()
            postsViewModel = PostsViewModel(
                dataProvider: dataProviderMock
            )
        }

        describe("cellModels") {
            it("reflects posts in DataProvider") {
                // arrange
                var cellModelChanges: [[PostCellModeling]] = []
                postsViewModel.cellModels
                    .producer
                    .startWithValues { cellModels in
                        cellModelChanges.append(cellModels)
                }

                // act
                dataProviderMock.mutablePosts.value = [
                    PostMock(identifier: 1, title: "1"),
                    PostMock(identifier: 2, title: "2"),
                    PostMock(identifier: 3, title: "3")
                ]

                // assert
                expect(cellModelChanges[0].count).toEventually(equal(0))
                expect(cellModelChanges[1].count).toEventually(equal(3))
            }
        }

    }
}

final class DataProviderMock: DataProviding {
    var posts: Property<[PostProtocol]?> {
        return Property(mutablePosts)
    }
    let mutablePosts = MutableProperty<[PostProtocol]?>(nil)

    func fetchPosts() {

    }
}
