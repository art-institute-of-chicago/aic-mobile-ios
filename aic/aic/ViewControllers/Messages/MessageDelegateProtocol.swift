/*
 Abstract:
 Shared delegate protocol for large and small message views
*/

import UIKit

@objc protocol MessageViewDelegate: class {
    func messageViewActionSelected(_ messageView:UIView)
    @objc optional func messageViewCancelSelected(_ messageView:UIView)
}
