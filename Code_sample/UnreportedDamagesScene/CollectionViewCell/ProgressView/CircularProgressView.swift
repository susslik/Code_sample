//
//  CircularProgressView.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 05.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

private let lineAnimationName = "lineAnimation"

class CircularProgressView: UIView {
    private var circleLineSize: CGFloat {
        return lineSize + 2
    }

    var lineSize: CGFloat = 4 {
        didSet {
            progressLayer.lineWidth = lineSize
            circleLayer.lineWidth = circleLineSize
        }
    }

    var lineCap: CAShapeLayerLineCap = .round {
        didSet { progressLayer.lineCap = lineCap }
    }

    var progressColor: UIColor = Asset.progressColor.color {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }

    var circleColor: UIColor = Asset.progressColor.color.withAlphaComponent(0.25) {
        didSet { circleLayer.strokeColor = circleColor.cgColor }
    }

    var showEmptyPath: Bool = true {
        didSet { updateLayers() }
    }

    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = progressColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = lineSize
        layer.lineCap = lineCap
        layer.strokeEnd = 0

        return layer
    }()

    private lazy var circleLayer: CAShapeLayer = {
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = circleColor.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = circleLineSize
        circleLayer.lineCap = lineCap
        circleLayer.strokeEnd = 1

        layer.addSublayer(circleLayer)

        return circleLayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }

    func commonInit() {
        layer.addSublayer(progressLayer)
    }

    private func updateLayers() {
        let progressWidth = showEmptyPath ? circleLineSize : lineSize
        let progressPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                        radius: (frame.size.width - progressWidth) / 2,
                                        startAngle: -.pi / 2, // start is top
                                        endAngle: .pi * 1.5,
                                        clockwise: true)

        progressLayer.path = progressPath.cgPath
        progressLayer.frame = layer.bounds

        guard showEmptyPath else { return }

        let emptyCirclePath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                           radius: (frame.size.width - circleLineSize) / 2,
                                           startAngle: -.pi / 2, // start is top
                                           endAngle: .pi * 1.5,
                                           clockwise: true)

        circleLayer.path = emptyCirclePath.cgPath
        circleLayer.frame = layer.bounds
    }

    func animate(withDuration duration: Double, timeOffset: Double = 0) {
        if progressLayer.animation(forKey: lineAnimationName) != nil {
            stopAnimation()
        }

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.timeOffset = timeOffset
        animation.fromValue = CGFloat(0)
        animation.toValue = CGFloat(1)
        animation.duration = duration

        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: lineAnimationName)
    }

    func set(progress: Double) {
        progressLayer.strokeEnd = CGFloat(progress)
    }

    func stopAnimation() {
        progressLayer.removeAnimation(forKey: lineAnimationName)
        progressLayer.strokeEnd = 0
    }
}
