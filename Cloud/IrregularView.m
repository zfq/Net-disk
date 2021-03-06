//
//  IrregularView.m
//  IrregularImages
//
//  Created by OranWu on 13-4-10.
//  Copyright (c) 2013年 Oran Wu. All rights reserved.
//

#import "IrregularView.h"
@interface IrregularView ()
@end

@implementation IrregularView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setMask{
    self.tempPath = [[UIBezierPath alloc] init];
    
    if (self.cornerRadius>0) {
        //calculate the Turning point of every corner.
        NSMutableArray *muaarray = [NSMutableArray array];
        for (int i=0; i < [self.trackPoints count]; i++) {
            CGPoint pointStart, pointEnd;
            if (i<[self.trackPoints count]-1) {
                pointStart = [[self.trackPoints objectAtIndex:i] CGPointValue];
                pointEnd = [[self.trackPoints objectAtIndex:i+1] CGPointValue];
                [muaarray addObject:[NSValue valueWithCGPoint:pointStart]];
            }else if (i==[self.trackPoints count]-1) {
                pointStart = [[self.trackPoints objectAtIndex:i] CGPointValue];
                pointEnd = [[self.trackPoints objectAtIndex:0] CGPointValue];
                [muaarray addObject:[NSValue valueWithCGPoint:pointStart]];
            }
            
            if (fabsf(pointStart.x-pointEnd.x)<0.2) {
                BOOL boolY = pointEnd.y-pointStart.y>0;
                pointStart.y = pointStart.y + self.cornerRadius*(boolY? 1 : -1);
                pointEnd.y = pointEnd.y - self.cornerRadius*(boolY? 1 : -1);
                
            }else if (fabsf(pointStart.y-pointEnd.y)<0.2){
                BOOL boolX = pointEnd.x-pointStart.x>0;
                pointStart.x = pointStart.x + self.cornerRadius*(boolX? 1 : -1);
                pointEnd.x = pointEnd.x - self.cornerRadius*(boolX? 1 : -1);
            }else{
                float tempL = (pointEnd.y-pointStart.y)/(pointEnd.x-pointStart.x);
                float cutX = sqrtf(self.cornerRadius*self.cornerRadius/(1+tempL*tempL));
                float cutY = fabsf(cutX*tempL);
                
                BOOL boolX = pointEnd.x-pointStart.x>0;
                BOOL boolY = pointEnd.y-pointStart.y>0;
                
                pointStart.x = pointStart.x + cutX*(boolX? 1 : -1);
                pointStart.y = pointStart.y + cutY*(boolY? 1 : -1);
                pointEnd.x = pointEnd.x - cutX*(boolX? 1 : -1);
                pointEnd.y = pointEnd.y - cutY*(boolY? 1 : -1);
            }
            [muaarray addObject:[NSValue valueWithCGPoint:pointStart]];
            [muaarray addObject:[NSValue valueWithCGPoint:pointEnd]];
        }
        
        //calculate the control point of every corner.
        NSMutableArray *arrayM = [NSMutableArray array];
        for (int i = 1; i<[muaarray count]; i=i+3) {
            CGPoint firstP;
            CGPoint nextP;
            CGPoint pointP;
            if (i<[muaarray count]-3) {
                firstP = [[muaarray objectAtIndex:i+1] CGPointValue];
                nextP  = [[muaarray objectAtIndex:i+3] CGPointValue];
                pointP  = [[muaarray objectAtIndex:i+2] CGPointValue];
            }else if (i==[muaarray count]-2){
                firstP = [[muaarray objectAtIndex:i+1] CGPointValue];
                nextP  = [[muaarray objectAtIndex:1] CGPointValue];
                pointP  = [[muaarray objectAtIndex:0] CGPointValue];
            }
            [arrayM addObject:[NSValue valueWithCGPoint:firstP]];
            [arrayM addObject:[NSValue valueWithCGPoint:pointP]];
            [arrayM addObject:[NSValue valueWithCGPoint:nextP]];
        }
        
        //set the path of maskLayer.
        for (int i=0; i <[arrayM count]; i=i+3) {
            CGPoint pathPoint = [[arrayM objectAtIndex:i] CGPointValue];
            if (i==0) {
                [self.tempPath moveToPoint:pathPoint];
            }else{
                [self.tempPath addLineToPoint:pathPoint];
            }
            
            CGPoint cPoint = [[arrayM objectAtIndex:i+1] CGPointValue];
            CGPoint endPoint = [[arrayM objectAtIndex:i+2] CGPointValue];
            [self.tempPath addQuadCurveToPoint:endPoint controlPoint:cPoint];
            
            if (i==[arrayM count]-3){
                pathPoint = [[arrayM objectAtIndex:0] CGPointValue];
                [self.tempPath addLineToPoint:pathPoint];
            }
        }
    }else{
        //set the path of maskLayer.
        for (int i=0; i <[self.trackPoints count]; i++) {
            CGPoint pathPoint = [[self.trackPoints objectAtIndex:i] CGPointValue];
            if (i==0) {
                [self.tempPath moveToPoint:pathPoint];
            }else{
                [self.tempPath addLineToPoint:pathPoint];
            }
            
            if (i==[self.trackPoints count]-1) {
                pathPoint = [[self.trackPoints objectAtIndex:0] CGPointValue];
                [self.tempPath addLineToPoint:pathPoint];
            }
        }
    }

    //do mask action.
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [self.tempPath CGPath];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.frame = self.frame;

    [maskLayer setShadowOffset:CGSizeMake(4, 3)];
    [maskLayer setShadowOpacity:0.8];

    self.layer.mask = maskLayer;
    
    CAShapeLayer *maskBorderLayer = [CAShapeLayer layer];
    maskBorderLayer.path = [self.tempPath CGPath];
    maskBorderLayer.fillColor = [[UIColor clearColor] CGColor];
    maskBorderLayer.strokeColor = [self.borderColor CGColor];
    maskBorderLayer.lineWidth = self.borderWidth;
    
    [self.layer addSublayer:maskBorderLayer];
    [self.layer setShadowColor:[[UIColor grayColor] CGColor]];
    [self.layer setShadowOffset:CGSizeMake(4, 3)];
    [self.layer setShadowOpacity:0.8];
}



@end
