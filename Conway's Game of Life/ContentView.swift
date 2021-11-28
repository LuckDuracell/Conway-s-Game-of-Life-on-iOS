//
//  ContentView.swift
//  Conway's Game of Life
//
//  Created by Luke Drushell on 11/27/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var gridLength: Int = 20
    @State var iteration: Int = 0
    @State var matrix: [[Bool]] = []
    @State var playing = false
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Stepper("Grid Length - \(gridLength)", value: $gridLength, in: 1...80)
                        .padding(10)
                        .background(.regularMaterial)
                        .cornerRadius(15)
                        .padding(.horizontal, 5)
                    HStack {
                        HStack {
                            Text("Iteration - \(iteration)")
                            Spacer()
                            Button {
                                if matrix.isEmpty != true { iterate() }
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 15)
                                    .background(Color.gray.opacity(0.18))
                                    .cornerRadius(10)
                            }
                            Button {
                                playing.toggle()
                            } label: {
                                Image(systemName: playing ? "pause.fill" : "play.fill")
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 15)
                                    .background(Color.gray.opacity(0.18))
                                    .cornerRadius(10)
                            } .onReceive(timer) { time in
                                if playing && (matrix.isEmpty == false) {
                                    iterate()
                                }
                            }
                        }
                        .padding(10)
                        .background(.regularMaterial)
                        .cornerRadius(15)
                        
                        Button {
                            iteration = 0
                            matrix.removeAll()
                            for _ in 0...gridLength - 1 {
                                var row: [Bool] = []
                                for _ in 0...gridLength - 1 {
                                    row.append(false)
                                }
                                matrix.append(row)
                            }
                        } label: {
                            Label("Create", systemImage: "person.3.fill")
                                .foregroundColor(.primary)
                                .padding()
                                .background(.regularMaterial)
                                .cornerRadius(15)
                        }
                        
                    } .padding(.horizontal, 5)
                    
                    if matrix.count == gridLength {
                        VStack(spacing: 0) {
                            ForEach(0...gridLength - 1, id: \.self, content: { i in
                                HStack(spacing: 0) {
                                    ForEach(0...gridLength - 1, id: \.self, content: { i2 in
                                        Button {
                                            var splitMatrix: [Bool] = matrix[i]
                                            splitMatrix[i2].toggle()
                                            matrix[i] = splitMatrix
                                        } label: {
                                            cell(x: i2, array: $matrix[i])
                                        }
                                    })
                                }
                            })
                        }
                        .border(.black, width: 0.8)
                        .padding(.horizontal, 5)
                    }
                    Spacer()
                } .padding(.top, 25)
            } .navigationBarTitle("The Game of Life")
        }
    }
    
    func iterate() {
        iteration += 1
    //Code for Iteration:
        //Copy so that the birthing and surviving can be independant of one another
        let matrixCopy = matrix
        //Find Live Cell Positions
        var liveCellPositions: [cellData] = []
        for i in 0...gridLength-1 {
            let row = matrix[i]
            for i2 in 0...gridLength-1 {
                if row[i2] { liveCellPositions.append(cellData(x: i2, y: i)) }
            }
        }
        if liveCellPositions.count > 0 {
            //Find Surviving Cells
            for i in 0...liveCellPositions.count-1 {
                var touchingCount = 0
                var rowAbove: [Bool] = []
                if liveCellPositions[i].y > 0 { rowAbove = matrixCopy[liveCellPositions[i].y-1] }
                var rowBelow: [Bool] = []
                if liveCellPositions[i].y < (gridLength-1) { rowBelow = matrixCopy[liveCellPositions[i].y+1] }
                let row = matrixCopy[liveCellPositions[i].y]
                //check left
                if liveCellPositions[i].x > 0 {
                    if row[liveCellPositions[i].x - 1] { touchingCount += 1 }
                }
                //check right
                if liveCellPositions[i].x < (gridLength-1) {
                    if row[liveCellPositions[i].x + 1] { touchingCount += 1 }
                }
                //check up
                if rowAbove.isEmpty != true {
                if rowAbove[liveCellPositions[i].x] { touchingCount += 1 }
                }
                //check down
                if rowBelow.isEmpty != true {
                if rowBelow[liveCellPositions[i].x] { touchingCount += 1 }
                }
                //check down left
                if rowBelow.isEmpty != true {
                    if liveCellPositions[i].x > 0 {
                        if rowBelow[liveCellPositions[i].x - 1] { touchingCount += 1 }
                    }
                }
                //check down right
                if rowBelow.isEmpty != true {
                    if liveCellPositions[i].x < (gridLength-1) {
                        if rowBelow[liveCellPositions[i].x + 1] { touchingCount += 1 }
                    }
                }
                //check up left
                if rowAbove.isEmpty != true {
                    if liveCellPositions[i].x > 0 {
                        if rowAbove[liveCellPositions[i].x - 1] { touchingCount += 1 }
                    }
                }
                //check up right
                if rowAbove.isEmpty != true {
                    if liveCellPositions[i].x < (gridLength-1) {
                        if rowAbove[liveCellPositions[i].x + 1] { touchingCount += 1 }
                    }
                }
                //Update
                if 2 > touchingCount || touchingCount > 3 {
                    var row = matrix[liveCellPositions[i].y]
                    row[liveCellPositions[i].x] = false
                    matrix[liveCellPositions[i].y] = row
                }
            }
        }
        //Find Birthing Cells
        for i in 0...gridLength-1 {
                for i2 in 0...gridLength-1 {
                    var touchingCount = 0
                    let row = matrixCopy[i]
                    var rowAbove: [Bool] = []
                    var rowBelow: [Bool] = []
                    if i > 0 { rowAbove = matrixCopy[i-1] }
                    if i < (gridLength-1) { rowBelow = matrixCopy[i+1] }
                    
                    //check left
                    if i2 > 0 {
                        if row[i2-1] { touchingCount += 1 }
                    }
                    //check right
                    if i2 < (gridLength-1) {
                        if row[i2 + 1] { touchingCount += 1 }
                    }
                    //check up
                    if rowAbove.isEmpty != true {
                        if rowAbove[i2] { touchingCount += 1 }
                    }
                    //check down
                    if rowBelow.isEmpty != true {
                        if rowBelow[i2] { touchingCount += 1 }
                    }
                    //check up left
                    if rowAbove.isEmpty != true {
                        if i2 > 0 {
                            if rowAbove[i2 - 1] { touchingCount += 1 }
                        }
                    }
                    //check up right
                    if rowAbove.isEmpty != true {
                        if i2 < (gridLength-1) {
                            if rowAbove[i2 + 1] { touchingCount += 1 }
                        }
                    }
                    //check down left
                    if rowBelow.isEmpty != true {
                        if i2 > 0 {
                            if rowBelow[i2 - 1] { touchingCount += 1 }
                        }
                    }
                    //check down right
                    if rowBelow.isEmpty != true {
                        if i2 < (gridLength-1) {
                            if rowBelow[i2 + 1] { touchingCount += 1 }
                        }
                    }
                    if touchingCount == 3 {
                        var row = matrix[i]
                        row[i2] = true
                        matrix[i] = row
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct cell: View {
    
    var x: Int
    @Binding var array: [Bool]
    
    var body: some View {
        Rectangle()
            .scaledToFit()
            .foregroundColor(array[x] ? .black : .white)
            .border(.black, width: 0.2)
    }
}

struct cellData {
    var x: Int
    var y: Int
}
