Pod::Spec.new do |s|
  s.name = 'KTSwiftExtensions'
  s.version = '0.4.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Swift extensions'

  s.homepage = 'https://github.com/kthomas/KTSwiftExtensions'
  s.authors = { 'Kyle Thomas' => 'k.thomas@unmarkedconsulting.com' }
  s.source = { :git => 'https://github.com/kthomas/KTSwiftExtensions.git', :tag => s.version }
  s.source_files = 'Source/**/*.swift'

  s.ios.deployment_target = '9.3'
  s.ios.dependency 'Alamofire'
  s.ios.dependency 'AlamofireObjectMapper'
  s.ios.dependency 'MBProgressHUD'
end
