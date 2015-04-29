## What is Instant Cocoa?

Instant Cocoa is an Objective-C framework for making iPhone apps. Instant Cocoa makes intelligent guesses about how your system is set up using introspection, and provides convenient points to override those guesses when you need to.

Instant Cocoa cuts down on the amount of boilerplate you have to write when creating your app by leveraging the powerful dynamic features of Objective-C and generalizing the components that we have to use every day.

## What's in Instant Cocoa?

Instant Cocoa is very modular. Each component is only reliant on the components above it.

### Dependencies

Instant Cocoa is dependent on [Objective-Shorthand](https://github.com/khanlou/Objective-Shorthand), [InflectorKit](https://github.com/mattt/InflectorKit), and [AFNetworking](https://github.com/AFNetworking/AFNetworking).

### Instant Core

Instant Cocoa's core provides the shared functionality that all of the other components rely on.

* [Routing](core/router) - `ICRouter` does the heavy lifting of mapping urls and paths to view controllers. It supports path matching, variables, and dependencies, and it also provides hooks for custom navigation controllers.
* [Inflector](core/inflector) - `ICInflector` does some of the same work as Rails's inflector, but more specialized for the needs of a modern Objective-C app, such as dynamically building selectors from string components.

### Instant Model

Instant Cocoa's model is very powerful. It's built on a lot of the ideas of the `RestKit` and `Mantle` frameworks. It has support for:

* [Reflection](instant-model/reflection) - Reflection lies at the heart of `ICModel`. It allows the class to peer into itself to understand its own properties and the attributes they have (such as `weak`, `readonly`, `copy`, etc).
* [Dictionary and JSON Mapping](instant-model/mapping) - `ICModel` can map a dictionary or JSON object to a model object, automatically serializing date and URL objects using the built-in ICSerializers.
* Coding, Equality, and Hashing - `ICModel`'s introspection enables each model to be able to encode itself using `NSCoding`, and to automatically provide descriptions, equality checks, and hashing.
* [Serializers](instant-model/serializers) - `ICSerializer` is a protocol that allows value objects to be easily serialized. Date and URL serializers are included. These serializers are automatically used where appropriate, such as in object mapping.
* [Value Objects](instant-model/value-objects) - ICValueObject is a protocol and class that allows you to easily make value objects that can tie type, value, and behavior together.
* [Gateways](instant-model/resource-gateway) - Model objects are almost always networking, so `ICModel` gives you the power to fetch, create, update, delete objects, using REST-based resource conventions. It also gives you the ability to perform REST-like verbs on your objects with a native interface.


### Instant Data Source

A large amount of the boilerplate in our apps is dealing with table views and collection views and their totally bewildering API. [Data source](instant-data-source) objects are an attempt to simplify that. They are designed to be configured, rather than continually modified. After being configured, they present a straightforward API for table views and collection views to consume.

* [`ICSimpleDataSource`](instant-data-source/simple-data-source) presents any array of objects to the table view.
* [`ICSectionedDataSource`](instant-data-source/sectioned-data-source) takes an array and a sectioning key. It then splits that array into sections based on the sectioning key.
* [`ICRemoteDataSource`](instant-data-source/remote-data-sources) is powered by an API endpoint. It also takes a model for automatic mapping. It provides information to the table view about whether it is loading, had an error, and of course, the objects its presenting.
* [`ICPaginatedDataSource`](instant-data-source/remote-data-sources) is similar to the remote data source, but also takes keys that let it automatically download the next page of objects.
*  [`ICMultiDataSource`](instant-data-source/multi-data-source) is where the true power of data source objects is revealed: It takes several sub-datasources, fetches all of them, and presents them to the table view (or collection view) as they are ready, allowing you to have mixed data types in your table view without the effort of painstakingly synchronizing each of them.

### Instant View Controller

Data source objects are very useful, but without a table view or controller to talk to, they're not doing very much.

* [`ICTableViewController`](instant-view-controller/table-view-controller) provides the basic implementation for a table view. It will agnostically display any Data Source, and will also automatically fetch new pages, if it is displaying a Paginated Data Source.
* [`ICCollectionViewController`](instant-view-controller/collection-view-controller) is essentially the same, but with a collection view instead of a table view.

## Why Instant Cocoa?

Instant Cocoa is a way of fighting all of boilerplate that we write daily in our apps. The less code we write, the more expressive we can be, the easier code review is, the easier it is to track down bugs, and the faster we can get through the boring stuff and get to the interesting parts of our apps.

Open-source code is extremely important because it allows us to work together on the common code in our code base. Relying on our vendor to provide the framework is risky, since Apple only provides code only when it is absolutely necessary, and the code they provide is usually very conservative. It is up to us to create the frameworks that we need make our app development easier.
