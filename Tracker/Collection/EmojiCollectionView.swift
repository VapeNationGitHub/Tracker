import UIKit

// MARK: - EmojiCollectionView

final class EmojiCollectionView: UICollectionView,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout {
    
    // MARK: - Data
    
    private let emojis = [
        "🙂", "😍", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😴"
    ]
    
    private var selectedEmoji: String?
    
    // MARK: - Callback
    
    var onEmojiSelected: ((String) -> Void)?
    
    // MARK: - Init
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        dataSource = self
        register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiCell else {
            return UICollectionViewCell()
        }
        
        let emoji = emojis[indexPath.item]
        let isSelected = emoji == selectedEmoji
        cell.configure(with: emoji, selected: isSelected)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let emoji = emojis[indexPath.item]
        selectedEmoji = emoji
        onEmojiSelected?(emoji)
        reloadData()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Размер ячейки
        return CGSize(width: 46, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8 // горизонтальный отступ
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8 // вертикальный отступ
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
}
