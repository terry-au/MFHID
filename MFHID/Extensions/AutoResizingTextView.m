//
// Created by Terry Lewis on 12/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import "AutoResizingTextView.h"


@implementation AutoResizingTextView {

}

- (NSSize)intrinsicContentSize {
    NSTextContainer *textContainer = self.textContainer;
    NSLayoutManager *layoutManager = self.layoutManager;
    [layoutManager ensureLayoutForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size;
}

- (void)didChangeText {
    [super didChangeText];
    [self invalidateIntrinsicContentSize];
}

@end