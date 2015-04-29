`ICCollectionViewController` is an `ICViewController` subclass that binds an `<ICDataSource>` and a `UICollectionView` together. It is designed to be subclassed.

`ICCollectionViewController` knows about `<ICDataSource>` and will do lots of heavy lifting so that you can easily write collection view screens.

## `ICCollectionViewCell`

Because `UICollectionViewCell` is so bare, Instant Cocoa comes with `ICCollectionViewCell`, which has a single UILabel called `textLabel` that is laid out to be the full size the cell.

## Registering cell classes and model classes

`ICCollectionViewController` allows you to register a cell class for each model class that you have. For each object in the data source, it will check which cell class it should allocate, and allocate that cell for you. If the model does not have a registered cell class, the `defaultCellClass` will be implicitly registered. This value defaults to `UICollectionViewCell`. To register a cell class, use the following method:

	- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;

## `cellConfigurationDelegate`

To configure cells, calculate heights, and update selections, `ICCollectionViewController` uses its `cellConfigurationDelegate`. This defaults to the collection view controller itself, and should conform to `ICCollectionCellConfigurationDelegate`.

## Dynamic message construction

The benefit of having an `<ICDataSource>` is that the collection view controller no longer needs to ask about how many sections there or how many objects are in each section. `ICCollectionViewController` and your `<ICDataSource>` will simply talk to each other and figure this information out. `ICCollectionViewController` is will also allocate your cells for you, so the only thing that you need to provide is the binding from your model object to your cell object.

Instant Cocoa gets this information by dynamically calling a message in the form of `-configureCell:with<ModelName>:` on its `cellConfigurationDelegate`. For example, if your data source was full of `MYUser` objects, you could implement

	- (void)configureCell:(MYUserCell *)cell withUser:(MYUser *) user {
		cell.textLabel.text = user.name;
		cell.imageView.image = user.avatar;
	}

The cell and model are already allocated and ready for binding. These objects are also passed-by-reference, so you don’t need to return the cell once the model has been bound to it. 

The `<ModelName>` that is used for constructing this message is created by calling `+modelName` on each object in the data source. `ICModel` implements this method by calling a method on [`ICInflector`](../../core/inflector), which turns the class name into a string and removes the prefix by default.

    + (NSString *)modelName {
        return [[ICInflector sharedInflector] modelNameFromClass:self];
    }

If the message is not implemented, `ICCollectionViewController` will fall back to other messages. The fallback order is:

1. `-configureCell:with<ModelName>:`
2. `-configureCell:with<ModelClassName>:`
3. `-configureCell:withObject:`

`ICCollectionViewController` provides a default implementation for `-configureCell:withObject:` which is a no-op.

## Placeholders

In addition to model object, `ICCollectionViewController` provides special consideration for a few other object types: placeholders and errors.

Instant Cocoa provides two types of placeholders: loading placeholders and “no results” placeholders. These correspond to special messages that are called on the `cellConfigurationDelegate`. `ICLoadingPlaceholder` corresponds to `-configureLoadingCell:`, `ICNoResultsPlaceholder` corresponds to `-configureNoResultsCell:`, and `NSError` corresponds to `-configureCell:withError:`. 

`ICLoadingCollectionViewCell` is registered by default for `ICLoadingPlaceholder`, but this can be overridden. The default implementation of `-configureLoadingCell:` calls `-startAnimating` on the cell’s `activityIndicator`.

## Cell selection

For configuring cells, getting objects is much easier than getting index paths. The same is true for cell selection, so Instant Cocoa will also call a dynamic message for this as well. This message takes the form

	-collectionView:didSelect<ModelName>:
 
Like cell configuration, it also falls back to other messages in the event that the `cellConfigurationDelegate` doesn’t respond to a message. The fallback order is:

1. `-collectionView:didSelect<ModelName>:`
2. `-collectionView:didSelect<ModelClassName>:`
3. `-collectionView:didSelectObject:`

## Overriding default behavior

`ICCollectionViewController` is `delegate` and `dataSource` for its collection view, so, to override any of these behaviors, simply reimplement these methods without calling the `super` implementation.


