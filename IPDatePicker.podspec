#
# Be sure to run `pod lib lint IPDatePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IPDatePicker'
  s.version          = '0.1.0'
  s.summary          = 'A customizable alternative to UIDatePicker.'

  s.description      = <<-DESC
                       IPDatePicker is an alternative to Apple's UIDatePicker control. It aims to provide the same level of out-of-the-box localization as UIDatePicker, but while also allowing for complete customization of the UI.
                       DESC

  s.homepage         = 'https://github.com/andrewdolce/IPDatePicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'andrewdolce' => 'andrew@intrepid.io' }
  s.source           = { :git => 'https://github.com/andrewdolce/IPDatePicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'IPDatePicker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IPDatePicker' => ['IPDatePicker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'PureLayout'
  s.dependency 'Intrepid'
end
