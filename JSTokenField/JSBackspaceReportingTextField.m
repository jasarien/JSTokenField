//
//  JSBackspaceReportingTextField.m
//  JSTokenField
//
//  Created by BJ Homer on 2/18/13.
//  Copyright (c) 2013 JamSoft. All rights reserved.
//

#import "JSBackspaceReportingTextField.h"

@implementation JSBackspaceReportingTextField

- (void)deleteBackward {
    BOOL shouldDismiss = (self.text.length == 0);

    [super deleteBackward];

    if (shouldDismiss) {
        if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
        }
    }
}

@end
