class HNewsLoginViewController: UIViewController {

    private let usernameField: UITextField = UITextField()
    private let passwordField: UITextField = UITextField()
    private let imagebackground: UIImageView = UIImageView()
    private let loginButton: UIButton = UIButton()
    
    override func viewDidLoad() {
        
        // Setup background
        imagebackground.image = Icons.loginBackground
        view.addSubview(imagebackground)
        imagebackground.snp_makeConstraints { (make) in
            make.center.equalTo(0)
        }
    }
}