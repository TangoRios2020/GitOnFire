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
import UIKit
import Moya

// 定义通向 imgur 的路径: 就先需要一个 target. 使用一个 target 初始化一个 provider
// 就是一个 APIRouter
public enum Imgur {
  // 1
  static private let clientId = "4242150567c7d52"

  // 2 定义一个通向 imger 这个资源点的所有 api, 以后所有与 imgur 相关的 api 都在这里.
  case upload(UIImage)
  case delete(String)
}

extension Imgur: TargetType {
  // 1
  public var baseURL: URL {
    return URL(string: "https://api.imgur.com/3")!
  }

  // 2
  public var path: String {
    switch self {
    case .upload: return "/image"
    case .delete(let deletehash): return "/image/\(deletehash)"
    }
  }

  // 3 moya 提供封装的几中 method 方法
  public var method: Moya.Method {
    switch self {
    case .upload: return .post
    case .delete: return .delete
    }
  }

  // 4 mock data
  public var sampleData: Data {
    return Data()
  }

  // 5
  /**
   * task is probably the most important property of the bunch. You’re expected to return a Task enumeration case for every endpoint you want to use.
   * There are many options for tasks you could use, e.g., plain request, data request, parameters request, upload request and many more.
   * This is currently marked as “to do” since you’ll deal with this in the next section.
   */
  public var task: Task {
    switch self {
    case .upload(let image):
      let imageData = image.jpegData(compressionQuality: 1.0)!

      return .uploadMultipart([MultipartFormData(provider: .data(imageData),
                                                 name: "image",
                                                 fileName: "card.jpg",
                                                 mimeType: "image/jpg")])
    case .delete:
      return .requestPlain
    }
  }

  // 6
  public var headers: [String: String]? {
    return [
      "Authorization": "Client-ID \(Imgur.clientId)",
      "Content-Type": "application/json"
    ]
  }

  // 7
  public var validationType: ValidationType {
    return .successCodes
  }
}
