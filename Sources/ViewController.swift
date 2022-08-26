import UIKit

final class ViewController: UIViewController {
    
    private var width: CGFloat = 200
    private var height: CGFloat = 300
    
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    private lazy var cornerView = SmoothCornerRadiusView(
        colorBehindView: .black,
        colorInsideOfCorners: .white.withAlphaComponent(0.3),
        cornerRadius: 0,
        frame: .zero
    )
    
    private lazy var cornerRadiusSlider = UISlider(frame: .zero)..{
        $0.minimumValue = 0
        $0.maximumValue = 50
        $0.isContinuous = true
        $0.tintColor = .green
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
    }
    
    private lazy var smoothCornerSwitch = UISwitch(frame: .zero)..{
        $0.setOn(false, animated: false)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black

        view.addSubview(cornerView)
        
        cornerView.translatesAutoresizingMaskIntoConstraints = false
        cornerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cornerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        widthConstraint = cornerView.widthAnchor.constraint(equalToConstant: width)
        widthConstraint?.isActive = true
        
        heightConstraint = cornerView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.isActive = true
        
        view.addSubview(cornerRadiusSlider)
        
        cornerRadiusSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cornerRadiusSlider.topAnchor.constraint(equalTo: cornerView.bottomAnchor, constant: 50).isActive = true
        cornerRadiusSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        cornerRadiusSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        view.addSubview(smoothCornerSwitch)
        smoothCornerSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        smoothCornerSwitch.topAnchor.constraint(equalTo: cornerRadiusSlider.bottomAnchor, constant: 50).isActive = true
        smoothCornerSwitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        smoothCornerSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func sliderValueDidChange(_ sender: UISlider!) {
        let percentage = sender.value
        
        cornerView.cornerRadius = width * CGFloat(percentage) / 100
    }
    
    @objc private func switchStateDidChange(_ sender: UISwitch!) {
        cornerView.useSmoothCorners = sender.isOn
    }

}
