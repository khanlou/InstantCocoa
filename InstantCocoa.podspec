Pod::Spec.new do |s|
  s.name     = 'InstantCocoa'
  s.version  = '0.1'
  s.license  = 'MIT'
  s.platform = :ios
  s.summary  = ''
  s.homepage = ''
  s.authors  = { 'Soroush Khanlou' => 'soroush@khanlou.com' }
  s.requires_arc = true

  s.source_files = 'InstantCocoa/InstantCocoa/**'
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'InstantCocoa/InstantCocoa/Core/*'
  end
  
  s.subspec 'Model' do |ss|
    ss.source_files = 'InstantCocoa/InstantCocoa/Model/*'
  end
  
  s.subspec 'View Controllers' do |ss|
    ss.source_files = 'InstantCocoa/InstantCocoa/View Controllers/*'
  end
  
  s.subspec 'Data Source' do |ss|
    ss.source_files = 'InstantCocoa/InstantCocoa/Data Source/*'
    ss.dependency 'AFNetworking', '~> 2.0'
    ss.dependency 'InstantCocoa/Model'
  end

end
