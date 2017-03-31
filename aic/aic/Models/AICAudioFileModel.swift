/*
Abstract:
 Defines a data structure for AIC Audio Files,
 which are associated with artworks and tours
*/

import Foundation

struct AICAudioFileModel {
    let nid: Int
    let title: String
    let url: URL
    let transcript: String
}
