Instant Cocoa uses Serializers to transform string values into Foundation types, like `NSDate` and `NSURL`, which are used during [mapping](../../instant-model/mapping/).

A serializer is an object that conforms to the `ICSerializer` protocol, which contains two methods:

	- (NSString*)serializedObject:(id)object;
	- (id)deserializedObjectFromString:(NSString*)stringRepresentation;

A serializer for a particular property may be specified with a method in the form `- (id<ICSerializer>) serializerFor<propertyName>`. For instance, if the property is called `createdDate`, the method to defined a serializer for that property would be `-serializerForCreatedDate`. Dictionary and JSON mappings will use that serializer to deserialize values for that property.

Instant Cocoa also will currently implicitly use serializers if the correct class is defined. If a serializer exists with the format `<Prefix><TargetClassSansPrefix>Serializer`, it will automatically be used. For example, for `NSURL`, the `NS` will be removed, leaving `URL`, and the existence of following classes will be checked: `ICURLSerializer`, `NSURLSerializer`, and serializers for any custom prefixes that have been added. If any of those classes exist, that serializer will be allocated and used automatically. *This is probably going away soon, since it's implicit nature makes it hard to predict. It will be replaced with an explicit registration model.*

Instant Cocoa ships with serializers for Dates and URLs, but serializers can easily be written for other classes, like `UIColor`.










