//
// Created by Terry Lewis on 12/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import "AutoResizingTextViewHolder.h"


@implementation AutoResizingTextViewHolder {

}

- (void)layout{
    [super layout];
    if (self.textView){
        [self.textView invalidateIntrinsicContentSize];
    }
}

@end