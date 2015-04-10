## Mapping

Mapping to and from JSON is central to working with resources with a remote component. Instant Cocoa can apply attributes from a JSON object to a local domain object.

### ICJSONMapper

The `ICJSONMapper` class does the heavy lifting of mapping model objects to and from dictionary representations and JSON representations. It handles serializers, collections, child models, and value objects.

*Warning: This class will probably be broken up into two classes or more in the near future.*

### Dictionary mapping

Model objects can be converted to and from dictionaries. You can declare your own objects as Mappable by conforming to the `ICMappable` protocol, which provides two instance methods:

	- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
	@property (nonatomic, copy, readonly) NSDictionary *dictionaryRepresentation;

which convert to and from dictionaries.

#### Mapping to dictionaries

When converting a model to a dictionary, the names of the properties are preserved as key names. This functionality can be accessed with the method

	- (NSDictionary *)dictionaryRepresentationOfObject:(id<ICMappable>)object;

The mapper loops through each property and checks its value.

* If the value is `nil` or `NSNull`, it is skipped.
* If that value conforms to `ICMappable`, it will be converted to a dictionary as well, by calling `-dictionaryRepresentation` on it.
* If that value has a valid serializer, it will be deserialized using the serializer.
* If that value is a value object (declared by conforming to `ICValueObject`), it's `-backingObject` property will be used.
* If that value is a collection, the items in the collection will be looped through, and the item will be replaced with its dictionary representation is available (i.e., if it conforms to `ICMappable`). Currently, values objects and objects that use serializers are not supported, but they would ideally be.

After converting each child element to a dictionary-compatible format, the completed dictionary is returned.

Objects graphs with retain cycles currently have undefined behavior. 

#### Mapping from dictionaries

Mapping from dictionaries is largely similar, but in reverse. It can be found in the method:

	- (id)mapFromDictionary:(NSDictionary*)dictionary toObject:(id<ICMappable>)object;

For each property on the target object, the input dictionary is checked for a value.

* If that value is non-existent, it is skipped.
* If the value is a collection type (`NSArray`, `NSSet`, `NSOrderedSet`), the mapper fetches the intended class to map to. Because Objective-C doesn't support annotating collections with the objects they contain, the mapper calls a class method on the model, in the form of `+mappingClassFor<propertyName>`. For example, if the propery were named `addresses`, the mapper would call a method called `+mappingClassForAddresses`. If the model doesn't respond to that message, the collection will contain dictionaries.
* If the value is an `NSNumber` or an `NSString`, and the target property has a class that conforms to the `ICValueObject` protocol, the target object will contain a value object of that type with that value for that property.
* If the target property has a class that conforms to `ICMappable`, that value in the target object is checked. If the value in the target object exists, the object is updated. If it does not exist, a new object is allocated, and that new object is updated.

After transformation, each value is applied to the target object using key-value coding.

### JSON mapping

JSON Mapping is similar to dictionary mapping, with three additional guarantees. First, all values coming out will be JSON-compatible (meaning they are either numbers, booleans, strings, null, dictionaries, or arrays, and all values going in must also be JSON-compatible. Second, when converting from JSON, values may be fetched from nested objects; the converse also holds, when converting to JSON, values may be placed in nested objects. Lastly, each model has a chance to manipulate the JSON dictionary before mapping, with the method:

	- (void)transformJSONRepresentationBeforeMapping:(NSDictionary**)JSONRepresentation;

#### Mapping to JSON

The functionality for mapping to JSON can be accessed in the method

	- (NSDictionary*)JSONRepresentationOfObject:(id<ICJSONMappable>)object;

Like with dictionaries, getting the JSON representation of a model involves looping through each property on the object.

* If the value is `nil` or `NSNull`, it is skipped.
* If the value is `ICJSONMappable`, `-JSONRepresentation` is called on it.
* If the value is a collection type (`NSArray`, `NSSet`, `NSOrderedSet`), the mapper transforms the collection to an array (for JSON compatibility), and each element inside that conforms to `ICJSONMappable` is converted to JSON by calling `-JSONRepresentation` on it.
* If the value conforms to the `ICValueObject` protocol, it's transformed to its backing object.
* If the value has a valid serializer, it is deserialized using that serializer.

After each property's value is transformed, the intended location in the JSON dictionary is determined by the `+JSONMapping` provided by the model class, and the mapper will create any intermediate dictionaries that are required to place that value in its intended location. If a key is not in the JSON mapping, it will be assumed to be the same as the property's name.

#### Mapping from JSON

Mapping from JSON can be accessed with the method

	- (id)mapFromJSONDictionary:(NSDictionary*)JSONDictionary toObject:(id<ICJSONMappable>)object;

Mapping occurs in two phases: first, the JSON is "flattened" to a flat dictionary version of the JSON, and then that dictionary is applied to the model object using the same technique as defined in the section "Mapping from dictionaries".

To flatten the JSON, each property of the model object is looped through. Using the `+JSONMapping` from the model, values are fetched from the JSON and placed in a new dictionary where they keys are the property names of the class.

Once this flattened JSON is obtained, it is applied to the model using

	- (id)mapFromDictionary:(NSDictionary*)dictionary toObject:(id<ICMappable>)object;



