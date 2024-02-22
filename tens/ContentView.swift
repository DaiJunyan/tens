//
//  ContentView.swift
//  tens
//
//  Created by Junyan Dai on 2/20/24.
//

import SwiftUI

class Cell {
    static var nextID = 0
    
    let id: Int
    var number: Int
    var rect: CGRect?
    
    init() {
        self.id = Cell.nextID
        Cell.nextID += 1
        self.number = Int.random(in: 1...9)
    }
}

struct ContentView: View {
    let columns: [GridItem] = Array(repeating: GridItem(.fixed(30)), count: 10)
    let cellSize: CGSize = CGSize(width: 30, height: 30)
    
    @State private var cells: [Cell] = (0..<100).map {_ in Cell()}
    @State private var selectedCellIndices = Set<Int>()
    @State private var selectionArea: CGRect?
    @State private var score: Int = 0
    @State private var timer: Timer? = nil
    @State private var elapsedSeconds: Int = 0
    
    var body: some View {
        VStack{
            // Score section
            HStack {
                Text("Score:")
                    .font(.title)
                    .fontWeight(.bold)
                Text("\(score)")
                    .font(.title)
                Text("\(elapsedSeconds)s")
                    .font(.title)
            }
                        .padding()
            ZStack (alignment: .topLeading) {
                LazyVGrid(columns: columns) {
                    ForEach(cells, id: \.id) { cell in
                        Text("\(cell.number)")
                            .frame(width: cellSize.width, height: cellSize.height)
                            .background() {
                                GeometryReader { geo -> Color in
                                    cell.rect = geo.frame(in: .named("container"))
                                    return Color.yellow.opacity(0.2)
                                }
                            }
                            .border(Color.yellow)
                            .background(selectedCellIndices.contains(cell.id) ? Color.yellow.opacity(0.5) : Color.clear)
                            .opacity(cell.number == 0 ? 0 : 1)
                    }
                }
                .coordinateSpace(name: "container")
                // Rectangle selection area
                if let area = selectionArea {
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 2)
                        .background(Color.blue.opacity(0.3))
                        .frame(width: area.width, height: area.height)
                        .offset(x: area.origin.x, y: area.origin.y)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let startLocation = value.startLocation
                        let currentLocation = value.location
                        
                        let minX = min(startLocation.x, currentLocation.x)
                        let minY = min(startLocation.y, currentLocation.y)
                        let maxX = max(startLocation.x, currentLocation.x)
                        let maxY = max(startLocation.y, currentLocation.y)
                        
                        let newArea = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                        selectionArea = newArea
                        
                        selectedCellIndices = identifySelectedCells(area: newArea)
                    }
                    .onEnded { value in
                        var sum = 0
                        for cell in cells {
                            if selectedCellIndices.contains(cell.id) {
                                sum += cell.number
                            }
                        }
                        
                        if sum == 10 {
                            var count = 0
                            for cell in cells {
                                if selectedCellIndices.contains(cell.id) {
                                    if (cell.number != 0) {
                                        count += 1
                                    }
                                    cell.number = 0
                                }
                            }
                            //                        for id in selectedCellIndices {
                            //                            cells[id].number = 0
                            //                        }
                            score += count
                        }
                        
                        selectionArea = nil
                        selectedCellIndices.removeAll()
                    }
            )
            // Button to reload or clear content
            Button(action: {
                // Perform the action to reload or clear content here
                reloadCells()
            }) {
                Text("Reload")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            // Start the timer when the view appears
            startTimer()
        }
        .onDisappear {
            // Stop the timer when the view disappears
            stopTimer()
        }
    }
    
    private func identifySelectedCells(area: CGRect) -> Set<Int> {
        var selectedCellIndices = Set<Int>()
        for cell in cells {
            if area.intersects(cell.rect!) {
                selectedCellIndices.insert(cell.id)
            }
        }
        return selectedCellIndices
    }
    
    private func reloadCells() {
        Cell.nextID = 0
        cells = (0..<100).map {_ in Cell()}
        score = 0
        
        stopTimer()
        elapsedSeconds = 0
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Update the elapsedSeconds or perform other timer-related logic
            elapsedSeconds += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
