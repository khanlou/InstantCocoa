In addition to the singularization and pluralization provided by [InflectorKit](https://github.com/mattt/InflectorKit), Instant Cocoa also provides a class for quickly manipulating strings for use by the runtime.

## The Inflector

Instant Cocoa's powerful [introspection and reflection](../../instant-model/reflection) capabilities are reliant on the ability to generate strings of specific formats easily. The `ICInflector` class provides that capability.

### Prefixes

Classes in Objective-C are usually prefixed with a 2 or 3 letter code representing the author of the class. `ICInflector` includes the capability of automatically stripping these class prefixes so that meaningful information can be extracted from the class name.

Instant Cocoa automatically includes the prefixes `IC` and `NS`.  You can add your own prefixes to the `sharedInflector`:

    [[ICInflector sharedInflector] addPrefixes:[NSSet setWithObject:@"SK"]];

### Property name transformation

An `@property` in Objective-C is usually `llamaCased`, meaning that the first letter of the first word is lowercased, and the first letter of every other word is capitalized. When retrieving from JSON, key names are usually `snake_cased`, meaning that they are lowercase, and joined by underscores.

For display and in other cases, these names have to be transformed to different types. These types include:

* CamelCase: The first word of each component is capitalized.
* llamaCase: The first word is lowercase, but each other component is capitalized
* snake_case: All words are lowercased, and joined by underscores
* train-case: All words are lowercased, and joined by hyphens

Abbreviations, such a "URL" in `aURLProperty`, are automatically intuited. `aURLProperty` would be transformed to, in snake\_case, `a_url_property`. In a near-future version of Instant Cocoa, you will be required to register such abbreviations explicitly, and common abbreviations, like "URL", will be pre-registered.

You can take advantage of these transformations by calling the appropriate method on `ICInflector`:

	[ICInflector sharedInflector] camelCasedString:myString];

A category is also provided, for convenience:

	[myString camelCasedString];

### Pluralization

Pluralization and singularization is powered by [InflectorKit](https://github.com/mattt/InflectorKit). It can be invoked as a category on `NSString`:

	[myString singularizedString];
	[myString pluralizedString];

See the documentation for that library for adding custom pluralizations.

### Selector Generation

One common use of the inflector is to generate selectors from strings. `ICInflector` provides a method to do that.

    - (SEL)selectorWithPrefix:(NSString*)prefix propertyName:(NSString*)propertyName suffix:(NSString*)suffix;

To generate a setter from a property name, for example, you could call

    [[ICInflector sharedInflector] selectorWithPrefix:@"set" propertyName:propertyName suffix:@“:”];

`ICInflector` will automatically handle all of the casing requirements for generating such selectors.

