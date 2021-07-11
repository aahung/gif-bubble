//
//  ContentView.swift
//  Gif Bubble
//
//  Created by Xinhong LIU on 7/9/21.
//

import SwiftUI
import Introspect
import SDWebImageSwiftUI

let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

struct GifImageActionRow: View {
    let gifImage: GiphyGifImage

    static let formatter: ByteCountFormatter = {
        let _formatter = ByteCountFormatter()
        _formatter.countStyle = .file
        return _formatter
    }()

    var body: some View {
        VStack {
            HStack {
                Text(GifImageActionRow.formatter.string(fromByteCount: Int64(gifImage.size)!))
                    .font(.footnote)
                Spacer()
                Button("🔗") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(gifImage.url, forType: .string)
                }
                Button("MD") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString("![](\(gifImage.url)", forType: .string)
                }
            }
        }
    }
}

struct GifView: View {
    let gif: GiphyGif

    @State private var hovering = false

    var body: some View {
        ZStack {
            WebImage(url: URL(string: gif.images.fixed_height_small.url))
                .frame(width: 150, height: 120, alignment: .center)
                .scaledToFill()
                .clipped()
            if hovering {
                VStack {
                    Text(gif.title.count > 0 ? gif.title : gif.id)
                        .font(.footnote)
                        .lineLimit(1)
                    Spacer()
                    if gif.images.original.size != gif.images.downsized.size {
                        GifImageActionRow(gifImage: gif.images.downsized)
                    }
                    GifImageActionRow(gifImage: gif.images.original)
                }
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity,
                       alignment: .center)
                .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                .background(Color.black.opacity(0.7))
            }
        }
        .onHover(perform: { hovering in
            self.hovering = hovering
        })
    }
}

struct ContentView: View {
    // Use singleton to perserve state even ContentView is destroyed
    @ObservedObject var searchResultViewModel: SearchResultViewModel = SearchResultViewModel.shared

    var body: some View {
        VStack(alignment: .center, spacing: nil/*@END_MENU_TOKEN@*/, content: {
            HStack(alignment: .top, spacing: 5, content: {
                TextField("Search...", text: $searchResultViewModel.searchText)
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                    }
                Picker(selection: .constant(1)/*@END_MENU_TOKEN@*/, label: Text("")) {
                    Text("Giphy").tag(1)
                }
                .disabled(true)
                .labelsHidden()
                .frame(width: 80)
                Button("Quit") {
                    NSApp.terminate(self)
                }
            })
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(searchResultViewModel.gifs, id: \.id) { gif in
                        GifView(gif: gif).onAppear(perform: {
                            if gif.id == searchResultViewModel.gifs.last?.id {
                                searchResultViewModel.fetchMore()
                            }
                        })
                    }
                })
            }
            Spacer()
        })
        .padding(10)
        .frame(width: 620, height: 720)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
