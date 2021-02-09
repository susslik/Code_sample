// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Comment
  internal static let commentPlaceholder = L10n.tr("Localizable", "comment_placeholder")
  /// Please wait untill image uploading finished
  internal static let imageIsUploadingErrorDescription = L10n.tr("Localizable", "image_is_uploading_error_description")
  /// Some images uploading failed. Please retry uploading or remove them
  internal static let imageUploadingFailedErrorDescription = L10n.tr("Localizable", "image_uploading_failed_error_description")
  /// Next
  internal static let nextButtonTitle = L10n.tr("Localizable", "next_button_title")
  /// Please fill comment
  internal static let noCommentErrorDescription = L10n.tr("Localizable", "no_comment_error_description")

  internal enum AlertAction {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "alert_action.cancel")
    /// Delete image
    internal static let deleteImage = L10n.tr("Localizable", "alert_action.delete_image")
    /// Select from Library
    internal static let openGallery = L10n.tr("Localizable", "alert_action.open_gallery")
    /// Open settings
    internal static let openSettings = L10n.tr("Localizable", "alert_action.open_settings")
    /// Select from Library
    internal static let selectFromGallery = L10n.tr("Localizable", "alert_action.select_from_gallery")
    /// Take a photo
    internal static let takePhoto = L10n.tr("Localizable", "alert_action.take_photo")
  }

  internal enum AlertMessage {
    /// To take a photo you will need to turn on camera permisson.
    internal static let cameraDenied = L10n.tr("Localizable", "alert_message.camera_denied")
    /// To select an photo you will need to turn on library permisson.
    internal static let libraryDenied = L10n.tr("Localizable", "alert_message.library_denied")
    /// Library permissions limited. Some photos may be unavailable.
    internal static let libraryLimited = L10n.tr("Localizable", "alert_message.library_limited")
  }

  internal enum AlertTitle {
    /// Permission limited.
    internal static let libraryLimited = L10n.tr("Localizable", "alert_title.library_limited")
    /// Permission denied.
    internal static let permissionDenied = L10n.tr("Localizable", "alert_title.permission_denied")
  }

  internal enum UnreportedDamages {
    /// Back Side
    internal static let backTitle = L10n.tr("Localizable", "unreported_damages.back_title")
    /// Front Side
    internal static let frontTitle = L10n.tr("Localizable", "unreported_damages.front_title")
    /// Left Side
    internal static let leftTitle = L10n.tr("Localizable", "unreported_damages.left_title")
    /// Right Side
    internal static let rightTitle = L10n.tr("Localizable", "unreported_damages.right_title")
    /// Please identify the unreported damage area
    internal static let title = L10n.tr("Localizable", "unreported_damages.title")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
