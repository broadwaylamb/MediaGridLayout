//
//  MediaLayoutHelper.swift
//
//
//  Created by Grishka on 25.03.2023.
//

public protocol Sized {
    var width: Double { get }
    var height: Double { get }
}

public struct MediaLayoutResult<Element> {
    public var width: Int
    public var height: Int
    public var columnSizes: [Int]
    public var rowSizes: [Int]
    public var tiles: [Tile]

    public init(
        width: Int,
        height: Int,
        columnSizes: [Int],
        rowSizes: [Int],
        tiles: [Tile],
    ) {
        self.width = width
        self.height = height
        self.columnSizes = columnSizes
        self.rowSizes = rowSizes
        self.tiles = tiles
    }

    public struct Tile {
        public var element: Element
        public var colSpan: Int
        public var rowSpan: Int
        public var startCol: Int
        public var startRow: Int
        public var width: Int

        public init(
            element: Element,
            colSpan: Int,
            rowSpan: Int,
            startCol: Int,
            startRow: Int,
            width: Int = 0,
        ) {
            self.element = element
            self.colSpan = colSpan
            self.rowSpan = rowSpan
            self.startCol = startCol
            self.startRow = startRow
            self.width = width
        }
    }
}

extension MediaLayoutResult.Tile: Equatable where Element: Equatable {}
extension MediaLayoutResult.Tile: Hashable where Element: Hashable {}
extension MediaLayoutResult: Equatable where Element: Equatable {}
extension MediaLayoutResult: Hashable where Element: Hashable {}

public struct MediaLayout {
    public var maxWidth: Double
    public var maxHeight: Double
    public var minHeight: Double
    public var gap: Double
    public var maxRatio: Double

    public init() {
        self.init(
            maxWidth: 1000,
            maxHeight: 1777, // 9:16
            minHeight: 563,  // ~2:1
            gap: 1.5,
        )
    }

