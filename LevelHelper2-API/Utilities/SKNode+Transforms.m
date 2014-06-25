//
//  SKNode+Transforms.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 25/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "SKNode+Transforms.h"

@implementation SKNode (Transforms)

#pragma mark - TRANSFORMS
-(CGSize)size{
    return CGSizeMake(64, 64);
}

-(CGRect)rect{
    CGSize size = [self size];
    
    return CGRectMake(-size.width*0.5,
                      -size.height*0.5,
                      size.width,
                      size.height);
}

-(CGPoint)anchor{
    return CGPointMake(0.5, 0.5);
}

- (CGPoint)anchorPointInPoints{
    CGPoint anc = [self anchor];
    CGSize size = [self size];
    return CGPointMake(size.width*anc.x, size.height*anc.y);
}

- (CGAffineTransform)nodeToParentTransform
{
    CGSize size = [self size];
    
    
    float anchorPointX = size.width*[self anchor].x;
    float anchorPointY = size.height*[self anchor].y;
    
    float centerPointX = size.width*0.5;
    float centerPointY = size.height*0.5;
    
    CGPoint pos = [self position];
    float rot = [self zRotation];
    
    float xScl = [self xScale];
    float yScl = [self yScale];
    


    CGAffineTransform nodeTransform = CGAffineTransformMakeTranslation(pos.x, pos.y);
    
    nodeTransform = CGAffineTransformRotate(nodeTransform, rot);
    nodeTransform = CGAffineTransformScale(nodeTransform, xScl, yScl);
    nodeTransform = CGAffineTransformTranslate(nodeTransform,
                                               -anchorPointX + centerPointX,
                                               -anchorPointY + centerPointY);
    
    return nodeTransform;
}

- (CGAffineTransform)parentToNodeTransform
{
    return CGAffineTransformInvert([self nodeToParentTransform]);
}

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = [self nodeToParentTransform];
    
	for (SKNode *p = [self parent]; p != nil/* && ![p isKindOfClass:[SKScene class]]*/; p = p.parent)
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
    
	return t;
}

- (CGAffineTransform)worldToNodeTransform
{
    return CGAffineTransformInvert([self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
    return CGPointApplyAffineTransform(worldPoint, [self worldToNodeTransform]);
}

- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint
{
    CGPoint pt =  [self convertToNodeSpace:worldPoint];
    CGRect sprRect = [self rect];
    return CGPointMake(pt.x - sprRect.origin.x,
                       pt.y - sprRect.origin.y);
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint
{
    return CGPointApplyAffineTransform(nodePoint, [self nodeToWorldTransform]);
}

-(CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint
{
    CGRect sprRect = [self rect];
    
    CGPoint pt = CGPointMake(nodePoint.x + (sprRect.origin.x + [self anchor].x * sprRect.size.width),
                             nodePoint.y + (sprRect.origin.y + [self anchor].y * sprRect.size.height));
    
    return [self convertToWorldSpace:pt];
}

- (CGPoint)convertToUnitPoint:(CGPoint)nodePoint
{
    CGSize size = [self size];
    nodePoint.x = nodePoint.x/size.width;
    nodePoint.y = nodePoint.y/size.height;
    return nodePoint;
}

- (CGPoint)lh_convertPoint:(CGPoint)point fromNode:(SKNode *)node{
    CGPoint localPt = [node convertToWorldSpace:point];
    return [self convertToNodeSpace:localPt];
}
- (CGPoint)lh_convertPoint:(CGPoint)point toNode:(SKNode *)node{
    
    CGPoint worldPt = [self convertToWorldSpace:point];
    return [node convertToNodeSpace:worldPt];
}

@end
