module Browser
  module Proxies
    module Chrome
      module ProxyAuthentication
                
        class Packager          
          def self.package_extension(proxy, path)
            file_id         =   Digest::SHA1.hexdigest("#{proxy[:username]}:#{proxy[:password]}@#{proxy[:host]}:#{proxy[:port]}")
            plugin_path     =   "#{path}/chrome-proxy-authentication-plugin-#{file_id}"
            FileUtils.mkdir_p plugin_path
            
            manifest_file   =   "#{plugin_path}/manifest.json"
            File.open(manifest_file, 'w') { |file| file.write(::Browsed::Proxies::Chrome::ProxyAuthentication::MANIFEST_JSON_TEMPLATE) }
            
            script_file     =   "#{plugin_path}/background.js"
            script_result   =   Browsed::Proxies::Chrome::ProxyAuthentication::BACKGROUND_SCRIPT_TEMPLATE % [proxy[:host], proxy[:port], proxy[:username], proxy[:password]]
            File.open(script_file, 'w') { |file| file.write(script_result) }
            
            return plugin_path
          end
        end
        
        MANIFEST_JSON_TEMPLATE =  <<-TEMPLATE
{
  "version": "1.0.0",
  "manifest_version": 2,
  "name": "Chrome Proxy",
  "permissions": [
    "proxy",
    "tabs",
    "unlimitedStorage",
    "storage",
    "<all_urls>",
    "webRequest",
    "webRequestBlocking"
  ],
  "background": {
    "scripts": ["background.js"]
  },
  "minimum_chrome_version":"22.0.0"
}
        TEMPLATE
        
        BACKGROUND_SCRIPT_TEMPLATE = <<-TEMPLATE
var config = {
  mode: "fixed_servers",
  rules: {
    singleProxy: {
      scheme: "http",
      host: "%s",
      port: parseInt(%s)
    },
    bypassList: ["localhost"]
  }
};

chrome.proxy.settings.set({value: config, scope: "regular"}, function() {});

function callbackFn(details) {
  return {
    authCredentials: {
      username: "%s",
      password: "%s"
    }
  };
}

chrome.webRequest.onAuthRequired.addListener(
  callbackFn,
  {urls: ["<all_urls>"]},
  ['blocking']
);
        TEMPLATE
        
      end
    end
  end
end