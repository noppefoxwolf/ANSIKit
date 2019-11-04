//
//  ContentView.swift
//  Example
//
//  Created by Tomoya Hirano on 2019/11/04.
//  Copyright © 2019 Tomoya Hirano. All rights reserved.
//

import SwiftUI

let log: String = {
    let url = Bundle.main.url(forResource: "log", withExtension: "txt")!
    return try! String(contentsOf: url)
}()

struct ContentView: View {
    var body: some View {
        ANSIText(log)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import UIKit

struct ANSIText: UIViewRepresentable {
    typealias UIViewType = UITextView
    
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    func makeUIView(context: UIViewRepresentableContext<ANSIText>) -> ANSIText.UIViewType {
        return .init()
    }
    
    func updateUIView(_ uiView: ANSIText.UIViewType, context: UIViewRepresentableContext<ANSIText>) {
        let options = ANSI.Options(color: UIColor.white, font: UIFont.preferredFont(forTextStyle: .caption1))
        let attributed = NSAttributedString(ansiString: text, options: options)
        uiView.isEditable = false
        uiView.attributedText = attributed
        uiView.backgroundColor = .black
    }
}
