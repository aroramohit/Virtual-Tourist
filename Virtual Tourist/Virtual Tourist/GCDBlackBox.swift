//
//  GCDBlackBox.swift
//  Virtual Tourist
//
//  Created by Mohit Arora on 18/02/18.
//  Copyright © 2018 soprateria. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

