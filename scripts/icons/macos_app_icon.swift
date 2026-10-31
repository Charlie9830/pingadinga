// Renders the macOS app icon (a redesign of windows_resources/msix_logo_512px.png
// to the macOS Big Sur+ icon grid) into every size AppIcon.appiconset needs.
//
//   swift scripts/icons/macos_app_icon.swift <output directory>
//
// Everything is drawn as vectors on a 1024pt canvas and rasterised natively at
// each size, so the small icons are not blurry downscales of the large one.

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
  CGColor(
    srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
    green: CGFloat((hex >> 8) & 0xFF) / 255,
    blue: CGFloat(hex & 0xFF) / 255,
    alpha: alpha)
}

func gradient(_ colors: [CGColor], _ locations: [CGFloat]? = nil) -> CGGradient {
  CGGradient(
    colorsSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
    colors: colors as CFArray, locations: locations)!
}

/// Apple's icon tile: 824pt with a ~185pt corner radius.
func tileShape(_ rect: CGRect) -> CGPath {
  CGPath(roundedRect: rect, cornerWidth: 185, cornerHeight: 185, transform: nil)
}

// Geometry, in a y-down 1024pt space.
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
let monitor = CGRect(x: 180, y: 330, width: 520, height: 360)
let screen = monitor.insetBy(dx: 26, dy: 26)
let lensCenter = CGPoint(x: 690, y: 330)
let lensRadius: CGFloat = 125
let rimWidth: CGFloat = 32
let handleStart = CGPoint(x: lensCenter.x + 82, y: lensCenter.y + 82)
let handleEnd = CGPoint(x: 846, y: 486)
let chart: [CGPoint] = [
  CGPoint(x: 250, y: 580), CGPoint(x: 330, y: 480), CGPoint(x: 410, y: 575),
  CGPoint(x: 495, y: 440), CGPoint(x: 590, y: 560),
]

