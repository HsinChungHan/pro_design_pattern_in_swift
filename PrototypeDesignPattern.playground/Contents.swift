import UIKit

class Appointment: NSObject {
  private(set) var name: String
  private(set) var day: String
  private(set) var place: String
  
  init(name: String, day: String, place: String) {
    self.name = name
    self.day = day
    self.place = place
  }
  
  fileprivate func set(name: String, day: String, place: String) {
    self.name = name
    self.day = day
    self.place = place
  }
  
  fileprivate func printDetails(label: String) {
    print("\(label) with \(name) on \(day) at \(place)")
  }
}

extension Appointment: NSCopying {
  func copy(with zone: NSZone? = nil) -> Any {
    return Appointment(name: self.name, day: self.day, place: self.place)
  }
}

//利用 NSCopying 可以複製出 bobMeeting，且記憶體位置會不一樣
var bobMeeting = Appointment(name: "Bob", day: "Mon", place: "Bob's pub")
var copyBobMeeting = bobMeeting
var edwardMeeting = bobMeeting.copy() as! Appointment

print(bobMeeting)
print(edwardMeeting)
print(copyBobMeeting)
copyBobMeeting.set(name: "CopyBob", day: "Copy Mon", place: "Copy Bob's pub")
bobMeeting.printDetails(label: "Bob")
bobMeeting.printDetails(label: "CopyBob")
print(copyBobMeeting)

edwardMeeting.set(name: "Edward", day: "Tue", place: "Edward's home")



//深複製與淺複製的比較
//淺複製 shallow copy
class ShallowLocation {
  
  var name: String
  var address: String
  
  init(name: String, address: String) {
    self.name = name
    self.address = address
  }
}

class ShollowAppointment: NSObject {
  private(set) var name: String
  private(set) var day: String
  private(set) var place: ShallowLocation
  
  init(name: String, day: String, place: ShallowLocation) {
    self.name = name
    self.day = day
    self.place = place
  }
  
  fileprivate func set(name: String, day: String, placeName: String, placeAddress: String) {
    self.name = name
    self.day = day
    self.place.name = placeName
    self.place.address = placeAddress
  }
  
  fileprivate func printDetails(label: String) {
    print("\(label) with \(name) on \(day) at \(place.name)")
  }
}

extension ShollowAppointment: NSCopying {
  
  func copy(with zone: NSZone? = nil) -> Any {
    return ShollowAppointment(name: self.name, day: self.day, place: self.place)
  }
}

let annieMeeting = ShollowAppointment(name: "Annie", day: "Mon", place: ShallowLocation(name: "Annie's bar", address: "123 Main st"))
let hsinMeeting = annieMeeting.copy() as! ShollowAppointment

//hsinMeeting.set(name: "Hsin", day: "Tue", place: Location(name: "Hsin's bar", address: "321 Hsin st"))
//淺複製，因為都 reference 到同個 location 實體 p94
hsinMeeting.set(name: "Hsin", day: "Tue", placeName: "Hsin's bar", placeAddress: "321 Hsin st")
annieMeeting.printDetails(label: "Annie")
hsinMeeting.printDetails(label: "hsin")

//實作深複製 deepCopy

class DeepLocation {
  
  var name: String
  var address: String
  
  init(name: String, address: String) {
    self.name = name
    self.address = address
  }
}

extension DeepLocation: NSCopying {
  func copy(with zone: NSZone? = nil) -> Any {
    return DeepLocation(name: self.name, address: self.address)
  }
}

class DeepAppointment: NSObject {
  
  private(set) var name: String
  private(set) var day: String
  private(set) var place: DeepLocation
  
  init(name: String, day: String, place: DeepLocation) {
    self.name = name
    self.day = day
    self.place = place
  }
  
  fileprivate func set(name: String, day: String, placeName: String, placeAddress: String) {
    self.name = name
    self.day = day
    self.place.name = placeName
    self.place.address = placeAddress
  }
  
  fileprivate func printDetails(label: String) {
    print("\(label) with \(name) on \(day) at \(place.name)")
  }
}

extension DeepAppointment: NSCopying {
  
  func copy(with zone: NSZone? = nil) -> Any {
    return DeepAppointment(name: self.name, day: self.day, place: self.place.copy() as! DeepLocation)
  }
}

let annieDeepMeeting = DeepAppointment(name: "Annie", day: "Mon", place: DeepLocation(name: "Annie's bar", address: "123 Main st"))
let hsinDeepMeeting = annieDeepMeeting.copy() as! DeepAppointment

