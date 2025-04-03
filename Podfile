platform :ios, '13.0'
use_frameworks!

target 'AcciontvUpload' do
	pod 'SwiftyJSON'
	pod 'SwiftValidator', :git => 'https://github.com/jpotts18/SwiftValidator.git', :branch => 'master'
	pod 'SQLite.swift', '0.11.5'
	pod 'BSImagePicker', '2.8'
	pod 'AWSS3', '~> 2.16.0'
	pod 'ReachabilitySwift'
	pod 'TaskQueue'
    pod 'ImagePicker', '3.1.0'
    pod 'SwipeCellKit', '2.4.3'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
            config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '13.0'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
            config.build_settings['ENABLE_BITCODE'] = 'YES' 
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
    end
end
