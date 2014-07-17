//
//  ALDColorBlindEffect.m
//  ALDColorBlindEffect
//
//  Created by Andy Drizen on 12/07/2014.
//  Copyright (c) 2014 Andy Drizen. All rights reserved.
//

#import "ALDColorBlindEffect.h"
#import <Accelerate/Accelerate.h>

@interface ALDColorBlindEffect ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGContextRef inContext;
@property (nonatomic, assign) CGContextRef outContext;
@property (nonatomic, assign) vImage_Buffer srcBuffer;
@property (nonatomic, assign) vImage_Buffer destBuffer;
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, assign) CGFloat cachedBlurAmount;

@property (nonatomic, assign) CGFloat qualityScale;
@property (nonatomic, assign) CGInterpolationQuality qualityInterpolation;
@end

@implementation ALDColorBlindEffect

+ (ALDColorBlindEffect *)sharedInstance
{
    static dispatch_once_t onceToken;
    static ALDColorBlindEffect *control = nil;
    dispatch_once(&onceToken, ^{
        control = [[[self class] alloc] init];
    });
    return control;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _quality = ALDColorBlindEffectQualityMedium;
        _cachedBlurAmount = 1; // No blur.
        [self updateQualityValuesForQuality:_quality];
        
    }
    return self;
}

- (void)setView:(UIView *)view
{
    [self.overlayWindow removeFromSuperview];
    self.overlayWindow = nil;
    
    _view = view;
    if (view) {
        [self enable];
    }
    else {
        [self disable];
    }
}

- (void)setBlurAmount:(CGFloat)blurAmount
{
    _blurAmount = blurAmount;
    int amount = 2 * round(50 * MIN(1, MAX(_blurAmount, 0))) + 1;
    self.cachedBlurAmount = amount;
    
    if (amount > 1) {
        self.qualityScale = 0.3;
        self.qualityInterpolation = kCGInterpolationLow;
        [self prepareContext];
    }
    else {
        self.quality = _quality;
    }
}

- (void)setQuality:(ALDColorBlindEffectQuality)quality
{
    _quality = quality;
    [self updateQualityValuesForQuality:quality];
    [self prepareContext];
}

- (void)updateQualityValuesForQuality:(ALDColorBlindEffectQuality)quality
{
    switch (quality) {
        case ALDColorBlindEffectQualityLow:
            self.qualityScale = 0.4;
            self.qualityInterpolation = kCGInterpolationLow;
            break;
        case ALDColorBlindEffectQualityMedium:
            self.qualityScale = 0.5;
            self.qualityInterpolation = kCGInterpolationLow;
            break;
        case ALDColorBlindEffectQualityHigh:
            self.qualityScale = 1.0;
            self.qualityInterpolation = kCGInterpolationHigh;
            break;
            
        default:
            break;
    }
}

- (void)enable
{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
    [self prepareContext];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)disable
{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.overlayWindow.hidden = YES;
    
    [self cleanUp];
}

- (void)cleanUp{
    if (self.inContext) {
        CGContextRelease(self.inContext);
        self.inContext = nil;
    }
    
    if (self.outContext) {
        CGContextRelease(self.outContext);
        self.outContext = nil;
    }
}

