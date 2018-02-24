/*
 Abstract:
 Model for map, containing all annotations + overlays
 Parses these from SVG File
 */

import Foundation
import CoreGraphics
import MapKit

class AICMapModel {
    // Global Annotations
    private (set) var lionAnnotations:[MapImageAnnotation] = []
    private (set) var landmarkAnnotations:[MapTextAnnotation] = []
    private (set) var gardenAnnotations:[MapTextAnnotation] = []
	
	private (set) var backgroundOverlay: FloorplanOverlay? = nil
    
    // Floors
    private (set) var floors:[AICMapFloorModel] = []
    
    // Go through the SVG file (XML) and create all of our
    // annotations up front
    func loadData() {
		
		// Background
		let backgroundPdfUrl = Bundle.main.url(forResource: "map_bg", withExtension: "pdf", subdirectory:Common.Map.mapsDirectory)!
		
		backgroundOverlay = FloorplanOverlay(floorplanUrl: backgroundPdfUrl, withPDFBox: CGPDFBox.trimBox, andAnchors: Common.Map.anchorPair)
		
        // Create parser with SVG File
        let svgParser = MapSVGParser(svgFile: Common.Map.mapSVGFileURL!,
                                     totalFloors: Common.Map.totalFloors
        )
        
        // Global Annotations
        lionAnnotations     = getImageAnnotations(fromSvgImages: svgParser.lions)
        landmarkAnnotations = getTextAnnotations(fromSVGTextLabels: svgParser.landmarks, type: MapTextAnnotation.AnnotationType.LandmarkGarden)
        gardenAnnotations   = getTextAnnotations(fromSVGTextLabels: svgParser.gardens, type: MapTextAnnotation.AnnotationType.LandmarkGarden)
        
        // Floors
        for i in 0..<Common.Map.totalFloors {
            let svgFloor = svgParser.floors[i]
            
            // Get the gallery annotations for this floor
            let galleryAnnotations = getGalleryAnnotations(forFloorNumber: i)

//            // Convert SVG Annotations for this floor (amenities, departments, spaces) to map annotations
//            let amenityAnnotations:[MapAmenityAnnotation]           = getAmenityAnnotations(fromSVGAmenities: svgFloor.amenities)
//            let departmentAnnotations:[MapDepartmentAnnotation]     = getDepartmentAnnotations(fromSVGDepartments: svgFloor.departments)
//            let spaceAnnotations:[MapTextAnnotation]                = getTextAnnotations(fromSVGTextLabels: svgFloor.spaces, type: MapTextAnnotation.AnnotationType.Space)
			
            
            // Create annotations for objects on this floor from app data
            var objectAnnotations:[MapObjectAnnotation] = []
            for object in AppDataManager.sharedInstance.getObjects(forFloor: i) {
                objectAnnotations.append(MapObjectAnnotation(object: object))
            }
            
            // Load Floorplan Overlay (Part of Apple Footprint) from PDF
            let pdfUrl = Bundle.main.url(forResource: Common.Map.floorplanFileNamePrefix + String(i), withExtension: "pdf", subdirectory:Common.Map.mapsDirectory)!
            
            let overlay = FloorplanOverlay(floorplanUrl: pdfUrl, withPDFBox: CGPDFBox.trimBox, andAnchors: Common.Map.anchorPair)
            
            // Create this floor
            let floor = AICMapFloorModel(floorNumber: i,
                                         overlay: overlay,
                                         objects:objectAnnotations,
                                         amenities: [MapAmenityAnnotation](),
                                         departments: [MapDepartmentAnnotation](),
                                         galleries: [MapTextAnnotation](),
                                         spaces: [MapTextAnnotation]()
            )
            
            floors.append(floor)
        }
    }
    
    // Gallery annotations from App Data
    private func getGalleryAnnotations(forFloorNumber floorNumber:Int) -> [MapTextAnnotation] {
        let galleriesForThisFloor = AppDataManager.sharedInstance.getGalleries(forFloorNumber: floorNumber)
        
        var galleryAnnotations:[MapTextAnnotation] = []
        for gallery in galleriesForThisFloor {
            galleryAnnotations.append(MapTextAnnotation(coordinate: gallery.location.coordinate, text: gallery.displayTitle, type: MapTextAnnotation.AnnotationType.Gallery))
        }
        
        return galleryAnnotations
    }
    
    // SVG to Image Annotation
    private func getImageAnnotations(fromSvgImages svgImages:[SVGImage]) -> [MapImageAnnotation] {
        var lionImageAnnotatations:[MapImageAnnotation] = []
        for svgImage in svgImages {
            let coord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(svgImage.positionInSVG))
            lionImageAnnotatations.append(MapImageAnnotation(coordinate: coord, imageName: svgImage.imageName))
        }
        
        return lionImageAnnotatations
    }
    
    private func getDepartmentAnnotations(fromSVGDepartments SVGDepartments:[SVGDepartment]) -> [MapDepartmentAnnotation] {
        var departmentAnnotations:[MapDepartmentAnnotation] = []
        
        for svgAnnotation in SVGDepartments {
            let coord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(svgAnnotation.positionInSVG))
            guard let department = Common.Map.Department(rawValue: svgAnnotation.id) else {
                print("Could not find correct department for SVGDepartment with id: \(svgAnnotation.id)")
                continue
            }
            
            guard let title = Common.Map.departmentTitles[department] else {
                print("Could not find department title for department: \(department)")
                continue
            }
            
            departmentAnnotations.append(MapDepartmentAnnotation(coordinate:coord, title: title, imageName:svgAnnotation.id))
            
        }
        
        return departmentAnnotations
    }
    
    // SVG to Amenity Annotation
    private func getAmenityAnnotations(fromSVGAmenities SVGAmenities:[SVGAmenity]) -> [MapAmenityAnnotation] {
        var amenityAnnotations: [MapAmenityAnnotation] = []
        for svgAnnotation in SVGAmenities {
            let coord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(svgAnnotation.positionInSVG))
            amenityAnnotations.append(MapAmenityAnnotation(coordinate: coord, type: svgAnnotation.type))
        }
        
        return amenityAnnotations
    }
    
    // SVG to Text Annotation
    private func getTextAnnotations(fromSVGTextLabels svgTextLabels:[SVGTextLabel], type:MapTextAnnotation.AnnotationType) -> [MapTextAnnotation] {
        var textAnnotations: [MapTextAnnotation] = []
        for svgAnnotation in svgTextLabels {
            let coord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(svgAnnotation.positionInSVG))
            textAnnotations.append(MapTextAnnotation(coordinate: coord, text: svgAnnotation.text, type:type))
        }
        
        return textAnnotations
    }

}
