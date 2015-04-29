`ICSectionedDataSource` is a data source that takes a stores objects broken into sections based on a key. It's initialized with an data source and a sectioning key:

	- (instancetype)initWithDataSource:(id<ICDataSource>)dataSource sectioningKey:(NSString *)sectioningKey sortDescriptors:(NSArray *)sortDescriptors;

Initialization with a data source allows for more flexibility. If you already have the objects that will be sectioned, you can turn those into a [simple data source](../simple-data-source) and initialize with that. If the objects come from a [remote data source](../remote-data-sources), or from Core Data, you can also use those data sources, pass them into this data source, and have them be automatically sectioned.

Note: the sectioned data source is required to be the delegate of the wrapped data source. It needs to know when data changes so that it can re-section itself and inform its own delegate.

The `sectioningKey` is fetched with `-valueForKeyPath:` and so may include dots and nested keys.

To perform the sectioning, call `-fetchData` on the sectioned data source. This will call `-fetchData` on its wrapped data source. When the `-dataSourceFinishedLoading:` delegate callback is fired, `ICSectionedDataSource` will get all the objects from the wrapped data source, sort them, and section them. The sectioning logic can be found in `NSArray+Sectioning`, although this will probably move to its own class soon.

The `-sectionTitles` property will hold, for each section, the value for the `sectioningKey` of the first object in the section.

Calling `-numberOfObjectsInSection:` or `-objectAtIndexPath:` with invalid section or row values will result in an exception.

## Sectioning by first character

Because a common use for sectioning is to divide objects into alphabetical sections, a category method on `NSString` is included with Instant Cocoa called `NSString+FirstCharacter`. This adds a method called `-firstCharacter` that returns a string containing the first composed character substring of the string (or nil, in the case of the empty string).

This allows you to easily use it in the `sectioningKey` like so:


	NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    [[ICSectionedDataSource alloc] initWithDataSource:backingDataSource
                                        sectioningKey:@"name.firstCharacter"
                                      sortDescriptors:sortDescriptors];

There are tests that confirm this behavior.