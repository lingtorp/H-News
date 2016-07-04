class HNDonateViewController: UIViewController {
    
    override func viewDidLoad() {
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Icons.dismiss, style: .Plain, target: self, action: #selector(HNDonateViewController.didTapClose))
    }
    
    func didTapClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}