import UIKit
import WebKit
import Turbolinks

/*!
 This is the TurbolinksNavigationController, which contains a Turbolinks Session object
 Use it to push Turbolinks.VisitableViewController
 */
class TurbolinksNavigationController: UINavigationController {
    // URL to be visited
    private var URL : NSURL;
    
    // whether this view controller should be reloaded or not on viewWillAppear.
    private var shouldReloadOnAppear : Bool = false;
    
    private lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()
    
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
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
    
    func visit(URL: NSURL) {
        showVisitableForSession(session, URL: URL)
    }
    
    // MARK: Initializers
    required init?(coder aDecoder: NSCoder) {
        self.URL = NSURL();
        super.init(coder: aDecoder)
    }
    
    init(url: NSURL) {
        self.URL = url;
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationCenterObservers()
        showVisitableForSession(session, URL: URL)
        

       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldReloadOnAppear {
            session.reload()
            shouldReloadOnAppear = false
        }
    }
    
    deinit {
        removeNotificationCenterObservers()
    }
    
    
    private func removeNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func handleDismissedForm() {
        shouldReloadOnAppear = true
    }

    // MARK: other
    private func showVisitableForSession(session: Session, URL: NSURL, action: Action = .Advance) {
        guard URL.path != nil else {
            return
        }
        
        if URL.description.lowercaseString.rangeOfString("http://") != nil || URL.description.lowercaseString.rangeOfString("https://") != nil {
            showVisitableViewControllerWithUrl(URL, action: action)
        } else {
            UIApplication.sharedApplication().openURL(URL)
        }
        
    }
    
    private func addNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleDismissedForm), name: K.NotificationCenter.hasDismissedForm, object: nil)
    }
    
    private func showVisitableViewControllerWithUrl(URL: NSURL, action: Action) {
        
        let visitable : BaseVisitableViewController = BaseVisitableViewController(URL: URL)
        
        switch action {
        case .Advance:
            pushViewController(visitable, animated: true)
        
        case .Replace:
            
            if viewControllers.count == 1 {
                setViewControllers([visitable], animated: false)
            } else {
                popViewControllerAnimated(false)
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
    
    
    func session(session: Session, didProposeVisitToURL URL: NSURL, withAction action: Action) {

        if shouldChangeNavigationTab(URL){

            switch(URL.path!){
            case K.URL.Tab1.path!:
                self.tabBarController?.selectedIndex = 0
            case K.URL.Tab2.path!:
                self.tabBarController?.selectedIndex = 1
            case K.URL.Tab3.path!:
                self.tabBarController?.selectedIndex = 2
            case K.URL.Tab4.path!:
                self.tabBarController?.selectedIndex = 3
            case K.URL.Tab5.path!:
                self.tabBarController?.selectedIndex = 4
            default:
                return
            }
            return
        }
        
        if shouldBeDismissedFromURL(self.URL, toURL:URL) {
            NSNotificationCenter.defaultCenter().postNotificationName(K.NotificationCenter.hasDismissedForm, object: nil)
            dismissViewControllerAnimated(true, completion: {})
            return
        }

        if shouldBePresentedFromURL(self.URL, toURL:URL) {
            presentViewController(URL)
            return
        }
        showVisitableForSession(session, URL: URL, action: action)
        
    }
    
    func session(session: Session){
        
    }
    
    func session(session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        guard let visitableViewController = visitable as? BaseVisitableViewController else { return }
        visitableViewController.handleError(error)
        
    }
    
    func session(session: Session, openExternalURL URL: NSURL) {
        if #available(iOS 10.0, *) {
            UIApplication.sharedApplication().openURL(URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.sharedApplication().openURL(URL)
        }
    }
    
    func sessionDidStartRequest(session: Session) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func sessionDidFinishRequest(session: Session) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    private func shouldChangeNavigationTab(toURL: NSURL) -> Bool {
        guard toURL.path != nil else { return false }
        return toURL == K.URL.Tab1 || toURL == K.URL.Tab2 || toURL == K.URL.Tab3 || toURL == K.URL.Tab4 || toURL == K.URL.Tab5
    }
    
    // Change here if you want a path to be dismissed on a visit proposal
    private func shouldBeDismissedFromURL(fromURL: NSURL, toURL: NSURL) -> Bool {
        return isModal()
    }
    
    
    // Change here if you want a path to be presented on a visit proposal
    private func shouldBePresentedFromURL(fromURL: NSURL, toURL: NSURL) -> Bool {
        guard toURL.path != nil else { return false }
        return (toURL.path == "/modal")
    }
}

extension TurbolinksNavigationController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
       
    }
    

}

// MARK: extension to presentViewController using URL
extension TurbolinksNavigationController {
    private func presentViewController(URL: NSURL) {
        let vc = TurbolinksNavigationController(url: URL)
        presentViewController(vc, animated: true, completion: nil)
    }
}


