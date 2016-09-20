Pod::Spec.new do |spec|
  spec.name         = "DGElasticPullToRefresh"
  spec.version      = "1.1"
  spec.authors      = { "Danil Gontovnik" => "gontovnik.danil@gmail.com" }
  spec.homepage     = "https://github.com/gontovnik/DGElasticPullToRefresh"
  spec.summary      = "Elastic pull to refresh compontent developed in Swift"
  spec.source       = { :git => "https://github.com/gontovnik/DGElasticPullToRefresh.git",
                        :tag => '1.1' }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.platform     = :ios, '8.0'
  spec.source_files = "DGElasticPullToRefresh/*.swift"

  spec.requires_arc = true

  spec.ios.deployment_target = '8.0'
  spec.ios.frameworks = ['UIKit', 'Foundation']
end
