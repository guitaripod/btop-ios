import UIKit

final class BarView: UIView {

    struct Segment {
        let value: Double
        let color: UIColor
    }

    private var segments: [Segment] = []
    private var trailingText: String?
    private var trailingColor: UIColor = Theme.textPrimary

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(segments: [Segment], trailingText: String? = nil, trailingColor: UIColor = Theme.textPrimary) {
        self.segments = segments
        self.trailingText = trailingText
        self.trailingColor = trailingColor
        setNeedsDisplay()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Theme.barHeight)
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let textWidth: CGFloat = trailingText != nil ? 50 : 0
        let barWidth = rect.width - textWidth
        let barRect = CGRect(x: 0, y: 0, width: barWidth, height: rect.height)

        ctx.saveGState()
        let path = UIBezierPath(roundedRect: barRect, cornerRadius: 2)
        ctx.addPath(path.cgPath)
        ctx.clip()

        Theme.border.setFill()
        ctx.fill(barRect)

        var x: CGFloat = 0
        for seg in segments {
            let w = CGFloat(seg.value / 100.0) * barWidth
            if w > 0 {
                seg.color.setFill()
                ctx.fill(CGRect(x: x, y: 0, width: w, height: rect.height))
                x += w
            }
        }
        ctx.restoreGState()

        if let text = trailingText {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: Theme.fontSmall,
                .foregroundColor: trailingColor,
            ]
            let str = text as NSString
            let size = str.size(withAttributes: attrs)
            let textX = barWidth + (textWidth - size.width) / 2
            let textY = (rect.height - size.height) / 2
            str.draw(at: CGPoint(x: textX, y: textY), withAttributes: attrs)
        }
    }
}
