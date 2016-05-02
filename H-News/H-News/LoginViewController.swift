import BEMCheckBox

class LoginViewController: UIViewController {

    private let usernameField: UITextField = UITextField()
    private let passwordField: UITextField = UITextField()
    private let keepUserloggedInCheckbox = BEMCheckBox(frame: CGRectZero)
    
    override func viewDidLoad() {
        title = "Login"
        
        view.backgroundColor = UIColor.darkGrayColor()
        
        // Setup interface
        usernameField.placeholder = "Username"
        usernameField.textColor = Colors.lightGray
        usernameField.tintColor = Colors.peach
        usernameField.textAlignment = .Center
        usernameField.autocorrectionType = .No
        usernameField.clearButtonMode = .Always
        view.addSubview(usernameField)
        usernameField.snp_makeConstraints { (make) in
            make.centerX.equalTo(0)
            make.top.equalTo(100)
            make.right.equalTo(-20)
            make.left.equalTo(20)
        }
        
        passwordField.placeholder = "Password"
        passwordField.textColor = Colors.lightGray
        passwordField.textAlignment = .Center
        passwordField.tintColor = Colors.peach
        passwordField.secureTextEntry = true
        view.addSubview(passwordField)
        passwordField.snp_makeConstraints { (make) in
            make.top.equalTo(usernameField.snp_bottom).offset(20)
            make.centerX.equalTo(0)
            make.right.equalTo(-20)
            make.left.equalTo(20)
        }
        
        view.addSubview(keepUserloggedInCheckbox)
        keepUserloggedInCheckbox.snp_makeConstraints { (make) in
            make.top.equalTo(passwordField.snp_bottom).offset(20)
            make.right.equalTo(-20)
            make.size.equalTo(25)
        }
        
        let keepUserloggedInLabel = UILabel()
        keepUserloggedInLabel.text = "Stay logged in"
        keepUserloggedInLabel.textColor = Colors.lightGray
        keepUserloggedInLabel.font = UIFont.italicSystemFontOfSize(12)
        view.addSubview(keepUserloggedInLabel)
        keepUserloggedInLabel.snp_makeConstraints { (make) in
            make.right.equalTo(keepUserloggedInCheckbox.snp_left).offset(-10)
            make.centerY.equalTo(keepUserloggedInCheckbox.snp_centerY)
        }
        
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .Plain, target: self, action: #selector(LoginViewController.didTapClose))
        
        // Login button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.accept, style: .Plain, target: self, action: #selector(LoginViewController.didTapLogin))
    }
    
    func didTapClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapLogin() {
        guard let username = usernameField.text else { return }
        guard let password = passwordField.text else { return }
        
        Settings.stayloggedin = keepUserloggedInCheckbox.on
        
        let oldBarButton = navigationItem.rightBarButtonItem
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.color = Colors.peach
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        Login.login(username, password: password) { (success) in
            activityIndicator.stopAnimating()
            self.navigationItem.rightBarButtonItem = oldBarButton
            if success {
                Popover(title: "Logged in", mode: .Success).present()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                Popover(title: "Something happened..", mode: .NoInternet).present()
            }
        }
    }
}