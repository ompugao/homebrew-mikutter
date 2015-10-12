class Mikutter < Formula
  homepage "http://mikutter.hachune.net/"
  url "http://mikutter.hachune.net/bin/mikutter.3.2.8.tar.gz"
  sha256 "c14bf9d5b5c1503ca4c52c0d1998b4ec54a789e36f61c25720c01be75e5c6622"

  # Require ruby 2.0.0 or above
  depends_on "ruby" if /\d\.\d(\.\d)?/.match(`ruby --version 2>&1`).to_s < "2.0.0"
  depends_on "gtk+"
  depends_on :x11

  def install
    prefix.install Dir["./*"]
    prefix.cd do
      ENV["GEM_HOME"] = "#{Pathname.pwd}/gems"
      unless /true/ =~ `gem list --installed bundler` && /bundle/ =~ `which bundle`
        system "gem", "install", "bundler", "--no-ri", "--no-rdoc"
        ENV.prepend_path "PATH", "#{ENV["GEM_HOME"]}/bin"
      end
      system "bundle", "config", "--local", "build.nokogiri", "--",
          "--use-system-libraries",
          "--with-xml2-include=\"$(xcrun --show-sdk-path)/usr/include/libxml2\""
      system "bundle", "install"
    end
    open("mikutter.sh", "w+") do |script|
      script.puts "#!/bin/sh"
      script.puts "export GEM_HOME=#{ENV["GEM_HOME"]}"
      script.puts "ruby \"#{prefix}/mikutter.rb\" $@"
    end
    bin.install "mikutter.sh" => "mikutter"
  end

  test do
    # Test without running X11
    system "mikutter", "--help"

    # Test whether the GUI/X11 will launch completely
    ### NOTE: This test can't work fine. ###
    #system "mikutter", "-d"
    #sleep 20 # waiting for mikutter to launch
    #system "pkill", "-f", "mikutter"
  end
end
