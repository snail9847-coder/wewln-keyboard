import UIKit

final class KeyboardViewController: UIInputViewController {
    private var shifted = false
    private var numbers = false
    private let container = UIStackView()
    private let rows = UIStackView()
    private var height: NSLayoutConstraint?
    private var globe: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        container.axis = .vertical
        container.spacing = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        let title = UILabel()
        title.text = "wewln · пробелы между буквами"
        title.font = .systemFont(ofSize: 14, weight: .medium)
        title.textColor = .secondaryLabel
        title.textAlignment = .center
        title.heightAnchor.constraint(equalToConstant: 20).isActive = true
        container.addArrangedSubview(title)
        rows.axis = .vertical
        rows.spacing = 8
        rows.distribution = .fillEqually
        container.addArrangedSubview(rows)
        height = view.heightAnchor.constraint(equalToConstant: 304)
        height?.priority = .defaultHigh
        height?.isActive = true
        rebuild()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        globe?.isHidden = !needsInputModeSwitchKey
    }

    private func rebuild() {
        for row in rows.arrangedSubviews {
            rows.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        let layout = numbers
            ? ["1234567890", "-/:;()₽&@#", ".,?!'[]+=_"]
            : ["йцукенгшщзх", "фывапролджэ", "ячсмитьбюъё"]
        for line in layout {
            let row = makeRow()
            for char in line {
                let plain = String(char)
                let label = shifted && !numbers ? plain.uppercased() : plain
                row.addArrangedSubview(makeButton(label) { [weak self] in self?.type(label) })
            }
            rows.addArrangedSubview(row)
        }
        let controls = makeRow(equal: false)
        let mode = makeButton(numbers ? "АБВ" : "123", special: true) { [weak self] in
            guard let self = self else { return }
            self.numbers.toggle(); self.rebuild()
        }
        controls.addArrangedSubview(mode)
        let shift = makeButton(shifted ? "⇧•" : "⇧", special: true) { [weak self] in
            guard let self = self else { return }
            self.shifted.toggle(); self.rebuild()
        }
        shift.accessibilityLabel = "Заглавная буква"
        controls.addArrangedSubview(shift)
        let next = UIButton(type: .system)
        style(next, label: "🌐", special: true)
        next.accessibilityLabel = "Следующая клавиатура"
        next.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        next.isHidden = !needsInputModeSwitchKey
        globe = next
        controls.addArrangedSubview(next)
        let space = makeButton("пробел") { [weak self] in self?.type(" ") }
        space.titleLabel?.font = .systemFont(ofSize: 16)
        controls.addArrangedSubview(space)
        let backspace = makeButton("⌫", special: true) { [weak self] in self?.erase() }
        backspace.accessibilityLabel = "Удалить"
        controls.addArrangedSubview(backspace)
        let enter = makeButton("↵", special: true) { [weak self] in self?.type("\n") }
        enter.accessibilityLabel = "Новая строка"
        controls.addArrangedSubview(enter)
        for key in [mode, shift, next, backspace, enter] {
            let width = key.widthAnchor.constraint(equalToConstant: 44)
            width.priority = UILayoutPriority(999)
            width.isActive = true
        }
        rows.addArrangedSubview(controls)
    }

    private func makeRow(equal: Bool = true) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.distribution = equal ? .fillEqually : .fill
        return row
    }

    private func style(_ button: UIButton, label: String, special: Bool) {
        button.setTitle(label, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.backgroundColor = special ? .tertiarySystemFill : .secondarySystemGroupedBackground
        button.layer.cornerRadius = 8
        button.accessibilityLabel = label
    }

    private func makeButton(_ label: String, special: Bool = false,
                            action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        style(button, label: label, special: special)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    private func type(_ key: String) {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        textDocumentProxy.insertText(Spacing.insertion(key, before: before))
        if shifted && key.first?.isLetter == true {
            shifted = false
            rebuild()
        }
    }

    private func erase() {
        let selected = textDocumentProxy.selectedText ?? ""
        if !selected.isEmpty {
            textDocumentProxy.deleteBackward()
            return
        }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        for _ in 0..<Spacing.deleteCount(before: before) {
            textDocumentProxy.deleteBackward()
        }
    }
}
