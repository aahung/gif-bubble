//
//  searchResultViewModel.swift
//  Gif Bubble
//
//  Created by Xinhong LIU on 7/9/21.
//

import Foundation
import Combine
import Alamofire

let GIPHY_KEY = "lBkWp4xWgwegUbSnnms1bsvPMX0zoT2i"; // some dummy account, ok to include in git

struct GiphyPagination: Decodable {
    let offset: Int
    let count: Int
}

struct GiphyGifImage: Decodable {
    let size: String
    let url: String
}

struct GiphyGifImages: Decodable {
    let original: GiphyGifImage
    let downsized: GiphyGifImage
    let fixed_height_small: GiphyGifImage
}

struct GiphyGif: Decodable {
    let title: String
    let id: String
    let images: GiphyGifImages
}

struct GiphyResponse: Decodable {
    let pagination: GiphyPagination
    let data: [GiphyGif]
}

class SearchResultViewModel: ObservableObject {

    static let shared = SearchResultViewModel()

    var subscription: Set<AnyCancellable> = []
    @Published private (set) var pagination: GiphyPagination?
    @Published var gifs: [GiphyGif] = []
    private var gifIds: Set<String> = [] // keep track of all image ids

    @Published var searchText: String = String()

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .map({ (string) -> String? in
                return string.count > 0 ? string : nil
            })
            .compactMap { $0 }
            .sink { text in
                self.gifIds = []
                self.gifs = []
                self.pagination = nil
                self.search(text: text, offset: 0)
            }
            .store(in: &subscription)
    }

    private func search(text: String, offset: Int) {
        AF.request(
            "https://api.giphy.com/v1/gifs/search",
            method: .get,
            parameters: ["q": text, "api_key": GIPHY_KEY, "offset": offset],
            encoding: URLEncoding.default
        )
        .validate()
        .publishDecodable(type: GiphyResponse.self)
        .value()
        .sink(receiveCompletion: { handler in
            debugPrint(handler)
        }, receiveValue: { response in
            self.pagination = response.pagination
            let newGifs = response.data.filter({ gif in
                return !self.gifIds.contains(gif.id)
            })
            self.gifs += newGifs
            newGifs.forEach { gif in
                self.gifIds.insert(gif.id)
            }
        })
        .store(in: &subscription)
    }

    func fetchMore() {
        self.search(text: searchText, offset: gifs.count)
    }
}
