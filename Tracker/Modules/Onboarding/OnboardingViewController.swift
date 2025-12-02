import UIKit

// MARK: - OnboardingViewController

final class OnboardingViewController: UIViewController {
    
    // MARK: - Public Callback
    
    var onNext: (() -> Void)?
    
    // MARK: - Private Properties
    
    private let page: OnboardingPage
    
    // MARK: - UI
    
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let button = UIButton(type: .system)
    
    
    // MARK: - Init
    
    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        layoutUI()
    }
    
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Фон
        backgroundImageView.image = UIImage(named: page.imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Текст
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 38
        paragraph.maximumLineHeight = 38
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping
        
        titleLabel.attributedText = NSAttributedString(
            string: page.title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor(named: "Black [day]") ?? .black,
                .paragraphStyle: paragraph
            ]
        )
        
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Кнопка
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "Black [day]") ?? .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(
            top: 19,
            left: 32,
            bottom: 19,
            right: 32
        )
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        // Добавляем UI
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(button)
    }
    
    
    // MARK: - Layout UI
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            // Фон
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 343),
            
            // Кнопка
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func nextTapped() {
        onNext?()
    }
}

