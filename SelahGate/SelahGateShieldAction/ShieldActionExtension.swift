import ManagedSettings
import UIKit

class ShieldActionExtension: ShieldActionDelegate {

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action, completionHandler: completionHandler)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action, completionHandler: completionHandler)
    }

    private func handleAction(_ action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            let ritual = PendingRitual(source: "shield", depth: .light)
            AppGroupStore.setPendingRitual(ritual)
            openRitual()
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    private func openRitual() {
        guard let url = URL(string: "selahgate://ritual?depth=light") else { return }
        var responder: UIResponder? = nil
        let sel = NSSelectorFromString("sharedApplication")
        if UIApplication.responds(to: sel) {
            responder = UIApplication.perform(sel).takeUnretainedValue() as? UIResponder
        }
        let openSel = NSSelectorFromString("openURL:")
        if let responder, responder.responds(to: openSel) {
            responder.perform(openSel, with: url)
        }
    }
}
