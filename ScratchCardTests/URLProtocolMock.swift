//
//  URLProtocolMock.swift
//

import Foundation

class URLProtocolMock: URLProtocol {

    static var dataForURLs: [URL?: Data] = [:]

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        self.client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .allowed)

        if let url = request.url,
           let data = URLProtocolMock.dataForURLs[url]
        {
            self.client?.urlProtocol(self, didLoad: data)
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}