    public init(
        maxWidth: Double,
        maxHeight: Double,
        minHeight: Double,
        gap: Double,
    ) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.minHeight = minHeight
        self.gap = gap
        self.maxRatio = maxWidth / maxHeight
    }

    public func generate<C : Collection>(
        _ elements: C
    ) -> MediaLayoutResult<C.Element>? where C.Element: Sized {
        if elements.count < 2 {
            return nil
        }

        var ratios: [Double] = []
        var allAreWide = true
        var allAreSquare = true
        for size in elements {
            let ratio: Double = max(0.45, Double(size.width / size.height))
            if ratio <= 1.2 {
                allAreWide = false
                if ratio < 0.8 {
                    allAreSquare = false
                }
            } else {
                allAreSquare = false
            }
            ratios.append(ratio)
        }

        let avgRatio: Double = ratios.reduce(0.0, +) / Double(ratios.count)

        typealias Tile = MediaLayoutResult<C.Element>.Tile

        var iterator = elements.makeIterator()

        func tile(colSpan: Int, rowSpan: Int, startCol: Int, startRow: Int) -> Tile {
            Tile(
                element: iterator.next()!,
                colSpan: colSpan,
                rowSpan: rowSpan,
                startCol: startCol,
                startRow: startRow,
            )
        }

        switch elements.count {
        case 2:
            if allAreWide && avgRatio > 1.4 * maxRatio && abs(ratios[1] - ratios[0]) < 0.2 {
                // Two wide attachments, one above the other
                let h = Int(max(min(maxWidth / ratios[0], min(maxWidth / ratios[1], (maxHeight - gap) / 2.0)), minHeight / 2.0).rounded())

                return MediaLayoutResult(width: Int(maxWidth),
                    height: Int((Double(h) * 2.0 + gap).rounded()),
                    columnSizes: [Int(maxWidth)],
                    rowSizes: [h, h],
                    tiles: [
                        tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 1),
                    ])
            } else if allAreWide {
                // two wide photos, one above the other, different ratios
                var h0 = maxWidth / ratios[0]
                var h1 = maxWidth / ratios[1]
                if h0 + h1 < minHeight {
                    let prevTotalHeight = h0 + h1
                    h0 = minHeight * (h0 / prevTotalHeight)
                    h1 = minHeight * (h1 / prevTotalHeight)
                }
                let h0Int = Int(h0.rounded())
                let h1Int = Int(h1.rounded())
                return MediaLayoutResult(width: Int(maxWidth),
                                         height: h0Int + h1Int + Int(gap),
                                         columnSizes: [Int(maxWidth)],
                                         rowSizes: [h0Int, h1Int],
                                         tiles: [
                                            tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 0),
                                            tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 1),
                                         ])
            } else if allAreSquare {
                // Next to each other, same ratio
                let w: Double = (maxWidth - gap) / 2.0
                let h: Double = max(min(w / ratios[0], min(w / ratios[1], maxHeight)), minHeight)

                let wInt: Int = Int(w.rounded())
                let hInt: Int = Int(h.rounded())

                return MediaLayoutResult(width: Int(maxWidth),
                    height: hInt,
                    columnSizes: [wInt, Int(maxWidth) - wInt],
                    rowSizes: [hInt],
                    tiles: [
                        tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 0),
                    ])
            } else {
                // Next to each other, different ratios
                let w0: Double = ((maxWidth - gap) / ratios[1] / (1.0 / ratios[0] + 1.0 / ratios[1]))
                let w1: Double = maxWidth - w0 - gap
                let h: Double = max(min(maxHeight, min(w0 / ratios[0], w1 / ratios[1])), minHeight)

                let w0Int = Int(w0.rounded())
                let w1Int = Int(w1.rounded())
                let hInt = Int(h.rounded())

                return MediaLayoutResult(width: Int((w0 + w1 + gap).rounded()),
                    height: hInt,
                    columnSizes: [w0Int, w1Int],
                    rowSizes: [hInt],
                    tiles: [
                        tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 0),
                    ])
            }
        case 3:
            if ratios[0] > 1.2 * maxRatio || avgRatio > 1.5 * maxRatio || allAreWide {
                // One above two smaller ones
                var hCover: Double = min(maxWidth / ratios[0], (maxHeight - gap) * 0.66)
                let w2: Double = (maxWidth - gap) / 2.0
                var h: Double = min(maxHeight - hCover - gap, min(w2 / ratios[1], w2 / ratios[2]))
                if hCover + h < minHeight {
                    let prevTotalHeight = hCover + h
                    hCover = minHeight * (hCover / prevTotalHeight)
                    h = minHeight * (h / prevTotalHeight)
                }

                return MediaLayoutResult(width: Int(maxWidth),
                    height: Int((hCover + h + gap).rounded()),
                    columnSizes: [Int(w2.rounded()), Int(maxWidth - w2.rounded())],
                    rowSizes: [Int(hCover.rounded()), Int(h.rounded())],
                    tiles: [
                        tile(colSpan: 2, rowSpan: 1, startCol: 0, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 1),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 1),
                    ])
            } else {
                // One on the left, two smaller ones on the right
                let height: Double = min(maxHeight, maxWidth * 0.66 / avgRatio)
                let wCover: Double = min(height * ratios[0], (maxWidth - gap) * 0.66)
                let h1: Double = ratios[1] * (height - gap) / (ratios[2] + ratios[1])
                let h0: Double = height - h1 - gap
                let w: Double = min(maxWidth - wCover - gap, h1 * ratios[2], h0 * ratios[1])

                return MediaLayoutResult(width: Int((wCover + w + gap).rounded()),
                    height: Int(height.rounded()),
                    columnSizes: [Int(wCover.rounded()), Int(w.rounded())],
                    rowSizes: [Int(h0.rounded()), Int(h1.rounded())],
                    tiles: [
                        tile(colSpan: 1, rowSpan: 2, startCol: 0, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 1),
                    ])
            }
        case 4:
            if ratios[0] > 1.2 * maxRatio || avgRatio > 1.5 * maxRatio || allAreWide {
                // One above three smaller ones
                var hCover: Double = min(maxWidth / ratios[0], (maxHeight - gap) * 0.66)
                var h: Double = (maxWidth - 2.0 * gap) / (ratios[1] + ratios[2] + ratios[3])
                let w0: Double = h * ratios[1]
                let w1: Double = h * ratios[2]
                h = min(maxHeight - hCover - gap, h)
                if hCover + h < minHeight {
                    let prevTotalHeight = hCover + h
                    hCover = minHeight * (hCover / prevTotalHeight)
                    h = minHeight * (h / prevTotalHeight)
                }

                return MediaLayoutResult(width: Int(maxWidth),
                    height: Int((hCover + h + gap).rounded()),
                    columnSizes: [Int(w0.rounded()), Int(w1.rounded()), Int(maxWidth - w0.rounded() - w1.rounded())],
                    rowSizes: [Int(hCover.rounded()), Int(h.rounded())],
                    tiles: [
                        tile(colSpan: 3, rowSpan: 1, startCol: 0, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: 1),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 1),
                        tile(colSpan: 1, rowSpan: 1, startCol: 2, startRow: 1),
                    ])
            } else {
                // One on the left, three smaller ones on the right
                let height: Double = min(maxHeight, maxWidth * 0.66 / avgRatio)
                let wCover: Double = min(height * ratios[0], (maxWidth - gap) * 0.66)
                var w: Double = (height - 2.0 * gap) / (1.0 / ratios[1] + 1.0 / ratios[2] + 1.0 / ratios[3])
                let h0: Double = w / ratios[1]
                let h1: Double = w / ratios[2]
                let h2: Double = w / ratios[3] + gap
                w = min(maxWidth - wCover - gap, w)

                return MediaLayoutResult(width: Int((wCover + gap + w).rounded()),
                    height: Int(height.rounded()),
                    columnSizes: [Int(wCover.rounded()), Int(w.rounded())],
                    rowSizes: [Int(h0.rounded()), Int(h1.rounded()), Int(h2.rounded())],
                    tiles: [
                        tile(colSpan: 1, rowSpan: 3, startCol: 0, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 0),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 1),
                        tile(colSpan: 1, rowSpan: 1, startCol: 1, startRow: 2),
                    ])
            }
        default:
            let cnt = elements.count
            var ratiosCropped: [Double] = []
            if avgRatio > 1.1 {
                for ratio in ratios {
                    ratiosCropped.append(max(1.0, ratio))
                }
            } else {
                for ratio in ratios {
                    ratiosCropped.append(min(1.0, ratio))
                }
            }

            var tries: [[Int]: [Double]] = [:]

            // One line
            tries[[elements.count]] = [calculateMultiThumbsHeight(ratios: ratiosCropped, width: maxWidth, margin: gap)]

            // Two lines
            for firstLine in 1...cnt - 1 {
                tries[[firstLine, cnt - firstLine]] = [
                    calculateMultiThumbsHeight(ratios: ratiosCropped[..<firstLine], width: maxWidth, margin: gap),
                    calculateMultiThumbsHeight(ratios: ratiosCropped[firstLine...], width: maxWidth, margin: gap)
                ]
            }

            // Three lines
            for firstLine in 1...cnt - 2 {
                for secondLine in 1...cnt - firstLine-1 {
                    tries[[firstLine, secondLine, cnt - firstLine - secondLine]] = [
                        calculateMultiThumbsHeight(ratios: ratiosCropped[..<firstLine], width: maxWidth, margin: gap),
                        calculateMultiThumbsHeight(ratios: ratiosCropped[firstLine..<firstLine + secondLine], width: maxWidth, margin: gap),
                        calculateMultiThumbsHeight(ratios: ratiosCropped[(firstLine + secondLine)...], width: maxWidth, margin: gap)
                    ]
                }
            }

            let realMaxHeight = min(maxWidth, maxHeight)

            var optConf: [Int] = []
            var optDiff: Double = Double.greatestFiniteMagnitude

            for (conf, heights) in tries {
                let confH: Double = heights.reduce(gap * Double(heights.count - 1), +)
                var confDiff = abs(confH - realMaxHeight)
                if conf.count > 1 && (conf[0] > conf[1] || (conf.count > 2 && conf[1] > conf[2])) {
                    confDiff *= 1.1
                }
                if confDiff < optDiff {
                    optConf = conf
                    optDiff = confDiff
                }
            }

            var thumbsRemain = elements.count
            var ratiosRemain: [Double] = Array(ratiosCropped)
            let optHeights = tries[optConf]!
            var totalHeight: Double = 0.0
            var rowSizes: [Int] = []
            var gridLineOffsets: [Int] = []
            var rowTiles: [[Tile]] = []

            for (i, lineChunksNum) in optConf.enumerated() {
                let lineThumbs = lineChunksNum
                thumbsRemain -= lineChunksNum
                let lineHeight = optHeights[i]
                totalHeight += lineHeight
                rowSizes.append(Int(lineHeight.rounded()))
                var totalWidth: Int = 0
                var row: [Tile] = []
                for j in 0..<lineThumbs {
                    let thumbRatio = ratiosRemain.removeFirst()
                    let w: Double = j == lineThumbs - 1 ? (maxWidth - Double(totalWidth)) : (thumbRatio * lineHeight)
                    totalWidth += Int(w.rounded())
                    if j < lineThumbs - 1 && !gridLineOffsets.contains(totalWidth) {
                        gridLineOffsets.append(totalWidth)
                    }
                    var tile = tile(colSpan: 1, rowSpan: 1, startCol: 0, startRow: i)
                    tile.width = Int(w.rounded())
                    row.append(tile)
                }
                rowTiles.append(row)
            }

            gridLineOffsets = gridLineOffsets.sorted()
            gridLineOffsets.append(Int(maxWidth))

            var columnSizes: [Int] = [gridLineOffsets[0]]
            for (i, offset) in gridLineOffsets[1...].enumerated() {
                columnSizes.append(offset - gridLineOffsets[i]) // i is already offset by one here
            }

            for row in 0..<rowTiles.count {
                var columnOffset: Int = 0
                for (tile, _) in rowTiles[row].enumerated() {
                    let startColumn = columnOffset
                    rowTiles[row][tile].startCol = startColumn
                    var width: Int = 0
                    rowTiles[row][tile].colSpan = 0
                    for i in startColumn..<columnSizes.count {
                        width += columnSizes[i]
                        rowTiles[row][tile].colSpan += 1
                        if width == rowTiles[row][tile].width {
                            break
                        }
                    }
                    columnOffset += rowTiles[row][tile].colSpan
                }
            }

            return MediaLayoutResult(width: Int(maxWidth),
                height: Int((totalHeight + gap * Double(optHeights.count - 1)).rounded()),
                columnSizes: columnSizes,
                rowSizes: rowSizes,
                tiles: rowTiles.flatMap { $0 },
            )
        }
    }

    private func calculateMultiThumbsHeight<Ratios: Collection>(
        ratios: Ratios,
        width: Double,
        margin: Double,
    ) -> Double where Ratios.Element == Double {
        return (width - (Double(ratios.count) - 1.0) * margin) / ratios.reduce(0.0, +)
    }
}
