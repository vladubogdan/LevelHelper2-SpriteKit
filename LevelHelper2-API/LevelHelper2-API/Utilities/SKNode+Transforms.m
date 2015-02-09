//
//  SKNode+Transforms.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 25/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "SKNode+Transforms.h"
#import "LHUtils.h"
#import "LHGameWorldNode.h"
#import "LHUINode.h"
#import "LHBackUINode.h"

@implementation SKNode (Transforms)

#pragma mark - TRANSFORMS
-(CGSize)contentSize{
    if([self respondsToSelector:@selector(size)]){
        return [(SKSpriteNode*)self size];
    }
    
    if([self respondsToSelector:@selector(lhContentSize)]){
        return [(id<LHNodeProtocol>)self lhContentSize];
    }
    
    return CGSizeMake(32, 32);
}

-(CGPoint)nodeAnchor{
    
    if([self respondsToSelector:@selector(anchorPoint)]){
        return [(SKSpriteNode*)self anchorPoint];
    }
    
    if([self respondsToSelector:@selector(lhAnchor)]){
        return [(id<LHNodeProtocol>)self lhAnchor];
    }
    
    return CGPointMake(0.5, 0.5);
}

-(CGRect)rect{
    
    CGSize size = [self contentSize];
    if([self isKindOfClass:[SKSpriteNode class]]){
        size = [(SKSpriteNode*)self size];
    }
    
    return CGRectMake(-size.width*0.5,
                      -size.height*0.5,
                      size.width,
                      size.height);
}

- (CGPoint)anchorPointInPoints{
    CGPoint anc = [self nodeAnchor];
    CGSize size = [self contentSize];
    if([self isKindOfClass:[SKSpriteNode class]]){
        size = [(SKSpriteNode*)self size];
    }
    return CGPointMake(size.width*anc.x, size.height*anc.y);
}

- (CGAffineTransform)nodeToParentTransform
{
    CGSize size = [self contentSize];
    if([self isKindOfClass:[SKSpriteNode class]]){
        size = [(SKSpriteNode*)self size];
    }
    
    CGPoint anc = [self nodeAnchor];
    CGFloat anchorPointX = size.width*anc.x;
    CGFloat anchorPointY = size.height*anc.y;
    
    CGFloat centerPointX = size.width*0.5;
    CGFloat centerPointY = size.height*0.5;
    
    CGPoint pos = [self position];
    CGFloat rot = [self zRotation];
    
    CGFloat xScl = [self xScale];
    CGFloat yScl = [self yScale];
    
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
    
//	for (SKNode *p = [self parent]; p != nil/* && ![p isKindOfClass:[SKScene class]]*/; p = p.parent)
//		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);

    for (SKNode *p = [self parent];
         p != nil && ![p isKindOfClass:[LHGameWorldNode class]] && ![p isKindOfClass:[LHUINode class]] && ![p isKindOfClass:[LHBackUINode class]];
         p = p.parent)
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
    
    CGPoint anc = [self nodeAnchor];
    
    CGPoint pt = CGPointMake(nodePoint.x + (sprRect.origin.x + anc.x * sprRect.size.width),
                             - nodePoint.y + (sprRect.origin.y + anc.y * sprRect.size.height));
    
    return [self convertToWorldSpace:pt];
}

- (CGPoint)convertToUnitPoint:(CGPoint)nodePoint
{
    CGSize size = [self contentSize];
    if([self isKindOfClass:[SKSpriteNode class]]){
        size = [(SKSpriteNode*)self size];
    }
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

-(CGPoint)convertToWorldScale:(CGPoint)nodeScale{
    for (SKNode *p = self.parent; p != nil && ![p isKindOfClass:[SKScene class]]; p = p.parent)
    {
        CGPoint scalePt = CGPointMake(p.xScale, p.yScale);
        nodeScale.x *= scalePt.x;
        nodeScale.y *= scalePt.y;
    }
    return nodeScale;
}
-(CGPoint)convertToNodeScale:(CGPoint)worldScale{
    for (SKNode *p = self.parent; p != nil && ![p isKindOfClass:[SKScene class]]; p = p.parent)
    {
        CGPoint scalePt = CGPointMake(p.xScale, p.yScale);
        worldScale.x /= scalePt.x;
        worldScale.y /= scalePt.y;
    }
    return worldScale;
}

-(float)globalAngleFromLocalAngle:(float)la{
    SKNode* prnt = [self parent];
    while(prnt && ![prnt isKindOfClass:[SKScene class]]){
        la += [prnt zRotation];
        prnt = [prnt parent];
    }
    return la;
}

-(float)localAngleFromGlobalAngle:(float)ga{
    SKNode* prnt = [self parent];
    while(prnt && ![prnt isKindOfClass:[SKScene class]]){
        ga -= [prnt zRotation];
        prnt = [prnt parent];
    }
    return ga;
}

-(float) convertToWorldAngle:(float)localRadians
{
    CGPoint rot = LHPointForAngle(localRadians);
    CGPoint worldPt = [self convertToWorldSpace:rot];
    CGPoint worldOriginPt = [self convertToWorldSpace:CGPointZero];
    CGPoint worldVec = LHPointSub(worldPt, worldOriginPt);
    return LHPointToAngle(worldVec);
}

-(float) convertToNodeAngle:(float)worldRadians
{
    CGPoint rot = LHPointForAngle(worldRadians);
    CGPoint nodePt = [self convertToNodeSpace:rot];
    CGPoint nodeOriginPt = [self convertToNodeSpace:CGPointZero];
    CGPoint nodeVec = LHPointSub(nodePt, nodeOriginPt);
    return LHPointToAngle(nodeVec);
}


-(CGPoint)unitForGlobalPosition:(CGPoint)globalpt
{
    CGPoint local = [self convertToNodeSpace:globalpt];
    
    CGSize sizer = [self contentSize];
    if([self isKindOfClass:[SKSpriteNode class]]){
        sizer = [(SKSpriteNode*)self size];
    }
    
    float centerPointX = sizer.width*0.5;
    float centerPointY = sizer.height*0.5;
    
    local.x += centerPointX;
    local.y += centerPointY;
    
    return  CGPointMake(local.x/sizer.width, local.y/sizer.height);
}

@end
