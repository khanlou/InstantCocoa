//
//  ICLoadingTableViewCell.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 2/9/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICLoadingTableViewCell.h"

@interface ICLoadingTableViewCell ()

@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicator;

@end

@implementation ICLoadingTableViewCell

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.contentView addSubview:_activityIndicator];
    }
    return _activityIndicator;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    self.activityIndicator.center = self.contentView.center;
}

@end
