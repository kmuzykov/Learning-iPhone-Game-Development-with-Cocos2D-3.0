//
//  Bird.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "Bird.h"
#import "cocos2d.h"
#import "CCAnimation.h"

@implementation Bird
{
    //Times the bird will return to the screen before flying away (and the player loses life)
    int _timesToVisit;
}

-(instancetype)initWithBirdType:(BirdType)typeOfBird
{
    //Setting sprite name depending on bird type.
    NSString *birdImageName;
    switch (typeOfBird) {
        case BirdTypeBig:
            birdImageName = @"bird_big_0.png";
            break;
        case BirdTypeMedium:
            birdImageName = @"bird_middle_0.png";
            break;
        case BirdTypeSmall:
            birdImageName = @"bird_small_0.png";
            break;
        default:
            CCLOG(@"Unknown bird type, using small bird!");
            birdImageName = @"bird_small_0.png";
            break;
    }
    
    //Using CCSprite's super method, since we want to reuse
    //CCSprite's functionality to draw ourselves(bird),
    //but want to add some functionality, and thus subclassed CCSprite.
    if (self = [super initWithImageNamed:birdImageName])
    {
        _timesToVisit = 1;
        self.birdState = BirdStateFlyingIn;
        
        //Saving bird type in case we need to know which bird type is this.
        self.birdType = typeOfBird;
        
        //Starting animation straight away.
        [self animateFly];
    }
    
    return self;
}

-(void)animateFly
{
    //Finding out frames format, depending on current bird type.
    NSString *animFrameNameFormat;
    switch (self.birdType) {
        case BirdTypeBig:
            animFrameNameFormat = @"bird_big_%d.png";
            break;
        case BirdTypeMedium:
            animFrameNameFormat = @"bird_middle_%d.png";
            break;
        case BirdTypeSmall:
            animFrameNameFormat = @"bird_small_%d.png";
            break;
        default:
            CCLOG(@"Unknown bird type, using small bird animation!");
            animFrameNameFormat = @"bird_small_%d.png";
            break;
    }
    
    //Creating mutable array (we know that there will be 7 frames)
    NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:7];
    
    //Generating frame names, by using stringWithFormat and getting corresponding frames.
    for (int i = 0; i < 7 ; i++)
    {
        NSString *currentFrameName  = [NSString stringWithFormat:animFrameNameFormat, i];
        CCSpriteFrame *animationFrame = [CCSpriteFrame frameWithImageNamed:currentFrameName];
        [animFrames addObject:animationFrame];
    }
    
    //Creating animation.
    CCAnimation* flyAnimation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.1f];
    
    //Creating action that will play the animation.
    CCActionAnimate *flyAnimateAction = [CCActionAnimate actionWithAnimation:flyAnimation];
    
    //Wrapping animate action with action that will repeat it forever.
    CCActionRepeatForever *flyForever = [CCActionRepeatForever actionWithAction:flyAnimateAction];
    
    //Running action.
    [self runAction:flyForever];
}

-(int)removeBird:(BOOL)hitByArrow
{
    //Stoping the bird from flying further.
    [self stopAllActions];
    
    //We'll update this to actual value if the bird was hit by an arrow,
    //otherwise we'll return 0.
    int score = 0;
    
    if (hitByArrow)
    {
        //Setting state to dead.
        self.birdState = BirdStateDead;

        //Calculating how many points the player scored based
        //on how many times the bird visited the game field.
        score = (_timesToVisit + 1) * 5;
        
        //Displaying floating points label.
        [self displayPoints:score];
    }
    else
    {
        self.birdState = BirdStateFlewOut;
    }

    //Removing the bird.
    [self removeFromParentAndCleanup:YES];
    
    //Returning score to add it to the game total score.
    return score;
}

-(void)turnaround
{
    //Fliping the bird.
    self.flipX = !self.flipX;
    
    //Decreasing counter.
    if (self.flipX)
        _timesToVisit--;
    
    //If visited enough times, setting the bird to fly away.
    if (_timesToVisit <= 0)
        self.birdState = BirdStateFlyingOut;
}

-(void)displayPoints:(int)amount
{
    //1: Creating bitmap font using points.fnt
    NSString *ptsStr = [NSString stringWithFormat:@"%d", amount];
    CCLabelBMFont *ptsLabel = [CCLabelBMFont labelWithString:ptsStr fntFile:@"points.fnt"];
    ptsLabel.position = self.position;
    
    //2: Finding scene (which is parent of batch node, and batch node is parent for the bird)
    CCNode *batchNode = self.parent;
    CCNode *scene = batchNode.parent;
    [scene addChild:ptsLabel];
    
    //3: Configuring bezier curve.
    float xDelta1 = 10;
    float yDelta1 = 5;
    float yDelta2 = 10;
    float yDelta4 = 20;
	ccBezierConfig curve;
	curve.controlPoint_1 = ccp(ptsLabel.position.x - xDelta1, ptsLabel.position.y + yDelta1);
	curve.controlPoint_2 = ccp(ptsLabel.position.x + xDelta1, ptsLabel.position.y + yDelta2);
	curve.endPosition =    ccp(ptsLabel.position.x,           ptsLabel.position.y + yDelta4);
    
    //4: Total duration of label floating
    float baseDuration = 1.0f;
    
    //5: Move along the bezier curve
	CCActionBezierTo *bezierMove = [CCActionBezierTo actionWithDuration:baseDuration bezier:curve];
    
    //6: Start to fade out in final 25% of movement
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:baseDuration * 0.25f];
    
    //7: Delaying fading out, to allow the label move 75% of the baseDuration fully visible
    CCActionDelay *delay = [CCActionDelay actionWithDuration:baseDuration * 0.75f];
    
    //8: Creating sequence: delay, then fade out.
    CCActionSequence *delayAndFade = [CCActionSequence actions:delay, fadeOut, nil];
    
    //9: Creating action to run move + (delay then fade) actions simultaneously.
    CCActionSpawn *bezieAndFadeOut = [CCActionSpawn actions:bezierMove, delayAndFade, nil];
    
    //10: Removing label in the end.
    CCActionRemove *removeInTheEnd = [CCActionRemove action];
    
    //11: Creating final complex sequence
  	CCActionSequence *actions = [CCActionSequence actions:bezieAndFadeOut, removeInTheEnd,  nil];
	
    //12: Running the final sequence.
    [ptsLabel runAction:actions];
}

@end
