//
//  ICETutorialPage.h
//  ICETutorial
//
//  Created by Icepat Dev on 25/03/13.
//  Copyright (c) 2013 Patrick Trillsam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICETutorialLabelStyle : NSObject {
    NSString *_text;
    UIFont *_font;
    UIColor *_textColor;
    NSUInteger _linesNumber;
    NSUInteger _offset;
}

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSUInteger linesNumber;
@property (nonatomic) NSUInteger offset;

// Init.
- (id)initWithText:(NSString *)text;
- (id)initWithText:(NSString *)text
              font:(UIFont *)font
         textColor:(UIColor *)color;
@end

@interface ICETutorialPage : NSObject {
    ICETutorialLabelStyle *_subTitle;
    ICETutorialLabelStyle *_description;
    NSString *_pictureName;
}

@property (nonatomic, retain) ICETutorialLabelStyle *subTitle;
@property (nonatomic, retain) ICETutorialLabelStyle *description;
@property (nonatomic, retain) NSString *pictureName;

// Init.
- (id)initWithSubTitle:(NSString *)subTitle
           description:(NSString *)description
           pictureName:(NSString *)pictureName;

- (void)setSubTitleStyle:(ICETutorialLabelStyle *)style;
- (void)setDescription:(ICETutorialLabelStyle *)style;

@end

