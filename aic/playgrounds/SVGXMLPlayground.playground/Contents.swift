//: Playground - noun: a place where people can play

import UIKit
import SWXMLHash

let svgURL = NSBundle.mainBundle().URLForResource("SVGTest", withExtension: "svg")
let content = try String(contentsOfURL: svgURL!, encoding: NSUTF8StringEncoding)

var xml = SWXMLHash.parse(content)
var map = xml[0]["svg"]
print(xml)


// one root element
let count = xml["svg"].all.count

var amenities:XMLIndexer?
for child in map.children {
    do {
        try child.withAttr("id", "Amenities")
        amenities = child
        break
    } catch {
        amenities = nil
    }
}

for child in amenities!.children {
    print(child)
    print(child.element!.attributes["cx"]!)
}

//for child in root! {
//    print(child)
//    if child.element!.attributes["id"] == "Amenities" {
//        print("hello")
//    }
//}
//
//xml["svg"]["g"]
////["amenities"].children
////[0].element?.attributes["id"]
//xml["svg"].element?.attributes["x"]
//xml["svg"].element?.attributes["y"]
//
//xml["svg"].children[0]