func draw(_ ctx: CGContext, scale: CGFloat) {
  // Shadow offsets and blurs ignore the CTM, so scale them by hand.
  func shadow(y: CGFloat, blur: CGFloat, alpha: CGFloat) {
    ctx.setShadow(
      offset: CGSize(width: 0, height: -y * scale), blur: blur * scale,
      color: rgb(0x000000, alpha))
  }

  let tilePath = tileShape(tile)
  func fillTileBackground() {
    ctx.drawLinearGradient(
      gradient([rgb(0x3FA9F5), rgb(0x1C6FCF), rgb(0x0B3B8C)], [0, 0.5, 1]),
      start: CGPoint(x: tile.minX, y: tile.minY), end: CGPoint(x: tile.maxX, y: tile.maxY),
      options: [])
    // Soft top sheen.
    ctx.drawLinearGradient(
      gradient([rgb(0xFFFFFF, 0.18), rgb(0xFFFFFF, 0)]),
      start: CGPoint(x: 0, y: tile.minY), end: CGPoint(x: 0, y: tile.midY), options: [])
  }

  // Tile with the standard macOS drop shadow.
  ctx.saveGState()
  shadow(y: 10, blur: 20, alpha: 0.3)
  ctx.addPath(tilePath)
  ctx.setFillColor(rgb(0x1C6FCF))
  ctx.fillPath()
  ctx.restoreGState()

  ctx.saveGState()
  ctx.addPath(tilePath)
  ctx.clip()
  fillTileBackground()
  ctx.restoreGState()

  ctx.saveGState()
  ctx.addPath(tilePath)
  ctx.clip()
  ctx.addPath(tilePath)
  ctx.setStrokeColor(rgb(0xFFFFFF, 0.22))
  ctx.setLineWidth(4)
  ctx.strokePath()
  ctx.restoreGState()

  ctx.saveGState()
  ctx.addPath(tilePath)
  ctx.clip()

  // Monitor: bezel, screen, neck and base, shadowed as one group.
  let bezelFill = gradient([rgb(0xFFFFFF), rgb(0xDCE6F2)])
  ctx.saveGState()
  shadow(y: 12, blur: 24, alpha: 0.28)
  ctx.beginTransparencyLayer(auxiliaryInfo: nil)

  let stand = CGMutablePath()
  stand.move(to: CGPoint(x: 395, y: monitor.maxY - 4))
  stand.addLine(to: CGPoint(x: 485, y: monitor.maxY - 4))
  stand.addLine(to: CGPoint(x: 505, y: 770))
  stand.addLine(to: CGPoint(x: 375, y: 770))
  stand.closeSubpath()
  stand.addPath(
    CGPath(
      roundedRect: CGRect(x: 330, y: 760, width: 220, height: 36),
      cornerWidth: 18, cornerHeight: 18, transform: nil))
  stand.addPath(
    CGPath(roundedRect: monitor, cornerWidth: 40, cornerHeight: 40, transform: nil))
  ctx.addPath(stand)
  ctx.clip()
  ctx.drawLinearGradient(
    bezelFill, start: CGPoint(x: 0, y: monitor.minY), end: CGPoint(x: 0, y: 796), options: [])
  ctx.endTransparencyLayer()
  ctx.restoreGState()

  let screenPath = CGPath(roundedRect: screen, cornerWidth: 18, cornerHeight: 18, transform: nil)
  ctx.saveGState()
  ctx.addPath(screenPath)
  ctx.clip()
  ctx.drawLinearGradient(
    gradient([rgb(0x13355F), rgb(0x0A1C38)]),
    start: CGPoint(x: 0, y: screen.minY), end: CGPoint(x: 0, y: screen.maxY), options: [])

  // Faint grid.
  ctx.setStrokeColor(rgb(0xFFFFFF, 0.07))
  ctx.setLineWidth(4)
  for y in stride(from: screen.minY + 77, to: screen.maxY, by: 77) {
    ctx.move(to: CGPoint(x: screen.minX, y: y))
    ctx.addLine(to: CGPoint(x: screen.maxX, y: y))
  }
  ctx.strokePath()

  // Area under the line.
  let area = CGMutablePath()
  area.addLines(between: chart)
  area.addLine(to: CGPoint(x: chart.last!.x, y: screen.maxY))
  area.addLine(to: CGPoint(x: chart.first!.x, y: screen.maxY))
  area.closeSubpath()
  ctx.saveGState()
  ctx.addPath(area)
  ctx.clip()
  ctx.drawLinearGradient(
    gradient([rgb(0x4FD8FF, 0.35), rgb(0x4FD8FF, 0)]),
    start: CGPoint(x: 0, y: 440), end: CGPoint(x: 0, y: screen.maxY), options: [])
  ctx.restoreGState()

  // The line itself, cyan to mint.
  ctx.saveGState()
  let line = CGMutablePath()
  line.addLines(between: chart)
  ctx.addPath(line.copy(strokingWithWidth: 24, lineCap: .round, lineJoin: .round, miterLimit: 10))
  ctx.clip()
  ctx.drawLinearGradient(
    gradient([rgb(0x5FE0FF), rgb(0x6CF5B8)]),
    start: CGPoint(x: chart.first!.x, y: 0), end: CGPoint(x: chart.last!.x, y: 0), options: [])
  ctx.restoreGState()

  for p in chart {
    ctx.setFillColor(rgb(0xFFFFFF))
    ctx.fillEllipse(in: CGRect(x: p.x - 21, y: p.y - 21, width: 42, height: 42))
    ctx.setFillColor(rgb(0x0F2A4E))
    ctx.fillEllipse(in: CGRect(x: p.x - 9, y: p.y - 9, width: 18, height: 18))
  }
  ctx.restoreGState()

  // Magnifier outline, used both to cut a gap into the monitor and to draw it.
  let lensDisc = CGPath(
    ellipseIn: CGRect(
      x: lensCenter.x - lensRadius, y: lensCenter.y - lensRadius,
      width: lensRadius * 2, height: lensRadius * 2), transform: nil)
  let handle = CGMutablePath()
  handle.move(to: handleStart)
  handle.addLine(to: handleEnd)
  // The gap only needs to follow the handle outside the lens.
  let handleOutside = CGMutablePath()
  handleOutside.move(to: CGPoint(x: lensCenter.x + lensRadius * 0.75, y: lensCenter.y + lensRadius * 0.75))
  handleOutside.addLine(to: handleEnd)
  let gap: CGFloat = 20
  let magnifierOutline = CGMutablePath()
  magnifierOutline.addPath(
    lensDisc.copy(strokingWithWidth: gap * 2, lineCap: .round, lineJoin: .round, miterLimit: 10))
  magnifierOutline.addPath(lensDisc)
  magnifierOutline.addPath(
    handleOutside.copy(
      strokingWithWidth: 54 + gap * 2, lineCap: .round, lineJoin: .round, miterLimit: 10))

  ctx.saveGState()
  ctx.addPath(magnifierOutline)
  ctx.clip()
  fillTileBackground()
  ctx.restoreGState()

  // Glass.
  ctx.saveGState()
  ctx.addPath(lensDisc)
  ctx.clip()
  ctx.drawLinearGradient(
    gradient([rgb(0xFFFFFF, 0.30), rgb(0xFFFFFF, 0.08)]),
    start: CGPoint(x: lensCenter.x - lensRadius, y: lensCenter.y - lensRadius),
    end: CGPoint(x: lensCenter.x + lensRadius, y: lensCenter.y + lensRadius), options: [])
  ctx.restoreGState()

  // Rim, handle and Wi-Fi glyph, shadowed as one group.
  ctx.saveGState()
  shadow(y: 10, blur: 22, alpha: 0.3)
  ctx.beginTransparencyLayer(auxiliaryInfo: nil)
  let solid = CGMutablePath()
  let rimRadius = lensRadius - rimWidth / 2
  let rim = CGPath(
    ellipseIn: CGRect(
      x: lensCenter.x - rimRadius, y: lensCenter.y - rimRadius,
      width: rimRadius * 2, height: rimRadius * 2), transform: nil)
  solid.addPath(rim.copy(strokingWithWidth: rimWidth, lineCap: .round, lineJoin: .round, miterLimit: 10))
  solid.addPath(handle.copy(strokingWithWidth: 54, lineCap: .round, lineJoin: .round, miterLimit: 10))

  let dot = CGPoint(x: lensCenter.x, y: lensCenter.y + 42)
  solid.addEllipse(in: CGRect(x: dot.x - 19, y: dot.y - 19, width: 38, height: 38))
  for radius: CGFloat in [52, 92] {
    let arc = CGMutablePath()
    arc.addArc(
      center: dot, radius: radius, startAngle: -.pi * 3 / 4, endAngle: -.pi / 4, clockwise: false)
    solid.addPath(arc.copy(strokingWithWidth: 24, lineCap: .round, lineJoin: .round, miterLimit: 10))
  }
  ctx.addPath(solid)
  ctx.clip()
  ctx.drawLinearGradient(
    bezelFill, start: CGPoint(x: 0, y: lensCenter.y - lensRadius), end: CGPoint(x: 0, y: handleEnd.y),
    options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
  ctx.endTransparencyLayer()
  ctx.restoreGState()

  ctx.restoreGState()
}

func render(pixels: Int, to url: URL) {
  let ctx = CGContext(
    data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  let scale = CGFloat(pixels) / 1024
  ctx.translateBy(x: 0, y: CGFloat(pixels))
  ctx.scaleBy(x: scale, y: -scale)
  ctx.setShouldAntialias(true)
  draw(ctx, scale: scale)

  let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
  guard CGImageDestinationFinalize(dest) else { fatalError("could not write \(url.path)") }
}

let args = CommandLine.arguments
guard args.count == 2 else {
  FileHandle.standardError.write("usage: swift macos_app_icon.swift <output directory>\n".data(using: .utf8)!)
  exit(64)
}
let out = URL(fileURLWithPath: args[1], isDirectory: true)
for pixels in [16, 32, 64, 128, 256, 512, 1024] {
  render(pixels: pixels, to: out.appendingPathComponent("app_icon_\(pixels).png"))
}
