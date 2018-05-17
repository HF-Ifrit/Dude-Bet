//
//  PariMutuelBet.swift
//  DudeBet
//
//  Created by Daniel Miles on 5/3/18.
//  Copyright © 2018 Daniel Miles. All rights reserved.
//

import UIKit

class PariMutuelBet: NSObject {
    
    static func computeWinnings (allBetters: [Entrant], winningBetters : [Entrant]) -> [Entrant] {
        var total = 0
        var wTotal = 0
        var returnWinnings = winningBetters
        for bet in allBetters {
            total += Int(bet.betAmount)
        }
        for bet in winningBetters {
            wTotal += Int(bet.betAmount)
        }
        for index in 0...(winningBetters.count - 1) {
            returnWinnings[index].betAmount = Int32(total * Int(returnWinnings[index].betAmount) / wTotal)
        }
        return returnWinnings
    }
}
