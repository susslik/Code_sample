//
//  UIImage+Compression.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 09.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

private let maxWidth: CGFloat = 1242
private let maxHeight: CGFloat = 2208

private let jpegQuality: CGFloat = 0.95

extension UIImage {
    var compressedData: Data? {
        return fixedOrientation()?
            .resizeToMaxWidth(maxWidth, maxHeight: maxHeight)?
            .jpegData(compressionQuality: jpegQuality)
    }

    private func resizeToMaxWidth(_ maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage? {
        if maxWidth >= size.width,
            maxHeight >= size.height {
            return self
        }

        var newWidth: CGFloat
        var newHeight: CGFloat

        let ratio = max(size.width / maxWidth, size.height / maxHeight)
        newHeight = round(size.height / ratio)
        newWidth = round(size.width / ratio)

        let rect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: newWidth, height: newHeight)

        UIGraphicsBeginImageContext(rect.size)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func fixedOrientation() -> UIImage? {
        // This is default orientation, don't need to do anything
        guard imageOrientation != .up else { return self }
        
        guard let cgImage = self.cgImage else { return nil }

        guard
            let colorSpace = cgImage.colorSpace,
            let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                                space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            return nil // Not able to create CGContext
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
