class HNewsLoginViewController: UIViewController {

    private let usernameField: UITextField = UITextField()
    private let passwordField: UITextField = UITextField()
    
    override func loadView() {
        super.loadView()
        

    }
    
    override func viewDidLoad() {
        title = "Login"
        
        view.backgroundColor = UIColor.darkGrayColor()
        
        // Setup interface
        usernameField.placeholder = "Username"
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
        
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .Plain, target: self, action: "didTapClose")
        
        // Login button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icons.accept, style: .Plain, target: self, action: "didTapLogin")
    }
    
    func didTapClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapLogin() {
        print("Did tap login")
    }
}