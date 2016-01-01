//
//  Board.swift
//  Clue
//
//  Created by Ben Chen on 12/30/15.
//  Copyright © 2015 Ben Chen. All rights reserved.
//

import Foundation
import UIKit

let ben = Player(name: "Ben", numberOfClues: 3)
let burak = Player(name: "Burak", numberOfClues: 3)
let xiaoyi = Player(name: "Xiaoyi", numberOfClues: 3)
let shupin = Player(name: "Shupin", numberOfClues: 3)
let jing = Player(name: "Jing", numberOfClues: 3)
let ma = Player(name: "Ma", numberOfClues: 3)
let players = [ben, burak, xiaoyi, shupin, jing, ma]
let board = Board(players: players)

// Turn 1
let benSuggestion = Suggestion(player: ben, suspect: .ColMustard, weapon: .Knife, room: .Hall)
let burakResponse = try Response(player: burak, suggestion: benSuggestion, type: .HasClue(Clue.Weapon(.Knife)))
try board.update(burakResponse)
board

// Turn 2
let burakSuggestion = Suggestion(player: burak, suspect: .ProfPlum, weapon: .Candlestick, room: .Lounge)
let xiaoyiResponse = try Response(player: xiaoyi, suggestion: burakSuggestion, type: .HasNone)
try board.update(xiaoyiResponse)
board

// Turn3
let xiaoyiSuggestion = Suggestion(player: xiaoyi, suspect: .MrGreen, weapon: .Knife, room: .DinningRoom)
let shupinResponse = try Response(player: shupin, suggestion: xiaoyiSuggestion, type: .HasSomeClue)
try board.update(shupinResponse)
board
