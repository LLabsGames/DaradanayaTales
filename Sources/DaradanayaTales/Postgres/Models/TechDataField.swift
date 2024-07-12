//
//  TechDataField.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

import FluentKit

final class TechData: Fields, @unchecked Sendable {
    @OptionalField(key: "referralFrom")
    var referralFrom: Int64?

    @Field(key: "referrals")
    var referrals: [Int64]

    init() { }

    init(referralFrom: Int64?, referrals: [Int64] = []) {
        self.referralFrom = referralFrom
        self.referrals = referrals
    }
}
