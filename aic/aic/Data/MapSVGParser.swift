/*
 Abstract:
 Parses a custom SVG file that contains floor information,
 amenities and locations.
 
 This is used for adding these elements and positioning them as annotations on the map
*/

import UIKit
import SWXMLHash

protocol SVGAnnotationProtocol {
    var positionInSVG:CGPoint { get }
}
// Models for parsed Map data
struct SVGImage : SVGAnnotationProtocol {
    var positionInSVG: CGPoint
    var imageName: String
}
struct SVGAmenity : SVGAnnotationProtocol {
    var positionInSVG:CGPoint
    var type:MapAmenityAnnotationType
}

struct SVGDepartment : SVGAnnotationProtocol {
    var positionInSVG: CGPoint
    var id: String
}

struct SVGTextLabel : SVGAnnotationProtocol {
    var positionInSVG:CGPoint
    var text:String
}

struct SVGFloor {
    let number:Int
    let amenities:[SVGAmenity]
    let departments:[SVGDepartment]
    let spaces:[SVGTextLabel]
}


class MapSVGParser {
    // XML ID/Attribute names
    private let floorIDPrefix = "Floor"
    private let lionsID = "Lions"
    private let landmarksID = "Landmarks"
    private let gardensID = "Gardens"
    private let amenitiesID = "Amenities"
    private let departmentsID = "Departments"
    private let spacesID = "Spaces"
    
    private let textFont = UIFont.aicSystemTextFont()
    
    var svgDimensions:CGRect? = nil
    
    // Parsed map data
    private(set) var lions:[SVGImage] = []
    private(set) var landmarks:[SVGTextLabel] = []
    private(set) var gardens:[SVGTextLabel] = []
    private(set) var floors:[SVGFloor] = []
    
    init(svgFile:URL, totalFloors:Int) {
        // Load in the file as a string
        do {
            let svgStringContent = try String(contentsOf: svgFile, encoding: String.Encoding.utf8)
            parse(svgString: svgStringContent, totalFloors: totalFloors)
        }
        
        catch {
            print("Could not load SVG Map File from \(svgFile)")
            return
        }
    }
    
    private func parse(svgString:String, totalFloors:Int) {
        // Get the XML
        let xml = SWXMLHash.parse(svgString)
        let root = xml[0]["svg"]
        guard let rootElement = root.element else {
            print("Could not get root element")
            return
        }
        
        // Get the size of the SVG so that we can inverse the Y Coords later on
        // This is from the svg "Viewbox" attribute
        guard let viewBox = rootElement.allAttributes["viewBox"] else {
            print("Could not get viewbox attribute from root of SVG file.")
            return
        }
        
        guard let dimensions = getDimensions(fromSVGViewboxString: viewBox.text) else {
            print("Could not get dimensions for SVG Viewbox")
            return
        }
        
        svgDimensions = dimensions
        
        // Lions
        do {
            let lionsGroup = try root["g"].withAttr("id", lionsID)
            self.lions = parseLionsForGroup(lionsGroup)
        }
        catch {
            print("Could not find element for lions.")
        }
        
        // Landmarks
        do {
            let landmarksGroup = try root["g"].withAttr("id", landmarksID)
            self.landmarks = parseTextLabels(forGroup: landmarksGroup)
        }
        catch {
            print("Could not find element for landmarks.")
        }
        
        // Gardens
        do {
            let gardensGroup = try root["g"].withAttr("id", gardensID)
            self.gardens = parseTextLabels(forGroup: gardensGroup)
        }
        catch {
            print("Could not find element for gardens.")
        }
        
        // Parse FLoors
        for floorNumber in 0..<totalFloors {
            do {
                let floorGroup = try root["g"].withAttr("id", floorIDPrefix + String(floorNumber))
                
                guard let departmentsGroup = getGroup(inGroup: floorGroup, forId: departmentsID) else {
                    print("Could not get departments for floor \(floorNumber)")
                    continue
                }
                
                guard let spacesGroup = getGroup(inGroup: floorGroup, forId: spacesID) else {
                    print("Could not get spaces for floor \(floorNumber)")
                    continue
                }
                
                let floor = SVGFloor(number: floorNumber,
                                     amenities: parseFloorAmenities(forFloor: floorGroup),
                                     departments: parseDepartments(forGroup: departmentsGroup),
                                     spaces: parseTextLabels(forGroup: spacesGroup)
                )
                
                floors.append(floor)
            }
            catch {
                print("Could not get element for floor number \(floorNumber)")
            }
        }
    }
    
