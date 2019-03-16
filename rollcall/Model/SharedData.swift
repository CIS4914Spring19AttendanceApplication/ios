//
//  SharedData.swift
//  rollcall
//
//  Created by Samantha Eboli on 3/14/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import Foundation

class Data{
    static let sharedInstance = Data()
    var accessToken : String?
    var userData = [String]()
}
