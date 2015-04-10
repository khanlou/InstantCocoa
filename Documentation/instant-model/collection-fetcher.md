## Collection Fetcher

Some REST endpoints represent a collection of resources. Instant Cocoa has an affordance for downloading and mapping an array of remote objects, called `ICCollectionFetcher`. `ICCollectionFetcher` provides the core of `ICRemoteDataSource` and `ICPaginatedDataSource`.

### Configuration

`ICCollectionFetcher` is designed to be configured and used.

#### `mappingClass`

To map each object in the array, `ICCollectionFetcher` needs to know what class to use. This class should conform to `ICJSONMappable`. If it is blank, `ICCollectionFetcher` will return an array of `NSDictionary` instances.

#### `remoteConfiguration`

The `remoteConfiguration` parameter tells the collection fetcher what base URL to use, as well as what headers. An `AFHTTPRequestOperationManager` can be injected with the `networkRequestManager` property, but the future of AFNetworking in Instant Cocoa is unsure.

#### `queryParameters`

Query parameters can be used to sort or filter your request, as the API needs.

#### `apiPath`

The `apiPath` parameter determines what endpoint to fetch.

#### `keyPath`

The `keyPath` parameter determines where in the JSON structure the array of objects can be found.

### Usage

Once configured, the collection fetcher is straightforward to use. It can only make one request at a time, but it can be reused. The request can be cancelled in mid-flight.

	- (void)fetchCollectionWithSuccessBlock:(void (^)(NSArray *objects))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
	- (void)cancelFetch;
