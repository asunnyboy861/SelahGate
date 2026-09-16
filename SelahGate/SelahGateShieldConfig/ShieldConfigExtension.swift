import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application?) -> ShieldConfiguration {
        let verse = VerseLibrary.randomToday()
        let appName = application?.localizedDisplayName ?? "this app"
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor(named: "DawnBackground") ?? UIColor(red: 0.99, green: 0.93, blue: 0.85, alpha: 1),
            icon: UIImage(named: "GateMark"),
            title: ShieldConfiguration.Label(
                text: "One Selah before \(appName)",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "\"\(verse.text)\" — \(verse.ref)",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Pray to Unlock",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.71, green: 0.53, blue: 0.29, alpha: 1),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Not now",
                color: .secondaryLabel
            )
        )
    }
}
