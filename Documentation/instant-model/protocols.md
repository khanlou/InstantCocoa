## Instant Model protocols

Instant Model's protocols provide flexibility when creating your model objects. Conforming to them will allow objects that don't subclass `ICModel` to continue to work with the rest of Instant Cocoa's infrastructure.

#### ICKeyValueCodable

The `ICKeyValueCodable` protocol formalizes the existence of Key-Value Coding in protocol form. All `NSObjects` conform to it already, but the `<NSObject>` protocol doesn't provide those methods. Other protocols are dependent on this one, but you won't have to do any work to conform to it.

	- (id)valueForKey:(NSString *)key;
	- (void)setValue:(id)value forKey:(NSString *)key;
	- (id)valueForKeyPath:(NSString *)keyPath;
	- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
	- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;
	- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

In `ICModel`, these don't have an implementation different from one provided by `NSObject`.

#### ICInspectable

`ICInspectable` provides one class method:

	+(NSDictionary*)properties;

This is a dictionary that maps key names to instances of `ICPropertyAttributes`. The `ICModelInspector` class provides an easy way to generate dictionaries for this role. A sample implementation:

	+ (NSDictionary *)properties {
	    return [[[ICModelInspector new] initWithClass:self] properties];
	}

#### ICMappable

The `ICMappable` protocol inherits from `ICKeyValueCodable` and adds two methods for [converting to and from dictionaries](instant-model/mapping).

	- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
	@property (nonatomic, copy, readonly) NSDictionary *dictionaryRepresentation;

#### ICJSONMappable

The `ICJSONMappable` protocol inherits from `ICMappable`. It adds three required methods. `+JSONMapping` is an NSDictionary that maps local property names to JSON keypaths:

	+ (NSDictionary*)JSONMapping;

With that data, [mapper objects can map to and from JSON](instant-model/mapping), using two other methods in the protocol:

	- (instancetype)initWithJSONDictionary:(NSDictionary*)JSONDictionary;
	@property (nonatomic, copy, readonly) NSDictionary *JSONRepresentation;

And one optional method, in case the server response needs additional manipulation before it's mapped:

	- (void)transformJSONRepresentationBeforeMapping:(NSDictionary**)JSONRepresentation;

#### ICRemoteObject

Objects that also have a remote component can conform to `ICRemoteObject`. This protocol provides information to [objects that need to know how to access each model as a resource](instant-model/resource-gateway).

It responds to a class method, which corresponds to the singleton resouce, such as `/users`

	+ (NSString *)resourceEndpoint;

It also responds to an instance method, which corresponds to the resource for *that specific* model, such as `/users/123`.

	- (NSString *)resourceEndpoint;

It also responds to an optional method that defines if the object lies at a particular keypath.

	@optional
	+ (NSString *)remoteKeyPath;


