/*
 Abstract:
 Testing data models
*/

import Foundation
import CoreLocation

class TestModels {
    let testTrackURL:URL
    let testAudioModel:AICAudioFileModel
    
    let testObject:AICObjectModel
    
    var allObjects:[AICObjectModel] = []
    
    var testNewsItems:[AICNewsItemModel] = []
    var testTours:[AICTourModel] = []
    
    static let sharedInstance = TestModels()
    
    init() {
        testTrackURL = Bundle.main.url(forResource: "thorneOverview", withExtension: "mp3", subdirectory:"Assets/placeholder/audio")!
    
        testAudioModel = AICAudioFileModel(nid:0, title: "Test Audio Track", url: testTrackURL, transcript: "Lindsay Mican Morgan:  &lt;sings&gt; Excited, excited, Thorne Rooms. Go.\r\n\r\nWelcome to the Mrs. James Ward Thorne Miniature Rooms.  My name is Lindsay Mican Morgan.  I&#039;m the keeper of the Thorne Rooms here at the Art Institute of Chicago.  After Mrs. Thorne constructed the Miniature Rooms they went on tour across the country, stopping at world&#039;s fairs and museum.\r\n\r\nAlice Pirie Wirtz:  And of course it was extraordinary before they moved the rooms to their present location.\r\nLindsay Mican Morgan:  Alice Pirie Wirtz was the keeper of the Thorne Rooms at the time. \r\n\r\nI&#039;ve always been somebody who likes little things, maybe too much so, because I&#039;ve got too much stuff, you know?\r\n\r\nLindsay Mican Morgan:  Previously to where they are now at the Art Institute, the Miniature Rooms were housed in the east side of the museum.\r\n\r\nAlice Pirie Wirtz:  It was very dark and gloomy, very dark.  There was a big railing in front of the rooms that didn&#039;t seem to be attached very securely because I think the children knew that they could shake this railing and move the little objects around in the rooms, and of course there was a train right under the Thorne Rooms &lt;sound of train&gt;.  The whole place shook.\r\n\r\nLindsay Mican Morgan:  In the beginning I think they were somewhat seen as perhaps a useful education tool, but as far as the academics I don&#039;t think that they were initially seen exactly as art objects.  If people want to first approach them as, &quot;Oh, doll houses,&quot; it&#039;s like, &quot;Yes, sure.&quot;  And now...\r\n\r\nAlice Pirie Wirtz:  It&#039;s a venture in history.  You can see a Louis VIII or Louis&#039;s VI room; you can see a Japanese pagoda, the early American rooms.\r\n\r\nLindsay Mican Morgan:  We tend to sort of write them off as small or insignificant or play things, but miniatures actually have, which we can see in their history, an incredible amount of meaning for humans in both this life and the afterlife. \r\n\r\nMarianne Malone:  The Thorne Rooms represent that very primitive, primal important urge that creatures have, a sense of mastery when you can see the whole space in front of you and you are bigger than that space.  You&#039;re like a god.  You&#039;re creating it.  You&#039;re controlling it.\r\n\r\nHank Kupjack:  These are little 3-dimensional virtual realities.  They&#039;re like silent films in color that you provide the life to.\r\n\r\nMarianne Malone:  They&#039;re an odd thing.  You know they&#039;re this fabulous obsession that this one woman had, and she executed it so perfectly and there&#039;s nothing like them in the world.\r\n\r\nAlice Pirie Wirtz:  You know it&#039;s just amazing how she created all this.  You&#039;ll never see anything like this again, ever.\r\n")
        
        let testObjectThumbnailurl = Bundle.main.url(forResource: "wrestler2", withExtension: "jpg", subdirectory:"Assets/placeholder/images")!
        let testObjectImageUrl = Bundle.main.url(forResource: "wrestler2", withExtension: "jpg", subdirectory:"Assets/placeholder/images")!
        
        let testObjectLocation = CoordinateWithFloor(coordinate: CLLocationCoordinate2DMake(41.878000,-87.623988), floor:1)
        testObject = AICObjectModel(nid:123,
                                    thumbnailUrl: testObjectThumbnailurl,
                                    thumbnailCropRect: nil,
                                    imageUrl:testObjectImageUrl,
                                    imageCropRect: nil,
                                    title:"California Love",
                                    audioFiles:[testAudioModel],
                                    audioGuideIDs: nil,
                                    tombstone: "Courtesan Playing with a Cat\nKaigetsudo Dohan\nJapanese, active c. 1708-16\nHand-colored woodblock Print; tan-e, vertical 0-oban",
                                    credits: "In fringilla ultricies velit, nec ultrices erat rutrum vel. Morbi nisi tortor, dictum ac imperdiet non, tincidunt at magna. Phasellus aliquet finibus augue, vitae ullamcorper leo condimentum non. ",
                                    imageCopyright: "© Robert Rauschenberg Foundation.",
                                    location: testObjectLocation
        )
        
        // News Items
        let titles:[String] = ["Van Gogh's Bedrooms", "The New Contemporary", "Martin Puryear: Multiple Dimensions", "Van Dyck, Rembrandt, and the Portrait Print", "Chagall Homecoming", "A Portrait of Antinous, in Two Parts", "Nothing Personal: Zoe Leonard, Cindy Sherman, Lorna Simpson", "Supernatural Shakespeare", "Shakers and Movers: Selections from the Collection of Dr. Thomas and Jan Pavlovic", "Materials Inside and Out"]
        
        let descriptions = ["Presented only at the Art Institute, this exhibition is the first dedicated to the artist's three \"Bedroom\" paintings, presenting an in-depth study of their making and meaning to Van Gogh.",
                            "Iconic contemporary masterpieces by artists such as Andy Warhol, Roy Lichtenstein, and Jasper Johns are among the 44 new works that transform the presentation of our contemporary collection.",
                            "Presenting over 100 drawings and prints as well as 12 sculptures, this exhibition offers an unprecedented look into Puryear's inspirations, methods, and transformative process.",
                            "Inspired by Van Dyck's \"Iconography\" etchings, this exhibition examines the history of the portrait print through 140 works—from Dürer, van Dyck, and Rembrandt through Degas, Kollwitz, and Close.",
                            "After two transatlantic journeys and a historic meeting in Florence last fall with His Holiness Pope Francis, Marc Chagall’s masterwork returns with a special presentation.",
                            "Uniting the “two parts” of a bust from the Art Institute and Rome’s Palazzo Altemps Museum, this exhibition features a reconstruction of the original piece as it would have appeared in antiquity.",
                            "The work of three Americans comes together in this show exploring the personal and all that it encompasses—personality, personhood, and what it means to be, or not be, able to be your own person.",
                            "Part of the Shakespeare 400 Festival, this focused installation features three engravings of Shakespearian scenes by various artists emulating works by the renowned Gothic artist Henri Fuseli.",
                            "This selection of over 20 Shaker objects made in the late 18th and 19th centuries exemplifies the craftsmanship synonymous with the influential utopian religious community.",
                            "Inspired by the wide-ranging approach of architect David Adjaye, this installation offers a hands-on exploration of how architects use building materials to create form and atmosphere."]
        
        for i in 0..<titles.count {
            let thumbUrl = Bundle.main.url(forResource: "newsThumb" + String(i+1), withExtension: "jpg", subdirectory:"Assets/placeholder/images")!
            let imageUrl = Bundle.main.url(forResource: "news" + String(i+1), withExtension: "jpg", subdirectory:"Assets/placeholder/images")!
            let location = getRandomLocation()
            
            let newsItem = AICNewsItemModel(title:titles[i],
                                            shortDescription:descriptions[i],
                                            longDescription:descriptions[i],
                                            additionalInformation: "Through May 20th, 2017",
                                            imageUrl: imageUrl,
                                            imageCropRect: nil,
                                            thumbnailUrl: thumbUrl,
                                            location: location,
                                            bannerString: nil
            )
            
            testNewsItems.append(newsItem)
        }
        
        // Dummy tours for temporary filler
        for i in 1...10 {
            let imageUrl = Bundle.main.url(forResource: "artwork" + String(i), withExtension: "jpg", subdirectory:"Assets/placeholder/images")!
            
            //let overviewImageUrl = NSBundle.mainBundle().URLForResource("wrestler0", withExtension: "jpg", subdirectory:"Assets/placeholder/images")!
            let overview = AICTourOverviewModel(title: "Tour Overview",
                                                description: "Tour Overview Description.......",
                                                imageUrl: imageUrl,
                                                audio: testAudioModel,
                                                credits: "Copyright 2016 Art Insitute of Chicago"
            )
            
            var stops:[AICTourStopModel] = []
            for j in 1..<5 {
                let objectThumbUrl = Bundle.main.url(forResource: "sculptureThumb" + String(j), withExtension: "jpg", subdirectory:"Assets/placeholder/images")!
                let objectImageUrl = Bundle.main.url(forResource: "sculpture" + String(j), withExtension: "jpg", subdirectory:"Assets/placeholder/images")!
                
                let location = getRandomLocation()
                
                let object = AICTourStopModel(order: j,
                                              object:AICObjectModel(
                                                    nid: j,
                                                    thumbnailUrl: objectThumbUrl,
                                                    thumbnailCropRect: nil,
                                                    imageUrl:objectImageUrl,
                                                    imageCropRect: nil,
                                                    title: "Tour Stop \(j)",
                                                    audioFiles:[testAudioModel],
                                                    audioGuideIDs: [800 + j],
                                                    tombstone: "This is the tombstone information about this object",
                                                    credits: "Copyright 2016 Art Insitute of Chicago",
                                                    imageCopyright:"© Robert Rauschenberg Foundation.",
                                                    location: location
                                                ),
                                                audio:testAudioModel
                )
                
                stops.append(object)
                allObjects.append(object.object)
            }
            
            let tourTitle = (i == 1) ? "Impressionism" :  "This is the title of tour item \(i)"
            let tourModel = AICTourModel(nid:i,
                                         title: tourTitle,
                                         shortDescription: "Experience this comprehensive and remarkable sampling from the Impressionist painters.",
                                         longDescription: "From the light-filled Impressionist paintings of Monet and Renoir to the influential Post-Impressionist canvases of Cézanne and Seurat, the Art Institute’s holdings of Iate 19th-century French art are among the largest and finest in the world, thanks to the Chicago collectors intent on building a great museum during the period that these paintings were made. Not only does this outstanding collection chart the history and legacy of the groundbreaking Impressionist and Post-Impressionist movements, but it also includes some of the most well-known and well-loved works in the entire museum. Enjoy paintings both beloved and iconic on a tour of this world-famous collection.",
                                         imageUrl: imageUrl,
                                         overview: overview,
                                         stops: stops,
                                         bannerString: nil
            )
            
            testTours.append(tourModel)
        }
    }
    
    func getRandomLocation() -> CoordinateWithFloor {
        let latitude1 = 41.880623
        let longitude1 = -87.624013
        
        let latitude2 = 41.878426
        let longitude2 = -87.620859
        
        let ranLatitude = latitude1 + Double(arc4random())/Double(UINT32_MAX) * (latitude2 - latitude1)
        let ranLongitude = longitude1 + Double(arc4random())/Double(UINT32_MAX) * (longitude2 - longitude1)
        
        let ranFloor:Int = Int(floor(Double(arc4random())/Double(UINT32_MAX) * 4))
        
        return CoordinateWithFloor(coordinate: CLLocationCoordinate2D(latitude: ranLatitude, longitude: ranLongitude), floor: ranFloor)
        
    }
}
