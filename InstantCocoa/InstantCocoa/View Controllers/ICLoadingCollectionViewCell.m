//
//  ICLoadingCollectionViewCell.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 7/14/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICLoadingCollectionViewCell.h"

@interface ICLoadingCollectionViewCell ()

@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicator;

@end

@implementation ICLoadingCollectionViewCell

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
