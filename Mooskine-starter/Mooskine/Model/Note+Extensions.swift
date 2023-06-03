//
//  Note+Extensions.swift
//  Mooskine
//
//  Created by Damaris Muhia on 01/06/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import CoreData
extension Note{
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
