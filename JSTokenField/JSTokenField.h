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

#import <UIKit/UIKit.h>

@class JSTokenButton;
@protocol JSTokenFieldDelegate;

extern NSString *const JSTokenFieldFrameDidChangeNotification;
extern NSString *const JSTokenFieldNewFrameKey;
extern NSString *const JSTokenFieldOldFrameKey;
extern NSString *const JSDeletedTokenKey;

@interface JSTokenField : UIView <UITextFieldDelegate> {
	
	JSTokenButton *_deletedToken;
}

@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic)           UILabel *label;
@property (nonatomic, readonly) NSMutableArray *tokens;
@property (nonatomic, weak)     id <JSTokenFieldDelegate> delegate;
@property (nonatomic)           BOOL editing;

- (void)addTokenWithTitle:(NSString *)string representedObject:(id)obj;
- (void)addTokenWithView:(UIView *)view representedObject:(id)obj;
- (void)removeTokenForString:(NSString *)string;
- (void)removeTokenWithRepresentedObject:(id)representedObject;
- (void)removeAllTokens;

@end

@protocol JSTokenFieldDelegate <NSObject>

@optional

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(id)value representedObject:(id)obj;
- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(id)value representedObject:(id)obj;
- (BOOL)tokenField:(JSTokenField *)tokenField shouldRemoveToken:(id)value representedObject:(id)obj;

- (void)tokenFieldTextDidChange:(JSTokenField *)tokenField;

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField;
- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField;
- (void)tokenFieldDidBeginEditing:(JSTokenField *)tokenField;

- (void)didSelectTokenButton:(JSTokenButton *)tokenButton;
- (void)didUnselectTokenButton:(JSTokenButton *)tokenButton;

@end
