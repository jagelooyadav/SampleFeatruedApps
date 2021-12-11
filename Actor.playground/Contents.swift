import UIKit

var greeting = "Hello, playground"

protocol Ab {
    
}

actor ABC {
    var abc: String = ""
    
    func mutate(value: String) {
        self.abc = value
    }
}

actor ImageDownloader {
    var localCache: [String: String] = [:]
    func updateCache(data: String, forKey key: String) {
        self.localCache[key] = data
    }
}


func test1() async {
    sleep(1)
    print("test1")
}

func test2() async {
    print("test1")
    sleep(2)
}

Task {
    
}

func doSomething() async {
    await test1()
    _ = await test2()
}



