//
//  SearchAPIInteractorTests.swift
//  MovieSearchTests
//
//  Created by Jageloo Yadav on 10/12/21.
//

import XCTest
@testable import MovieSearch

class ApiClientMock: APIClientProtocol {
    var isApiCalled = false
    func call<R: Encodable, T: Decodable>(request: R, completion: ((Result<T, Error>) -> Void)?) {
        isApiCalled = true
        
        if let query = request as? String, query.contains("query=") {
            isApiCalled = true
            completion?(.success(SearchResult.init(page: 1, results: []) as! T))
        }
    }
}

class Mock: SearchAPIInteractorOutPut {
    var isShowMoviesCalled = false
    func showMovies() {
        isShowMoviesCalled = true
    }
}

class SearchAPIInteractorTests: XCTestCase {
    var apiMock: ApiClientMock!
    var presenterMock: Mock!
    var subject: SearchAPIInteractor!
    
    override func setUp() {
        apiMock = ApiClientMock()
        presenterMock = Mock()
        subject = SearchAPIInteractor()
        subject.presenter = presenterMock
        subject.apiClient = apiMock
    }

    override func tearDown() {
        apiMock = nil
        presenterMock = nil
        subject = nil
    }
    
    func testFetchData_returnsFail() {
        subject.fetchData(query: "")
        XCTAssertTrue(apiMock.isApiCalled == true)
        XCTAssertFalse(presenterMock.isShowMoviesCalled)
    }
    
    func testFetchData_returnsSuccess() {
        subject?.fetchData(query: "query=Harry")
        XCTAssertTrue(apiMock?.isApiCalled == true)
        XCTAssertTrue(presenterMock?.isShowMoviesCalled == true)
    }
}
