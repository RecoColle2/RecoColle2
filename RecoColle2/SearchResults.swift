//
//  SearchResults.swift
//  RecoColle2
//
//  Created by 丸田信一 on 2024/07/07.
//

class SearchResults: Decodable {
    let href:Href
    let total:Total
    let limit:Limit
    let offset:Offset
}
