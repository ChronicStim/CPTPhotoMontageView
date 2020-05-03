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
< UICollectionViewDelegate, UICollectionViewDataSource, CPTMontageFlowLayoutDelegate >

@property (nonatomic, assign) NSInteger numberOfImages;
@property (nonatomic, strong) NSArray *images;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISlider *countSlider;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (IBAction)countSliderValueChanged:(id)sender;


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
    layout.headerReferenceSize = CGSizeMake(HEADER_SIZE, HEADER_SIZE);
    layout.footerReferenceSize = CGSizeMake(FOOTER_SIZE, FOOTER_SIZE);
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

#pragma mark - CPTMontageFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(CPTMontageFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.images objectAtIndex:indexPath.item] size];
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

/*
 - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 UICollectionReusableView *view = nil;
 
 if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
 view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
 }
 else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
 view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
 }
 
 return view;
 }
 */

#pragma mark - UISlider Method

- (IBAction)countSliderValueChanged:(id)sender {
    
    NSInteger newValue = (NSInteger)roundf([(UISlider *)sender value]);
    self.numberOfImages = newValue;
}

@end
