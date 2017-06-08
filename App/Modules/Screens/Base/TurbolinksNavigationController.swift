import UIKit
import WebKit
import Turbolinks

/*!
 This is the TurbolinksNavigationController, which contains a Turbolinks Session object
 Use it to push Turbolinks.VisitableViewController
 */
class TurbolinksNavigationController: UINavigationController {
    // URL to be visited
    fileprivate var URL : Foundation.URL;
    
    // whether this view controller should be reloaded or not on viewWillAppear.
    fileprivate var shouldReloadOnAppear : Bool = false;
    
    fileprivate lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()
    
    
    fileprivate lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = AppDelegate.webViewProcessPool
        configuration.applicationNameForUserAgent = K.Session.AppNameForUserAgent
        return configuration
    }()
    
    // MARK: public
    func reset() {
        session.reload()
        session.webView.reloadFromOrigin()
    }
    
    func visit(_ URL: Foundation.URL) {
        showVisitableForSession(session, URL: URL)
    }
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        self.URL = Foundation.URL(string: Domain)!
        super.init(coder: aDecoder)
    }
    
    init(url: Foundation.URL) {
        self.URL = url;
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationCenterObservers()
        showVisitableForSession(session, URL: URL)
        

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldReloadOnAppear {
            session.reload()
            shouldReloadOnAppear = false
        }
    }
    
    deinit {
        removeNotificationCenterObservers()
    }
    
    
    fileprivate func removeNotificationCenterObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func handleDismissedForm() {
        shouldReloadOnAppear = true
    }

    // MARK: other
    fileprivate func showVisitableForSession(_ session: Session, URL: Foundation.URL, action: Action = .Advance) {
        guard URL.path != nil else {
            return
        }
        
        if URL.description.lowercased().range(of: "http://") != nil || URL.description.lowercased().range(of: "https://") != nil {
            showVisitableViewControllerWithUrl(URL, action: action)
        } else {
            UIApplication.shared.openURL(URL)
        }
        
    }
    
    fileprivate func addNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDismissedForm), name: NSNotification.Name(rawValue: K.NotificationCenter.hasDismissedForm), object: nil)
    }
    
    fileprivate func showVisitableViewControllerWithUrl(_ URL: Foundation.URL, action: Action) {
        
        let visitable : BaseVisitableViewController = BaseVisitableViewController(url: URL)
        
        switch action {
        case .Advance:
            pushViewController(visitable, animated: true)
        
        case .Replace:
            
            if viewControllers.count == 1 {
                setViewControllers([visitable], animated: false)
            } else {
                popViewController(animated: false)
                pushViewController(visitable, animated: false)
            }
        case .Restore:
            // from the [docs](https://github.com/turbolinks/turbolinks#restoration-visits):
            // > Restoration visits have an action of restore and Turbolinks reserves them for internal use. You should not attempt to annotate links or invoke Turbolinks.visit with an action of restore.
            break
        }
        session.visit(visitable)
    }
}

extension TurbolinksNavigationController: SessionDelegate {
    
    
    func session(_ session: Session, didProposeVisitToURL URL: Foundation.URL, withAction action: Action) {

        if shouldChangeNavigationTab(URL){

            switch(URL.path){
            case K.URL.Tab1.path:
                self.tabBarController?.selectedIndex = 0
            case K.URL.Tab2.path:
                self.tabBarController?.selectedIndex = 1
            case K.URL.Tab3.path:
                self.tabBarController?.selectedIndex = 2
            case K.URL.Tab4.path:
                self.tabBarController?.selectedIndex = 3
            case K.URL.Tab5.path:
                self.tabBarController?.selectedIndex = 4
            default:
                return
            }
            return
        }
        
        if shouldBeDismissedFromURL(self.URL, toURL:URL) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: K.NotificationCenter.hasDismissedForm), object: nil)
            dismiss(animated: true, completion: {})
            return
        }

        if shouldBePresentedFromURL(self.URL, toURL:URL) {
            presentViewController(URL)
            return
        }
        showVisitableForSession(session, URL: URL, action: action)
        
    }
    
    func session(_ session: Session){
        
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        guard let visitableViewController = visitable as? BaseVisitableViewController else { return }
        visitableViewController.handleError(error)
        
    }
    
    func session(_ session: Session, openExternalURL URL: Foundation.URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL)
        }
    }
    
    func sessionDidStartRequest(_ session: Session) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func sessionDidFinishRequest(_ session: Session) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    fileprivate func shouldChangeNavigationTab(_ toURL: Foundation.URL) -> Bool {
        return toURL == K.URL.Tab1 || toURL == K.URL.Tab2 || toURL == K.URL.Tab3 || toURL == K.URL.Tab4 || toURL == K.URL.Tab5
    }
    
    // Change here if you want a path to be dismissed on a visit proposal
    fileprivate func shouldBeDismissedFromURL(_ fromURL: Foundation.URL, toURL: Foundation.URL) -> Bool {
        return isModal()
    }
    
    
    // Change here if you want a path to be presented on a visit proposal
    fileprivate func shouldBePresentedFromURL(_ fromURL: Foundation.URL, toURL: Foundation.URL) -> Bool {
        return (toURL.path == "/modal")
    }
}

extension TurbolinksNavigationController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
       
    }
    

}

// MARK: extension to presentViewController using URL
extension TurbolinksNavigationController {
    fileprivate func presentViewController(_ URL: Foundation.URL) {
        let vc = TurbolinksNavigationController(url: URL)
        present(vc, animated: true, completion: nil)
    }
}


