Pod::Spec.new do |s|
  s.name         = "SwiftyCrypto"
  s.version      = "0.0.2"
  s.summary      = "A library for Crypto using Swift"
  s.homepage     = "https://github.com/Wstunes/SwiftyCrypto"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Wstunes" => "wangshuogr@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Wstunes/SwiftyCrypto.git", :tag => s.version }
  s.source_files = 'Sources/**/*.swift'
  s.swift_version = '5.0'
end