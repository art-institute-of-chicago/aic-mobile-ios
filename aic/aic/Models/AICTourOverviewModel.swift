/*
 Abstract:
 The tour's overview, which functions as the first tour stop
 */
import Foundation

struct AICTourOverviewModel {
    let title: String
    let description: String
    let imageUrl: URL
    let audio: AICAudioFileModel
    let credits: String
}
