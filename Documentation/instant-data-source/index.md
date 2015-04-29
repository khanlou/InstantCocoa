Instant Cocoa provides an abstraction for storing objects behind index paths, for use in table and collection views. Instant Cocoa comes with several concrete implementations of data sources, and also provides a protocol for creating custom data sources.

## The `<ICDataSource>` protocol

The Instant Cocoa Data Source protocol allows Instant Cocoa's table view controller to play nicely with Instant Cocoa's data sources. The protocol’s methods are enumerated below:

### Object access

`<ICDataSource>` is designed to “fit” into `UITableView` and `UICollectionView` cleanly. Where `UITableViewDataSource` has methods like

	- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

`<ICDataSource>` has methods like:

	@property (nonatomic, assign, readonly) NSUInteger numberOfSections;
	- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section;
	- (id)objectAtIndexPath:(NSIndexPath*)indexPath;

Providing access to the objects that it stores is the primary role of `<ICDataSource>` objects. `-objectAtIndexPath:` is undefined for index paths that are invalid. It may return nil and it may throw an exception, depending on the implementation.

You can also do a reverse lookup, by using the object to get its index path:

	- (NSIndexPath *)indexPathForObject:(id)object;

### Names

Each `<ICDataSource>` can have a name, using the `name` property. Instant Cocoa uses only uses this for determining the section titles for `ICMultiDataSource`. The `sectionTitles` array is also optional, but can be used to store data about each section.

### Asynchronicity

Because some data sources, like [`ICRemoteDataSource`](remote-data-sources), can’t access their data in a synchronous way, users of the data source will call `-fetchData` when they want  the fetch itself to occur, whether the fetch hits a network or a database. To inform its parent of its fetch status, data source objects have a delegate.

	@property (nonatomic, weak) id<ICDataSourceDelegate> delegate;

The `ICDataSourceDelegate` defines how objects should expect to receive changes from data sources. This protocol contains four methods.

	- (void)dataSourceWillLoadData:(id<ICDataSource>)dataSource;

This method is expected to be called one time each time `-fetchData` is called.

	- (void)dataSourceDidPartiallyLoad:(id<ICDataSource>)dataSource;

This method can be called 0, 1, or *n* times, depending on the implementation of the data source. It should only be called after `-dataSourceWillLoadData:` and before the final method is called.

	- (void)dataSourceFinishedLoading:(id<ICDataSource>)dataSource;
	- (void)dataSource:(id<ICDataSource>)dataSource failedWithError:(NSError*)error;

One of these finalizing methods is expected to be called each time `-fetchData` is called.

Five concrete implementations of `<ICDataSource>` are included with Instant Cocoa:

* [`ICSimpleDataSource`](simple-data-source), which is initialized with an array or objects and has one section.
* [`ICSectionedDataSource`](sectioned-data-source), which is initialized with a `<ICDataSource>` and a sectioning key.
* [`ICRemoteDataSource`](remote-data-sources), which fetches remote objects, maps them, and presents them for display.
* [`ICPaginatedDataSource`](remote-data-sources), which fetches remote objects and automatically handles pagination.
* [`ICMultiDataSource`](multi-data-source), which is initialized with an array of `<ICDataSource>` objects, and creates a section for each sub-data-source.