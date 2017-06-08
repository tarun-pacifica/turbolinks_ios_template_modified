import UIKit
import WebKit
import Turbolinks

/*!
 A VisitableViewController which handles NSError and also sets a dismiss button on presented view controllers
 */
class BaseVisitableViewController: Turbolinks.VisitableViewController, UIScrollViewDelegate{

    let pathsToAvoidDismissButton : [String?] = [
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDismissButton()
        
        //Disable zoom
        visitableView.webView?.scrollView.pinchGestureRecognizer?.isEnabled = false
        
        //Disable pull to refresh
        visitableView.webView?.scrollView.bounces = false
        
        self.navigationController!.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.white ]
    }

    
    // MARK: Visitable
    override func visitableDidRender() {
        let title = visitableView.webView?.title
        self.navigationItem.title = title
    }
    
    // MARK: dismiss
    fileprivate func setupDismissButton() {
        if isModal() && navigationController?.viewControllers.count == 1 && !pathsToAvoidDismissButton.contains(where: {$0 == visitableURL.path}) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTouchCancel))
        }
    }
    
    func didTouchCancel() {
        
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: Error
    func handleError(_ error: NSError) {
        guard let errorCode = ErrorCode(rawValue: error.code) else {
            presentError(.UnknownError)
            return
        }

        switch errorCode {
        case .httpFailure:
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
        case .networkFailure:
            presentError(.NetworkError)
            
        }
    }
    
    fileprivate func presentError(_ error: Error) {
        errorView.error = error
        view.addSubview(errorView)
        installErrorViewConstraints()
    }
    
    
    fileprivate lazy var errorView: ErrorView = {
        guard let view = Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)?.first as? ErrorView else {
            return ErrorView()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.retryButton.addTarget(self, action: #selector(retry(_:)), for: .touchUpInside)
        return view
    }()
    
    fileprivate func installErrorViewConstraints() {
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
    }
    
    @objc fileprivate func retry(_ sender: AnyObject) {
        errorView.removeFromSuperview()
        reloadVisitable()
    }
}
