//
//  Algorithm.swift
//  Clue
//
//  Created by Ben Chen on 12/30/15.
//  Copyright © 2015 Ben Chen. All rights reserved.
//

import Foundation

public enum SuspectClue: String {
  case ColMustard = "Col. Mustard", ProfPlum = "Prof. Plum", MrGreen = "Mr. Green", MrsPeacock = "Mrs. Peacock", MissScarlet = "Miss Scarlet", MrsWhite = "Mrs White"
  public static let allValues = [ColMustard, ProfPlum, MrGreen, MrsPeacock, MissScarlet, MrsWhite]
}

public enum WeaponClue: String {
  case Knife = "🗡", Candlestick = "🕯", Pistol = "🔫", Rope = "Rope", LeadPipe = "Pipe", Wrench = "🔧"
  public static let allValues = [Knife, Candlestick, Pistol, Rope, LeadPipe, Wrench]
}

public enum RoomClue: String {
  case Hall = "Hall", Lounge = "Lounge", DinningRoom = "Dinning Room", Kitchen = "Kitchen", BallRoom = "Ball Room", Conservatory = "Conservatory", BilliardRoom = "Billiard Room", Library = "Library", Study = "Study"
  public static let allValues = [Hall, Lounge, DinningRoom, Kitchen, BallRoom, Conservatory, BilliardRoom, Library, Study]
}

public enum Clue: Hashable, Equatable, CustomStringConvertible {
  case Suspect(SuspectClue), Weapon(WeaponClue), Room(RoomClue)
  
  public static let allValues = [Suspect(.ColMustard), Suspect(.ProfPlum), Suspect(.MrGreen), Suspect(.MrsPeacock), Suspect(.MissScarlet), Suspect(.MrsWhite),
    Weapon(.Knife), Weapon(.Candlestick), Weapon(.Pistol), Weapon(.Rope), Weapon(.LeadPipe), Weapon(.Wrench),
    Room(.Hall), Room(.Lounge), Room(.DinningRoom), Room(.Kitchen), Room(.BallRoom), Room(.Conservatory), Room(.BilliardRoom), Room(.Library), Room(.Study)]
  
  public var description: String {
    return clueRawValue()
  }
 
  private func clueRawValue() -> String {
    switch self {
    case .Suspect(let suspect):
      return suspect.rawValue
    case .Weapon(let weapon):
      return weapon.rawValue
    case .Room(let room):
      return room.rawValue
    }
  }
  
  public var hashValue: Int {
    return clueRawValue().hashValue
  }
}

public func ==(lhs: Clue, rhs: Clue) -> Bool {
  return lhs.clueRawValue() == rhs.clueRawValue()
}

public enum State: CustomStringConvertible {
  case Unknown, NotHave, Have, MayHave
  
  public var description: String {
    switch self {
    case .Unknown:
      return ""
    case .NotHave:
      return "✕"
    case .Have:
      return "✓"
    case .MayHave:
      return "?"
    }
  }
}

public enum UpdateError: ErrorType {
  case InvalidInput
  case InconsistentNewValue
}

public struct Suggestion {
  let player: Player // player who's making the suggestion
  let suspect: Clue
  let weapon: Clue
  let room: Clue
  
  public init(player: Player, suspect: SuspectClue, weapon: WeaponClue, room: RoomClue) {    
    self.player = player
    self.suspect = Clue.Suspect(suspect)
    self.weapon = Clue.Weapon(weapon)
    self.room = Clue.Room(room)
  }
  
  func allClues() -> [Clue] {
    return [suspect, weapon, room]
  }
}

public enum ResponseType {
  case HasNone
  case HasSomeClue
  case HasClue(Clue)
}

public struct Response {
  let player: Player // player who's responding to a suggestion
  let suggestion: Suggestion // suggestion which the player responds to
  let type: ResponseType
  
  public init(player: Player, suggestion: Suggestion, type: ResponseType) throws {
    var clueInResponse: Clue? = nil
    switch type {
    case .HasClue(let clue):
      clueInResponse = clue
    default:
      break
    }
    
    if let theClue = clueInResponse {
      guard suggestion.allClues().contains(theClue) else {
        throw UpdateError.InvalidInput
      }
    }
        
    self.player = player
    self.suggestion = suggestion
    self.type = type
  }
}

