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
