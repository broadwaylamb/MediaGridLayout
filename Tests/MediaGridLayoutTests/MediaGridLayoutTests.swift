import Testing
import MediaGridLayout
import CoreGraphics

private let layout = MediaLayout(maxWidth: 1000, maxHeight: 1777, minHeight: 563, gap: 1.5)

@Test func returnsNilWhenZeroOrOneMedia() {
    #expect(layout.generate(mediaSizes: []) == nil)
    #expect(layout.generate(mediaSizes: [CGSize(width: 100, height: 100)]) == nil)
}

@Test func squareSizesOnly() {
    #expect(
        layout.generate(mediaSizes: [
            CGSize(width: 100, height: 100),
            CGSize(width: 200, height: 200),
            CGSize(width: 300, height: 300),
        ]) == MediaLayoutResult(
            width: 1000,
            height: 1501,
            columnSizes: [499, 501],
            rowSizes: [1000, 499],
            tiles: [
                .init(colSpan: 2, rowSpan: 1, startCol: 0, startRow: 0),
                .init(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 1),
                .init(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 1),
            ],
        )
    )
}

@Test func nineItems() {
    #expect(
        layout.generate(mediaSizes: [
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
                .init(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 0, width: 87),
                .init(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 0, width: 174),
                .init(colSpan: 2, rowSpan: 1, startCol: 2, startRow: 0, width: 174),
                .init(colSpan: 1, rowSpan: 1, startCol: 4, startRow: 0, width: 130),
                .init(colSpan: 1, rowSpan: 1, startCol: 5, startRow: 0, width: 78),
                .init(colSpan: 1, rowSpan: 1, startCol: 6, startRow: 0, width: 174),
                .init(colSpan: 1, rowSpan: 1, startCol: 7, startRow: 0, width: 183),
                .init(colSpan: 3, rowSpan: 1, startCol: 0, startRow: 1, width: 310),
                .init(colSpan: 5, rowSpan: 1, startCol: 3, startRow: 1, width: 690)
            ],
        )
    )
}

