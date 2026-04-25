import SwiftUI
import UIKit

func configureNavigationBarAppearance() {
    let large = UIFont(name: "EBGaramond-SemiBold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
    let inline = UIFont(name: "EBGaramond-SemiBold", size: 18) ?? .systemFont(ofSize: 18, weight: .semibold)
    let button = UIFont(name: "EBGaramond-SemiBold", size: 17) ?? .systemFont(ofSize: 17)
    let white = UIColor(Color.starWhite)
    let background = UIColor(Color.nightSky)

    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = background
    appearance.shadowColor = .clear
    appearance.largeTitleTextAttributes = [.font: large, .foregroundColor: white]
    appearance.titleTextAttributes = [.font: inline, .foregroundColor: white]

    let buttonAppearance = UIBarButtonItemAppearance()
    buttonAppearance.normal.titleTextAttributes = [.font: button, .foregroundColor: white]
    buttonAppearance.highlighted.titleTextAttributes = [.font: button, .foregroundColor: white]
    appearance.buttonAppearance = buttonAppearance
    appearance.doneButtonAppearance = buttonAppearance

    let scrollEdge = UINavigationBarAppearance()
    scrollEdge.configureWithOpaqueBackground()
    scrollEdge.backgroundColor = background
    scrollEdge.shadowColor = .clear
    scrollEdge.largeTitleTextAttributes = [.font: large, .foregroundColor: white]
    scrollEdge.titleTextAttributes = [.font: inline, .foregroundColor: white]
    scrollEdge.buttonAppearance = buttonAppearance
    scrollEdge.doneButtonAppearance = buttonAppearance

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = scrollEdge
    UINavigationBar.appearance().compactAppearance = appearance
}
