`ICSimpleDataSource` and its partner, `ICPaginatedDataSource`, are designed for fetching remote objects and mappping them. Neither has a special initializer.

## `ICRemoteDataSource`

`ICRemoteDataSource` is the marriage of `ICCollectionFetcher` and the `<ICDataSource>` protocol. `ICRemoteDataSource` is configured similarly to `ICCollectionFetcher`.

View the docs for [`ICCollectionFetcher`](../../instant-model/collection-fetcher) for the details on usage of `mappingClass`, `remoteConfiguration`, `queryParameters`, `apiPath`, and `keyPath`.

### Usage

To fetch remote data, use the `-fetchData` method. This will kick off the network request. If you need to cancel the request in mid-flight, you can use the `-cancelFetch` method. You can query the state of the request with the `-isFetching` boolean.

#### Placeholders

Since everything stored in a data source must be an object, and since these objects usually represent table rows or collection view items, Instant Cocoa uses placeholder objects to represent rows that would normally display an activity indicator or a "No results" label. These classes for these objects are `ICLoadingPlaceholder` and `ICNoResultsPlaceholder` respectively. Errors can also be stored in remote and paginated data sources.

`ICRemoteDataSource` and `ICPaginatedDataSource` have options for whether or not to store these placeholders. `placeholderStorageOptions` is a bitwise property that can hold any combination of three options:

	typedef NS_ENUM(NSUInteger, ICRemoteDataSourceStorage) {
		ICRemoteDataSourceShouldStoreLoadingPlaceholder = 1 << 1,
		ICRemoteDataSourceShouldStoreNoResultsPlaceholder = 1 << 2,
		ICRemoteDataSourceShouldStoreErrors = 1 << 3,
	};

The default value is `ICRemoteDataSourceShouldStoreLoadingPlaceholder | ICRemoteDataSourceShouldStoreNoResultsPlaceholder`.

## `ICPaginatedDataSource`

`ICPaginatedDataSource` is very similar to `ICRemoteDataSource`, but includes some extra functionality.

The `ICPaginatorKeys` class holds the names of the keys where information about `pageSize`, `currentPage`, `numberOfPages`, and `numberOfTotalObjects` can be held. The default values for these are:

* `pageSize`: `@"page_size"`
* `currentPage`: `@"page"`
* `numberOfPages`: `@"number_of_pages"`
* `numberOfTotalObjects`: `@"total_count"`

`ICPaginatedDataSource` allows you to read these values as it downloads new pages.

	@property (readonly) NSInteger pageSize;
	@property (readonly) NSInteger currentPage;
	@property (readonly) NSInteger numberOfPages;
	@property (readonly) NSInteger numberOfTotalResults;

`hasMorePages` is a read-only property that changes to `NO` as soon as it detects that a page has been fetched with no objects.

	@property (readonly) BOOL hasMorePages;

To fetch new pages, a method called `-fetchNextPage` is provided. When displaying objects in a table or collection view, you can call `-willDisplayObjectAtIndexPath:` which will call `-fetchNextPage` if it is the last object currently in the collection. These correspond to the `UITableView` delegate method

	- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

and the `UICollectionView` delegate method

	- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath



