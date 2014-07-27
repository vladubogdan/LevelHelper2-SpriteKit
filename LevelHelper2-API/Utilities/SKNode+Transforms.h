//
//  SKNode+Transforms.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 25/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKNode (Transforms)

- (CGPoint)anchorPointInPoints;

- (CGAffineTransform)nodeToParentTransform;
- (CGAffineTransform)parentToNodeTransform;
- (CGAffineTransform)nodeToWorldTransform;
- (CGAffineTransform)worldToNodeTransform;

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint;
- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint;

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint;
- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint;

- (CGPoint)convertToUnitPoint:(CGPoint)nodePoint;

- (CGPoint)lh_convertPoint:(CGPoint)point fromNode:(SKNode *)node;
- (CGPoint)lh_convertPoint:(CGPoint)point toNode:(SKNode *)node;

-(CGPoint)convertToWorldScale:(CGPoint)nodeScale;
-(CGPoint)convertToNodeScale:(CGPoint)worldScale;

-(float)globalAngleFromLocalAngle:(float)la;
-(float)localAngleFromGlobalAngle:(float)ga;

@end
