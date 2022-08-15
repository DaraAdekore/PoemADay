//
//  poemApi.swift
//  PoemADay
//
//  Created by Dara on 2022-08-11.
//

import Foundation

class poemApi{
    let baseUrl = "https://poetrydb.org/"
    var requestEndpoint:String = ""
    var request: URLRequest? = nil
    var localPoem:Poem?
    
    init(){
    }
    
    
    struct Poem: Codable {
        let title, author: String
        let lines: [String]
        let linecount: String
    }

}
