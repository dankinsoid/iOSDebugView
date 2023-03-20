import ColorizeSwift
import SwiftPrettyPrint
import UIKit

extension String {

	func colorizedAttributed(font: UIFont = .systemFont(ofSize: 14)) -> NSAttributedString {
		let mutableString = NSMutableAttributedString(string: self, attributes: [.font: font])
		guard let regex = try? NSRegularExpression(pattern: "\\\u{001B}\\[([0-9;]+)m") else { return mutableString }

		let matches = regex.matches(in: self, range: NSRange(0 ..< count)).compactMap {
			Range($0.range, in: self)
		}

		var prevRange: Range = startIndex ..< startIndex
		var styles: [String] = []
		for range in matches {
			let style = String(self[range])
			if range.lowerBound > prevRange.upperBound {
				let nsRange = NSRange(prevRange.upperBound ..< range.lowerBound, in: self)
				mutableString.addAttributes(attributes(for: styles, font: font), range: nsRange)
				styles = [style]
			} else {
				styles.append(style)
			}
			prevRange = range
		}
		for range in matches.reversed() {
			mutableString.replaceCharacters(in: NSRange(range, in: self), with: "")
		}
		return mutableString
	}

	private func attributes(for styles: [String], font: UIFont) -> [NSAttributedString.Key: Any] {
		Dictionary(
			styles.compactMap { attribute(for: $0, font: font) }
		) { _, p in
			p
		}
	}

	private func attribute(for style: String, font: UIFont) -> (NSAttributedString.Key, Any)? {
		switch style {
		case TerminalStyle.bold.open: return (.font, font.bold())
		case TerminalStyle.dim.open: return nil
		case TerminalStyle.italic.open: return (.font, font.italics())
		case TerminalStyle.underline.open: return (.underlineStyle, NSUnderlineStyle.single.rawValue)
		case TerminalStyle.blink.open: return nil
		case TerminalStyle.reverse.open: return nil
		case TerminalStyle.hidden.open: return nil
		case TerminalStyle.strikethrough.open: return (.strikethroughStyle, NSUnderlineStyle.single.rawValue)
		case TerminalStyle.reset.open: return nil
		case TerminalStyle.black.open: return (.foregroundColor, UIColor.black)
		case TerminalStyle.red.open: return (.foregroundColor, UIColor.systemRed)
		case TerminalStyle.green.open: return (.foregroundColor, UIColor.systemGreen)
		case TerminalStyle.yellow.open: return (.foregroundColor, UIColor.systemYellow)
		case TerminalStyle.blue.open: return (.foregroundColor, UIColor.systemBlue)
		case TerminalStyle.magenta.open: return (.foregroundColor, UIColor.magenta)
		case TerminalStyle.cyan.open: return (.foregroundColor, UIColor(displayP3Red: 102 / 255, green: 1, blue: 1, alpha: 1.0))
		case TerminalStyle.lightGray.open: return (.foregroundColor, UIColor.lightGray)
		case TerminalStyle.darkGray.open: return (.foregroundColor, UIColor.darkGray)
		case TerminalStyle.lightRed.open: return (.foregroundColor, UIColor(displayP3Red: 1, green: 76 / 255, blue: 91 / 255, alpha: 1.0))
		case TerminalStyle.lightGreen.open: return (.foregroundColor, UIColor(displayP3Red: 58 / 255, green: 222 / 255, blue: 58 / 255, alpha: 1.0))
		case TerminalStyle.lightYellow.open: return (.foregroundColor, UIColor(displayP3Red: 1, green: 1, blue: 20 / 255, alpha: 1.0))
		case TerminalStyle.lightBlue.open: return (.foregroundColor, UIColor(displayP3Red: 58 / 255, green: 222 / 255, blue: 58 / 255, alpha: 1.0))
		case TerminalStyle.lightMagenta.open: return (.foregroundColor, UIColor(displayP3Red: 1, green: 51 / 255, blue: 1, alpha: 1.0))
		case TerminalStyle.lightCyan.open: return (.foregroundColor, UIColor(displayP3Red: 51 / 255, green: 204 / 255, blue: 1, alpha: 1.0))
		case TerminalStyle.white.open: return (.foregroundColor, UIColor.white)
		case TerminalStyle.onBlack.open: return (.backgroundColor, UIColor.black)
		case TerminalStyle.onRed.open: return (.backgroundColor, UIColor.systemRed)
		case TerminalStyle.onGreen.open: return (.backgroundColor, UIColor.systemGreen)
		case TerminalStyle.onYellow.open: return (.backgroundColor, UIColor.systemYellow)
		case TerminalStyle.onBlue.open: return (.backgroundColor, UIColor.systemBlue)
		case TerminalStyle.onMagenta.open: return (.backgroundColor, UIColor.magenta)
		case TerminalStyle.onCyan.open: return (.backgroundColor, UIColor(displayP3Red: 102 / 255, green: 1, blue: 1, alpha: 1.0))
		case TerminalStyle.onLightGray.open: return (.backgroundColor, UIColor.lightGray)
		case TerminalStyle.onDarkGray.open: return (.backgroundColor, UIColor.darkGray)
		case TerminalStyle.onLightRed.open: return (.backgroundColor, UIColor(displayP3Red: 1, green: 76 / 255, blue: 91 / 255, alpha: 1.0))
		case TerminalStyle.onLightGreen.open: return (.backgroundColor, UIColor(displayP3Red: 58 / 255, green: 222 / 255, blue: 58 / 255, alpha: 1.0))
		case TerminalStyle.onLightYellow.open: return (.backgroundColor, UIColor(displayP3Red: 1, green: 1, blue: 20 / 255, alpha: 1.0))
		case TerminalStyle.onLightBlue.open: return (.backgroundColor, UIColor(displayP3Red: 58 / 255, green: 222 / 255, blue: 58 / 255, alpha: 1.0))
		case TerminalStyle.onLightMagenta.open: return (.backgroundColor, UIColor(displayP3Red: 1, green: 51 / 255, blue: 1, alpha: 1.0))
		case TerminalStyle.onLightCyan.open: return (.backgroundColor, UIColor(displayP3Red: 51 / 255, green: 204 / 255, blue: 1, alpha: 1.0))
		case TerminalStyle.onWhite.open: return (.backgroundColor, UIColor.white)
		default: return nil
		}
	}
}

extension Pretty {

	static func prettyAttributedString(for value: Any, font: UIFont = .systemFont(ofSize: 14)) -> NSAttributedString {
		var string = ""
		prettyPrint(value, option: Option(colored: true), to: &string)
		return string.colorizedAttributed(font: font)
	}

	static func prettyString(for value: Any) -> String {
		var string = ""
		prettyPrint(value, option: Option(colored: true), to: &string)
		return string
	}
}

extension Data {

	var prettyPrintedJSONString: String {
		guard
			let object = try? JSONSerialization.jsonObject(with: self, options: []),
			let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
			let prettyPrintedString = String(data: data, encoding: .utf8)
		else {
			return ""
		}

		return prettyPrintedString
	}
}

extension UIFont {

	func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {

		// create a new font descriptor with the given traits
		guard let fd = fontDescriptor.withSymbolicTraits(traits) else {
			// the given traits couldn't be applied, return self
			return self
		}

		// return a new font with the created font descriptor
		return UIFont(descriptor: fd, size: pointSize)
	}

	func italics() -> UIFont {
		withTraits(.traitItalic)
	}

	func bold() -> UIFont {
		withTraits(.traitBold)
	}

	func boldItalics() -> UIFont {
		withTraits([.traitBold, .traitItalic])
	}
}
