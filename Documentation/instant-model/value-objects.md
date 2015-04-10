## Value Objects

While entities (like ICModel) are objects that have an important sense of identity (such as an `objectID`), value objects also live in the model layer, but they don't have that same sense of identity. The only important thing about a value object is what value it contains; it's otherwise interchangeable. 

A very practical way of looking at it is that value objects don't get their own row in a database, they usually get represented in a single field of some other object's row.

### Protocol

Instant Cocoa provides a protocol for value objects, called `ICValueObject`.

The backing object is normally a string or a number (since those are the primary value types in JSON), but it can be backed with anything. The only required methods in the `ICValueObject` protocol are:

	- (instancetype)initWithBackingObject:(id)backingObject;

	@property (nonatomic, readonly) id backingObject;

#### Optional Methods

The `ICValueObject` protocol also includes two optional methods:

	- (instancetype)initWithString:(NSString *)string;
	- (instancetype)initWithNumber:(NSNumber *)number;

These provide a little extra type information when reading, and Instant Cocoa will reflect on the `backingObject`'s type, and use the appropriate one if it is available.

### Concrete Implementation

Instant Cocoa also includes a concrete implmentation of the `ICValueObject` protocol, in a class also named `ICValueObject`.

The `ICValueObject` class conforms to the `ICValueObject` protocol, and can easily be subclassed to make quick value objects.

It implements `-copyWithZone:`, `-hash`, `-compare`, `-isEqual`, and `-description`.