- (void)prepareContext
{
    [self cleanUp];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGRect r = self.view.frame;
    CGFloat scale = self.qualityScale * [UIScreen mainScreen].scale;
    CGSize scaledSize = CGSizeMake(scale * CGRectGetWidth(r),
                                   scale * CGRectGetHeight(r));
    
    self.inContext = CGBitmapContextCreate(NULL,
                                           scaledSize.width,
                                           scaledSize.height,
                                           8,
                                           0,
                                           colorSpace,
                                           kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    self.outContext = CGBitmapContextCreate(NULL,
                                            scaledSize.width,
                                            scaledSize.height,
                                            8,
                                            0,
                                            colorSpace,
                                            kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetInterpolationQuality(self.inContext, self.qualityInterpolation);
    CGContextSetInterpolationQuality(self.outContext, self.qualityInterpolation);
    
    CGContextConcatCTM(self.inContext, CGAffineTransformMake(1, 0, 0, -1, 0, scaledSize.height));
    CGContextScaleCTM(self.inContext, scale, scale);
    
    self.srcBuffer = (vImage_Buffer){
		.data = CGBitmapContextGetData(self.inContext),
		.width = CGBitmapContextGetWidth(self.inContext),
		.height = CGBitmapContextGetHeight(self.inContext),
		.rowBytes = CGBitmapContextGetBytesPerRow(self.inContext)
	};
	
    self.destBuffer = (vImage_Buffer){
		.data = CGBitmapContextGetData(self.outContext),
		.width = CGBitmapContextGetWidth(self.outContext),
		.height = CGBitmapContextGetHeight(self.outContext),
		.rowBytes = CGBitmapContextGetBytesPerRow(self.outContext)
	};
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    CGPoint originInWindow;
    if (self.view.superview) {
        originInWindow = [self.view.superview convertPoint:self.view.frame.origin toView:nil];
    }
    else {
        originInWindow = self.view.frame.origin;
    }
    CGRect rect = CGRectMake(originInWindow.x,
                             originInWindow.y,
                             CGRectGetWidth(self.view.frame),
                             CGRectGetHeight(self.view.frame));
    
    if (!self.overlayWindow) {
        self.overlayWindow = [[UIWindow alloc] initWithFrame:rect];
        self.overlayWindow.windowLevel = UIWindowLevelNormal;
        self.overlayWindow.backgroundColor = [UIColor clearColor];
        self.overlayWindow.userInteractionEnabled = NO;
        self.overlayWindow.accessibilityElementsHidden = YES;
    }
    self.overlayWindow.hidden = NO;
    
    CGContextRef inContext = CGContextRetain(self.inContext);
	CGContextRef outContext = CGContextRetain(self.outContext);
    
    CGContextClearRect(inContext, rect);
    
    if ([self.view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        UIGraphicsPushContext(self.inContext);
        [self.view drawViewHierarchyInRect:rect afterScreenUpdates:NO];
        UIGraphicsPopContext();
    }
    else {
        [self.view.layer renderInContext:self.inContext];
    }
    
    vImage_Buffer srcBuffer = self.srcBuffer;
	vImage_Buffer destBuffer = self.destBuffer;
    
    switch (self.type) {
        case ALDColorBlindEffectTypeProtanopia:
            convertToProtanopia(&srcBuffer, &destBuffer, kvImageBackgroundColorFill);
            break;
        case ALDColorBlindEffectTypeDeuteranopia:
        {
            convertToDeuteranopia(&srcBuffer, &destBuffer, kvImageBackgroundColorFill);
            break;
        }
        case ALDColorBlindEffectTypeTritanopia:
        {
            convertToTritanopia(&srcBuffer, &destBuffer, kvImageBackgroundColorFill);
            break;
        }
        case ALDColorBlindEffectTypeDog:
        {
            convertToDog(&srcBuffer, &destBuffer, kvImageBackgroundColorFill);
            break;
        }
        case ALDColorBlindEffectTypeRodMonochromacy:
        {
            convertToRodMonochromacy(&srcBuffer, &destBuffer, kvImageBackgroundColorFill);
            break;
        }
        case ALDColorBlindEffectTypeConeMonochromacyLRed:
        {
            convertToMonochromacyLRed(&srcBuffer, &destBuffer, kvImageBackgroundColorFill);
            break;
        }
        case ALDColorBlindEffectTypeConeMonochromacyMGreen:
        {
            convertToConeMonochromacyMGreen(&srcBuffer, &destBuffer, kvImageBackgroundColorFill);
            break;
        }
        case ALDColorBlindEffectTypeConeMonochromacySBlue:
        {
            convertToConeMonochromacySBlue(&srcBuffer, &destBuffer, kvImageBackgroundColorFill);
            break;
        }
            
        default:
            break;
    }
    
    BOOL useOutContext = NO;
    if (self.type != ALDColorBlindEffectTypeNone) {
        vImage_Buffer tmpBuffer = destBuffer;
        destBuffer = srcBuffer;
        srcBuffer = tmpBuffer;
        useOutContext = YES;
    }
    
    if (self.blurAmount > 0) {
        useOutContext = YES;
        blur(&srcBuffer, &destBuffer, kvImageEdgeExtend, self.cachedBlurAmount);
    }
    
    CGContextRef finalContext = useOutContext ? outContext : inContext;
    
    CGImageRef outImage = CGBitmapContextCreateImage(finalContext);
	self.overlayWindow.layer.contents = (__bridge id)(outImage);
	CGImageRelease(outImage);
    
    CGContextRelease(inContext);
	CGContextRelease(outContext);
}

void blur(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags, int kernelSize)
{
    unsigned char bgColor[4] = { 0, 0, 0, 0 };
    vImageBoxConvolve_ARGB8888(srcBuffer, destBuffer, NULL, 0, 0, kernelSize, kernelSize, bgColor, flags);
    vImageBoxConvolve_ARGB8888(destBuffer, srcBuffer, NULL, 0, 0, kernelSize, kernelSize, bgColor, flags);
    vImageBoxConvolve_ARGB8888(srcBuffer, destBuffer, NULL, 0, 0, kernelSize, kernelSize, bgColor, flags);
}

void convertToProtanopia(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags)
{
    const int16_t matrix[16] =
    {   52,    42,     2,     0,
        253,   202,    -3,    0,
        -49,   11,    255,    0,
        0,     0,      0,     256 };
    vImageMatrixMultiply_ARGB8888(srcBuffer, destBuffer, matrix, 255, NULL, NULL, flags);
}

void convertToDeuteranopia(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags)
{
    const int16_t matrix[16] =
    { 110,    86,   -6,    0,
        183,   146,    7,    0,
        -38,    23,  254,    0,
        0,     0,    0,   255 };
    vImageMatrixMultiply_ARGB8888(srcBuffer, destBuffer, matrix, 255, NULL, NULL, flags);
}

void convertToTritanopia(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags)
{
    const int16_t matrix[16] =
    { 248,     6,    -16,    0,
        29,   209,    225,    0,
        -21,    41,     46,    0,
        0,     0,      0,  255 };
    vImageMatrixMultiply_ARGB8888(srcBuffer, destBuffer, matrix, 255, NULL, NULL, flags);
}

void convertToDog(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags)
{
    const int16_t matrix[16] =
    { 81,    64,   -2,    0,
        218,   174,    2,    0,
        -44,    17,  255,    0,
        0,     0,    0,   255 };
    vImageMatrixMultiply_ARGB8888(srcBuffer, destBuffer, matrix, 255, NULL, NULL, flags);
}

void convertToRodMonochromacy(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags)
{
    const int16_t matrix[16] =
    {  76,    76,     76,     0,
        150,   150,    150,     0,
        29,    29,     29,     0,
        0,     0,      0,   255 };
    vImageMatrixMultiply_ARGB8888(srcBuffer, destBuffer, matrix, 255, NULL, NULL, flags);
}

void convertToMonochromacyLRed(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags)
{
    const int16_t matrix[16] =
    { 87,    87,     87,     0,
        148,   148,    148,     0,
        20,    20,     20,     0,
        0,     0,      0,   255 };
    vImageMatrixMultiply_ARGB8888(srcBuffer, destBuffer, matrix, 255, NULL, NULL, flags);
}

void convertToConeMonochromacyMGreen(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags)
{
    const int16_t matrix[16] =
    { 38,    38,     38,     0,
        184,   184,    184,     0,
        32,    32,     32,     0,
        0,     0,      0,   255 };
    vImageMatrixMultiply_ARGB8888(srcBuffer, destBuffer, matrix, 255, NULL, NULL, flags);
}

void convertToConeMonochromacySBlue(const vImage_Buffer *srcBuffer, const vImage_Buffer *destBuffer, vImage_Flags flags)
{
    const int16_t matrix[16] =
    {   9,    9,     9,     0,
        29,   29,    29,    0,
        217,  217,   217,   0,
        0,    0,     0,     255 };
    vImageMatrixMultiply_ARGB8888(srcBuffer, destBuffer, matrix, 255, NULL, NULL, flags);
}

- (void)dealloc
{
    CGContextRelease(self.inContext);
    CGContextRelease(self.outContext);
}

@end
