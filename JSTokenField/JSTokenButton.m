//
//	Copyright 2011 James Addyman (JamSoft). All rights reserved.
//	
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//	
//		1. Redistributions of source code must retain the above copyright notice, this list of
//			conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//			of conditions and the following disclaimer in the documentation and/or other materials
//			provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JAMES ADDYMAN (JAMSOFT) ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMES ADDYMAN (JAMSOFT) OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of James Addyman (JamSoft).
//

#import "JSTokenButton.h"
#import "JSTokenField.h"
#import <QuartzCore/QuartzCore.h>

@implementation JSTokenButton

@synthesize toggled = _toggled;
@synthesize normalBg = _normalBg;
@synthesize highlightedBg = _highlightedBg;
@synthesize representedObject = _representedObject;
@synthesize parentField = _parentField;

/*- (id)init
{
    self = [super init];
    if (self) {
        self.ty
    }
    return self;
}*/

static __strong UIImage *_defaultNormalButtonImage = nil;
static __strong UIImage *_defaultHighlightedButtonImage = nil;
static __strong UIColor *_defaultNormalButtonTitleColor = nil;
static __strong UIColor *_defaultHighlightedButtonTitleColor = nil;

+ (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj
{
	return [JSTokenButton tokenWithString:string
						representedObject:obj
								 normalBG:nil
							highlightedBG:nil
						 normalTitleColor:nil
					highlightedTitleColor:nil
			];
}

+ (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj normalBG:(UIImage *)nbg highlightedBG:(UIImage *)hbg normalTitleColor:(UIColor *)normalTColor highlightedTitleColor:(UIColor *)hiTColor {
	JSTokenButton *button = (JSTokenButton *)[self buttonWithType:UIButtonTypeCustom];
	if (nbg == nil) {
		if (_defaultNormalButtonImage == nil) {
			button.normalBg = [[UIImage imageNamed:@"tokenNormal"]
							   stretchableImageWithLeftCapWidth:14
							   topCapHeight:0];
		}
		else {
			button.normalBg = _defaultNormalButtonImage;
		}
	}
	else {
		button.normalBg = nbg;
	}
	if (hbg == nil) {
		if (_defaultHighlightedButtonImage == nil) {
			button.highlightedBg = [[UIImage imageNamed:@"tokenHighlighted"]
									stretchableImageWithLeftCapWidth:14
									topCapHeight:0];
		}
		else {
			button.highlightedBg = _defaultHighlightedButtonImage;
		}
	}
	else {
		button.highlightedBg = hbg;
	}
	[button setAdjustsImageWhenHighlighted:NO];
	if (normalTColor == nil) {
		if (_defaultNormalButtonTitleColor == nil) {
			button.normalTitleColor = [UIColor blackColor];
		}
		else {
			button.normalTitleColor = _defaultNormalButtonTitleColor;
		}
	}
	else {
		button.normalTitleColor = normalTColor;
	}
	if (hiTColor == nil) {
		if (_defaultHighlightedButtonTitleColor == nil) {
			button.highlightedTitleColor = [UIColor whiteColor];
		}
		else {
			button.highlightedTitleColor = _defaultHighlightedButtonTitleColor;
		}
	}
	else {
		button.highlightedTitleColor = hiTColor;
	}
	[button setTitleColor:button.normalTitleColor forState:UIControlStateNormal];

	[[button titleLabel] setFont:[UIFont fontWithName:@"Helvetica Neue" size:15]];
	[[button titleLabel] setLineBreakMode:UILineBreakModeTailTruncation];
	[button setTitleEdgeInsets:UIEdgeInsetsMake(2, 10, 0, 10)];
	
	[button setTitle:string forState:UIControlStateNormal];
	
	[button sizeToFit];
	CGRect frame = [button frame];
	frame.size.width += 20;
	frame.size.height = 25;
	[button setFrame:frame];
	
	[button setToggled:NO];
	
	[button setRepresentedObject:obj];
	
	return button;	
}

- (void)setToggled:(BOOL)toggled
{
	_toggled = toggled;
	
	if (_toggled)
	{
		[self setBackgroundImage:self.highlightedBg forState:UIControlStateNormal];
		[self setTitleColor:self.highlightedTitleColor forState:UIControlStateNormal];
	}
	else
	{
		[self setBackgroundImage:self.normalBg forState:UIControlStateNormal];
		[self setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
	}
}

- (void)dealloc
{
	self.representedObject = nil;
	self.highlightedBg = nil;
	self.normalBg = nil;
    [super dealloc];
}

- (BOOL)becomeFirstResponder {
    BOOL superReturn = [super becomeFirstResponder];
    if (superReturn) {
        self.toggled = YES;
    }
    return superReturn;
}

- (BOOL)resignFirstResponder {
    BOOL superReturn = [super resignFirstResponder];
    if (superReturn) {
        self.toggled = NO;
    }
    return superReturn;
}

#pragma mark - UIKeyInput
- (void)deleteBackward {
    [_parentField removeTokenForString:[self titleForState:UIControlStateNormal]];
}

- (BOOL)hasText {
    return NO;
}
- (void)insertText:(NSString *)text {
    return;
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Customization related methods

+ (void)setDefaultNormalButtonImage:(UIImage *)image {
	_defaultNormalButtonImage = [image copy];
}

+ (void)setDefaultHighlightedButtonImage:(UIImage *)image {
	_defaultHighlightedButtonImage = [image copy];
}

+ (void)setDefaultNormalButtonTitleColor:(UIColor *)nColor {
	_defaultNormalButtonTitleColor = [nColor copy];
}

+ (void)setDefaultHighlightedButtonTitleColor:(UIColor *)hColor {
	_defaultHighlightedButtonTitleColor = [hColor copy];
}
@end
