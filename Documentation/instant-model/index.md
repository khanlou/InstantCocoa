## Instant Model

Instant Model provides a rich model layer for your app. It handles reflection, JSON mapping, networking, `NSCoding` serialization, and value objects.

### Protocols

The [Instant Model protocols](instant-model/protocols/) provide flexibility when working with Instant Model. The `ICModel` class provides an implementation for most of them, but your own model class can conform to them as well, so you are not required to subclass `ICModel` to make your entities. If an interface that takes one of these protocols does not work (with a non-`ICModel` object), we consider that a bug.

### Reflection

[Reflection](instant-model/reflection/) in Instant Cocoa is handled by two classes, `ICModelInspector` and `ICPropertyAttributes`. These are currently designed for use in the model layer, but in the future, they may be used in other layers, including the view layer. These classes can be used by your own model object to provide simple reflection.

### JSON Mapping

[JSON Mapping](instant-model/mapping/) is a core part of Instant Model. Mappings are provided by the `+JSONMapping` class method, and objects are mapped to and from JSON with the `ICJSONMapper` class. This class is complex and hard to understand, so it may change in the near future, possibly being broken out into multiple classes. The model protocols should be considered stable.

#### Collection Mapping

Collections, such as `NSArrays`, `NSSets`, and `NSOrderedSets` can contain object types that are mappable.

#### Serializers

Foundation (and foundational) types, such as `NSDate`, `NSURL`, and `UIColor`, can be automatically mapped using [Serializers](instant-model/serializers). Because of their implicit nature, their future is somewhat shakey, and their interface may change.

### Value Objects

Instant Cocoa supports [value types](instant-model/value-objects) as well as entity types. Value types are initialized and backed with an `NSString` or an `NSNumber`, and provide a richer domain layer for apps.

### Remote Access

Instant Model provides [REST-based access to remote objects](instant-model/resource-gateway/), including performing verbs on them through `ICResourceGateway`.

### Collection Fetcher

[REST-based collections can also be fetched and mapped](instant-model/collection-fetcher) with `ICCollectionFetcher`. This provides the core of `ICRemoteDataSource`.