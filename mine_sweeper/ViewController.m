//
//  ViewController.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/24/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)layMinesButtonClicked:(UIButton *)sender
{

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    int rows;
    int columns;
    int numberOfMines;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        rows = 9;
        columns = 9;
        numberOfMines = 16;
    }else{
        rows = 16;
        columns = 16;
        numberOfMines = 40;
    }
    MineBoard *mineBoard = [[MineBoard alloc] initWithRows:rows columns:columns];
    [mineBoard layMines:numberOfMines];
    
    PlayerBoard *playerBoard = [[PlayerBoard alloc] initWithMineBoard:mineBoard];
    [self.playerBoardView setPlayerBoard:playerBoard];
    
    [self.layMinesButton addTarget:self action:@selector(layMinesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
