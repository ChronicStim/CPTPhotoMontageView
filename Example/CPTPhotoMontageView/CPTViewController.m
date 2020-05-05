//
//  CPTViewController.m
//  CPTPhotoMontageView
//
//  Created by support@chronicstimulation.com on 05/03/2020.
//  Copyright (c) 2020 support@chronicstimulation.com. All rights reserved.
//

#import "CPTViewController.h"
#import "CPTMontageFlowLayout.h"
#import "CPTCollectionViewCell.h"

#define NUMBER_OF_IMAGES_INITIAL 5
#define NUMBER_OF_IMAGES_MIN 1
#define NUMBER_OF_IMAGES_MAX 24

#define HEADER_SIZE 0.0f
#define FOOTER_SIZE 0.0f

@interface CPTViewController ()
< UICollectionViewDelegate, UICollectionViewDataSource >

@property (nonatomic, assign) NSInteger numberOfImages;
@property (nonatomic, strong) NSArray *images;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISlider *countSlider;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)countSliderValueChanged:(id)sender;
- (IBAction)scrollDirectionChanged:(UISegmentedControl *)sender;

@end

@implementation CPTViewController

@synthesize numberOfImages = _numberOfImages;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (int i = 1; i <= NUMBER_OF_IMAGES_MAX; i++) {
            NSString *imageName = [NSString stringWithFormat:@"photo-%02d.jpg", i];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        _images = [images copy];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.numberOfImages = NUMBER_OF_IMAGES_INITIAL;
    
    self.countSlider.minimumValue = (float)NUMBER_OF_IMAGES_MIN;
    self.countSlider.maximumValue = (float)NUMBER_OF_IMAGES_MAX;
    [self.countSlider setValue:(float)self.numberOfImages animated:NO];
    
    [self initializeLayout];
}

-(void)initializeLayout;
{
    CPTMontageFlowLayout *layout = (CPTMontageFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
}

-(NSInteger)numberOfImages;
{
    return _numberOfImages;
}

-(void)setNumberOfImages:(NSInteger)numberOfImages;
{
    if (numberOfImages != _numberOfImages) {
        _numberOfImages = numberOfImages;
        self.countLabel.text = [NSString stringWithFormat:@"%li",(long)_numberOfImages];
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.numberOfImages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    CPTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPTCollectionViewCell" forIndexPath:indexPath];
    cell.imageView.image = nil;
    
    UIImage *image = [self.images objectAtIndex:indexPath.item];
    cell.imageView.image = image;
    
    return cell;
}

#pragma mark - UISegmentedControl Method

- (IBAction)scrollDirectionChanged:(UISegmentedControl *)sender {
    
    NSInteger newValue = sender.selectedSegmentIndex;
    UICollectionViewScrollDirection scrollDirection = UICollectionViewScrollDirectionVertical;
    if (0 == newValue) {
        scrollDirection = UICollectionViewScrollDirectionVertical;
    } else if (1 == newValue) {
        scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    [(CPTMontageFlowLayout *)self.collectionView.collectionViewLayout setScrollDirection:scrollDirection];
}

#pragma mark - UISlider Method

- (IBAction)countSliderValueChanged:(id)sender {
    
    NSInteger newValue = (NSInteger)roundf([(UISlider *)sender value]);
    self.numberOfImages = newValue;
}

@end
