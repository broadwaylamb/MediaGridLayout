import Testing
import MediaGridLayout

private let layout = MediaLayout()

private struct CGSize: HasAspectRatio, Equatable, CustomStringConvertible {
    var width: Double
    var height: Double

    var aspectRatio: Double { width / height }

    var description: String {
        "\(width)×\(height)"
    }
}

@Test func returnsNilWhenZeroOrOneMedia() {
    #expect(layout.generate([CGSize]()) == nil)
    #expect(layout.generate([CGSize(width: 100, height: 100)]) == nil)
}

@Test func squareSizesOnly() {
    #expect(
        layout.generate([
            CGSize(width: 100, height: 100),
            CGSize(width: 200, height: 200),
            CGSize(width: 300, height: 300),
        ]) == MediaLayoutResult(
            width: 1000,
            height: 1501,
            columnSizes: [499, 501],
            rowSizes: [1000, 499],
            tiles: [
                .init(element: CGSize(width: 100, height: 100), colSpan: 2, rowSpan: 1, startCol: 0, startRow: 0),
                .init(element: CGSize(width: 200, height: 200), colSpan: 1, rowSpan: 1, startCol: 0, startRow: 1),
                .init(element: CGSize(width: 300, height: 300), colSpan: 1, rowSpan: 1, startCol: 1, startRow: 1),
            ],
        )
    )
}

@Test func oneAboveTwoSmallerOnes() {
    let layout = MediaLayout(
        maxWidth: 320,
        maxHeight: 569,
        minHeight: 160,
        gap: 1,
    )
    #expect(
        layout.generate([
            CGSize(width: 60, height: 20),
            CGSize(width: 30, height: 20),
            CGSize(width: 20, height: 20),
        ]) == MediaLayoutResult(
            width: 320,
            height: 214,
            columnSizes: [160, 160],
            rowSizes: [107, 106],
            tiles: [
                .init(element: CGSize(width: 60, height: 20), colSpan: 2, rowSpan: 1, startCol: 0, startRow: 0),
                .init(element: CGSize(width: 30, height: 20), colSpan: 1, rowSpan: 1, startCol: 0, startRow: 1),
                .init(element: CGSize(width: 20, height: 20), colSpan: 1, rowSpan: 1, startCol: 1, startRow: 1),
            ],
        )
    )
}

@Test func nineItems() {
    #expect(
        layout.generate([
            CGSize(width: 100, height: 200),
            CGSize(width: 200, height: 100),
            CGSize(width: 300, height: 300),
            CGSize(width: 150, height: 200),
            CGSize(width: 10, height: 100),
            CGSize(width: 10, height: 10),
            CGSize(width: 250, height: 200),
            CGSize(width: 33, height: 100),
            CGSize(width: 160, height: 90),
        ]) == MediaLayoutResult(
            width: 1000,
            height: 864,
            columnSizes: [87, 174, 49, 125, 130, 78, 174, 183],
            rowSizes: [174, 689],
            tiles: [
                .init(element: CGSize(width: 100, height: 200), colSpan: 1, rowSpan: 1, startCol: 0, startRow: 0, width: 87),
                .init(element: CGSize(width: 200, height: 100), colSpan: 1, rowSpan: 1, startCol: 1, startRow: 0, width: 174),
                .init(element: CGSize(width: 300, height: 300), colSpan: 2, rowSpan: 1, startCol: 2, startRow: 0, width: 174),
                .init(element: CGSize(width: 150, height: 200), colSpan: 1, rowSpan: 1, startCol: 4, startRow: 0, width: 130),
                .init(element: CGSize(width: 10, height: 100), colSpan: 1, rowSpan: 1, startCol: 5, startRow: 0, width: 78),
                .init(element: CGSize(width: 10, height: 10), colSpan: 1, rowSpan: 1, startCol: 6, startRow: 0, width: 174),
                .init(element: CGSize(width: 250, height: 200), colSpan: 1, rowSpan: 1, startCol: 7, startRow: 0, width: 183),
                .init(element: CGSize(width: 33, height: 100), colSpan: 3, rowSpan: 1, startCol: 0, startRow: 1, width: 310),
                .init(element: CGSize(width: 160, height: 90), colSpan: 5, rowSpan: 1, startCol: 3, startRow: 1, width: 690)
            ],
        )
    )
}