    private func getGroup(inGroup group:XMLIndexer, forId id:String) -> XMLIndexer? {
        return group["g"].filter({ ($0.element!.allAttributes["id"]?.text.contains(id))! }).first
    }
    
    
    /**
    Parse the lions
    */
    private func parseLionsForGroup(_ group:XMLIndexer) -> [SVGImage] {
        var lions:[SVGImage] = []
        // Get the rect nodes
        let lionGroups = group.children.filter({
            $0.element?.name.contains("Lion") != nil
        })
        
        for child in lionGroups {
            do {
                let imageName = child.element!.allAttributes["id"]!.text
                let rect = try child["g"].byKey("rect")
                
                let position = getCenteredPosition(forSVGRectElement: rect.element)
                lions.append(SVGImage(positionInSVG: position, imageName: imageName))
            } catch {
                print("Could not get rect for lion.")
            }
            
        }
        
        return lions
    }
    
    /**
     Parse out the departmetns in a group
    */
    private func parseDepartments(forGroup group:XMLIndexer) -> [SVGDepartment] {
        var departments:[SVGDepartment] = []
        
        let departmentRects = group.children.filter({
            $0.element?.name == "rect"
        })
        
        for department in departmentRects {
            guard let id = department.element!.allAttributes["id"] else {
                print("Could not get ID for SVG Department")
                continue
            }
            
            let sharedID = getSharedSVGId(forString: id.text)
            let position = getCenteredPosition(forSVGRectElement: department.element)
            
            let svgDepartment = SVGDepartment(positionInSVG: position, id: sharedID)
            departments.append(svgDepartment)
        }
        
        
        return departments
    }
    
    /**
     Parse out the text boxes in a group
     */
    private func parseTextLabels(forGroup group:XMLIndexer) -> [SVGTextLabel] {
        var labels:[SVGTextLabel] = []
        
        // Filter out just the text nodes in case there is other garbage in there
        let filteredLabels = group.children.filter({
            $0.element?.name == "text"
        })
        
        for child in filteredLabels {
            let text = getText(forSVGTextIndexer: child)
            let position = getCenteredPosition(forSVGTextIndexer: child, text: text, fontSize: UIFont.aicMapSVGTextFont()!.pointSize)
            
            labels.append(SVGTextLabel(positionInSVG: position, text: text))
        }
        
        return labels
    }
    
    
    /**
     Go through a floor, find the Amenities group and pull out any layers matching
     the amenities that we support
    */
    private func parseFloorAmenities(forFloor floor:XMLIndexer) -> [SVGAmenity] {
        var parsedAmenities:[SVGAmenity] = []
        
        let amenityGroup = floor["g"].filter({ ($0.element!.allAttributes["id"]?.text.contains(amenitiesID))! })
        
        if amenityGroup.first != nil {
            // Filter out amenity groups with IDs
            let amenities = amenityGroup[0].children.filter({ $0.element?.allAttributes["id"] != nil})
            
            // Go through and try to pull out amenities
            for child in amenities {
                // Find the amenity annotation type
                let idString = getSharedSVGId(forString: child.element!.allAttributes["id"]!.text)
                guard let amenityType = MapAmenityAnnotationType(rawValue: idString) else {
                    print("Could not find corresponding amenity for SVG id: \(idString)")
                    continue
                }
                
                // Get the positioning rect
                do {
                    let rect = try child.byKey("rect")
                    let position = getCenteredPosition(forSVGRectElement: rect.element!)

                    parsedAmenities.append(SVGAmenity(positionInSVG: position, type: amenityType))
                } catch {
                    print("Could not get rect for amenity type \(idString) in floor \(floor)")
                }
            }
        }
        
        return parsedAmenities
    }
    
    
    // MARK: SVG Parsing Helpers
    /**
     This parses out our SVG doc's viewBox to give us
     a CGRect we can work with. The viewBox attribute is a string in format like "x y w h"
    */
    private func getDimensions(fromSVGViewboxString viewBox:String) -> CGRect? {
        let viewBoxElements = viewBox.components(separatedBy: CharacterSet(charactersIn: " "))
        var viewBoxElementsAsCGFloat:[CGFloat] = []
        
        for element in viewBoxElements {
            if let n = NumberFormatter().number(from: element) {
                viewBoxElementsAsCGFloat.append(CGFloat(n))
            }
        }
        
        if viewBoxElements.count == 4 {
            return CGRect(x: viewBoxElementsAsCGFloat[0], y: viewBoxElementsAsCGFloat[1], width: viewBoxElementsAsCGFloat[2], height: viewBoxElementsAsCGFloat[3])
        } else {
            return nil
        }
    }
    
