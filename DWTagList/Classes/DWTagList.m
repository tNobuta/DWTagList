//
//  DWTagList.m
//
//  Created by Dominic Wroblewski on 07/07/2012.
//  Copyright (c) 2012 Terracoding LTD. All rights reserved.
//

#import "DWTagList.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 10.0f
#define LABEL_MARGIN_DEFAULT 5.0f
#define BOTTOM_MARGIN_DEFAULT 5.0f
#define FONT_SIZE_DEFAULT 13.0f
#define HORIZONTAL_PADDING_DEFAULT 7.0f
#define VERTICAL_PADDING_DEFAULT 3.0f
#define BACKGROUND_COLOR [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]
#define TEXT_COLOR [UIColor blackColor]
#define TEXT_SHADOW_COLOR [UIColor whiteColor]
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 1.0f)
#define BORDER_COLOR [UIColor lightGrayColor].CGColor
#define BORDER_WIDTH 1.0f
#define HIGHLIGHTED_BACKGROUND_COLOR [UIColor colorWithRed:0.40 green:0.80 blue:1.00 alpha:0.5]
#define DEFAULT_AUTOMATIC_RESIZE NO
#define DEFAULT_SHOW_TAG_MENU NO

@interface DWTagList () <DWTagViewDelegate>

@end

@implementation DWTagList

@synthesize view, textArray, automaticResize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.automaticResize = DEFAULT_AUTOMATIC_RESIZE;
        self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
        self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
        self.cornerRadius = CORNER_RADIUS;
        self.borderColor = BORDER_COLOR;
        self.borderWidth = BORDER_WIDTH;
        self.textColor = TEXT_COLOR;
        self.textShadowColor = TEXT_SHADOW_COLOR;
        self.textShadowOffset = TEXT_SHADOW_OFFSET;
        self.showTagMenu = DEFAULT_SHOW_TAG_MENU;
        fullLineWidth = frame.size.width;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
        self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
        self.cornerRadius = CORNER_RADIUS;
        self.borderColor = BORDER_COLOR;
        self.borderWidth = BORDER_WIDTH;
        self.textColor = TEXT_COLOR;
        self.textShadowColor = TEXT_SHADOW_COLOR;
        self.textShadowOffset = TEXT_SHADOW_OFFSET;
        self.showTagMenu = DEFAULT_SHOW_TAG_MENU;
        fullLineWidth = self.frame.size.width;
    }
    return self;
}

- (void)setTags:(NSArray *)array
{
    textArray = [[NSArray alloc] initWithArray:array];
    sizeFit = CGSizeZero;
    if (automaticResize) {
        [self display];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
    }
    else {
        [self display];
    }
}

- (void)setTagBackgroundColor:(UIColor *)color
{
    lblBackgroundColor = color;
    [self setNeedsLayout];
}

- (void)setTagHighlightColor:(UIColor *)color
{
    self.highlightedBackgroundColor = color;
    [self setNeedsLayout];
}

- (void)setViewOnly:(BOOL)viewOnly
{
    if (_viewOnly != viewOnly) {
        _viewOnly = viewOnly;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

//    [self display];
//    
//    if (automaticResize) {
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
//    }
}

- (void)display
{
    NSMutableArray *tagViews = [NSMutableArray array];
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[DWTagView class]]) {
            DWTagView *tagView = (DWTagView*)subview;
            for (UIGestureRecognizer *gesture in [subview gestureRecognizers]) {
                [subview removeGestureRecognizer:gesture];
            }

            [tagView.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];

            [tagViews addObject:subview];
        }
        [subview removeFromSuperview];
    }

    hasMultipleLines = NO;
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    CGRect originFrame = self.frame;
    originFrame.size.width = fullLineWidth;
    self.frame = originFrame;

    NSInteger tag = 0;
    NSMutableArray *newTagViews = [[NSMutableArray alloc] init];
    for (id text in textArray) {
        DWTagView *tagView;
        if (tagViews.count > 0) {
            tagView = [tagViews lastObject];
            [tagViews removeLastObject];
        }
        else {
            tagView = [[DWTagView alloc] init];
        }

        [newTagViews addObject:tagView];

        [tagView updateWithString:text
                             font:self.font
               constrainedToWidth:self.frame.size.width - (self.horizontalPadding * 2)
                          padding:CGSizeMake(self.horizontalPadding, self.verticalPadding)
                     minimumWidth:self.minimumWidth
         ];

        if (gotPreviousFrame) {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + tagView.frame.size.width + self.labelMargin > self.frame.size.width) {
                hasMultipleLines = YES;
                newRect.origin = CGPointMake(0, previousFrame.origin.y + tagView.frame.size.height + self.bottomMargin);
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + self.labelMargin, previousFrame.origin.y);
            }
            newRect.size = tagView.frame.size;
            [tagView setFrame:newRect];
        }

        previousFrame = tagView.frame;
        gotPreviousFrame = YES;

        [tagView setBackgroundColor:[self getBackgroundColor]];
        [tagView setCornerRadius:self.cornerRadius];
        [tagView setBorderColor:self.borderColor];
        [tagView setBorderWidth:self.borderWidth];
        [tagView setTextShadowColor:self.textShadowColor];
        [tagView setTextShadowOffset:self.textShadowOffset];
        [tagView setTextColor:self.textColor];
        
        if ([self.tagDelegate respondsToSelector:@selector(DWTagList:willDisplayTagView:atTagIndex:)]) {
            [self.tagDelegate DWTagList:self willDisplayTagView:tagView atTagIndex:tag];
        }
        
        [tagView setTag:tag];
        [tagView setDelegate:self];
        
        tag++;

        [self addSubview:tagView];

        if (!_viewOnly) {
            [tagView.button addTarget:self action:@selector(touchDownInside:) forControlEvents:UIControlEventTouchDown];
            [tagView.button addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [tagView.button addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
            [tagView.button addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
        }
    }
    
    self.tagViews = newTagViews;

    CGFloat totalWidth = hasMultipleLines ? self.frame.size.width : (previousFrame.origin.x + previousFrame.size.width + self.labelMargin);
    sizeFit = CGSizeMake(totalWidth, previousFrame.origin.y + previousFrame.size.height + self.bottomMargin + 1.0f);
    self.contentSize = sizeFit;
}

- (CGSize)fittedSize
{
    return sizeFit;
}

- (void)touchDownInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:self.highlightedBackgroundColor];
}

