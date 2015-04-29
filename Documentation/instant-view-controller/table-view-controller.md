`ICTableViewController` is an `ICViewController` subclass that binds an `<ICDataSource>` and a `UITableView` together. It is designed to be subclassed.

`ICTableViewController` knows about `<ICDataSource>` and will do lots of heavy lifting so that you can easily write table view screens.

## Registering cell classes and model classes

`ICTableViewController` allows you to register a cell class for each model class that you have. For each object in the data source, it will check which cell class it should allocate, and allocate that cell for you. If the model does not have a registered cell class, the `defaultCellClass` will be implicitly registered. This value defaults to `UITableViewCell`. To register a cell class, use the following method:

	- (void)registerCellClass:(Class)cellClass forModelClass:(Class)modelClass;

## `cellConfigurationDelegate`

To configure cells, calculate heights, and update selections, `ICTableViewController` uses its `cellConfigurationDelegate`. This defaults to the table view controller itself, and should conform to `ICTableCellConfigurationDelegate`.

## Dynamic message construction

The benefit of having an `<ICDataSource>` is that the table view controller no longer needs to ask about how many sections there or how many objects are in each section. `ICTableViewController` and your `<ICDataSource>` will simply talk to each other and figure this information out. `ICTableViewController` is will also allocate your cells for you, so the only thing that you need to provide is the binding from your model object to your cell object.

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

If the message is not implemented, `ICTableViewController` will fall back to other messages. The fallback order is:

1. `-configureCell:with<ModelName>:`
2. `-configureCell:with<ModelClassName>:`
3. `-configureCell:withObject:`

`ICTableViewController` provides a default implementation for `-configureCell:withObject:` which is a no-op.

## Placeholders

In addition to model object, `ICTableViewController` provides special consideration for a few other object types: placeholders and errors.

Instant Cocoa provides two types of placeholders: loading placeholders and “no results” placeholders. These correspond to special messages that are called on the `cellConfigurationDelegate`. `ICLoadingPlaceholder` corresponds to `-configureLoadingCell:`, `ICNoResultsPlaceholder` corresponds to `-configureNoResultsCell:`, and `NSError` corresponds to `-configureCell:withError:`. 

`ICLoadingTableViewCell` is registered by default for `ICLoadingPlaceholder`, but this can be overridden. The default implementation of `-configureLoadingCell:` calls `-startAnimating` on the cell’s `activityIndicator`.

## Cell selection

For configuring cells, getting objects is much easier than getting index paths. The same is true for cell selection, so Instant Cocoa will also call a dynamic message for this as well. This message takes the form

	-tableView:didSelect<ModelName>:
 
Like cell configuration, it also falls back to other messages in the event that the `cellConfigurationDelegate` doesn’t respond to a message. The fallback order is:

1. `-tableView:didSelect<ModelName>:`
2. `-tableView:didSelect<ModelClassName>:`
3. `-tableView:didSelectObject:`

## Cell height

Similar to cell configuration and selection, cell height is also performed with a dynamic message. This one takes the form: 

	-tableView:heightFor<ModelName>:

It also follows the same fallback pattern as the other two messages.

1. `-tableView:heightFor<ModelName>:`
2. `-tableView:heightFor<ModelClassName>:`
3. `-tableView:heightForObject:`

## The payoff

Using these techniques pays off in a major way, making table view controllers much more digestable.

	@implementation SKFollowerListViewController

	- (instancetype)initWithUsers:(NSArray *)followers {
	    self = [super init];
	    if (!self) return nil;
    
	    self.dataSource = [[ICSimpleDataSource alloc] initWithObjects:followers];
       [self registerCellClass:[SKUserCell class] forModelClass:[SKUser class]];

	    return self;
	}

	- (void)configureCell:(SKUserCell *)cell withUser:(SKUser *)user {
	    cell.textLabel.text = user.name;
	    cell.detailTextLabel.text = user.bio;
	}

	- (void)tableView:(UITableView *)tableView didSelectUser:(SKUser *)user {
	    SKUserViewController *userViewController = [[SKUserViewController alloc] initWithUser:user];
	    [self.navigationController pushViewController:userViewController animated:YES];
	}

	@end

That's it!

## Overriding default behavior

`ICTableViewController` is `delegate` and `dataSource` for its table view, so, to override any of these behaviors, simply reimplement these methods without calling the `super` implementation.


