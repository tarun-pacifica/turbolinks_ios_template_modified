# Turbolinks iOS Template

## Quick Setup
* Check out this project
* Run `pod install` in your terminal
* Open `App.xcworkspace` (not `App.xcodeproj`)
* Profit

## Installation
Install Turbolinks manually by building Turbolinks.framework and linking it to your project.

**Installing with CocoaPods**
Add the following to your `Podfile`:
```
use_frameworks!
pod 'Turbolinks', :git => 'https://github.com/turbolinks/turbolinks-ios.git'
```
Then run `pod install` in your terminal.

**You can use Carthage instead of Pods**
Add the following to your `Cartfile`:
```
github "turbolinks/turbolinks-ios" "master"
```

*Be warned, Carthage is not as stable as Pod's for now*

# ROR Setup/Tips
You will need to make the following changes to your ROR app to work with Turbolinks iOS in a usable manor.
* Implement `TurbolinksNativeMessageHandler` JS
* All forms MUST be submitted `remote: true`
* Handle redirection from JS with `Turbolinks.visit("<%= j your_path %>");`
* Do not use modals (especially CSS only modals), use individual pages.

**ENV Requirements**
```
TURBOLINKS_IOS_APP_USER_AGENT=App
TURBOLINKS_ANDROID_APP_USER_AGENT=App
TURBOLINKS_NATIVE_MESSAGE_HANDLER=App
```

**application.html.erb**
```
<html data-turbolinks-native-message-handler="<%= ENV.fetch('TURBOLINKS_NATIVE_MESSAGE_HANDLER'.freeze) %>">
```
