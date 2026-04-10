import Foundation
import FamilyControls

/// User-selected blocking preferences used by `FocusBlocker`.
public struct BlockingConfiguration: Sendable {
    /// Selected applications and categories from `FamilyActivityPicker`.
    public var selection: FamilyActivitySelection
    /// Whether shields also apply during breaks.
    public var blockDuringBreaks: Bool
    /// Title shown on the shield view.
    public var shieldTitle: String
    /// Subtitle shown on the shield view.
    public var shieldSubtitle: String

    /// Creates a new blocking configuration.
    public init(
        selection: FamilyActivitySelection = FamilyActivitySelection(),
        blockDuringBreaks: Bool = false,
        shieldTitle: String = "Focus Time",
        shieldSubtitle: String = "Stay on task"
    ) {
        self.selection = selection
        self.blockDuringBreaks = blockDuringBreaks
        self.shieldTitle = shieldTitle
        self.shieldSubtitle = shieldSubtitle
    }
}
