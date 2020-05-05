#
# Be sure to run `pod lib lint CPTPhotoMontageView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CPTPhotoMontageView'
  s.version          = '0.1.0'
  s.summary          = 'Displays any number of photos within the visible bounds of your collectionView automatically.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'The CPTMontageFlowLayout class is designed to display photos in a defined view bounds. Within the provided space, the layout will determine the appropriate cell size to maximize the space usage for the given number of photos. Cells are arranged in rows & columns. Row height is consistent, but column width per row will vary depending on the number of cells to be displayed in the row. The effect is a fully utilized collectionView bounds area whether you are displaying 1 or 100 photos. The Layout currently supports a single section. Header & Footer views are not supported.'

  s.homepage         = 'https://github.com/ChronicStim/CPTPhotoMontageView.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'support@chronicstimulation.com' => 'support@chronicstimulation.com' }
  s.source           = { :git => 'https://github.com/ChronicStim/CPTPhotoMontageView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CPTPhotoMontageView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CPTPhotoMontageView' => ['CPTPhotoMontageView/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
