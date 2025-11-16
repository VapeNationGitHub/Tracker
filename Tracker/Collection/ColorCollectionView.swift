import UIKit
import UIColorHexSwift

// MARK: - ColorCollectionView

final class ColorCollectionView: UICollectionView,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout {

    // MARK: - Data

    private let colors: [UIColor] = [
        "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
        "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
        "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
    ].map { UIColor($0) }

    private var selectedColor: UIColor?

    // MARK: - Callback

    var onColorSelected: ((UIColor) -> Void)?

    // MARK: - Init

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        super.init(frame: .zero, collectionViewLayout: layout)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        isScrollEnabled = true // без прокрутки, как в макете

        delegate = self
        dataSource = self

        register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        colors.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCell.reuseIdentifier,
            for: indexPath
        ) as? ColorCell else {
            return UICollectionViewCell()
        }

        let color = colors[indexPath.item]
        let isSelected = selectedColor?.isEqualToColor(color) ?? false
        cell.configure(with: color, selected: isSelected)
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let color = colors[indexPath.item]
        selectedColor = color
        onColorSelected?(color)
        collectionView.reloadData()
    }


    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 46, height: 46)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 8 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 8 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
