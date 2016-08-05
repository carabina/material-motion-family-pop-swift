abstract_target 'MaterialMotionPopMotionFamily' do
  pod 'MaterialMotionRuntime' , :git => 'git@github.com:material-motion/material-motion-runtime-objc.git', :branch => 'develop'
  pod 'pop'

  pod 'MaterialMotionPopMotionFamily', :path => './'

  workspace 'MaterialMotionPopMotionFamily.xcworkspace'
  use_frameworks!

  target "Catalog" do
    project 'examples/apps/Catalog/Catalog.xcodeproj'
  end

  target "UnitTests" do
    project 'examples/apps/Catalog/Catalog.xcodeproj'
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |configuration|
        configuration.build_settings['SWIFT_VERSION'] = "3.0"
      end
    end
  end
end
