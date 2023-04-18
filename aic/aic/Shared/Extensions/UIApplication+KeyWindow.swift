import UIKit

extension UIApplication {

  static var keyWindow: UIWindow? {
    let window = UIApplication
      .shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    return window
  }

}
