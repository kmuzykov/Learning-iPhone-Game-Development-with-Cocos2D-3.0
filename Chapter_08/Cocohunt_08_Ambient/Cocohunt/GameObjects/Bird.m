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
#import "AudioManager.h"

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

-(void)animateFall
{
    //Falling
    CGPoint fallDownOffScreenPoint = ccp(self.position.x, -self.boundingBox.size.height);
    CCActionMoveTo *fallOffScreen = [CCActionMoveTo actionWithDuration:2.0f position:fallDownOffScreenPoint];
    CCActionRemove *removeWhenDone = [CCActionRemove action];
    CCActionSequence *fallSequence = [CCActionSequence actions: fallOffScreen, removeWhenDone, nil];
    [self runAction:fallSequence];
    
    //Rotating
    CCActionRotateBy *rotate = [CCActionRotateBy actionWithDuration:0.1 angle:60];
    CCActionRepeatForever *rotateForever = [CCActionRepeatForever actionWithAction:rotate];
    [self runAction:rotateForever];
}

-(void)explodeFeathers
{
    //1: Total amount of particles
    int totalNumberOfFeathers = 100;
    
    //2: Creating partucle system
    CCParticleSystem *explosion = [CCParticleSystem particleWithTotalParticles:totalNumberOfFeathers];
    
    //3: Setting position to the bird center
    explosion.position = self.position;
    
    //4: Using gravity mode for explosion
    explosion.emitterMode = CCParticleSystemModeGravity;
    
    //5: Making feathers to fall down a bit, since they still affected by world's gravity.
    explosion.gravity = ccp(0, -200.0f);
    
    //6: Explosion should have really small duration.
    explosion.duration = 0.1f;
    
    //7: Calculating rate
    explosion.emissionRate = totalNumberOfFeathers/explosion.duration;
    
    //8: Setting texture and start and end color. Feathers will be white, slowly fading out to 0 alpha.
    explosion.texture = [CCTexture textureWithFile:@"feather.png"];
    explosion.startColor = [CCColor whiteColor];
    explosion.endColor = [[CCColor whiteColor] colorWithAlphaComponent:0.0f];
    
    //9: Setting parameter of how far and how fast the feathers will move away from center.
    explosion.life = 0.25f;
    explosion.lifeVar = 0.75f;
    explosion.speed = 60;
    explosion.speedVar = 80;
    
    //10: Setting start/end size of particles.
    explosion.startSize = 16;
    explosion.startSizeVar = 4;
    explosion.endSize = CCParticleSystemStartSizeEqualToEndSize;
    explosion.endSizeVar = 8;
    
    //11: Adding random starting angle and random rotation.
    explosion.angleVar = 360;
    explosion.startSpinVar = 360;
    explosion.endSpinVar = 360;
    
    //12: Telling particle system to remove it from the scene automatically in the end (no need to keep reference)
    explosion.autoRemoveOnFinish = YES;
    
    //13: Setting how particles should blend with background.
    ccBlendFunc blendFunc;
    blendFunc.src = GL_SRC_ALPHA;
    blendFunc.dst = GL_ONE;
    explosion.blendFunc = blendFunc;
    
    //14: Finding scene and addint particle system to it.
    CCNode *batchNode = self.parent;
    CCNode *scene = batchNode.parent;
    [scene addChild:explosion];
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
        
        //Falling and rotating
        [self animateFall];
        
        //Adding particle system with feathers exposion
        [self explodeFeathers];
        
        [[AudioManager sharedAudioManager] playSoundEffect:@"bird_hit.mp3"];
    }
    else
    {
        self.birdState = BirdStateFlewOut;
        
        //Removing the bird immediatly only in case it flew away,
        //since if it is hit by an arrow it still needs to fall rotating.
        [self removeFromParentAndCleanup:YES];
    }
    
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
    //Creating bitmap font using points.fnt
    NSString *ptsStr = [NSString stringWithFormat:@"%d", amount];
    CCLabelBMFont *ptsLabel = [CCLabelBMFont labelWithString:ptsStr fntFile:@"points.fnt"];
    ptsLabel.position = self.position;
    
    //Finding scene (which is parent of batch node, and batch node is parent for the bird)
    CCNode *batchNode = self.parent;
    CCNode *scene = batchNode.parent;
    [scene addChild:ptsLabel];
    
    //Configuring bezier curve.
    float xDelta1 = 10;
    float yDelta1 = 5;
    float yDelta2 = 10;
    float yDelta4 = 20;
	ccBezierConfig curve;
	curve.controlPoint_1 = ccp(ptsLabel.position.x - xDelta1, ptsLabel.position.y + yDelta1);
	curve.controlPoint_2 = ccp(ptsLabel.position.x + xDelta1, ptsLabel.position.y + yDelta2);
	curve.endPosition =    ccp(ptsLabel.position.x,           ptsLabel.position.y + yDelta4);
    
    //Total duration of label floating
    float baseDuration = 1.0f;
    
    //Move along the bezier curve
	CCActionBezierTo *bezierMove = [CCActionBezierTo actionWithDuration:baseDuration bezier:curve];
    
    //Start to fade out in final 25% of movement
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:baseDuration * 0.25f];
    
    //Delaying fading out, to allow the label move 75% of the baseDuration fully visible
    CCActionDelay *delay = [CCActionDelay actionWithDuration:baseDuration * 0.75f];
    
    //Creating sequence: delay, then fade out.
    CCActionSequence *delayAndFade = [CCActionSequence actions:delay, fadeOut, nil];
    
    //Creating action to run move + (delay then fade) actions simultaneously.
    CCActionSpawn *bezieAndFadeOut = [CCActionSpawn actions:bezierMove, delayAndFade, nil];
    
    //Removing label in the end.
    CCActionRemove *removeInTheEnd = [CCActionRemove action];
    
    //Creating final complex sequence
  	CCActionSequence *actions = [CCActionSequence actions:bezieAndFadeOut, removeInTheEnd,  nil];
	
    //Running the final sequence.
    [ptsLabel runAction:actions];
}

@end
