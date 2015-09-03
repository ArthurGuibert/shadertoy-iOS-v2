//
//  Utils.m
//  shadertoy
//
//  Created by Reinder Nijhoff on 31/08/15.
//  Copyright (c) 2015 Reinder Nijhoff. All rights reserved.
//

#import "Utils.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

void trackEvent( NSString *category, NSString *action, NSString *label ) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category    // Event category (required)
                                                      action:action
                                                       label:label           // Event label
                                                       value:nil] build]];   // Event value
}

void trackScreen( NSString *screen ) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screen];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

@implementation UIImage (Utils)

- (UIImage *) setShaderWatermarkText:(APIShaderObject *)shader {
    return self;
//    return [self drawWatermarkText:[@"\"" stringByAppendingString:[[shader.shaderName stringByAppendingString:@"\" by "] stringByAppendingString:shader.username]]];
}

- (UIImage *) drawWatermarkText:(NSString*)text {
    CGSize imageSize = self.size;
    
    UIColor *textColor = [UIColor colorWithWhite:1.0 alpha:.8];
    UIFont *font = [UIFont systemFontOfSize:imageSize.height * 0.045];
    CGFloat paddingX = imageSize.height * 0.01;
    CGFloat paddingY = imageSize.height * 0.01;
    
    NSDictionary *attr = @{NSForegroundColorAttributeName: textColor, NSFontAttributeName: font};
    CGSize textSize = [text sizeWithAttributes:attr];
    CGRect textRect = CGRectMake(imageSize.width - textSize.width - paddingX, imageSize.height - textSize.height - paddingY, textSize.width, textSize.height);
    
    // Create the image
    UIGraphicsBeginImageContext(imageSize);
    [self drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    CGContextSetShadow(UIGraphicsGetCurrentContext(), CGSizeMake(0.0f, 0.0f), imageSize.height * 0.003);
    [text drawInRect:CGRectIntegral(textRect) withAttributes:attr];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *) resizedImageWithMaximumSize: (CGSize) size {
    CGImageRef imgRef = [self CGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio < height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio))];
}

- (UIImage *) drawImageInBounds: (CGRect) bounds {
    UIGraphicsBeginImageContext(bounds.size);
    [self drawInRect: bounds];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (CGImageRef) CGImageWithCorrectOrientation {
    if (self.imageOrientation == UIImageOrientationDown) {
        //retaining because caller expects to own the reference
        CGImageRetain([self CGImage]);
        return [self CGImage];
    }
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, 90 * M_PI/180);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, -90 * M_PI/180);
    } else if (self.imageOrientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, 180 * M_PI/180);
    }
    
    [self drawAtPoint:CGPointMake(0, 0)];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    return cgImage;
}

@end