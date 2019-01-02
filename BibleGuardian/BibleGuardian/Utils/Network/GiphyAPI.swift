//
//  GiphyAPI.swift
//  SwiftFlashKeyboard
//
//  Created by Avazu Holding on 2018/11/20.
//  Copyright © 2018 Avazu Holding. All rights reserved.
//

import Foundation
import Moya

let GiphyProvider = MoyaProvider<GiphyAPI>()

public enum GiphyAPI {
	case search(q: String,limit: NSInteger,offset: NSInteger,rating: String?,lang: String)
	case trending(limit: NSInteger,offset: NSInteger,rating: String?)
	
}

extension GiphyAPI:TargetType {
	
	public var baseURL: URL {
		
		return URL(string: "https://api.giphy.com")!
	}
	
	public var path: String {
		switch self {
		
		case .search(q: _, limit: _, offset: _, rating: _, lang: _):
				return "/v1/gifs/search"
			
		case .trending(limit: _, offset: _, rating: _):
				return "/v1/gifs/trending"
		}
	}
	
	public var method: Moya.Method {
		switch self {
		case .search(q: _, limit: _, offset: _, rating: _, lang: _):
			return .get
			
		case .trending(limit: _, offset: _, rating: _):
			return .get
		}
	}
	
	public var sampleData: Data {
		return "{}".data(using: String.Encoding.utf8)!
	}
	
	public var task: Task {
		
		
		switch self {
	
		case .trending(let limit, let offset, let rating):
			var params:[String: Any] = [:]
			
			params["api_key"] = "0oxzRcpUzEISx6K0XxHO9seUNu3ApRSX"
			params["limit"] = limit
			params["offset"] = offset
			if rating != nil {
				params["rating"] = rating
			}
			
			
//			let jsonData = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: 0))

			return .requestParameters(parameters: params, encoding: URLEncoding.default)
	
		case .search(let q, let limit, let offset, let rating, let lang):
			var params:[String: Any] = [:]
			
			params["api_key"] = "0oxzRcpUzEISx6K0XxHO9seUNu3ApRSX"
			params["limit"] = limit
			params["offset"] = offset
			params["rating"] = rating
			params["lang"] = lang
//			let jsonData = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: 0))
			
			return .requestParameters(parameters: params, encoding: URLEncoding.default)
		}
	}
	public var headers: [String : String]? {
		return nil
	}
}
	
struct TrendingStruct: Codable {
	let meta: GiphyMetaStruct?
	let data: [GiphyGifStruct]?
	let pagination: GiphyPaginationStruct?
}
struct GiphyMetaStruct: Codable {
	let status: Int?
	let msg: String?
	let response_id: String?
}
struct GiphyPaginationStruct: Codable {
	let total_count: Int?
	let count: Int?
	let offset: Int?
}
struct GiphyGifStruct: Codable {
	let is_sticker: Bool?
	let slug: String?
	let source: String?
	let title: String?
	let url: String?
//	let _score: Int?
	let images: GiphyImagesStruct?
//	let bitly_gif_url: String?
	let trending_datetime: String?
	let source_tld: String?
	let type: String?
//	let analytics:
	let id: String?
//	let user:
	let content_url: String?
	let bitly_url: String?
//	let source_post_url: String?
	let import_datetime: String?
	let embed_url: String?
	let rating: String?
	let username: String?
}
struct GiphyImagesStruct: Codable, Equatable {
    
    static func == (lhs: GiphyImagesStruct, rhs: GiphyImagesStruct) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
	let fixedWidthSmall: GiphyGifInfoStruct?
	let fixedHeightSmall: GiphyGifInfoStruct?
	let fixedWidthSmallStill: GiphyGifStillInfoStruct?
	let fixedHeightSmallStill: GiphyGifStillInfoStruct?
	let fixedWidth: GiphyGifInfoStruct?
	let fixedWidthStill: GiphyGifStillInfoStruct?
	let fixedHeight: GiphyGifInfoStruct?
	let fixedHeightStill: GiphyGifStillInfoStruct?
	let fixedHeightDownsampled: GiphyGifDownsampledStruct?
	let fixedWidthDownsampled: GiphyGifDownsampledStruct?
	
	enum CodingKeys: String, CodingKey {
        case id = "id"
		case fixedWidthSmall = "fixed_width_small"
		case fixedHeightSmall = "fixed_height_small"
		case fixedWidthSmallStill = "fixed_width_small_still"
		case fixedHeightSmallStill = "fixed_height_small_still"
		case fixedWidth = "fixed_width"
		case fixedWidthStill = "fixed_width_still"
		case fixedHeight = "fixed_Height"
		case fixedHeightStill = "fixed_height_still"
		case fixedHeightDownsampled = "fixed_height_downsampled"
		case fixedWidthDownsampled = "fixed_width_downsampled"
	}
	var defaultFixedWidth: GiphyGifInfoStruct? {
		return self.fixedWidth
	}
	var defaultFixedHeight: GiphyGifInfoStruct? {
		return self.fixedWidth
	}
	var isLiked: Bool = false
}
struct GiphyGifInfoStruct: Codable {
	let height :Int?
	let mp4_size: Int?
	let width: Int?
	let size: Int?
	let mp4: String?
	let webp: String?
	let webp_size: String?
	let url: String?
}
struct GiphyGifStillInfoStruct: Codable {
	let url: String?
	let width: Int?
	let height: Int?
	let size: Int?
}
struct GiphyGifDownsampledStruct: Codable {
	let size: Int?
	let webp: String?
	let webp_size: Int?
	let url: String?
	let width: Int?
	let height: Int?
}
