import UIKit

/*
 1. 讀者於書本未借出時，可以立即借閱
 2. 每一本書同一時間只可以借給一個讀者
 3.
 */
class Book {
  let author: String
  let title: String
  let stockNumber: Int
  var reader: String?
  var checkoutCount = 0
  
  init(author: String, title: String, stockNumber: Int) {
    self.author = author
    self.title = title
    self.stockNumber = stockNumber
  }
}

class Pool<T> {
	private var elements = [T]()
  //這個 Queue 的目的是確保再多執行緒的環境下，不會有多個執行緒同時做 getFromPool() 或 returnInPool(item: T)
  private let arrayQ = DispatchQueue(label: "arrayQ") //預設為 Serial Queue
  
  /*
   使用 semaphore 的狀況是為了避免類似同時性的例子
   當 threadA 執行 getFromPool() 時，發現 elements.count > 0 便會排隊，準備在下一個 time session 的時候拿取物件。
   但同時也有 threadB 執行 getFromPool()，發現 elements.count > 0，便也跟著排隊。
   在下一個 time session 時，threadA 拿了，此時 elements 已經沒了。
   在下下一個 time session 時，threadB 試圖拿取 elements 中的元素，罰線已經沒有元素可拿，就 crash 了
   */
  private let semaphore: DispatchSemaphore
  
  
  init(items:[T]) {
    elements.reserveCapacity(items.count) //預先根據 items 的大小給予 array 容量
    for item in items {
      elements.append(item)
    }
    self.semaphore = DispatchSemaphore(value: items.count)
  }
  
  func getFromPool() -> T? {
    var result: T?
    if elements.count > 0 {
      //計數器每 wait 一次就會減 1，直到 0 便會阻斷
      if semaphore.wait(timeout: .distantFuture) == .success {
        //借出要排隊
        arrayQ.sync {
          result = elements.remove(at: 0)
        }
      }
    }
    return result
  }
  
  func returnInPool(item: T) {
    //還的時候不用排隊
    arrayQ.async {[weak self] in
      self?.elements.append(item)
      //計數器每 wait 一次就會加 1
      self?.semaphore.signal()
    }
  }
}
