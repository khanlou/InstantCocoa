## Instant Router

Instant Cocoa's Router allows you to easily map a URL or path to a specific view controller or set of view controllers.

Setting up the router requires creating `ICRoute` objects, and registering them with the `ICRouter` singleton. 

### The Routes

Route information is stored in objects of type `ICRoute`. Routes have a "matcher" and information about how to present view controllers. A typically route can is initialized like so:

	id<ICRouteMatcher> matcher = [[ICSimpleRouteMatcher alloc] initWithPath:@"users/{user_id}"];
	ICRoute *route = [[ICRoute alloc] initWithMatcher:matcher];

A convenience method is provided for using simple route matching, and can be used like so:

	ICRoute *route = [ICRoute routeWithPath:@"users/{user_id}"];

Other matchers can be created by conforming to the `ICRouteMatcher` protocol, which involves implmenting two methods:

	- (BOOL)canHandlePath:(NSString*)incomingPath;
	- (NSDictionary*)parametersForPath:(NSString*)incomingPath;

Once a route is created, the route object can store additional information about how to present the route.

* `viewControllerClass`: The class that the router will alloc and init with the routing parameters from the matcher. View Controllers to be presented should conform to the `<ICRoutable>` protocol explicitly.
* `shouldPopToRoot`: Whether or not the navigation controller should pop to root before presenting this route.
* `navigationControllerKey`: An `NSString` that you can use to show the correct tab in a tab bar applciation.
* `dependencies`: An `NSArray` of other, dependent routes that should be executed before executing this route. Use this for nested resources.

When a route is ready, register it with `ICRouter`.

### The Router

The `ICRouter` class holds on to the routes and allows you to handle URLs opaquely.

Creating a router allows you to:

Register a new `ICRoute` with:

	- (void)registerRoute:(ICRoute*)route;

Check if a route can be handled with:

	- (BOOL)canHandleURL:(NSURL*)url;

Navigate to a route with:

	- (BOOL)handleURL:(NSURL*)url;

Navigating to a route involves three steps:

1. Fetching all the parameters from the route matcher.
2. Navigating to all the routes dependencies.
3. Navigating to the route itself.

Navigating to an individual route involves:

1. Showing the correct tab (if needed).
2. Allocating a new view controller, and calling `-initWithRoutingInfo:` on it (if it conforms to ICRoutable) or `-init` (if it doesn't).
3. Popping to root if required and not a dependency.
4. Presenting the view controller.

These steps can be overriden with the router's delegate. The `ICRouterDelegate` protocol provides methods the following methods:

	- (UIViewController*)showViewControllerWithKey:(NSString*)viewControllerKey;
	- (void)viewController:(UIViewController*)viewController requiresPopToRootForRoute:(ICRoute*)route;
	- (void) presentViewController:(UIViewController*)viewControllerToPresent forRoute:(ICRoute*)route fromViewController:(UIViewController*)fromViewController;

They will be called *instead of* the default behavior, if they are implemented.
