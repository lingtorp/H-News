import BEMCheckBox

class LoginViewController: UIViewController {

    fileprivate let usernameField: UITextField = UITextField()
    fileprivate let passwordField: UITextField = UITextField()
    fileprivate let keepUserloggedInCheckbox = BEMCheckBox(frame: CGRect.zero)
    
    override func viewDidLoad() {
        title = "Login"
        
        view.backgroundColor = UIColor.darkGray
        
        // Setup interface
        usernameField.placeholder = "Username"
        usernameField.textColor = Colors.lightGray
        usernameField.tintColor = Colors.peach
        usernameField.textAlignment = .center
        usernameField.autocorrectionType = .no
        usernameField.clearButtonMode = .always
        view.addSubview(usernameField)
        usernameField.snp.makeConstraints { (make) in
            make.centerX.equalTo(0)
            make.top.equalTo(100)
            make.right.equalTo(-20)
            make.left.equalTo(20)
        }
        
        passwordField.placeholder = "Password"
        passwordField.textColor = Colors.lightGray
        passwordField.textAlignment = .center
        passwordField.tintColor = Colors.peach
        passwordField.isSecureTextEntry = true
        view.addSubview(passwordField)
        passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameField.snp.bottom).offset(20)
            make.centerX.equalTo(0)
            make.right.equalTo(-20)
            make.left.equalTo(20)
        }
        
        view.addSubview(keepUserloggedInCheckbox)
        keepUserloggedInCheckbox.snp.makeConstraints { (make) in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.right.equalTo(-20)
            make.size.equalTo(25)
        }
        
        let keepUserloggedInLabel = UILabel()
        keepUserloggedInLabel.text = "Stay logged in"
        keepUserloggedInLabel.textColor = Colors.lightGray
        keepUserloggedInLabel.font = UIFont.italicSystemFont(ofSize: 12)
        view.addSubview(keepUserloggedInLabel)
        keepUserloggedInLabel.snp.makeConstraints { (make) in
            make.right.equalTo(keepUserloggedInCheckbox.snp.left).offset(-10)
            make.centerY.equalTo(keepUserloggedInCheckbox.snp.centerY)
        }
        
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .plain, target: self, action: #selector(LoginViewController.didTapClose))
        
        // Login button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.accept, style: .plain, target: self, action: #selector(LoginViewController.didTapLogin))
    }
    
    func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func didTapLogin() {
        guard let username = usernameField.text else { return }
        guard let password = passwordField.text else { return }
        
        Settings.stayloggedin = keepUserloggedInCheckbox.on
        
        let oldBarButton = navigationItem.rightBarButtonItem
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.color = Colors.peach
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        Login.login(username, password: password) { (success) in
            activityIndicator.stopAnimating()
            self.navigationItem.rightBarButtonItem = oldBarButton
            if success {
                Popover(title: "Logged in", mode: .success).present()
                self.dismiss(animated: true, completion: nil)
            } else {
                Popover(title: "Something happened..", mode: .noInternet).present()
            }
        }
    }
}
