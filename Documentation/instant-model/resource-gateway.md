## Resource Gateway

Model objects live locally as well as remotely. Instant Cocoa has affordances for manipulating objects remotely.

The REST-based resource model corresponds to the entity model quite well, so each `ICModel` instance has a **resource gateway**. This terminology is borrowed from Martin Fowler's Patterns of Enterprise Application Archicture.

Each class and instance has a resource gateway, represented by the class `ICResourceGateway`. Resource gateways are lazily loaded by ICModel, so to create one, just call `-resourceGateway`. You can then use it that gateway to perform REST "actions" on your remote objects. For example, if you had a user object, and you wanted to current user to follow them, you could invoke:

	[someUser.resourceGateway performAction:@"follow" successBlock:nil failureBlock:nil];

This corresponds to the REST endpoint `users/1234/follow`.

### HTTP Verbs

Passing in an HTTP verb will perform that verb. For example, if you wanted to destroy the remote object, you could invoke:

	[someUser.resourceGateway performAction:@"DELETE" successBlock:nil failureBlock:nil];

There are shorthands for all these methods. The category `ICModel+Remote` contains convenience methods for the default verbs.

There are a few ways to customize `ICResourceGateway`:

#### `updateObjectOnCompletion`

	@property (nonatomic, assign) BOOL updateObjectOnCompletion;

If the model object should update itself after successful completion with the response from the server, set this to `YES`. It defaults to `YES`.

#### `HTTPVerbForCustomActions`

	@property (nonatomic, strong) HTTPVerb *HTTPVerbForCustomActions;

If an action isn't an HTTP verb (such as the `follow` example from above), `ICResourceGateway` defaults to using `HTTPVerbPUT`. This property allows you to customize the verb.

#### `remoteKeypath`

	@property (nonatomic, strong) NSString *remoteKeypath;

This defaults to the value from model (assuming it conforms to `ICRemoteObject`), but it can be overridden in specific cases.

### Injection

It currently doesn't have a protocol (as a means of hooking in customized objects), but this is an addition that would be welcomed.