source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'LetsDinnerV2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LetsDinnerV2

end

target 'LetsDinnerV2 MessagesExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LetsDinnerV2 MessagesExtension
  
  pod 'Kingfisher', '~> 5.0'
  pod 'iMessageDataKit'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Crashlytics'
  pod 'RealmSwift'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'SnapKit', '~> 5.0.0'
  pod 'ReactiveSwift', '~> 6.1'
  pod 'ReactiveCocoa', '~> 10.1'
  pod 'SwiftyStoreKit'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
