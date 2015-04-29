`ICMultiDataSource` is a data source that allows you to combine multiple data sources in one. Each sub-data-source then becomes a section in the multi data source.

It's initialized with an array of `<ICDataSource`> objects:

	- (instancetype)initWithDataSources:(NSArray *)dataSources;

The multi data source should be the delegate of all of its children.

Calling `-fetchData` on this data source will call `-fetchData` on all of its children. Because some of those child data sources may be asynchronous, `ICMultiDataSource` will keep track of all the responses.

As a child's response comes in (either success or failure), the data source folds the objects from the child into its own objects, and calls `-dataSourceDidPartiallyLoad:`. When all of the children have responded, the multi data source calls `-dataSourceFinishedLoading:`.

There is an option to `preserveSectionsInSubDataSources`. Setting this to `YES` will ensure that any sections of child data sources will be preserved.

The section titles will also be drawn from the child data sources.