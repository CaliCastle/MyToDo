//
//  Note.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/6/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

extension Note {
    
    // MARK: - Dates
    
    var updatedAtAsDate: Date {
        guard let updatedAt = updatedAt else { return Date() }
        
        return Date(timeIntervalSince1970: updatedAt.timeIntervalSince1970)
    }
    
    var createdAtAsDate: Date {
        guard let createdAt = createdAt else { return Date() }
        
        return Date(timeIntervalSince1970: createdAt.timeIntervalSince1970)
    }
    
    // MARK: - Tags
    
    var alphabetizedTags: [Tag]? {
        guard let tags = tags as? Set<Tag> else { return nil }
        
        return tags.sorted(by: {
            guard let tag0 = $0.name else { return true }
            guard let tag1 = $1.name else { return true }
            
            return tag0 < tag1
        })
    }
    
    var alphabetizedTagsAsString: String? {
        guard let tags = alphabetizedTags, tags.count > 0 else { return nil }
        
        let names = tags.flatMap { $0.name }
        
        return names.joined(separator: ", ")
    }
    
}
