//
//  Helpers.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 8/7/24.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .padding()
            .background(Color.black)
            .clipShape(.buttonBorder)
            .opacity(configuration.isPressed ? 0.25 : 1)
    }
}

extension ButtonStyle where Self == MainButtonStyle {
    static var main: MainButtonStyle { .init() }
}
