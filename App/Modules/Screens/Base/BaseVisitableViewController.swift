import UIKit
import WebKit
import Turbolinks

/*!
 A VisitableViewController which handles NSError and also sets a dismiss button on presented view controllers
 */
class BaseVisitableViewController: Turbolinks.VisitableViewController, UIScrollViewDelegate{

    let pathsToAvoidDismissButton : [String?] = [
    ]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDismissButton()
        
        //Disable zoom
        visitableView.webView?.scrollView.pinchGestureRecognizer?.enabled = false
        
        //Disable pull to refresh
        visitableView.webView?.scrollView.bounces = false
        
        self.navigationController!.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
    }

    
    // MARK: Visitable
    override func visitableDidRender() {
        let title = visitableView.webView?.title
        self.navigationItem.title = title
    }
    
    // MARK: dismiss
    private func setupDismissButton() {
        if isModal() && navigationController?.viewControllers.count == 1 && !pathsToAvoidDismissButton.contains({$0 == visitableURL.path}) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(didTouchCancel))
        }
    }
    
    func didTouchCancel() {
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: Error
    func handleError(error: NSError) {
        guard let errorCode = ErrorCode(rawValue: error.code) else {
            presentError(.UnknownError)
            return
        }

        switch errorCode {
        case .HTTPFailure:
            guard let statusCode = error.userInfo["statusCode"] as? Int else {
                presentError(.UnknownError)
                return
            }
            switch statusCode {
            case 404:
                presentError(.HTTPNotFoundError)
            default:
                presentError(Error(HTTPStatusCode: statusCode))
            }
        case .NetworkFailure:
            presentError(.NetworkError)
            
        }
    }
    
    private func presentError(error: Error) {
        errorView.error = error
        view.addSubview(errorView)
        installErrorViewConstraints()
    }
    
    
    private lazy var errorView: ErrorView = {
        guard let view = NSBundle.mainBundle().loadNibNamed("ErrorView", owner: self, options: nil)?.first as? ErrorView else {
            return ErrorView()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.retryButton.addTarget(self, action: #selector(retry(_:)), forControlEvents: .TouchUpInside)
        return view
    }()
    
    private func installErrorViewConstraints() {
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
    }
    
    @objc private func retry(sender: AnyObject) {
        errorView.removeFromSuperview()
        reloadVisitable()
    }
}