    /**
     Given a SVG Rect element, find its position + size,
     figure out offset (we want the center position for annotations)
     and return as a point
     */
    private func getCenteredPosition(forSVGRectElement element:XMLElement?) -> CGPoint {
        guard let element = element , element.name == "rect" else {
            print("Element is not a rect.")
            return CGPoint()
        }
        
        // Get Position
        let x = CGFloat(Float(element.allAttributes["x"]!.text)!)
        let y = CGFloat(Float(element.allAttributes["y"]!.text)!)
        
        // Offset the y to switch to right hand coord system
        let offsetY = svgDimensions!.origin.y + svgDimensions!.height - CGFloat(y)
        
        // Get the width + height of the rect
        let width = CGFloat(Float(element.allAttributes["width"]!.text)!)
        let height  = CGFloat(Float(element.allAttributes["height"]!.text)!)
        
        let centerX = x + width/2.0
        let centerY = offsetY - height/2.0
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    /**
     Grab a text box from SVG, parse out the string value + add \n
     when we find a span
     */
    private func getText(forSVGTextIndexer textIndexer:XMLIndexer) -> String {
        var text = ""
        
        if textIndexer.children.count > 1 {
            text = getText(forSVGIndexerWithSpanTags: textIndexer)
        } else {
            text = textIndexer.element!.text!
        }
        
        return text
    }
    
    /**
     Get the origin from a SVG text node,
     then find it's center point based on the font and text
     */
    private func getCenteredPosition(forSVGTextIndexer textIndexer:XMLIndexer, text:String, fontSize:CGFloat) -> CGPoint {
        let transformText = textIndexer.element!.allAttributes["transform"]
        
        
        let transformComponents = transformText!.text.components(separatedBy: "(")[1]
            .components(separatedBy: ")")[0]
            .components(separatedBy: " ")
        
        let x = CGFloat(Float(transformComponents[4])!)
        
        // Y Position is a mess
        //First Flip coords
        var y = CGFloat(Float(transformComponents[5])!)
        // First flip coords into top-left space
        y = svgDimensions!.origin.y + svgDimensions!.height - y
        // Then offset by 1 line height since SVG TextBoxes measure from first baseline
        y += getOffsetRect(forText: "T", forFont: UIFont.aicMapSVGTextFont()!).height
        
        // Find the center point of the text box
        let offsetRect = getOffsetRect(forText: text, forFont: UIFont.aicMapSVGTextFont()!)
        let centerX = x + offsetRect.width/2.0
        let centerY = y - offsetRect.height/2.0
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    /**
     Illustrator uses the layer name as the ID, and IDs can not be shared.
     Fortunately it appends _1_ (incremented per duplicate occurences, so as long as we don't use _ in our
     layer names we can just strip it.
     */
    private func getSharedSVGId(forString string:String) -> String {
        return string.components(separatedBy: "_")[0]
    }
    
    private func getText(forSVGIndexerWithSpanTags textIndexer:XMLIndexer) -> String {
        var text = ""
        
        for (index, child) in textIndexer.children.enumerated() {
            guard let span = child.element , child.element!.name == "tspan" else {
                print(child.element!.name)
                continue
            }
            
            text.append(span.text!)
            if index != textIndexer.children.count-1 {
                text += "\n"
            }
        }
        
        return text
    }
}
