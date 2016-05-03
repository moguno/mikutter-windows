#coding: UTF-8

require "rubygems"
require "fileutils"
require "openssl"

# OpenSSLの証明書がアレなので、証明書の検証をすっ飛ばすよ。
# DNSが汚染されてたらがっかりですね。
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require File.join(Dir.pwd, "packaged", "core")


def install_plugin!(user, repo, slug = repo, &block)
  if !Packaged::Local::get_plugin_info_by_slug(slug)
    tgz = Packaged::Remote::get_repo_tarball(user, repo, "master")
    Packaged::Local::install_plugin_by_tgz(tgz, &block)
  end
end

def install_cool_plugins!
  if !File.exist?(Packaged::Local::PLUGIN_DIR)
    FileUtils.mkdir_p(Packaged::Local::PLUGIN_DIR)
  end

  install_plugin!("moguno", "mikutter-portable-path")
  install_plugin!("moguno", "mikutter-large-pic-twitter-com")
  install_plugin!("moguno", "mikutter-mac-de-emoji")
  install_plugin!("moguno", "mikutter-tab-hardpoint")
  install_plugin!("moguno", "mikutter-tall-replyviewer")
  install_plugin!("moguno", "mikutter-uwm-hommage")
  install_plugin!("moguno", "mikutter-subparts-image", "sub_parts_image") { |extracted_dir, plugin_dir|
    FileUtils.mv(File.join(extracted_dir, "for_3.2", "sub_parts_image"), plugin_dir)
    FileUtils.rm_rf(extracted_dir)
  }
end


if $0 == __FILE__
  install_cool_plugins!
end
