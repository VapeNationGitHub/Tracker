import UIKit

extension UIColor {
    func isEqualToColor(_ otherColor: UIColor) -> Bool {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0

        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        otherColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return (Int(r1*255) == Int(r2*255) &&
                Int(g1*255) == Int(g2*255) &&
                Int(b1*255) == Int(b2*255) &&
                Int(a1*255) == Int(a2*255))
    }
}
