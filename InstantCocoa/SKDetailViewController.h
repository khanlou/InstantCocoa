//
//  SKDetailViewController.h
//  InstantCocoa
//
//  Created by Soroush Khanlou on 12/15/13.
//  Copyright (c) 2013 Soroush Khanlou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
