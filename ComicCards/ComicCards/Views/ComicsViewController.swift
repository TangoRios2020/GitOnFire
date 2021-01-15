/// Copyright (c) 2018 Razeware LLC
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

class ComicsViewController: UIViewController {
  // MARK: - View State
  private var state: State = .loading {
    // 属性监测器
    didSet {
      switch state {
      case .ready:
        viewMessage.isHidden = true
        tblComics.isHidden = false
        tblComics.reloadData()
      case .loading:
        tblComics.isHidden = true
        viewMessage.isHidden = false
        lblMessage.text = "Getting comics ..."
        imgMeessage.image = #imageLiteral(resourceName: "Loading")
      case .error:
        tblComics.isHidden = true
        viewMessage.isHidden = false
        lblMessage.text = """
                            Something went wrong!
                            Try again later.
                          """
        imgMeessage.image = #imageLiteral(resourceName: "Error")
      }
    }
  }

  // MARK: - Outlets
  @IBOutlet weak private var tblComics: UITableView!
  @IBOutlet weak private var viewMessage: UIView!
  @IBOutlet weak private var lblMessage: UILabel!
  @IBOutlet weak private var imgMeessage: UIImageView!

  // 要向 Marvel 这个 target 部分发送请求, 需要一个对应的 Provider 来做事情
  let provider = MoyaProvider<Marvel>()

  override func viewDidLoad() {
    super.viewDidLoad()

    state = .loading
    
    // 2
    provider.request(.comics) { [weak self] result in
      guard let self = self else { return }

      // 3
      switch result {
      case .success(let response):
        do {
          // 4
//          print(try response.mapJSON())
          // 此处进行赋值, 设置当前的状态为 .ready, 后续使用时, 可以通过这个 .ready 获取关联的值 comics 数组.
          self.state = .ready(try response.map(MarvelResponse<Comic>.self).data.results)

        } catch {
          self.state = .error
        }
      case .failure:
        // 5
        self.state = .error
      }
    }
  }
}

extension ComicsViewController {
  // 在状态的枚举中增加关联值的使用.
  // 这里将 Comics 数组属性藏在了 state 中, 自己少了一个属性值. 妙啊
  enum State {
    case loading
    case ready([Comic])
    case error
  }
}

// MARK: - UITableView Delegate & Data Source
extension ComicsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // 使用到自定义 cell, 需要进行强制转换
    let cell = tableView.dequeueReusableCell(withIdentifier: ComicCell.reuseIdentifier, for: indexPath) as? ComicCell ?? ComicCell()

    // 这里是 如果 state 是 ready 话
    // Swift 中的枚举 只是做一种比较, 几种枚举值作为状态被比较, 枚举中的关联值 需要先放进去, 然后才有用
    guard case .ready(let items) = state else { return cell }

    cell.configureWith(items[indexPath.item])

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard case .ready(let items) = state else { return 0 }

    return items.count
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    // 当 items 不足时
    guard case .ready(let items) = state else { return }

    let comicVC = CardViewController.instantiate(comic: items[indexPath.item])
    navigationController?.pushViewController(comicVC, animated: true)
  }
}