//hsinMeeting.set(name: "Hsin", day: "Tue", place: Location(name: "Hsin's bar", address: "321 Hsin st"))
//深複製，因為 reference 到不同的 location 實體 p96
hsinDeepMeeting.set(name: "Hsin", day: "Tue", placeName: "Hsin's bar", placeAddress: "321 Hsin st")
annieDeepMeeting.printDetails(label: "Annie")
hsinDeepMeeting.printDetails(label: "hsin")

/*p96
 若想要做深複製，所有的 class 型別，都必須 conform NSCopying
 使用時機：
 	1.物件初始化的成本
  2.儲存複製品的記憶體成本
  3.複製品物件的使用方式(思考所有物件是否有共用的項目，有的部分就用淺複製，沒有的部分用深複製)
*/

//深複製陣列
class Person: NSObject {
  
  var name: String
  var country: String
  
  init(name: String, country: String) {
    self.name = name
    self.country = country
  }
}

extension Person: NSCopying {
  func copy(with zone: NSZone? = nil) -> Any {
    return Person(name: self.name, country: self.country)
  }
}

var people = [
	Person(name: "Hsin", country: "Taiwan"),
  Person(name: "Osmara", country: "Mexico")
]

func deepCopy(data: [Any]) -> [Any] {
  return data.map { (item) -> Any in
    if (item is NSCopying) && (item is NSObject) {
      return (item as! NSObject).copy()
    }else {
      return item
    }
  }
}

var otherPeople = deepCopy(data: people) as! [Person]

people[0].country = "UK"
print("Country: \(otherPeople[0].country)")

/*
 使用 prototype pattern 的好處
 1. 避免昂貴的初始成本
 2. 複製物件不用知道初始化的參數(這樣若是初始化的參數需要修改時，不用全部都修改)
*/

class Message {
  
  var to: String
  var subject: String
  init(to: String, subject: String) {
    self.to = to
    self.subject = subject
  }
}

class MessageLogger {
  
  var messages: [Message] = []
  
  func logMessage(message: Message) {
    messages.append(message)
  }
  
  func processMessages(callBack: (Message) -> Void) {
    for message in messages {
      callBack(message)
    }
  }
  
}

//同時兩個物件存取到同一個 reference
/*out put
 Message - to Annie for subjec For dinner!
 Message - to Annie for subjec For dinner!
 原本預計為：
 Message - to Hsin for subjec Just for test!
 Message - to Annie for subjec For dinner!
 */
var logger = MessageLogger()

var message = Message(to: "Hsin", subject: "Just for test")
logger.logMessage(message: message)

message.to = "Annie"
message.subject = "For dinner!"
logger.logMessage(message: message)

logger.processMessages { (message) in
  print("Message - to \(message.to) for subjec \(message.subject)")
}

//改善方式一:每次都 append 一個新物件

/*
 缺點：
	因為每次都會重新 init 一個新物件，換句話說，我會在 init 新物件的時候，就決定了物件的 type，如果想要像範例一樣，有一個繼承 Message 的 DetailedMessage，此時我就會被之前的 type 侷限住，無法新增一個 DetailedMessage 加入了
 output:
 Message - to Hsin for subjec Just for test
 Message - to Annie for subjec Just for dinner
 Message - to Katy for subjec Just for lunch
 
 預想:
 Message - to Hsin for subjec Just for test
 Message - to Annie for subjec Just for dinner
 Message - to Katy for subjec Just for lunch, from Hsin
 */
class MyMessage {
  
  var to: String
  var subject: String
  init(to: String, subject: String) {
    self.to = to
    self.subject = subject
  }
}

class DetailedMessage: MyMessage {
  var from: String
  
  init(to: String, subject: String, from: String) {
    self.from = from
    super.init(to: to, subject: subject)
  }
}

class MyMessageLogger {
  
  var messages: [MyMessage] = []
  
  //每次都 append 一個新物件
  func logMessage(message: MyMessage) {
    messages.append(MyMessage(to: message.to, subject: message.subject))
  }
  
  func processMessages(callBack: (MyMessage) -> Void) {
    for message in messages {
      callBack(message)
    }
  }
}

var myMessageLogger = MyMessageLogger()
var myMessage = MyMessage(to: "Hsin", subject: "Just for test")
myMessageLogger.logMessage(message: myMessage)

myMessage.to = "Annie"
myMessage.subject = "Just for dinner"
myMessageLogger.logMessage(message: myMessage)

myMessageLogger.logMessage(message: DetailedMessage(to: "Katy", subject: "Just for lunch", from: "Hsin"))

myMessageLogger.processMessages { (message) in
  if let detailedMessage = message as? DetailedMessage {
    print("Message - to \(message.to) for subjec \(message.subject), from \(detailedMessage.from)")
  }else {
    print("Message - to \(message.to) for subjec \(message.subject)")
  }
}



