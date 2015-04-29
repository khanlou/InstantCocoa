`ICSimpleDataSource` is the most basic data source. It's initialized with an array:

	- (instancetype)initWithObjects:(NSArray*)objects;

Once the data source is initialized with an array, its contents shouldn't change.

## `-numberOfSections`

This method will always return 1.

## `-objectAtIndexPath:`

Calling this method with an invalid index path will through an exception.

## `-indexPathForObject:`

Calling this method with an object that is not present in the collection will return `nil`.

## `-fetchData`

Calling this method will call the delegate methods `-dataSourceWillLoadData:` and `-dataSourceFinishedLoading:` in succession, synchronously, with no change to the underlying data.