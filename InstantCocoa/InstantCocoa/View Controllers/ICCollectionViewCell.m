//
//  ICCollectionViewCell.m
//  InstantCocoa
//
//  Created by Soroush Khanlou on 7/14/14.
//  Copyright (c) 2014 Soroush Khanlou. All rights reserved.
//

#import "ICCollectionViewCell.h"

@interface ICCollectionViewCell ()

@property (nonatomic, strong, readwrite) UILabel *textLabel;

@end


@implementation ICCollectionViewCell

- (UILabel *)textLabel {
    if (!_textLabel) {
        self.textLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = self.contentView.bounds;
}

@end
