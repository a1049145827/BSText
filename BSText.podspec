Pod::Spec.new do |spec|
  spec.name         = 'BSText'
  spec.version      = '3.0.0'
  spec.summary      = 'TextKit 2 Enhancement Framework for iOS'
  spec.description  = 'BSText 3 is a modern rich text framework built on top of TextKit 2. It enhances the system text engine with viewport rendering, fragment caching, async decorations, and rich text editing capabilities.'
  spec.homepage     = 'https://github.com/a1049145827/BSText'
  spec.author       = { 'Geek Bruce' => 'a1049145827@hotmail.com' }
  spec.social_media_url = 'https://a1049145827.github.io'
  spec.source       = { :git => 'https://github.com/a1049145827/BSText.git', :tag => spec.version.to_s }
  spec.platforms    = { :ios => '17.0' }
  spec.source_files = 'BSText/Sources/**/*.{swift,h,m}'
  spec.resource_bundles = {}
  spec.frameworks   = 'UIKit'
  spec.swift_version = '5.0'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
end
