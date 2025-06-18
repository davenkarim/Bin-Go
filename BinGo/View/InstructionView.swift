//
//  InstructionView.swift
//  BinGo
//
//  Created by sam on 14/06/25.
//

import SwiftUI

struct InstructionView: View {
    var body: some View {
        VStack {
            HStack {
                Image("Arrow-Left").padding(.top,60)
                Spacer()
            }
            Spacer()
            HStack(spacing:0) {
                Image("bingo_character_instruction")
                    .resizable()
                    .frame(width: 480, height: 480)
                VStack {
                    Spacer()
                    Text("Place your trash inside the box!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal,30)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green)
                        ).offset(x: -135, y: 0)
                    Spacer().frame(height: 60)
                }
                VStack {
                    Image("Arrow-Right")
                        .offset(x:-40)
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.bottom, 100)
        }
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Text("Error: \(message)")
                .foregroundColor(.red)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
            Spacer()
        }
        .padding()
    }
}

#Preview{
    InstructionView()
}
