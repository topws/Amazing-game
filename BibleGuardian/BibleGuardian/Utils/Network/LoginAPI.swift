//
//  LoginAPI.swift
//  SwiftFlashKeyboard
//
//  Created by AVAZU on 2018/11/9.
//  Copyright © 2018 Avazu Holding. All rights reserved.
//

import Foundation
import Moya

let LoginAPIProvider = MoyaProvider<LoginAPI>()

public enum LoginAPI {
    case login(String)
    case register(String)
}

extension LoginAPI:TargetType {
    public var baseURL: URL {
        
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .login(_):
            return "/v1/passport/login"
        case .register(_):
            return "/v1/passport/register"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        var params:[String: Any] = [:]
        switch self {
        case .login(_):
            params["device_id"] = AppInfo.init().uuid
            params["account"] = AppInfo.init().uuid
            params["password"] = "88888888"
            params["app_id"] = "60"
            params["prd_id"] = "8"
            params["type"] = "0"
            params["version"] = AppInfo.init().appVersion
            params["extra"] = ["mark" : "2", "nick" : "haha"]
            params["package-name"] = AppInfo.init().bundleID

            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        case .register(_):
            params["device_id"] = AppInfo.init().uuid
            params["account"] = AppInfo.init().uuid
            params["password"] = "88888888"
            params["app_id"] = "60"
            params["prd_id"] = "8"
            params["type"] = "0"
            params["package-name"] = AppInfo.init().bundleID
            params["token"] = ""

            let data:Data =  Data.init(encryptionParams: params)
            return .requestData(data)
        }
    }
    
    public var headers: [String : String]? {
        return ["package-name": AppInfo.init().bundleID]
    }
}

struct RegisterModel:Codable {
    
    var msg:String?
    var data:RegisterDataModel?
    var code:Int
}

struct RegisterDataModel:Codable {
    
    var id:String?
    var token:String?
    var uid:String?
    var type:String?
    var device_id:String?
    var third_id:String?
    var create_time:String?
    var update_time:String?

}

struct LoginModel:Codable {
    
    var msg:String?
    var data:LoginDataModel?
    var code:Int
}

struct LoginDataModel:Codable {
    
    var id:String?
    var token:String?
    var uid:String?
    var type:String?
    var device_id:String?
    var third_id:String?
    var create_time:String?
    var update_time:String?
    var account_status:String?
    var expire_time:String?

}

//let publicParamEndpointClosure = { (target: LoginAPI) -> Endpoint in
//    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
//    let endpoint = Endpoint<AccountService>(url: url, sampleResponseClosure: { .networkResponse(200, target.sampleData) }, method: target.method, parameters: target.parameters, parameterEncoding: target.parameterEncoding)
//    return endpoint.adding(newHTTPHeaderFields: ["x-platform" : "iOS", "x-interface-version" : "1.0"])
//}