// This kind of simulates one column on the note for one player
// one Player struct keeps track of if we know which clues this player has
public class Player: CustomStringConvertible, Hashable, Equatable {
  
  public let name: String
  let numberOfClues: UInt
  
  public var states = [Clue: State]()
  
  public var description: String {
    return "\(name) with \(numberOfClues) clues"
  }
  
  public var hashValue: Int {
    return name.hashValue
  }
  
  public init(name: String, numberOfClues: UInt) {
    self.name = name
    self.numberOfClues = numberOfClues
    
    for clue in Clue.allValues {
      states[clue] = .Unknown
    }
  }
  
  public func update(response: Response) throws {
    if response.player.name == self.name {
      try updateSelf(response)
    } else {
      try updateOther(response)
    }
  }
  
  private func updateSelf(response: Response) throws {
    // TODO: we should be able to compare the two players directly
    guard response.player.name == self.name else {
      throw UpdateError.InvalidInput
    }
    
    switch response.type {
    case .HasNone:
      try update(response.suggestion.suspect, state: .NotHave)
      try update(response.suggestion.weapon, state: .NotHave)
      try update(response.suggestion.room, state: .NotHave)
    case .HasSomeClue:
      try update(response.suggestion.suspect, state: .MayHave)
      try update(response.suggestion.weapon, state: .MayHave)
      try update(response.suggestion.room, state: .MayHave)
      
      // If we know that the Player doesn't have two clues of the three
      // then we know that she must have the third one
      let clues = [response.suggestion.suspect, response.suggestion.weapon, response.suggestion.room]
      
      for (index, clue) in clues.enumerate() {
        var otherClues = clues
        otherClues.removeAtIndex(index)
        
        var donnotHaveOtherClues = true
        for otherClue in otherClues {
          if states[otherClue] != .NotHave {
            donnotHaveOtherClues = false
            break
          }
        }
        
        if (donnotHaveOtherClues) {
          try update(clue, state: .Have)
          break
        }
      }
    case .HasClue(let clue):
      try update(clue, state: .Have)
    }
  }
  
  private func updateOther(response: Response) throws {
    // TODO: we should be able to compare the two players directly
    guard response.player.name != self.name else {
      throw UpdateError.InvalidInput
    }
    
    switch response.type {
    case .HasNone:
      break
    case .HasSomeClue:
      break
    case .HasClue(let clue):
      try update(clue, state: .NotHave)
    }
  }
  
  private func update(clue: Clue, state: State) throws {
    if states[clue] == state {
      return
    }
    
    if states[clue] == .Have || states[clue] == .NotHave {
      guard state == .MayHave else {
        throw UpdateError.InconsistentNewValue
      }
      // Ignore the MayHave case if we already know for certain that if this player has or does not have the clue
      return
    }
    
    states[clue] = state
  }
  
  // See if we can deduct anyother clue that this player has
  // e.g. if the player has 3 clues, and we already know that she doesn't have any other clues
  // then we know for certain that
  func postUpdate() {
    
  }
  
  private func allCluesDetermined() -> Bool {
    return cluesMatchingState(.Have).count == Int(numberOfClues)
  }
  
  private func cluesMatchingState(state: State) -> [Clue] {
    var clues = [Clue]()
    
    for (clue, theState) in states {
      if (theState == state) {
        clues.append(clue)
      }
    }
    
    return clues
  }
}

public func ==(lhs: Player, rhs: Player) -> Bool {
  return lhs.name == rhs.name
}

public class Board {
  public let players: [Player]
  
  public init(players: [Player], playing: Player, initialClues: [Clue]) throws {
    self.players = players
    
    guard players.contains(playing) else {
      throw UpdateError.InvalidInput
    }

    guard playing.numberOfClues == UInt(initialClues.count) else {
      throw UpdateError.InvalidInput
    }

    var otherPlayers = players
    otherPlayers.removeAtIndex(otherPlayers.indexOf(playing)!)
    for clue in initialClues {
      try playing.update(clue, state: .Have)
      for otherPlayer in otherPlayers {
        try otherPlayer.update(clue, state: .NotHave)
      }
    }
  }
  
  public func update(response: Response) throws {
    for player in players {
      try player.update(response)
    }
  }
}


