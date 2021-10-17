# Uncomment the next line to define a global platform for your project
#  platform :ios, '14.0'

target 'PoseStudy' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'PolarBleSdk', '~> 3.2'

  # Pods for PoseStudy

  target 'PoseStudyTests' do
    inherit! :search_paths
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
    # Pods for testing
  end

  target 'PoseStudyUITests' do
    # Pods for testing
  end

end

post_install do |installer|
        installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          end
        end
      end