- (void)touchUpInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    DWTagView *tagView = (DWTagView *)[button superview];
    [tagView setBackgroundColor:[self getBackgroundColor]];
    
    if ([self.tagDelegate respondsToSelector:@selector(DWTagList:selectedTag:tagIndex:)]) {
        [self.tagDelegate DWTagList:self selectedTag:tagView.button.titleLabel.text tagIndex:tagView.tag];
    }

    if ([self.tagDelegate respondsToSelector:@selector(DWTagList:selectedTag:)]) {
        [self.tagDelegate DWTagList:self selectedTag:tagView.button.titleLabel.text];
    }

    if (self.showTagMenu) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:tagView.frame inView:self];
        [menuController setMenuVisible:YES animated:YES];
        [tagView becomeFirstResponder];
    }
}

- (void)touchDragExit:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:[self getBackgroundColor]];
}

- (void)touchDragInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:[self getBackgroundColor]];
}

- (UIColor *)getBackgroundColor
{
    if (!lblBackgroundColor) {
        return BACKGROUND_COLOR;
    } else {
        return lblBackgroundColor;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

- (void)setBorderColor:(CGColorRef)borderColor
{
    _borderColor = borderColor;
    [self setNeedsLayout];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setNeedsLayout];
}

- (void)setTextShadowColor:(UIColor *)textShadowColor
{
    _textShadowColor = textShadowColor;
    [self setNeedsLayout];
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset
{
    _textShadowOffset = textShadowOffset;
    [self setNeedsLayout];
}

- (void)dealloc
{
    view = nil;
    textArray = nil;
    lblBackgroundColor = nil;
}

#pragma mark - DWTagViewDelegate

- (void)tagViewWantsToBeDeleted:(DWTagView *)tagView {
    NSMutableArray *mTextArray = [self.textArray mutableCopy];
    [mTextArray removeObject:tagView.label.text];
    [self setTags:mTextArray];

    if ([self.tagDelegate respondsToSelector:@selector(tagListTagsChanged:)]) {
        [self.tagDelegate tagListTagsChanged:self];
    }
}

@end


@implementation DWTagView

- (id)init
{
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_label setTextColor:TEXT_COLOR];
        [_label setShadowColor:TEXT_SHADOW_COLOR];
        [_label setShadowOffset:TEXT_SHADOW_OFFSET];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];

        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_button setFrame:self.frame];
        [self addSubview:_button];

        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:CORNER_RADIUS];
        [self.layer setBorderColor:BORDER_COLOR];
        [self.layer setBorderWidth:BORDER_WIDTH];
    }
    return self;
}

- (void)updateWithString:(id)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth
{
    CGSize textSize = CGSizeZero;
    BOOL isTextAttributedString = [text isKindOfClass:[NSAttributedString class]];

    if (isTextAttributedString) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        [attributedString addAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, ((NSAttributedString *)text).string.length)];

        textSize = [attributedString boundingRectWithSize:CGSizeMake(maxWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        [_button setAttributedTitle:[attributedString copy] forState:UIControlStateNormal];
    } else {
        textSize = [text sizeWithFont:font forWidth:maxWidth lineBreakMode:NSLineBreakByTruncatingTail];
        [_button setTitle:text forState:UIControlStateNormal];
    }

    textSize.width = MAX(textSize.width, minimumWidth);
    textSize.height += padding.height*2;

    self.frame = CGRectMake(0, 0, textSize.width+padding.width*2, textSize.height);
    _button.titleLabel.frame = CGRectMake(padding.width, 0, MIN(textSize.width, self.frame.size.width), textSize.height);
    _button.titleLabel.font = font;

    [_button setAccessibilityLabel:self.label.text];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [self.layer setCornerRadius:cornerRadius];
}

- (void)setBorderColor:(CGColorRef)borderColor
{
    [self.layer setBorderColor:borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    [self.layer setBorderWidth:borderWidth];
}

- (void)setLabelText:(NSString*)text
{
    [_button setTitle:text forState:UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)textColor
{
    [_button setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)setTextShadowColor:(UIColor*)textShadowColor
{
    [_button.titleLabel setShadowColor:textShadowColor];
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset
{
    [_button.titleLabel setShadowOffset:textShadowOffset];
}

- (void)dealloc
{
    _label = nil;
    _button = nil;
}

#pragma mark - UIMenuController support

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:)) || (action == @selector(delete:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.label.text];
}

- (void)delete:(id)sender
{
    [self.delegate tagViewWantsToBeDeleted:self];
}

@end
