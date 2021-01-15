/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Moya


/**
 * switch case api 就可以提供不同的配置信息在一个 Marvel 中
 * This is a general best practice, since your target might easily evolve and add more endpoints
 * Target + EndPoint
 * Any new endpoint will require its own values for the different target properties.
 */
public enum Marvel {
  // 1
  static private let publicKey = "aea08f4dcf47773c52fc1c572658ea8d"
  static private let privateKey = "d43268ed74b2af885f671685fc6bc36658e93d95"
  
  // 2 定义将要使用的 api 接口 endpoint
  case comics
}

// 遵守 TargetType 协议
extension Marvel: TargetType {
  // 1
  public var baseURL: URL {
    return URL(string: "https://gateway.marvel.com/v1/public")!
  }
  
  // 2
  public var path: String {
    switch self {
    case .comics: return "/comics"
    }
  }
  
  // 3
  public var method: Moya.Method {
    switch self {
    case .comics: return .get
    }
  }
  
  // 4
  public var sampleData: Data {
    return Data()
  }
  
  // 5
  public var task: Task {
    let ts = "\(Date().timeIntervalSince1970)"
    // 1
    let hash = (ts + Marvel.privateKey + Marvel.publicKey).md5
    
    // 2
    let authParams = ["apikey": Marvel.publicKey, "ts": ts, "hash": hash]
    
    switch self {
    case .comics:
      // 3
      return .requestParameters(
        parameters: [
          "format": "comic",
          "formatType": "comic",
          "orderBy": "-onsaleDate",
          "dateDescriptor": "lastWeek",
          "limit": 50] + authParams,
        encoding: URLEncoding.default)
    }
  }
  
  // 6
  public var headers: [String: String]? {
    return ["Content-Type": "application/json"]
  }
  
  // 7
  public var validationType: ValidationType {
    return .successCodes
  }
}
