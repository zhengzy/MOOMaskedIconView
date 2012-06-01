//
//  MOOMaskedIconButton.m
//  Tag
//
//  Created by Peyton Randolph on 5/31/12.
//

#import "MOOMaskedIconButton.h"

#import "Support/AHHelper.h"
#import "MOOMaskedIconView.h"

static NSString * const MOOHighlightedKeyPath = @"highlighted";
static NSString * const MOOEnabledKeyPath = @"enabled";

static NSString * const MOONormalStyleKeyPath = @"normalStyle";
static NSString * const MOOHighlightedStyleKeyPath = @"highlightedStyle";
static NSString * const MOODisabledStyleKeyPath = @"disabledStyle";

@implementation MOOMaskedIconButton
@synthesize icon = _icon;
@synthesize normalStyle = _normalStyle;
@synthesize highlightedStyle = _highlightedStyle;
@synthesize disabledStyle = _disabledStyle;

@synthesize contentEdgeInsets = _contentEdgeInsets;
@synthesize highlightedContentOffset = _highlightedContentOffset;

- (id)initWithFrame:(CGRect)frame;
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    self.userInteractionEnabled = YES;
    
    // Monitor button state for styling
    [self addObserver:self forKeyPath:MOOHighlightedKeyPath options:0 context:(__bridge void *)MOOHighlightedKeyPath];
    [self addObserver:self forKeyPath:MOOEnabledKeyPath options:0 context:(__bridge void *)MOOEnabledKeyPath];
    
    // Monitor styles for changes
    [self addObserver:self forKeyPath:MOONormalStyleKeyPath options:0 context:(__bridge void *)MOONormalStyleKeyPath];
    [self addObserver:self forKeyPath:MOOHighlightedStyleKeyPath options:0 context:(__bridge void *)MOOHighlightedStyleKeyPath];
    [self addObserver:self forKeyPath:MOODisabledStyleKeyPath options:0 context:(__bridge void *)MOODisabledStyleKeyPath];
    
    return self;
}

- (id)initWithIcon:(MOOMaskedIconView *)icon;
{
    if (!(self = [self initWithFrame:icon.bounds]))
        return nil;
    
    // Set the button's icon
    self.icon = icon;
    
    return self;
}

- (void)dealloc;
{
    // Tear down KVO
    [self removeObserver:self forKeyPath:MOOHighlightedKeyPath];
    [self removeObserver:self forKeyPath:MOOEnabledKeyPath];
    [self removeObserver:self forKeyPath:MOONormalStyleKeyPath];
    [self removeObserver:self forKeyPath:MOOHighlightedStyleKeyPath];
    [self removeObserver:self forKeyPath:MOODisabledStyleKeyPath];
    
    AH_SUPER_DEALLOC;
}

+ (MOOMaskedIconButton *)buttonWithIcon:(MOOMaskedIconView *)icon;
{
    return AH_AUTORELEASE([[self alloc] initWithIcon:icon]);
}

#pragma mark - Layout methods

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    // Apply styles if needed
    [self styleIfNeeded];
    
    // Position icon
    [self.icon sizeToFit];
    CGRect iconFrame = self.icon.frame;
    iconFrame.origin = CGPointMake(self.contentEdgeInsets.left, self.contentEdgeInsets.top);
    if (self.isHighlighted)
        iconFrame.origin = CGPointApplyAffineTransform(iconFrame.origin, CGAffineTransformMakeTranslation(self.highlightedContentOffset.width, self.highlightedContentOffset.height));
    
    self.icon.frame = iconFrame;
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    CGSize iconSize = [self.icon sizeThatFits:size];
    
    // Add contentEdgeInsets to iconSize
    iconSize.width += self.contentEdgeInsets.left + self.contentEdgeInsets.right;
    iconSize.height += self.contentEdgeInsets.top + self.contentEdgeInsets.bottom;
    
    return iconSize;
}

#pragma mark - Subview handling

- (void)didAddSubview:(UIView *)subview;
{
    subview.userInteractionEnabled = NO;
}

#pragma mark - Styling

- (void)styleIfNeeded;
{
    if (!_iconButtonFlags.needsStyling)
        return;
    
    if (!self.isEnabled && self.disabledStyle)
        self.icon.trait = self.disabledStyle;
    else if (self.isHighlighted && self.highlightedStyle)
        self.icon.trait = self.highlightedStyle;
    else if (self.normalStyle)
        self.icon.trait = self.normalStyle;
    
    _iconButtonFlags.needsStyling = NO;
}

#pragma mark - Getters and setters

- (void)setIcon:(MOOMaskedIconView *)icon;
{
    if (icon == self.icon)
        return;
    
    [self.icon removeFromSuperview];
    AH_RELEASE(self.icon);
    
    _icon = AH_RETAIN(icon);
    [self addSubview:icon];
    [self setNeedsLayout];
}

- (void)setNeedsStyling;
{
    _iconButtonFlags.needsStyling = YES;
    [self setNeedsLayout];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (context == (__bridge void *)MOOHighlightedKeyPath || context == (__bridge void *)MOOEnabledKeyPath)
        [self setNeedsStyling];
    
    else if (context == (__bridge void *)MOONormalStyleKeyPath || context == (__bridge void *)MOOHighlightedStyleKeyPath || context == (__bridge void *)MOODisabledStyleKeyPath)
        [self setNeedsStyling];
}

@end
