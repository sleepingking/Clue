import Foundation
import UIKit

let labelWidth = 150.0, labelHeight = 50.0, columnWidth = 50.0, tableHeight = labelHeight * Double(Clue.allValues.count), headerHeight = 20.0

extension Player {
  public func customPlaygroundView() -> UIView {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: tableHeight))
    view.backgroundColor = UIColor.whiteColor()
    view.layer.borderColor = UIColor.blueColor().CGColor
    view.layer.borderWidth = 2.0
    
    var labelYPoz = 0.0
    for clue in Clue.allValues {
      let label = UILabel(frame: CGRect(x: 0.0, y: labelYPoz, width: 50, height: labelHeight))
      label.text = states[clue]?.description
      label.textAlignment = .Center
      label.sizeToFit()
      
      view.addSubview(label)
      
      labelYPoz += labelHeight
    }
    
    return view
  }
}

extension Board: CustomPlaygroundQuickLookable {
  public func customPlaygroundQuickLook() -> PlaygroundQuickLook {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: columnWidth * Double(self.players.count) + labelWidth, height: tableHeight + headerHeight))
    
    var xPoz = labelWidth
    
    // Player names
    for player in players {
      let label = UILabel(frame: CGRect(x: xPoz, y: 0.0, width: columnWidth, height: headerHeight))
      label.text = player.name
      label.sizeToFit()
      
      view.addSubview(label)
      
      xPoz += columnWidth
    }
    
    // Labels
    var labelYPoz = headerHeight
    for clue in Clue.allValues {
      let label = UILabel(frame: CGRect(x: 0.0, y: labelYPoz, width: labelYPoz, height: labelHeight))
      label.text = clue.description
      label.sizeToFit()
      
      view.addSubview(label)
      
      labelYPoz += labelHeight
    }
    
    xPoz = labelWidth
    
    for player in self.players {
      let playerView = player.customPlaygroundView()
      var frame = playerView.frame
      frame.origin.x = CGFloat(xPoz)
      frame.origin.y = CGFloat(headerHeight)
      playerView.frame = frame
      
      view.addSubview(playerView)
      xPoz += (columnWidth - 1.0)
    }
    
    return PlaygroundQuickLook(reflecting: view)
  }
}
