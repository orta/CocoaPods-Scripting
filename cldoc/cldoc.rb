require 'cocoapods-core'
require 'cocoapods-downloader'
require 'cocoapods'
require 'set'

$podspec = "FXBlurView"
$podspec_version = "1.4.1"

# $podspec = "AFCache"
# $podspec_version = "0.0.1"

$cldoc = "/Users/orta/Library/Python/2.7/bin/cldoc"

# from cocoadocs
def headers_for_spec
  	download_location = Dir.getwd + "/download/#{@spec.name}/"
  	pathlist = Pod::Sandbox::PathList.new( Pathname.new(download_location) )  
  	headers = []

  	# https://github.com/CocoaPods/cocoadocs.org/issues/35
  	[@spec, *@spec.recursive_subspecs].each do |internal_spec|

  		internal_spec.available_platforms.each do |platform|
  			consumer = Pod::Specification::Consumer.new(internal_spec, platform)
  			accessor = Pod::Sandbox::FileAccessor.new(pathlist, consumer)
				  	
  			if accessor.public_headers
  				headers += accessor.public_headers.map{ |filepath| filepath.to_s }
	  		else
  				puts "Skipping headers for #{internal_spec} on platform #{platform} (no headers found)."
  			end
  		end
  	end

  	headers.uniq
  	p headers
end



spec_path = "../Specs/#{$podspec}/#{$podspec_version}/#{$podspec}.podspec"
@spec = eval(File.open(spec_path).read)

@download_location = "download/#{@spec.name}"
unless Dir.exists? @download_location
	
	downloader = Pod::Downloader.for_target(@download_location, @spec.source)
	downloader.download
	
	p "Downloaded Pod"  
end

fxblur = "-x objective-c -arch i386 -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -std=gnu99 -fmodules -fmodules-cache-path=/Users/orta/Library/Developer/Xcode/DerivedData/ModuleCache -Wno-trigraphs -fpascal-strings -O0 -Wno-missing-field-initializers -Wno-missing-prototypes -Werror=return-type -Wno-implicit-atomic-properties -Werror=deprecated-objc-isa-usage -Werror=objc-root-class -Wno-receiver-is-weak -Wno-arc-repeated-use-of-weak -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations -DDEBUG=1 -DCOCOAPODS=1 -isysroot /Applications/Xcode51-Beta3.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.1.sdk -fexceptions -fasm-blocks -fstrict-aliasing -Wprotocol -Wdeprecated-declarations -g -Wno-sign-conversion -fobjc-abi-version=2 -fobjc-legacy-dispatch -mios-simulator-version-min=7.0"

headers = headers_for_spec

command =  "#{ $cldoc } generate #{fxblur} -- --output html #{ headers.join " " } docs"
command =  "#{ $cldoc } generate #{fxblur} -- --output html #{ "download/FXBlurView/XFBlurView/FXBlurView.h" } docs"

p command
system command

