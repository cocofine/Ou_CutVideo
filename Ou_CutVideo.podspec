#
# Be sure to run `pod lib lint Ou_CutVideo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Ou_CutVideo'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Ou_CutVideo.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/CocoaPods/Specs.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1096438749@qq.com' => 'ouyangqi@haohaozhu.com' }
  s.source           = { :git => 'https://github.com/cocofine/Ou_CutVideo.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Ou_CutVideo/Classes/**/*'
  
  s.resource = 'Ou_CutVideo/CutResource.bundle'
#   s.resource_bundles = {
#     'CutResource' => ['Ou_CutVideo/Assets/*.png']
#   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
