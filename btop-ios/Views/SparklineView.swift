import UIKit

final class SparklineView: UIView {

    struct Series {
        let data: [Double]
        let color: UIColor
        let fillAlpha: CGFloat
    }

    private var seriesLayers: [(line: CAShapeLayer, fill: CAShapeLayer)] = []
    private var gridLayers: [CAShapeLayer] = []
    private var fixedMax: Double?
    private var lastSeries: [Series] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.background
        layer.cornerRadius = 2
        layer.borderWidth = 0.5
        layer.borderColor = Theme.border.cgColor
        clipsToBounds = true
        setupGrid()
    }

    required init?(coder: NSCoder) { fatalError() }

    func setFixedMax(_ max: Double) {
        fixedMax = max
    }

    func update(series: [Series]) {
        lastSeries = series

        while seriesLayers.count < series.count {
            let fill = CAShapeLayer()
            fill.actions = ["path": NSNull()]
            fill.lineWidth = 0
            layer.addSublayer(fill)

            let line = CAShapeLayer()
            line.actions = ["path": NSNull()]
            line.lineWidth = 1
            line.fillColor = nil
            layer.addSublayer(line)

            seriesLayers.append((line: line, fill: fill))
        }

        renderSeries(series)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Theme.graphHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let fractions: [CGFloat] = [0.25, 0.50, 0.75]
        for (i, frac) in fractions.enumerated() {
            let gl = gridLayers[i]
            gl.frame = bounds
            let y = bounds.height * frac
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: bounds.width, y: y))
            gl.path = path
        }

        for pair in seriesLayers {
            pair.line.frame = bounds
            pair.fill.frame = bounds
        }

        if !lastSeries.isEmpty {
            renderSeries(lastSeries)
        }
    }

    private func renderSeries(_ series: [Series]) {
        let bounds = self.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let sharedMax: Double
        if let fixed = fixedMax {
            sharedMax = fixed
        } else {
            var globalMax: Double = 1
            for s in series {
                if let m = s.data.max(), m > globalMax { globalMax = m }
            }
            sharedMax = globalMax
        }

        for (i, s) in series.enumerated() {
            guard !s.data.isEmpty else { continue }

            let maxVal = sharedMax

            let pair = seriesLayers[i]
            pair.line.strokeColor = s.color.cgColor
            pair.fill.fillColor = s.color.withAlphaComponent(s.fillAlpha).cgColor

            let count = s.data.count
            let step = bounds.width / CGFloat(max(count - 1, 1))

            let linePath = CGMutablePath()
            let fillPath = CGMutablePath()

            for (j, val) in s.data.enumerated() {
                let x = CGFloat(j) * step
                let y = bounds.height - (CGFloat(val / maxVal) * bounds.height)
                let clamped = min(max(y, 0), bounds.height)
                if j == 0 {
                    linePath.move(to: CGPoint(x: x, y: clamped))
                    fillPath.move(to: CGPoint(x: x, y: bounds.height))
                    fillPath.addLine(to: CGPoint(x: x, y: clamped))
                } else {
                    linePath.addLine(to: CGPoint(x: x, y: clamped))
                    fillPath.addLine(to: CGPoint(x: x, y: clamped))
                }
            }

            fillPath.addLine(to: CGPoint(x: CGFloat(count - 1) * step, y: bounds.height))
            fillPath.closeSubpath()

            pair.line.path = linePath
            pair.fill.path = fillPath
        }
    }

    private func setupGrid() {
        for _ in 0..<3 {
            let gl = CAShapeLayer()
            gl.strokeColor = Theme.border.cgColor
            gl.lineWidth = 0.5
            gl.lineDashPattern = [2, 3]
            gl.fillColor = nil
            gl.actions = ["path": NSNull()]
            layer.addSublayer(gl)
            gridLayers.append(gl)
        }
    }
}
