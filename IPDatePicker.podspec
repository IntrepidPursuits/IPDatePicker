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

  s.homepage         = 'https://github.com/IntrepidPursuits/IPDatePicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrew Dolce' => 'andrew@intrepid.io' }
  s.source           = { :git => 'https://github.com/IntrepidPursuits/IPDatePicker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'IPDatePicker/Classes/**/*'
  
  s.dependency 'PureLayout'
  s.dependency 'Intrepid'
end
