//
//  ViewController.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/24/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineBoard.h"
#import "PlayerBoard.h"
#import "PlayerBoardView.h"

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet PlayerBoardView *playerBoardView;
@property (weak, nonatomic) IBOutlet UIButton *layMinesButton;


@end

