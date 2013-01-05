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

@class JSTokenField;


@protocol JSTokenFieldDelegate <NSObject>
@optional

- (NSArray *)tokenField:(JSTokenField *)tokenField tokenIdentifiersForString:(NSString *)untokenizedText;
- (NSString *)tokenField:(JSTokenField *)tokenField labelForIdentifier:(id)identifier;

- (void)tokenField:(JSTokenField *)tokenField didAddTokenWithIdentifier:(id)identifier;
- (void)tokenField:(JSTokenField *)tokenField didRemoveTokenWithIdentifier:(id)identifier;
- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField;

@end



@interface JSTokenField : UIView <UITextFieldDelegate>

@property (nonatomic, assign) id <JSTokenFieldDelegate> delegate;
@property (nonatomic, readonly, retain) UILabel *label;
@property (nonatomic, readonly, retain) UITextField *textField;

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) CGSize tokenPadding;

- (NSArray *)allTokens;
- (void)addTokenIdentifiers:(NSArray *)tokenIdentifiers;
- (void)removeAllTokens;

- (void)addTokenWithLabel:(NSString *)labelText forIdentifier:(id)identifier;
- (void)removeTokenForIdentifier:(id)identifier;

@end

