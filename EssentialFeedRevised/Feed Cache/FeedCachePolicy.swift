//
//  FeedCachePolicy.swift
//  EssentialFeedRevised
//
//  Created by 13401027 on 17/06/22.
//

import Foundation

internal final class FeedCachePolicy {
    private init() {}
    private static let calender = Calendar(identifier: .gregorian)
    
    /*
     private let currentDate: () -> Date
     
     init(currentDate: @escaping () -> Date) {
     self.currentDate = currentDate
     } */
    
    /*
     Currently the current date is impure as It is not deterministic and it may change.
     To make it pure fucntion we can pass data instead of fucntion and our method become deterministic.
     
     Now data is a struct and In this case it is Immutable.
     */
    
    /*
     Both the test method and controller type are abstracted from policy
     We can easily change this policy as neeeded with out breaking the test and controller.
     We can even load this policy from a configuration file.
     */
    
    /*
     Seperate application specifc details from bussiness rules.
     Controller are not business models.
     They communicate with bussiness model to solve application specific bussiness rules.
     By separating bussiness models, controllers and frameworks is key to achieve modularity, freedom.
     */
    private static var maxCacheAgeInDays: Int {
        return 3
    }
    
    internal static func validate(_ timestamp: Date, against data: Date) -> Bool {
        guard let maxCacheAge = FeedCachePolicy.calender.date(byAdding: .day, value: FeedCachePolicy.maxCacheAgeInDays, to: timestamp) else { return false }
        return data < maxCacheAge
    }
}
