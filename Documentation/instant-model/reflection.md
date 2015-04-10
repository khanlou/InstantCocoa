## Reflection

Many of Instant Cocoa's capabilities come from the ability to inspect a class's properties at runtime. Classes that are *inspectable* conform to the `ICInspectable` protocol, which contains only one method.

	+ (NSDictionary*)properties;

It returns a dictionary that has strings for keys and instances of `ICPropertyAttributes` as values. 

### ICPropertyAttributes

The `ICPropertyAttributes` class stores all the metadata about a property. For example, if a property were annotated:

	@property (nonatomic, strong, readonly) NSString *username;

* `name` (NSString) - the name of the property. In the above example, this value would be `@"username"`.
* `readOnly` (BOOL) - whether or not the property is readonly
* `nonatomic` (BOOL) - whether or not the property is nonatomic
* `weak` (BOOL) - whether or not the property is weak
* `dynamic` (BOOL) - whether or not the setters and getters are synthesized dynamically with the `@dynamic` specifier
* `memoryManagementPolicy` (ICMemoryManagmentPolicy) - the memory management policy for the property. Values include `ICMemoryManagmentPolicyAssign`, `ICMemoryManagmentPolicyStrong`, and `ICMemoryManagmentPolicyCopy`.
* `protocols` (NSSet) - a set of `NSStrings` of each protocol that that property is specified to conform to. If a property's type were `id<NSObject, NSCopying>`, this value would be a set with the string `@"NSObject"` and `@"NSCopying"`. This does not include protocols that the class conforms to.
* `instanceVariable` (NSString) - the name of the instance variable backing the property. In the above example, this value would be `@"_username"`
* `type` (NSString) - the Objective-C type of the property. In the above example, this value would be `@"object"`. This will probably change to an enumeration in the near future.
* `className` (NSString) - the name of the class. The value of an `@property` declared as `id` is the empty string. In the above example, this value would be `@"NSString"`
* `getter` (SEL) - the getter for the property. In the above example, this value would be `"username"`
* `setter` (SEL) - the setter for the property. Read-only properties return NULL. In the above example, this value would be `"setUsername:"`

### ICModelInspector

*This class's name will change to `ICObjectInspector` soon.*

The `ICModelInspector` class is initialized with a class:

	- (instancetype)initWithClass:(Class)class;

It returns the `properties` dictionary for that class.

	- (NSDictionary*)properties;

It currently does not return computed properties, but this may change.

#### Cache

Properties are currently cached with a static `NSCache`. Currently, there isn't a public way to clear the cache.